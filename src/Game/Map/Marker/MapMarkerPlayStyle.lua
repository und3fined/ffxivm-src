local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerPlayStyle : MapMarker
local MapMarkerPlayStyle = LuaClass(MapMarker)

---Ctor
function MapMarkerPlayStyle:Ctor()
    self.StartTimeMS = nil
    self.Progress = nil
    self.Radius = 0
end

function MapMarkerPlayStyle:GetType()
    return MapMarkerType.PlayStyle
end

function MapMarkerPlayStyle:GetBPType()
    return MapMarkerBPType.CommGameplay
end

function MapMarkerPlayStyle:GetTipsName()
    return self.Name
end

function MapMarkerPlayStyle:OnTriggerMapEvent(EventParams)
    local Params = {
        MapMarker = self,
        ScreenPosition = EventParams.ScreenPosition,
        ID = self.ID,
        EntertainID = self.EntertainID
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.WorldMapMarkerPlayStyleStageInfo, Params)
end

function MapMarkerPlayStyle:InitMarker(Params)
    self:UpdateMarker(Params)
end

function MapMarkerPlayStyle:UpdateMarker(Params)
    self.ID = Params.ID -- 1 表示报名NPC， 2表示小雏鸟游戏中的小雏鸟
    self.EntertainID = Params.EntertainID
    self.IconPath = Params.IconPath
    local Point = Params.BirthPoint
    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
    self:SetAreaMapPos(X, Y)
    self.Name = _G.GoldSauserMgr:GetCurGameName()
end

return MapMarkerPlayStyle
