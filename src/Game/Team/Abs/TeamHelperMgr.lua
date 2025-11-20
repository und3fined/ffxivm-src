local LuaClass = require("Core/LuaClass")
local LogableMgr = require("Common/LogableMgr")
local ProtoCS = require("Protocol/ProtoCS")
local TeamHelper = require("Game/Team/TeamHelper")
local MajorUtil = require("Utils/MajorUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local MainPanelVM = require("Game/Main/MainPanelVM")
local ActorUtil = require("Utils/ActorUtil")
local TeamGlobalCfg = require("TableCfg/TeamGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SceneParamsCfg = require("TableCfg/SceneParamsCfg")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local AudioUtil = require("Utils/AudioUtil")

local CS_CMD <const> = ProtoCS.CS_CMD
local SUB_MSG_ID_TEAM = ProtoCS.Team.Team.CS_SUBMSGID_TEAM
local TeamMemberDataQueryType <const> = ProtoCS.Team.Team.TeamMemberDataQueryType
local SidebarTypeTeamReadyConfirm <const> = SidebarDefine.SidebarType.TeamReadyConfirm
local TeamReadyTickAudioPath <const> = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_CFTimeCount.Play_SE_UI_SE_UI_CFTimeCount'"


---@class TeamHelperMgr: LogableMgr
local TeamHelperMgr = LuaClass(LogableMgr)

function TeamHelperMgr:OnInit()
    self:SetLogName("TeamHelperMgr")
end

function TeamHelperMgr:OnBegin()
    self.Super.OnBegin(self)

    local TeamReadyTimeoutSecs
    local TGCfg = TeamGlobalCfg:FindCfgByKey(ProtoRes.team_global_cfg_id.TEAM_CFG_READY_TIMEOUT)
    if TGCfg and TGCfg.Value then
        TeamReadyTimeoutSecs = TGCfg.Value[1]
    end

    self.TeamReadyTimeoutSecs = TeamReadyTimeoutSecs or 30
    self:LogInfo("TeamHelperMgr:Begin init TeamReadyTimeoutSecs %s", self.TeamReadyTimeoutSecs)

    local PWorldTeamReadyTimeoutSecs
    local SPCfg = SceneParamsCfg:FindCfgByKey(ProtoRes.Scene.ParameterID.ParameterIDTeamReadyTimeout)
    if SPCfg and SPCfg.Values then
        PWorldTeamReadyTimeoutSecs = SPCfg.Values[1]
    end
    self.PWorldTeamReadyTimeoutSecs = PWorldTeamReadyTimeoutSecs or 30
    self:LogInfo("TeamHelperMgr:Begin init PWorldTeamReadyTimeoutSecs %s", self.PWorldTeamReadyTimeoutSecs)
end

function TeamHelperMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID_TEAM.CsQueryTeamMemberData, self.OnNetMsgTeamMemberData)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID_TEAM.CSSubCmdTeamReady, self.OnNetMsgTeamReady)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID_TEAM.CSSubCmdTeamReadyVoteNotify, self.OnNetMsgTeamReadyVoteNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID_TEAM.CSSubCmdTeamReadyVote, self.OnNetMsgTeamReadyVote)

    -- pworld 
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_TEAM_READY_VOTE_NTF, self.OnNetMsgTeamReadyPWorldVoteNotify)
end

function TeamHelperMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.TeamUpdateMember, self.OnTeamVMUpdate)
    self:RegisterGameEvent(_G.EventID.SidebarExpandOpen, self.OnSidebarExpandOpen)
    self:RegisterGameEvent(_G.EventID.TeamDestroy, self.OnTeamDestroy)
    self:RegisterGameEvent(EventID.PWorldEnterNotify, self.OnPWorldEnter)
end

local function GetTeamMemberQueryKey(TeamID, Type)
    return string.sformat("%s-%s", TeamID, Type)
end

