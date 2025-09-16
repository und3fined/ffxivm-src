local LuaClass = require("Core/LuaClass")
local LogableMgr = require("Common/LogableMgr")
local VoiceMgr = require("Game/Voice/VoiceMgr")
local TeamHelper = require("Game/Team/TeamHelper")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")

---@class TeamVoiceMgr: LogableMgr
local TeamVoiceMgr = LuaClass(LogableMgr)

function TeamVoiceMgr:OnInit()
    self.RoomJoined = {}
    self:SetLogName("TeamVoiceMgr")
    self:SetSpeakerOn(false)
    self:SetMicOn(false)
end

function TeamVoiceMgr:OnBegin()
    self:SetCurTeamMgr(TeamHelper.GetTeamMgr())
end

function TeamVoiceMgr:OnEnd()
    for RoomName in pairs(self.RoomJoined) do
        self:LogInfo("OnEnd quit room %s", RoomName)
        local OK, Err = pcall(function ()
            VoiceMgr:QuitTeamRoom(RoomName)
        end)
        if not OK then
            self:LogErr("quit room %s err: %s", RoomName, tostring(Err))
        end
    end
end

function TeamVoiceMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PWorldMapEnter, self.OnPWorldMapEnter)
    self:RegisterGameEvent(_G.EventID.GVoiceJoinTeamRoomComplete,          self.OnEventJoinTeamRoomComplete)			-- 加入队伍房间语音完成
    self:RegisterGameEvent(_G.EventID.GVoiceQuitTeamRoomComplete,          self.OnQuitTeamRoomComplete)			-- 退出队伍房间完成
    self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnLogin)
    self:RegisterGameEvent(_G.EventID.TeamUpdateMember, self.OnTeamMemberUpdate)
    self:RegisterGameEvent(_G.EventID.GVoiceTeamMembeSayingStatusChanged,  self.OnEventTeamMembeSayingStatusChanged)	-- 队伍房间成员Saying状态变化
    self:RegisterGameEvent(_G.EventID.GVoiceCheckIphoneDeviceMuteStateResult, self.OnCheckIphoneDeviceMuteStateResult)
    self:RegisterGameEvent(_G.EventID.GVoiceTeamMembeDrop,                 self.OnEventTeamMembeDrop)				-- 队伍房间成员掉线
    self:RegisterGameEvent(_G.EventID.GVoiceBanned, self.OnGVocieBanned)
    self:RegisterGameEvent(_G.EventID.GVoiveOnReportPlayer, self.OnReportPlayer)
    self:RegisterGameEvent(_G.EventID.GVoiveRoomMemberInfo, self.OnRoomMemberInfo)
    self:RegisterGameEvent(_G.EventID.TeamMemberMicSyncStateChanged, self.OnMemberMicSyncStateUpdate)
end

---@private
---@param VM ATeamVM
function TeamVoiceMgr:OnTeamMemberUpdate(VM)
    if VM:GetOwnerMgr() == self:GetCurTeamMgr() then
       self:CheckVoice() 
    end
end

---@private
function TeamVoiceMgr:CheckVoice()
    local CurTeamMgr = self:GetCurTeamMgr()
    if CurTeamMgr == nil then
       return
    end

    self:LogInfo("CheckVoice ...")
    local bShouldOnVoice = self:IsVoiceNeedOn(CurTeamMgr)
    local bCurOnVoiceRoom = self:IsCurInVoiceRoom()
    local bJoin = bShouldOnVoice and not bCurOnVoiceRoom
    local bQuit = not bShouldOnVoice and bCurOnVoiceRoom
    if bJoin or bQuit then
        self:LogWarn('mismatch state, bJoin: %s, bQuit: %s', bJoin, bQuit)
        self:DumpDebugInfo()
    end

    if bJoin then
        self:TryJoinRoom(CurTeamMgr)
    elseif  bQuit then
        self:QuitCurrentRoom()
    end
end

function TeamVoiceMgr:OnPWorldMapEnter()
    self:SetCurTeamMgr(TeamHelper.GetTeamMgr())
end

function TeamVoiceMgr:OnLogin()
    self.RoomJoined = {}
    self:Refresh()
end

