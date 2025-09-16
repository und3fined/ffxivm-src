--
-- Author: henghaoli
-- Date: 2024-04-26 14:04:00
-- Description: 对应C++里面的USkillSplashCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local AddCellTimer <const> = _G.UE.USkillMgr.AddCellTimer



---@class SkillSplashCell : SkillCellBase
---@field Super SkillCellBase
---@field EndCellTimerID number
local SkillSplashCell = LuaClass(SkillCellBase, false)

function SkillSplashCell:Init(CellData, SkillObject)
    self.EndCellTimerID = nil
    SuperInit(self, CellData, SkillObject, self:CanShow(CellData, SkillObject))
end

function SkillSplashCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local AvatarComp = ActorUtil.GetActorAvatarComponent(SkillObject.OwnerEntityID)
    if AvatarComp then
        local Duration = (CellData.m_EndTime - CellData.m_StartTime) * SkillObject.PlayRate
        AvatarComp:SplashSkill(
            CellData.animType,
            Duration,
            CellData.inStrength,
            CellData.inRange,
            SkillActionUtil.ProtoColor2FLinearColor(CellData.m_Color),
            CellData.m_EffectType
        )

        if CellData.bResetWhenCellEnd then
            self.EndCellTimerID = AddCellTimer(self, "BreakSplash", Duration)
        end
    end
end

function SkillSplashCell:BreakSplash()
    self.EndCellTimerID = nil
    local SkillObject = self.SkillObject
    local CellData = self.CellData
    if not SkillObject or not CellData then
        return
    end
    if SkillObject.bIsSingSkillObject or CellData.bResetWhenCellEnd then
        local AvatarComp = ActorUtil.GetActorAvatarComponent(SkillObject.OwnerEntityID)
        if AvatarComp then
            AvatarComp:SplashSkillReset()
        end
    end
end

function SkillSplashCell:ResetAction()
    self:BreakSplash()
    SuperResetAction(self)
end

return SkillSplashCell