---@param TeamID number
---@param Type number
---@param Data any
---@param Callback function | nil
---@param Timeout number | nil if nil default 5 secs
---@param TimeoutCallback function | nil
function TeamHelperMgr:QueryTeamMemberData(TeamID, Type, Data, Callback, Timeout, TimeoutCallback)
    if TeamID == nil or TeamID == 0 then
        return
    end

    local MsgBody = {
        SubCmd = SUB_MSG_ID_TEAM.CsQueryTeamMemberData,
        TeamID = TeamID,
        TeamMemData = {
            TeamID = TeamID,
            QueryType = Type,
        }
    }
    if Type == TeamMemberDataQueryType.TeamMemberDataQueryTypeCounter then
        MsgBody.TeamMemData.CounterIDs = Data
    end
        
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID_TEAM.CsQueryTeamMemberData, MsgBody)

    if type(Callback) ~= 'function' then
       return 
    end

    if self.CallbackTimerIds == nil then
       self.CallbackTimerIds = {} 
    end

    self:RemoveTeamMemberQueryCallback(TeamID, Type)
    local TimeoutTimerID = self:RegisterTimer(function()
        self:LogErr("time out for QueryTeamMemberData, team id: %s, type %s", TeamID, Type)
        self:RemoveTeamMemberQueryCallback(TeamID, Type)
        if TimeoutCallback then
           TimeoutCallback(TeamID, Type) 
        end
    end, Timeout or 5)

    self.CallbackTimerIds[GetTeamMemberQueryKey(TeamID, Type)] = {
        TimerID = TimeoutTimerID,
        Callback = Callback
    }
end

function TeamHelperMgr:TryConfirmReady()
    if _G.SignsMgr.IsDuringCountDown then
        _G.MsgTipsUtil.ShowTipsByID(103122)
        return
	end

    if self:IsTeamReadyConfirming() then
        _G.MsgTipsUtil.ShowTipsByID(103121)
        return
    end

	if ActorUtil.IsCombatState(MajorUtil.GetMajorEntityID()) then
        _G.MsgTipsUtil.ShowTipsByID(103114)
        return
    end

    if self.LastConfirmTeamReadyTime and os.time() - self.LastConfirmTeamReadyTime <= 5 then
        _G.MsgTipsUtil.ShowTipsByID(103120)
        return
    end

    local Mgr = TeamHelper.GetTeamMgr()
    if not Mgr:IsInTeam() or Mgr:GetTeamMemberCount() < 2 then
        _G.MsgTipsUtil.ShowTipsByID(101106)
       return 
    end

    _G.MsgBoxUtil.ShowMsgBoxTwoOp(
			nil, 
			_G.LSTR(1300087), 	
			_G.LSTR(1300088),	
			function()
				self.PendingTeamReadyTeamID = TeamHelper:GetTeamMgr():GetTeamID()
                if _G.PWorldMgr:CurrIsInDungeon() then
                    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_TEAM_READY, {
                        Cmd = ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_TEAM_READY,
                        PWorldInstID = _G.PWorldMgr:GetCurrPWorldInstID()
                    })
                else
                    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID_TEAM.CSSubCmdTeamReady, {
                        SubCmd = SUB_MSG_ID_TEAM.CSSubCmdTeamReady,
                        TeamID = self.PendingTeamReadyTeamID,
                        Ready = {}
                    })
                end
			end,
			nil,
			_G.LSTR(1300090),	
			_G.LSTR(1300091)
	)
end

function TeamHelperMgr:SetEnableTeamReady(bEnable)
    self.bEnableTeamReady = bEnable
end

function TeamHelperMgr:IsEnableTeamReady()
    return self.bEnableTeamReady
end

---@param Mgr ATeamMgr
function TeamHelperMgr:ConfirmReadyOK(Mgr)
    if Mgr and Mgr:GetTeamID() == self.TeamReadyTeamID then
        if Mgr == _G.TeamMgr then
            self:ConfirmNormalTeamReady(ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusReady)
        else
            self:ConfirmPWorldTeamReady(ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusReady)
        end
    end
end

---@param Mgr ATeamMgr
function TeamHelperMgr:ConfirmReadyCancel(Mgr)
    if Mgr and Mgr:GetTeamID() == self.TeamReadyTeamID then
        if Mgr == _G.TeamMgr then
            self:ConfirmNormalTeamReady(ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusWait)
        else
            self:ConfirmPWorldTeamReady(ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusWait)
        end
    end
end

function TeamHelperMgr:IsTeamReadyConfirming()
    return self.TeamReadyTeamID ~= nil and self.TeamReadyTeamID == TeamHelper:GetTeamMgr():GetTeamID() and self.TeamReadyVoteFinish ~= true
