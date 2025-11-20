---
--- Author: Administrator
--- DateTime: 2025-09-04 16:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

---@class MountPanelDeBugUIView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GS_DefaultCameraDistance UHorizontalBox
---@field GS_OffsetX UHorizontalBox
---@field GS_OffsetY UHorizontalBox
---@field GS_OffsetZ UHorizontalBox
---@field GS_Pitch UHorizontalBox
---@field GS_Roll UHorizontalBox
---@field GS_Yaw UHorizontalBox
---@field MOX UEditableTextBox
---@field MOX_1 UEditableTextBox
---@field MOX_10 UEditableTextBox
---@field MOX_11 UEditableTextBox
---@field MOX_12 UEditableTextBox
---@field MOX_13 UEditableTextBox
---@field MOX_14 UEditableTextBox
---@field MOX_15 UEditableTextBox
---@field MOX_16 UEditableTextBox
---@field MOX_17 UEditableTextBox
---@field MOX_18 UEditableTextBox
---@field MOX_19 UEditableTextBox
---@field MOX_2 UEditableTextBox
---@field MOX_20 UEditableTextBox
---@field MOX_21 UEditableTextBox
---@field MOX_22 UEditableTextBox
---@field MOX_23 UEditableTextBox
---@field MOX_3 UEditableTextBox
---@field MOX_4 UEditableTextBox
---@field MOX_5 UEditableTextBox
---@field MOX_6 UEditableTextBox
---@field MOX_7 UEditableTextBox
---@field MOX_8 UEditableTextBox
---@field MOX_9 UEditableTextBox
---@field ModelOffsetX UHorizontalBox
---@field ModelOffsetY UHorizontalBox
---@field ModelOffsetZ UHorizontalBox
---@field ModelPitch UHorizontalBox
---@field ModelRoll UHorizontalBox
---@field ModelYaw UHorizontalBox
---@field PanelBG1 UFCanvasPanel
---@field S0_DescDirection UHorizontalBox
---@field S0_DescDistance UHorizontalBox
---@field S0_DescOffsetX UHorizontalBox
---@field S0_DescOffsetY UHorizontalBox
---@field S0_Description UHorizontalBox
---@field S0_OffsetX UHorizontalBox
---@field S0_OffsetY UHorizontalBox
---@field S0_OffsetZ UHorizontalBox
---@field S0_Pitch UHorizontalBox
---@field S0_Roll UHorizontalBox
---@field S0_Yaw UHorizontalBox
---@field Slider_MOX USlider
---@field Slider_MOX_1 USlider
---@field Slider_MOX_10 USlider
---@field Slider_MOX_11 USlider
---@field Slider_MOX_12 USlider
---@field Slider_MOX_13 USlider
---@field Slider_MOX_14 USlider
---@field Slider_MOX_15 USlider
---@field Slider_MOX_16 USlider
---@field Slider_MOX_17 USlider
---@field Slider_MOX_18 USlider
---@field Slider_MOX_19 USlider
---@field Slider_MOX_2 USlider
---@field Slider_MOX_20 USlider
---@field Slider_MOX_21 USlider
---@field Slider_MOX_23 USlider
---@field Slider_MOX_3 USlider
---@field Slider_MOX_4 USlider
---@field Slider_MOX_5 USlider
---@field Slider_MOX_6 USlider
---@field Slider_MOX_7 USlider
---@field Slider_MOX_8 USlider
---@field Slider_MOX_9 USlider
---@field TextBlock_MOX UTextBlock
---@field TextBlock_MOX_1 UTextBlock
---@field TextBlock_MOX_10 UTextBlock
---@field TextBlock_MOX_11 UTextBlock
---@field TextBlock_MOX_12 UTextBlock
---@field TextBlock_MOX_13 UTextBlock
---@field TextBlock_MOX_14 UTextBlock
---@field TextBlock_MOX_15 UTextBlock
---@field TextBlock_MOX_16 UTextBlock
---@field TextBlock_MOX_17 UTextBlock
---@field TextBlock_MOX_18 UTextBlock
---@field TextBlock_MOX_19 UTextBlock
---@field TextBlock_MOX_2 UTextBlock
---@field TextBlock_MOX_20 UTextBlock
---@field TextBlock_MOX_21 UTextBlock
---@field TextBlock_MOX_22 UTextBlock
---@field TextBlock_MOX_23 UTextBlock
---@field TextBlock_MOX_3 UTextBlock
---@field TextBlock_MOX_4 UTextBlock
---@field TextBlock_MOX_5 UTextBlock
---@field TextBlock_MOX_6 UTextBlock
---@field TextBlock_MOX_7 UTextBlock
---@field TextBlock_MOX_8 UTextBlock
---@field TextBlock_MOX_9 UTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountPanelDeBugUIView = LuaClass(UIView, true)

