--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2024-09-03 11:01:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-09-12 15:52:09
FilePath: \Script\Game\PWorld\Team\PWorldTeamMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local ATeamMgr = require("Game/Team/Abs/ATeamMgr")

local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local MemStateType = ProtoCommon.MemStateType

local CS_CMD_PWORLD = ProtoCS.CS_CMD.CS_CMD_PWORLD
local SUB_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local EventID
local PWorldTeamVM
local PWorldQuestVM

local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local TeamDefine = require("Game/Team/TeamDefine")
local OpDef = PWorldQuestDefine.OpDef
local ChatDefine = require("Game/Chat/ChatDefine")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local TeamHelper = require("Game/Team/TeamHelper")

local SceneVoteTypeDef = ProtoCommon.SceneVoteType

-------------------------------------------------------------------------------------------------------
---@see Local
local function GetMajorID()
    return MajorUtil.GetMajorRoleID()
end

-------------------------------------------------------------------------------------------------------
---@see Template
---@class PWorldTeamMgr : ATeamMgr
local PWorldTeamMgr = LuaClass(ATeamMgr)

function PWorldTeamMgr:OnInit()
    self.Super.OnInit(self)
    self.MemberList = {}
    self.HasMemExited = false
    self.VoteGiveUpStamp = 0
    self.IsSupplementing = false
    self.VoteTimeDict = {}
    self.IsDuringVoteMVP = false
    self.MemVoteEnbaleDict = nil
    self.ExileMemID = nil
    self.PWorldQuestEnable = false
    self.bVotedMVP = false

    self.SceneTeamData = table.makeconst({})

	self.ChatChannelType = ChatDefine.ChatChannel.SceneTeam 

    self:SetLogName("PWorldTeamMgr")
end

function PWorldTeamMgr:OnBegin()
    PWorldTeamVM = require("Game/PWorld/Team/PWorldTeamVM")
    PWorldQuestVM = require("Game/PWorld/Quest/PWorldQuestVM")
    EventID = require("Define/EventID")

    self.Super.OnBegin(self)
    self:SetTeamVM(PWorldTeamVM)

    PWorldTeamVM.MatchMems:RegisterUpdateListCallback(self, self.OnMatchMemsUpdate)
end

function PWorldTeamMgr:OnEnd()
    if PWorldTeamVM then
        PWorldTeamVM.MatchMems:UnRegisterAddItemsCallback(self, self.OnMatchMemsUpdate)
    end
    self.Super.OnEnd(self)
end

function PWorldTeamMgr:OnShutdown()
    self.Super.OnShutdown(self)
end

function PWorldTeamMgr:OnRegisterNetMsg()
    self.Super.OnRegisterNetMsg(self)

    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_ADD_MEMBERS,                    self.OnMsgAddMemsStart)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_CANCEL_ADD_MEMBERS,             self.OnMsgAddMemsCancel)

    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_VOTE_START,                     self.OnMsgPWVoteStart)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_VOTE_REPLY,                     self.OnMsgPWVoteReply)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_VOTE_RESULT,                    self.OnMsgPWVoteRlt)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_VOTE_CANCEL,                    self.OnMsgPWVoteCancel)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_MVP_VOTE,                       self.OnMsgPWVoteMVP)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_MVP_INFO,                       self.OnMsgNtfPWVoteMVP)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_RELOGIN_DATA_RECOVER,           self.OnMsgVoteReloginRecover)

    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_QUERY_SCENE_MEMBER, self.OnMsgQuerySceneTeamMembers)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_SCENE_MEMBER_ENTER, self.OnSceneTeamMemberEnter)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_SCENE_MEMBER_LEAVE, self.OnSceneTeamMemberLeave)
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_SCENE_TEAM_MEMBER_STATUS, self.OnResvTeamMemberStatus)

    -- 语音
    self:RegisterGameNetMsg(CS_CMD_PWORLD, SUB_PWORLD_CMD.CS_PWORLD_CMD_SELF_DATA_NTF,                  self.OnMsgNtfVoiceSelfData)
end

function PWorldTeamMgr:OnRegisterGameEvent()
    self.Super.OnRegisterGameEvent(self)

    self:RegisterGameEvent(EventID.PWorldBegin, self.OnPWorldBegin)

    self:RegisterGameEvent(EventID.TeamIDUpdate, self.OnTeamIDChanged)
end

function PWorldTeamMgr:Reset()
    if _G.ReviveMgr then
        for _, RoleID in self:IterTeamMembers() do
            _G.ReviveMgr:MarkReviveByRoleID(RoleID)
        end
    end

    self:UpdateMemberData({})
    self:SetHasMemExited(false)
    self.VoteGiveUpStamp = 0
    self:SetSupplement(false)
    self.VoteTimeDict = {}
    self:SetExileMemID(nil)
    self:ResetVoteMvpInfo()
    self.SceneTeamData = table.makeconst({})
    self:SetTeamID(nil)
    self:SetCaptainByRoleID(nil)
    self:SetVotedMVP(false)
    self.bReconnPWorld = false
end

function PWorldTeamMgr:PWorldEnter()
    local MainPanelVM = require("Game/Main/MainPanelVM")
    local PCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
    MainPanelVM:SetOnPVPMap(PCfg and PCfg.CanPK == 1)

    if not _G.PWorldMgr:CurrIsInDungeon() then
        _G.EventMgr:SendEvent(_G.EventID.SceneTeamQueryFinish)
        return
    end

    self:ReqQuerySceneTeamData()
    _G.PWorldTeamVM:OnEnterMap()

    self:LogInfo("Hide PWorldMainlinePanel for enter pworld!")
    _G.UIViewMgr:HideView(_G.UIViewID.PWorldMainlinePanel)

    _G.TeamRecruitMgr:Clear(true)
