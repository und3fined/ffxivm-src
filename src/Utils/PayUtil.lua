local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")
local CommonUtil = require("Utils/CommonUtil")
local RechargeCfg = require("TableCfg/RechargeCfg")
local UPayMgr = _G.UE.UPayMgr
local PayUtil = {}

function PayUtil.Login(RoleID, WorldID)
	UPayMgr.Get():Login(RoleID, WorldID)
end

---BuyCoins
---@param Stall number
---@param BillReceivedCallback function 后台订单回调
---@param LoginExpiredCallback function 登录态过期回调
---@param PayFinishedCallback function 客户端支付成功回调
---@param GoodsReceivedCallback function 后台到货回调
---@param DelegateBindTarget UE.UObject 委托绑定对象，一般可传入UIView
function PayUtil.BuyCoins(Stall, BillReceivedCallback, LoginExpiredCallback, PayFinishedCallback, GoodsReceivedCallback,
						  DelegateBindTarget)
	_G.FLOG_INFO("[PayMgr]PayUtil.BuyCoins, StallID:%d, OpenID:%s, RoleID:%s", Stall, tostring(_G.LoginMgr:GetOpenID()), tostring(_G.LoginMgr:GetRoleID()))
	UPayMgr.Get():BuyCoins(Stall, {DelegateBindTarget, BillReceivedCallback}, {DelegateBindTarget, LoginExpiredCallback}, {DelegateBindTarget, PayFinishedCallback},
			    		   {DelegateBindTarget, GoodsReceivedCallback})
end

--已废弃，请使用BuyCoins接口
function PayUtil.BuyItems(ItemId, Quantity, LoginExpiredCallback, PayFinishedCallback)
	UPayMgr.Get():BuyItems(ItemId, Quantity, {UPayMgr, LoginExpiredCallback}, {UPayMgr, PayFinishedCallback})
end

--已废弃，请使用BuyCoins接口
function PayUtil.BuyMonthCard(Days, LoginExpiredCallback, PayFinishedCallback)
	UPayMgr.Get():BuyMonthCard(Days, {UPayMgr, LoginExpiredCallback}, {UPayMgr, PayFinishedCallback})
end

--已废弃，请使用BuyCoins接口
function PayUtil.Subscribe(SubscribeType, Months, LoginExpiredCallback, PayFinishedCallback)
	UPayMgr.Get():Subscribe(SubscribeType, Months, {UPayMgr, LoginExpiredCallback}, {UPayMgr, PayFinishedCallback})
end

function PayUtil.GetBalance()
	return ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS)
end

function PayUtil.SetEnableScanPay(IsEnable)
	UPayMgr.Get():SetEnableScanPay(IsEnable)
end

function PayUtil.GetProductID(Stall)
	--return UPayMgr.Get():GetProductID(Stall)

	local Platform = CommonUtil.GetPlatformName()
	local PlatID = "0"
	if Platform == "Android" then
		PlatID = "1"
	elseif Platform == "IOS" then
		PlatID = "2"
	end
	local AllRechargeCfg = RechargeCfg:FindAllCfg("Platform="..PlatID)
	if nil ~= AllRechargeCfg then
		for _, Cfg in ipairs(AllRechargeCfg) do
			if Cfg.DisplayOrder == Stall then
				return Cfg.ProductID
			end
		end
	end

	return ""
end

function PayUtil.GetProductTypeName(Stall)
	local Platform = CommonUtil.GetPlatformName()
	local PlatID = "0"
	if Platform == "Android" then
		PlatID = "1"
	elseif Platform == "IOS" then
		PlatID = "2"
	end
	local ProductType = 0
	local AllRechargeCfg = RechargeCfg:FindAllCfg("Platform="..PlatID)
	if nil ~= AllRechargeCfg then
		for _, Cfg in ipairs(AllRechargeCfg) do
			if Cfg.DisplayOrder == Stall then
				ProductType = Cfg.Type
			end
		end
	end

	if ProductType == 1 then
		return _G.LSTR(940043)  --"水晶点"
	elseif ProductType == 2 then
		return _G.LSTR(940044)  --"月卡"
	elseif ProductType == 3 then
		return _G.LSTR(940045)  --"战令"
	end
	return ""
end

function PayUtil.ReshowPaySuccessTips(ResID, Value)
	local LootItem = { Type = 1, Item = { ResID = ResID, Value = Value, Percent = 0, ProfID = 0 } }
	local CommList = { LootItem }
	_G.LootMgr:ShowSysChatDropList(CommList)
	_G.LootMgr:HandleMultipleDrop(CommList)
end

function PayUtil.OnLoginExpired()
end

function PayUtil.OnPayFinished()
end

return PayUtil
