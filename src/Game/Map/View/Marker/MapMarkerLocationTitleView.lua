---
--- Author: peterxie
--- DateTime: 2024-07-05 10:05
--- Description: 一级地图主城标题
---

local LuaClass = require("Core/LuaClass")
local MapMarkerCommIconBaseView = require("Game/Map/View/Marker/MapMarkerCommIconBaseView")


---@class MapMarkerLocationTitleView : MapMarkerCommIconBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field PanelLocationTitle UFCanvasPanel
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerLocationTitleView = LuaClass(MapMarkerCommIconBaseView, true)

function MapMarkerLocationTitleView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.PanelLocationTitle = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerLocationTitleView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

return MapMarkerLocationTitleView