---@private
function TeamVoiceMgr:Refresh()
    local TeamMgr = self:GetCurTeamMgr()
    if TeamMgr == nil then
       return 
    end

    if self:IsCurInVoiceRoom() then
        -- voice
        if self:IsCurVoiceOn() then
            self:SetSpeakerOn(self:OpenSpeaker() == true)
        else
            self:CloseSpeaker()
        end
        -- mic
        if self:IsCurMicOn() and not self:IsVoiceBanned() then
            self:OpenMic()
        else
            self:CloseMic()
        end
    end

    self:CheckVoice()
end

function TeamVoiceMgr:IsCurVoiceOn()
    return self.bSpeakerOn
end

function TeamVoiceMgr:IsCurMicOn()
    return self.bMicOn
end

function TeamVoiceMgr:IsUsingMic()
    return self:IsCurMicOn() and self:IsCurInVoiceRoom()
end

function TeamVoiceMgr:UIOpenSpeaker()
    self:LogInfo('UIOpenSpeaker %s', self:GetCurTeamShortInfo())

    VoiceMgr:CheckIphoneDeviceMuteState()
    self:SetSpeakerOn(true)
    if self:IsCurInVoiceRoom() then
        self:SetSpeakerOn(self:OpenSpeaker() == true)
    end
    self:CheckVoice()

    return self.bSpeakerOn
end

function TeamVoiceMgr:UICloseSpeaker()
    self:LogInfo('UICloseSpeaker %s', self:GetCurTeamShortInfo())

    self:SetSpeakerOn(false, self.bMicOn ~= false)
    self:SetMicOn(false)
    if self:IsCurInVoiceRoom() then
       self:CloseSpeaker()
       self:CloseMic() 
    end
    self:QuitCurrentRoom()
end

function TeamVoiceMgr:UIOpenMic()
    self:LogInfo('UIOpenMic %s', self:GetCurTeamShortInfo())

    if not self:IsCurVoiceOn() then
        self:LogErr('try open mic while voice not on, trace: %s', debug.traceback())
        return false
    end

    if _G.LoginMgr:IsGVoiceBanned() then
        _G.LoginMgr:TipGVoiceBanned()
        self:LogWarn("open mic failed for gvoice banned")
       return false 
    end

    if _G.ChatMgr:IsRecordingVoice() then
        self:LogWarn("open mic failed for recording")
        _G.MsgTipsUtil.ShowTips(_G.LSTR(1300080))
        return false
    end

    local bOpened
    if self:IsCurInVoiceRoom() then
        bOpened = self:OpenMic()
    end
    
    self:CheckVoice()
    return bOpened
end

function TeamVoiceMgr:UICloseMic()
    self:LogInfo('UICloseMic %s', self:GetCurTeamShortInfo())

    self:SetMicOn(false)
    self:CloseMic()
    self:CheckVoice()
end

---@private
function TeamVoiceMgr:OpenSpeaker()
    self:LogInfo("open speaker")

    if not VoiceMgr:OpenSpeaker() then
        self:LogErr("open speaker failed")
       _G.MsgTipsUtil.ShowTipsByID(103097)
       return false
    end

    return true
end

---@private
function TeamVoiceMgr:CloseSpeaker()
    self:LogInfo("close speaker")
    VoiceMgr:CloseSpeaker()
end

---@param Mgr ATeamMgr
function TeamVoiceMgr:TryJoinRoom(Mgr)
    if not Mgr then
       return 
    end

    if not self:IsVoiceNeedOn(Mgr) then
        self:LogInfo("try to join room %s %s while voice should not on", Mgr, Mgr:GetTeamVoiceRoomNameToJoin())
        self:DumpDebugInfo()
        return 
    end

    if not self:CanJoinRoom() then
        self:LogWarn('cannot join room for %s %s', Mgr, Mgr:GetTeamVoiceRoomNameToJoin())
        self:DumpDebugInfo()
        return 
    end

    local _, err = pcall(function ()
        local RoomName = Mgr:GetTeamVoiceRoomNameToJoin()
        self:LogInfo('try to join room %s', RoomName)
        if not VoiceMgr:JoinTeamRoom(RoomName) then
            self:LogErr('failed to join room %s', RoomName)
        end
    end)

    if err then
        self:LogErr('faild to join room for %s, err: %s, trace: %s', Mgr, err, debug.traceback()) 
     end
end

