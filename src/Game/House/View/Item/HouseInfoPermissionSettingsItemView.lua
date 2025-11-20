---
--- Author: muyanli
--- DateTime: 2025-06-06 11:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HouseInfoPermissionSettingsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSingleBox_UIBP CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoPermissionSettingsItemView = LuaClass(UIView, true)
local EToggleButtonState = _G.UE.EToggleButtonState

function HouseInfoPermissionSettingsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSingleBox_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoPermissionSettingsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSingleBox_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoPermissionSettingsItemView:OnInit()
	self.Selected = false
	self.Index = 1
	self.SettingVM = nil
end

function HouseInfoPermissionSettingsItemView:OnDestroy()

end

function HouseInfoPermissionSettingsItemView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local Data = Params.Data
	if Data == nil then
		return
	end

	self.CommSingleBox_UIBP.TextContent:SetText(Data.PrivilegeName)
	self.Index = Data.Index
	self.SettingVM = Data.SettingVM
	self.RealIndex = 1
	local CurSettingData = self.SettingVM.PrivilegeList[self.SettingVM.CurrentRoommate]
	for i, v in ipairs(CurSettingData) do
		if v.Index == self.Index then
			self.RealIndex = i
			break
		end
	end


	if self.SettingVM.PrivilegeList[self.SettingVM.CurrentRoommate][self.RealIndex].Selected == true then
		self:SetSelect()
	else
		self:UnSelect()
	end
end

function HouseInfoPermissionSettingsItemView:OnHide()

end

function HouseInfoPermissionSettingsItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.CommSingleBox_UIBP.ToggleButton, self.OnSelectClick)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox_UIBP.ToggleButton, self.OnToggleButtonStateChanged)
end

function HouseInfoPermissionSettingsItemView:OnRegisterGameEvent()

end

function HouseInfoPermissionSettingsItemView:OnRegisterBinder()

end

function HouseInfoPermissionSettingsItemView:SetSelect()
	self.CommSingleBox_UIBP.ToggleButton:SetCheckedState(EToggleButtonState.Checked, false)
end

function HouseInfoPermissionSettingsItemView:UnSelect()
	self.CommSingleBox_UIBP.ToggleButton:SetCheckedState(EToggleButtonState.UnChecked, false)
end

function HouseInfoPermissionSettingsItemView:OnToggleButtonStateChanged(ToggleButton, CheckState)
	if CheckState == EToggleButtonState.Checked then
		self.SettingVM.PrivilegeList[self.SettingVM.CurrentRoommate][self.RealIndex].Selected = true
	elseif CheckState == EToggleButtonState.UnChecked then
		self.SettingVM.PrivilegeList[self.SettingVM.CurrentRoommate][self.RealIndex].Selected = false
	end
end

return HouseInfoPermissionSettingsItemView