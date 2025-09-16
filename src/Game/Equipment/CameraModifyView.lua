---
--- Author: enqingchen
--- DateTime: 2022-10-31 16:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")

local ModifyCfg = 
{
	{MinValue = 1200, MaxValue = 2000},	--视距上限
	{MinValue = -80, MaxValue = 80},	--俯仰角上限
	{MinValue = 0, MaxValue = 20},	--摄像机操作灵敏度
	{MinValue = -100, MaxValue = 100},	--注视点高度偏移
}

---@class CameraModifyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_CloseBtn_UIBP CommonCloseBtnView
---@field Cur_0 UTextBlock
---@field Cur_1 UTextBlock
---@field Cur_2 UTextBlock
---@field Cur_3 UTextBlock
---@field Max_0 UTextBlock
---@field Max_1 UTextBlock
---@field Max_2 UTextBlock
---@field Max_3 UTextBlock
---@field Min_0 UTextBlock
---@field Min_1 UTextBlock
---@field Min_2 UTextBlock
---@field Min_3 UTextBlock
---@field Slider_0 USlider
---@field Slider_1 USlider
---@field Slider_2 USlider
---@field Slider_3 USlider
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CameraModifyView = LuaClass(UIView, true)

function CameraModifyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_CloseBtn_UIBP = nil
	--self.Cur_0 = nil
	--self.Cur_1 = nil
	--self.Cur_2 = nil
	--self.Cur_3 = nil
	--self.Max_0 = nil
	--self.Max_1 = nil
	--self.Max_2 = nil
	--self.Max_3 = nil
	--self.Min_0 = nil
	--self.Min_1 = nil
	--self.Min_2 = nil
	--self.Min_3 = nil
	--self.Slider_0 = nil
	--self.Slider_1 = nil
	--self.Slider_2 = nil
	--self.Slider_3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CameraModifyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_CloseBtn_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CameraModifyView:OnInit()

end

function CameraModifyView:OnDestroy()

end

function CameraModifyView:OnShow()
	for k,v in ipairs(ModifyCfg) do
		local CurValue = self:GetCurValue(k)
		
		local Slider = self["Slider_"..tostring(k - 1)]
		local Cur = self["Cur_"..tostring(k - 1)]
		local Min = self["Min_"..tostring(k - 1)]
		local Max = self["Max_"..tostring(k - 1)]

		Max:SetText(tostring(v.MaxValue))
		Min:SetText(tostring(v.MinValue))
		Cur:SetText(tostring(CurValue))
		
		Slider:SetMinValue(v.MinValue)
		Slider:SetMaxValue(v.MaxValue)
		Slider:SetValue(CurValue)

		UIUtil.AddOnValueChangedEvent(self, Slider, function ()
			self:OnSliderValueChange(k, Slider, Cur)
		end)
	end
end

function CameraModifyView:OnHide()

end

function CameraModifyView:OnRegisterUIEvent()

end

function CameraModifyView:OnRegisterGameEvent()

end

function CameraModifyView:OnRegisterBinder()

end

function CameraModifyView:GetCurValue(Key)
	local CameraControlComponent = MajorUtil.GetMajorCameraControlComponent()
	if CameraControlComponent == nil then
		return 0
	end

	if (Key == 1) then	--视距上限
		return CameraControlComponent:GetMaxCameraDistance()
	elseif (Key == 2) then	--俯仰角上限
		return CameraControlComponent:GetViewPitchMax()
	elseif (Key == 3) then --摄像机操作灵敏度
		return CameraControlComponent:GetTurnSpeed()
	elseif (Key == 4) then --注视点高度偏移
		local Offset = CameraControlComponent:GetTargetOffsetTarget()
		return Offset.Z
	end

	return 0
end

function CameraModifyView:OnSliderValueChange(Key, Slider, Cur)
	local CameraControlComponent = MajorUtil.GetMajorCameraControlComponent()
	if CameraControlComponent == nil then
		return 0
	end

	local Value = math.floor(Slider:GetValue())
	Cur:SetText(tostring(Value))
	if (Key == 1) then	--视距上限
		CameraControlComponent:SetMaxCameraDistance(Value)
	elseif (Key == 2) then	--俯仰角上限
		CameraControlComponent:SetViewPitchMax(Value)
	elseif (Key == 3) then --摄像机操作灵敏度
		CameraControlComponent:SetTurnSpeed(Value)
	elseif (Key == 4) then --注视点高度偏移
		local Offset = CameraControlComponent:GetTargetOffsetTarget()
		Offset.Z = Value
		CameraControlComponent:SetTargetOffsetTarget(Offset)
	end

end

return CameraModifyView