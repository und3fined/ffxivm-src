--
-- Author: henghaoli
-- Date: 2024-04-26 14:50:00
-- Description: 对应C++里面的UMirrorEffectCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")

local MirrorEffectMgr = _G.MirrorEffectMgr
local FMirrorEffectParam = _G.UE.FMirrorEffectParam
local UCameraMgr = _G.UE.UCameraMgr.Get()



---@class MirrorEffectCell : SkillCellBase
---@field Super SkillCellBase
---@field MirrorEffectID number
local MirrorEffectCell = LuaClass(SkillCellBase, false)

function MirrorEffectCell:Init(CellData, SkillObject)
    self.MirrorEffectID = 0
    SuperInit(self, CellData, SkillObject, CellData.EffectActorPath ~= "")
end

function MirrorEffectCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CameraComp = UCameraMgr:GetCurrentCameraComp()
    if not CameraComp then
        return
    end
    local CellData = self.CellData
    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)

    local MirrorEffectParam = FMirrorEffectParam()
    MirrorEffectParam.Target = Me
    local TrajCurves = CellData.TrajCurves
    local TrajCurvePaths = MirrorEffectParam.TrajCurvePaths
    local Add = TrajCurvePaths.Add
    for _, Curve in ipairs(TrajCurves) do
        Add(TrajCurvePaths, Curve)
    end
    MirrorEffectParam.CameraComp = CameraComp

    self.MirrorEffectID = MirrorEffectMgr:PlayEffect(MirrorEffectParam)
end

function MirrorEffectCell:BreakSkill()
    SuperBreakSkill(self)
    MirrorEffectMgr:BreakEffect(self.MirrorEffectID)
end

function MirrorEffectCell:ResetAction()
    MirrorEffectMgr:BreakEffect(self.MirrorEffectID)
    SuperResetAction(self)
end

return MirrorEffectCell
