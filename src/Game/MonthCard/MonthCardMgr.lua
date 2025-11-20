--
--Author: ZhengJanChuan
--Date: 2023-11-14 15:53
--Description:月卡管理器
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local ProtoCS = require("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local PayUtil = require("Utils/PayUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.MonthCardCmd
local CS_PAY_CMD = ProtoCS.CS_PAY_CMD

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local MonthCardDefine = require("Game/MonthCard/MonthCardDefine")
local ActivityCfg = require("TableCfg/ActivityCfg")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local LSTR
local GameNetworkMgr
local EventMgr
local UIViewMgr
local FLOG_INFO
local FLOG_ERROR


---@class MonthCardMgr : MgrBase
local MonthCardMgr = LuaClass(MgrBase)

MonthCardMgr.ActiviyID = 107

---OnInit
function MonthCardMgr:OnInit()
	self.VaildTime = 0 -- 月卡有效期时间戳
	self.DailyRewardNum = 0 -- 月卡奖励可领取次数(会累积)
	self.DataValidTime = 0 -- 数据有效性时间戳
	self.ReceivedGoods = false
	self.PayFinished = false
	self.MonthCardOverdueTimer = nil
	self.IsPaying = false  --是否正在支付中
	self.CurrentProductID = ""
	self.OrderToken = ""
	self.CurrentRequestOrder = 0
end

---OnBegin
function MonthCardMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
	UIViewMgr = _G.UIViewMgr
	FLOG_INFO = _G.FLOG_INFO
	FLOG_ERROR = _G.FLOG_ERROR
	LSTR = _G.LSTR
end

function MonthCardMgr:OnEnd()
end

function MonthCardMgr:OnShutdown()
end

function MonthCardMgr:OnRegisterNetMsg()
	-- 网络协议
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MONTH_CARD, SUB_MSG_ID.MonthCardCmd_Status, self.OnGetMonthCardDataRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MONTH_CARD, SUB_MSG_ID.MonthCardCmd_DailyReward, self.OnGetMonthCardDayRewardRsq)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MONTH_CARD, SUB_MSG_ID.MonthCardCmd_RechargePreCheck, self.OnBuyMonthCardCheckRsq)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MONTH_CARD, SUB_MSG_ID.MonthCardCmd_RewardShow, self.OnPushRewardShow)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)

end

function MonthCardMgr:OnRegisterGameEvent()
	-- 游戏内事件
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnMonthCardModuleOpen)
	self:RegisterGameEvent(EventID.AppEnterBackground, self.ResetPaying)
	self:RegisterGameEvent(EventID.AppEnterForeground, self.ResetPaying)
end

function MonthCardMgr:OnNetMsgError(MsgBody)
	local Msg = MsgBody
    if nil == Msg then
        return
    end

    local ErrorCode = Msg.ErrCode

	if Msg.Cmd and Msg.SubCmd and Msg.Cmd == CS_CMD.CS_CMD_PAY and Msg.SubCmd == CS_PAY_CMD.CS_CMD_PAY_DISTRIBUTE_ORDER then
		self.IsPaying = false
	end

	if ErrorCode and ErrorCode == 135851 then
		self.IsPaying = false
	end
end

function MonthCardMgr:OnGameEventLoginRes(Params)
	if nil ~= Params and nil ~= Params.bReconnect and Params.bReconnect == true then
		_G.FLOG_INFO("MonthCardMgr:OnGameEventLoginRes, bReconnect is true")
		if self.CurrentProductID ~= "" then
			-- 断线重连时，可能有未收到完成通知的订单，需要重新查询状态
			_G.RechargingMgr:SendPayResultToServer(self.CurrentProductID, false, self.OrderToken)
		end
	end
	if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard) then
		self:SendMonthCardDataReq()
	end
	self.IsPaying = false
	-- _G.FLOG_INFO(string.format("MonthCardMgr self.IsPaying is %s", tostring(self.IsPaying )))
end