end

function PWorldTeamMgr:OnGameEventPWorldMapEnter()
    self:CheckAndApplyMajorKick()
    self:CheckAndApplyGiveUp()
end

function PWorldTeamMgr:OnGameEventLoginRes(Params)
    self.bReconnPWorld = Params and Params.bReconnect and _G.PWorldMgr:CurrIsInDungeon()

    self:RegisterTimer(function()
        if self:IsInTeam() then
            self:ReqQueryVote()
        end
    end, 2, 1, 1, nil)

    if _G.PWorldMgr:CurrIsInDungeon() then
        self:ReqQuerySceneTeamData()
    end
end

local TeamTipsRecs = {}
function PWorldTeamMgr:OnPWorldBegin()
    -- tips
    if not self.bReconnPWorld and _G.PWorldMgr:CurrIsInDungeon() then
        if _G.PWorldMgr:CurrIsInDungeon() then
            local TipsID = nil
            local MsgTipsID = require("Define/MsgTipsID")
            if _G.PWorldMgr:GetMode() == ProtoCommon.SceneMode.SceneModeStory then
                TipsID = MsgTipsID.TeamMemberNum4
            elseif #(self.MemberList or {}) == 4 then
                TipsID = MsgTipsID.TeamMemberNum4
            elseif #(self.MemberList or {}) == 8 then
                TipsID = MsgTipsID.TeamMemberNum8
            end
            local PInstID = _G.PWorldMgr:GetCurrPWorldInstID()
            if PInstID and TipsID ~= nil and (TeamTipsRecs[PInstID] == nil or TeamTipsRecs[PInstID][TipsID] == nil) then
                TeamTipsRecs[PInstID] = TeamTipsRecs[PInstID] or {}
                TeamTipsRecs[PInstID][TipsID] = true
                MsgTipsUtil.ShowTipsByID(TipsID) 
            end
        end
    end

    self:ClearRemainTimeTips()
    if (SceneEnterCfg:FindCfgByKey(_G.PWorldMgr:GetCurrPWorldResID()) or {}).TypeID ~= ProtoCommon.ScenePoolType.ScenePoolMuRen then
        self.RemainTimeTipTimers = {}
        local RemainTime = _G.PWorldMgr.BaseInfo.EndTime - _G.TimeUtil.GetServerTime()
        for _, m in ipairs({10, 5, 1}) do
            local t = RemainTime - m * 60
            if t > 0 then
               table.insert(self.RemainTimeTipTimers, self:RegisterTimer(function (_, m)
                    MsgTipsUtil.ShowTips(PWorldHelper.pformat("HINT_PWORLD_REMAIN_TIME", m), nil, nil)
               end, t, 0, 1, m)) 
            end
        end
    end
end

---@private
function PWorldTeamMgr:OnGameEventPWorldExit()
    self.Super.OnGameEventPWorldExit(self)

    self:Reset()
    self:ClearRemainTimeTips()
end

---@private
function PWorldTeamMgr:ClearRemainTimeTips()
    for _, v in ipairs(self.RemainTimeTipTimers or {}) do
        self:UnRegisterTimer(v)
    end
    self.RemainTimeTipTimers = nil
end

function PWorldTeamMgr:OnTeamIDChanged(mgr)
    if mgr == self and self:IsInTeam() then
        self:ReqQueryVote()
    end
end

function PWorldTeamMgr:SetVotedMVP(V)
    self.bVotedMVP = V
end

-------------------------------------------------------------------------------------------------------
---@see NetMsgHandle
-- Pworld team resp
function PWorldTeamMgr:OnMsgPWVoteStart(MsgBody)
    local VoteStart = MsgBody.VoteStart
    if VoteStart then
        self:OnMsgVoteStartOrQueryInner(VoteStart.Type, VoteStart.Members, VoteStart.EndTime, 
            VoteStart.Param, VoteStart.SponsorRoleID)
        if SceneVoteTypeDef.SceneVoteKick == VoteStart.Type then
            _G.UIViewMgr:HideView(_G.UIViewID.PWorldVoteBest)
        end
    end
end

function PWorldTeamMgr:OnMsgVoteReloginRecover(MsgBody)
    local ReloginRecover = MsgBody.ReloginRecover
    if not ReloginRecover then
        return
    end
    local PWorldVote = ReloginRecover.PWorldVote
    if PWorldVote then
        self:OnMsgVoteStartOrQueryInner(PWorldVote.Type, PWorldVote.Members, PWorldVote.EndTime, 
        PWorldVote.Param, PWorldVote.SponsorRoleID)
    else
       self.VoteTimeDict = {} 
    end

    local PworldMVPVote = ReloginRecover.PworldMVPVote
    self:SetVotedMVP(PworldMVPVote and PworldMVPVote.Status == 1)
    if PworldMVPVote and  PworldMVPVote.Status == 0 then
        self:OnMsgVoteMVPOrQueryInner(PworldMVPVote.Candidates)
    end

    local PWorldAddMember = ReloginRecover.PWorldAddMember
    self:SetSupplement(PWorldAddMember ~= nil)
end