---@param Mgr ATeamMgr
function TeamVoiceMgr:QuitRoom(Mgr)
    if not Mgr then
       return 
    end

    local RoomName = Mgr:GetTeamVoiceRoomNameToJoin()
    if not self:IsRoomJoined(RoomName) then
        return
    end

    local _, err = pcall(function ()
        self:LogInfo("try to quit room %s", RoomName)
        VoiceMgr:QuitTeamRoom(RoomName) 
        Mgr:OnQuitTeamVoiceRoom()
    end)

    if err then
       self:LogErr('faild to quit room for %s, err: %s, trace: %s', Mgr, err, debug.traceback()) 
    end
end


---@private
function TeamVoiceMgr:QuitCurrentRoom()
    self:QuitRoom(self:GetCurTeamMgr())
end

---@private
function TeamVoiceMgr:OpenMic()
    local OK = VoiceMgr:OpenMic()
    self:LogInfo('open mic, success %s, cur team: %s', OK, self:GetCurTeamShortInfo())
    self:SetMicOn(OK)
    if not OK then
       self:LogErr('failed to open mic') 
    end
    return OK
end

---@private
function TeamVoiceMgr:CloseMic()
    self:LogInfo('close mic, cur team %s', self:GetCurTeamShortInfo())
    VoiceMgr:CloseMic()
end

--- EveHandle

---@param Params FEventParams
---Params.StringParam1, room name 
---Params.IntParam1, the player's ID in this room 
function TeamVoiceMgr:OnEventJoinTeamRoomComplete(Params)
    if nil == Params then
		return
	end

    local RoomName = Params.StringParam1
    local VoiceID = Params.IntParam1
    if RoomName then
       self.RoomJoined[RoomName] = true 
    end

    self:LogInfo("recv joined room %s %s", RoomName, VoiceID)
    TeamHelper.IterTeamMgrs(function (Mgr)
        if Mgr and Mgr:GetTeamVoiceRoomNameToJoin() == RoomName then
            self:UpdateMajorVoiceID(Mgr, VoiceID)
        end
    end)

    local Team = self:GetCurTeamMgr()
    local bJoined = Team:GetTeamVoiceRoomNameToJoin() == RoomName
    if  not bJoined then
        self:LogErr('join room %s, but now is %s',RoomName, Team:GetTeamVoiceRoomNameToJoin())
    else
       self:LogInfo("join room %s complete", RoomName) 
    end

    if bJoined then
        self:Refresh()
        if self.IsGVoiceAbroad() then
            self:LogInfo("EnableReportALLAbroad")
            self.GetCppVoiceMgr():EnableReportALLAbroad(true)
        else
            self:LogInfo("EnableReportALL")
            self.GetCppVoiceMgr():EnableReportALL(true)
        end
    else
        self:CheckVoice()
    end

    -- quit the room if odd case exists
    local bExists = false
    TeamHelper.IterTeamMgrs(function (Mgr)
        if Mgr and Mgr:GetTeamVoiceRoomNameToJoin() == RoomName then
            bExists = true
        end
    end)

    if not bExists then
       self:LogErr('recv join an unknown room %s, try to quit', RoomName) 
       local OK, Err = pcall(function ()
            VoiceMgr:QuitTeamRoom(RoomName)
       end)
       if not OK then
            self:LogErr('error occurs when quiting room %s: %s', RoomName, Err)
       end
    end

    self:DumpDebugInfo()
end

---@param Params FEventParams
---Params.StringParam1, room name 
function TeamVoiceMgr:OnQuitTeamRoomComplete( Params )
	if nil == Params then
		return
	end

    local RoomName = Params.StringParam1
    if RoomName then
       self.RoomJoined[RoomName] = nil
    end

    self:LogInfo('on quit room complete %s', RoomName)

    local Team = self:GetCurTeamMgr()
    if Team and Team:GetTeamVoiceRoomNameToJoin() == RoomName then
        Team:OnQuitTeamRoom(Params)
    else
        self:LogWarn("cur team is not the quited room: %s!", RoomName)
    end

    self:CheckVoice()

    self:DumpDebugInfo()
end

---@return ATeamMgr | nil
function TeamVoiceMgr:GetCurTeamMgr()
    return self.CurTeamMgr
end

---@private
function TeamVoiceMgr:CanJoinRoom()
    return not next(self.RoomJoined)
end

