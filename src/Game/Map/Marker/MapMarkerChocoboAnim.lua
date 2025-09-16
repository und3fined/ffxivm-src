local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType

---@class MapMarkerChocoboAnim
local MapMarkerChocoboAnim = LuaClass(MapMarker)

---Ctor
function MapMarkerChocoboAnim:Ctor()
	self.ID = nil
	self.Radius = 0
end

function MapMarkerChocoboAnim:GetType()
	return MapMarkerType.ChocoboAnim
end

function MapMarkerChocoboAnim:GetBPType()
	return MapMarkerBPType.ChocoboAnim
end

function MapMarkerChocoboAnim:GetTipsName()
	return self.Name
end

function MapMarkerChocoboAnim:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerChocoboAnim:UpdateMarker(Params)
end

function MapMarkerChocoboAnim:IsIconVisible(Scale)
	return _G.ChocoboTransportMgr:GetIsTransporting()
end

return MapMarkerChocoboAnim