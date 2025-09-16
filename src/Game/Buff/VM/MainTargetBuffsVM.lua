---
--- Author: loiafeng
--- DateTime: 2024-06-18 09:41:14
--- Description: 主界面选中目标的Buff单独使用一个VM管理
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActorUtil = require("Utils/ActorUtil")
local UIBindableBuffList = require("Game/Buff/VM/UIBindableBuffList")
local BuffDefine = require("Game/Buff/BuffDefine")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")

---@class MainTargetBuffsVM : UIViewModel
local MainTargetBuffsVM = LuaClass(UIViewModel)

---Ctor
function MainTargetBuffsVM:Ctor()
    self.EntityID = nil
    self.BuffList = UIBindableBuffList.New()

    self.IsBuffDetailVisiable = false  -- 是否显示Buff详情面板
    self.SelectedBuffIndex = nil  -- 当前选中Buff的索引
    self.SelectedBuffVM = nil  -- 当前选中Buff的VM
end

function MainTargetBuffsVM:CheckSelectedIndex()
    if nil ~= self.SelectedBuffVM then
        local Index = self.BuffList:GetItemIndex(self.SelectedBuffVM)
        self:SetSelectedIndex(Index)
    else
        self:SetSelectedIndex(nil)
    end
end

----------------------------------------------------------------
--- Interface

---SetTarget
---@param EntityID number
function MainTargetBuffsVM:SetTarget(EntityID)
    local _ <close> = CommonUtil.MakeProfileTag("MainTargetBuffsVM:SetTarget")

    self.EntityID = EntityID
    self.SelectedBuffIndex = nil
    self.SelectedBuffVM = nil
    self.IsBuffDetailVisiable = false

    if self:HasTarget() then
        local Values = BuffUIUtil.GetEntityBuffVMParamsList(EntityID, true)
        self.BuffList:UpdateByValues(Values, BuffUIUtil.SortBuffDisplay)
    end
end

---HasTarget
---@return boolean
function MainTargetBuffsVM:HasTarget()
    return (self.EntityID or 0) > 0
end

---IsTarget
---@params EntityID number
---@return boolean
function MainTargetBuffsVM:IsTarget(EntityID)
    return self.EntityID == EntityID
end

---GetBuffNum
---@return number
function MainTargetBuffsVM:GetBuffNum()
    return self.BuffList:Length()
end

---AddOrUpdateBuff 新增或者刷新Buff
---@param BuffID number
---@param BuffType BuffDefine.BuffSkillType
---@param Params FCombatBuff|LifeSkillBuffInfo|BonusState
function MainTargetBuffsVM:AddOrUpdateBuff(BuffID, BuffType, Params)
    local Value = nil

    if BuffType ==  BuffDefine.BuffSkillType.Combat then
        Value = BuffUIUtil.CombatBuff2BuffVMParams(self.EntityID, BuffID, Params)
    elseif BuffType == BuffDefine.BuffSkillType.Life then
        Value = BuffUIUtil.LifeSkillBuff2BuffVMParams(self.EntityID, BuffID, Params)
    elseif BuffType == BuffDefine.BuffSkillType.BonusState then
        Value = BuffUIUtil.BonusState2BuffVMParams(self.EntityID, BuffID, Params)
    end

    if nil ~= Value and BuffUIUtil.CheckBuffDisplay(Value) then
        self.BuffList:AddOrUpdateBuff(Value)
        self:CheckSelectedIndex()
    end
end

---RemoveBuff
---@param BuffID number
---@param GiverID number
---@param BuffSkillType BuffDefine.BuffSkillType
function MainTargetBuffsVM:RemoveBuff(BuffID, GiverID, BuffSkillType)
    local bOK = self.BuffList:RemoveBuff(BuffID, GiverID, BuffSkillType)
    if bOK then
        self:CheckSelectedIndex()
    end
end

---SetSelectedIndex
---@param Index number
function MainTargetBuffsVM:SetSelectedIndex(Index)
    if nil ~= Index and Index > 0 and Index <= self.BuffList:Length() then
        self.SelectedBuffIndex = Index
        self.SelectedBuffVM = self.BuffList:Get(Index)
        self.IsBuffDetailVisiable = true
    else
        self.SelectedBuffIndex = nil
        self.SelectedBuffVM = nil
        self.IsBuffDetailVisiable = false
    end
end

---被AcotrMgr驱动
function MainTargetBuffsVM:OnTimer()
    self.BuffList:UpdateBuffsLeftTime()
end

return MainTargetBuffsVM
