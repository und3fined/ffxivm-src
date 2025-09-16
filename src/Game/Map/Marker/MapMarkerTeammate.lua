--
-- Author: anypkvcai
-- Date: 2022-12-20 16:26
-- Description: 队友
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local ActorUtil = require("Utils/ActorUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType


---@class MapMarkerTeammate
local MapMarkerTeammate = LuaClass(MapMarker)

function MapMarkerTeammate:Ctor()
	self.EntityID = nil
	self.RoleID = nil
end

function MapMarkerTeammate:GetType()
	return MapMarkerType.Teammate
end

function MapMarkerTeammate:GetBPType()
	return MapMarkerBPType.Teammate
end

function MapMarkerTeammate:InitMarker(Params)
	self.RoleID = Params.RoleID
	-- 小地图只显示视野内的队友，用EntityID区分，大地图EntityID为nil
	self.EntityID = Params.EntityID

	self.IconPath = MapDefine.MapIconConfigs.Teammate
end

function MapMarkerTeammate:GetAreaMapPos()
	if self.EntityID then
		return MapUtil.GetActorUIPosByEntityID(self.UIMapID, self.EntityID)
	else
		return MapUtil.GetActorUIPosByRoleID(self.UIMapID, self.RoleID)
	end
end

function MapMarkerTeammate:GetWorldPos()
	if self.EntityID then
		-- 获取小地图视野内的队友的场景坐标
		local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
		if Actor then
			local Location = Actor:FGetActorLocation()
			return Location.X, Location.Y, Location.Z, Location
		end
	end

	return 0, 0, 0, nil
end

function MapMarkerTeammate:OnTriggerMapEvent(EventParams)
	local Name = self:GetTipsName()
	if nil ~= Name and string.len(Name) > 0 then
		local Params = { Name = Name, ScreenPosition = EventParams.ScreenPosition }
		UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsTarget, Params)
	end
end

function MapMarkerTeammate:GetTipsName()
	if self.EntityID then
		 return ActorUtil.GetActorName(self.EntityID)
	else
		local RoleVM = _G.RoleInfoMgr:FindRoleVM(self.RoleID)
		if nil == RoleVM then
			return ""
		end
		return RoleVM.Name
	end
end


return MapMarkerTeammate