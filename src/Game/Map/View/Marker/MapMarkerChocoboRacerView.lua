---
--- Author: yuhang_lightpaw
--- DateTime: 2024-11-04 16:36
--- Description: 陆行鸟竞赛玩家小地图
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local MapVM = require("Game/Map/VM/MapVM")

local MapConstant = MapDefine.MapConstant
local MapContentType = MapDefine.MapContentType
local MAP_PANEL_HALF_WIDTH = MapConstant.MAP_PANEL_HALF_WIDTH
local RADIUS = MapConstant.MAP_RADIUS
local ViewPosition = _G.UE.FVector2D()


---@class MapMarkerChocoboRacerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field PanelMarker UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerChocoboRacerView = LuaClass(UIView, true)

function MapMarkerChocoboRacerView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.PanelMarker = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerChocoboRacerView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerChocoboRacerView:OnInit()
    self.Scale = 1

    self.Binders = {
        { "IsMarkerVisible", UIBinderSetIsVisible.New(self, self.ImgIcon) },
        { "Color", UIBinderSetColorAndOpacity.New(self, self.ImgIcon) },
    }
end

function MapMarkerChocoboRacerView:OnDestroy()

end

function MapMarkerChocoboRacerView:OnShow()

end

function MapMarkerChocoboRacerView:OnHide()

end

function MapMarkerChocoboRacerView:OnRegisterUIEvent()

end

function MapMarkerChocoboRacerView:OnRegisterGameEvent()

end

function MapMarkerChocoboRacerView:OnRegisterBinder()
    local ViewModel = self.Params
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerChocoboRacerView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerChocoboRacerView:IsUnderLocation(ScreenPosition)
    return UIUtil.IsUnderLocation(self.ImgIcon, ScreenPosition)
end

function MapMarkerChocoboRacerView:OnScaleChanged(Scale)
    self.Scale = Scale

    self:UpdateMarkerView()
end

function MapMarkerChocoboRacerView:OnTimer()
    self:UpdateMarkerView()
end

function MapMarkerChocoboRacerView:UpdateMarkerView()
    local ViewModel = self.Params
    if nil == ViewModel then
        return
    end

    local MapMarker = ViewModel:GetMapMarker()
    if nil == MapMarker then
        return
    end

    local ParentView = self.ParentView
    if nil == ParentView then
        return
    end

    if MapContentType.MiniMap ~= ParentView.ContentType then
        -- 【大地图】
        UIUtil.SetIsVisible(self.PanelMarker, true)

        local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())
        ViewPosition.X = X
		ViewPosition.Y = Y
        UIUtil.CanvasSlotSetPosition(self, ViewPosition)
        return
    end

    -- 【小地图】
    local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())
    local MajorPos = MapVM:GetMajorPosition()

    local OffsetX = X - MAP_PANEL_HALF_WIDTH - MajorPos.X
    local OffsetY = Y - MAP_PANEL_HALF_WIDTH - MajorPos.Y

    if X == 0 and Y == 0 then
        UIUtil.SetIsVisible(self.PanelMarker, false)
    else
        UIUtil.SetIsVisible(self.PanelMarker, true)
    end

    if math.abs(OffsetX) > RADIUS or math.abs(OffsetY) > RADIUS then
        ViewModel:SetIsShowMarker(false)
    else
        ViewPosition.X = X
		ViewPosition.Y = Y
        UIUtil.CanvasSlotSetPosition(self, ViewPosition)
        ViewModel:SetIsShowMarker(true)
    end
end

return MapMarkerChocoboRacerView