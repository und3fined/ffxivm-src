--
-- Author: henghaoli
-- Date: 2024-04-26 14:17:00
-- Description: 对应C++里面的USkillWeaponSwitchCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

local UE = _G.UE
local FTransform = UE.FTransform
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")

local AddCellTimer <const> = _G.UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = _G.UE.USkillMgr.RemoveCellTimer

local Transform = FTransform()



---@class SkillWeaponSwitchCell : SkillCellBase
---@field Super SkillCellBase
---@field bIsMajor bool 是否是主角
---@field EndCellTimerID number
local SkillWeaponSwitchCell = LuaClass(SkillCellBase, false)

function SkillWeaponSwitchCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
    self.bIsMajor = false
    self.EndCellTimerID = AddCellTimer(self, "BreakSkill", CellData.m_EndTime * SkillObject.PlayRate)
end

function SkillWeaponSwitchCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local AvatarComp = ActorUtil.GetActorAvatarComponent(SkillObject.OwnerEntityID)
    if not AvatarComp then
        return
    end

    if MajorUtil.IsMajor(SkillObject.OwnerEntityID) then
        self.bIsMajor = true
    end

    local CellData = self.CellData
    local BindSocketInfo = CellData.BindSocketInfo
    Transform:SetRotation(SkillActionUtil.ProtoRotator2FRotator(BindSocketInfo.m_RelativeRotation):ToQuat())
    Transform:SetLocation(SkillActionUtil.ProtoVector2FVector(BindSocketInfo.m_RelativeLocation))
    AvatarComp:ChangeWeaponModel(
        CellData.ReplaceWeaponModelPath,
        CellData.ReplaceWeaponSubModelPath,
        CellData.ReplaceWeaponImagechange,
        BindSocketInfo.m_SocketNameFinal,
        Transform,
        CellData.bHideOriginalWeapon
   )
end

function SkillWeaponSwitchCell:BreakSkill()
    SuperBreakSkill(self)
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    RemoveCellTimer(self.EndCellTimerID)
    -- 切换关卡时, 主角EntityID发生了变化, 且早于关卡exit/preload/postload等事件
    -- 这时候用OwnerEntityID是拿不到对应的组件的, 需要重新获取下主角的EntityID 
    local AvatarComp
    if self.bIsMajor then
        AvatarComp = MajorUtil.GetMajorAvatarComponent()
    else
        AvatarComp = ActorUtil.GetActorAvatarComponent(SkillObject.OwnerEntityID)
    end

    if AvatarComp then
        AvatarComp:ResumeWeaponModel()
    end
end

function SkillWeaponSwitchCell:ResetAction()
    self:BreakSkill()
    SuperResetAction(self)
end

return SkillWeaponSwitchCell