end

function TeamHelperMgr:IsMajorTeamReadyConfirmed()
    local MajorReadyVoteStatus = self:GetTeamReadyVoteStatus(MajorUtil.GetMajorRoleID())
    return MajorReadyVoteStatus == ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusReady or MajorReadyVoteStatus == ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusWait
end

function TeamHelperMgr:IsTeamReadyVoteFinished()
    return self.TeamReadyTeamID ~= nil and self.TeamReadyVoteFinish
end

function TeamHelperMgr:SetTeamReadyVoteFinish(Value)
    local bChanged =  self.TeamReadyVoteFinish ~= Value
    self.TeamReadyVoteFinish = Value
    if Value then
       self:ClearTeamReadyAudioTimer() 
    end

    if bChanged and Value then
        EventMgr:SendEvent(EventID.TeamReadyConfirmFinish, self.TeamReadyTeamID)
        self.LastConfirmTeamReadyTime = os.time()
        local TeamVM = TeamHelper:GetTeamMgr().TeamVM
        if TeamVM then
            TeamVM:SetMajorConfirmTeamReady(true)
            local Count, Total, OKCount = TeamVM:GetTeamReadyConfirmTuple()
            if Total > 0 and OKCount == Total then
                _G.MsgTipsUtil.ShowTipsByID(103118)
                _G.UIViewMgr:HideView(_G.UIViewID.TeamReadyConfirm)
                SidebarMgr:RemoveSidebarItem(SidebarTypeTeamReadyConfirm)
            else
                local SidebarItem = SidebarMgr:GetSidebarItemVM(SidebarTypeTeamReadyConfirm)
                if SidebarItem then
                    SidebarItem.StartTime = 0
                end
                _G.MsgTipsUtil.ShowTipsByID(103119, nil, string.sformat("%d/%d", OKCount, Total), string.sformat("%d/%d", Total - OKCount, Total))
            end
        end
    end
end

function TeamHelperMgr:GetTeamReadyConfirmTimeoutInterval()
    if _G.PWorldMgr:CurrIsInDungeon() then
        return self.PWorldTeamReadyTimeoutSecs or 30
    else
        return self.TeamReadyTimeoutSecs or 30
    end
end

function TeamHelperMgr:GetTeamReadyConfirmTimeoutSeconds()
    return (self.TeamReadyStartTime or 0) + self:GetTeamReadyConfirmTimeoutInterval() - _G.TimeUtil.GetServerTime()
end

function TeamHelperMgr:GetTeamReadyConfirmStartTime()
    return self.TeamReadyStartTime or 0
end

---@private
function TeamHelperMgr:ConfirmNormalTeamReady(Status)
    if not self:IsTeamReadyConfirming() then
        self:LogWarn("ConfirmTeamReady: not in team ready confirming state")
        return
    end

    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID_TEAM.CSSubCmdTeamReadyVote, {
        SubCmd = SUB_MSG_ID_TEAM.CSSubCmdTeamReadyVote,
        TeamID =    self.TeamReadyTeamID,
        ReadyVote =  {Status=Status},
    })

end

---@private
function TeamHelperMgr:ConfirmPWorldTeamReady(Status)
    if not self:IsTeamReadyConfirming() then
        self:LogWarn("ConfirmTeamReady: not in team ready confirming state")
        return
    end

    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_TEAM_READY_VOTE, {
        Cmd = ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_TEAM_READY_VOTE,
        PWorldInstID = _G.PWorldMgr:GetCurrPWorldInstID(),
        ReadyVote =  {Status=Status},
    })
end

---@private
function TeamHelperMgr:OnNetMsgTeamMemberData(MsgBody)
    local TeamMemData = MsgBody.TeamMemData

    if TeamMemData == nil then
        self:LogErr("TeamHelperMgr:OnNetMsgTeamMemberData get nil data")
       return 
    end

    local Data = self:RemoveTeamMemberQueryCallback(TeamMemData.TeamID, TeamMemData.QueryType)
    if Data then
       Data.Callback(TeamMemData) 
    end
end

