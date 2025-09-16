
local LuaClass = require("Core/LuaClass")
local EntranceNpc = require("Game/Interactive/EntranceItem/EntranceNpc")
local EntranceGather = require("Game/Interactive/EntranceItem/EntranceGather")
local EntrancePlayer = require("Game/Interactive/EntranceItem/EntrancePlayer")
local EntranceCrystal = require("Game/Interactive/EntranceItem/EntranceCrystalPortal")
local EntranceEObj = require("Game/Interactive/EntranceItem/EntranceEObj")
local EntranceUseItem = require("Game/Interactive/EntranceItem/EntranceUseItem")
local EntranceChocoboNpc = require("Game/Interactive/EntranceItem/EntranceChocoboNpc")
local EntranceWorldViewObj = require("Game/Interactive/EntranceItem/EntranceWorldViewObj")
local EntranceNpcQuest = require("Game/Interactive/EntranceItem/EntranceNpcQuest")
local EntrancePWorldBranch = require("Game/Interactive/EntranceItem/EntrancePWorldBranch")
local EntranceArmyNpc = require("Game/Interactive/EntranceItem/EntranceArmyNpc")

local EntranceItemFactory = LuaClass()

_G.LuaEntranceType = _G.LuaEntranceType or {
    NPC = _G.UE.EActorType.Npc,       --3
    GATHER = _G.UE.EActorType.Gather, --5
    PLAYER = _G.UE.EActorType.Player, --1
    EOBJ = _G.UE.EActorType.EObj,     --9

    --非EActorType类型，可以从100开始定义
    CRYSTAL = 101,
    NPCQUEST = 102,

    --共享Entrance类型从200开始定义
    SharedEntranceMin = 200,
    UseItem = 201,
    WorldViewObj = 202,
    PWorldBranch = 203,
    ArmyNpc = 204,
}

--以后有需要再按Type，记录各个子类，然后通过Type获取
--现在直接在这里按类型处理了
---@return EntranceBase
function EntranceItemFactory:CreateEntrance(EntranceParams, ExtraParam)
    local IUnit = nil

    local targetType = EntranceParams.IntParam1

    if nil == targetType then
        FLOG_ERROR("Interactive Factory:CreateEntreance Failed, targetType is nil")
        return nil
    end

    if targetType == LuaEntranceType.NPC then
        if _G.NpcMgr:IsChocoboNpcByNpcID(EntranceParams.ULongParam2) then
            IUnit = EntranceChocoboNpc.New()
        else
            IUnit = EntranceNpc.New()
        end
    elseif targetType == LuaEntranceType.GATHER then
        IUnit = EntranceGather.New()
    elseif targetType == LuaEntranceType.PLAYER then
        IUnit = EntrancePlayer.New()
    elseif targetType == LuaEntranceType.CRYSTAL then
        IUnit = EntranceCrystal.New()
    elseif targetType == LuaEntranceType.EOBJ then
        IUnit = EntranceEObj.New()
    elseif targetType == LuaEntranceType.WorldViewObj then
        IUnit = EntranceWorldViewObj.New()
    elseif targetType == LuaEntranceType.NPCQUEST then
        IUnit = EntranceNpcQuest.New()
    elseif targetType == LuaEntranceType.PWorldBranch then
        IUnit = EntrancePWorldBranch.New()
    elseif targetType == LuaEntranceType.ArmyNpc then
        IUnit = EntranceArmyNpc.New()
    end

    if not IUnit then
        FLOG_ERROR("Interactive Factory:CreateEntreance Failed, targetType:%d", targetType)
        return nil
    end

    IUnit:Init(EntranceParams, ExtraParam)

    return IUnit
end

-- 有些功能要走Entrance，又不局限于某种Actor，放在这里处理
---@return EntranceBase
function EntranceItemFactory:CreateSharedEntrance(EntranceParams)
    -- local ActorType = EntranceParams.IntParam1
    -- local EntityID = EntranceParams.ULongParam1
    -- local ResID = EntranceParams.ULongParam2
    -- local ListID = EntranceParams.ULongParam3

    local IUnit = EntranceUseItem.New()

    if IUnit then
        IUnit:Init(EntranceParams)
    end

    return IUnit
end

return EntranceItemFactory