--
-- Author: henghaoli
-- Date: 2023-11-29 15:13:00
-- Description: 管理音频层面上Actor类型
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local TeamMgr = require("Game/Team/TeamMgr")



local RTPCName       <const> = "Player_type"
local RTPCValueType  <const> = _G.UE.ERTPCValueType.GameObject
local SelfPlayer     <const> = 1
local TeammatePlayer <const> = 2
local OtherPlayer    <const> = 0

local EventID
local UAudioMgr
local FLOG_INFO
local FLOG_ERROR



---@class AudioPlayerTypeMgr : MgrBase
local AudioPlayerTypeMgr = LuaClass(MgrBase)

function AudioPlayerTypeMgr:OnInit()
end

function AudioPlayerTypeMgr:OnBegin()
	EventID = _G.EventID
    UAudioMgr = _G.UE.UAudioMgr.Get()
    FLOG_INFO = _G.FLOG_INFO
    FLOG_ERROR = _G.FLOG_ERROR
end

function AudioPlayerTypeMgr:OnEnd()
	self.SetupRecorder = {}
	self.bSetupRequested = false
end

function AudioPlayerTypeMgr:OnShutdown()

end

function AudioPlayerTypeMgr:OnRegisterNetMsg()

end

function AudioPlayerTypeMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.PlayerCreate, self.OnGameEventPlayerCreate)
    self:RegisterGameEvent(EventID.TeamUpdateMember, self.OnTeamMemberChanged)
end

function AudioPlayerTypeMgr:ChangePlayerType(EntityID, PlayerType)
    if not EntityID or not PlayerType then
        FLOG_ERROR("AudioPlayerTypeMgr:ChangePlayerType: EntityID or PlayerType is nil!")
        return
    end

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        return
    end
    -- local ActorName = ActorUtil.GetActorName(EntityID) or ""

    -- FLOG_INFO(
    --     "AudioPlayerTypeMgr:ChangePlayerType: EntityID: %d, EntityName: %s, TargetPlayerType: %s.",
    --     EntityID, ActorName, PlayerType)

    UAudioMgr.SetRTPCValue(RTPCName, PlayerType, 0, Actor)
end

local function GetMemberEntityIDList()
    local MemberRoleIDList = TeamMgr:GetMemberRoleIDList()
    local MemberEntityIDList = {}

    for _, RoleID in pairs(MemberRoleIDList) do
        table.insert(MemberEntityIDList, ActorUtil.GetEntityIDByRoleID(RoleID))
    end

    return MemberEntityIDList
end

function AudioPlayerTypeMgr:OnTeamMemberChanged()
    local LastTeamMemberList = self.TeamMemberList or {}
    local CurrentTeamMemberList = GetMemberEntityIDList()

    -- 处理新加入小队的成员
    for _, EntityID in pairs(CurrentTeamMemberList) do
        if table.find_item(LastTeamMemberList, EntityID) == nil then
            if not MajorUtil.IsMajor(EntityID) then
                self:ChangePlayerType(EntityID, TeammatePlayer)
            end
        end
    end

    -- 处理离开小队的成员
    for _, EntityID in pairs(LastTeamMemberList) do
        if table.find_item(CurrentTeamMemberList, EntityID) == nil then
            if not MajorUtil.IsMajor(EntityID) then
                self:ChangePlayerType(EntityID, OtherPlayer)
            end
        end
    end

    self.TeamMemberList = CurrentTeamMemberList
end

function AudioPlayerTypeMgr:OnGameEventMajorCreate(_)
    local EntityID = MajorUtil.GetMajorEntityID()
    self:ChangePlayerType(EntityID, SelfPlayer)

    -- 演奏bus RTPC设置, 0表示MainPlayer. 这个RTPC默认是1, 所以其他玩家不需要设置
    local Major = MajorUtil.GetMajor()
    if Major then
        UAudioMgr.SetRTPCValue("Instruments_Type", 0, 0, Major)
    end
end

function AudioPlayerTypeMgr:OnGameEventPlayerCreate(Params)
    local EntityID = Params.ULongParam1

    if MajorUtil.IsMajor(EntityID) then
        return
    end

    -- # TODO - PVP接入后更新逻辑
    local PlayerType
    if PWorldMgr:CurrIsInDungeon() or TeamMgr:IsTeamMemberByEntityID(EntityID) then
        PlayerType = TeammatePlayer
    else
        PlayerType = OtherPlayer
    end

    self:ChangePlayerType(EntityID, PlayerType)
end

function AudioPlayerTypeMgr:GetOnHitSoundDelegatePair(CasterEntityID)
    local Caster = ActorUtil.GetActorByEntityID(CasterEntityID)
    local Value = UAudioMgr.GetRTPCValue(RTPCName, 0, RTPCValueType, 0, Caster)
    return CommonUtil.GetDelegatePair(function(_, PlayingID)
        UAudioMgr.SetRTPCValueByPlayingID(RTPCName, Value, PlayingID, 0)
    end, true)
end

return AudioPlayerTypeMgr
