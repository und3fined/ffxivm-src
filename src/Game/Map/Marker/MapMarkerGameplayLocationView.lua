---
--- Author: Administrator
--- DateTime: 2024-10-23 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class MapMarkerGameplayLocationView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field PanelTrack UFCanvasPanel
---@field AnimChange UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerGameplayLocationView = LuaClass(UIView, true)

function MapMarkerGameplayLocationView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.PanelTrack = nil
	--self.AnimChange = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerGameplayLocationView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerGameplayLocationView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
	}
end

function MapMarkerGameplayLocationView:OnDestroy()

end

function MapMarkerGameplayLocationView:OnShow()

end

function MapMarkerGameplayLocationView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end
end

function MapMarkerGameplayLocationView:OnRegisterUIEvent()

end

function MapMarkerGameplayLocationView:OnRegisterGameEvent()

end

function MapMarkerGameplayLocationView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerGameplayLocationView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerGameplayLocationView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerGameplayLocation
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)

	local ImgSize
	local Radius = MapMarker:GetRadius()
	if Radius > 0 then
		ImgSize = _G.UE.FVector2D(Radius / 50 * Scale, Radius / 50 * Scale)
	else
		ImgSize = _G.UE.FVector2D(100, 100)
	end
	UIUtil.CanvasSlotSetSize(self.ImgIcon, ImgSize)
end

function MapMarkerGameplayLocationView:OnFollowStateChange(NewValue)
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

return MapMarkerGameplayLocationView