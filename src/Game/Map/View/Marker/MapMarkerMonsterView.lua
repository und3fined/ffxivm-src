---
--- Author: peterxie
--- DateTime: 2024-11-07
--- Description: 小地图怪物
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUIUtil = require("Utils/ActorUIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local ViewPosition = _G.UE.FVector2D()
local ViewScale = _G.UE.FVector2D()


---@class MapMarkerMonsterView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field PanelIcon UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerMonsterView = LuaClass(UIView, true)

function MapMarkerMonsterView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.PanelIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerMonsterView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerMonsterView:OnInit()
	self.Scale = 1

	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
		{ "IsMarkerVisible", UIBinderSetIsVisible.New(self, self.PanelIcon) },
	}
end

function MapMarkerMonsterView:OnDestroy()

end

function MapMarkerMonsterView:OnShow()
	self:InitMarkerView()
	self:UpdateMarkerView()
end

function MapMarkerMonsterView:OnHide()

end

function MapMarkerMonsterView:OnRegisterUIEvent()

end

function MapMarkerMonsterView:OnRegisterGameEvent()

end

function MapMarkerMonsterView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerMonsterView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerMonsterView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.ImgIcon, ScreenPosition)
end

function MapMarkerMonsterView:OnScaleChanged(Scale)
	self.Scale = Scale
end

function MapMarkerMonsterView:InitMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	if MapMarker.IsColosseumCrystal then
		-- PVP地图水晶图标，将标记缩小显示
		ViewScale.X = 0.3
		ViewScale.Y = 0.3
	else
		ViewScale.X = 1
		ViewScale.Y = 1
	end
	self.PanelIcon:SetRenderScale(ViewScale)
end

function MapMarkerMonsterView:OnTimer()
	self:UpdateMarkerView()
end

function MapMarkerMonsterView:UpdateMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerMonster
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	if ViewModel:GetIsMarkerVisible() then
		local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())
		ViewPosition.X = X
		ViewPosition.Y = Y
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)
	end

	if MapMarker:IsEnmityMonster() then
		ViewModel:SetIsShowMarker(true)
	else
		ViewModel:SetIsShowMarker(false)
	end
end

return MapMarkerMonsterView