---
--- Author: anypkvcai
--- DateTime: 2021-04-26 10:33
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local MajorUtil = require("Utils/MajorUtil")
local BuffDefine = require("Game/Buff/BuffDefine")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR

---@class ActorBufferVM : UIViewModel
local ActorBufferVM = LuaClass(UIViewModel)

---Ctor
function ActorBufferVM:Ctor()
    self.BuffSkillType = nil
    self.BuffID = nil
    self.EntityID = nil
    self.GiverID = nil

    self.BuffIcon = nil
    self.Name = nil
    self.Desc = nil

    self.Weight = nil  -- 排序优先级，越大越靠前
    self.IsBuffTimeDisplayOrigin = nil
    self.IsBuffTimeDisplay = nil

    self.Pile = nil --层数
    self.LeftTime = nil --剩余时间 或 次数
    self.ExpdTime = nil --期望结束时间
    self.IsEffective = nil --是否生效
    self.IsEternal = nil -- 是否是永久buff
    self.AddTime = nil

    self.IsFromMajor = nil

    self.BuffActiveType = nil
    self.BuffRemoveType = nil
end

function ActorBufferVM:IsEqualVM(Value)
    return nil ~= Value and Value.GiverID == self.GiverID and Value.BuffID == self.BuffID and Value.BuffSkillType == self.BuffSkillType
end

---@class BuffVMParams
---@field BuffSkillType BuffDefine.BuffSkillType
---@field BuffID number
---@field EntityID number
---@field GiverID number
---@field ExpdTime number
---@field Pile number
---@field Cfg table
---@field IsEffective boolean Buff是否生效
---@field IsBuffTimeDisplay boolean 是否显示剩余时间(次数)
---@field BuffRemoveType ProtoRes.REMOVE_TYPE 计时or计次
---@field RemainingCount number 若BuffRemoveType为计次，需要传入剩余次数
---@field IsEternal boolean 若BuffRemoveType为计时，需要传入是否为永久buff
---@field AddTime number Buff添加时间(或添加工次)

---UpdateVM
---@param Value BuffVMParams
function ActorBufferVM:UpdateVM(Value)
    if table.is_nil_empty(Value) then return end

    self.BuffSkillType = Value.BuffSkillType
    self.BuffID = Value.BuffID
    self.EntityID = Value.EntityID
    self.GiverID = Value.GiverID

    self.IsBuffTimeDisplayOrigin = Value.IsBuffTimeDisplay
    self.IsBuffTimeDisplay = Value.IsBuffTimeDisplay

    self.BuffRemoveType = Value.BuffRemoveType
    self.IsEternal = Value.IsEternal
    self.ExpdTime = Value.ExpdTime
    self.RemainingCount = Value.RemainingCount

    self.IsEffective = Value.IsEffective

    self.Pile = Value.Pile
    self.AddTime = Value.AddTime

    local Cfg = Value.Cfg
    self.Weight = Cfg.IconDisplayWeight
    if Value.BuffSkillType == BuffDefine.BuffSkillType.Combat then
        self.BuffIcon = Cfg.BuffIcon
        self.Name = Cfg.BuffName

        -- loiafeng: 有一些战斗Buff会动态修正属性，需要运行时计算具体数值
        local DescFromTable = Cfg.Desc
        if BuffUIUtil.HasDynamicBuffDesc(Cfg.Tag) then
            local RoleLevel = (MajorUtil.GetMajorRoleVM() or {}).Level or 0  -- 副本同步前的等级
            self.Desc = BuffUIUtil.TranslateDynamicBuffDesc(DescFromTable, MajorUtil.GetMajorProfClass(), RoleLevel, _G.PWorldMgr:GetSceneLevel())
        else
            self.Desc = DescFromTable
        end

        self.BuffActiveType = Cfg.DisplayType
        self.IsFromMajor = (Value.GiverID == MajorUtil.GetMajorEntityID())
    elseif Value.BuffSkillType == BuffDefine.BuffSkillType.Life then
        self.BuffIcon = Cfg.Icon
        self.Name = Cfg.Name
        self.Desc = Cfg.Desc
        self.BuffActiveType = Cfg.DisplayType
        self.IsFromMajor = true
    elseif Value.BuffSkillType == BuffDefine.BuffSkillType.BonusState then
        self.BuffIcon = Cfg.EffectIcon
        if Cfg.StateType == ProtoRes.BonusStateType.BonusStateTypeGroup then
            self.Name = LSTR(500006) .. Cfg.EffectName  -- 部队特效：
        else
            self.Name = Cfg.EffectName
        end
        self.Desc = Cfg.Desc

        self.BuffActiveType = BuffDefine.BuffDisplayActiveType.Positive
        self.IsFromMajor = true
    end

    self:UpdateLeftTime()
    self:UpdateBuffTimeDisplay()

    -- print("loiafeng: ActorBufferVM.BuffName: " .. tostring(self.Name))
    -- print("loiafeng: ActorBufferVM.BuffID: " .. tostring(self.BuffID))
    -- print("loiafeng: ActorBufferVM.BuffRemoveType: " .. tostring(self.BuffRemoveType))
    -- print("loiafeng: ActorBufferVM.IsEternal: " .. tostring(self.IsEternal))
    -- print("loiafeng: ActorBufferVM.IsBuffTimeDisplay: " .. tostring(self.IsBuffTimeDisplay))
    -- print("loiafeng: ActorBufferVM.ExpdTime: " .. tostring(self.ExpdTime))
    -- print("loiafeng: ActorBufferVM.LeftTime: " .. tostring(self.LeftTime))
    -- print("loiafeng: ActorBufferVM.Weight: " .. tostring(self.Weight))
end

function ActorBufferVM:SetEffective(Value)
    self.IsEffective = Value
end

function ActorBufferVM:UpdateLeftTime()
    if self.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION then
        self.LeftTime = self.IsEternal and 0 or BuffUIUtil.GetLeftTimeSecondByExpdTime(self.ExpdTime)
    elseif self.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_COUNT then
        self.LeftTime = self.RemainingCount
    else
        self.LeftTime = 0
    end
   _G.EventMgr:SendEvent(_G.EventID.MajorUpdateBuffTime, {
    BuffLeftTime = self.LeftTime,
    BuffID = self.BuffID
})
end

function ActorBufferVM:UpdateBuffTimeDisplay()
    if not self.IsBuffTimeDisplayOrigin then
        self.IsBuffTimeDisplay = false
        return
    end

    if self.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION then
        --大于60秒的Buff不显示时间，剩余时间为0的也有可能是永久Buff
        self.IsBuffTimeDisplay = self.LeftTime < BuffDefine.MainBuffUIShowLeftTime and self.LeftTime > 0
    elseif self.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_COUNT then
        --剩余次数小于0的为无限次buff
        self.IsBuffTimeDisplay = (self.LeftTime > 0)
    else
        self.IsBuffTimeDisplay = false
    end
end

function ActorBufferVM:IsCountBuff()
    return self.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_COUNT
end

return ActorBufferVM
