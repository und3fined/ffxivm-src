---
--- Author: Administrator
--- DateTime: 2024-02-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")

---@class WardrobePresetsListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnList UFButton
---@field FVerticalText UFVerticalBox
---@field ImgAdd UFImage
---@field ImgCheck UFImage
---@field ImgPresets UFImage
---@field ImgSelect UFImage
---@field PanelAdd UFCanvasPanel
---@field PanelIcon UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field TextAdd UFTextBlock
---@field TextCondition UFTextBlock
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobePresetsListItemView = LuaClass(UIView, true)

function WardrobePresetsListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnList = nil
	--self.FVerticalText = nil
	--self.ImgAdd = nil
	--self.ImgCheck = nil
	--self.ImgPresets = nil
	--self.ImgSelect = nil
	--self.PanelAdd = nil
	--self.PanelIcon = nil
	--self.PanelList = nil
	--self.TextAdd = nil
	--self.TextCondition = nil
	--self.TextName = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobePresetsListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobePresetsListItemView:OnInit()
	self.Binders = {
		{ "DetailVisible", UIBinderSetIsVisible.New(self, self.PanelList) },
		{ "AddVisible", UIBinderSetIsVisible.New(self, self.PanelAdd) },
		{ "IconVisible", UIBinderSetIsVisible.New(self, self.PanelIcon)},
		{ "CurSuitCheck", UIBinderSetIsVisible.New(self, self.ImgCheck) },
		{ "Num", UIBinderSetText.New(self, self.TextNum) },
		{ "PresetName", UIBinderSetText.New(self, self.TextName) },
		{ "ProfName", UIBinderSetText.New(self, self.TextCondition) },
		{ "ProfVisible", UIBinderSetIsVisible.New(self, self.TextCondition) },
		{ "ProfColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCondition)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect2)},
		{ "IsFirst", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "PresetIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPresets)},
	}
end

function WardrobePresetsListItemView:OnDestroy()

end

function WardrobePresetsListItemView:OnShow()
	self.TextAdd:SetText(_G.LSTR(1080094))
end

function WardrobePresetsListItemView:OnHide()

end

function WardrobePresetsListItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnList, self.OnClickedBtnList)
end

function WardrobePresetsListItemView:OnRegisterGameEvent()

end

function WardrobePresetsListItemView:OnClickedBtnList()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then return end

	if ViewModel.AddVisible then
		Adapter.View:OnClickedItemEnlargerBtn()
	else
		Adapter:OnItemClicked(self, Params.Index)
	end

end

function WardrobePresetsListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

-- function WardrobePresetsListItemView:OnSelectChanged(bSelected)
-- 	local Params = self.Params
-- 	if Params == nil then
-- 		return
-- 	end

-- 	local ViewModel = Params.Data
-- 	if ViewModel == nil then
-- 		return
-- 	end
-- 	if not ViewModel.AddVisible then
-- 		ViewModel.IsSelected = bSelected
-- 	end
-- end


return WardrobePresetsListItemView