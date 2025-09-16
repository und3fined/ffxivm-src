---
--- Author: Administrator
--- DateTime: 2024-01-11 15:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")

---@class ChocoboBreedChangeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AvatarItem ChocoboRaceAvatarItemView
---@field ImgFavor UFImage
---@field ImgGender UFImage
---@field ImgIcon UFImage
---@field ImgLease UFImage
---@field ImgSelect UFImage
---@field ImgSelectIcon UFImage
---@field LevelItem ChocoboLevelItemView
---@field PanelStar UFCanvasPanel
---@field StarPanelItem ChocoboStarPanelItemView
---@field TextName UFTextBlock
---@field TextStars UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboBreedChangeItemView = LuaClass(UIView, true)

function ChocoboBreedChangeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AvatarItem = nil
	--self.ImgFavor = nil
	--self.ImgGender = nil
	--self.ImgIcon = nil
	--self.ImgLease = nil
	--self.ImgSelect = nil
	--self.ImgSelectIcon = nil
	--self.LevelItem = nil
	--self.PanelStar = nil
	--self.StarPanelItem = nil
	--self.TextName = nil
	--self.TextStars = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboBreedChangeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AvatarItem)
	self:AddSubView(self.LevelItem)
	self:AddSubView(self.StarPanelItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboBreedChangeItemView:OnInit()
	self.BlueStarAdapter = UIAdapterTableView.CreateAdapter(self, self.StarPanelItem.TableViewBlue, nil, nil)
    self.RedStarAdapter = UIAdapterTableView.CreateAdapter(self, self.StarPanelItem.TableViewRed, nil, nil)
end

function ChocoboBreedChangeItemView:OnDestroy()

end

function ChocoboBreedChangeItemView:OnShow()

end

function ChocoboBreedChangeItemView:OnHide()

end

function ChocoboBreedChangeItemView:OnRegisterUIEvent()

end

function ChocoboBreedChangeItemView:OnRegisterGameEvent()

end

function ChocoboBreedChangeItemView:OnRegisterBinder()
	local Params = self.Params
	if Params ==  nil then return end 

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self.VM = ViewModel

	self.Binders = {
        { "IsChecked", UIBinderSetIsVisible.New(self, self.ImgSelect) },
        { "IsSelectParent", UIBinderSetIsVisible.New(self, self.ImgSelectIcon) },
        { "IsLike", UIBinderSetIsVisible.New(self, self.ImgFavor) },
        { "IsRent", UIBinderSetIsVisible.New(self, self.ImgLease) },
        { "Color", UIBinderSetColorAndOpacity.New(self, self.AvatarItem.ImgColor) },
        { "GenderPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGender) },
        { "FilterAttrIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
        { "GenerationText", UIBinderSetText.New(self, self.LevelItem.TextLevel) },
        { "StarCountText", UIBinderSetText.New(self, self.TextStars) },
        { "Name", UIBinderSetText.New(self, self.TextName) },
        { "FilterBlueStarVMList", UIBinderUpdateBindableList.New(self, self.BlueStarAdapter) },
        { "FilterRedStarVMList", UIBinderUpdateBindableList.New(self, self.RedStarAdapter) },
	}
	self:RegisterBinders(ViewModel, self.Binders)

	local MainVMBinders = {
        { "MateFilterType", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurFilterType) },
    }
    self:RegisterBinders(_G.ChocoboMainVM, MainVMBinders)

end

function ChocoboBreedChangeItemView:OnValueChangedCurFilterType(Value)
	UIUtil.SetIsVisible(self.StarPanelItem.ImgBG, false)
    if Value == ChocoboDefine.OVERVIEW_FILTER_TYPE.STAR then
        UIUtil.SetIsVisible(self.TextStars, true)
        UIUtil.SetIsVisible(self.PanelStar, false)
    elseif Value == ChocoboDefine.OVERVIEW_FILTER_TYPE.LEVEL then
        UIUtil.SetIsVisible(self.TextStars, false)
        UIUtil.SetIsVisible(self.PanelStar, false)
    elseif Value == ChocoboDefine.OVERVIEW_FILTER_TYPE.FEATHER_VALUE then
        UIUtil.SetIsVisible(self.TextStars, false)
        UIUtil.SetIsVisible(self.PanelStar, false)
    else
        UIUtil.SetIsVisible(self.TextStars, false)
        UIUtil.SetIsVisible(self.PanelStar, true)
        self.VM:SetOverviewFilterType(Value)
    end
end

function ChocoboBreedChangeItemView:OnSelectChanged(Value)
	local Params = self.Params
	if Params ==  nil then return end 

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	ViewModel.IsSelectParent = Value
	ViewModel.IsChecked = Value
end

return ChocoboBreedChangeItemView