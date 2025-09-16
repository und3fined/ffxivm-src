--
-- Author: henghaoli
-- Date: 2024-04-24 17:05:00
-- Description: 对应C++里面的UCameraShakeCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")

local UE = _G.UE
local SkillLogicMgr = _G.SkillLogicMgr
local UCameraMgr = UE.UCameraMgr.Get()
local IsSimulateMajor = UE.USkillUtil.IsSimulateMajor
local USkillSystemUtil = UE.USkillSystemUtil



---@class CameraShakeCell : SkillCellBase
---@field Super SkillCellBase
---@field ShakeGuid UE.FGuid
local CameraShakeCell = LuaClass(SkillCellBase, false)

function CameraShakeCell:Init(CellData, SkillObject)
    local bCanShake = false
    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    if not CellData.IsMajorShake or IsSimulateMajor(Me) then
        bCanShake = true
    end

    local ShakeGrade = UCameraMgr:GetCameraShakeGrade()
    if ShakeGrade ~= nil and  ShakeGrade - 2 < CellData.ShakeGrade  then
        bCanShake = false
    end
    SuperInit(self, CellData, SkillObject, bCanShake)
end

function CameraShakeCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CameraShakePath = self.CellData.CameraShakeType
    if CameraShakePath ~= "None" then
        if SkillObject.bIsSingSkillObject then
            self.ShakeGuid = _G.UE.UCameraMgr:Get():PlayCameraShake(CameraShakePath)
        elseif SkillLogicMgr:IsSkillSystem(SkillObject.OwnerEntityID) then
            USkillSystemUtil.PlayCameraShakeSample(CameraShakePath)
        else
            UCameraMgr:PlayCameraShakeSample(CameraShakePath, nil)
        end
    end
end

function CameraShakeCell:ResetAction()
    local ShakeGuid = self.ShakeGuid
    if ShakeGuid then
        UCameraMgr:StopCameraShake(ShakeGuid)
        self.ShakeGuid = nil
    end
    SuperResetAction(self)
end

return CameraShakeCell
