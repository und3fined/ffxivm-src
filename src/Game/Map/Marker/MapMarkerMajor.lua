--
-- Author: anypkvcai
-- Date: 2023-01-05 19:30
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local MapUICfg = require("TableCfg/MapUICfg")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType

---@class MapMarkerMajor
local MapMarkerMajor = LuaClass(MapMarker)

---Ctor
function MapMarkerMajor:Ctor()

end

function MapMarkerMajor:GetType()
	return MapMarkerType.Major
end

function MapMarkerMajor:GetBPType()
	return MapMarkerBPType.Major
end

---@param AreaUIMapID 主角所在地图的三级地图UIMapID
function MapMarkerMajor:InitMarker(AreaUIMapID)
	local Cfg = MapUICfg:FindCfgByKey(AreaUIMapID)
	if nil == Cfg then
		return
	end

	-- 记录参数用于三级地图坐标转换
	self.MapScale = Cfg.Scale
	self.MapOffsetX = Cfg.OffsetX
	self.MapOffsetY = Cfg.OffsetY

	self.RoleID = MajorUtil.GetMajorRoleID()
end

function MapMarkerMajor:GetAreaMapPos()
	local Actor = ActorUtil.GetActorByRoleID(self.RoleID)
	if nil == Actor then
		return 0, 0
	end

	local Location = Actor:FGetActorLocation()

	return MapUtil.ConvertMapPos2UI(Location.X, Location.Y, self.MapOffsetX, self.MapOffsetY, self.MapScale, true)
end

return MapMarkerMajor