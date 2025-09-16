---
--- Author: anypkvcai
--- DateTime: 2023-07-04 20:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")

---@class MapMarkerFishRangeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field PanelTrack UFCanvasPanel
---@field TextPlace UFTextBlock
---@field AnimScaleIn UWidgetAnimation
---@field AnimScaleOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerFishRangeView = LuaClass(UIView, true)

function MapMarkerFishRangeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.PanelTrack = nil
	--self.TextPlace = nil
	--self.AnimScaleIn = nil
	--self.AnimScaleOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerFishRangeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerFishRangeView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextPlace) },
		{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
	}
end

function MapMarkerFishRangeView:OnDestroy()

end

function MapMarkerFishRangeView:OnShow()

end

function MapMarkerFishRangeView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end
end

function MapMarkerFishRangeView:OnRegisterUIEvent()

end

function MapMarkerFishRangeView:OnRegisterGameEvent()

end

function MapMarkerFishRangeView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerFishRangeView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerFish
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	self.Scale = Scale

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)

	local CorrectedFactor = 20
	local MapScale = MapUtil.GetMapScale(MapMarker:GetUIMapID())
	if nil == MapScale then
		return
	end

	local SizeValue = MapMarker:GetRadius() / MapScale * Scale * CorrectedFactor
	local Size = _G.UE.FVector2D(SizeValue, SizeValue)

	UIUtil.CanvasSlotSetSize(self.ImgNormal, Size)
	UIUtil.CanvasSlotSetSize(self.ImgSelect, Size)
end

function MapMarkerFishRangeView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerFishRangeView:OnFollowStateChange(NewValue)
	if NewValue then
		if self.TrackAnimView then
			self.TrackAnimView:PlayAnimLoop()
		else
			local View = MapUtil.CreateTrackAnimView()
			if self.PanelTrack then
				self.PanelTrack:AddChild(View)
				self.TrackAnimView = View
				self.TrackAnimView:PlayAnimLoop()
			end
		end
	else
		if self.TrackAnimView then
			self.TrackAnimView:StopAnimLoop()
		end
	end
end

return MapMarkerFishRangeView