local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")

local EventID = require("Define/EventID")
local TradeMarketSystemParamCfg = require("TableCfg/TradeMarketSystemParamCfg")
local ProtoRes = require("Protocol/ProtoRes")
local RichTextUtil = require("Utils/RichTextUtil")
local ScoreCfg = require("TableCfg/ScoreCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local TradeMarketGoodsCfg = require("TableCfg/TradeMarketGoodsCfg")
local MonthcardGlobalCfg = require("TableCfg/MonthcardGlobalCfg")
local TimeUtil = require("Utils/TimeUtil")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local MarketDefine = require("Game/Market/MarketDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")
local LSTR
local GameNetworkMgr
local EventMgr
local ChatMgr
local MsgTipsUtil
local MonthCardMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.MarketOptCmd

---@class MarketMgr : MgrBase
local MarketMgr = LuaClass(MgrBase)

---OnInit
function MarketMgr:OnInit()
end

---OnBegin
function MarketMgr:OnBegin()
	LSTR = _G.LSTR
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
	ChatMgr = _G.ChatMgr
	MsgTipsUtil = _G.MsgTipsUtil
	MonthCardMgr = _G.MonthCardMgr

	--免费摊位数量
	local FreeStallCfg = TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_FREE_STALL) 
	if nil ~= FreeStallCfg then
		self.FreeStallNum = FreeStallCfg.Value[1]
	end
	--月卡摊位数量
	local MonthCardStallCfg = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalAddTradeStall)
	if nil ~= MonthCardStallCfg then
		self.MonthCardStallNum = MonthCardStallCfg.Value[1]
	end

	local TradeTaxCfg =  MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalInvalidTradeTax)
	if nil ~= TradeTaxCfg then
		self.NormalTradeTax = TradeTaxCfg.Value[1] / 100
	end
	
	local TradeTaxWithMonthCard = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalValidTradeTax)
	if nil ~= TradeTaxWithMonthCard then
		self.MonthCardTradeTax = TradeTaxWithMonthCard.Value[1] / 100
	end

	--关注数量上限
	local ConcernCfg = TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_WATCH_MAX)
	if nil ~= ConcernCfg then
		self.ConcernNum = ConcernCfg.Value[1]
	end

	--售价浮动比例
	local PriceGearPersentCfg = TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_PRICE_GEAR_PERSENT)
	if nil ~= PriceGearPersentCfg then
		self.PriceGearPersent = PriceGearPersentCfg.Value[1]
	end

	--最高售价
	local PriceSellMaxCfg =TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_SHOW_MONEY_MAX)
	if nil ~= PriceSellMaxCfg then
		self.PriceSellMax = PriceSellMaxCfg.Value[1]
	end

	--单次最高售卖数量
	local OnceSellNumMaxCfg = TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_ONCE_SALE_ITEM_MAX)
	if nil ~= OnceSellNumMaxCfg then
		self.OnceSellNumMax = OnceSellNumMaxCfg.Value[1]
	end

	self.SaleGoodCache = {}
	self.NotShowBatchOffMsgTip = false
	self.NotShowBatchOnMsgTip = false

	self.StallListOnePageNum = 6
end

function MarketMgr:OnEnd()
end

function MarketMgr:OnShutdown()
end

function MarketMgr:OnRegisterNetMsg()
	--示例代码先注释 以免影响正常逻辑
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_Status, self.OnNetMsgStallStatusRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_Sale, self.OnNetMsgSaleGoodRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_Close, self.OnNetMsgCloseSaleGoodsRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_Money, self.OnNetMsgGetBackMoneyRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_Price, self.OnNetMsgReferencePriceRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_QueryGoods, self.OnNetMsgTypeQueryRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_Buy, self.OnNetMsgBuyGoodsRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_Follow, self.OnNetMsgConcernGoodsRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_ListRecords, self.OnNetMsgRecordListRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_ListStalls, self.OnNetMsgListStallsRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_ReSale, self.OnNetMsgReSaleGoodRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_Login, self.OnNetMsgMarketLogin)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_BatchReSale, self.OnNetMsgBatchReSaleGoodRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_BatchClose, self.OnNetMsgBatchCloseSaleGoodsRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKET, SUB_MSG_ID.MarketOptCmd_StallChgNtf, self.OnNetMsgStallChgNtfRsp)
	

