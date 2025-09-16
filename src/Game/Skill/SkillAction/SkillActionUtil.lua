--
-- Author: henghaoli
-- Date: 2024-04-16 17:01:00
-- Description: SkillAction相关的实用函数
--

local GameNetworkMgr = require("Network/GameNetworkMgr")
local SkillUtil = require("Utils/SkillUtil")
local ActorUtil = require("Utils/ActorUtil")
local EffectUtil = require("Utils/EffectUtil")
local ProtoCS = require ("Protocol/ProtoCS")
local MonsterCfg = require("TableCfg/MonsterCfg")
local NPCBaseCfg = require("TableCfg/NpcbaseCfg")
local ProtoRes = require("Protocol/ProtoRes")

local UE = _G.UE
local FVector = UE.FVector
local FRotator = UE.FRotator
local FTransform = UE.FTransform
local FQuat = UE.FQuat
local FLinearColor = UE.FLinearColor
local USkillUtil = UE.USkillUtil

local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO



---@class SkillActionUtil
local SkillActionUtil = {}

function SkillActionUtil.SendQuitAction(EntityID, SkillID)
    local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
	local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_QUIT_ACTION
    local MsgBody = {
        Cmd = SubMsgID,
        QuitAction = {
            ObjID = EntityID,
            SkillID = SkillID,
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function SkillActionUtil.SendAttack(ObjID, SkillID, TargetList, FDir, SelectPos, DirPos, SeriesID, SeriesIdx, StorageID, StorageIdx)
    SeriesID = SeriesID or 0
    SeriesIdx = SeriesIdx or 0
    StorageID = StorageID or 0
    StorageIdx = StorageIdx or 0

    local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
	local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_ATTACK
    local MsgBody = {
        Cmd = SubMsgID,
        Attack = {
            select = {
                DirPos = SkillUtil.ConvertVector2CSPosition(DirPos),
                SelectPos = SkillUtil.ConvertVector2CSPosition(SelectPos),
                ObjID = ObjID,
                SkillID = SkillID,
                SelfDir = FDir,
                SeriesID = SeriesID,
                SeriesIdx = SeriesIdx,
                StorageID = StorageID,
                StorageIdx = StorageIdx,
                TargetList = TargetList,
            }
        }
    }

    -- 这里如果报错, 很可能是角色位置为NaN
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function SkillActionUtil.GetLODLevel(EntityID)
    local LODLevel = 0
    local bHighPriority = false
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if USkillUtil.IsSimulateMajor(Actor) then
        LODLevel = EffectUtil.GetMajorEffectLOD()
        bHighPriority = true
    elseif ActorUtil.IsPlayer(EntityID) then
        LODLevel = EffectUtil.GetPlayerEffectLOD()
    elseif ActorUtil.IsMonster(EntityID) then
        LODLevel = EffectUtil.GetBOSSEffectLOD()
        bHighPriority = SkillActionUtil.GetMonsterIsHighPriority(EntityID)
    end
    return LODLevel, bHighPriority
end

function SkillActionUtil.GetMonsterIsHighPriority(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if nil == Actor then
        return false
    end

    local AttributeComponent = Actor:GetAttributeComponent()
    if nil == AttributeComponent then
        return false
    end

    local ResID = AttributeComponent.ResID
    local Cfg = MonsterCfg:FindCfgByKey(ResID)
    if Cfg == nil then
        return false
    end

    local ProfileName = tonumber(Cfg.ProfileName)
    if ProfileName == nil then
        return false
    end

    local RankType = NPCBaseCfg:FindValue(ProfileName, "Rank")
    if RankType ~= nil then
        return RankType >= ProtoRes.NPC_RANK_TYPE.Boss and RankType <= ProtoRes.NPC_RANK_TYPE.Elite2
    end
    return false
end


function SkillActionUtil.ConvertClientVector(InVector)
    local Origin = _G.PWorldMgr:GetWorldOriginLocation()
    return Origin + InVector
end

function SkillActionUtil.RandomRotationOnAxis(Range)
    if Range > 0 then
        return math.random(-Range, Range)
    end
    return 0
end

function SkillActionUtil.CSPosition2FVector(InVector)
    return FVector(InVector.x, InVector.y, InVector.z)
end

function SkillActionUtil.ConvertServerVector(InVector)
    local Origin = _G.PWorldMgr:GetWorldOriginLocation()
    local Vector = SkillActionUtil.CSPosition2FVector(InVector)
    return Vector - Origin
end

function SkillActionUtil.ProtoVector2FVector(InVector)
    return FVector(InVector.X, InVector.Y, InVector.Z)
end

function SkillActionUtil.ProtoRotator2FRotator(InRotator)
    return FRotator(InRotator.Pitch, InRotator.Yaw, InRotator.Roll)
end

function SkillActionUtil.ProtoQuat2FQuat(InQuat)
    return FQuat(InQuat.X, InQuat.Y, InQuat.Z, InQuat.W)
end

function SkillActionUtil.ProtoTransform2FTransform(InTransform)
    local Translation = SkillActionUtil.ProtoVector2FVector(InTransform.Translation)
    local Scale3D = SkillActionUtil.ProtoVector2FVector(InTransform.Scale3D)
    local Rotation = SkillActionUtil.ProtoQuat2FQuat(InTransform.Rotation)
    return FTransform(Rotation, Translation, Scale3D)
end

function SkillActionUtil.ProtoColor2FLinearColor(InColor)
    return FLinearColor(InColor.R, InColor.G, InColor.B, InColor.A)
end

function SkillActionUtil.GetPathID(SkillObject)
    return SkillObject.CurrentSubSkillID * 100 + 1
end

function SkillActionUtil.LogPoolInfo(Name, ObjectPool, DefaultNum)
    local FreeNum = #ObjectPool.FreeObjectList
    local UsedNum = #ObjectPool.UsedObjectList
    local TotalNum = FreeNum + UsedNum
    FLOG_INFO("%s - Free:  %d", Name, FreeNum)
    FLOG_INFO("%s - Used:  %d", Name, UsedNum)
    FLOG_INFO("%s - Total: %d", Name, TotalNum)
    if DefaultNum and TotalNum > DefaultNum then
        FLOG_WARNING("%s - Current size exceeded default size, default size is %d", Name, DefaultNum)
    end
end

function SkillActionUtil.NeedSkipHitEffAndSound(EffectType,bIsBulletVfx)
    if bIsBulletVfx==nil  then bIsBulletVfx = true end
    return
        (ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_MISS == EffectType or ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_DODGE == EffectType or
            ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_SUPERMAN == EffectType) and not bIsBulletVfx
end

function SkillActionUtil.CanShow(IsMajorShow, OwnerEntityID)
    local bCanShow = false
    if not IsMajorShow or
       ActorUtil.IsMajor(OwnerEntityID) or
       _G.SkillLogicMgr:IsSkillSystem(OwnerEntityID) then
        bCanShow = true
    end

    return bCanShow
end

--主角或技能系统角色均视为主角
function SkillActionUtil.IsSimulateMajor(OwnerEntityID)
    return ActorUtil.IsMajor(OwnerEntityID) or _G.SkillLogicMgr:IsSkillSystem(OwnerEntityID)
end

return SkillActionUtil