function PWorldTeamMgr:OnMsgQuerySceneTeamMembers(MsgBody)
    if not _G.PWorldMgr:CurrIsInDungeon() then
       self:LogErr("PWorldTeamMgr:OnMsgQuerySceneTeamMembers rev scene team data in non pworld!") 
       return
    end

    self.SceneTeamData = table.shallowcopy((MsgBody.QueryMembers or {}).Members or {}, true)
    table.makeconst(self.SceneTeamData)
    self:OnUpdateSceneTeamData()

    _G.EventMgr:SendEvent(_G.EventID.SceneTeamQueryFinish)
end

---@private
function PWorldTeamMgr:OnUpdateSceneTeamData()
    if TeamHelper.GetTeamMgr() == self then
        local CaptainID = nil
        local CaptainPriority = math.maxinteger
        local TeamID = nil
        for _, V in ipairs(self.SceneTeamData) do
            if V.CaptainPriority < CaptainPriority then
               CaptainID = V.RoleID 
               CaptainPriority = V.CaptainPriority
            end

            if V.RoleID == GetMajorID() and V.RoleID then
                TeamID = V.TeamID 
            end
        end

        self:SetTeamID(TeamID)
        self:UpdateMemberData(self.SceneTeamData)
        self:SetCaptainByRoleID(CaptainID, true)
        if self:IsInTeam() then
           self:ReqQueryVote() 
        end
    end

    _G.EventMgr:SendEvent(_G.EventID.TeamSceneTeamDataUpdate)
end

function PWorldTeamMgr:OnSceneTeamMemberEnter(MsgBody)
    if not _G.PWorldMgr:CurrIsInDungeon() then
        self:LogWarn("PWorldTeamMgr:OnSceneTeamMemberEnter rev scene team data in non pworld!") 
        return
    end

    local Member = (MsgBody.EnterScene or {}).Member
    if Member then
        setmetatable(self.SceneTeamData, nil) 
        local bFound = table.array_remove_item_pred(self.SceneTeamData, function (v)
            if v.Type == Member.Type then
                if v.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer then
                    return v.RoleID == Member.RoleID and Member.RoleID ~= nil
                else
                    return v.RoleID == Member.RoleID and v.EntityID == Member.EntityID
                end
            end
        end, 1)
        if bFound then
           self:LogWarn("found a duplicated member when adding, type: %s, role id: %s, entity id: %s", Member.Type, Member.RoleID, Member.EntityID) 
        end

        table.insert(self.SceneTeamData, table.shallowcopy(Member, true))
        table.makeconst(self.SceneTeamData)

        if not bFound and Member.IsMatchAdded then
            _G.RoleInfoMgr:QueryRoleSimple(Member.RoleID, function(_, VM)
                MsgTipsUtil.ShowTipsByID(103068, nil, VM.Name)
		    end, true)
        end
    end

    self:OnUpdateSceneTeamData()
end

function PWorldTeamMgr:OnSceneTeamMemberLeave(MsgBody)
    if not _G.PWorldMgr:CurrIsInDungeon() then
        self:LogErr("PWorldTeamMgr:OnSceneTeamMemberLeave rev scene team data in non pworld!") 
        return
    end

    local MemberLeaveData = MsgBody.LeaveScene
    if MemberLeaveData then
        setmetatable(self.SceneTeamData, nil) 
        local bRemoved = table.array_remove_item_pred(self.SceneTeamData, function (v)
            local bFound
            if v.Type == MemberLeaveData.Type then
               if v.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer then
                    bFound = v.RoleID == MemberLeaveData.ResID
               else
                    bFound = v.RoleID == MemberLeaveData.ResID and v.EntityID == MemberLeaveData.EntityID
               end
            end
            return bFound
        end, 1)
        if not bRemoved then
           self:LogErr("failded to remove a leave member") 
        end

        if bRemoved and MemberLeaveData.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer then
            _G.ReviveMgr:MarkReviveByEntityID(MemberLeaveData.EntityID)
        end
        table.makeconst(self.SceneTeamData)
    end

    self:OnUpdateSceneTeamData()
end

function PWorldTeamMgr:OnResvTeamMemberStatus(MsgBody)
    local Data = MsgBody.TeamMemberStatus
    if Data == nil then
        return
    end

    local RoleID = Data.RoleID
    if Data.Rescued then
        _G.EventMgr:SendEvent(EventID.OnRescureInfo, table.makeconst({
            RoleID = RoleID,
            RescueDeadline = Data.Rescued.EndTime,
        }))
    end

    if Data.DisplayTag and Data.DisplayTag.Tag then
        self:LogInfo("update online status, %s: %s", RoleID, Data.DisplayTag.Tag)
        self:InnerUpdateOnlineStatus(RoleID, Data.DisplayTag.Tag)
    end
end

function PWorldTeamMgr:OnMsgVoteStartOrQueryInner(VoteType, Members, EndTime, Param, SponRoleID)
    local Samples = {}
    for _, Mem in pairs(Members) do
        Samples[Mem.RoleID] = Mem.Status
    end
    self:ResetAllVoteOp(VoteType, Samples)
    self:SetVoteTime(VoteType, EndTime)
    local RemainTime = math.max((EndTime or 0) - TimeUtil.GetServerTime(), 0)
    local bShow = RemainTime > 0
    if VoteType == SceneVoteTypeDef.SceneVoteKick then
        if Param and Param ~= MajorUtil.GetMajorRoleID() then
            self:SetViewVisibleVoteExile(bShow)
            self:SetExileMemID(Param)
        end
    elseif VoteType == SceneVoteTypeDef.SceneVoteGiveup then
        self:SetViewVisibleVoteGiveUp(bShow)
    end

    if self.TimerIDVoteExpireMap == nil then
        self.TimerIDVoteExpireMap = {}
    end
    if RemainTime > 0 and VoteType then
        self:ClearVoteTimeoutTimer(VoteType)
        self.TimerIDVoteExpireMap[VoteType] = self:RegisterTimer(self.OnVoteTimeout, RemainTime, nil, nil, {VoteType=VoteType})
    end
