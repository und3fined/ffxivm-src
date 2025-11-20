---
--- Author: peterxie
--- DateTime:
--- Description: PVP地图通用标记
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")

local ViewScale = _G.UE.FVector2D()


---@class MapMarkerPVPCommonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field PanelIcon UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field AnimNew UWidgetAnimation
---@field AnimScaleIn UWidgetAnimation
---@field AnimScaleOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerPVPCommonView = LuaClass(UIView, true)

function MapMarkerPVPCommonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.PanelIcon = nil
	--self.PanelMarker = nil
	--self.AnimNew = nil
	--self.AnimScaleIn = nil
	--self.AnimScaleOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerPVPCommonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerPVPCommonView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.PanelMarker) },
	}
end

function MapMarkerPVPCommonView:OnDestroy()

end

function MapMarkerPVPCommonView:OnShow()
	-- 将标记缩小显示
	ViewScale.X = 0.5
	ViewScale.Y = 0.5
	self.PanelMarker:SetRenderScale(ViewScale)
end

function MapMarkerPVPCommonView:OnHide()

end

function MapMarkerPVPCommonView:OnRegisterUIEvent()

end

function MapMarkerPVPCommonView:OnRegisterGameEvent()

end

function MapMarkerPVPCommonView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerPVPCommonView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerPVPCommonView:IsUnderLocation(ScreenPosition)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerPVPCommonView:UpdateMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	-- 小地图Size修改后，需要重新计算标记坐标
	local WorldPosX, WorldPosY, _ = MapMarker:GetWorldPos()
	local X, Y = MapUtil.GetUIPosByXY(WorldPosX, WorldPosY, MapMarker:GetUIMapID())
	local Scale = ViewModel:GetScale()
	X = X * Scale
	Y = Y * Scale
	MapMarker:SetAreaMapPos(X, Y)
	local MapMarkerViewPosition = _G.UE.FVector2D(0,0)
	MapMarkerViewPosition.X = X
	MapMarkerViewPosition.Y = Y
	UIUtil.CanvasSlotSetPosition(self, MapMarkerViewPosition)
end

function MapMarkerPVPCommonView:UpdateMarkerViewScale(Scale)
	ViewScale.X = Scale
	ViewScale.Y = Scale
	self.PanelMarker:SetRenderScale(ViewScale)
end

return MapMarkerPVPCommonView