---
--- Author: sammrli
--- DateTime: 2025-05-24 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")


---@class MapMarkerRedPointView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field PanelTrack UFCanvasPanel
---@field AnimChange UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerRedPointView = LuaClass(UIView, true)

function MapMarkerRedPointView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.PanelTrack = nil
	--self.AnimChange = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerRedPointView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerRedPointView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
		{ "Alpha", UIBinderSetOpacity.New(self, self.ImgIcon) },
	}
end

function MapMarkerRedPointView:OnDestroy()

end

function MapMarkerRedPointView:OnShow()

end

function MapMarkerRedPointView:OnHide()
end

function MapMarkerRedPointView:OnRegisterUIEvent()

end

function MapMarkerRedPointView:OnRegisterGameEvent()

end

function MapMarkerRedPointView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerRedPointView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerRedPointView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	--[[
	local QuestType = MapMarker:GetQuestType()
	if QuestType == 1 then
		UIUtil.SetColorAndOpacityHex(self.ImgIcon, "FF000080")
	elseif QuestType == 2 then
		UIUtil.SetColorAndOpacityHex(self.ImgIcon, "00FF0080")
	elseif QuestType == 3 then
		UIUtil.SetColorAndOpacityHex(self.ImgIcon, "0000FF80")
	else
		UIUtil.SetColorAndOpacityHex(self.ImgIcon, "FFFFFF80")
	end
	]]

	local MapScale = MapUtil.GetMapScale(MapMarker:GetUIMapID())
	if nil == MapScale then
		return
	end

	local SizeValue = MapMarker:GetRadius() / MapScale * Scale
	SizeValue = math.clamp( SizeValue, 80, 200)
	local Size = _G.UE.FVector2D(SizeValue, SizeValue)
	UIUtil.CanvasSlotSetSize(self.ImgIcon, Size)
end

function MapMarkerRedPointView:OnFollowStateChange(NewValue)
end

return MapMarkerRedPointView