---priavte
function TeamVoiceMgr:DumpDebugInfo()
    self:LogInfo("dump debug info>>>")
    local CurTeamMgr = self:GetCurTeamMgr()
    self:LogInfo("speaker on: %s, mic on: %s", self:IsCurVoiceOn(), self:IsCurMicOn())
    self:LogInfo("team: %s, room to join: %s\nRoomJoined:", self:GetCurTeamShortInfo(), CurTeamMgr and CurTeamMgr:GetTeamVoiceRoomNameToJoin() or nil)
    for RoomName in pairs(self.RoomJoined) do
        self:LogInfo("room: %s", RoomName)
    end
    self:LogVoiceInfo(self:GetCurTeamMgr())
    self:LogInfo("<<<")
end


---@private
function TeamVoiceMgr:LogVoiceInfo(Mgr)
    local TeamMemVMList = Mgr and Mgr.TeamVM.BindableListMember or nil
    if TeamMemVMList then
        for i = 1, TeamMemVMList:Length() do
            local VM = TeamMemVMList:Get(i) or {}
            self:LogInfo("mem[%d]: %s, name: %s, voice id: %s", i, VM.RoleID, VM.Name, VM.VoiceMemberID)
        end
    end
end

---priavte
function TeamVoiceMgr:IsRoomJoined(RoomName)
    for K in pairs(self.RoomJoined) do
        if K == RoomName then
           return true 
        end
    end

    return false
end

function TeamVoiceMgr:IsCurInVoiceRoom()
    local Mgr = self:GetCurTeamMgr()
    if Mgr then
       return self:IsRoomJoined(Mgr:GetTeamVoiceRoomNameToJoin()) 
    end
end

---@param Mgr ATeamMgr | nil
function TeamVoiceMgr:IsVoiceNeedOn(Mgr)
    if Mgr == nil or TeamHelper.GetTeamMgr() ~= Mgr then
       return false 
    end

    return self:IsCurVoiceOn() and Mgr:IsInTeam() and Mgr:GetTeamMemberCount() > 1
end

---@private
function TeamVoiceMgr:SetSpeakerOn(bOn, bIgnoreSync)
    local bChanged = (bOn ~= self.bSpeakerOn)
    self.bSpeakerOn = bOn

    TeamHelper.IterTeamMgrs(function(Mgr)
        if Mgr and Mgr.TeamVM then
            Mgr.TeamVM:SetVoice(bOn)
        end

        if bChanged and Mgr and Mgr.TeamVM and Mgr:IsInTeam() and not bIgnoreSync then
            local VoiceID = Mgr.TeamVM:FindMemberVoiceID(MajorUtil.GetMajorRoleID())
            if VoiceID and VoiceID ~= 0 then
                self:UpdateMajorVoiceID(Mgr, VoiceID)
            end
        end
    end)

    self:UpdateCurrentVocieState()
end

---@private
function TeamVoiceMgr:SetMicOn(bOn)
    local bChanged = (bOn ~= self.bMicOn)
    self.bMicOn = bOn

    TeamHelper.IterTeamMgrs(function(Mgr)
        if Mgr and Mgr.TeamVM then
            Mgr.TeamVM:SetMic(bOn)
        end

        if bChanged and Mgr and Mgr.TeamVM and Mgr:IsInTeam() then
            local VoiceID = Mgr.TeamVM:FindMemberVoiceID(MajorUtil.GetMajorRoleID())
            if VoiceID and VoiceID ~= 0 then
                self:UpdateMajorVoiceID(Mgr, VoiceID)
            end
        end
    end)

    self:UpdateCurrentVocieState()
end

---@param Mgr ATeamMgr
function TeamVoiceMgr:OnVoiceMemberIDUpdate(Mgr, RoleID, VoiceID)
    self:LogInfo('on voice mem id update %s %s %s role: %s, name: %s, voice id: %s', Mgr, Mgr.Name, Mgr:GetTeamVoiceRoomNameToJoin(), RoleID, (_G.RoleInfoMgr:FindRoleVM(RoleID, true) or {}).Name, VoiceID)
    local bFlag = Mgr.TeamVM:UpdateMemberVoiceMemberID(RoleID, VoiceID)
    if not bFlag then
       self:LogErr("failed to update voice id for %s %s %s %s", Mgr, Mgr.Name, RoleID, VoiceID) 
    end
    self:LogVoiceInfo(Mgr)
end

