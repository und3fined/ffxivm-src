local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerChocoboTransferLine = require("Game/Map/Marker/MapMarkerChocoboTransferLine")
local ProtoRes = require("Protocol/ProtoRes")

local TransitionType = ProtoRes.transition_type

---@class MapMarkerProviderChocoboTransferLine
local MapMarkerProviderChocoboTransferLine = LuaClass(MapMarkerProvider)

function MapMarkerProviderChocoboTransferLine:Ctor()
end

function MapMarkerProviderChocoboTransferLine:OnGetMarkers(UIMapID)
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    self.UIMapID = UIMapID

    local Markers = {}
    local DstMapList = _G.ChocoboTransportMgr.MapGapDict[MapID]
    if not DstMapList then
        return
    end
    for _, DstMapData in ipairs(DstMapList) do
        if DstMapData.TransType == TransitionType.TRANSITION_EDGE then
            local Marker = self:OnCreateMarker(DstMapData)
            if Marker then
                table.insert(Markers, Marker)
            end
        end
    end

    return Markers
end

---@param DstMapData @c_trans_graph_cfg
function MapMarkerProviderChocoboTransferLine:OnCreateMarker(DstMapData)
    local Point = DstMapData.Position

    ---@type MapMarkerChocoboTransferLine
    local Marker = self:CreateMarker(MapMarkerChocoboTransferLine, DstMapData.ID, DstMapData)

    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)
    Marker:SetWorldPos(Point.X, Point.Y, Point.Z)

    return Marker
end

return MapMarkerProviderChocoboTransferLine
