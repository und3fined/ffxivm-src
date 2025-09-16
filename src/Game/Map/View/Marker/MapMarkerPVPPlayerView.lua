---
--- Author: peterxie
--- DateTime:
--- Description: PVP地图玩家标记
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local MapVM = require("Game/Map/VM/MapVM")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetProfIconSimple2nd = require("Binder/UIBinderSetProfIconSimple2nd")

local ViewPosition = _G.UE.FVector2D()
local ViewScale = _G.UE.FVector2D()


---@class MapMarkerPVPPlayerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCamara UFImage
---@field ImgJob UFImage
---@field ImgJob1 UFImage
---@field ImgJobBg UFImage
---@field ImgJobMe UFImage
---@field ImgJobSelect UFImage
---@field ImgJobSelectBg UFImage
---@field PanelJob UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerPVPPlayerView = LuaClass(UIView, true)

function MapMarkerPVPPlayerView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.PanelIcon = nil
	--AUTO GENERATED CODE 1 END, PLEAS.E DON'T MODIFY
end

function MapMarkerPVPPlayerView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerPVPPlayerView:OnInit()
	self.Scale = 1

	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgJobBg) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.PanelMarker) },
	}

	self.MajorBinders = {
		{ "MajorRotationAngle", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMajorRotationAngle) },
		{ "CameraRotationAngle", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCameraRotationAngle) },
		{ "MajorLeftTopPosition", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMajorPosition)},
	}

	self.TeamMemberBinders = {
		{ "ProfID", UIBinderSetProfIconSimple2nd.New(self, self.ImgJob) },
	}
end

function MapMarkerPVPPlayerView:OnDestroy()

end

function MapMarkerPVPPlayerView:OnShow()
	self:SetProfIcon()
	self:UpdateMarkerView()

	-- 将标记缩小显示
	ViewScale.X = 0.5
	ViewScale.Y = 0.5
	self.PanelMarker:SetRenderScale(ViewScale)
end

function MapMarkerPVPPlayerView:OnHide()

end

function MapMarkerPVPPlayerView:OnRegisterUIEvent()

end

function MapMarkerPVPPlayerView:OnRegisterGameEvent()

end

function MapMarkerPVPPlayerView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerPVPPlayer
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)

	if MapMarker.IsMajor then
		self:RegisterBinders(MapVM, self.MajorBinders)
	end

	self:RegisterBinders(MapMarker.MemberVM, self.TeamMemberBinders)
end

function MapMarkerPVPPlayerView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerPVPPlayerView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.PanelJob, ScreenPosition)
end

function MapMarkerPVPPlayerView:OnScaleChanged(Scale)
	self.Scale = Scale
end

function MapMarkerPVPPlayerView:SetProfIcon()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	-- 主角表现有差异
	UIUtil.SetIsVisible(self.ImgJobMe, MapMarker.IsMajor)
	UIUtil.SetIsVisible(self.ImgCamara, MapMarker.IsMajor)

	-- 高亮选中
	UIUtil.SetIsVisible(self.PanelSelect, false)
end

-- 主角朝向
function MapMarkerPVPPlayerView:OnValueChangedMajorRotationAngle(Value)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self.ImgJobMe:SetRenderTransformAngle(Value - 90)
end

-- 主角相机朝向
function MapMarkerPVPPlayerView:OnValueChangedCameraRotationAngle(Value)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self.ImgCamara:SetRenderTransformAngle(Value)
end

-- 主角位置
function MapMarkerPVPPlayerView:OnValueChangedMajorPosition(MajorLeftTopPosition)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, MajorLeftTopPosition.X, MajorLeftTopPosition.Y)
	ViewPosition.X = X
	ViewPosition.Y = Y
	UIUtil.CanvasSlotSetPosition(self, ViewPosition)
end

function MapMarkerPVPPlayerView:OnTimer()
	self:UpdateMarkerView()
end

function MapMarkerPVPPlayerView:UpdateMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	-- 其他玩家位置定时更新，主角位置更新方式和小地图保持一致
	if MapMarker.IsMajor then
		return
	end

	if ViewModel:GetIsMarkerVisible() then
		local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())
		ViewPosition.X = X
		ViewPosition.Y = Y
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)
	end
end

return MapMarkerPVPPlayerView