function MountPanelDeBugUIView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GS_DefaultCameraDistance = nil
	--self.GS_OffsetX = nil
	--self.GS_OffsetY = nil
	--self.GS_OffsetZ = nil
	--self.GS_Pitch = nil
	--self.GS_Roll = nil
	--self.GS_Yaw = nil
	--self.MOX = nil
	--self.MOX_1 = nil
	--self.MOX_10 = nil
	--self.MOX_11 = nil
	--self.MOX_12 = nil
	--self.MOX_13 = nil
	--self.MOX_14 = nil
	--self.MOX_15 = nil
	--self.MOX_16 = nil
	--self.MOX_17 = nil
	--self.MOX_18 = nil
	--self.MOX_19 = nil
	--self.MOX_2 = nil
	--self.MOX_20 = nil
	--self.MOX_21 = nil
	--self.MOX_22 = nil
	--self.MOX_23 = nil
	--self.MOX_3 = nil
	--self.MOX_4 = nil
	--self.MOX_5 = nil
	--self.MOX_6 = nil
	--self.MOX_7 = nil
	--self.MOX_8 = nil
	--self.MOX_9 = nil
	--self.ModelOffsetX = nil
	--self.ModelOffsetY = nil
	--self.ModelOffsetZ = nil
	--self.ModelPitch = nil
	--self.ModelRoll = nil
	--self.ModelYaw = nil
	--self.PanelBG1 = nil
	--self.S0_DescDirection = nil
	--self.S0_DescDistance = nil
	--self.S0_DescOffsetX = nil
	--self.S0_DescOffsetY = nil
	--self.S0_Description = nil
	--self.S0_OffsetX = nil
	--self.S0_OffsetY = nil
	--self.S0_OffsetZ = nil
	--self.S0_Pitch = nil
	--self.S0_Roll = nil
	--self.S0_Yaw = nil
	--self.Slider_MOX = nil
	--self.Slider_MOX_1 = nil
	--self.Slider_MOX_10 = nil
	--self.Slider_MOX_11 = nil
	--self.Slider_MOX_12 = nil
	--self.Slider_MOX_13 = nil
	--self.Slider_MOX_14 = nil
	--self.Slider_MOX_15 = nil
	--self.Slider_MOX_16 = nil
	--self.Slider_MOX_17 = nil
	--self.Slider_MOX_18 = nil
	--self.Slider_MOX_19 = nil
	--self.Slider_MOX_2 = nil
	--self.Slider_MOX_20 = nil
	--self.Slider_MOX_21 = nil
	--self.Slider_MOX_23 = nil
	--self.Slider_MOX_3 = nil
	--self.Slider_MOX_4 = nil
	--self.Slider_MOX_5 = nil
	--self.Slider_MOX_6 = nil
	--self.Slider_MOX_7 = nil
	--self.Slider_MOX_8 = nil
	--self.Slider_MOX_9 = nil
	--self.TextBlock_MOX = nil
	--self.TextBlock_MOX_1 = nil
	--self.TextBlock_MOX_10 = nil
	--self.TextBlock_MOX_11 = nil
	--self.TextBlock_MOX_12 = nil
	--self.TextBlock_MOX_13 = nil
	--self.TextBlock_MOX_14 = nil
	--self.TextBlock_MOX_15 = nil
	--self.TextBlock_MOX_16 = nil
	--self.TextBlock_MOX_17 = nil
	--self.TextBlock_MOX_18 = nil
	--self.TextBlock_MOX_19 = nil
	--self.TextBlock_MOX_2 = nil
	--self.TextBlock_MOX_20 = nil
	--self.TextBlock_MOX_21 = nil
	--self.TextBlock_MOX_22 = nil
	--self.TextBlock_MOX_23 = nil
	--self.TextBlock_MOX_3 = nil
	--self.TextBlock_MOX_4 = nil
	--self.TextBlock_MOX_5 = nil
	--self.TextBlock_MOX_6 = nil
	--self.TextBlock_MOX_7 = nil
	--self.TextBlock_MOX_8 = nil
	--self.TextBlock_MOX_9 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountPanelDeBugUIView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountPanelDeBugUIView:OnInit()
	self.MountView = nil
	self.CameraInitOffsetY = 80