end

function MarketMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.MonthCardUpdate, self.OnMonthCardUpdate)
end

function MarketMgr:OnGameEventLoginRes(Params)
	self:SendMarketLoginMessage()
end

function MarketMgr:OnMonthCardUpdate()
	if self.RecordIsOpenMonthCard == nil then
		self.RecordIsOpenMonthCard = MonthCardMgr:GetMonthCardStatus() == true
	else
		local IsOpenMonthCard = MonthCardMgr:GetMonthCardStatus() == true
		if self.RecordIsOpenMonthCard == false and  IsOpenMonthCard == true then
			self.PlayAnimMonthCardUnlock = true
			self.RecordIsOpenMonthCard = IsOpenMonthCard
		end
	end
end

function MarketMgr:OnNetMsgSaleGoodRsp(MsgBody)
	local Msg = MsgBody.Sale
	if nil == Msg then
		return
	end
	table.insert(self.StallItemList, Msg.Stall)
	table.sort(self.StallItemList, self.SortStallItemList)
	EventMgr:SendEvent(EventID.MarketStallInfoUpdata)

	self.SaleGoodCache[Msg.Stall.ResID] = {Price = Msg.Stall.SinglePrice, Num = Msg.Stall.TotalNum} 

	MsgTipsUtil.ShowTips(LSTR(1010001))
end

function MarketMgr:OnNetMsgReSaleGoodRsp(MsgBody)
	local Msg = MsgBody.ReSale
	if nil == Msg then
		return
	end
	local Stall = Msg.Stall or {}
	for i, v in ipairs(self.StallItemList) do
		if v.SellID == Stall.SellID then
			v.SoldNum = Stall.SoldNum
			v.ResID = Stall.ResID
			v.TotalNum = Stall.TotalNum
			v.SinglePrice = Stall.SinglePrice
			v.ExpireTick = Stall.ExpireTick
			v.TaxRate = Stall.TaxRate
			v.BackedMoney = Stall.BackedMoney
			break
		end
	end
	EventMgr:SendEvent(EventID.MarketStallInfoUpdata)
	self.SaleGoodCache[Stall.ResID] = {Price = Stall.SinglePrice, Num = Stall.TotalNum} 
	MsgTipsUtil.ShowTips(LSTR(1010002))

	if self:HasBatchOnOrOffStall() and not self.NotShowBatchOnMsgTip then
		local Params = { bUseNever = true,  NeverMindText = LSTR(1160073), bUseTips = true,
		TipsText = LSTR(1010100) } --下次登陆不再提醒

		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1010098),  LSTR(1010099),
				function(_, Info)
					--一键上架所有过期摊位
					self.NotShowBatchOnMsgTip = Info and Info.IsNeverAgain == true or false
					self:SendBatchReSaleItemMessage()
				end
				, nil, LSTR(980007), LSTR(980035), Params)--取消 确定
	end
end

function MarketMgr:OnNetMsgBatchReSaleGoodRsp(MsgBody)
	local Msg = MsgBody.BatchReSale
	if nil == Msg then
		return
	end
	local Rsps = Msg.Rsps or {}
	for _, Rsp in ipairs(Rsps) do
		local Stall = Rsp.Stall
		for _, v in ipairs(self.StallItemList) do
			if v.SellID == Stall.SellID then
				v.SoldNum = Stall.SoldNum
				v.ResID = Stall.ResID
				v.TotalNum = Stall.TotalNum
				v.SinglePrice = Stall.SinglePrice
				v.ExpireTick = Stall.ExpireTick
				v.TaxRate = Stall.TaxRate
				v.BackedMoney = Stall.BackedMoney
				break
			end
		end
	end

	EventMgr:SendEvent(EventID.MarketStallInfoUpdata)
	MsgTipsUtil.ShowTips(LSTR(1010103))

