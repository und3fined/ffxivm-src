--
-- Author: peterxie
-- Date:
-- Description: PVP地图玩家标记
--

local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")

local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType
local MapMarkerPriority = MapDefine.MapMarkerPriority


---@class MapMarkerPVPPlayer : MapMarker
---@field MemberVM TeamMemberVM
local MapMarkerPVPPlayer = LuaClass(MapMarker)

function MapMarkerPVPPlayer:Ctor()
	self.RoleID = nil -- 玩家RoleID
	self.MemberVM = nil -- 玩家队伍成员VM
	self.IsMajor = false -- 是否是主角
end

function MapMarkerPVPPlayer:GetType()
	return MapMarkerType.PVPPlayer
end

function MapMarkerPVPPlayer:GetBPType()
	return MapMarkerBPType.PVPPlayer
end

function MapMarkerPVPPlayer:InitMarker(Params)
	self.RoleID = Params.RoleID
	self.MemberVM = Params.MemberVM

	self.IsMajor = MajorUtil.GetMajorRoleID() == self.RoleID

	-- 队伍成员所属红蓝方
	local bIsMyTeam = _G.PVPColosseumMgr:IsMyTeamByCampID(self.MemberVM.CampID)
	if bIsMyTeam then
		self.IconPath = MapDefine.MapIconConfigs.PVPPlayerBlueBg
	else
		self.IconPath = MapDefine.MapIconConfigs.PVPPlayerRedBg
	end
end

function MapMarkerPVPPlayer:GetPriority()
	local MarkerPriority = MapMarkerPriority.Player
	if self.IsMajor then
		MarkerPriority = MapMarkerPriority.Major
	end
	return MarkerPriority
end

---获取玩家的UI坐标
function MapMarkerPVPPlayer:GetAreaMapPos()
	if self.RoleID then
		return MapUtil.GetActorUIPosByRoleID(self.UIMapID, self.RoleID, true)
	end
end


return MapMarkerPVPPlayer