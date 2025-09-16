---
--- Author: anypkvcai
--- DateTime: 2023-04-20 20:07
--- Description: 任务范围标记
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")


---@class MapMarkerQuestRangeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerQuestRangeView = LuaClass(UIView, true)

function MapMarkerQuestRangeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerQuestRangeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerQuestRangeView:OnInit()
	self.Binders = {
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.ImgIcon) },
	}
end

function MapMarkerQuestRangeView:OnDestroy()

end

function MapMarkerQuestRangeView:OnShow()

end

function MapMarkerQuestRangeView:OnHide()

end

function MapMarkerQuestRangeView:OnRegisterUIEvent()

end

function MapMarkerQuestRangeView:OnRegisterGameEvent()

end

function MapMarkerQuestRangeView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerQuestRangeView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerQuest
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	self.Scale = Scale

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)

	local CorrectedFactor = 2 -- 注意：任务范围，和钓场、采集的Radius不是一个量级，缩放因子不能统一
	local MapScale = MapUtil.GetMapScale(MapMarker:GetUIMapID())
	if nil == MapScale then
		return
	end

	local SizeValue = MapMarker:GetRadius() / MapScale * Scale * CorrectedFactor
	local Size = _G.UE.FVector2D(SizeValue, SizeValue)

	UIUtil.CanvasSlotSetSize(self.ImgIcon, Size)
end

function MapMarkerQuestRangeView:IsUnderLocation(ScreenPosition)
	return false
end

return MapMarkerQuestRangeView