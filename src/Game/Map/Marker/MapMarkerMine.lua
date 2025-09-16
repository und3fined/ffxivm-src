local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerMine
local MapMarkerMine = LuaClass(MapMarker)

---Ctor
function MapMarkerMine:Ctor()

end

function MapMarkerMine:GetType()
	return MapMarkerType.TreasureMine
end

function MapMarkerMine:GetBPType()
	return MapMarkerBPType.TreasureMine
end

function MapMarkerMine:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerMine:UpdateMarker(Params)
	self.PosID = Params.PosID
	self.StartTime = Params.StartTime
end

function MapMarkerMine:GetPosID()
	return self.PosID
end

function MapMarkerMine:GetStartTime()
	return self.StartTime
end

function MapMarkerMine:OnTriggerMapEvent(EventParams)

end

return MapMarkerMine