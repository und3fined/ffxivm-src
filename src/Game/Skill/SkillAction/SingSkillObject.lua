--
-- Author: henghaoli
-- Date: 2024-06-05 17:00:00
-- Description: 吟唱技能的技能母体
--

local LuaClass = require("Core/LuaClass")
local CommonUtil = require("Utils/CommonUtil")
local ActorUtil = require("Utils/ActorUtil")
local EffectUtil = require("Utils/EffectUtil")
local SingProcessCfg = require("TableCfg/SingProcessCfg")

local XPCall = CommonUtil.XPCall

local TimerMgr
local SkillSingEffectMgr

local UE = _G.UE

local FLOG_ERROR = _G.FLOG_ERROR

local AddCellTimer <const> = _G.UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = _G.UE.USkillMgr.RemoveCellTimer



---@class SingSkillObject
---@field SingID number 吟唱表ID
---@field OwnerEntityID number 所有者ID
---@field TargetIDList table 技能选怪列表(模拟的)
---@field SingEffectID number 吟唱句柄, SkillSingEffectMgr返回的吟唱UniqueID
---@field PlayRate number 加速倍率
---@field endTime number 吟唱持续的原始时间(ms)
---@field DelayTimerID number BreakSing的TimerID
---@field bIsSingSkillObject boolean 是否是吟唱Object(用来和一般技能区分)
---@field AllEffectIDList table
local SingSkillObject = LuaClass()

function SingSkillObject:Ctor()
    self:ResetParams()

    self.bIsSingSkillObject = true
    if not TimerMgr then
        TimerMgr = _G.TimerMgr
        SkillSingEffectMgr = _G.SkillSingEffectMgr
    end
end

function SingSkillObject:ResetParams()
    self.SingID = 0
    self.OwnerEntityID = 0
    self.TargetIDList = nil
    self.AllEffectIDList = nil
    self.SingEffectID = 0
    self.PlayRate = 1
    self.EndTime = 0
end

function SingSkillObject:Init(SingID, OwnerEntityID, TargetIDList, SingEffectID, EndTime, PlayRate)
    self.SingID = SingID
    self.OwnerEntityID = OwnerEntityID
    self.TargetIDList = TargetIDList
    self.SingEffectID = SingEffectID
    self.PlayRate = PlayRate
    self.EndTime = EndTime * PlayRate / 1000
    self.AllEffectIDList = {}

    self:CastSkill()
end

function SingSkillObject:CastSkill()
    self.Actions = _G.SkillActionMgr:GetSingActionList(self.SingID)
    local Actions = self.Actions

    do
        local _ <close> = CommonUtil.MakeProfileTag("SingSkillObject:ActionInit")
        for _, Action in ipairs(Actions) do
            local CellData = Action.CellData
            -- 避免某个Cell Init过程中出现Error影响其他Cell
            XPCall(Action, Action.Init, CellData, self)
        end
    end

    local EndTime = self.EndTime
    if EndTime > 0 then
        self.DelayTimerID = AddCellTimer(self, "SkillEnd", EndTime)
    end
end

function SingSkillObject:SkillEnd()
    SkillSingEffectMgr:BreakSingEffect(self.OwnerEntityID, self.SingEffectID)
end

function SingSkillObject:BreakSkill()
    local Cfg = SingProcessCfg:FindCfgByKey(self.SingID)
    local bShowWeaponOnBreak = Cfg and Cfg.ShowWeaponOnBreak or 0
    if bShowWeaponOnBreak > 0 then
        local AvatarComp = ActorUtil.GetActorAvatarComponent(self.OwnerEntityID)
        if AvatarComp then
            AvatarComp:SetAvatarHiddenInGame(UE.EAvatarPartType.WEAPON_MASTER_HAND, false, false, false)
            AvatarComp:SetAvatarHiddenInGame(UE.EAvatarPartType.WEAPON_SLAVE_HAND, false, false, false)
        end
    end

    local Actions = self.Actions
    local SkillActionMgr = _G.SkillActionMgr
    local FreeSingCellObject = SkillActionMgr.FreeSingCellObject
    for Index, Action in pairs(Actions) do
        local Type = Action.CellData.Type
        XPCall(Action, Action.ResetAction)
        FreeSingCellObject(SkillActionMgr, Type, Action)
        Actions[Index] = nil
    end

    RemoveCellTimer(self.DelayTimerID)

    if _G.SkillLogicMgr:IsSkillSystem(self.OwnerEntityID) then
        local AllEffectIDList = self.AllEffectIDList
        for _, ID in pairs(AllEffectIDList) do
            EffectUtil.StopVfx(ID, 0, 0)
        end
    end
end

function SingSkillObject:GetDamageCellData()
    FLOG_ERROR("Try to get damage cell data in sing skill object! SingID is %d", self.SingID or 0)
end

function SingSkillObject:RecordEffectID(EffectID)
    local AllEffectIDList = self.AllEffectIDList
    if table.find_item(AllEffectIDList, EffectID) == nil then
        table.insert(AllEffectIDList, EffectID)
    end
end

function SingSkillObject:AddEffectID()
end

function SingSkillObject:RemoveEffectID()
end

return SingSkillObject
