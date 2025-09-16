--
-- Author: sammrli
-- Date: 2025-03-25 16:57
-- Description: 任务追踪辅助标记
--

local LuaClass = require("Core/LuaClass")

local MapUtil = require("Game/Map/MapUtil")

local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType

---@class MapMarkerTracking : MapMarker
local MapMarkerTracking = LuaClass(MapMarker)

function MapMarkerTracking:Ctor()
	self.TargetID = 0 -- 任务TargetID
end

function MapMarkerTracking:GetType()
	return MapMarkerType.Tracking
end

function MapMarkerTracking:GetBPType()
	return MapMarkerBPType.Quest
end

function MapMarkerTracking:IsNameVisible(Scale)
	return false
end

function MapMarkerTracking:IsIconVisible(Scale)
	return true
end

function MapMarkerTracking:GetTipsName()
	return self:GetName()
end

function MapMarkerTracking:GetTargetID()
	return self.TargetID
end

function MapMarkerTracking:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerTracking:UpdateMarker(Params)
	self.TargetID = Params.TargetID
	self.Pos = Params.Pos

	self.Name = _G.QuestMgr:GetQuestName(Params.QuestID)
	self:UpdateFollow()
end

function MapMarkerTracking:OnTriggerMapEvent(EventParams)
	MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
end

function MapMarkerTracking:GetAlpha()
	if _G.FogMgr:IsAllActivate(self.MapID) then
		return 1
	end
	local InDiscovery = _G.MapAreaMgr:GetDiscoveryIDByLocation(self.Pos.X, self.Pos.Y, self.Pos.Z, self.MapID)
	if InDiscovery and InDiscovery > 0 then
		if not _G.FogMgr:IsInFlag(self.MapID, InDiscovery) then
			return 0.5
		end
	end
	return 1
end

return MapMarkerTracking