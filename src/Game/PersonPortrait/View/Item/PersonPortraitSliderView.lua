---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PersonPortraitSliderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ContentPanel UFCanvasPanel
---@field ImgIcon UFImage
---@field ProgressBar UProgressBar
---@field Slider USlider
---@field TextNum UFTextBlock
---@field MinValue float
---@field MaxValue float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitSliderView = LuaClass(UIView, true)

function PersonPortraitSliderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ContentPanel = nil
	--self.ImgIcon = nil
	--self.ProgressBar = nil
	--self.Slider = nil
	--self.TextNum = nil
	--self.MinValue = nil
	--self.MaxValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitSliderView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitSliderView:OnInit()
	self.Range = 1 
end

function PersonPortraitSliderView:OnDestroy()

end

function PersonPortraitSliderView:OnShow()
	self.LastPercent = nil
	self:SetContentRenderOpacity(1)
end

function PersonPortraitSliderView:OnHide()
end

function PersonPortraitSliderView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, self.Slider, self.OnValueChangedSlider)
end

function PersonPortraitSliderView:OnRegisterGameEvent()

end

function PersonPortraitSliderView:OnRegisterBinder()

end

function PersonPortraitSliderView:SetContentRenderOpacity(Opacity)
	UIUtil.SetRenderOpacity(self.ContentPanel, Opacity)
end

function PersonPortraitSliderView:OnValueChangedSlider(_, Percent)
	if Percent == self.LastPercent then  -- 用于解决超出滑动区域后，仍然会触发函数值变化
		return
	end

	self.LastPercent = Percent

	self.ProgressBar:SetPercent(Percent)

	local Value = math.ceil(self.MinValue + Percent * self.Range)
	self:SetTextNum(Value)

	if self.ValueChangedCallback ~= nil then
		self.ValueChangedCallback(Value)
	end
end

function PersonPortraitSliderView:SetImgIcon(Path)
	if string.isnilorempty(Path) then
		UIUtil.SetIsVisible(self.ImgIcon, false)
		return
	end

	UIUtil.SetIsVisible(self.ImgIcon, true)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Path)
end

function PersonPortraitSliderView:SetTextNum(Value)
	self.TextNum:SetText(tostring(Value))
end

function PersonPortraitSliderView:SetValueParam(Min, Max)
	self.MinValue = Min
	self.MaxValue = Max
	self.Range = math.max(Max - Min, 1)
end

---设置滑动条值
---@param Value float
function PersonPortraitSliderView:SetValue(Value)
	local Percent = (Value - self.MinValue) / self.Range

	self.LastPercent = Percent
	self.ProgressBar:SetPercent(Percent)
	self.Slider:SetValue(Percent)

	self:SetTextNum(Value)
end

function PersonPortraitSliderView:GetCurValue()
	local Percent = self.Slider:GetValue()
	return Percent * self.Range
end

function PersonPortraitSliderView:SetValueChangedCallback( func )
	self.ValueChangedCallback = func 
end

return PersonPortraitSliderView