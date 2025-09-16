local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerPlayStyle = require("Game/Map/Marker/MapMarkerPlayStyle")
local MapDefine = require("Game/Map/MapDefine")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")

---@class MapMarkerProviderPlayStyle
local MapMarkerProviderPlayStyle = LuaClass(MapMarkerProvider)

---Ctor
function MapMarkerProviderPlayStyle:Ctor()
    self.ID = TimeUtil.GetServerTimeMS()
end

function MapMarkerProviderPlayStyle:OnGetMarkers(UIMapID, MapID)
    if _G.GoldSauserMgr.Entertain == nil then
        return nil
    end

    local NpcMarker =  self:OnCreateMarker(_G.GoldSauserMgr.MarkerForSignupNpc)
    if (NpcMarker == nil) then
        return nil
    end

    local Markers = {}
    Markers[1] = NpcMarker

    -- 小雏鸟
    local ChickenMarker =  self:OnCreateMarker(_G.GoldSauserMgr.MarkerForChecken)
    if (ChickenMarker ~= nil) then
        Markers[2] = ChickenMarker
    end

    return Markers
end

function MapMarkerProviderPlayStyle:OnCreateMarker(Params)
    if self.UIMapID ~= _G.MapMgr:GetUIMapID() then
        return
    end

    if (_G.GoldSauserMgr.Entertain == nil) then
        return nil
    end

    if (Params == nil or Params.bShow == false) then
        return nil
    end

    local Marker = self:CreateMarker(MapMarkerPlayStyle, Params.ID, Params)

    return Marker
end

function MapMarkerProviderPlayStyle:GetMarkerType()
    return MapDefine.MapMarkerType.PlayStyle
end

return MapMarkerProviderPlayStyle