end

function MarketMgr.SortStallItemList(Left, Right)
    local LeftScore = Left.ExpireTick
    local RightScore = Right.ExpireTick

    return LeftScore < RightScore
end

function MarketMgr:OnNetMsgMarketLogin(MsgBody)
	local Msg = MsgBody.Login
	if nil == Msg then
		return
	end
	self.FollowResIDs = Msg.FollowResIDs or {}        --关注列表
	self.StallItemList = Msg.StallList or {}          --摊位
	table.sort(self.StallItemList, self.SortStallItemList)

	local MajorUtil = require("Utils/MajorUtil")
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if RoleSimple then
		local ServerTime = TimeUtil.GetServerTime()
    	local CurDayZeroTime = TimeUtil.GetCurTimeStampZero(ServerTime)
		if type(RoleSimple.LogoutTime) == "number" then
			FLOG_INFO("MarketMgr:OnNetMsgMarketLogin, CurDayZeroTime = %d, RoleSimple.LogoutTime = %d", CurDayZeroTime, RoleSimple.LogoutTime)
			local LogoutDayZeroTime = RoleSimple.LogoutTime > 0 and TimeUtil.GetCurTimeStampZero(RoleSimple.LogoutTime) or 0
			if CurDayZeroTime ~= LogoutDayZeroTime then
				for _, V in ipairs(self.StallItemList) do
					if V.ExpireTick < TimeUtil.GetServerTime() then
						ChatMgr:AddSysChatMsg(string.format(LSTR(1010003), ItemCfg:GetItemName(V.ResID), V.TotalNum))
					end
				end
			end
		end
	end
	
	self:UpdateRedDot()
end

function MarketMgr:OnNetMsgStallStatusRsp(MsgBody)
	local Msg = MsgBody.Status
	if nil == Msg then
		return
	end
	self.StallItemList = Msg.StallList or {}
	table.sort(self.StallItemList, self.SortStallItemList)
	EventMgr:SendEvent(EventID.MarketStallInfoUpdata)

	self:UpdateRedDot()
end

function MarketMgr:UpdateRedDot()
	if self:HasStallExpired() or self:GetAllStallIncome() > 0 then
		RedDotMgr:AddRedDotByID(MarketDefine.MarketRedDotID.Stall)
	else
		RedDotMgr:DelRedDotByID(MarketDefine.MarketRedDotID.Stall)
	end
end


function MarketMgr:OnNetMsgCloseSaleGoodsRsp(MsgBody)
	local Msg = MsgBody.Close
	if nil == Msg then
		return
	end

	for i, v in ipairs(self.StallItemList) do
		if v.SellID == Msg.SellID then
			table.remove(self.StallItemList, i)
			break
		end
	end

	table.sort(self.StallItemList, self.SortStallItemList)
	EventMgr:SendEvent(EventID.MarketStallInfoUpdata)
	self:UpdateRedDot()
	MsgTipsUtil.ShowTips(LSTR(1010105))

	if self:HasBatchOnOrOffStall() and not self.NotShowBatchOffMsgTip then
		local Params = { bUseNever = true,  NeverMindText = LSTR(1160073)} --下次登陆不再提醒
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1010101),  LSTR(1010102),
				function(_, Info)
					self.NotShowBatchOffMsgTip = Info and Info.IsNeverAgain == true or false
					--一键下架所有过期摊位
					self:SendBatchCloseSaleMessage()
				end
				, nil, LSTR(980007), LSTR(980035), Params)--取消 确定

	end
end

function MarketMgr:OnNetMsgBatchCloseSaleGoodsRsp(MsgBody)
	local Msg = MsgBody.BatchClose
	if nil == Msg then
		return
	end

	local Rsps = Msg.Rsps or {}
	for _, Rsp in ipairs(Rsps) do
		local SellID = Rsp.SellID
		for i, v in ipairs(self.StallItemList) do
			if v.SellID == SellID then
				table.remove(self.StallItemList, i)
				break
			end
		end
	end

	table.sort(self.StallItemList, self.SortStallItemList)
	EventMgr:SendEvent(EventID.MarketStallInfoUpdata)
	MsgTipsUtil.ShowTips(LSTR(1010104))
	self:UpdateRedDot()

