--
-- Author: anypkvcai
-- Date: 2023-06-19 17:09
-- Description:
--


local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local GatherPointCfg = require("TableCfg/GatherPointCfg")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerGather : MapMarker
local MapMarkerGather = LuaClass(MapMarker)

function MapMarkerGather:Ctor()
	self.bTracking = false -- 小地图采集点是否追踪，追踪后有发光动效
end

function MapMarkerGather:GetType()
	return MapMarkerType.Gather
end

function MapMarkerGather:GetBPType()
	return MapMarkerBPType.Gather
end

function MapMarkerGather:InitMarker(Params)
	self.ResID = Params.ResID

	local Cfg = GatherPointCfg:FindCfgByKey(Params.ResID)
	if nil ~= Cfg then
		self.IconPath = Cfg.MapIcon
	end
end

function MapMarkerGather:GetIsSelected()
	return false
end

function MapMarkerGather:GetIsTracking()
	return self.bTracking
end

function MapMarkerGather:SetIsTracking(bTracking)
	self.bTracking = bTracking
end


return MapMarkerGather