---
--- Author: anypkvcai
--- DateTime: 2022-12-27 10:30
--- Description: 点击地图放置标记项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class WorldMapPlacedMarkerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgIcon UFImage
---@field ImgMapTagSelect UFImage
---@field TextClickMark UFTextBlock
---@field AnimChange UWidgetAnimation
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapPlacedMarkerItemView = LuaClass(UIView, true)

function WorldMapPlacedMarkerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgIcon = nil
	--self.ImgMapTagSelect = nil
	--self.TextClickMark = nil
	--self.AnimChange = nil
	--self.AnimClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapPlacedMarkerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapPlacedMarkerItemView:OnInit()
	self.Binders = {
		{ "PlacedMarkerIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
	}
end

function WorldMapPlacedMarkerItemView:OnDestroy()

end

function WorldMapPlacedMarkerItemView:OnShow()
	self.TextClickMark:SetText(_G.LSTR(700033)) -- "标记点"

	local _, MapPlacedMarkerCfg = _G.WorldMapMgr:GetRecommendedTraceMarkerIndex()
	local DefaultIconPath = MapPlacedMarkerCfg.IconPath
	WorldMapVM:SetPlacedMarkerIconPath(DefaultIconPath)

	self:PlayAnimation(self.AnimClick)

	self.HideSelfTimerID = self:RegisterTimer(function()
		if not WorldMapVM.MapSetMarkPanelVisible then
			WorldMapVM:SetPlacedMarkerVisible(false)
		end
	end, 3.0)
end

function WorldMapPlacedMarkerItemView:OnHide()
	if self.HideSelfTimerID then
		self:UnRegisterTimer(self.HideSelfTimerID)
		self.HideSelfTimerID = nil
	end
end

function WorldMapPlacedMarkerItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickedBtnTransmit)
end

function WorldMapPlacedMarkerItemView:OnRegisterGameEvent()

end

function WorldMapPlacedMarkerItemView:OnRegisterBinder()
	self:RegisterBinders(WorldMapVM, self.Binders)
end

function WorldMapPlacedMarkerItemView:SetPositionByCenter(Position)
	local Size = UIUtil.CanvasSlotGetSize(self.ImgMapTagSelect)
	Position.X = Position.X - Size.X / 2
	Position.Y = Position.Y - Size.Y / 2
	UIUtil.CanvasSlotSetPosition(self, Position)
end

function WorldMapPlacedMarkerItemView:OnClickedBtnTransmit()
	WorldMapVM:ShowWorldMapPlaceMarkerPanel(nil)
end

return WorldMapPlacedMarkerItemView