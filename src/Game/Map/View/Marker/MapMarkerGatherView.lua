---
--- Author: anypkvcai
--- DateTime: 2023-06-19 16:46
--- Description: 小地图采集点
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MathUtil = require("Utils/MathUtil")
local MapVM = require("Game/Map/VM/MapVM")
local MapDefine = require("Game/Map/MapDefine")

local MapConstant = MapDefine.MapConstant
local MAP_PANEL_HALF_WIDTH = MapConstant.MAP_PANEL_HALF_WIDTH
local RADIUS = 73 -- 小地图里的采集显示半径，采集标记要贴边显示

local ViewPosition = _G.UE.FVector2D()


---@class MapMarkerGatherView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgDirection UFImage
---@field ImgIcon UFImage
---@field ImgTrack UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerGatherView = LuaClass(UIView, true)

function MapMarkerGatherView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgDirection = nil
	--self.ImgIcon = nil
	--self.ImgTrack = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerGatherView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerGatherView:OnInit()
	self.Scale = 1

	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IsMarkerVisible", UIBinderSetIsVisible.New(self, self.ImgIcon) },
		{ "IsDirectionVisible", UIBinderSetIsVisible.New(self, self.ImgDirection) },
		{ "IsTracking", UIBinderSetIsVisible.New(self, self.ImgTrack) },
		--{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
	}
end

function MapMarkerGatherView:OnDestroy()

end

function MapMarkerGatherView:OnShow()
	self:UpdateMarkerView()
end

function MapMarkerGatherView:OnHide()

end

function MapMarkerGatherView:OnRegisterUIEvent()

end

function MapMarkerGatherView:OnRegisterGameEvent()

end

function MapMarkerGatherView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerGatherView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerGatherView:IsUnderLocation(ScreenPosition)
	return false
end

function MapMarkerGatherView:OnScaleChanged(Scale)
	self.Scale = Scale

	--local ViewModel = self.Params
	--if nil == ViewModel then
	--	return
	--end
	--
	--local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, ViewModel:GetPosition())
	--UIUtil.CanvasSlotSetPosition(self, _G.UE.FVector2D(X, Y))
end

function MapMarkerGatherView:OnTimer()
	self:UpdateMarkerView()
end

function MapMarkerGatherView:UpdateMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())

	local MajorPos = MapVM:GetMajorPosition()

	local XTopLeft = MajorPos.X + MAP_PANEL_HALF_WIDTH
	local YTopLeft = MajorPos.Y + MAP_PANEL_HALF_WIDTH

	local OffsetX = X - XTopLeft
	local OffsetY = Y - YTopLeft

	if math.abs(OffsetX) > RADIUS or math.abs(OffsetY) > RADIUS then
		ViewModel:SetOutOfRange(true)
		local Angle = MathUtil.GetAngle(OffsetX, OffsetY)
		self.ImgDirection:SetRenderTransformAngle(Angle + 90) -- 加90度是因为美术贴图资源改了默认朝向

		--[[
		if X > XTopLeft + RADIUS then
			X = XTopLeft + RADIUS
		elseif X < XTopLeft - RADIUS then
			X = XTopLeft - RADIUS
		end

		if Y > YTopLeft + RADIUS then
			Y = YTopLeft + RADIUS
		elseif Y < YTopLeft - RADIUS then
			Y = YTopLeft - RADIUS
		end
		--]]

		local angle_radians = Angle * (math.pi / 180)
		local sin_value = math.sin(angle_radians)
		local cos_value = math.cos(angle_radians)
		X = XTopLeft + RADIUS * cos_value
		Y = YTopLeft + RADIUS * sin_value

		ViewPosition.X = X
		ViewPosition.Y = Y
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)
	else
		ViewModel:SetOutOfRange(false)
		ViewPosition.X = X
		ViewPosition.Y = Y
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)
	end
end

return MapMarkerGatherView