end

function MountPanelDeBugUIView:OnShow()
	print(" [MountPanelDeBugUIView] 仅供模型位置、镜头位置调试使用")
end

function MountPanelDeBugUIView:OnHide()

end

function MountPanelDeBugUIView:OnRegisterUIEvent()
	if not CommonUtil.IsWithEditor() then
		return
	end
	---模型位置
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX, self.OnSliderValueChange)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_1, self.OnSliderValueChange_1)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_2, self.OnSliderValueChange_2)
	UIUtil.AddOnTextChangedEvent(self, self.MOX, self.OnTextChangedMOX)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_1, self.OnTextChangedMOX_1)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_2, self.OnTextChangedMOX_2)
	---模型旋转
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_3, self.OnSliderValueChange_3)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_4, self.OnSliderValueChange_4)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_5, self.OnSliderValueChange_5)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_3, self.OnTextChangedMOX_3)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_4, self.OnTextChangedMOX_4)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_5, self.OnTextChangedMOX_5)
	---全身镜头默认视距
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_6, self.OnSliderValueChange_6)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_6, self.OnTextChangedMOX_6)
	---全身镜头偏移
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_7, self.OnSliderValueChange_7)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_8, self.OnSliderValueChange_8)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_9, self.OnSliderValueChange_9)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_7, self.OnTextChangedMOX_7)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_8, self.OnTextChangedMOX_8)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_9, self.OnTextChangedMOX_9)
	---全身镜头旋转
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_10, self.OnSliderValueChange_10)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_11, self.OnSliderValueChange_11)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_12, self.OnSliderValueChange_12)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_10, self.OnTextChangedMOX_10)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_11, self.OnTextChangedMOX_11)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_12, self.OnTextChangedMOX_12)
	---特写镜头
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_13, self.OnSliderValueChange_13)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_14, self.OnSliderValueChange_14)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_15, self.OnSliderValueChange_15)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_16, self.OnSliderValueChange_16)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_17, self.OnSliderValueChange_17)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_18, self.OnSliderValueChange_18)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_19, self.OnSliderValueChange_19)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_20, self.OnSliderValueChange_20)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_21, self.OnSliderValueChange_21)
	UIUtil.AddOnValueChangedEvent(self, self.Slider_MOX_23, self.OnSliderValueChange_23)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_13, self.OnTextChangedMOX_13)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_14, self.OnTextChangedMOX_14)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_15, self.OnTextChangedMOX_15)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_16, self.OnTextChangedMOX_16)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_17, self.OnTextChangedMOX_17)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_18, self.OnTextChangedMOX_18)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_19, self.OnTextChangedMOX_19)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_20, self.OnTextChangedMOX_20)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_21, self.OnTextChangedMOX_21)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_22, self.OnTextChangedMOX_22)
	UIUtil.AddOnTextChangedEvent(self, self.MOX_23, self.OnTextChangedMOX_23)
end