function MonthCardMgr:OnMonthCardModuleOpen(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDMonthCard then
		self:SendMonthCardDataReq()
	end
end

function MonthCardMgr:ResetPaying()
	self.IsPaying = false
end

------------------------------------------- 协议 ----------------------------------

--- 登录/打开界面，请求月卡数据请求
function MonthCardMgr:SendMonthCardDataReq()
	local MsgID = CS_CMD.CS_CMD_MONTH_CARD
    local SubMsgID = SUB_MSG_ID.MonthCardCmd_Status

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 月卡数据回调
function MonthCardMgr:OnGetMonthCardDataRsp(MsgBody)
	if nil == MsgBody then
        return
    end

	local Data = MsgBody.Status

	self.VaildTime = Data.ValidTime
	self.DailyRewardNum = Data.DailyRewardNum
	self.DataValidTime = Data.DataValidTime

	self:SetRedDot()

	EventMgr:SendEvent(EventID.MonthCardUpdate)

	if self.MonthCardOverdueTimer ~= nil then
		self:UnRegisterTimer(self.MonthCardOverdueTimer)
		self.MonthCardOverdueTimer = nil
	end

	-- 定时器逻辑
	if MonthCardMgr:GetMonthCardStatus() then
		self.MonthCardOverdueTimer = self:RegisterTimer(self.OnMonthCardOverdue, 0, 1, -1)
	end
end



function MonthCardMgr:OnMonthCardOverdue()
	local Time = TimeUtil.GetServerLogicTime()
	if Time > MonthCardMgr:GetMonthCardValidTime() then
		MonthCardMgr:SendMonthCardDataReq()
		self:UnRegisterTimer(self.MonthCardOverdueTimer)
		self.MonthCardOverdueTimer = nil
	end
end

--- 请求领取月卡每日奖励
function MonthCardMgr:SendGetMonthCardDayRewardReq()
	local MsgID = CS_CMD.CS_CMD_MONTH_CARD
    local SubMsgID = SUB_MSG_ID.MonthCardCmd_DailyReward

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 月卡奖励回调
function MonthCardMgr:OnGetMonthCardDayRewardRsq(MsgBody)

	if nil == MsgBody then
		return
	end

	self.DailyRewardNum = 0

	self:SetRedDot()

	EventMgr:SendEvent(EventID.MonthCardUpdate)
end

--- 发送购买月卡
function MonthCardMgr:SendBuyMonthCardCheckReq()
	local MsgID = CS_CMD.CS_CMD_MONTH_CARD
    local SubMsgID = SUB_MSG_ID.MonthCardCmd_RechargePreCheck

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 购买月卡成功回调
function MonthCardMgr:OnBuyMonthCardCheckRsq(MsgBody)
	if nil == MsgBody then
        return
    end

	local Data = MsgBody.Status

	if nil == Data then
		return
	end

	self.VaildTime = Data.ValidTime
	self.DailyRewardNum = Data.DailyRewardNum
	self.DataValidTime = Data.DataValidTime

	self:SetRedDot()

	local Cfg = ActivityCfg:FindCfgByKey(MonthCardMgr.ActiviyID)
	if Cfg ~= nil then
		self:UpdateActivityRedDot(Cfg.ClassifyID, Cfg)
	end

	EventMgr:SendEvent(EventID.MonthCardUpdate)
	self.IsPaying = false
end


--- 奖励展示推送
function MonthCardMgr:OnPushRewardShow(MsgBody)
	if nil == MsgBody then
        return
    end
	
	-- 服务器数据
	local Params = {}
	Params.ItemList = {}
    Params.Title = _G.LSTR(840010)
	local Data = MsgBody.RewardShow.ItemList

	for _, v  in ipairs(Data) do
		table.insert(Params.ItemList, { ResID = v.ItemID, Num = v.ItemNum})
	end

	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
	self.IsPaying = false
	MonthCardMgr:SendMonthCardDataReq()
end

---------------------------------- 对外接口 -------------------------------------------
---@return Status boolean 返回月卡有效期时间戳(秒)
function MonthCardMgr:GetMonthCardStatus()
	local LocalTimeStamp = TimeUtil.GetServerLogicTime()
	return self.VaildTime > LocalTimeStamp
end

---@return Status boolean 返回月卡是否能领奖
function MonthCardMgr:GetMonthCardReward()
	return self.DailyRewardNum > 0
end

function MonthCardMgr:GetDailyRewardNum()
	return self.DailyRewardNum
end

function MonthCardMgr:GetMonthCardValidTime()
	return self.VaildTime
end

function MonthCardMgr:GetMonthCardRemainTime()
	if self.VaildTime == 0 or type(self.VaildTime) ~= "number" then
		return 0
	end

	local LocalTimeStamp = TimeUtil.GetServerLogicTime()
	local VaildTimeStamp = MonthCardMgr:GetMonthCardValidTime()
	local RemainTimeStamp = VaildTimeStamp - LocalTimeStamp
	return RemainTimeStamp > 0 and RemainTimeStamp or  0
end

--@return timestamp 
function MonthCardMgr:GetDataValidTime()
	return self.DataValidTime
end

--- 购买月卡
function MonthCardMgr:BuyMonthCard(Order, Crystas, Bonus, View)
	FLOG_INFO("MonthCardMgr amount: "..tostring(Order))
	FLOG_INFO("MonthCardMgr amount: "..tostring(Crystas))
	FLOG_INFO("MonthCardMgr bonus: "..tostring(Bonus))

	_G.FLOG_INFO(string.format("MonthCardMgr:BuyMonthCard self.IsPaying  %s", tostring(self.IsPaying)))
	if not self.IsPaying then
	self.IsPaying = true
	self.CurrentRequestOrder = Order
	self.CurrentRequestCrystas = Crystas
	self.CurrentRequestBonus = Bonus
	self.CurrentRequestSum = Crystas + Bonus
	PayUtil.BuyCoins(Order,
	function(_, BillData) self:OnBillReceived(BillData) end,
	function(_) self:OnLoginExpired() end,
	function(_, PayReturnData) self:OnPayFinished(PayReturnData) end,
	function(_, GoodsData) self:OnGoodsReceived(GoodsData) end,
	View)
	self.CurrentProductID = PayUtil.GetProductID(Order)
	end
end

function MonthCardMgr:OnBillReceived(BillData)
	if BillData == nil then
		FLOG_ERROR("MonthCardMgr:OnBillReceived, Cannot get pay bill data")
		return
	end

	if string.isnilorempty(BillData.Token) then
		FLOG_ERROR("MonthCardMgr:OnBillReceived, Pay token is empty")
	else
		self.OrderToken = BillData.Token
	end

	if BillData.URL == "" then
		FLOG_ERROR("MonthCardMgr:OnBillReceived, Pay bill is empty")
	end
	-- self.IsPaying = false
end

function MonthCardMgr:OnLoginExpired()
	FLOG_ERROR("Login expired!")
	self.IsPaying = false
end

function MonthCardMgr:OnPayFinished(PayReturnData)
	local IsPaySuccess = true
	if PayReturnData == nil then
		_G.FLOG_ERROR("MonthCardMgr:OnPayFinished, Cannot get pay return data")
		IsPaySuccess = false
	else
		if PayReturnData.ResultCode == 0 then
			_G.FLOG_INFO("MonthCardMgr:OnPayFinished, Pay succeeded.")
			--self.CurrentProductID = ""
			local TipsContent = string.format(_G.LSTR(940042), PayUtil.GetProductTypeName(self.CurrentRequestOrder))
			MsgTipsUtil.ShowTips(TipsContent)
		else
			IsPaySuccess = false
		end
	end
    _G.RechargingMgr:SendPayResultToServer(self.CurrentProductID, IsPaySuccess, self.OrderToken)
end

function MonthCardMgr:OnGoodsReceived(GoodsData)
	self:OnRechargeSucceed()
	self.CurrentProductID = ""
	self.OrderToken = ""
end

function MonthCardMgr:OnRechargeSucceed(Quantity)

	self.ReceivedGoods = false
	self.PayFinished = false
	self.IsPaying = false
end


--- 红点
function MonthCardMgr:SetRedDot()
	--更新活动系统的红点
	local Cfg = ActivityCfg:FindCfgByKey(MonthCardMgr.ActiviyID)
	if Cfg ~= nil then
		_G.OpsActivityMgr:UpdateActivityRedDot(Cfg.ClassifyID, Cfg)
	end

	--更新月卡增加的红点
	local Status = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard) and MonthCardMgr:GetMonthCardStatus() and MonthCardMgr:GetMonthCardReward()
	if Status then
		RedDotMgr:AddRedDotByID(MonthCardDefine.RedDefines.MonthCard)
	else
		RedDotMgr:DelRedDotByID(MonthCardDefine.RedDefines.MonthCard)
	end
end


--要返回当前类
return MonthCardMgr