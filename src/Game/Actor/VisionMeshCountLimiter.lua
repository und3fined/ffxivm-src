local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")

local VisionMeshCountLimiter = {}

function VisionMeshCountLimiter.GetVisionPriority(EntityID)
    return 0
    -- local Actor = ActorUtil.GetActorByEntityID(EntityID)
    -- local Attr = ActorUtil.GetActorAttributeComponent(EntityID)
    -- local Major = MajorUtil.GetMajor()

    -- if Actor == nil or Attr == nil then
    --     return 0
    -- end

    -- local ActorType = Actor:GetActorType()
    -- local CharacterEntityID = EntityID
    -- if ActorType == _G.UE.EActorType.Player then
    --     return VisionMeshCountLimiter.CharacterPriority(EntityID)
    -- elseif ActorType == _G.UE.EActorType.Monster then
    --     if Attr.FirstAttackerEntityID == MajorUtil.GetMajorEntityID() then
    --         return 1000
    --     else
    --         return 0
    --     end
    -- elseif ActorType == _G.UE.EActorType.Npc then

    -- elseif ActorType == _G.UE.EActorType.Companion then
    --     return VisionMeshCountLimiter.CharacterPriority(Attr.Owner)
    -- end
    -- return 0
end

function VisionMeshCountLimiter.CharacterPriority(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    local Attr = ActorUtil.GetActorAttributeComponent(EntityID)
    if Actor == nil or Attr == nil then return 0 end

    if _G.TeamMgr:IsTeamMemberByEntityID(EntityID) then
        return 1000
    end
    if _G.FriendMgr:IsFriend(Attr.RoleID) then
        return 900
    end
    if _G.ArmyMgr:GetIsArmyMemberByRoleID(Attr.RoleID) then
        return 800
    end
end

function VisionMeshCountLimiter.IsActorAlwaysVisible(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    local Attr = ActorUtil.GetActorAttributeComponent(EntityID)
    local Major = MajorUtil.GetMajor()

    if Actor == nil or Attr == nil then
        return false
    end

    if Attr.MonsterSubType == ProtoRes.monster_sub_type.MONSTER_SUB_TYPE_BOSS then
        return true
    end

    return false
end

return VisionMeshCountLimiter