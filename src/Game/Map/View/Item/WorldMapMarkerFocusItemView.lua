---
--- Author: peterxie
--- DateTime: 2024-05-08 16:24
--- Description: 地图标记聚焦动效
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldMapMarkerFocusItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMapTagSelect UFImage
---@field AnimChange UWidgetAnimation
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerFocusItemView = LuaClass(UIView, true)

function WorldMapMarkerFocusItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMapTagSelect = nil
	--self.AnimChange = nil
	--self.AnimClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerFocusItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerFocusItemView:OnInit()

end

function WorldMapMarkerFocusItemView:OnDestroy()

end

function WorldMapMarkerFocusItemView:OnShow()

end

function WorldMapMarkerFocusItemView:OnHide()

end

function WorldMapMarkerFocusItemView:OnRegisterUIEvent()

end

function WorldMapMarkerFocusItemView:OnRegisterGameEvent()

end

function WorldMapMarkerFocusItemView:OnRegisterBinder()

end

function WorldMapMarkerFocusItemView:SetPositionByCenter(Position)
	local Size = UIUtil.CanvasSlotGetSize(self.ImgMapTagSelect)
	Position.X = Position.X - Size.X / 2
	Position.Y = Position.Y - Size.Y / 2
	UIUtil.CanvasSlotSetPosition(self, Position)
end

return WorldMapMarkerFocusItemView