end

---@private
function PWorldTeamMgr:ClearVoteTimeoutTimer(VoteType)
    if VoteType and self.TimerIDVoteExpireMap then
        if self.TimerIDVoteExpireMap[VoteType] then
            self:UnRegisterTimer(self.TimerIDVoteExpireMap[VoteType]) 
            self.TimerIDVoteExpireMap[VoteType] = nil
         end
    end
end

function PWorldTeamMgr:OnVoteTimeout(Param)
    local Type = Param.VoteType
    if Type == SceneVoteTypeDef.SceneVoteKick then
        self:SetViewVisibleVoteExile(false)
    elseif Type == SceneVoteTypeDef.SceneVoteGiveup then
        self:SetViewVisibleVoteGiveUp(false)
    end
end

function PWorldTeamMgr:OnMsgPWVoteReply(MsgBody)
    local VoteReply = MsgBody.VoteReply
    if VoteReply then
        local Type = VoteReply.Type
        local Mems = VoteReply.Members
        local Samples = {}
        for _, Mem in pairs(Mems) do
            Samples[Mem.RoleID] = Mem.Status
        end
        self:ResetAllVoteOp(Type, Samples)
    end
end

function PWorldTeamMgr:OnMsgPWVoteRlt(MsgBody)
    local VoteResult = MsgBody.VoteResult
    if VoteResult then
        local Type = VoteResult.Type
        local Param = VoteResult.Param
        local Succeed = VoteResult.Succeed
        if Type == SceneVoteTypeDef.SceneVoteKick then
            if Succeed then
                self:CheckAndRecordMajorKick(Param)
            end
            self:SetViewVisibleVoteExile(false)
            self:SetExileMemID(nil)
            if Param ~= MajorUtil.GetMajorRoleID() then
                self:ShowExileVoteRltView(Succeed, Param)
            end
        elseif Type == SceneVoteTypeDef.SceneVoteGiveup then
            if Succeed then
                self:CheckAndRecordGiveUp()
            end
            self:SetViewVisibleVoteGiveUp(false)
            self:ShowGiveUpVoteRltView(Succeed)
        end
        self:ClearVoteTimeoutTimer(Type)
        self:SetVoteTime(Type, nil)
    end
end

function PWorldTeamMgr:OnMsgPWVoteCancel(MsgBody)
    local VoteCancel = MsgBody.VoteCancel
    if VoteCancel then
        local Type = VoteCancel.Type
        local Reason = VoteCancel.Reason
        if Type == SceneVoteTypeDef.SceneVoteKick then
            self:SetExileMemID(nil)
            self:SetViewVisibleVoteExile(false)
            if Reason == 1 or Reason == 2 then
                _G.MsgTipsUtil.ShowTipsByID(103099)
            end
        elseif Type == SceneVoteTypeDef.SceneVoteGiveup then
            self:SetViewVisibleVoteGiveUp(false)
        end
        self:ClearVoteTimeoutTimer(Type)
        self:SetVoteTime(Type, nil)
    end
end

function PWorldTeamMgr:OnMsgPWVoteMVP(MsgBody)
    self:UpdateMajorMVPCounts()
    self:SetViewVisibleVoteMVP(false)
    _G.MsgTipsUtil.ShowTips(_G.LSTR(1300006))
end

function PWorldTeamMgr:OnMsgNtfPWVoteMVP(MsgBody)
    local MVPInfo = MsgBody.MVPInfo
    if MVPInfo then
        if not self.bVotedMVP then
            self:OnMsgVoteMVPOrQueryInner(MVPInfo.Candidates)
        end
        if MVPInfo.MVPRoleID == MajorUtil.GetMajorRoleID() then
            _G.ChatMgr:AddSysChatMsg(_G.LSTR(1300007))
        end
    end

    self:UpdateMajorMVPCounts()
end

function PWorldTeamMgr:UpdateMajorMVPCounts()
    MajorUtil.UpdMvpTimes()
end

function PWorldTeamMgr:OnMsgVoteMVPOrQueryInner(Candidates)
    self:SetVoteMvpInfo(Candidates)
end

function PWorldTeamMgr:OnMsgAddMemsStart()
    self:SetSupplement(true)
end

function PWorldTeamMgr:OnMsgAddMemsCancel()
    self:SetSupplement(false)
end

-------------------------------------------------------------------------------------------------------
---@see Request
function PWorldTeamMgr:ReqPWorld(SubCmd, Params)
    local MsgBody = Params
    MsgBody.Cmd = SubCmd
	GameNetworkMgr:SendMsg(CS_CMD_PWORLD, SubCmd, MsgBody)
end

-- Sub pworld vote req
function PWorldTeamMgr:ReqPWVoteMVP(RoleID)
    local Params = {
        MVPVote = {
            RoleID = RoleID,
        }
    }
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_MVP_VOTE, Params)
end

function PWorldTeamMgr:ReqPWVoteStartExile(RoleID)
    local Params = {
        VoteStart = {
            Type = SceneVoteTypeDef.SceneVoteKick,
            Param = RoleID,
        }
    }
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_VOTE_START, Params)
end

