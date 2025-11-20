---
--- Author: yutingzhan
--- DateTime: 2025-06-19 10:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local OpsMysteryShopMainPanelVM = require("Game/Ops/VM/OpsMysteryShop/OpsMysteryShopMainPanelVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EventID = require("Define/EventID")
local MallCfg = require("TableCfg/MallCfg")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EventMgr = require("Event/EventMgr")
local SaveKey = require("Define/SaveKey")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local USaveMgr = _G.UE.USaveMgr

---@class OpsMysteryShopMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommInforBtn CommInforBtnView
---@field OpsCommMoneySlot OpsCommMoneySlotView
---@field PanelTitle UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextHint UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMysteryShopMainPanelView = LuaClass(UIView, true)

function OpsMysteryShopMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommInforBtn = nil
	--self.OpsCommMoneySlot = nil
	--self.PanelTitle = nil
	--self.TableViewSlot = nil
	--self.TextHint = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMysteryShopMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.OpsCommMoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMysteryShopMainPanelView:OnInit()
	self.ViewModel = OpsMysteryShopMainPanelVM.New()
	self.CommodityTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)
	self.Binders = {
        {"CommodityVMList", UIBinderUpdateBindableList.New(self, self.CommodityTableViewAdapter)},
    }
end

function OpsMysteryShopMainPanelView:OnDestroy()

end

function OpsMysteryShopMainPanelView:OnShow()
	if self.Params == nil then
		return
	end
	self.OpsCommMoneySlot.ShowMysteryMoneySlot = true
	local ActivityDate = self.Params.BindableActivityList:Get(1)
	local Activity = ActivityDate.Activity
	self.TextTitle:SetText(Activity.Title)
	self.TextHint:SetText(Activity.SubTitle)
	self.CommInforBtn.HelpInfoID = ActivityDate:GetActivityHelpInfo()
	self.AdapterCountDownTime:Start(self:GetUpdateTimeStamp(), 1, true, false)
	_G.ShopMgr:SendMysteryShopInfoReq()
	local SaveValue = USaveMgr.GetInt(SaveKey.PlayRefreshAnim, -1, true)
	if SaveValue > 0 then
		if SaveValue < self.NowInterValStartStamp or SaveValue > self.NextEndTimestamp then
			self:PlayRefreshAnimation()
		end
	else
		self:PlayRefreshAnimation()
	end
	USaveMgr.SetInt(SaveKey.PlayRefreshAnim, TimeUtil.GetServerLogicTime(), true)
	_G.OpsActivityMgr:RecordRedDotClicked(Activity.ActivityID, _G.TimeUtil.GetServerLogicTime())
end

function OpsMysteryShopMainPanelView:PlayRefreshAnimation()
	self:RegisterTimer(function()
			EventMgr:SendEvent(EventID.PlayRefreshAnim)
	end, 0.6)
end

function OpsMysteryShopMainPanelView:OnHide()

end

function OpsMysteryShopMainPanelView:OnRegisterUIEvent()
end

function OpsMysteryShopMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateOpsMysteryShop, self.UpdateOpsMysteryShop)
	self:RegisterGameEvent(EventID.UpdateOpsMysteryShopGoods, self.UpdateOpsMysteryShopGoods)
	self:RegisterGameEvent(EventID.UpdateMysteryShopCommMoney, self.ShowCommMoneySlot)
end

function OpsMysteryShopMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsMysteryShopMainPanelView:ShowCommMoneySlot(Params)
	UIUtil.SetIsVisible(self.OpsCommMoneySlot, Params.CommMoneyVisible)
end

function OpsMysteryShopMainPanelView:TimeOutCallback()
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.OpsMysteryBuyPropsWinView) then
		_G.UIViewMgr:HideView(_G.UIViewID.OpsMysteryBuyPropsWinView)
	end

	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.OpsMysteryBuySuitWinView) then
		_G.UIViewMgr:HideView(_G.UIViewID.OpsMysteryBuySuitWinView)
	end
	EventMgr:SendEvent(EventID.PlayRefreshAnim)
	USaveMgr.SetInt(SaveKey.PlayRefreshAnim, TimeUtil.GetServerLogicTime(), true)
	self:RegisterTimer(function()
		_G.ShopMgr:SendMysteryShopInfoReq()
	end, 0.2)
	self.AdapterCountDownTime:Start(self:GetUpdateTimeStamp(), 1, true, false)
end

function OpsMysteryShopMainPanelView:TimeUpdateCallback(LeftTime)
	local CountdownText = string.format("%s %s", LocalizationUtil.GetCountdownTimeForLongTime(LeftTime, ""), _G.LSTR("后自动刷新"))
	-- local Items = self.ViewModel.CommodityVMList.Items
	-- for Index, Item in ipairs(Items) do
	-- 	if Item.TimeVisible then
	-- 		Item:UpdateDiscountAndTime()
	-- 		self.ViewModel.CommodityVMList:InsertByValue(Item, Index)
	-- 	end
	-- end
	return CountdownText
end


function OpsMysteryShopMainPanelView:UpdateOpsMysteryShopGoods(MallInfo)
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.OpsMysteryBuyPropsWinView) then
		_G.UIViewMgr:HideView(_G.UIViewID.OpsMysteryBuyPropsWinView)
	end

	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.OpsMysteryBuySuitWinView) then
		_G.UIViewMgr:HideView(_G.UIViewID.OpsMysteryBuySuitWinView)
	end
	local GoodInfo = MallInfo.Good
	local GoodsID = GoodInfo.GoodID
	local Items = self.ViewModel.CommodityVMList.Items
	local ItemID = nil
	local Num = nil
	for Index, Item in ipairs(Items) do
		if Item.GoodsID == GoodsID then
			Item.MaskVisible = true
			Item.IsCanBuy = false
			ItemID = Item.ItemID
			Num = Item.Num
			self.ViewModel.CommodityVMList.Items[Index] = Item
			break
		end
	end
	local Params = {}
	local Rewards  = {}
	Params.ShowBtn = false
	Params.ItemList = Rewards
	table.insert(Rewards, {ResID = ItemID, Num = Num})
	_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
end

function OpsMysteryShopMainPanelView:UpdateOpsMysteryShop(MsgBody)
	if MsgBody == nil then
		return
	end
	local GoodsList = MsgBody.StoreQuery.Goods
	self.ViewModel:Update(GoodsList)
end

function OpsMysteryShopMainPanelView:GetUpdateTimeStamp()
    local MysteryMallCfg = MallCfg:FindCfgByKey(5002)
    local StartTime = MysteryMallCfg.RefreshStartTime
    local Interval = MysteryMallCfg.RefreshInterval

    local StartTimestamp = TimeUtil.GetTimeFromString(StartTime)

    local CurrentTimestamp = TimeUtil.GetServerLogicTime()

    local IntervalsPassed = math.floor((CurrentTimestamp - StartTimestamp) / (Interval * 3600))

    self.NextEndTimestamp = StartTimestamp + (IntervalsPassed + 1) * Interval * 3600

	self.NowInterValStartStamp = self.NextEndTimestamp - Interval * 3600

    return self.NextEndTimestamp
end

return OpsMysteryShopMainPanelView