---@private
function TeamHelperMgr:RemoveTeamMemberQueryCallback(TeamID, Type)
    if self.CallbackTimerIds == nil then
        return
    end

    local Key = GetTeamMemberQueryKey(TeamID, Type)
    local Data = self.CallbackTimerIds[Key]
    if Data ~= nil then
       self:UnRegisterTimer(Data.TimerID)
    end
    self.CallbackTimerIds[Key] = nil

    return Data
end

---@private
function TeamHelperMgr:OnNetMsgTeamReady(MsgBody)
end

---@private
function TeamHelperMgr:OnNetMsgTeamReadyVoteNotify(MsgBody)
    local ReadyVoteNtf = MsgBody.ReadyVoteNtf

    if ReadyVoteNtf == nil then
       return 
    end

    local TeamMgr = TeamHelper:GetTeamMgr()
    local TeamID = MsgBody.TeamID
    if not TeamMgr:IsInTeam() or TeamMgr:GetTeamID() ~= TeamID then
        self:LogWarn("OnNetMsgTeamReadyVoteNotify: team id not match, local team id: %s, msg team id: %s, local is team %s", TeamMgr:GetTeamID(), TeamID, TeamMgr:IsInTeam())
        return
    end

    self:HandleTeamReadyConfirm(ReadyVoteNtf.VoteData.RoleID, ReadyVoteNtf.VoteData, TeamMgr)

    local View = UIViewMgr:FindVisibleView(_G.UIViewID.CommonMsgBox)
    if View and View.Params and View.Params.Message == _G.LSTR(1300088) then
        UIViewMgr:HideView(_G.UIViewID.CommonMsgBox)
    end
end