end

function MarketMgr:OnNetMsgStallChgNtfRsp(MsgBody)
	local Msg = MsgBody.StallChgNtf
	if nil == Msg then
		return
	end
	if self.StallItemList == nil then
		return
	end
	local Stalls = Msg.Stalls or {}
	for _, Stall in ipairs(Stalls) do
		for _, v in ipairs(self.StallItemList) do
			if v.SellID == Stall.SellID then
				v.SoldNum = Stall.SoldNum
				v.ResID = Stall.ResID
				v.TotalNum = Stall.TotalNum
				v.SinglePrice = Stall.SinglePrice
				v.ExpireTick = Stall.ExpireTick
				v.TaxRate = Stall.TaxRate
				v.BackedMoney = Stall.BackedMoney
				break
			end
		end
	end

	EventMgr:SendEvent(EventID.MarketStallInfoUpdata)
	self:UpdateRedDot()
end


function MarketMgr:OnNetMsgGetBackMoneyRsp(MsgBody)
	local Msg = MsgBody.Money
	if nil == Msg then
		return
	end

	local ReserveList = {}
	for _, v in ipairs(self.StallItemList) do
		for _, w in ipairs(Msg.ChangeList) do
			if v.SellID == w.SellID then
				v.SoldNum = w.SoldNum
				v.BackedMoney = w.BackedMoney
			end
		end
		if  v.TotalNum * v.SinglePrice - v.BackedMoney > 0 then
			table.insert(ReserveList, v)
		end
	end

	self.StallItemList = ReserveList
	table.sort(self.StallItemList, self.SortStallItemList)
	EventMgr:SendEvent(EventID.MarketReceiveMoney)
	MsgTipsUtil.ShowTips(LSTR(1010004))

	self:UpdateRedDot()
	--MarketMgr:ShowSysChatObtainScoreMsg(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE, Msg.AllMoney)
end

function MarketMgr:OnNetMsgReferencePriceRsp(MsgBody)
	local Msg = MsgBody.Price
	if nil == Msg then
		return
	end
	EventMgr:SendEvent(EventID.MarketReferencePriceUpdata, Msg)
end

function MarketMgr:OnNetMsgTypeQueryRsp(MsgBody)
	local Msg = MsgBody.QueryGoods
	if nil == Msg then
		return
	end
	self.GoodsList = Msg.GoodsList or {}
	table.sort(self.GoodsList, function(l, r) 
		local Hasl = l.AllSellNum > 0
		local Hasr = r.AllSellNum > 0
		if Hasl == Hasr then
			local Cfgl = TradeMarketGoodsCfg:FindCfgByKey(l.ResID) or {}
			local Cfgr = TradeMarketGoodsCfg:FindCfgByKey(r.ResID) or {}
			local Orderl = Cfgl.ShowOrderID
    		local Orderr = Cfgr.ShowOrderID

			if Orderl == Orderr then
				return Cfgl.ResID < Cfgr.ResID
			end

    		return Orderl < Orderr
		end
		return Hasl
	end)

	EventMgr:SendEvent(EventID.MarketTypeQueryGoods)
end


function MarketMgr:OnNetMsgBuyGoodsRsp(MsgBody)
	if MsgBody.ErrorCode then
		EventMgr:SendEvent(EventID.MarketRefreshBuyPage)
        return 
    end

	local Msg = MsgBody.Buy
	if nil == Msg then
		return
	end
	EventMgr:SendEvent(EventID.MarketRefreshBuyPage)
	MsgTipsUtil.ShowTips(LSTR(1010005))
end

