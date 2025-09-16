--
-- Author: henghaoli
-- Date: 2024-04-25 20:43:00
-- Description: 对应C++里面的USkillPlayWindEffectCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local CommonUtil = require("Utils/CommonUtil")
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")

local UE = _G.UE
local FVector = UE.FVector
local AWindDirectionalSource = UE.AWindDirectionalSource
local AddCellTimer <const> = _G.UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = _G.UE.USkillMgr.RemoveCellTimer



---@class SkillPlayWindEffectCell : SkillCellBase
---@field Super SkillCellBase
---@field Wind userdata
---@field EndWindTimerID number
local SkillPlayWindEffectCell = LuaClass(SkillCellBase, false)

function SkillPlayWindEffectCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function SkillPlayWindEffectCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    local Socket = CellData.Socket
    local SocketName = Socket.m_SocketNameFinal
    local Location
    if SocketName == "NONE" then
        Location = Me:GetSocketLocationByName(SocketName)
    else
        Location = Me:FGetActorLocation() - FVector(0, 0, Me:GetCapsuleHalfHeight())
    end
    local RelativeLocation = SkillActionUtil.ProtoVector2FVector(Socket.m_RelativeLocation)
    local ActorRotation = Me:FGetActorRotation()
    Location = Location + ActorRotation:RotateVector(RelativeLocation)

    local Wind = CommonUtil.SpawnActor(AWindDirectionalSource, Location)
    local Component = Wind.Component
    Component.Strength = CellData.Strength
    Component.Speed = CellData.Speed
    Component.MinGustAmount = CellData.MinGustAmount
    Component.MaxGustAmount = CellData.MaxGustAmount
    Component.Radius = CellData.Radius
    Component:SetWindType(CellData.bPointWind and 1 or 0)
    self.Wind = Wind

    self.EndWindTimerID = AddCellTimer(self, "EndWind", CellData.m_EndTime - CellData.m_StartTime)
end

function SkillPlayWindEffectCell:EndWind()
    local Wind = self.Wind
    if Wind then
        CommonUtil.DestroyActor(Wind)
        self.Wind = nil
    end
end

function SkillPlayWindEffectCell:BreakSkill()
    SuperBreakSkill(self)
    RemoveCellTimer(self.EndWindTimerID)
    self:EndWind()
end

function SkillPlayWindEffectCell:ResetAction()
    RemoveCellTimer(self.EndWindTimerID)
    self:EndWind()
    SuperResetAction(self)
end

return SkillPlayWindEffectCell
