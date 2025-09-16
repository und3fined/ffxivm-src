---
--- Author: anypkvcai
--- DateTime: 2023-01-05 19:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MapVM = require("Game/Map/VM/MapVM")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local MapUtil = require("Game/Map/MapUtil")
local EventID = require("Define/EventID")
local MapDefine = require("Game/Map/MapDefine")

local MapContentType = MapDefine.MapContentType
local FVector2D = _G.UE.FVector2D


---@class MapMarkerMajorView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCamara UFImage
---@field ImgMajor UFImage
---@field MajorPosition UFCanvasPanel
---@field PanelTrack UFCanvasPanel
---@field AnimIn1 UWidgetAnimation
---@field AnimLoop1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerMajorView = LuaClass(UIView, true)

function MapMarkerMajorView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCamara = nil
	--self.ImgMajor = nil
	--self.MajorPosition = nil
	--self.PanelTrack = nil
	--self.AnimIn1 = nil
	--self.AnimLoop1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerMajorView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerMajorView:OnInit()
	self.Scale = 1

	self.Binders = {
		--{ "MajorRotationAngle", UIBinderSetRenderTransformAngle.New(self, self.ImgMajor) },
		--{ "CameraRotationAngle", UIBinderSetRenderTransformAngle.New(self, self.ImgCamara) },
		{ "MajorRotationAngle", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMajorRotationAngle) },
		{ "CameraRotationAngle", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCameraRotationAngle) },
		{ "IsMajorVisible", UIBinderSetIsVisible.New(self, self.MajorPosition)},
		--{ "IsMajorVisible", UIBinderSetIsVisible.New(self, self.ImgCamara)},
		{ "MajorLeftTopPosition", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMajorPosition)},
	}
end

function MapMarkerMajorView:OnDestroy()

end

function MapMarkerMajorView:OnShow()
	local ParentView = self.ParentView
	if nil == ParentView then
		return
	end

	-- 主角标记，除小地图外，需要播放动效
	if ParentView.ObjectName ~= "MiniMap" then
		self:PlayAnimation(self.AnimIn1)
		self:PlayAnimation(self.AnimLoop1, 0, 0)
	end
end

function MapMarkerMajorView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end
end

function MapMarkerMajorView:OnRegisterUIEvent()

end

function MapMarkerMajorView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapChanged, self.OnGameEventMapChanged)
end

function MapMarkerMajorView:OnRegisterBinder()
	self:RegisterBinders(MapVM, self.Binders)

	-- self.BindersEx = {
	-- 	{ "MapAutoPathMoving", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
	-- }
	-- self:RegisterBinders(WorldMapVM, self.BindersEx)
end

function MapMarkerMajorView:OnGameEventMapChanged()
	local ParentView = self.ParentView
	if nil == ParentView then
		return
	end

	if MapContentType.WorldMap == ParentView.ContentType then
		-- 只处理大地图。打开大地图时，场景里移动主角切换UIMap，大地图的主角标记要更新
		if _G.WorldMapMgr:GetUIMapID() ~= _G.MapMgr:GetUIMapID() then
			UIUtil.SetIsVisible(self.MajorPosition, false)
		else
			UIUtil.SetIsVisible(self.MajorPosition, true)
		end
	end
end

function MapMarkerMajorView:OnScaleChanged(Scale)
	self.Scale = Scale

	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerMajorView:IsUnderLocation(ScreenPosition)
	return false
end

function MapMarkerMajorView:OnValueChangedMajorRotationAngle(Value)
	local ViewModel = self.Params
	if nil == ViewModel then
		self.ImgMajor:SetRenderTransformAngle(Value)
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	if MapMarker.InRegionIconUI or MapMarker.InWorldIconUI then
		self.ImgMajor:SetRenderTransformAngle(-90)
	else
		self.ImgMajor:SetRenderTransformAngle(Value)
	end
end

function MapMarkerMajorView:OnValueChangedCameraRotationAngle(Value)
	local ViewModel = self.Params
	if nil == ViewModel then
		-- 小地图主角标记是直接嵌到蓝图里的，没有VM
		self.ImgCamara:SetRenderTransformAngle(Value)
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	if MapMarker.InRegionIconUI or MapMarker.InWorldIconUI then
		UIUtil.SetIsVisible(self.ImgCamara, false)
	else
		UIUtil.SetIsVisible(self.ImgCamara, true)
		self.ImgCamara:SetRenderTransformAngle(Value)
	end
end

function MapMarkerMajorView:OnValueChangedMajorPosition(MajorLeftTopPosition)
	local ViewModel = self.Params
	if nil == ViewModel then
		-- 小地图主角标记是直接嵌到蓝图里的，没有VM
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	if MapMarker.InRegionIconUI or MapMarker.InWorldIconUI then
		UIUtil.SetIsVisible(self.ImgCamara, false)
	else
		-- 不能把三级地图的UI坐标用在二级地图上
		--[[
		local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, MajorLeftTopPosition.X, MajorLeftTopPosition.Y)
		UIUtil.CanvasSlotSetPosition(self, FVector2D(X, Y))
		--]]

		MapUtil.SetMapMarkerViewPosition(self.Scale, ViewModel, self)
	end
end


function MapMarkerMajorView:OnFollowStateChange(NewValue)
	local ViewModel = self.Params
	if nil == ViewModel then
		-- 小地图主角标记是直接嵌到蓝图里的，没有VM
		return
	end

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


return MapMarkerMajorView