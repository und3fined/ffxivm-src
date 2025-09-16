local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerChocoboWharf = require("Game/Map/Marker/MapMarkerChocoboWharf")
local ProtoRes = require("Protocol/ProtoRes")

local TransitionType = ProtoRes.transition_type

---@class MapMarkerProviderChocoboWharf
local MapMarkerProviderChocoboWharf = LuaClass(MapMarkerProvider)

function MapMarkerProviderChocoboWharf:Ctor()
end

function MapMarkerProviderChocoboWharf:OnGetMarkers(UIMapID)
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    self.UIMapID = UIMapID

    local Markers = {}
    local DstMapList = _G.ChocoboTransportMgr.MapGapDict[MapID]
    if not DstMapList then
        return
    end
    for _, DstMapData in ipairs(DstMapList) do
        if DstMapData.TransType == TransitionType.TRANSITION_NPC then
            local Marker = self:OnCreateMarker(DstMapData)
            if Marker then
                table.insert(Markers, Marker)
            end
        end
    end

    return Markers
end

---@param DstMapData @c_trans_graph_cfg
function MapMarkerProviderChocoboWharf:OnCreateMarker(DstMapData)
    local NpcData = _G.MapEditDataMgr:GetNpc(DstMapData.ActorResID)
    if not NpcData then
        return
    end

    local Point = NpcData.BirthPoint

    ---@type MapMarkerChocoboWharf
    local Marker = self:CreateMarker(MapMarkerChocoboWharf, DstMapData.ActorResID, DstMapData)

    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)
    Marker:SetWorldPos(Point.X, Point.Y, Point.Z)

    return Marker
end

return MapMarkerProviderChocoboWharf
