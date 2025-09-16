--
-- Author: anypkvcai
-- Date: 2022-12-13 16:55
-- Description:
--


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")

---@class MapMarkerCommTextBaseView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerCommTextBaseView = LuaClass(UIView, true)

function MapMarkerCommTextBaseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerCommTextBaseView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerCommTextBaseView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "NameVisibility", UIBinderSetVisibility.New(self, self.TextName) },
	}
end

function MapMarkerCommTextBaseView:OnDestroy()

end

function MapMarkerCommTextBaseView:OnShow()
	self:UpdateColor()
end

function MapMarkerCommTextBaseView:OnHide()

end

function MapMarkerCommTextBaseView:OnRegisterUIEvent()

end

function MapMarkerCommTextBaseView:OnRegisterGameEvent()

end

function MapMarkerCommTextBaseView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerCommTextBaseView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerCommTextBaseView:IsUnderLocation(ScreenPosition)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if not MapMarker:GetIsEnableHitTest() then
		return false
	end

	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerCommTextBaseView:UpdateColor()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	local TextName = self.TextName
	local ColorHex, OutlineColorHex, FontSize = MapUtil.GetCommMarkerTextColor(MapMarker)

	UIUtil.TextBlockSetColorAndOpacityHex(TextName, ColorHex)
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(TextName, OutlineColorHex)
	UIUtil.TextBlockSetFontSize(TextName, FontSize)
end

return MapMarkerCommTextBaseView