---@private
---@param Params FEventParams
---Params.StringParam1，room name
---Params.StringParam2，The openid of the user who's status has changed.
---Params.IntParam1，The ID of the room member who's status has changed.
---Params.IntParam2，status could be 0, 1, 2. ( 0 means being silence from saying, 1 means begining saying from silence and 2 means continue saying.)
function TeamVoiceMgr:OnEventTeamMembeSayingStatusChanged(Params)
    if nil == Params then
		return
	end

    local RoomName = Params.StringParam1
    local VoiceID = Params.IntParam1
    local Status = Params.IntParam2
    local bSaying = Status ~= 0 and self:IsCurVoiceOn()

    if not self:IsRoomJoined(RoomName) then
       self:LogErr("recv voice data for an unjoined room %s, mem id: %s, status: %s", RoomName, VoiceID, Status) 
       self:DumpDebugInfo()
       return
    end

    local bFoundTeam
    local function IterTeamVoiceData(Mgr)
        if Mgr and Mgr:GetTeamVoiceRoomNameToJoin() == RoomName then
            self:UpdateTeamVoice(Mgr, VoiceID, bSaying)
            bFoundTeam = true
        end
    end

    if RoomName then
       TeamHelper.IterTeamMgrs(IterTeamVoiceData) 
    end

	if not bFoundTeam then
        self:LogErr("failded to find team for room %s, mem id: %s, status: %s", RoomName, VoiceID, Status) 
    end
end

---@private
---@param Mgr ATeamMgr
function TeamVoiceMgr:UpdateTeamVoice(Mgr, VoiceID, bSaying)
    if Mgr then
       local bFlag = Mgr.TeamVM:UpdateMemberVoiceState(VoiceID, bSaying)
       if bSaying and not bFlag and CommonUtil.IsWithEditor() then
            self:LogErr("failed to update voice for team %s %s, voice id: %s", Mgr, Mgr.Name, VoiceID)
       end
    end
end

---@private
---@param Mgr ATeamMgr
function TeamVoiceMgr:UpdateMajorVoiceID(Mgr, VoiceID)
    if Mgr then
       self:LogInfo("update major voice id:: team: %s %s, voice id: %s", Mgr, Mgr.Name, VoiceID) 
       Mgr:SendSetSelfVoiceMemberID(VoiceID)
    end
end

---@private
function TeamVoiceMgr:SetCurTeamMgr(Mgr)
    if Mgr == nil then
        self:LogErr('try to set a nil team: trace: %s', debug.traceback())
       return 
    end

    local bChanged = self.CurTeamMgr ~= Mgr
    if  bChanged then
        self:QuitCurrentRoom()
    end

    if bChanged then
       self:LogInfo('set cur team mgr %s => %s', self:GetCurTeamShortInfo(), self.GetTeamShortInfo(Mgr)) 
    end
    
    self.CurTeamMgr = Mgr
    
    if bChanged then
        self:Refresh()
    end
end

---@return string
function TeamVoiceMgr:GetCurTeamShortInfo()
    return self.GetTeamShortInfo(self:GetCurTeamMgr())
end

---@param Mgr string | nil
function TeamVoiceMgr.GetTeamShortInfo(Mgr)
    return Mgr and string.sformat("%s(%s)", Mgr.Name, Mgr) or "nil"
end

function TeamVoiceMgr:OnCheckIphoneDeviceMuteStateResult(Params)
    self:LogInfo("on check mute result %s", Params.IntParam1)

    if  Params.IntParam1 ~= nil and  Params.IntParam1 ~= 0 then
        _G.MsgTipsUtil.ShowTipsByID(103098)
    end
end

function TeamVoiceMgr:OnEventTeamMembeDrop(Params)
    if Params == nil then
       return 
    end

    local VoiceID = Params.IntParam1
    local RoomName = Params.StringParam1
    self:LogInfo("mem drop, room: %s, voice id: %s", RoomName, VoiceID)

    if self:IsRoomJoined(RoomName) and self:IsCurInVoiceRoom() and self:GetCurTeamMgr():GetTeamVoiceRoomNameToJoin() == RoomName and self.ContainVoiceMember(self:GetCurTeamMgr(), MajorUtil.GetMajorRoleID(), VoiceID) then
        self:LogErr("mem drop but in room, room: %s, voice id: %s", RoomName, VoiceID)
        self:DumpDebugInfo()
        self.RoomJoined[RoomName] = nil
    end

    self:CheckVoice()
end

function TeamVoiceMgr:OnGVocieBanned(bBanned)
    if  bBanned and self:IsCurMicOn() then
        self:LogInfo("close mic for gvoice banned")
        self:UICloseMic() 
    end
end

local TipsOnReport <const> = {
    [24577] = 103102,
    [12300] = 103103,
    [12294] = 103105,
    [24578] = 103105,
}

