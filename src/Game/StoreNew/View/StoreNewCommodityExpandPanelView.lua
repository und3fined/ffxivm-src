---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 15:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local StoreDefine = require("Game/Store/StoreDefine")

local LSTR = _G.LSTR

local StoreMainVM = _G.StoreMainVM

---@class StoreNewCommodityExpandPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExpand UFButton
---@field PanelCommodity UFCanvasPanel
---@field SingleBox CommSingleBoxView
---@field TableViewCommodity UTableView
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewCommodityExpandPanelView = LuaClass(UIView, true)

function StoreNewCommodityExpandPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExpand = nil
	--self.PanelCommodity = nil
	--self.SingleBox = nil
	--self.TableViewCommodity = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewCommodityExpandPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewCommodityExpandPanelView:OnInit()
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCommodity, self.OnGoodListSelectChanged, true, false)
	self.Binders = {
		{ "GoodList", 			UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
	}
end

function StoreNewCommodityExpandPanelView:OnDestroy()

end

function StoreNewCommodityExpandPanelView:OnShow()
	if nil == StoreMainVM.TabList or nil == next(StoreMainVM.TabList) then
		StoreMainVM:InitData()
	end
	self:OnRefreshGoodsSelected()
	self.SingleBox:SetText(LSTR(950079))	--- 未拥有
	if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		local Index = StoreMainVM.TabSelecteIndex >= 1 and StoreMainVM.TabSelecteIndex or 1
		local TabData = StoreMainVM.TabList[Index]
		if nil ~= TabData then
			UIUtil.SetIsVisible(self.SingleBox, TabData.IsDisplayHaveFilter)
		end
	else
		UIUtil.SetIsVisible(self.SingleBox, false)
	end
end

function StoreNewCommodityExpandPanelView:OnGoodListSelectChanged(Index, ItemData, ItemView)
	StoreMainVM:ChangeGood(Index)
	StoreMainVM:InitBuyView()
	StoreMainVM:CacheSelectedGoodsForCategory(StoreMainVM.TabSelecteIndex, ItemData.GoodID)
	self.GoodsTableViewAdapter:ScrollToIndex(Index % 2 == 0 and Index - 1 or Index)
end

function StoreNewCommodityExpandPanelView:OnHide()

end

function StoreNewCommodityExpandPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnClickSingleBox)
end

function StoreNewCommodityExpandPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.StoreRefreshGoodsSelected, self.OnRefreshGoodsSelected)

end

function StoreNewCommodityExpandPanelView:OnRegisterBinder()
	self:RegisterBinders(StoreMainVM, self.Binders)
end

function StoreNewCommodityExpandPanelView:OnRefreshGoodsSelected()
	local _, Index = self.GoodsTableViewAdapter:GetItemDataByPredicate(
		function(VM) return VM.GoodID == StoreMainVM.SelectedGoods[StoreMainVM:GetCurrentMainTabType()] end)
	Index = Index or 1
	self.GoodsTableViewAdapter:SetSelectedIndex(Index)
end

---@type 切换未拥有筛选
function StoreNewCommodityExpandPanelView:OnClickSingleBox(_, BtnState)
	local bIsChecked = BtnState == _G.UE.EToggleButtonState.Checked
	StoreMainVM:SetSecondScreen(bIsChecked)
	self:PlayAnimation(self.AnimGoodsUpdate)
end

return StoreNewCommodityExpandPanelView