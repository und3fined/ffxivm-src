---
--- Author: anypkvcai
--- DateTime: 2022-12-07 10:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")

local FVector2D = _G.UE.FVector2D

---@class MapMarkerRegionView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion1 UFButton
---@field BtnRegion2 UFButton
---@field ImgIcon UFImage
---@field PanelIcon UFCanvasPanel
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerRegionView = LuaClass(UIView, true)

function MapMarkerRegionView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion1 = nil
	--self.BtnRegion2 = nil
	--self.ImgIcon = nil
	--self.PanelIcon = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerRegionView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerRegionView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "NameVisibility", UIBinderSetVisibility.New(self, self.TextName) },
		{ "IsActive", UIBinderValueChangedCallback.New(self, nil, self.OnActiveStateChange) },
	}
end

function MapMarkerRegionView:OnDestroy()

end

function MapMarkerRegionView:OnShow()
	self:UpdateRegionInfo()
end

function MapMarkerRegionView:OnHide()

end

function MapMarkerRegionView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnRegion1, self.OnClickedRegion)
	--UIUtil.AddOnClickedEvent(self, self.BtnRegion2, self.OnClickedRegion)
end

function MapMarkerRegionView:OnRegisterGameEvent()

end

function MapMarkerRegionView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerRegionView:UpdateRegionInfo()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	local Cfg = MapMarker:GetMarkerRegionCfg()

	local BtnRegion1 = self.BtnRegion1
	UIUtil.CanvasSlotSetSize(BtnRegion1, FVector2D(Cfg.Col1W, Cfg.Col1H))
	UIUtil.CanvasSlotSetPosition(BtnRegion1, FVector2D(Cfg.Col1X, Cfg.Col1Y))

	local BtnRegion2 = self.BtnRegion2
	UIUtil.CanvasSlotSetSize(BtnRegion2, FVector2D(Cfg.Col2W, Cfg.Col2H))
	UIUtil.CanvasSlotSetPosition(BtnRegion2, FVector2D(Cfg.Col2X, Cfg.Col2Y))

	local TextName = self.TextName
	UIUtil.CanvasSlotSetPosition(TextName, FVector2D(Cfg.NameX, Cfg.NameY))

	local ColorHex, OutlineColorHex
	ColorHex = "ffffff"
	OutlineColorHex = "945600"
	UIUtil.TextBlockSetColorAndOpacityHex(TextName, ColorHex)
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(TextName, OutlineColorHex)

	local Alignment = MapUtil.GetRegionMarkerTextAlignment(MapMarker:GetLayout())
	UIUtil.CanvasSlotSetAlignment(TextName, Alignment)
end

function MapMarkerRegionView:OnScaleChanged(Scale)
	self.TextName:SetRenderScale(FVector2D(1 / Scale, 1 / Scale))
end

function MapMarkerRegionView:IsUnderLocation(ScreenPosition)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if not MapMarker:GetIsEnableHitTest() then
		return false
	end

	return UIUtil.IsUnderLocation(self.BtnRegion1, ScreenPosition) or UIUtil.IsUnderLocation(self.BtnRegion2, ScreenPosition)
end

function MapMarkerRegionView:OnActiveStateChange(NewValue)
	local InOpacity = NewValue and 1 or 0.3
	UIUtil.SetOpacity(self.ImgIcon, InOpacity)
end

function MapMarkerRegionView:PlayClickAnim()
	if self.AnimClick then
		self:PlayAnimation(self.AnimClick)
	end
end

return MapMarkerRegionView