function TeamVoiceMgr:OnReportPlayer(Params)
    local Code = Params.IntParam1
    local Info = Params.StringParam1

    self:LogInfo("TeamVoiceMgr:OnReportPlayer code (0x%x)%d info %s", Code, Code, Info)
    if Code then
       local TipID = TipsOnReport[Code]
       if TipID then
            _G.MsgTipsUtil.ShowTipsByID(TipID)
       end
    end
end

function TeamVoiceMgr:OnRoomMemberInfo(Params)
    local Code = Params.IntParam1
    local MemID = Params.IntParam2
    local RoomName = Params.StringParam1
    local OpenID = Params.StringParam2

    if Code == 32771 then
        self:LogInfo("room %s, mic open %s %s", RoomName, OpenID, MemID)
    elseif Code == 32772 then
        self:LogInfo("room %s, mic close %s %s", RoomName, OpenID, MemID)
    end
end

function TeamVoiceMgr:OnMemberMicSyncStateUpdate(VM, RoleID, State)
    if RoleID == MajorUtil.GetMajorRoleID() and State ~= self:ConvertCurrentState() then
        if self:GetCurTeamMgr() then
            self:LogInfo("fix voice state for %s (%s) state %s -> %s", RoleID, VM.Name, State, self:ConvertCurrentState())
            self:GetCurTeamMgr():SendSyncVoiceData(VM.VoiceMemberID or 0) 
        end
    end
end

---@param Mgr ATeamMgr | nil
---@param RoleID any
---@param VocieID any
function TeamVoiceMgr.ContainVoiceMember(Mgr, RoleID, VocieID)
    if Mgr and Mgr.TeamVM then
        return VocieID ~= nil and Mgr.TeamVM:FindMemberVoiceID(RoleID) == VocieID
    end
end

function TeamVoiceMgr:IsVoiceBanned()
    local LoginMgr = require("Game/Login/LoginMgr")
    return LoginMgr:IsGVoiceBanned()
end

function TeamVoiceMgr.IsGVoiceAbroad()
    return not (_G.LoginMgr:GetChannelID() == 1 or _G.LoginMgr:GetChannelID() == 2 or _G.LoginMgr:GetIsResearchLogin())
end

function TeamVoiceMgr.GetCppVoiceMgr()
    return _G.UE.UVoiceMgr.Get()
end

function TeamVoiceMgr:ReportPlayer(RoleID)
    if RoleID == MajorUtil.GetMajorRoleID() then
        self:LogErr("can not reprot self: \n%s", debug.traceback())
        return
    end

    if RoleID and self.ReportTimeMap and (self.ReportTimeMap[RoleID] == nil or (os.time() - self.ReportTimeMap[RoleID]) <= 10) then
       self:LogInfo("stop report %s while in threshould!", RoleID) 
       _G.MsgTipsUtil.ShowTipsByID(103104)
       return
    end

    if self.ReportTimeMap == nil then
       self.ReportTimeMap = {}
    end
    self.ReportTimeMap[RoleID or 0] = os.time()

    _G.RoleInfoMgr:QueryRoleSimple(RoleID, function(InRoleID, VM)
        if InRoleID == RoleID and RoleID then
            local Json = require("Core/Json")
            local ExtraInfo = Json.encode({Players={{RoleID=RoleID, OpenID=VM.OpenID}}})
            self:LogInfo("report player %s %s with %s", RoleID, VM.OpenID, ExtraInfo)
            local Code = self.GetCppVoiceMgr():ReportPlayer(VM.OpenID, ExtraInfo) 
            if Code ~= 0 then
                self:OnReportPlayer({IntParam1=Code, StringParam1=ExtraInfo})
            end
        end
    end, RoleID, true)
end

function TeamVoiceMgr:ConvertCurrentState()
    local MicBit = self:IsCurMicOn() and 1 or 0
    local SpeakerBit = self:IsCurVoiceOn() and 2 or 0
    return MicBit | SpeakerBit
end

function TeamVoiceMgr:UpdateCurrentVocieState()
    local TeamMgr = self:GetCurTeamMgr()
    if TeamMgr then
        local VM = TeamMgr:GetTeamMemberVMByRoleID(MajorUtil.GetMajorRoleID())
        if VM then
            VM:SetMicSyncState(self:ConvertCurrentState())
        end
    end 
end

return TeamVoiceMgr