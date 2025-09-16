---
--- Author: anypkvcai
--- DateTime: 2023-03-13 10:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")

---@class MapMarkerPlaceNameView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerPlaceNameView = LuaClass(UIView, true)

function MapMarkerPlaceNameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerPlaceNameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerPlaceNameView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "NameVisibility", UIBinderSetVisibility.New(self, self.TextName) },
	}
end

function MapMarkerPlaceNameView:OnDestroy()

end

function MapMarkerPlaceNameView:OnShow()

end

function MapMarkerPlaceNameView:OnHide()

end

function MapMarkerPlaceNameView:OnRegisterUIEvent()

end

function MapMarkerPlaceNameView:OnRegisterGameEvent()

end

function MapMarkerPlaceNameView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerPlaceNameView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerPlaceNameView:IsUnderLocation(ScreenPosition)
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

return MapMarkerPlaceNameView