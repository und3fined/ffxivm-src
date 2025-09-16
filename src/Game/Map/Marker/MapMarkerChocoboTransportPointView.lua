---
--- Author: sammrli
--- DateTime: 2024-04-30 15:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")

local MapDefine = require("Game/Map/MapDefine")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
--local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")

local MapMarkerType = MapDefine.MapMarkerType

---@class MapMarkerChocoboTransportPointView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field EnterBoom ChocoboTransportEnterBirdRoomItemView
---@field ImgIcon UFImage
---@field TrackAnim ChocoboTransportTrackBirdRoomItemView
---@field AnimChange UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerChocoboTransportPointView = LuaClass(UIView, true)

function MapMarkerChocoboTransportPointView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.EnterBoom = nil
	--self.ImgIcon = nil
	--self.TrackAnim = nil
	--self.AnimChange = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerChocoboTransportPointView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EnterBoom)
	self:AddSubView(self.TrackAnim)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerChocoboTransportPointView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
		{ "IconPath", UIBinderValueChangedCallback.New(self, nil, self.OnIconValueChanged)}
		--{ "Alpha", UIBinderSetOpacity.New(self, self.ImgIcon) },
	}
end

function MapMarkerChocoboTransportPointView:OnDestroy()

end

function MapMarkerChocoboTransportPointView:OnShow()
	if self.MapMarkerType == MapMarkerType.ChocoboTransportPoint then
		--self.TrackAnim:PlayAnim()
		UIUtil.SetIsVisible(self.TrackAnim, true)
		UIUtil.SetIsVisible(self.EnterBoom, false)
	else
		UIUtil.SetIsVisible(self.TrackAnim, false)
		UIUtil.SetIsVisible(self.EnterBoom, true)
	end
end

function MapMarkerChocoboTransportPointView:OnHide()

end

function MapMarkerChocoboTransportPointView:OnRegisterUIEvent()

end

function MapMarkerChocoboTransportPointView:OnRegisterGameEvent()

end

function MapMarkerChocoboTransportPointView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	if ViewModel.MapMarker then
		self.MapMarkerType = ViewModel.MapMarker:GetType()
	end

	self:RegisterBinders(ViewModel, self.Binders)
end


function MapMarkerChocoboTransportPointView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerChocoboTransportPointView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerChocoboTransportPointView:OnIconValueChanged()
	if self.MapMarkerType == MapMarkerType.ChocoboStable then
		local ViewModel = self.Params
		if nil == ViewModel then
			return
		end
		if ViewModel.MapMarker and ViewModel.MapMarker.IsBook then
			self.EnterBoom:PlayAnimInGold()
		else
			self.EnterBoom:PlayAnimInWhite()
		end
	end
end

return MapMarkerChocoboTransportPointView