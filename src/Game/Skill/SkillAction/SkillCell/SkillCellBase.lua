--
-- Author: henghaoli
-- Date: 2024-04-15 10:30:00
-- Description: 对应C++里面的USkillCell
--

local LuaClass = require("Core/LuaClass")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local CommonDefine = require("Define/CommonDefine")

local AddCellTimer <const> = CommonDefine.bUseSkillTimerDelay and _G.UE.USkillMgr.AddCellTimerNextFrame or _G.UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = _G.UE.USkillMgr.RemoveCellTimer



---@class SkillCellBase
---@field CellData table 只读数据
---@field SkillObject SkillObject
---@field TotalDamageCount number
---@field DelayTimerID number 延迟执行StartCell的Timer的ID
local SkillCellBase = LuaClass()

function SkillCellBase:Ctor()
end

-- 根据IsMajorShow判断节点是否可以播放
---MajorShowType 
---nil or false: IsMajorShow
---true: IsMajorShowSplash
function SkillCellBase:CanShow(CellData, SkillObject, MajorShowType)
    local bCanShow = true
    if MajorShowType then
        bCanShow = SkillActionUtil.CanShow(CellData.IsMajorShowSplash,SkillObject.OwnerEntityID)
    else
        bCanShow = SkillActionUtil.CanShow(CellData.IsMajorShow,SkillObject.OwnerEntityID)
    end
    -- LuaClass的小bug, 这里手工恢复一下
    self.__Current = self.__BaseType
    return bCanShow
end

function SkillCellBase:Init(CellData, SkillObject, bShouldStartCell, bReversePlayRate)
    self.CellData = CellData
    self.SkillObject = SkillObject

    if bShouldStartCell then
        local Delay
        if not bReversePlayRate then
            Delay = CellData.m_StartTime * SkillObject.PlayRate
        else
            Delay = CellData.m_StartTime / SkillObject.PlayRate
        end
        self.DelayTimerID = AddCellTimer(self, "StartCell", Delay)
    end
end

function SkillCellBase:OnActionPresent(ActionData)
end

function SkillCellBase:OnAttackPresent(AttackData)
end

function SkillCellBase:BreakSkill()
    RemoveCellTimer(self.DelayTimerID)
end

function SkillCellBase:StopCell()
end

-- 这个函数会把SkillObject和CellData清掉, 如果有依赖这两个表的操作,
-- 请在执行SuperResetAction(self)之前完成
function SkillCellBase:ResetAction()
    self.SkillObject = nil
    self.CellData = nil
    RemoveCellTimer(self.DelayTimerID)
end

return SkillCellBase
