--
-- Author: anypkvcai
-- Date: 2022-12-26 23:59
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local ProtoRes = require("Protocol/ProtoRes")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")

local MapMarkerType = MapDefine.MapMarkerType
local MapConstant = MapDefine.MapConstant
local MapMarkerBPType = MapDefine.MapMarkerBPType
local MapPlacedMarkerType = ProtoRes.MapPlacedMarkerType


---@class MapMarkerPlaced
local MapMarkerPlaced = LuaClass(MapMarker)

function MapMarkerPlaced:Ctor()
	self.PlacedMarkerCfg = nil
end

function MapMarkerPlaced:InitMarker(PlacedMarkerCfg, Name, PosX, PosY)
	self.PlacedMarkerCfg = PlacedMarkerCfg
	self.Name = Name
	self.IconPath = PlacedMarkerCfg.IconPath
	self.AreaUIPosX = PosX
	self.AreaUIPosY = PosY
	self:UpdateMarker(PlacedMarkerCfg, Name)
end

function MapMarkerPlaced:UpdateMarker(PlacedMarkerCfg, Name)
	if nil ~= PlacedMarkerCfg then
		self.PlacedMarkerCfg = PlacedMarkerCfg
		self.IconPath = PlacedMarkerCfg.IconPath
	end

	if nil ~= Name then
		self.Name = Name
	end

	self:UpdateFollow()
end

function MapMarkerPlaced:GetPlacedMarkerCfg()
	return self.PlacedMarkerCfg
end

function MapMarkerPlaced:GetName()
	return self:IsTraceMarker() and MapConstant.MAP_DEFAULT_MARKER_NAME or self.Name
end

function MapMarkerPlaced:GetCfgID()
	return self.PlacedMarkerCfg.ID
end

function MapMarkerPlaced:GetType()
	return MapMarkerType.Placed
end

function MapMarkerPlaced:GetBPType()
	return MapMarkerBPType.Placed
end

function MapMarkerPlaced:OnTriggerMapEvent(EventParams)
	local Params = { Marker = self }
	WorldMapVM:ShowWorldMapPlaceMarkerPanel(Params)
end

function MapMarkerPlaced:IsNameVisible(Scale)
	return false
end

function MapMarkerPlaced:GetTipsName()
	return self:GetName()
end

function MapMarkerPlaced:IsTraceMarker()
	return MapPlacedMarkerType.MAP_PLACED_MARKER_TRACE == self.PlacedMarkerCfg.Type
end

function MapMarkerPlaced:IsIconMarker()
	return MapPlacedMarkerType.MAP_PLACED_MARKER_ICON == self.PlacedMarkerCfg.Type
end

function MapMarkerPlaced:GetMarkerIndex()
	return self.PlacedMarkerCfg.MarkerIndex
end


return MapMarkerPlaced