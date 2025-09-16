---
--- Author: Administrator
--- DateTime: 2023-10-09 14:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")


---@class MapMarkerPlayStyleView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field PanelTrack UFCanvasPanel
---@field AnimScaleIn UWidgetAnimation
---@field AnimScaleOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerPlayStyleView = LuaClass(UIView, true)

function MapMarkerPlayStyleView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.PanelTrack = nil
	--self.AnimScaleIn = nil
	--self.AnimScaleOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerPlayStyleView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerPlayStyleView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
	}
end

function MapMarkerPlayStyleView:OnDestroy()

end

function MapMarkerPlayStyleView:OnShow()

end

function MapMarkerPlayStyleView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end
end

function MapMarkerPlayStyleView:OnRegisterUIEvent()

end

function MapMarkerPlayStyleView:OnRegisterGameEvent()

end

function MapMarkerPlayStyleView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerPlayStyleView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerPlayStyleView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerPlayStyleView:OnFollowStateChange(NewValue)
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

return MapMarkerPlayStyleView