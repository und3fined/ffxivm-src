---
--- Author: anypkvcai
--- DateTime: 2023-01-02 23:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")


---@class MapMarkerPlacedView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field PanelTrack UFCanvasPanel
---@field AnimChange UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerPlacedView = LuaClass(UIView, true)

function MapMarkerPlacedView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.PanelTrack = nil
	--self.AnimChange = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerPlacedView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerPlacedView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
	}
end

function MapMarkerPlacedView:OnDestroy()

end

function MapMarkerPlacedView:OnShow()

end

function MapMarkerPlacedView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end
end

function MapMarkerPlacedView:OnRegisterUIEvent()

end

function MapMarkerPlacedView:OnRegisterGameEvent()

end

function MapMarkerPlacedView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerPlacedView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerPlacedView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerPlacedView:OnFollowStateChange(NewValue)
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

return MapMarkerPlacedView