function PWorldTeamMgr:ReqPWVoteExile(Accept)
    local Params = {
        VoteReply = {
            Type = SceneVoteTypeDef.SceneVoteKick,
            Accept = Accept
        }
    }
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_VOTE_REPLY, Params)
end


function PWorldTeamMgr:ReqPWVoteStartGiveUp()
    local Params = {
        VoteStart = {
            Type = SceneVoteTypeDef.SceneVoteGiveup
        }
    }
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_VOTE_START, Params)
end

function PWorldTeamMgr:ReqPWVoteGiveUp(Accept)
    local Params = {
        VoteReply = {
            Type = SceneVoteTypeDef.SceneVoteGiveup,
            Accept = Accept
        }
    }
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_VOTE_REPLY, Params)
end

-- Sub pworld team req
function PWorldTeamMgr:ReqStartAddMem()
    local Params = {}
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_ADD_MEMBERS, Params)
end

function PWorldTeamMgr:ReqStopAddMem()
    local Params = {}
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_CANCEL_ADD_MEMBERS, Params)
end

function PWorldTeamMgr:ReqQuerySceneTeamData()
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_QUERY_SCENE_MEMBER, {})
end

function PWorldTeamMgr:ReqQueryVote()
    local Params = {
        ReloginRecover = {}
    }
    self:ReqPWorld(SUB_PWORLD_CMD.CS_PWORLD_CMD_RELOGIN_DATA_RECOVER, Params)
end

---@private
function PWorldTeamMgr:UpdateMemberData(InMemList)
    local NewList = {}
    local PWorldID = _G.PWorldMgr:GetCurrPWorldResID()
    local RequireCnt = PWorldEntUtil.GetRequireMemCnt(PWorldID)
    local CurCnt = #(self.MemberList or {})
    local NewMemCnt = #InMemList
    self:SetHasMemExited(RequireCnt > NewMemCnt)
    if  self.HasMemExited then
        PWorldQuestVM:UpdateSupplement()
        -- 少一个人触发 如 4->3
        if CurCnt > NewMemCnt and RequireCnt - NewMemCnt == 1 and self:IsCaptain() and _G.PWorldQuestVM.CanSupplement then
			_G.UIViewMgr:ShowView(_G.UIViewID.PWorldAddMember)
        end
    end

    for _, Mem in ipairs(InMemList) do
        local CacheItem = table.find_item(self.MemberList or {}, Mem.RoleID, "RoleID")
        local Data = self.SceneTeamMemberToProtoTeamMember(Mem)
        Data.VoteOpDict = CacheItem and CacheItem.VoteOpDict or {}  --#TODO PENDING DELETE
        if CacheItem and CacheItem.CliData then
           Data.CliData =  CacheItem.CliData
           if Data.CliData ~= Mem.CliData then
                self:LogInfo("not consistent CliData, raw: %s, cur: %s", Mem.CliData, Data.CliData)
           end
        end
        table.insert(NewList, Data)
    end

    self.HasFirstPass = false
    local Roles = {}
    for _, Mem in ipairs(NewList) do
        if Mem.IsFirstChange then
            self.HasFirstPass = true
        end
        table.insert(Roles, Mem.RoleID)
    end

    self.MemberList = NewList
	_G.RoleInfoMgr:QueryRoleSimples(Roles, function()
    end, nil, false)
    self:NtfUpdateMems()

    for _, Data in ipairs(NewList) do
        if Data.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer then
            if Data.DisplayTag then
                self:InnerUpdateOnlineStatus(Data.RoleID, Data.DisplayTag)
            else
                self:LogErr("rev a nil tag for role %s", Data.RoleID)
            end
        end
    end
end

function PWorldTeamMgr:NtfUpdateMems()
    PWorldTeamVM:UpdateVM()
    PWorldQuestVM:UpdateSupplement()
    _G.EventMgr:SendEvent(EventID.PWorldTeamMemUpd)
end

-- Member property
function PWorldTeamMgr:SetVoteOp(RoleID, Type, Op)
    local Mem = self:GetMem(RoleID, true)
    Mem.VoteOpDict[Type] = Op

    if Type == SceneVoteTypeDef.SceneVoteKick then
        PWorldTeamVM:UpdVoteExile()
    elseif Type == SceneVoteTypeDef.SceneVoteGiveup then
        PWorldTeamVM:UpdVoteGiveUp()
    end
end

function PWorldTeamMgr:ResetVoteOp(RoleID, Type)
    self:SetVoteOp(RoleID, Type, OpDef.Nil)
end

function PWorldTeamMgr:ResetAllVoteOp(Type, Samples)
    Samples = Samples or {}
    for _, Mem in pairs(self.MemberList) do
        Mem.VoteOpDict[Type] = Samples[Mem.RoleID] or OpDef.InValid
    end

    if Type == SceneVoteTypeDef.SceneVoteKick then
        PWorldTeamVM:UpdVoteExile()
    elseif Type == SceneVoteTypeDef.SceneVoteGiveup then
        PWorldTeamVM:UpdVoteGiveUp()
    end
end

function PWorldTeamMgr:SetHasMemExited(V)
    self.HasMemExited = V
    PWorldQuestVM:UpdateExit()
end

---@private
function PWorldTeamMgr:SetSupplement(V)
    self.IsSupplementing = V
    PWorldTeamVM:SetSupplement(V)
    PWorldQuestVM:UpdateSupplement()
end

