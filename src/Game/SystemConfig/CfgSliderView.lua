---
--- Author: chaooren
--- DateTime: 2021-10-22 16:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CfgSliderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CurrentValue_2 UFTextBlock
---@field MaxValue UFTextBlock
---@field MinValue UFTextBlock
---@field ValueSlider USlider
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CfgSliderView = LuaClass(UIView, true)

function CfgSliderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CurrentValue_2 = nil
	--self.MaxValue = nil
	--self.MinValue = nil
	--self.ValueSlider = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CfgSliderView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CfgSliderView:OnInit()
	self.ValueChangeFunc = nil
	self.bInt = false
	self.SaveKey = nil
end

function CfgSliderView:OnDestroy()

end

function CfgSliderView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	self.bInt = Params.bInt or false
	self.SaveKey = Params.SaveKey
	self:BindSliderValueChange(Params.Callback)
	self:SetSliderValue(Params.MinValue, Params.MaxValue, Params.CurValue)
end

function CfgSliderView:OnHide()

end

function CfgSliderView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, self.ValueSlider, self.OnSliderValueChange)
end

function CfgSliderView:OnRegisterGameEvent()

end

function CfgSliderView:OnRegisterBinder()

end

function CfgSliderView:BindSliderValueChange(Func)
	self.ValueChangeFunc = Func
end

function CfgSliderView:SetSliderValue(MinValue, MaxValue, CurValue)
	if MinValue and MaxValue then
		if self.bInt then
			MinValue = math.ceil(MinValue)
			MaxValue = math.floor(MaxValue)
		end
		self.ValueSlider:SetMinValue(MinValue)
		self.ValueSlider:SetMaxValue(MaxValue)

		self.MinValue:SetText(tostring(MinValue))
		self.MaxValue:SetText(tostring(MaxValue))
	end
	if CurValue ~= nil then
		if self.bInt then
			CurValue = math.floor(CurValue)
		end
		self.ValueSlider:SetValue(CurValue)
		self.CurrentValue_2:SetText(tostring(CurValue))
	end
end

function CfgSliderView:OnSliderValueChange(_, Value)
	if self.bInt then
		Value = math.floor(Value)
		self.CurrentValue_2:SetText(string.format("%d", Value))
	else
		self.CurrentValue_2:SetText(string.format("%.2f", Value))
	end
	if self.ValueChangeFunc ~= nil then
		local CallBack = self.ValueChangeFunc
		CallBack(Value)
		self:SaveData(Value)
	end
end

function CfgSliderView:SaveData(Data)
	if self.SaveKey then
		_G.UE.USaveMgr.SetFloat(self.SaveKey, Data, false)
	end
end

return CfgSliderView