function MarketMgr:OnNetMsgConcernGoodsRsp(MsgBody)
	local Msg = MsgBody.Follow
	if nil == Msg then
		return
	end

	if self.FollowResIDs == nil then
		self.FollowResIDs = {}
	end

	if Msg.Cancel == false then
		MsgTipsUtil.ShowTips(LSTR(1010006))
		table.insert(self.FollowResIDs, Msg.ResID)
	else
		for pos, v in ipairs(self.FollowResIDs) do
			if v == Msg.ResID then
				table.remove(self.FollowResIDs, pos)
				break
			end
		end
		MsgTipsUtil.ShowTips(LSTR(1010007))
	end
	
	EventMgr:SendEvent(EventID.MarketRefreshConcernInfo)
end

function MarketMgr:OnNetMsgListStallsRsp(MsgBody)
	local Msg = MsgBody.ListStalls
	if nil == Msg then
		return
	end
	self.StallBriefNum = Msg.Sum
	--[[local Bgein = Msg.Begin < Msg.End and Msg.Begin or Msg.End
	for index, value in ipairs(Msg.Stalls) do
		Msg.Stalls[index].Index = Bgein + index
	end]]--
	EventMgr:SendEvent(EventID.MarketRefreshStallBriefList, {Begin = Msg.Begin, End = Msg.End, Stalls = Msg.Stalls})
end

function MarketMgr:OnNetMsgRecordListRsp(MsgBody)
	local Msg = MsgBody.ListRecords
	if nil == Msg then
		return
	end

	EventMgr:SendEvent(EventID.MarketRecordList, {AllNum = Msg.AllNum, RecordList = Msg.RecordList})
end

--- 请求摊位数据
function MarketMgr:SendStallStatusMessage()
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_Status
	local MsgBody = { Cmd = SUB_MSG_ID.MarketOptCmd_Status }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求上架
function MarketMgr:SendSaleItemMessage(GID, ResID, Price, Num, Index)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_Sale
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_Sale,
		Sale = { GID = GID, ResID = ResID, SinglePrice = Price, Num = Num, ContainerIndex = Index },
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求重新上架
function MarketMgr:SendReSaleItemMessage(ResID, SellID, Num, Price)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_ReSale
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_ReSale,
		ReSale = { ResID = ResID, SellID = SellID, TotalNum = Num, SinglePrice = Price},
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--请求批量
function MarketMgr:SendBatchReSaleItemMessage()
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_BatchReSale
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_BatchReSale,
		BatchReSale = {},
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求下架
function MarketMgr:SendCloseSaleItemMessage(SellGID, ResID)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_Close
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_Close,
		Close = { SellID = SellGID, ResID = ResID},
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MarketMgr:SendBatchCloseSaleMessage()
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_BatchClose
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_BatchClose,
		BatchClose = {},
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求取回金币
function MarketMgr:SendGetBackMoneyMessage(SellInfos)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_Money
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_Money,
		Money = { GetList = SellInfos},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求获取市场参考价
