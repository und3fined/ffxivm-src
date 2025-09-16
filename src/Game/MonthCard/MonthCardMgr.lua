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

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local MonthCardDefine = require("Game/MonthCard/MonthCardDefine")
local ActivityCfg = require("TableCfg/ActivityCfg")
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

end

function MonthCardMgr:OnRegisterGameEvent()
	-- 游戏内事件
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnMonthCardModuleOpen)
end

function MonthCardMgr:OnGameEventLoginRes()
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

	if not self.IsPaying then
	self.IsPaying = true
	self.CurrentRequestOrder = Order
	self.CurrentRequestCrystas = Crystas
	self.CurrentRequestBonus = Bonus
	self.CurrentRequestSum = Crystas + Bonus
	PayUtil.BuyCoins(Order,
	function(_, BillData) self:OnBillReceived(BillData) end,
	function(_) self:OnLoginExpired() end,
	nil, --- -- 切后台可能导致米大师回调丢失，不再使用
	function(_, GoodsData) self:OnGoodsReceived(GoodsData) end,
	View)
	end
end

function MonthCardMgr:OnBillReceived(BillData)
	if BillData == nil then
		FLOG_ERROR("Cannot get pay bill data")
		return
	end

	if BillData.URL == "" then
		FLOG_ERROR("Pay bill is empty")
	end
	self.IsPaying = false
end

function MonthCardMgr:OnLoginExpired()
	FLOG_ERROR("Login expired!")
	self.IsPaying = false
end

function MonthCardMgr:OnPayFinished(PayReturnData)
	if PayReturnData == nil then
		FLOG_ERROR("Cannot get pay return data")
		return
	end

	if PayReturnData.ResultCode == 0 then
		FLOG_INFO("Pay succeeded.")
		if not self.ReceivedGoods then
			FLOG_INFO("Waiting for goods...")
			self.PayFinished = true
		else
			self:OnRechargeSucceed(self.CurrentRequestSum)
		end
	end
end

function MonthCardMgr:OnGoodsReceived(GoodsData)
	self:OnRechargeSucceed()
end

function MonthCardMgr:OnRechargeSucceed(Quantity)
	-- FLOG_INFO("Recharge succeeded. Append %d crystas", Quantity)

	self.ReceivedGoods = false
	self.PayFinished = false
	self.IsPaying = false
end


--- 红点
function MonthCardMgr:SetRedDot()
	local Cfg = ActivityCfg:FindCfgByKey(MonthCardMgr.ActiviyID)
	if Cfg ~= nil then
		_G.OpsActivityMgr:UpdateActivityRedDot(Cfg.ClassifyID, Cfg)
	end
end


--要返回当前类
return MonthCardMgr