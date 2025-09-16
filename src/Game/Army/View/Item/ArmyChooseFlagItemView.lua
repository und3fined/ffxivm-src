---
--- Author: Administrator
--- DateTime: 2024-04-16 16:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class ArmyChooseFlagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgFlag UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field TextArmy UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimDefaultMiddle UWidgetAnimation
---@field AnimDefaultSide UWidgetAnimation
---@field AnimInMiddle UWidgetAnimation
---@field AnimMoveToMiddle UWidgetAnimation
---@field AnimMoveToSide UWidgetAnimation
---@field AnimSelectIn UWidgetAnimation
---@field AnimSelectOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyChooseFlagItemView = LuaClass(UIView, true)

function ArmyChooseFlagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgFlag = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.TextArmy = nil
	--self.AnimCheck = nil
	--self.AnimDefaultMiddle = nil
	--self.AnimDefaultSide = nil
	--self.AnimInMiddle = nil
	--self.AnimMoveToMiddle = nil
	--self.AnimMoveToSide = nil
	--self.AnimSelectIn = nil
	--self.AnimSelectOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyChooseFlagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyChooseFlagItemView:SetItemVM(InItemVM)
	self.ItemVM = InItemVM
end

function ArmyChooseFlagItemView:GetFlagID()
	return self.ItemVM:GetFlagID()
end

function ArmyChooseFlagItemView:UpdateFlagData(Data)
	self.ItemVM:UpdateVM(Data)
end

function ArmyChooseFlagItemView:SetIsSelected(InSetIsSelected)
	self.ItemVM:SetIsSelected(InSetIsSelected)
end

function ArmyChooseFlagItemView:OnInit()
	self.Binders = {
		--{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
        { "FlagIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFlag)},
		{ "LabelIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgNormal)},
        { "SelectedLabelIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgSelect)},
		--{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgNormal, true)},
        { "IsSelected", UIBinderValueChangedCallback.New(self, nil, self.OnSelectedChange)},
		{ "ArmyFlagName",UIBinderSetText.New(self, self.TextArmy)},
		{ "NameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextArmy) },
	}
end

function ArmyChooseFlagItemView:OnDestroy()

end

function ArmyChooseFlagItemView:OnShow()

end

function ArmyChooseFlagItemView:OnHide()
	if self:IsAnimationPlaying(self.AnimMoveToMiddle) then
		UIUtil.PlayAnimationTimePointPct(self, self.AnimMoveToMiddle, 1, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
	end
	if self:IsAnimationPlaying(self.AnimSelectIn) then
		UIUtil.PlayAnimationTimePointPct(self, self.AnimSelectIn, 1, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
	end
	if self:IsAnimationPlaying(self.AnimMoveToSide) then
		UIUtil.PlayAnimationTimePointPct(self, self.AnimMoveToSide, 1, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
	end
	if self:IsAnimationPlaying(self.AnimSelectOut) then
		UIUtil.PlayAnimationTimePointPct(self, self.AnimSelectOut, 1, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
	end
end

function ArmyChooseFlagItemView:SetOnClickedCallback(Owner, CallBackFunc)
	self.Owner = Owner
	self.CallBackFunc = CallBackFunc
end

function ArmyChooseFlagItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickedBtnSelect)
end

function ArmyChooseFlagItemView:OnClickedBtnSelect()
	self.CallBackFunc(self.Owner, self:GetFlagID())
end

function ArmyChooseFlagItemView:OnRegisterGameEvent()

end

function ArmyChooseFlagItemView:OnRegisterBinder()
	if nil == self.ItemVM  then
		return
	end
	self:RegisterBinders(self.ItemVM, self.Binders)
end

function ArmyChooseFlagItemView:OnSelectedChange(IsSelected)
	if IsSelected then
		UIUtil.SetIsVisible(self.ImgSelect, true)
		if self:IsAnimationPlaying(self.AnimMoveToSide) then
			self:StopAnimation(self.AnimMoveToSide)
		end
		self:PlayAnimation(self.AnimMoveToMiddle)
		self:PlayAnimation(self.AnimSelectIn)
	else
		if self:IsAnimationPlaying(self.AnimMoveToMiddle) then
			self:StopAnimation(self.AnimMoveToMiddle)
		end
		self:PlayAnimation(self.AnimMoveToSide)
		self:PlayAnimation(self.AnimSelectOut)
		local HideTime = self.AnimSelectOut:GetEndTime() 
        self:RegisterTimer(self.HideImgSelect, HideTime, HideTime, 1)
	end
end

function ArmyChooseFlagItemView:HideImgSelect(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, false)
end


return ArmyChooseFlagItemView