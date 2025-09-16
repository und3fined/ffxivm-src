--
-- Author: peterxie
-- Date:
-- Description: PVP地图玩家标记
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerPVPPlayer = require("Game/Map/Marker/MapMarkerPVPPlayer")
local MapDefine = require("Game/Map/MapDefine")


---@class MapMarkerProviderPVPPlayer : MapMarkerProvider
local MapMarkerProviderPVPPlayer = LuaClass(MapMarkerProvider)

function MapMarkerProviderPVPPlayer:Ctor()

end

function MapMarkerProviderPVPPlayer:GetMarkerType()
	return MapDefine.MapMarkerType.PVPPlayer
end

function MapMarkerProviderPVPPlayer:OnGetMarkers(UIMapID)
	return self:CreatePlayerMarkers()
end

function MapMarkerProviderPVPPlayer:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerPVPPlayer, Params.ID, Params)
	if nil == Marker then
		return
	end

	return Marker
end

function MapMarkerProviderPVPPlayer:CreatePlayerMarkers()
	local MapMarkers = {}

	-- 我方队伍成员标记
	local PlayerMemberVMList = _G.PVPTeamMgr:GetPVPTeamVM():GetTeamMemberList()
	for i = 1, PlayerMemberVMList:Length() do
		local MemberVM = PlayerMemberVMList:Get(i)
		if MemberVM then
			local Params = { ID = MemberVM.RoleID, RoleID = MemberVM.RoleID, MemberVM = MemberVM, }
			local Marker = self:OnCreateMarker(Params)
			table.insert(MapMarkers, Marker)
		end
	end

	-- 敌方队伍成员标记
	local EnemyMemberVMList = _G.PVPTeamMgr:GetPVPTeamVM():GetEnemyMemberList()
	for i = 1, EnemyMemberVMList:Length() do
		local MemberVM = EnemyMemberVMList:Get(i)
		if MemberVM then
			local Params = { ID = MemberVM.RoleID, RoleID = MemberVM.RoleID, MemberVM = MemberVM, }
			local Marker = self:OnCreateMarker(Params)
			table.insert(MapMarkers, Marker)
		end
	end

	return MapMarkers
end


return MapMarkerProviderPVPPlayer