function MarketMgr:SendReferencePriceMessage(ResID)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_Price
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_Price,
		Price = { ResID = ResID},
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求按分类查询
function MarketMgr:SendTypeQueryMessage(ItemResIDs)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_QueryGoods
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_QueryGoods,
		QueryGoods = {ResIDList = ItemResIDs}
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MarketMgr:SendBuyGoodsMessage(SellID, ResID, Num, Price)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_Buy
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_Buy,
		Buy = {SellID = SellID, ResID = ResID, BuyNum = Num, BuyPrice = Price}
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MarketMgr:SendMarketLoginMessage()
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_Login
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_Login,
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MarketMgr:SendConcernGoodsMessage(ResID, Cancel)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_Follow
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_Follow,
		Follow = {ResID = ResID, Cancel = Cancel}
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 请求数量默认200 之后有枚举定义
function MarketMgr:SendRecordListMessage(Begin, Type)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_ListRecords
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_ListRecords,
		ListRecords = {Type = Type, BeginIndex = Begin, EndIndex = Begin + 100}
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MarketMgr:SendStallListMessage(ResID, Begin, End, IsReverse)
	local MsgID = CS_CMD.CS_CMD_MARKET
	local SubMsgID = SUB_MSG_ID.MarketOptCmd_ListStalls
	local MsgBody = {
		Cmd = SUB_MSG_ID.MarketOptCmd_ListStalls,
		ListStalls = {ResID = ResID, Begin = IsReverse and End or Begin, End = IsReverse and Begin or End}
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MarketMgr:IsGoodsConcernMax()
	if self.FollowResIDs == nil then
		return false
	end
	return self.ConcernNum == #self.FollowResIDs
end

function MarketMgr:IsGoodsConcern(ResID)
	if self.FollowResIDs == nil then
		return false
	end
	for _, v in ipairs(self.FollowResIDs) do
		if v == ResID then
			return true
		end
	end

	return false
end

function MarketMgr:GetConcernGoodsNum()
	if self.FollowResIDs == nil then
		return 0
	end

	return #self.FollowResIDs
end

function MarketMgr:GetGoodsConcernByResID(ResID)
	if self.FollowResIDs == nil then
		return nil
	end

	for _, v in ipairs(self.FollowResIDs) do
		if v == ResID then
			return v
		end
	end

	return nil
end

function MarketMgr:GetConcernGoodsByType(Type)
	if self.FollowResIDs == nil then
		return {}
	end

	local TypeConcernList = {}
	for _, v in ipairs(self.FollowResIDs) do
		local Cfg = TradeMarketGoodsCfg:FindCfgByKey(v)
		if Type == ProtoRes.TradeMainType.TRADE_CONCERN_TYPE then
			table.insert(TypeConcernList,1, Cfg.ResID)
		else
			if Cfg.MainType == Type then
				table.insert(TypeConcernList,1, Cfg.ResID)
			end
		end
	end

	return TypeConcernList
end

function MarketMgr:GetGoodsByResID(ResID)
	if self.GoodsList == nil then
		return nil
	end

	for _, v in ipairs(self.GoodsList) do
		if v.ResID == ResID then
			return v
		end
	end

	return nil
end

function MarketMgr:HasStallExpired()
	if self.StallItemList == nil then
		return false
	end
	
	for _, V in ipairs(self.StallItemList) do
		if V.ExpireTick < TimeUtil.GetServerTime() then
			return true
		end
	end

	return false
end

function MarketMgr:HasBatchOnOrOffStall()
	if self.StallItemList == nil then
		return false
	end
	
	for _, V in ipairs(self.StallItemList) do
		if V.ExpireTick < TimeUtil.GetServerTime() and self:GetStallIncome(V) <= 0 then
			return true
		end
	end

	return false
end

function MarketMgr:GetAllStallIncome()
	local Income = 0
	if self.StallItemList == nil then
		return Income
	end
	
	for _, V in ipairs(self.StallItemList) do
		Income = Income + self:GetStallIncome(V)
	end

	return Income
end

function MarketMgr:GetStallIncome(StallItem)
	if StallItem == nil then
		return 0
	end
	return math.floor(self:GetStallIncomeNoTax(StallItem)*(1 - StallItem.TaxRate))
end

function MarketMgr:GetStallIncomeNoTax(StallItem)
	if StallItem == nil then
		return 0
	end
	return StallItem.SoldNum * StallItem.SinglePrice - StallItem.BackedMoney
end

function MarketMgr:GetCurTax()
	if MonthCardMgr:GetMonthCardStatus() == true then
		return self.MonthCardTradeTax
	else
		return self.NormalTradeTax
	end
end

function MarketMgr:ShowSysChatObtainScoreMsg(ScoreID, Value)
	-- 获得了[图标][金币]×10000
	local ScoreInfo = ScoreCfg:FindCfgByKey(ScoreID)

	local GetRitchText = RichTextUtil.GetText(string.format("%s", LSTR(1010008)), "d1ba81", 0, nil)
	local IconRichText = RichTextUtil.GetTexture(ScoreInfo.IconName, 40, 40, nil)--EEDC83FF
	local ScoreRichText = RichTextUtil.GetText(string.format("[%s]", ScoreInfo.NameText), "DAB53AFF", 0, nil)
	local SoceNumRichText = RichTextUtil.GetText(string.format("×%s", Value), "d1ba81", 0, nil)
	local Text = string.format("%s%s%s%s", GetRitchText, IconRichText, ScoreRichText, SoceNumRichText)
	ChatMgr:AddSysChatMsg(Text)
end

function MarketMgr:ShowSysChatObtainItemMsg(ResID, Value)
	-- 从市场购买了[物品名字]×1
	local GetRitchText = RichTextUtil.GetText(string.format("%s", LSTR(1010009)), "d1ba81", 0, nil)
	local NameRichText = RichTextUtil.GetText(string.format("[%s]", ItemCfg:GetItemName(ResID)), "DAB53AFF", 0, nil)
	local NumRichText = RichTextUtil.GetText(string.format("×%s", Value), "d1ba81", 0, nil)
	local Text = string.format("%s%s%s", GetRitchText, NameRichText, NumRichText)
	ChatMgr:AddSysChatMsg(Text)
end

function MarketMgr:GetMarketItemLevelInfo(ItemCfg)
	local LevelRichText = ItemCfg.ItemLevel
	if ItemUtil.CheckIsEquipment(ItemCfg.Classify) and _G.BagMgr:DiffQualityWithEquipment(ItemCfg.ItemID) > 0 then
		local GetRitchText = RichTextUtil.GetText(string.format("%d", ItemCfg.ItemLevel), "89bd88", 0, nil)
		local Path = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Icon_Arrow_Upgrade_png.UI_Comm_Icon_Arrow_Upgrade_png'"
	 	local IconText = RichTextUtil.GetTexture(Path, 40, 40, -11) or ""
		LevelRichText =  string.format("%s%s", GetRitchText, IconText)
	end
	
	return string.format("%s   %s%s", ItemTypeCfg:GetTypeName(ItemCfg.ItemType), _G.LSTR(1010096), LevelRichText)
end

function MarketMgr:GetMarketItemDesc(ItemCfg)
	if ItemUtil.CheckIsEquipment(ItemCfg.Classify) or ItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.CONSUMABLES_BAIT then

		local ProfText = ""
		if #ItemCfg.ProfLimit > 0 then
			local ProfNames = {}
			for i = 1, #ItemCfg.ProfLimit do
				local ProfLimitName = _G.EquipmentMgr:GetProfName(ItemCfg.ProfLimit[i])
				if not string.isnilorempty(ProfLimitName) then
					table.insert(ProfNames, ProfLimitName)
				end
			end
			ProfText = table.concat(ProfNames, "  ", 1, #ProfNames)
		else
			if ItemCfg.ClassLimit == 0 then
				ProfText = LSTR(1020004)
			else
				ProfText = _G.EquipmentMgr:GetProfClassName(ItemCfg.ClassLimit)
			end
		end
	
		local CanWearable, OtherProfWearable = ItemUtil.UpdateProfRestrictions(ItemCfg.ItemID)
		local ProfDetailColor = "dc5868"
		local GradeColor = ProfDetailColor
		if CanWearable then
			ProfDetailColor = "FFFFFF"
			GradeColor = MajorUtil.GetMajorLevel() < ItemCfg.Grade and "dc5868" or ProfDetailColor
		else
			if OtherProfWearable then
				ProfDetailColor = "6fb1e9"
				GradeColor = MajorUtil.GetMajorLevel() < ItemCfg.Grade and "dc5868" or ProfDetailColor
			end
		end

		local ProfRitchText = RichTextUtil.GetText(string.format("%s", ProfText), ProfDetailColor, 0, nil)
		local GradeRichText = RichTextUtil.GetText(string.format(LSTR(1020025), ItemCfg.Grade), GradeColor, 0, nil)
		return string.format("%s %s", ProfRitchText, GradeRichText)
	end
	
	return CommonUtil.GetTextFromStringWithSpecialCharacter(ItemCfg.ItemDesc)
end

function MarketMgr:CanUnLockMarket()
	local AccRechargePoints = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_RECHARGE)
	return AccRechargePoints >= 3000
end


--要返回当前类
return MarketMgr