---@param VoteStartRoleID any
---@param VoteData table
---@param TeamMgr ATeamMgr
function TeamHelperMgr:HandleTeamReadyConfirm(VoteStartRoleID, VoteData, TeamMgr)
    if VoteStartRoleID == nil or VoteData == nil or TeamMgr == nil then
       return 
    end

    local OldVoteCount = self.TeamReadyVotes and #(self.TeamReadyVotes) or 0
    local TeamVM = TeamMgr.TeamVM
    local TeamID = TeamMgr:GetTeamID()
    if TeamID ~= self.TeamReadyTeamID then
       OldVoteCount = 0 
    end

    -- if a timeout confirm
    if  self.TeamReadyTeamID ~= TeamID then
        if VoteData.IsEnd or (VoteData.StartTime + self:GetTeamReadyConfirmTimeoutInterval() - _G.TimeUtil.GetServerTime()) <= 0 then
            return
        end
    end

    self.TeamReadyTeamID = TeamID
    if self.TeamReadyStartTime ~= VoteData.StartTime then
       OldVoteCount = 0 
    end
    self.TeamReadyStartTime = VoteData.StartTime
    self.TeamReadyVotes = VoteData.Votes
    local bVoteFinished = VoteData.IsEnd
    self.VoteStartRoleID = VoteStartRoleID

    for _, VM in ipairs(TeamVM:GetTeamMemberVMs()) do
        TeamVM:SetConfirmState(VM.RoleID, self:GetTeamReadyVoteStatus(VM.RoleID))
    end
    local MajorReadyVoteStatus = self:GetTeamReadyVoteStatus(MajorUtil.GetMajorRoleID())
    TeamVM:SetMajorConfirmTeamReady(MajorReadyVoteStatus == ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusReady or MajorReadyVoteStatus == ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusWait)
    local SidebarItem = SidebarMgr:GetSidebarItemVM(SidebarTypeTeamReadyConfirm)
    local function GetSidebarTips()
        return _G.LSTR(self:IsMajorTeamReadyConfirmed() and 1300100 or 1300099)
    end
    if SidebarItem then
        SidebarItem:SetTips(GetSidebarTips())
        SidebarItem:SetStartTime(self.TeamReadyStartTime)
    end
    
    if self.TimerIDTimeoutTeamReady then
        self:UnRegisterTimer(self.TimerIDTimeoutTeamReady)
        self.TimerIDTimeoutTeamReady = nil
    end
    local ValidVoteSecs = self:GetTeamReadyConfirmTimeoutInterval()
    local TimeoutSecs <const>  = self.TeamReadyStartTime + ValidVoteSecs - _G.TimeUtil.GetServerTime()
    if TimeoutSecs > 0 then
       self.TimerIDTimeoutTeamReady = self:RegisterTimer(function(_, Param)
            if self.TeamReadyTeamID == Param.TeamID and self.TeamReadyStartTime == Param.StartTime then
                self:LogInfo("OnNetMsgTeamReadyVoteNotify: team ready vote timeout, team id: %s", Param.TeamID)
                self:SetTeamReadyVoteFinish(true)
                local SidebarItem = SidebarMgr:GetSidebarItemVM(SidebarTypeTeamReadyConfirm)
                if SidebarItem then
                    local TeamVM = SidebarItem.TransData and SidebarItem.TransData.TeamVM or nil
                    local bFlag = true
                    if TeamVM and TeamVM.IsTeam then
                        local Count, Total = TeamVM:GetTeamReadyConfirmTuple()
                        if Count ~= Total then
                            bFlag = false
                        end
                    end
                    if bFlag then
                       SidebarMgr:RemoveSidebarItem(SidebarTypeTeamReadyConfirm) 
                    else
                        SidebarItem:SetTips(_G.LSTR(1300100))
                    end
                end
                MainPanelVM:SetTeamReadyConfirming(false)
                self:ClearTeamReadyAudioTimer()
            end
        end, TimeoutSecs, nil, nil, {TeamID = TeamID, StartTime=self.TeamReadyStartTime}) 
        self:ClearTeamReadyAudioTimer()
        self.TeamReayAudioTickTimerID = self:RegisterTimer(function()
            AudioUtil.LoadAndPlayUISound(TeamReadyTickAudioPath)
        end, 0.1, 1, 0)
    end

    if TimeoutSecs <= 0 then
        bVoteFinished = true
    end

    local Count, Total = TeamVM:GetTeamReadyConfirmTuple()
    if Count == Total and Total > 0 then
        bVoteFinished = true
    end

    self:SetTeamReadyVoteFinish(bVoteFinished)
    MainPanelVM:SetTeamReadyConfirming(self:IsTeamReadyConfirming())
    TeamVM:SetTeamConfirmReadyTime(self.TeamReadyStartTime)
    if not self:IsTeamReadyConfirming() then
        self:ClearTeamReadyAudioTimer()
    end

    if VoteData.IsEnd then
        self:LogInfo("OnNetMsgTeamReadyVoteNotify: team ready vote finished, team id: %s, start role id: %s", TeamID, VoteStartRoleID)
        return
    end

    if not bVoteFinished and self.TeamReadyVotes and OldVoteCount == 0 and #(self.TeamReadyVotes) == 1 then
        _G.RoleInfoMgr:QueryRoleSimple(VoteStartRoleID, function(InRoleID, VM)
            if InRoleID == self.VoteStartRoleID then
                _G.MsgTipsUtil.ShowTipsByID(103116, nil, VM.Name)
            end
        end, VoteStartRoleID, true)
    end

    if TimeoutSecs <= 0 then
        return
    end

    if SidebarItem ~= nil then
       SidebarMgr:TryOpenSidebarMainWin() 
    end

    if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.TeamReadyConfirm)  and SidebarItem == nil then
        SidebarMgr:RemoveSidebarItem(SidebarTypeTeamReadyConfirm)
        _G.UIViewMgr:ShowView(_G.UIViewID.TeamReadyConfirm, {TeamVM=TeamVM, TimeoutSecs=TimeoutSecs})
    end
end

---@private
function TeamHelperMgr:OnNetMsgTeamReadyVote(MsgBody)
end

---@private
function TeamHelperMgr:OnNetMsgTeamReadyPWorldVoteNotify(MsgBody)
    if not _G.PWorldMgr:CurrIsInDungeon() then
        self:LogWarn("TeamHelperMgr:OnNetMsgTeamReadyPWorldVoteNotify not in pworld")
       return 
    end

    local Notify = MsgBody.ReadyVoteNtf
    local PWorldInstID = MsgBody.PWorldInstID

    if Notify == nil then
       return 
    end

    if PWorldInstID ~= _G.PWorldMgr:GetCurrPWorldInstID() then
        self:LogErr("TeamHelperMgr:OnNetMsgTeamReadyPWorldVoteNotify mismatch pworld inst id %s %s", PWorldInstID, _G.PWorldMgr:GetCurrPWorldInstID())
        return
    end

    local VoteData = Notify.VoteData
    local RoleID = VoteData.RoleID
    self:HandleTeamReadyConfirm(RoleID, VoteData, TeamHelper:GetTeamMgr())
