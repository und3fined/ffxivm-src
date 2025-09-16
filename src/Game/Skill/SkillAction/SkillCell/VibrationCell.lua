--
-- Author: henghaoli
-- Date: 2024-04-25 15:24:00
-- Description: 对应C++里面的UVibrationCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init

local UE =_G.UE
local FForceFeedback = UE.FForceFeedback
local UForceFeedbackMgr = UE.UForceFeedbackMgr.Get()



---@class VibrationCell : SkillCellBase
---@field Super SkillCellBase
local VibrationCell = LuaClass(SkillCellBase, false)

function VibrationCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function VibrationCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local ForceFeedback = FForceFeedback()
    ForceFeedback.DurationTime = CellData.m_EndTime - CellData.m_StartTime
    ForceFeedback.bUseTimelineTime = true
    ForceFeedback.Path:SetPath(CellData.m_ForceFeedAsset)
    ForceFeedback.IntensityMultiplier = CellData.m_IntensityMultiplier
    ForceFeedback.bLoop = CellData.m_bLooping
    UForceFeedbackMgr:Play(ForceFeedback)
end

return VibrationCell
