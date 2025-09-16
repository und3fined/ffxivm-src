local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerChocoboStable = require("Game/Map/Marker/MapMarkerChocoboStable")

---@class MapMarkerProviderChocoboStable
local MapMarkerProviderChocoboStable = LuaClass(MapMarkerProvider)

function MapMarkerProviderChocoboStable:Ctor()
end

function MapMarkerProviderChocoboStable:OnGetMarkers(UIMapID)
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    local NpcCfgDict = _G.MapEditDataMgr:GetNpcCfgList()

    local Markers = {}
    for _, NpcCfg in pairs(NpcCfgDict) do
        if _G.NpcMgr:IsChocoboNpcByNpcID(NpcCfg.NpcID) then
            local Param =
            {
                NpcID = NpcCfg.NpcID,
                MapID = MapID,
                ListID = NpcCfg.ListId,
                BirthPoint = NpcCfg.BirthPoint,
            }

            local Marker = self:OnCreateMarker(Param)

            table.insert(Markers, Marker)
        end
    end

    return Markers
end

function MapMarkerProviderChocoboStable:OnCreateMarker(Params)
    local Point = Params.BirthPoint

    ---@type MapMarkerChocoboStable
    local Marker = self:CreateMarker(MapMarkerChocoboStable, Params.ID, Params)

    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)
    Marker:SetWorldPos(Point.X, Point.Y, Point.Z)

    return Marker
end

return MapMarkerProviderChocoboStable
