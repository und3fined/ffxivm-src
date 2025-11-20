---
--- Author: mingyyzhang
--- DateTime: 2025-06-18 17:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class HouseInfoTagSettingsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSingleBox CommSingleBoxView
---@field IconTag UFImage
---@field TextTag UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoTagSettingsItemView = LuaClass(UIView, true)
local EToggleButtonState = _G.UE.EToggleButtonState
function HouseInfoTagSettingsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSingleBox = nil
	--self.IconTag = nil
	--self.TextTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoTagSettingsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoTagSettingsItemView:OnInit()
	self.ID = nil
	self.SettingVM = nil
end

function HouseInfoTagSettingsItemView:OnDestroy()

end

function HouseInfoTagSettingsItemView:OnShow()
	if self.Params and self.Params.Data then
		UIUtil.ImageSetBrushFromAssetPath(self.IconTag, self.Params.Data.IconPath)
		self.TextTag:SetText(LSTR(self.Params.Data.TagText))
		self.ID = self.Params.Data.ID
		self.SettingVM = self.Params.Data.SettingVM
		if self.SettingVM.TagTable[self.ID] == 1 then
			self.CommSingleBox.ToggleButton:SetCheckedState(EToggleButtonState.Checked)
		else
			self.CommSingleBox.ToggleButton:SetCheckedState(EToggleButtonState.UnChecked)
		end

		self.ToggleState = self.CommSingleBox.ToggleButton:GetCheckedState()
	end
end

function HouseInfoTagSettingsItemView:OnHide()

end

function HouseInfoTagSettingsItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommSingleBox.ToggleButton, self.OnTagsToggleButtonClick)
end

function HouseInfoTagSettingsItemView:OnRegisterGameEvent()

end

function HouseInfoTagSettingsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
end

function HouseInfoTagSettingsItemView:OnTagsToggleButtonClick()
	if  self.ToggleState == EToggleButtonState.UnChecked then
		if  self.SettingVM.TagNum < 3 then
			self.SettingVM.TagTable[self.ID] = 1
			self.SettingVM.TagNum = self.SettingVM.TagNum + 1
		else
			MsgTipsUtil.ShowTips(LSTR("标签选择数量不能超过三个"))
			self.CommSingleBox.ToggleButton:SetCheckedState(EToggleButtonState.UnChecked)
		end
	elseif self.ToggleState == EToggleButtonState.Checked then
		self.SettingVM.TagTable[self.ID] = 0
		self.SettingVM.TagNum = self.SettingVM.TagNum - 1
	else
		return
	end
	self.ToggleState = self.CommSingleBox.ToggleButton:GetCheckedState()
end

return HouseInfoTagSettingsItemView