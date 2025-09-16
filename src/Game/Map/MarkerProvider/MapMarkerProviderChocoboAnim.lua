local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerChocoboAnim = require("Game/Map/Marker/MapMarkerChocoboAnim")

---@class MapMarkerProviderChocoboAnim
local MapMarkerProviderChocoboAnim = LuaClass(MapMarkerProvider)

function MapMarkerProviderChocoboAnim:Ctor()
end

function MapMarkerProviderChocoboAnim:OnGetMarkers(UIMapID)
    if UIMapID ~= _G.MapMgr:GetUIMapID() then
		return
	end

    local Markers = {}

    local Marker = self:OnCreateMarker()
    table.insert(Markers, Marker)

    return Markers
end

function MapMarkerProviderChocoboAnim:OnCreateMarker()
    local Marker = self:CreateMarker(MapMarkerChocoboAnim)
    return Marker
end

return MapMarkerProviderChocoboAnim
