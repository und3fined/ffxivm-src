---
--- Author: Administrator
--- DateTime: 2025-01-22 18:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class ArmyEditArmyInformationItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSingleBox CommSingleBoxView
---@field ImgJob01 UFImage
---@field TextJob UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyEditArmyInformationItemView = LuaClass(UIView, true)

function ArmyEditArmyInformationItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSingleBox = nil
	--self.ImgJob01 = nil
	--self.TextJob = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyEditArmyInformationItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyEditArmyInformationItemView:OnInit()
    self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgJob01)},
		{"Text", UIBinderSetText.New(self, self.TextJob)},
		{"IsChecked", UIBinderValueChangedCallback.New(self, nil, self.OnIsCheckedChange)},
		{"IsEnabled", UIBinderValueChangedCallback.New(self, nil, self.OnIsEnabledChange)},
    }
end

function ArmyEditArmyInformationItemView:OnDestroy()

end

function ArmyEditArmyInformationItemView:OnShow()
	if self.CommSingleBox and self.CommSingleBox.TextContent then
		UIUtil.SetIsVisible(self.CommSingleBox.TextContent, false)
	end
end

function ArmyEditArmyInformationItemView:OnHide()

end

function ArmyEditArmyInformationItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox, self.OnToggleStateChanged)
end

function ArmyEditArmyInformationItemView:OnRegisterGameEvent()

end

function ArmyEditArmyInformationItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function ArmyEditArmyInformationItemView:OnIsCheckedChange(IsChecked)
	self.CommSingleBox:SetChecked(IsChecked, false)
end

function ArmyEditArmyInformationItemView:OnIsEnabledChange(IsEnabled)
	self.CommSingleBox:SetIsEnabled(IsEnabled)
end

function ArmyEditArmyInformationItemView:OnToggleStateChanged(ToggleButton, State)
	if self.ViewModel then
		local IsChecked = State == 1
		local CurChecked = self.ViewModel:GetIsChecked()
		if IsChecked ~= CurChecked then
			self.ViewModel:SetIsChecked(IsChecked)
		end
		local Params = self.Params
		if nil == Params then
			return
		end
		local Adapter = Params.Adapter
		if nil == Adapter then
			return
		end
		Adapter:OnItemClicked(self, Params.Index)
	end
end

return ArmyEditArmyInformationItemView