--
-- Author: henghaoli
-- Date: 2024-04-23 18:35:00
-- Description: 对应C++里面的UFadeWeaponCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EquipmentType = ProtoRes.EquipmentType



---@class FadeWeaponCell : SkillCellBase
---@field Super SkillCellBase
local FadeWeaponCell = LuaClass(SkillCellBase, false)

function FadeWeaponCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true, true)
end

function FadeWeaponCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    if not Me then
        return
    end
    local Type = CellData.WeaponType == 1 and EquipmentType.WEAPON_MASTER_HAND or EquipmentType.WEAPON_SLAVE_HAND
    local bHidden = CellData.TargetType == 1 and true or false
    Me:GetAvatarComponent():SetAvatarHiddenInGame(Type, bHidden, false, false)
end

function FadeWeaponCell:ResetEffect()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    if not Me then
        return
    end
    local AvatarComp = Me:GetAvatarComponent()
    AvatarComp:SetAvatarHiddenInGame(EquipmentType.WEAPON_MASTER_HAND, false, false, false)
    AvatarComp:SetAvatarHiddenInGame(EquipmentType.WEAPON_SLAVE_HAND, false, false, false)
end

function FadeWeaponCell:BreakSkill()
    SuperBreakSkill(self)
    self:ResetEffect()
end

function FadeWeaponCell:ResetAction()
    self:ResetEffect()
    SuperResetAction(self)
end

return FadeWeaponCell
