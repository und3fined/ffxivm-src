--
-- Author: henghaoli
-- Date: 2024-04-18 20:32:00
-- Description: 对应C++里面的USkillSoundCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local AudioUtil = require("Utils/AudioUtil")

local UE = _G.UE
local UAudioMgr = UE.UAudioMgr.Get()
local FRotator = UE.FRotator
local NoCache = UE.EObjectGC.NoCache
local Cache_LRU = UE.EObjectGC.Cache_LRU

local AddCellTimer <const> = UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = UE.USkillMgr.RemoveCellTimer

local SetRTPCValue <const> = UE.UAudioMgr.SetRTPCValue
local RTPCName <const> = "Speed_audio"



---@class SkillSoundCell : SkillCellBase
---@field Super SkillCellBase
---@field EndSoundTimerID number
---@field PostEventHandle number 异步调用PostEvent资源的Handle
---@field bIsMajor boolean 是不是主角, 主角有预加载, 资产NoCache即可, 非主角LRU
local SkillSoundCell = LuaClass(SkillCellBase, false)

function SkillSoundCell:Init(CellData, SkillObject)
    local bIsCanPlay = false
    local bIsMajor = ActorUtil.IsMajor(SkillObject.OwnerEntityID)
    if bIsMajor or UAudioMgr:IsPlaySound() then
        bIsCanPlay = true
    end

    self.bIsMajor = bIsMajor
    self.PostEventHandle = nil

    SuperInit(self, CellData, SkillObject, bIsCanPlay)
end

function SkillSoundCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local OwnerEntityID = SkillObject.OwnerEntityID
    local Me = ActorUtil.GetActorByEntityID(OwnerEntityID)
    local bPostAtLocation = CellData.m_IsOffsetPoint or CellData.bUseSelectPoint

    if Me then
        SetRTPCValue(RTPCName, 1 / SkillObject.PlayRate - 1, 0, Me)
    end
    local GCType = (self.bIsMajor or _G.SkillLogicMgr:IsSkillSystem(SkillObject.OwnerEntityID)) and NoCache or Cache_LRU
    if bPostAtLocation then
        local Location = CellData.bUseSelectPoint and
            SkillObject.Position or
            Me:FGetActorLocation() + Me:FGetActorRotation():RotateVector(SkillActionUtil.ProtoVector2FVector(CellData.m_PointOffset))
        local Rotator = CellData.bUseSelectPoint and FRotator(0, SkillObject.Angle or 0, 0) or Me:FGetActorRotation()
        self.PostEventHandle = UAudioMgr:AsyncLoadAndPostEventAtLocationWithOwner(_G.FWORLD(), CellData.m_Event, Me, Location, Rotator, nil, GCType)
    else
        self.PostEventHandle = UAudioMgr:AsyncLoadAndPostEvent(CellData.m_Event, Me, nil, false, GCType)
    end
    self.EndSoundTimerID = AddCellTimer(self, "EndSound", CellData.m_EndTime - CellData.m_StartTime)
end

function SkillSoundCell:EndSound()
    if self.PostEventHandle then
        AudioUtil.StopAsyncAudioHandle(self.PostEventHandle)
        self.PostEventHandle = nil
    end
end

function SkillSoundCell:ConditionalEndSound()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end
    if _G.SkillLogicMgr:IsSkillSystem(SkillObject.OwnerEntityID) or self.CellData.IsCanBeBreak then
        self:EndSound()
    end

    local OwnerEntityID = SkillObject.OwnerEntityID
    local Me = ActorUtil.GetActorByEntityID(OwnerEntityID)
    if Me then
        SetRTPCValue(RTPCName, 0, 0, Me)
    end

    RemoveCellTimer(self.EndSoundTimerID)
end

function SkillSoundCell:BreakSkill()
    SuperBreakSkill(self)
    self:ConditionalEndSound()
end

function SkillSoundCell:ResetAction()
    self:ConditionalEndSound()
    SuperResetAction(self)
end

return SkillSoundCell
