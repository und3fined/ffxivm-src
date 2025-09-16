---
--- Author: peterxie
--- DateTime: 2025-02-24
--- Description: 地图通用玩法标记，只有一个图标，很多地方使用
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")


---@class MapMarkerCommGameplayView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field PanelMarker UFCanvasPanel
---@field PanelTrack UFCanvasPanel
---@field AnimScaleIn UWidgetAnimation
---@field AnimScaleOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerCommGameplayView = LuaClass(UIView, true)

function MapMarkerCommGameplayView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.PanelMarker = nil
	--self.PanelTrack = nil
	--self.AnimScaleIn = nil
	--self.AnimScaleOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerCommGameplayView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerCommGameplayView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.PanelMarker) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
	}
end

function MapMarkerCommGameplayView:OnDestroy()

end

function MapMarkerCommGameplayView:OnShow()

end

function MapMarkerCommGameplayView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end

	if self.HighlightAnimView then
		self.HighlightAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.HighlightAnimView)
		self.HighlightAnimView = nil
	end
end

function MapMarkerCommGameplayView:OnRegisterUIEvent()

end

function MapMarkerCommGameplayView:OnRegisterGameEvent()

end

function MapMarkerCommGameplayView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerCommGameplayView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerCommGameplayView:IsUnderLocation(ScreenPosition)
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

function MapMarkerCommGameplayView:OnFollowStateChange(NewValue)
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

function MapMarkerCommGameplayView:PlayHighlightEffect()
	if self.HighlightAnimView == nil then
		local View = MapUtil.CreateHighlightAnimView()
		if self.PanelTrack then
			self.PanelTrack:AddChild(View)
			self.HighlightAnimView = View
		end
	end
	if self.HighlightAnimView then
		self.HighlightAnimView:PlayAnimIn()
	end
end

return MapMarkerCommGameplayView