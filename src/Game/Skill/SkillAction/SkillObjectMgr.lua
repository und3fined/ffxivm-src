--
-- Author: henghaoli
-- Date: 2024-04-08 19:50:00
-- Description: SkillObject的管理类
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ObjectPool = require("Game/ObjectPool/ObjectPool")
local SkillObject = require("Game/Skill/SkillAction/SkillObject")
local TimeUtil = require("Utils/TimeUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local SkillActionConfig = require("Game/Skill/SkillAction/SkillActionConfig")

local FLOG_INFO = _G.FLOG_INFO
local MakeProfileTag = CommonUtil.MakeProfileTag

local ResetSkillWeight <const> = -1

---@class SkillObjectMgr : MgrBase
local SkillObjectMgr = LuaClass(MgrBase)

function SkillObjectMgr:OnInit()
end

function SkillObjectMgr:OnBegin()
    self:InitSkillObjectPool()
    self.EntityDataMap = {}
    SkillObject:SetSkillObjectMgr(self)
end

function SkillObjectMgr:OnEnd()
    self:ReleaseSkillObjectPool()
end

function SkillObjectMgr:OnShutdown()
end

function SkillObjectMgr:OnRegisterNetMsg()
end

function SkillObjectMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PWorldExit, self.OnPWorldExit)
end

function SkillObjectMgr:InitSkillObjectPool()
    local function Constructor()
        return SkillObject.New()
    end

    local Pool = ObjectPool.New(Constructor)
    Pool:PreLoadObject(SkillActionConfig.SkillObjectPoolSize)

    self.SkillObjectPool = Pool
end

function SkillObjectMgr:ReleaseSkillObjectPool()
    self.SkillObjectPool:ReleaseAll()
end

function SkillObjectMgr:AllocSkillObject()
    ---@param Object SkillObject
    local Object = self.SkillObjectPool:AllocObject()
    Object:ResetParams()
    return Object
end

function SkillObjectMgr:FreeSkillObject(Object)
    self.SkillObjectPool:FreeObject(Object)
end

function SkillObjectMgr:GetOrCreateEntityData(EntityID)
    local EntityDataMap = self.EntityDataMap
    if not EntityDataMap then
        _G.FLOG_ERROR("[SkillObjectMgr] Try to get entity data before SkillObjectMgr init!")
        return {}
    end
    local EntityData = EntityDataMap[EntityID]
    if not EntityData then
        EntityData = {
            SkillObjectMap = {},
            CurrentSkillObject = nil,
        }
        EntityDataMap[EntityID] = EntityData
    end
    return EntityData
end

function SkillObjectMgr:GetCurrentSkillWeight(EntityID)
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if CurrentSkillObject then
        return CurrentSkillObject.SkillWeight
    end

    return ResetSkillWeight
end

function SkillObjectMgr:GetSkillCanBreak(EntityID)
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if CurrentSkillObject then
        return CurrentSkillObject.bIsCanBreak
    end
    return true
end

function SkillObjectMgr:RegisterSkillObject(EntityID, SubSkillID, Object)
    local EntityData = self:GetOrCreateEntityData(EntityID)
    EntityData.SkillObjectMap[SubSkillID] = Object
end

function SkillObjectMgr:UnRegisterSkillObject(EntityID, Object)
    local EntityData = self:GetOrCreateEntityData(EntityID)
    if EntityData.CurrentSkillObject == Object then
        EntityData.CurrentSkillObject = nil
    end

    local SubSkillID = Object.CurrentSubSkillID or 0
    local SkillObjectMap = EntityData.SkillObjectMap
    local CachedObject = SkillObjectMap[SubSkillID]
    if CachedObject == Object then
        SkillObjectMap[SubSkillID] = nil
    end

    -- 执行了UnRegister操作, 意味着这个Object已经不再使用, 需要归还给池子
    self:FreeSkillObject(Object)
end

function SkillObjectMgr:CheckSkillWeight(EntityID, SkillWeight)
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if not CurrentSkillObject then
        return true
    end

    if CurrentSkillObject.bIsEndState == false and SkillWeight <= CurrentSkillObject.SkillWeight then
        return false
    end

    return true
end

function SkillObjectMgr:BreakSkill(EntityID)
    if not self.EntityDataMap then
        return
    end

    local EntityData = self:GetOrCreateEntityData(EntityID)
    local CurrentSkillObject = EntityData.CurrentSkillObject
    if CurrentSkillObject then
        CurrentSkillObject:BreakSkill()
    end