end

---@private
function TeamHelperMgr:GetTeamReadyVoteStatus(RoleID)
    if self.TeamReadyVotes == nil or RoleID == nil then
        return
    end

    for _, Vote in ipairs(self.TeamReadyVotes) do
        if Vote.RoleID == RoleID then
            return Vote.Status
        end
    end
end

function TeamHelperMgr:OnTeamVMUpdate(TeamVM)
    if not TeamVM then
        return
    end

    local TeamID
    if TeamVM:GetOwnerMgr() then
       TeamID = TeamVM:GetOwnerMgr():GetTeamID() 
    end
    if self.TeamReadyTeamID and TeamID == self.TeamReadyTeamID then
        for _, VM in ipairs(TeamVM:GetTeamMemberVMs()) do
            TeamVM:SetConfirmState(VM.RoleID, self:GetTeamReadyVoteStatus(VM.RoleID))
        end
        TeamVM:SetMajorConfirmTeamReady(self:IsMajorTeamReadyConfirmed() or self:GetTeamReadyConfirmTimeoutSeconds() <= 0)
        local Cur, Total = TeamVM:GetTeamReadyConfirmTuple()
        if Cur > 0 and Cur == Total then
            self:SetTeamReadyVoteFinish(true)
        end
    end
end

function TeamHelperMgr:OnSidebarExpandOpen(VM)
    local SidebarType = VM.Type
    if SidebarType == SidebarTypeTeamReadyConfirm then
        local Mgr = TeamHelper:GetTeamMgr()
        if Mgr and Mgr:IsInTeam() and Mgr:GetTeamID() == self.TeamReadyTeamID then
            SidebarMgr:RemoveSidebarItem(SidebarTypeTeamReadyConfirm)
            if VM.TransData.TeamVM == Mgr.TeamVM then
                 _G.UIViewMgr:ShowView(_G.UIViewID.TeamReadyConfirm, {TeamVM = Mgr.TeamVM})
            end
        end
    end
end

function TeamHelperMgr:OnTeamDestroy(TeamID)
    if TeamID == nil or self.TeamReadyTeamID ~= TeamID then
       return 
    end

    self.TeamReadyTeamID = nil
    self:SetTeamReadyVoteFinish(false)
    _G.UIViewMgr:HideView(_G.UIViewID.TeamReadyConfirm)
    SidebarMgr:RemoveSidebarItem(SidebarTypeTeamReadyConfirm)
    MainPanelVM:SetTeamReadyConfirming(false)
    self:ClearTeamReadyAudioTimer()

    if self.TimerIDTimeoutTeamReady then
        self:UnRegisterTimer(self.TimerIDTimeoutTeamReady)
        self.TimerIDTimeoutTeamReady = nil
    end
end

function TeamHelperMgr:OnPWorldEnter()
    local bPWorld = _G.PWorldMgr:CurrIsInDungeon()
    if bPWorld then
       local VM = SidebarMgr:GetSidebarItemVM(SidebarTypeTeamReadyConfirm) 
       if VM and (VM.TransData == nil or VM.TransData.TeamVM == nil or VM.TransData.TeamVM == _G.TeamVM) then
            SidebarMgr:RemoveSidebarItem(SidebarTypeTeamReadyConfirm)
       end

       if _G.TeamMgr:GetTeamID() == self.TeamReadyTeamID then
            if self.TimerIDTimeoutTeamReady then
                self:UnRegisterTimer(self.TimerIDTimeoutTeamReady)
                self.TimerIDTimeoutTeamReady = nil
            end
            MainPanelVM:SetTeamReadyConfirming(false)
            self:ClearTeamReadyAudioTimer()
            SidebarMgr:RemoveSidebarItem(SidebarTypeTeamReadyConfirm)
            self.TeamReadyTeamID = nil
       end
    end
end

function TeamHelperMgr:ClearTeamReadyAudioTimer()
    if self.TeamReayAudioTickTimerID then
        self:UnRegisterTimer(self.TeamReayAudioTickTimerID)
        self.TeamReayAudioTickTimerID = nil
    end
end

return TeamHelperMgr

