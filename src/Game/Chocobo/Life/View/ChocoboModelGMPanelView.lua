---
--- Author: Administrator
--- DateTime: 2024-04-10 14:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChocoboShowModelMgr

---@class ChocoboModelGMPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnFold UToggleButton
---@field SpinBoxDistance USpinBox
---@field SpinBoxDistance_1 USpinBox
---@field SpinBoxDistance_2 USpinBox
---@field SpinBoxFOV USpinBox
---@field SpinBoxPitch USpinBox
---@field SpinBoxPitch_1 USpinBox
---@field SpinBoxPitch_2 USpinBox
---@field SpinBoxRoll USpinBox
---@field SpinBoxRoll_1 USpinBox
---@field SpinBoxRoll_2 USpinBox
---@field SpinBoxYaw USpinBox
---@field SpinBoxYaw_1 USpinBox
---@field SpinBoxYaw_2 USpinBox
---@field TxtIsDebugging UFTextBlock
---@field AnimFold UWidgetAnimation
---@field NewEventDispatcher_0 mcdelegate
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboModelGMPanelView = LuaClass(UIView, true)

function ChocoboModelGMPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnFold = nil
	--self.SpinBoxDistance = nil
	--self.SpinBoxDistance_1 = nil
	--self.SpinBoxDistance_2 = nil
	--self.SpinBoxFOV = nil
	--self.SpinBoxPitch = nil
	--self.SpinBoxPitch_1 = nil
	--self.SpinBoxPitch_2 = nil
	--self.SpinBoxRoll = nil
	--self.SpinBoxRoll_1 = nil
	--self.SpinBoxRoll_2 = nil
	--self.SpinBoxYaw = nil
	--self.SpinBoxYaw_1 = nil
	--self.SpinBoxYaw_2 = nil
	--self.TxtIsDebugging = nil
	--self.AnimFold = nil
	--self.NewEventDispatcher_0 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboModelGMPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboModelGMPanelView:OnInit()
	ChocoboShowModelMgr = _G.ChocoboShowModelMgr
end

function ChocoboModelGMPanelView:OnDestroy()

end

function ChocoboModelGMPanelView:OnShow()
	if ChocoboShowModelMgr:IsCreateFinish() then
		self.TxtIsDebugging:SetText("链接成功")
		self:InitDefaultParams()
	else
		self.TxtIsDebugging:SetText("链接失败")
	end
end

function ChocoboModelGMPanelView:OnHide()

end

function ChocoboModelGMPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnFold, self.OnFoldClicked)
end

function ChocoboModelGMPanelView:OnRegisterGameEvent()
end

function ChocoboModelGMPanelView:OnRegisterBinder()

end

function ChocoboModelGMPanelView:OnFoldClicked(ToggleButton, ButtonState)
	local bHidePanel = ButtonState == _G.UE.EToggleButtonState.Checked
	if bHidePanel then
		self:PlayAnimation(self.AnimFold)
	else
		self:PlayAnimationReverse(self.AnimFold)
	end
end

function ChocoboModelGMPanelView:InitDefaultParams()
	if ChocoboShowModelMgr:IsCreateFinish() == false then return end
	local Length = ChocoboShowModelMgr.ModelCameraController:GetSpringArmCompArmLength()
	local Location = ChocoboShowModelMgr.ModelCameraController:GetSpringArmLocation()
	local FOV = ChocoboShowModelMgr.ModelCameraController:GetFOV()
	
	self.SpinBoxDistance:SetValue(Length)
	self.SpinBoxFOV:SetValue(FOV)
	self.SpinBoxPitch:SetValue(Location.X)
	self.SpinBoxYaw:SetValue(Location.Y)
	self.SpinBoxRoll:SetValue(Location.Z)
	
	local Pos = ChocoboShowModelMgr.ModelMajorController:GetModelLocation()
	local Rotation = ChocoboShowModelMgr.ModelMajorController:GetModelRotation()
	self.SpinBoxDistance_1:SetValue(Rotation.Yaw)
	self.SpinBoxPitch_1:SetValue(Pos.X)
	self.SpinBoxYaw_1:SetValue(Pos.Y)
	self.SpinBoxRoll_1:SetValue(Pos.Z)

	Pos = ChocoboShowModelMgr.ModelChocoboController:GetModelLocation()
	Rotation = ChocoboShowModelMgr.ModelChocoboController:GetModelRotation()
	self.SpinBoxDistance_2:SetValue(Rotation.Yaw)
	self.SpinBoxPitch_2:SetValue(Pos.X)
	self.SpinBoxYaw_2:SetValue(Pos.Y)
	self.SpinBoxRoll_2:SetValue(Pos.Z)

	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxDistance, self.OnDistanceChanged)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxPitch, self.OnRotationChanged)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxYaw, self.OnRotationChanged)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxRoll, self.OnRotationChanged)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxFOV, self.OnFOVChanged)

	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxDistance_1, self.OnPlayerDir)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxPitch_1, self.OnPlayerLocation)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxYaw_1, self.OnPlayerLocation)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxRoll_1, self.OnPlayerLocation)

	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxDistance_2, self.OnChocoboDir)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxPitch_2, self.OnChocoboLocation)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxYaw_2, self.OnChocoboLocation)
	UIUtil.AddOnValueChangedEvent(self, self.SpinBoxRoll_2, self.OnChocoboLocation)
end

function ChocoboModelGMPanelView:GetExtraLocation()
	return _G.UE.FVector(self.SpinBoxPitch:GetValue(), self.SpinBoxYaw:GetValue(), self.SpinBoxRoll:GetValue())
end

function ChocoboModelGMPanelView:OnDistanceChanged(__, Value)
	if ChocoboShowModelMgr:IsCreateFinish() == false then return end

	ChocoboShowModelMgr.ModelCameraController:SetSpringArmCompArmLength(Value, true)
end

function ChocoboModelGMPanelView:OnRotationChanged()
	if ChocoboShowModelMgr:IsCreateFinish() == false then return end

	ChocoboShowModelMgr.ModelCameraController:SetSpringArmLocation(self:GetExtraLocation(), true)
end

function ChocoboModelGMPanelView:OnFOVChanged(__, Value)
	if ChocoboShowModelMgr:IsCreateFinish() == false then return end

	ChocoboShowModelMgr.ModelCameraController:SetCameraFOV(Value)
end

function ChocoboModelGMPanelView:OnPlayerDir(__, Value)
	if ChocoboShowModelMgr:IsCreateFinish() == false then return end

	ChocoboShowModelMgr.ModelMajorController:SetModelRotation(0, Value, 0)
end

function ChocoboModelGMPanelView:OnPlayerLocation()
	if ChocoboShowModelMgr:IsCreateFinish() == false then return end

	ChocoboShowModelMgr.ModelMajorController:SetModelLocation(self.SpinBoxPitch_1:GetValue(), self.SpinBoxYaw_1:GetValue(), self.SpinBoxRoll_1:GetValue())
end

function ChocoboModelGMPanelView:OnChocoboDir(__, Value)
	if ChocoboShowModelMgr:IsCreateFinish() == false then return end

	ChocoboShowModelMgr.ModelChocoboController:SetModelRotation(0, Value, 0)
end

function ChocoboModelGMPanelView:OnChocoboLocation()
	if ChocoboShowModelMgr:IsCreateFinish() == false then return end
	
	ChocoboShowModelMgr.ModelChocoboController:SetModelLocation(self.SpinBoxPitch_2:GetValue(), self.SpinBoxYaw_2:GetValue(), self.SpinBoxRoll_2:GetValue())
end

return ChocoboModelGMPanelView