---
--- Author: Administrator
--- DateTime: 2024-04-01 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FootPrintMgr = require("Game/FootPrint/FootPrintMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MapUtil = require("Game/Map/MapUtil")

local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR
local LightDelayCloseWidget = 2.5 -- 足迹界面点亮延迟关闭界面时间
local LightDelayShowTip = 0.9 -- 足迹界面点亮延迟关闭界面时间

---@class FootPrintDataPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonRedDot CommonRedDotView
---@field CommonTitle CommonTitleView
---@field FHorizontalBox_0 UFHorizontalBox
---@field FootPrintBottleItem_UIBP FootPrintBottleItemView
---@field FootPrintScheduleItem_UIBP FootPrintScheduleItemView
---@field FootPriont USpineWidget
---@field TableViewTab UTableView
---@field TexxtFootprints UFTextBlock
---@field TexxtSchedule UFTextBlock
---@field TreeViewLIst UFTreeView
---@field AnimIn UWidgetAnimation
---@field AnimInBackup UWidgetAnimation
---@field AnimLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FootPrintDataPanelView = LuaClass(UIView, true)

function FootPrintDataPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.CloseBtn = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonRedDot = nil
	--self.CommonTitle = nil
	--self.FHorizontalBox_0 = nil
	--self.FootPrintBottleItem_UIBP = nil
	--self.FootPrintScheduleItem_UIBP = nil
	--self.FootPriont = nil
	--self.TableViewTab = nil
	--self.TexxtFootprints = nil
	--self.TexxtSchedule = nil
	--self.TreeViewLIst = nil
	--self.AnimIn = nil
	--self.AnimInBackup = nil
	--self.AnimLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FootPrintDataPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.FootPrintBottleItem_UIBP)
	self:AddSubView(self.FootPrintScheduleItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FootPrintDataPanelView:InitConstStringInfo()
	self.CommonTitle:SetTextTitleName(LSTR(320004))
	self.TexxtFootprints:SetText(LSTR(320005))
	self.Btn:SetButtonText(LSTR(320009))
	self.CommonRedDot:SetIsCustomizeRedDot(true)
end

function FootPrintDataPanelView:OnInit()
	self.TableViewTabAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnTableViewTabSelectChanged, true)
	self.TreeViewItemAdapter = UIAdapterTreeView.CreateAdapter(self, self.TreeViewLIst, self.OnTreeViewTabsSelectChanged, true, false)
	self.Binders = {
		{"ParentTypeListItems", UIBinderUpdateBindableList.New(self, self.TableViewTabAdapter)},
		{"TypeItemList", UIBinderUpdateBindableList.New(self, self.TreeViewItemAdapter)},
		{"bLighted", UIBinderSetIsVisible.New(self, self.FHorizontalBox_0)},
		{"bLighted", UIBinderSetIsVisible.New(self, self.FootPrintScheduleItem_UIBP, true)},
		{"CompleteScheduleText", UIBinderSetText.New(self, self.TexxtSchedule)},
		{"bLighted", UIBinderValueChangedCallback.New(self, nil, self.OnNotifyUpdateMapRewardState)},
	}
	self:InitConstStringInfo()
end

function FootPrintDataPanelView:OnDestroy()

end

function FootPrintDataPanelView:OnShow()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end
	local RegionId = ViewModel.RegionID
	if not RegionId then
		return
	end
	local bShowOtherRegionRedDot = FootPrintMgr:IsNeedShowOtherRegionRedDot(RegionId)
	self.CommonRedDot:SetRedDotUIIsShow(bShowOtherRegionRedDot)
end

function FootPrintDataPanelView:OnHide()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end
	ViewModel:ResumeBottleVMScheduleVisible()

	self:StopLightAnim()
	FootPrintMgr:ClearLastSelectedData()
end

function FootPrintDataPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function FootPrintDataPanelView:OnRegisterGameEvent()

end

function FootPrintDataPanelView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	self.FootPrintBottleItem_UIBP:SetParams({Data = ViewModel.BottleVM})
	self.FootPrintScheduleItem_UIBP:SetParams(Params)
	self.CloseBtn:SetCallback(self, function()
		self:Hide()
	end)
	self:RegisterBinders(ViewModel, self.Binders)
end

function FootPrintDataPanelView:OnTableViewTabSelectChanged(_, ItemData, _, byClick)
	local CurParentType = ItemData.ParentType
	FootPrintMgr:SelectTheParentType(CurParentType)
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	ViewModel.LastSelectedTypeID = 0
end

function FootPrintDataPanelView:OnTreeViewTabsSelectChanged(Index, ItemData, _)
	local Adapter = self.TreeViewItemAdapter
	if not Adapter then
		return
	end

	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local LastSelectedTypeID = ViewModel.LastSelectedTypeID
	if LastSelectedTypeID and LastSelectedTypeID ~= 0 then
		FLOG_INFO("FootPrintDataPanelView:OnTreeViewTabsSelectChanged ExpandFalse: %d", LastSelectedTypeID)
		ViewModel.LastSelectedTypeID = 0
		Adapter:SetIsExpansion(LastSelectedTypeID, false)
	end

	local IsExpanded = ItemData.IsExpanded
	if IsExpanded then
		local Key = ItemData:GetKey()
		ViewModel.LastSelectedTypeID = Key
		Adapter:ScrollIndexIntoView(Index)
	end--]]
end

function FootPrintDataPanelView:OnBtnClicked()
	self:BackToMainPanel()
end

function FootPrintDataPanelView:OnNotifyUpdateMapRewardState(NewValue, OldValue)
	if not NewValue or NewValue == OldValue then
		return
	end

	if not FootPrintMgr.CurLightRegionID then
		return
	end
	self:PlayAnimation(self.AnimLight)

	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end
	local RegionId = ViewModel.RegionID
	if not RegionId then
		return
	end
	local RegionName = MapUtil.GetRegionName(RegionId) or ""
    self:RegisterTimer(function()
		MsgTipsUtil.ShowInfoTextTips(1, string.format(LSTR(320013), RegionName))
	end, LightDelayShowTip)
	self:RegisterTimer(function()
		self:StopLightAnim()
	end, LightDelayCloseWidget)--]]
end

function FootPrintDataPanelView:StopLightAnim()
	self:StopAnimation(self.AnimLight)
end

function FootPrintDataPanelView:BackToMainPanel()
	FootPrintMgr:OpenFootPrintMainPanel()
	self:Hide()
end

function FootPrintDataPanelView:OnAnimationFinished(Anim)
	if Anim == self.AnimLight then
		local Bottle = self.FootPrintBottleItem_UIBP
		if Bottle then
			local BottleLightAnim = Bottle.AnimLight
			if BottleLightAnim then
				Bottle:StopAnimation(BottleLightAnim)
			end
		end
		FootPrintMgr.bNeedPlayAnimIn = false
		self:BackToMainPanel()
	end
end

return FootPrintDataPanelView