end

function SkillObjectMgr:SendQuitSkill(EntityID)
    local EntityData = self:GetOrCreateEntityData(EntityID)
    local CurrentSkillObject = EntityData.CurrentSkillObject
    if CurrentSkillObject and CurrentSkillObject.bIsCanBreak and not CurrentSkillObject.bIsEndState then
        local SkillID = CurrentSkillObject.CurrentSkillID
        CurrentSkillObject:BreakSkill()
        SkillActionUtil.SendQuitAction(EntityID, SkillID)
    end
end

function SkillObjectMgr:StopCurSkillSingleCell(EntityID, CellType)
    local EntityData = self:GetOrCreateEntityData(EntityID)
    local CurrentSkillObject = EntityData.CurrentSkillObject
    if CurrentSkillObject and not CurrentSkillObject.bIsEndState then
        CurrentSkillObject:StopSkillCell(CellType)
    end
end

function SkillObjectMgr:GetCurSkillRunningTime(EntityID)
    local RunningTime = 0
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if CurrentSkillObject then
        RunningTime = TimeUtil.GetLocalTimeMS() - CurrentSkillObject.CurrentStartTime
    end
    return RunningTime
end

function SkillObjectMgr:CreateSkillObjectAndCast(...)
    if not self.SkillObjectPool then
        _G.FLOG_ERROR("[SkillObjectMgr] Try to cast skill before SkillObjectMgr init!")
        return
    end
    local _ <close> = MakeProfileTag("SkillObjectMgr:CreateSkillObjectAndCast")
    local Object = self.SkillObjectPool:AllocObject()
    if not Object:Init(...) then
        self.SkillObjectPool:FreeObject(Object)
        return
    end
    local EntityID = Object.OwnerEntityID
    self:RegisterSkillObject(EntityID, Object.CurrentSubSkillID, Object)
    self:GetOrCreateEntityData(EntityID).CurrentSkillObject = Object
end

function SkillObjectMgr:OnActionPresent(EntityID, ActionData)
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if CurrentSkillObject then
        CurrentSkillObject:OnActionPresent(ActionData)
    end
end

function SkillObjectMgr:OnAttackPresent(EntityID, SubSkillID, AttackData)
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if CurrentSkillObject and CurrentSkillObject.CurrentSubSkillID == SubSkillID and CurrentSkillObject.bHasServerCheck then
        local _ <close> = MakeProfileTag("SkillObjectMgr:OnAttackPresent")
        CurrentSkillObject:OnAttackPresent(AttackData)
        return true
    end
    return false
end

function SkillObjectMgr:MajorReceiveSkillAction(EntityID, SkillID, SubSkillID)
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if CurrentSkillObject and CurrentSkillObject.CurrentSkillID == SkillID and CurrentSkillObject.CurrentSubSkillID == SubSkillID then
        CurrentSkillObject.bHasServerCheck = true
    end
end

function SkillObjectMgr:SetSkillObjectSelectPos(EntityID, SelectPos)
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if CurrentSkillObject then
        CurrentSkillObject.Position = _G.UE.FVector(SelectPos.X, SelectPos.Y, SelectPos.Z)
    end
end

function SkillObjectMgr:RecordSkillEffectID(EntityID, EffectID)
    local CurrentSkillObject = self:GetOrCreateEntityData(EntityID).CurrentSkillObject
    if CurrentSkillObject then
        CurrentSkillObject:RecordEffectID(EffectID)
    end
end

function SkillObjectMgr:LogPoolInfo()
    FLOG_INFO("--------------- SkillObjectMgr Start ---------------")
    local SkillObjectPool = self.SkillObjectPool
    if SkillObjectPool then
        SkillActionUtil.LogPoolInfo("SkillObjectPool", SkillObjectPool, SkillActionConfig.SkillObjectPoolSize)
    end
    FLOG_INFO("--------------- SkillObjectMgr End   ---------------")
end

-- 切图清理掉所有正在释放的技能
function SkillObjectMgr:OnPWorldExit()
    if not self.EntityDataMap then
        return
    end

    for _, EntityData in pairs(self.EntityDataMap) do
        local CurrentSkillObject = EntityData.CurrentSkillObject
        if CurrentSkillObject then
            CurrentSkillObject:BreakSkill()
        end
    end

    self.EntityDataMap = {}
end

return SkillObjectMgr
