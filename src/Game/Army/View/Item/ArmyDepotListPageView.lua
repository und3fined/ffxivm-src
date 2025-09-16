---
--- Author: Administrator
--- DateTime: 2023-12-04 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local UIAdapterToggleGroup = require("UI/Adapter/UIAdapterToggleGroup")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetCheckedIndex = require("Binder/UIBinderSetCheckedIndex")

local ArmyMgr = nil
local ArmyDepotPageVM = nil

---@class ArmyDepotListPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonEnlarge UFButton
---@field ButtonToplimit UFButton
---@field PanelEnlarge UFCanvasPanel
---@field PanelToplimit UFCanvasPanel
---@field StoreEnlarge UFCanvasPanel
---@field TextToplimit URichTextBox
---@field ToggleGroupDynamicItem UToggleGroupDynamic
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyDepotListPageView = LuaClass(UIView, true)

function ArmyDepotListPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonEnlarge = nil
	--self.ButtonToplimit = nil
	--self.PanelEnlarge = nil
	--self.PanelToplimit = nil
	--self.StoreEnlarge = nil
	--self.TextToplimit = nil
	--self.ToggleGroupDynamicItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyDepotListPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyDepotListPageView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	local ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
    ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
	self.AdapterToggleGroupItem = UIAdapterToggleGroup.CreateAdapter(self, self.ToggleGroupDynamicItem)
	self.Binders = {
		{ "BindableToggleListPage", UIBinderUpdateBindableList.New(self, self.AdapterToggleGroupItem) },
		{ "CurrentPage", UIBinderSetCheckedIndex.New(self, self.ToggleGroupDynamicItem) },
		{ "IsOpenEnlarge", UIBinderSetIsVisible.New(self, self.PanelEnlarge) },
		{ "IsCloseEnlarge", UIBinderSetIsVisible.New(self, self.PanelToplimit) },
	}
end

function ArmyDepotListPageView:OnDestroy()

end

function ArmyDepotListPageView:OnShow()
	---屏蔽掉不需要显示的UI
	UIUtil.SetIsVisible(self.PanelEnlarge, false)
end

function ArmyDepotListPageView:OnHide()

end

function ArmyDepotListPageView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupDynamicItem, self.OnToggleGroupStateChanged)
	--UIUtil.AddOnClickedEvent(self, self.ButtonEnlarge, self.OnButtonEnlarge)
end

function ArmyDepotListPageView:OnRegisterGameEvent()

end

function ArmyDepotListPageView:OnRegisterBinder()
	if nil == ArmyDepotPageVM then
		local ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
		ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
	end
	self:RegisterBinders(ArmyDepotPageVM, self.Binders)
end

function ArmyDepotListPageView:OnToggleGroupStateChanged(ToggleGroup, ToggleButton, Index, State)
	ArmyDepotPageVM:SetCurrentPage(Index + 1)
	ArmyDepotPageVM:SetDepotListVisible(false)

	local PageIndex = ArmyDepotPageVM:GetCurDepotIndex()
	ArmyMgr:SendGroupStoreReqStoreInfo(PageIndex)
end

-- function ArmyDepotListPageView:OnButtonEnlarge()
-- 	UIViewMgr:ShowView(UIViewID.DepotExpandWin, {EnlargeID = ArmyDepotPageVM.Enlarge})
-- 	ArmyDepotPageVM:SetDepotListVisible(false)
-- end

return ArmyDepotListPageView