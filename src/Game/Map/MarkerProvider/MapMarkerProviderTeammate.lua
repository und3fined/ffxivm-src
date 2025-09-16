--
-- Author: anypkvcai
-- Date: 2023-12-11 16:03
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerTeammate = require("Game/Map/Marker/MapMarkerTeammate")
local MapDefine = require("Game/Map/MapDefine")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local TeamHelper = require("Game/Team/TeamHelper")

local MapMarkerType = MapDefine.MapMarkerType
local MapContentType = MapDefine.MapContentType


---@class MapMarkerProviderTeammate : MapMarkerProvider
local MapMarkerProviderTeammate = LuaClass(MapMarkerProvider)

function MapMarkerProviderTeammate:Ctor()

end

function MapMarkerProviderTeammate:GetMarkerType()
	return MapMarkerType.Teammate
end

function MapMarkerProviderTeammate:OnGetMarkers(UIMapID)
	return self:CreateTeammateMarkers()
end

function MapMarkerProviderTeammate:CreateTeammateMarkers()
	local MapMarkers = {}

	if _G.PWorldMgr:CurrIsInSingleDungeon() then
		return MapMarkers
	end

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	for _, RoleID, EntityID in TeamHelper.GetTeamMgr():IterTeamMembers() do
		if RoleID ~= MajorRoleID then
			if self:GetContentType() == MapContentType.MiniMap then
				if EntityID and EntityID > 0 then
					local Params = { ID = EntityID, RoleID = RoleID, EntityID = EntityID }
					local Marker = self:OnCreateMarker(Params)
					table.insert(MapMarkers, Marker)
				end
			else
				if RoleID and RoleID > 0 then
					-- 大地图显示玩家队友
					local Params = { ID = RoleID, RoleID = RoleID }
					local Marker = self:OnCreateMarker(Params)
					table.insert(MapMarkers, Marker)
				elseif EntityID and EntityID > 0 then
					-- 大地图显示剧情AI队友，AI没有RoleID，和小地图一样用视野内EntityID
					local Params = { ID = EntityID, RoleID = nil, EntityID = EntityID }
					local Marker = self:OnCreateMarker(Params)
					table.insert(MapMarkers, Marker)
				end
			end
		end
	end

	return MapMarkers
end

function MapMarkerProviderTeammate:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerTeammate, Params.ID, Params)
	if nil == Marker then
		return
	end

	return Marker
end

function MapMarkerProviderTeammate:OnVisionEnter(EntityID, RoleID)
	if self:GetContentType() == MapContentType.MiniMap then
		local Params = { ID = EntityID, EntityID = EntityID, RoleID = RoleID }
		self:AddMarker(Params)
	end
end

function MapMarkerProviderTeammate:OnVisionLeave(EntityID)
	if self:GetContentType() == MapContentType.MiniMap then
		self:RemoveMarker(EntityID)
	end
end


return MapMarkerProviderTeammate