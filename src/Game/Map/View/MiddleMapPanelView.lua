---
--- Author: anypkvcai
--- DateTime: 2022-10-24 14:51
--- Description: 废弃(中地图不要了)
---
--[[
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapVM = require("Game/Map/VM/MapVM")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local MapContentType = MapDefine.MapContentType
--local WidgetWidth = 1034 - 13 * 2
--local WidgetHeight = 769 - 13 * 2

---@class MiddleMapPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMap UFButton
---@field MapMarkerMajor MapMarkerMajorView
---@field NaviMapContent NaviMapContentView
---@field TextCoordinate UFTextBlock
---@field WeatherBox MapWeatherBoxItemView
---@field AnimDefault UWidgetAnimation
---@field AnimMapMToS UWidgetAnimation
---@field AnimMapSToM UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MiddleMapPanelView = LuaClass(UIView, true)

function MiddleMapPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMap = nil
	--self.MapMarkerMajor = nil
	--self.NaviMapContent = nil
	--self.TextCoordinate = nil
	--self.WeatherBox = nil
	--self.AnimDefault = nil
	--self.AnimMapMToS = nil
	--self.AnimMapSToM = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MiddleMapPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MapMarkerMajor)
	self:AddSubView(self.NaviMapContent)
	self:AddSubView(self.WeatherBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MiddleMapPanelView:OnInit()
	self.MapImgPosition = _G.UE.FVector2D(0, 0)

	self.NaviMapContent:SetContentType(MapContentType.MiddleMap)
end

function MiddleMapPanelView:OnDestroy()

end

function MiddleMapPanelView:OnShow()

end

function MiddleMapPanelView:OnHide()

end

function MiddleMapPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMap, self.OnClickedBtnMap)
end

function MiddleMapPanelView:OnRegisterGameEvent()

end

function MiddleMapPanelView:OnRegisterBinder()

end

function MiddleMapPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimerUpdateMap, 0, 0.2, 0)
end

function MiddleMapPanelView:OnTimerUpdateMap()
	self:UpdateImagePosition()

	self:UpdateCoordinate()
end

function MiddleMapPanelView:UpdateImagePosition()
	local Position = MapVM:GetMajorPosition()

	self.MapImgPosition.X = -Position.X
	self.MapImgPosition.Y = -Position.Y

	self.NaviMapContent:SetContentPosition(self.MapImgPosition)
end

function MiddleMapPanelView:UpdateCoordinate()
	local Text = MapUtil.GetCoordinateText()

	self.TextCoordinate:SetText(Text)
end

function MiddleMapPanelView:PlayShowAnimation()
	self:PlayAnimation(self.AnimMapSToM)
end

function MiddleMapPanelView:OnClickedBtnMap()
	UIViewMgr:ShowView(UIViewID.WorldMapPanel)
end

return MiddleMapPanelView

--]]