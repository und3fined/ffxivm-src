---
--- Author: Administrator
--- DateTime: 2023-08-29 16:03
--- Description: 地图缩放
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldMapScaleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnSub UFButton
---@field ImgAdd UFImage
---@field ImgProgressBarBg UFImage
---@field ImgScrollbarFigure UFImage
---@field ImgSub UFImage
---@field ProgressBar UProgressBar
---@field Slider USlider
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapScaleItemView = LuaClass(UIView, true)

function WorldMapScaleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnSub = nil
	--self.ImgAdd = nil
	--self.ImgProgressBarBg = nil
	--self.ImgScrollbarFigure = nil
	--self.ImgSub = nil
	--self.ProgressBar = nil
	--self.Slider = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapScaleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapScaleItemView:OnInit()

end

function WorldMapScaleItemView:OnDestroy()

end

function WorldMapScaleItemView:OnShow()

end

function WorldMapScaleItemView:OnHide()

end

function WorldMapScaleItemView:OnRegisterUIEvent()

end

function WorldMapScaleItemView:OnRegisterGameEvent()

end

function WorldMapScaleItemView:OnRegisterBinder()

end

function WorldMapScaleItemView:UpdateSlider(MinValue, MaxValue)
	local Slider = self.Slider
	if nil == Slider then
		return
	end

	Slider:SetMinValue(MinValue)
	Slider:SetMaxValue(MaxValue)
end

function WorldMapScaleItemView:SetButtonVisible(IsVisible)
	UIUtil.SetIsVisible(self.ImgAdd, IsVisible or false)
	UIUtil.SetIsVisible(self.ImgSub, IsVisible or false)
end

return WorldMapScaleItemView