---
--- Author: peterxie
--- DateTime:
--- Description: 房屋土地标记
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")


---@class MapMarkerHouseLandView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommHead CommHeadView
---@field ImgHouse UFImage
---@field ImgHouseS UFImage
---@field PanelHeadPlusIcon UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field SizeIcon USizeBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerHouseLandView = LuaClass(UIView, true)

function MapMarkerHouseLandView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommHead = nil
	--self.ImgHouse = nil
	--self.ImgHouseS = nil
	--self.PanelHeadPlusIcon = nil
	--self.PanelMarker = nil
	--self.SizeIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerHouseLandView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerHouseLandView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgHouse) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgHouseS) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.PanelMarker) },
	}
end

function MapMarkerHouseLandView:OnDestroy()

end

function MapMarkerHouseLandView:OnShow()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerHouseLand
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	UIUtil.SetIsVisible(self.ImgHouse, not MapMarker.IsShowPlayerHead)
	UIUtil.SetIsVisible(self.PanelHeadPlusIcon, MapMarker.IsShowPlayerHead)

	if MapMarker.IsShowPlayerHead and MapMarker.PlayerRoleID and MapMarker.PlayerRoleID ~= 0 then
		self.CommHead:SetInfo(MapMarker.PlayerRoleID)
		self.CommHead:SetIsTriggerClick(false)
	end
end

function MapMarkerHouseLandView:OnHide()

end

function MapMarkerHouseLandView:OnRegisterUIEvent()

end

function MapMarkerHouseLandView:OnRegisterGameEvent()

end

function MapMarkerHouseLandView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerHouseLandView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerHouseLandView:IsUnderLocation(ScreenPosition)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	return UIUtil.IsUnderLocation(self.PanelMarker, ScreenPosition)
end

return MapMarkerHouseLandView