---@private
function PWorldTeamMgr:SetVoteTime(Type, Time)
    if Type then
        self.VoteTimeDict[Type] = Time
    end
end

function PWorldTeamMgr:IsVoting()
    for _, ExpireTime in pairs(self.VoteTimeDict) do
        if ExpireTime and TimeUtil.GetServerTime() < ExpireTime then
           return true 
        end
    end
end

function PWorldTeamMgr:SetExileMemID(V)
    self.ExileMemID = V
    PWorldTeamVM:UpdExileMemName()
end

function PWorldTeamMgr:SetVoteMvpInfo(MemVoteEnbaleDict)
    if (not MemVoteEnbaleDict) or table.empty(MemVoteEnbaleDict) then
        return
    end

    self.MemVoteEnbaleDict = MemVoteEnbaleDict
    PWorldTeamVM:UpdVoteMVPEnbale()

    if not self.IsDuringVoteMVP and self:HasMatchMembers() then
        self:SetViewVisibleVoteMVP(true)
        self.IsDuringVoteMVP = true
    end
end

---@private
function PWorldTeamMgr:ResetVoteMvpInfo()
    self.IsDuringVoteMVP = nil
    self.MemVoteEnbaleDict = nil
    PWorldTeamVM:UpdVoteMVPEnbale()
    self:SetViewVisible(_G.UIViewID.PWorldVoteBest, false)
    _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.PWorldQuestMVP)
end

-------------------------------------------------------------------------------------------------------
---@see Public
-- Query member
function PWorldTeamMgr:GetMemIDList()
    local Ret = {}
    for _, RoleID in self:IterTeamMembers() do
        if RoleID then
           table.insert(Ret, RoleID) 
        end
    end
    return Ret
end

---@deprecated use IterTeamMembers instead
function PWorldTeamMgr:GetMemberList()
    return self.MemberList
end

---@deprecated #TODO PENDING DELETE
function PWorldTeamMgr:GetMems(IsRef, Pred)
    local Mems

    if Pred then
        Mems = table.find_all_by_predicate(self.MemberList, Pred)
    else
        Mems = self.MemberList
    end

    if IsRef or Pred ~= nil then
        return Mems
    end

    return table.deepcopy(Mems) or {}
end

function PWorldTeamMgr:GetMemCnt(Pred)
    return #(self:GetMems(true, Pred) or {})
end

function PWorldTeamMgr:GetMemGiveUpVoteCnt()
    return self:GetMemCnt(function(Item)
        return Item.VoteOpDict[SceneVoteTypeDef.SceneVoteGiveup] ~= OpDef.InValid
    end)
end

function PWorldTeamMgr:GetMemVoteGiveUpAcceptCnt()
    return self:GetMemCnt(function(Item)
        return Item.VoteOpDict[SceneVoteTypeDef.SceneVoteGiveup] == OpDef.Accept
    end)
end

function PWorldTeamMgr:GetMemVoteGiveUpRejectCnt()
    return self:GetMemCnt(function(Item)
        return Item.VoteOpDict[SceneVoteTypeDef.SceneVoteGiveup] == OpDef.Reject
    end)
end

function PWorldTeamMgr:GetMemExileVoteCnt()
    return self:GetMemCnt(function(Item)
        return Item.VoteOpDict[SceneVoteTypeDef.SceneVoteKick] ~= OpDef.InValid
    end)
end

function PWorldTeamMgr:GetMemVoteExileAcceptCnt()
    return self:GetMemCnt(function(Item)
        return Item.VoteOpDict[SceneVoteTypeDef.SceneVoteKick] == OpDef.Accept
    end)
end

function PWorldTeamMgr:GetMemVoteExileRejectCnt()
    return self:GetMemCnt(function(Item)
        return Item.VoteOpDict[SceneVoteTypeDef.SceneVoteKick] == OpDef.Reject
    end)
end

function PWorldTeamMgr:GetMemHasVoteGiveUpCnt()
    return self:GetMemCnt(function(Item)
        return Item.VoteOpDict[SceneVoteTypeDef.SceneVoteGiveup] ~= OpDef.Nil
    end)
end

function PWorldTeamMgr:GetMemHasVoteExileCnt()
    return self:GetMemCnt(function(Item)
        local Op = Item.VoteOpDict[SceneVoteTypeDef.SceneVoteKick]
        return Op == OpDef.Accept or Op == OpDef.Reject
    end)
end

function PWorldTeamMgr:GetMem(RoleID, IsRef)
    local Mems = self:GetMems(true) or {}
    local Info = table.find_item(Mems, RoleID, "RoleID")
    if not Info then
        return
    end

    if IsRef then
        return Info
    end

    return table.deepcopy(Info)
end

-- Member property
-- MVP候选人是不是已经离开 候选人状态: 0-可推荐（在线） 1-不可推荐（下线）
function PWorldTeamMgr:HasVoteMvpMemGone(RoleID)
    if self.IsDuringVoteMVP == true then
        if self.MemVoteEnbaleDict then
            return self.MemVoteEnbaleDict[RoleID] == 1
        end
    end

    return false
end

function PWorldTeamMgr:HasMemVoteGiveUp(RoleID)
    local Mem = self:GetMem(RoleID, true)
    if not Mem then
        return
    end

    return Mem.VoteOpDict[SceneVoteTypeDef.SceneVoteGiveup] == OpDef.Nil
end

