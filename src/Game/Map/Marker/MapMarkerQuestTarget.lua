--
-- Author: anypkvcai
-- Date: 2023-03-29 16:57
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local MapFollowTargetType = MapDefine.MapFollowTargetType
local MapFollowTargetConfigs = MapDefine.MapFollowTargetConfigs


---@class MapMarkerQuestTarget : MapMarker
local MapMarkerQuestTarget = LuaClass(MapMarker)

function MapMarkerQuestTarget:Ctor()
	self.ArrowPath = "" -- 方向箭头资源路径
	self.TargetID = nil -- 任务TargetID
end

function MapMarkerQuestTarget:GetType()
	return MapMarkerType.QuestTarget
end

function MapMarkerQuestTarget:GetBPType()
	return MapMarkerBPType.QuestTarget
end

function MapMarkerQuestTarget:IsNameVisible(Scale)
	return false
end

function MapMarkerQuestTarget:IsIconVisible(Scale)
	return true
end

function MapMarkerQuestTarget:GetTipsName()
	return self:GetName()
end

function MapMarkerQuestTarget:GetArrowPath()
	return self.ArrowPath
end

function MapMarkerQuestTarget:GetTargetID()
	return self.TargetID
end

function MapMarkerQuestTarget:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerQuestTarget:UpdateMarker(Params)
	self.TargetID = Params.TargetID
	self.Name = tostring(Params.QuestID)

	local FollowTargetConfig = MapFollowTargetConfigs[MapFollowTargetType.QuestTarget]
	if FollowTargetConfig then
		self.ArrowPath = FollowTargetConfig.Arrow
	end
end

return MapMarkerQuestTarget