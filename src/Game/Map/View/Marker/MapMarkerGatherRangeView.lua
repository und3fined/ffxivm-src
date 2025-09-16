---
--- Author: peterxie
--- DateTime: 2024-06-03 19:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")


---@class MapMarkerGatherRangeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field PanelIcon UFCanvasPanel
---@field PanelTrack UFCanvasPanel
---@field TextPlace UFTextBlock
---@field AnimScaleIn UWidgetAnimation
---@field AnimScaleOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerGatherRangeView = LuaClass(UIView, true)

function MapMarkerGatherRangeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.PanelIcon = nil
	--self.PanelTrack = nil
	--self.TextPlace = nil
	--self.AnimScaleIn = nil
	--self.AnimScaleOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerGatherRangeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerGatherRangeView:OnInit()
	self.Binders = {
		--{ "Name", UIBinderSetText.New(self, self.TextPlace) },
		{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.PanelIcon) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
	}
end

function MapMarkerGatherRangeView:OnDestroy()

end

function MapMarkerGatherRangeView:OnShow()
	self.TextPlace:SetText("")
end

function MapMarkerGatherRangeView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end
end

function MapMarkerGatherRangeView:OnRegisterUIEvent()

end

function MapMarkerGatherRangeView:OnRegisterGameEvent()

end

function MapMarkerGatherRangeView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerGatherRangeView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerWorldMapGather
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

function MapMarkerGatherRangeView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerGatherRangeView:OnFollowStateChange(NewValue)
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

return MapMarkerGatherRangeView