function PWorldTeamMgr:HasAcceptVoteGiveUp(RoleID)
    local Mem = self:GetMem(RoleID, true)
    if not Mem then
        return
    end

    return Mem.VoteOpDict[SceneVoteTypeDef.SceneVoteGiveup] == OpDef.Accept
end

function PWorldTeamMgr:HasMemVoteExile(RoleID)
    local Mem = self:GetMem(RoleID, true)
    if not Mem then
        return
    end

    return Mem.VoteOpDict[SceneVoteTypeDef.SceneVoteKick] == OpDef.Nil
end

function PWorldTeamMgr:HasAcceptVoteExile(RoleID)
    local Mem = self:GetMem(RoleID, true)
    if not Mem then
        return
    end

    return Mem.VoteOpDict[SceneVoteTypeDef.SceneVoteKick] == OpDef.Accept
end

-- query major
function PWorldTeamMgr:GetMajorInfo(IsRef)
    local MajorID = GetMajorID()
    local Info = self:GetMem(MajorID, IsRef)
    return Info
end

function PWorldTeamMgr:HasMajorVoteGiveUp()
    local Info = self:GetMajorInfo()
    if not Info then
        return
    end
    return Info.VoteOpDict[SceneVoteTypeDef.SceneVoteGiveup] ~= OpDef.Nil
end

function PWorldTeamMgr:GetMajorVoteOpGiveUp()
    local Info = self:GetMajorInfo()
    if not Info then
        return
    end
    return Info.VoteOpDict[SceneVoteTypeDef.SceneVoteGiveup]
end

function PWorldTeamMgr:HasMajorVoteExile()
    local Info = self:GetMajorInfo()
    if not Info then
        return
    end
    return Info.VoteOpDict[SceneVoteTypeDef.SceneVoteKick] ~= OpDef.Nil
end

function PWorldTeamMgr:GetMajorVoteOpExile()
    local Info = self:GetMajorInfo()
    if not Info then
        return
    end
    return Info.VoteOpDict[SceneVoteTypeDef.SceneVoteKick]
end

-- View Visible
function PWorldTeamMgr:SetViewVisible(ViewID, IsVisible, Params)
    if IsVisible then
        _G.UIViewMgr:ShowView(ViewID, Params or {})
    else
        _G.UIViewMgr:HideView(ViewID, Params or {})
    end
end

function PWorldTeamMgr:SetViewVisibleVoteGiveUp(IsVisible)
	self:SetViewVisible(_G.UIViewID.SidebarGiveUpTaskWin, IsVisible, {ShowType = TeamDefine.VoteType.TASK_GIVEUP})
    self:SetSideBar(SidebarDefine.SidebarType.PWorldQuestGiveUp, IsVisible, _G.TimeUtil.GetLocalTime(), self:GetVoteGiveupRemainTime(), nil, false)
end

function PWorldTeamMgr:SetViewVisibleVoteExile(IsVisible)
    self:SetViewVisible(_G.UIViewID.SidebarGiveUpTaskWin, IsVisible, {ShowType = TeamDefine.VoteType.EXPEL_PLAYER})
    self:SetSideBar(SidebarDefine.SidebarType.PWorldQuestKick, IsVisible, _G.TimeUtil.GetLocalTime(), self:GetVoteExpelRemainTime(), nil, false)
end

---@deprecated PENDING DELETE
function PWorldTeamMgr:SetViewVisibleVoteMVP(IsVisible)
    self:SetViewVisible(_G.UIViewID.PWorldVoteBest, IsVisible, {ShowType = TeamDefine.VoteType.BEST_PLAYER})
    self:SetSideBar(SidebarDefine.SidebarType.PWorldQuestMVP, IsVisible, nil, nil, nil, false)
end

---@deprecated
---@private
function PWorldTeamMgr:SetSideBar(Ty, IsShow, StartTime, CD, Params, TryOpenSidebar)
    local SidebarMgr = _G.SidebarMgr
    local IsExist = SidebarMgr:GetSidebarItemVM(Ty) ~= nil
    if IsShow then
        if IsExist then
            return
        end

        SidebarMgr:AddSidebarItem(Ty, StartTime, CD, Params, TryOpenSidebar)
    else
        if not IsExist then
            return
        end
 
        SidebarMgr:RemoveSidebarItem(Ty)
    end
end

function PWorldTeamMgr:ShowExileVoteRltView(Succ, Param)
    local AcceptCnt = self:GetMemVoteExileAcceptCnt()
    local AgainstCnt = self:GetMemVoteExileRejectCnt()
    local Params = {
		AcceptCnt = AcceptCnt,
		AgainstCnt = AgainstCnt,
		Succ = Succ,
		Param1 = Param,
	}

    _G.UIViewMgr:ShowView(_G.UIViewID.PWorldVoteExpelResult, Params)
end

function PWorldTeamMgr:ShowGiveUpVoteRltView(Succ)
    local AcceptCnt = self:GetMemVoteGiveUpAcceptCnt()
    local AgainstCnt = self:GetMemVoteGiveUpRejectCnt()

    local Params = {
		AcceptCnt = AcceptCnt,
		AgainstCnt = AgainstCnt,
		-- MajorAccept = MajorAccept,
		Succ = Succ,
	}
    _G.UIViewMgr:ShowView(_G.UIViewID.PWorldVoteExpelResult, Params)
end

function PWorldTeamMgr:GetVoteExpireTime(VoteType)
    return self.VoteTimeDict[VoteType] or 0
end

---@return UIView | nil
local function GetVisibleVoteView()
    return  _G.UIViewMgr:FindVisibleView(_G.UIViewID.PWorldVoteBest)
