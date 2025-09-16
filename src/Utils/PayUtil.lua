local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")

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

function PayUtil.OnLoginExpired()
end

function PayUtil.OnPayFinished()
end

return PayUtil
