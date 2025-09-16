local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local MapFollowTargetConfigs = MapDefine.MapFollowTargetConfigs


---@class MapMarkerFollowTarget : MapMarker
local MapMarkerFollowTarget = LuaClass(MapMarker)

function MapMarkerFollowTarget:Ctor()
	self.FollowTargetType = 0 -- 追踪目标类型
	self.ArrowPath = "" -- 方向箭头资源路径
end

function MapMarkerFollowTarget:GetType()
	return MapMarkerType.FollowTarget
end

function MapMarkerFollowTarget:GetBPType()
	return MapMarkerBPType.QuestTarget
end

function MapMarkerFollowTarget:IsNameVisible(Scale)
	return false
end

function MapMarkerFollowTarget:IsIconVisible(Scale)
	return true
end

function MapMarkerFollowTarget:GetTipsName()
	return self:GetName()
end

function MapMarkerFollowTarget:GetSubType()
	return self.FollowTargetType
end

function MapMarkerFollowTarget:GetArrowPath()
	return self.ArrowPath
end

function MapMarkerFollowTarget:InitMarker(Params)
	self:UpdateMarker(Params)
end

function MapMarkerFollowTarget:UpdateMarker(Params)
	self.FollowTargetType = Params.FollowTargetType

	local FollowTargetConfig = MapFollowTargetConfigs[Params.FollowTargetType]
	if FollowTargetConfig then
		self.ArrowPath = FollowTargetConfig.Arrow
	end
end

return MapMarkerFollowTarget