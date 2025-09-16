local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerGoldActiviry : MapMarker
local MapMarkerGoldActiviry = LuaClass(MapMarker)

---Ctor
function MapMarkerGoldActiviry:Ctor()
	self.StartTimeMS = nil
	self.Progress = nil
	self.Radius = 0
end

function MapMarkerGoldActiviry:GetType()
	return MapMarkerType.GoldActivity
end

function MapMarkerGoldActiviry:GetBPType()
	return MapMarkerBPType.CommGameplay
end

function MapMarkerGoldActiviry:GetTipsName()
	return self.Name
end

function MapMarkerGoldActiviry:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerGoldActiviry:UpdateMarker(Params)
	self.ID = Params.ID
    self.IconPath = Params.IconPath
    self.AreaUIPosX = Params.PosX
	self.AreaUIPosY = Params.PosY
end


return MapMarkerGoldActiviry