end

local function IsVoteViewVisible(VoteType)
    local VoteView =  GetVisibleVoteView()
    return VoteView and VoteView.Params and VoteView.Params.ShowType == VoteType and VoteType ~= nil
end

local function IsVoteBestViewVisible()
    return IsVoteViewVisible(TeamDefine.VoteType.BEST_PLAYER)
end

local function IsVoteExpelViewVisible()
    return IsVoteViewVisible(TeamDefine.VoteType.EXPEL_PLAYER)
end

function PWorldTeamMgr:OnMatchMemsUpdate()
    if not self:HasMatchMembers() then
        _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.PWorldQuestKick)
        _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.PWorldQuestMVP)
    end

    if not self:HasMatchMembers() and (IsVoteExpelViewVisible() or IsVoteBestViewVisible())  then
        if self.TimerIDHideExpelView then
           self:UnRegisterTimer(self.TimerIDHideExpelView) 
        end
        self.TimerIDHideExpelView = self:RegisterTimer(function ()
            if not self:HasMatchMembers() and (IsVoteExpelViewVisible() or IsVoteBestViewVisible()) then
                self:SetViewVisible(_G.UIViewID.PWorldVoteBest, false, nil)
                _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.PWorldQuestKick)
                _G.SidebarMgr:RemoveSidebarItem(SidebarDefine.SidebarType.PWorldQuestMVP)
            end
        end, 0.01, nil, nil, nil)
    end
end

function PWorldTeamMgr:GetVoteRemainTime(VoteType)
    local t = self:GetVoteExpireTime(VoteType) - _G.TimeUtil.GetServerTime()
    return t > 0 and t or 0
end

function PWorldTeamMgr:GetVoteExpelRemainTime()
    return self:GetVoteRemainTime(require("Protocol/ProtoCommon").SceneVoteType.SceneVoteKick)
end

function PWorldTeamMgr:GetVoteGiveupRemainTime()
    return self:GetVoteRemainTime(require("Protocol/ProtoCommon").SceneVoteType.SceneVoteGiveup)     
end

function PWorldTeamMgr:HasMatchMembers()
    return _G.PWorldTeamVM and _G.PWorldTeamVM.MatchMems:Length() > 0
end
-------------------------------------------------------------------------------------------------------
---@see 初见

function PWorldTeamMgr:HasFirstPassMem()
    return self.HasFirstPass
end

function PWorldTeamMgr:HasAddedMember()
    for _, v in ipairs(self.SceneTeamData or {}) do
        if v.IsMatchAdded then
           return true 
        end
    end

    return false
end

-------------------------------------------------------------------------------------------------------
---@see 语音

function PWorldTeamMgr:OnMsgNtfVoiceSelfData( MsgBody )
	local Msg = MsgBody.SelfDataNtf
	if nil == Msg then
		return
	end

    local Mem = {
        RoleID = Msg.RoleID,
        CliData = Msg.Data,
    }

	self:OnMemDataNtf(Mem)
end

-- override
function PWorldTeamMgr:SendSelfTeamData( Data )
	local MsgID = CS_CMD_PWORLD
	local SubMsgID = SUB_PWORLD_CMD.CS_PWORLD_CMD_SET_SELF_DATA

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.SelfData = { Data = Data }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function PWorldTeamMgr:GetTeamVoiceRoomNameToJoin()
    if self:IsInTeam() then
        return string.format("P-%s", tostring(self:GetTeamID()))
    end
end


-------------------------------------------------------------------------------------------------------
---@region 玩家被踢提示

function PWorldTeamMgr:CheckAndRecordMajorKick(KickRoleID)
    if KickRoleID == GetMajorID() then
        self.KickFlag = true
    end
end

function PWorldTeamMgr:CheckAndApplyMajorKick()
    if not _G.PWorldMgr:CurrIsInDungeon() then

        if self.KickFlag then
            self.KickFlag = nil
            _G.MsgBoxUtil.ShowMsgBoxOneOpRight(self, _G.LSTR(1300002), _G.LSTR(1300008), nil, _G.LSTR(1300010))
        end
    end
end

function PWorldTeamMgr:CheckAndRecordGiveUp()
    self.GiveUpFlag = true
end

function PWorldTeamMgr:CheckAndApplyGiveUp()
    if not _G.PWorldMgr:CurrIsInDungeon() then
        if self.GiveUpFlag then
            self.GiveUpFlag = nil
            _G.MsgBoxUtil.ShowMsgBoxOneOpRight(self, _G.LSTR(1300002), _G.LSTR(1300009), nil, _G.LSTR(1300010))
        end
    end
end

function PWorldTeamMgr:GetTeamMemberProf(RoleID)
	if RoleID == MajorUtil.GetMajorRoleID() then
		return MajorUtil.GetMajorProfID()
	end

    if not self:IsInTeam() then
        return
    end

    for _, v in ipairs(self.SceneTeamData or {}) do
        if v.RoleID == RoleID and v.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer then
            return v.Info and v.Info.ProfID or 0
        end
    end
end

function PWorldTeamMgr:GetTeamMemberLevel(RoleID)
	if RoleID == MajorUtil.GetMajorRoleID() then
		return MajorUtil.GetMajorLevel()
	end

	if not self:IsInTeam() then
        return
    end

    for _, v in ipairs(self.SceneTeamData or {}) do
        if v.RoleID == RoleID and v.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer then
            return v.Info and v.Info.Level or 0
        end
    end
end

return PWorldTeamMgr
