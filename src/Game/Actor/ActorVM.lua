---
--- Author: anypkvcai
--- DateTime: 2021-04-26 15:33
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActorUtil = require("Utils/ActorUtil")
local UIBindableBuffList = require("Game/Buff/VM/UIBindableBuffList")
local ProtoCommon = require("Protocol/ProtoCommon")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local BuffDefine = require("Game/Buff/BuffDefine")
local MajorUtil = require("Utils/MajorUtil")

local attr_type = ProtoCommon.attr_type

---@class ActorVM : UIViewModel
local ActorVM = LuaClass(UIViewModel)

---Ctor
function ActorVM:Ctor()
    self.EntityID = nil
    self.RoleID = nil
    self.CurHP = 0
    self.MaxHP = 0
    self.CurMP = 0
    self.MaxMP = 0
    self.CurGP = 0
    self.MaxGP = 0
    self.CurMK = 0
    self.MaxMK = 0
    self.Level = 0

    self.BufferVMList = UIBindableBuffList.New()

    self.UpdateTimerReq = 0
end

---UpdateVM
---@param Value table @{ EntityID = EntityID, RoleID = RoleID }
function ActorVM:UpdateVM(Value)
    local EntityID = Value.EntityID
    self.EntityID = EntityID
    self.RoleID = Value.RoleID

    local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
    if nil == AttributeComponent then
        return
    end

    self.CurHP = AttributeComponent:GetCurHp()
    self.MaxHP = AttributeComponent:GetMaxHp()
    self.CurMP = AttributeComponent:GetCurMp()
    self.MaxMP = AttributeComponent:GetMaxMp()
    self.CurGP = AttributeComponent:GetAttrValue(attr_type.attr_gp)
    self.MaxGP = AttributeComponent:GetAttrValue(attr_type.attr_gp_max)
    self.CurMK = AttributeComponent:GetAttrValue(attr_type.attr_mk)
    self.MaxMK = AttributeComponent:GetAttrValue(attr_type.attr_mk_max)

    self:UpdateBuffer()

    self:UpdateLevel()
end

function ActorVM:UpdateLevel()
    if MajorUtil.IsMajor(self.EntityID) then
        self.Level = MajorUtil.GetMajorLevel() or 0
    elseif ActorUtil.IsBuddy(self.EntityID) then  -- 搭档使用主人的等级
        local OwnerID = ActorUtil.GetActorOwner(self.EntityID)
        local AttrComp = ActorUtil.GetActorAttributeComponent(OwnerID)
        if nil ~= AttrComp then
            self.Level = AttrComp.Level
        end
    else
        local AttrComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
        if nil ~= AttrComp then
            self.Level = AttrComp.Level
        end
    end
end

function ActorVM:UpdateBuffer()
    local Values = BuffUIUtil.GetEntityBuffVMParamsList(self.EntityID, true)
    self.BufferVMList:UpdateByValues(Values, BuffUIUtil.SortBuffDisplay)
end

---AddOrUpdateBuff 新增或者刷新Buff
---@param BuffID number
---@param BuffType BuffDefine.BuffSkillType
---@param Params FCombatBuff|LifeSkillBuffInfo|BonusState
function ActorVM:AddOrUpdateBuff(BuffID, BuffType, Params)
    local Value = nil

    if BuffType ==  BuffDefine.BuffSkillType.Combat then
        Value = BuffUIUtil.CombatBuff2BuffVMParams(self.EntityID, BuffID, Params)
    elseif BuffType == BuffDefine.BuffSkillType.Life then
        Value = BuffUIUtil.LifeSkillBuff2BuffVMParams(self.EntityID, BuffID, Params)
    elseif BuffType == BuffDefine.BuffSkillType.BonusState then
        Value = BuffUIUtil.BonusState2BuffVMParams(self.EntityID, BuffID, Params)
    end

    if nil ~= Value and BuffUIUtil.CheckBuffDisplay(Value) then
        self.BufferVMList:AddOrUpdateBuff(Value)
    end
end

---RemoveBuff
---@param BuffID number
function ActorVM:RemoveBuff(BuffID, GiverID, BuffSkillType)
    self.BufferVMList:RemoveBuff(BuffID, GiverID, BuffSkillType)
end

---SetBuffIsEffective
---@param BuffID number
---@param GiverID number
---@param BuffSkillType BuffDefine.BuffSkillType
---@param IsEffective boolean
function ActorVM:SetBuffIsEffective(BuffID, GiverID, BuffSkillType, IsEffective)
    local BuffVM = self.BufferVMList:FindBuffVM(BuffID, GiverID, BuffSkillType)
    if nil ~= BuffVM then
        BuffVM:SetEffective(IsEffective)
    end
end

---被AcotrMgr驱动
function ActorVM:OnTimer()
    if nil == self.BufferVMList then return end
    self.BufferVMList:UpdateBuffsLeftTime()
end

---ClearBuffer
function ActorVM:ClearBuffer()
    self.BufferVMList:Clear()
end

-----------------------------------------------------------------------------
---HP

---SetCurHP
---@param Value number
function ActorVM:SetCurHP(Value)
    self.CurHP = Value
end

---GetCurHP
---@return number
function ActorVM:GetCurHP()
    return self.CurHP
end

---SetMaxHP
---@param Value number
function ActorVM:SetMaxHP(Value)
    self.MaxHP = Value
end

---GetMaxHP
---@return number
function ActorVM:GetMaxHP()
    return self.MaxHP
end

-----------------------------------------------------------------------------
---MP

---SetCurMP
---@param Value number
function ActorVM:SetCurMP(Value)
    self.CurMP = Value
end

---GetCurMP
---@return number
function ActorVM:GetCurMP()
    return self.CurMP
end

---SetMaxMP
---@param Value number
function ActorVM:SetMaxMP(Value)
    self.MaxMP = Value
end

---GetMaxMP
---@return number
function ActorVM:GetMaxMP()
    return self.MaxMP
end

-----------------------------------------------------------------------------
---GP

---SetCurGP
---@param Value number
function ActorVM:SetCurGP(Value)
    self.CurGP = Value
end

---GetCurGP
---@return number
function ActorVM:GetCurGP()
    return self.CurGP
end

---SetMaxGP
---@param Value number
function ActorVM:SetMaxGP(Value)
    self.MaxGP = Value
end

---GetMaxGP
---@return number
function ActorVM:GetMaxGP()
    return self.MaxGP
end

-----------------------------------------------------------------------------
---MK

---SetCurMK
---@param Value number
function ActorVM:SetCurMK(Value)
    self.CurMK = Value or 0
end

---GetCurMK
---@return number
function ActorVM:GetCurMK()
    return self.CurMK or 0
end

---SetMaxMK
---@param Value number
function ActorVM:SetMaxMK(Value)
    self.MaxMK = Value or 10
end

---GetMaxMK
---@return number
function ActorVM:GetMaxMK()
    return self.MaxMK or 10
end

return ActorVM
