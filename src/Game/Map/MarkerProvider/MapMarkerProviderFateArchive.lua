local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapUtil = require("Game/Map/MapUtil")
local MapMarkerFate = require("Game/Map/Marker/MapMarkerFate")
local ProtoRes = require("Protocol/ProtoRes")
local MapDefine = require("Game/Map/MapDefine")
local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
local MapMarkerEventType = ProtoRes.MapMarkerEventType

local PWorldMgr = _G.PWorldMgr
local LSTR = _G.LSTR

---@class MapMarkerProviderFateArchive
local MapMarkerProviderFateArchive = LuaClass(MapMarkerProvider)

---Ctor
function MapMarkerProviderFateArchive:Ctor()
end

function MapMarkerProviderFateArchive:OnGetMarkers(UIMapID)
    local Markers = {}
    local CurrActiveFate = FateArchiveMainVM:GetCurrentFate()
    local ActiveFate = _G.FateMgr:GetActiveFate(CurrActiveFate.ID)
    if (ActiveFate ~= nil) then
        CurrActiveFate.StartTime = ActiveFate.StartTime
        CurrActiveFate.Progress = ActiveFate.Progress
        CurrActiveFate.State = ActiveFate.State
        CurrActiveFate.ItemTime = ActiveFate.ItemTime
    end
    local Marker = self:CreateMarker(MapMarkerFate, CurrActiveFate.ID, CurrActiveFate)
    table.insert(Markers, Marker)
	if (ActiveFate ~= nil) then
		Marker:UpdateMarker(ActiveFate)
	end
    return Markers
end

---OnCreateMarker
---@param Params table @Fate 注意，这里不会实时新建 MapMarker ，因为图鉴中，有且只会有一个目标 Fate 显示
function MapMarkerProviderFateArchive:OnCreateMarker(Params)
    return nil
end

function MapMarkerProviderFateArchive:GetMarkerType()
    return MapDefine.MapMarkerType.Fate
end


return MapMarkerProviderFateArchive