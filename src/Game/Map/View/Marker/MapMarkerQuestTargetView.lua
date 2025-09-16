---
--- Author: anypkvcai
--- DateTime: 2023-04-13 10:47
--- Description: 小地图任务追踪和地图追踪方向箭头
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MathUtil = require("Utils/MathUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MapConstant = MapDefine.MapConstant
local MapVM = require("Game/Map/VM/MapVM")

local MAP_PANEL_HALF_WIDTH = MapConstant.MAP_PANEL_HALF_WIDTH
local RADIUS = MapConstant.MAP_RADIUS


---@class MapMarkerQuestTargetView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgDirection UFImage
---@field ImgMinTrack UFImage
---@field PanelMarker UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerQuestTargetView = LuaClass(UIView, true)

function MapMarkerQuestTargetView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgDirection = nil
	--self.ImgMinTrack = nil
	--self.PanelMarker = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerQuestTargetView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerQuestTargetView:OnInit()
	self.Scale = 1

	self.Binders = {
		{ "IsMarkerVisible", UIBinderSetIsVisible.New(self, self.PanelMarker) },
	}
end

function MapMarkerQuestTargetView:OnDestroy()

end

function MapMarkerQuestTargetView:OnShow()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	-- local IconPath = MapMarker:GetIconPath()
	-- if not string.isnilorempty(IconPath) then
	-- 	_G.UIUtil.ImageSetBrushFromAssetPath(self.ImgMinTrack, IconPath)
	-- end
	local ArrowPath = MapMarker:GetArrowPath()
	if not string.isnilorempty(ArrowPath) then
		_G.UIUtil.ImageSetBrushFromAssetPath(self.ImgDirection, ArrowPath)
	end

	self:UpdateMarkerView()
end

function MapMarkerQuestTargetView:OnHide()

end

function MapMarkerQuestTargetView:OnRegisterUIEvent()

end

function MapMarkerQuestTargetView:OnRegisterGameEvent()

end

function MapMarkerQuestTargetView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerQuestTargetView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerQuestTargetView:IsUnderLocation(ScreenPosition)
	return false
end

function MapMarkerQuestTargetView:OnScaleChanged(Scale)
	self.Scale = Scale
end

function MapMarkerQuestTargetView:OnTimer()
	self:UpdateMarkerView()
end

function MapMarkerQuestTargetView:UpdateMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())

	local MajorPos = MapVM:GetMajorPosition()

	local OffsetX = X - MAP_PANEL_HALF_WIDTH - MajorPos.X
	local OffsetY = Y - MAP_PANEL_HALF_WIDTH - MajorPos.Y

	if math.abs(OffsetX) > RADIUS or math.abs(OffsetY) > RADIUS then
		ViewModel:SetIsShowMarker(true)
		local Angle = MathUtil.GetAngle(OffsetX, OffsetY)
		self.PanelMarker:SetRenderTransformAngle(Angle)
	else
		ViewModel:SetIsShowMarker(false)
	end
end

return MapMarkerQuestTargetView