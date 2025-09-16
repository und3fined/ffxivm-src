local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local VisionDefine = require("Game/Actor/VisionDefine")
local VisionConfigs = require("Game/Actor/VisionConfigs")

---@class VisionMeshMgr : MgrBase
local VisionMeshMgr = LuaClass(MgrBase)

function VisionMeshMgr:OnInit()
	-- self:SetUpMeshCacheCount()
end

function VisionMeshMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.TeamIdentityChanged, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.FriendAdd, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.FriendRemoved, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.VisionAvatarDataSync, self.AvatarDataUpdate)
    self:RegisterGameEvent(EventID.VisionUpdateFirstAttacker, self.FirstAttackerUpdate)
end

function VisionMeshMgr:OnGameEventRoleIdentityChanged(RoleIDs)
    for _, RoleID in pairs(RoleIDs) do
        local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID) or 0
        if EntityID > 0 then
            _G.UE.UVisionMgr.Get():UpdateVisionInfo(EntityID)
        end
    end
end

function VisionMeshMgr:AvatarDataUpdate(Params)
    local EntityID = Params.ULongParam1
    _G.UE.UVisionMgr.Get():UpdateVisionInfo(EntityID)
end

function VisionMeshMgr:FirstAttackerUpdate(Params)
	local EntityID = Params.ULongParam1
    _G.UE.UVisionMgr.Get():UpdateVisionInfo(EntityID)
end

function VisionMeshMgr:ChangeMaxCacheCount(Channel, Count)
	local MeshLimiterChannel = VisionDefine.MeshLimiterChannel
	local Channel2CacheCount =
	{
		[MeshLimiterChannel.Player] = "VisionPlayerMaxCacheCount",
		[MeshLimiterChannel.NPC] = "VisionNPCMaxCacheCount",
		[MeshLimiterChannel.Monster] = "VisionMonsterMaxCacheCount",
		[MeshLimiterChannel.Companion] = "VisionCompanionMaxCacheCount",
	}
	_G.UE.UConfigMgr.Get()[Channel2CacheCount[Channel]] = Count
end

function VisionMeshMgr:SetUpMeshCacheCount()
	local QualityLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
	local Configs = VisionConfigs.MeshCacheMap[QualityLevel]
	if nil == Configs then
		return
	end
	for Channel, Count in pairs(Configs) do
		self:ChangeMaxCacheCount(Channel, Count)
	end
end

return VisionMeshMgr