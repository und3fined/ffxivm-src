--
-- Author: peterxie
-- Date:
-- Description: PVP地图通用标记
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local ProtoRes = require("Protocol/ProtoRes")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerPVPCommon : MapMarker
local MapMarkerPVPCommon = LuaClass(MapMarker)

function MapMarkerPVPCommon:Ctor()
	self.GameplayID = 0 -- 标记所属玩法ID

	self.TeamIndex = 0 -- 队伍索引，决定所属红蓝方
    self.LayoutType = 0 -- 地图标记SG类型
end

function MapMarkerPVPCommon:GetType()
	return MapMarkerType.PVPCommon
end

function MapMarkerPVPCommon:GetBPType()
	return MapMarkerBPType.PVPCommon
end

function MapMarkerPVPCommon:InitMarker(Params)
	self.GameplayID = Params.GameplayID
	self.TeamIndex = Params.TeamIndex
	self.LayoutType = Params.LayoutType

    self:UpdateMarker(Params)
end

function MapMarkerPVPCommon:UpdateMarker(Params)
	if self.GameplayID == ProtoRes.Game.GameID.GameIDPvpcolosseumCrystal then
		local IconID = _G.PVPColosseumMgr:GetSGMapMarkerIconID(self.TeamIndex, self.LayoutType)
		self.IconPath = MapUtil.GetIconPath(IconID)
	end
end


return MapMarkerPVPCommon