--------SetModelLocation
function MountPanelDeBugUIView:OnSliderValueChange()
	local SliderValue = math.floor(self.Slider_MOX:GetValue())
	self.MOX:SetText(SliderValue)
	self.MountView.ModelToImage:SetModelLocation(SliderValue, self.MountView.ModelToImage:GetModelLocation().Y, self.MountView.ModelToImage:GetModelLocation().Z, true)
end

function MountPanelDeBugUIView:OnSliderValueChange_1()
	local SliderValue = math.floor(self.Slider_MOX_1:GetValue())
	self.MOX_1:SetText(SliderValue)
	self.MountView.ModelToImage:SetModelLocation(self.MountView.ModelToImage:GetModelLocation().X, SliderValue, self.MountView.ModelToImage:GetModelLocation().Z, true)
end

function MountPanelDeBugUIView:OnSliderValueChange_2()
	local SliderValue = math.floor(self.Slider_MOX_2:GetValue())
	self.MOX_2:SetText(SliderValue)
	self.MountView.ModelToImage:SetModelLocation(self.MountView.ModelToImage:GetModelLocation().X, self.MountView.ModelToImage:GetModelLocation().Y, SliderValue, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX()
	local SliderValue = tonumber(self.MOX:GetText())
	self.Slider_MOX:SetValue(SliderValue)
	self.MountView.ModelToImage:SetModelLocation(SliderValue, self.MountView.ModelToImage:GetModelLocation().Y, self.MountView.ModelToImage:GetModelLocation().Z, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_1()
	local SliderValue = tonumber(self.MOX_1:GetText())
	self.Slider_MOX_1:SetValue(SliderValue)
	self.MountView.ModelToImage:SetModelLocation(self.MountView.ModelToImage:GetModelLocation().X, SliderValue, self.MountView.ModelToImage:GetModelLocation().Z, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_2()
	local SliderValue = tonumber(self.MOX_2:GetText())
	self.Slider_MOX_2:SetValue(SliderValue)
	self.MountView.ModelToImage:SetModelLocation(self.MountView.ModelToImage:GetModelLocation().X, self.MountView.ModelToImage:GetModelLocation().Y, SliderValue, true)
end

--------SetModelRotation
function MountPanelDeBugUIView:OnSliderValueChange_3()
	local SliderValue = math.floor(self.Slider_MOX_3:GetValue())
	self.MOX_3:SetText(SliderValue)
	local MountCom = self.MountView.ModelToImage.UIComplexCharacter:GetRideMeshComponent()
	self.MountView.ModelToImage:SetModelRotation(SliderValue, MountCom:GetRelativeRotation().Yaw, MountCom:GetRelativeRotation().Roll, true)
end

function MountPanelDeBugUIView:OnSliderValueChange_4()
	local SliderValue = math.floor(self.Slider_MOX_4:GetValue())
	self.MOX_4:SetText(SliderValue)
	local MountCom = self.MountView.ModelToImage.UIComplexCharacter:GetRideMeshComponent()
	self.MountView.ModelToImage:SetModelRotation(MountCom:GetRelativeRotation().Pitch, SliderValue, MountCom:GetRelativeRotation().Roll, true)
end

function MountPanelDeBugUIView:OnSliderValueChange_5()
	local SliderValue = math.floor(self.Slider_MOX_5:GetValue())
	self.MOX_5:SetText(SliderValue)
	local MountCom = self.MountView.ModelToImage.UIComplexCharacter:GetRideMeshComponent()
	self.MountView.ModelToImage:SetModelRotation(MountCom:GetRelativeRotation().Pitch, MountCom:GetRelativeRotation().Yaw, SliderValue, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_3()
	local SliderValue = tonumber(self.MOX_3:GetText())
	self.Slider_MOX_3:SetValue(SliderValue)
	local MountCom = self.MountView.ModelToImage.UIComplexCharacter:GetRideMeshComponent()
	self.MountView.ModelToImage:SetModelRotation(SliderValue, MountCom:GetRelativeRotation().Yaw, MountCom:GetRelativeRotation().Roll, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_4()
	local SliderValue = tonumber(self.MOX_4:GetText())
	self.Slider_MOX_4:SetValue(SliderValue)
	local MountCom = self.MountView.ModelToImage.UIComplexCharacter:GetRideMeshComponent()
	self.MountView.ModelToImage:SetModelRotation(MountCom:GetRelativeRotation().Pitch, SliderValue, MountCom:GetRelativeRotation().Roll, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_5()
	local SliderValue = tonumber(self.MOX_5:GetText())
	self.Slider_MOX_5:SetValue(SliderValue)
	local MountCom = self.MountView.ModelToImage.UIComplexCharacter:GetRideMeshComponent()
	self.MountView.ModelToImage:SetModelRotation(MountCom:GetRelativeRotation().Pitch, MountCom:GetRelativeRotation().Yaw, SliderValue, true)
end

--------SetSpringArmDistance
function MountPanelDeBugUIView:OnSliderValueChange_6()
	local SliderValue = math.floor(self.Slider_MOX_6:GetValue())
	self.MOX_6:SetText(SliderValue)
	self.MountView.ModelToImage:SetSpringArmDistance(SliderValue, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_6()
	local SliderValue = tonumber(self.MOX_6:GetText())
	self.Slider_MOX_6:SetValue(SliderValue)
	self.MountView.ModelToImage:SetSpringArmDistance(SliderValue, true)
end

--------SetSpringArmLocation
function MountPanelDeBugUIView:OnSliderValueChange_7()
	local SliderValue = math.floor(self.Slider_MOX_7:GetValue())
	self.MOX_7:SetText(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(SliderValue + self.MountView.CameraFocusCfgMap:GetSpringArmOriginX("c0101"), y, z, true)
end

function MountPanelDeBugUIView:OnSliderValueChange_8()
	local SliderValue = math.floor(self.Slider_MOX_8:GetValue())
	self.MOX_8:SetText(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(x, SliderValue + 80 + self.MountView.CameraFocusCfgMap:GetSpringArmOriginY("c0101"), z, true)
end

function MountPanelDeBugUIView:OnSliderValueChange_9()
	local SliderValue = math.floor(self.Slider_MOX_9:GetValue())
	self.MOX_9:SetText(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(x, y, SliderValue + self.MountView.CameraFocusCfgMap:GetSpringArmOriginZ("c0101"), true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_7()
	local SliderValue = tonumber(self.MOX_7:GetText())
	self.Slider_MOX_7:SetValue(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(SliderValue + self.MountView.CameraFocusCfgMap:GetSpringArmOriginX("c0101"), y, z, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_8()
	local SliderValue = tonumber(self.MOX_8:GetText())
	self.Slider_MOX_8:SetValue(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(x, SliderValue + 80 + self.MountView.CameraFocusCfgMap:GetSpringArmOriginY("c0101"), z, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_9()
	local SliderValue = tonumber(self.MOX_9:GetText())
	self.Slider_MOX_9:SetValue(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(x, y, SliderValue + self.MountView.CameraFocusCfgMap:GetSpringArmOriginZ("c0101"), true)
end

---------SetSpringArmRotation
function MountPanelDeBugUIView:OnSliderValueChange_10()
	local SliderValue = math.floor(self.Slider_MOX_10:GetValue())
	self.MOX_10:SetText(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(SliderValue, Yew, Roll, true, 8)
end

function MountPanelDeBugUIView:OnSliderValueChange_11()
	local SliderValue = math.floor(self.Slider_MOX_11:GetValue())
	self.MOX_11:SetText(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(Pitch, SliderValue + 180, Roll, true, 8)
end

function MountPanelDeBugUIView:OnSliderValueChange_12()
	local SliderValue = math.floor(self.Slider_MOX_12:GetValue())
	self.MOX_12:SetText(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(Pitch, Yew, SliderValue, true, 8)
end

function MountPanelDeBugUIView:OnTextChangedMOX_10()
	local SliderValue = tonumber(self.MOX_10:GetText())
	self.Slider_MOX_10:SetValue(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(SliderValue, Yew, Roll, true, 8)
end

function MountPanelDeBugUIView:OnTextChangedMOX_11()
	local SliderValue = tonumber(self.MOX_11:GetText())
	self.Slider_MOX_11:SetValue(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(Pitch, SliderValue + 180, Roll, true, 8)
end

function MountPanelDeBugUIView:OnTextChangedMOX_12()
	local SliderValue = tonumber(self.MOX_12:GetText())
	self.Slider_MOX_12:SetValue(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(Pitch, Yew, SliderValue, true, 8)
end

---------Shot
---------Shot Description
function MountPanelDeBugUIView:OnTextChangedMOX_22()
	local Description = self.MOX_22:GetText()

	if self.MountView.GuidelineViewList[1] then
		local VM = self.MountView.GuidelineViewList[1].ViewModel
		VM.Text = Description
	end
end

---------Shot DescOffset
function MountPanelDeBugUIView:OnSliderValueChange_13()
	local SliderValue = math.floor(self.Slider_MOX_13:GetValue())
	self.MOX_13:SetText(SliderValue)

	if self.MountView.GuidelineViewList[1] then
		local VM = self.MountView.GuidelineViewList[1].ViewModel
		local OffsetX, OffsetY = VM.Offset:GetValue()
		VM.Index = 1
		VM.Offset:SetValue(SliderValue, OffsetY)
	end
end

function MountPanelDeBugUIView:OnSliderValueChange_14()
	local SliderValue = math.floor(self.Slider_MOX_14:GetValue())
	self.MOX_14:SetText(SliderValue)

	if self.MountView.GuidelineViewList[1] then
		local VM = self.MountView.GuidelineViewList[1].ViewModel
		local OffsetX, OffsetY = VM.Offset:GetValue()
		VM.Index = 1
		VM.Offset:SetValue(OffsetX, SliderValue)
	end
end

function MountPanelDeBugUIView:OnTextChangedMOX_13()
	local SliderValue = tonumber(self.MOX_13:GetText())
	self.Slider_MOX_13:SetValue(SliderValue)

	if self.MountView.GuidelineViewList[1] then
		local VM = self.MountView.GuidelineViewList[1].ViewModel
		local OffsetX, OffsetY = VM.Offset:GetValue()
		VM.Index = 1
		VM.Offset:SetValue(SliderValue, OffsetY)
	end
end

function MountPanelDeBugUIView:OnTextChangedMOX_14()
	local SliderValue = tonumber(self.MOX_14:GetText())
	self.Slider_MOX_14:SetValue(SliderValue)

	if self.MountView.GuidelineViewList[1] then
		local VM = self.MountView.GuidelineViewList[1].ViewModel
		local OffsetX, OffsetY = VM.Offset:GetValue()
		VM.Index = 1
		VM.Offset:SetValue(OffsetX, SliderValue)
	end
end

---------Shot DescDirection
function MountPanelDeBugUIView:OnSliderValueChange_23()
	local SliderValue = math.floor(self.Slider_MOX_23:GetValue())
	self.MOX_23:SetText(SliderValue)

	if self.MountView.GuidelineViewList[1] then
		local VM = self.MountView.GuidelineViewList[1].ViewModel
		VM.Direction = SliderValue
	end
end

function MountPanelDeBugUIView:OnTextChangedMOX_23()
	local SliderValue = tonumber(self.MOX_23:GetText())
	self.Slider_MOX_23:SetValue(SliderValue)

	if self.MountView.GuidelineViewList[1] then
		local VM = self.MountView.GuidelineViewList[1].ViewModel
		VM.Direction = SliderValue
	end
end

---------Shot DefaultCameraDistance
function MountPanelDeBugUIView:OnSliderValueChange_15()
	local SliderValue = math.floor(self.Slider_MOX_15:GetValue())
	self.MOX_15:SetText(SliderValue)

	self.MountView.ModelToImage:SetSpringArmDistance(SliderValue, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_15()
	local SliderValue = tonumber(self.MOX_15:GetText())
	self.Slider_MOX_15:SetValue(SliderValue)

	self.MountView.ModelToImage:SetSpringArmDistance(SliderValue, true)
end

--------Shot SetSpringArmLocation
function MountPanelDeBugUIView:OnSliderValueChange_16()
	local SliderValue = math.floor(self.Slider_MOX_16:GetValue())
	self.MOX_16:SetText(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(SliderValue + self.MountView.CameraFocusCfgMap:GetSpringArmOriginX("c0101"), y, z, true)
end

function MountPanelDeBugUIView:OnSliderValueChange_17()
	local SliderValue = math.floor(self.Slider_MOX_17:GetValue())
	self.MOX_17:SetText(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(x, SliderValue + 80 + self.MountView.CameraFocusCfgMap:GetSpringArmOriginY("c0101"), z, true)
end

function MountPanelDeBugUIView:OnSliderValueChange_18()
	local SliderValue = math.floor(self.Slider_MOX_18:GetValue())
	self.MOX_18:SetText(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(x, y, SliderValue + self.MountView.CameraFocusCfgMap:GetSpringArmOriginZ("c0101"), true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_16()
	local SliderValue = tonumber(self.MOX_16:GetText())
	self.Slider_MOX_16:SetValue(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(SliderValue + self.MountView.CameraFocusCfgMap:GetSpringArmOriginX("c0101"), y, z, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_17()
	local SliderValue = tonumber(self.MOX_17:GetText())
	self.Slider_MOX_17:SetValue(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(x, SliderValue + 80 + self.MountView.CameraFocusCfgMap:GetSpringArmOriginY("c0101"), z, true)
end

function MountPanelDeBugUIView:OnTextChangedMOX_18()
	local SliderValue = tonumber(self.MOX_18:GetText())
	self.Slider_MOX_18:SetValue(SliderValue)

	local SpringLocation = self.MountView.ModelToImage:GetSpringArmLocation()
	local x = SpringLocation.x
	local y = SpringLocation.y
	local z = SpringLocation.z
	self.MountView.ModelToImage:SetSpringArmLocation(x, y, SliderValue + self.MountView.CameraFocusCfgMap:GetSpringArmOriginZ("c0101"), true)
end

---------Shot SetSpringArmRotation
function MountPanelDeBugUIView:OnSliderValueChange_19()
	local SliderValue = math.floor(self.Slider_MOX_19:GetValue())
	self.MOX_19:SetText(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(SliderValue, Yew, Roll, true, 8)
end

function MountPanelDeBugUIView:OnSliderValueChange_20()
	local SliderValue = math.floor(self.Slider_MOX_20:GetValue())
	self.MOX_20:SetText(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(Pitch, SliderValue + 180, Roll, true, 8)
end

function MountPanelDeBugUIView:OnSliderValueChange_21()
	local SliderValue = math.floor(self.Slider_MOX_21:GetValue())
	self.MOX_21:SetText(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(Pitch, Yew, SliderValue, true, 8)
end

function MountPanelDeBugUIView:OnTextChangedMOX_19()
	local SliderValue = tonumber(self.MOX_19:GetText())
	self.Slider_MOX_19:SetValue(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(SliderValue, Yew, Roll, true, 8)
end

function MountPanelDeBugUIView:OnTextChangedMOX_20()
	local SliderValue = tonumber(self.MOX_20:GetText())
	self.Slider_MOX_20:SetValue(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(Pitch, SliderValue + 180, Roll, true, 8)
end

function MountPanelDeBugUIView:OnTextChangedMOX_21()
	local SliderValue = tonumber(self.MOX_21:GetText())
	self.Slider_MOX_21:SetValue(SliderValue)

	local CurRotation = self.MountView.ModelToImage:GetSpringArmRotation()
	local Pitch = CurRotation.Pitch
	local Yew = CurRotation.Yaw
	local Roll = CurRotation.Roll

	self.MountView.ModelToImage:SetSpringArmRotation(Pitch, Yew, SliderValue, true, 8)
end

return MountPanelDeBugUIView