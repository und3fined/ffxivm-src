--
-- Author: stellahxhu
-- Date: 2020-08-15 16:57:14
-- Description:

--
local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local ChatUtil = require("Game/Chat/ChatUtil")
local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
local TeamMgr = require("Game/Team/TeamMgr")
local ChatMgr = require("Game/Chat/ChatMgr")
local EventID = require("Define/EventID")
local LogableMgr = require("Common/LogableMgr")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local RecruitParamsCfg = require("TableCfg/RecruitParamsCfg")

local UIViewMgr
local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT
local RECRUIT_STATE = ProtoCS.Team.TeamRecruit.RECRUIT_STATE

local PAGE_LIMIT <const> = 20
local TIMEOUT_R1 <const> = 5
local TIMEOUT_R2 <const> = 5

local function GetTimerIDKeyR1(TypeID)
    return string.sformat("TimerIDKeyR1_%s", TypeID)
end

local function GetTimerIDKeyR2(TypeID)
    return string.sformat("TimerIDKeyR2_%s", TypeID)
end


---@class TeamRecruitMgr : LogableMgr
local TeamRecruitMgr = LuaClass(LogableMgr)

function TeamRecruitMgr:OnInit()
    self:SetLogName("TeamRecruitMgr")
end

function TeamRecruitMgr:OnBegin()
    self:LogInfo("TeamRecruitMgr:OnBegin")

    UIViewMgr = _G.UIViewMgr

    self:Clear(false)
end

function TeamRecruitMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_UPDATE, self.OnNetMsgTeamRecruitUpdate)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_QUERY, self.OnNetMsgQueryRecuiteList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_GET_LIST, self.OnNetMsgGetRecruitList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_JOIN, self.OnNetMsgTeamRecruitJoin)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_INDEX, self.OnNetMsgCalcMemberIndex)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_QUERY_SELF, self.OnNetMsgGetSelfRecruitMessage)

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_CREATE_NTF, self.OnNetMsgTeamRecruitCreateNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_COMPLETE_NTF, self.OnNetMsgTeamRecruitCompleteNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_CLOSE_NTF, self.OnNetMsgTeamRecruitCloseNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_JOIN_NTF, self.OnNetMsgTeamRecruitJoinNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_QUERY_RELATION, self.OnNetMsgRelation)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM_RECRUIT, SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_QUERY_RELATION_INFO, self.OnNetMsgRelationRecruitInfos)
end

function TeamRecruitMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.TeamInfoUpdate, self.OnTeamInfoUpdate)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnLoginRes)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.ChatMsgPushed, self.OnChatSharePush)
    self:RegisterGameEvent(EventID.QueryRoleInfo, self.OnQueryCaptainRoleInfoDataUpdate)
end

function TeamRecruitMgr:OnTeamInfoUpdate()
    self:NetUpdateCurrentRecruit()
end

function TeamRecruitMgr:OnLoginRes(Params)
    self:LogInfo("TeamRecruitMgr:OnLoginRes")
    self:Clear(true)
    self:NetUpdateCurrentRecruit()

    if Params.bReconnect and not (_G.TeamMgr:IsInTeam() and not _G.TeamMgr:IsCaptain()) then
       self:TryRecoverEditRecruit() 
    end
end

function TeamRecruitMgr:OnPWorldExit()
    self:NetUpdateCurrentRecruit()
end

function TeamRecruitMgr:OnChatSharePush(Data)
    if Data.Fail then
       return 
    end

    if not (Data.Msg and Data.Msg.Data and Data.Msg.Data.ParamList and #(Data.Msg.Data.ParamList) > 0) then
        return
    end
    if Data.Msg.Data.ParamList[1].Type ~= 9 then
       return 
    end

    local Type = Data.Channel and Data.Channel.Type or nil

    local RoleID = (Type == 6 and Data.Channel) and Data.Channel.ChannelID or nil
    if Type == 6 and RoleID then
        if self.RecruitShareToPerson == nil then
            self.RecruitShareToPerson = {}
        end
        self.RecruitShareToPerson[RoleID] = {
            Time = os.time()
        }
        if self.TimerIDFlushPersonChat then
           self:UnRegisterTimer(self.TimerIDFlushPersonChat) 
        end
        self:RegisterTimer(function()
            self.RecruitShareToPerson = nil
            self.TimerIDFlushPersonChat = nil
        end, 5)

        if Data.Msg.Sender == MajorUtil.GetMajorRoleID() and self.RecruitShareWaitTip and (os.time() - (self.RecruitShareWaitTip[RoleID] or 0)) < 5 then
            MsgTipsUtil.ShowTipsByID(301041)
            self.RecruitShareWaitTip[RoleID] = nil
        end
    end

    if self.ChatShareCallbackData == nil then
        return 
    end

    if Type == nil or Type ~= self.ChatShareCallbackData.ChatType then
        return 
    end

    if Data.Msg and Data.Msg.Data and Data.Msg.Data.Content == _G.ChatMgr.MakeRecruitShareContent(self.ChatShareCallbackData.RoleID) then
        self.ChatShareCallbackData.Callback()
        self.ChatShareCallbackData = nil
        if self.TimerIDTimeoutChatShare then
           self:UnRegisterTimer(self.TimerIDTimeoutChatShare) 
        end
        self.TimerIDTimeoutChatShare = nil
    end
end

function TeamRecruitMgr:OnQueryCaptainRoleInfoDataUpdate(RoleID)
    if not self.CacheCaptainData or not self.CacheCaptainData.RoleID or RoleID ~= self.CacheCaptainData.RoleID then return end
    local CaptainRoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
    if not CaptainRoleVM then
        FLOG_ERROR("OnQueryCaptainRoleInfoDataUpdate FindEmpty CaptainRoleVM")
        return
    end

    local ConfirmCallBack = function()
        self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_JOIN, "Join", { ID = self.CacheCaptainData.RoleID, PassWord = self.CacheCaptainData.PassWord})
        self.CacheCaptainData = {}
    end

    local CaptainRoleWorldID = CaptainRoleVM.CurWorldID
    local MajorRoleWorldID = (MajorUtil.GetMajorRoleVM() or {}).CurWorldID or 0 
    if MajorRoleWorldID ~= CaptainRoleWorldID then
        local SuccessCallback = function()
            UIViewMgr:HideView(UIViewID.TeamMainPanel)
        end   

        local CrossWorldUtil = require("Utils/CrossWorldUtil")
        CrossWorldUtil.CrossWorldWithoutCrtstal(CaptainRoleWorldID, LSTR(1530009), LSTR(1530010), ConfirmCallBack, SuccessCallback, RoleID, EventID.TeamRecruitJoin)
    else
        ConfirmCallBack()
    end
end

---@private
function TeamRecruitMgr:Clear(bClearCache)
    self:LogInfo("Clear")
    self:SetRecruiting(false)
    self.CacheTeamRecruitID = nil
    self:SetRecruitID(nil)
    self.RecruitClipboard = nil

    if bClearCache then
       self:SetCachedRecruitData(nil)
       self.MyRecruitCacheData = nil 
    end
end

---创建招募
function TeamRecruitMgr:SendCreateRecruitReq()
    self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_CREATE, "Create", {
        ID          = TeamRecruitVM.EditContentID, 
        Message     = TeamRecruitVM.EditMessage or "",
        Prof        = TeamRecruitVM:GetEditProfs(),
        TaskLimit   = TeamRecruitVM.EditSceneMode,
        Password    = TeamRecruitVM:GetEditPassword(),
        EquipLv     = TeamRecruitVM.EditEquipLv or 0,
        CompleteTask = TeamRecruitVM.EditCompleteTask == true,
        QuickMessageIDs = TeamRecruitVM.EditQuickTextIDs,
        WeeklyAward = TeamRecruitVM.EditWeeklyAward == true
    })
end

---创建招募
---@param RecruitData csteamrecruitdd.TeamRecruit @招募的完整服务器信息
function TeamRecruitMgr:SendCreateRecruitReqByRecruitData( RecruitData )
    self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_CREATE, "Create", {
        ID          = RecruitData.ID, 
        Message     = RecruitData.Message,
        Prof        = RecruitData.Prof,
        TaskLimit   = RecruitData.TaskLimit,
        Password    = "",
        EquipLv     = RecruitData.EquipLv,
        CompleteTask = RecruitData.ComplateTask,
    })
end

---更新招募回包
function TeamRecruitMgr:OnNetMsgTeamRecruitUpdate()
end

---@private
function TeamRecruitMgr:QueryBelongingRecruitInfo()
    local RecruitID = 0
    if _G.TeamMgr:IsInTeam() then
        RecruitID = self.RecruitID or _G.TeamMgr:GetTeamRecruitID()
    else
        RecruitID = MajorUtil.GetMajorRoleID()
    end
    if RecruitID and RecruitID > 0 then
        self:SendGetRecruitStateReq({ RecruitID })
        self:NetUpdateCurrentRecruit()
    end
end

---查询指定玩家招募信息
---@param RoleID number @玩家RoleID
function TeamRecruitMgr:QueryRecruitInfoReq( RoleID, Params)
    if nil == RoleID then
        return
    end

    self._QueringRoleID = RoleID
    self._QueryingParams = Params
    self:SendGetRecruitStateReq({ RoleID })
end

---查询招募状态
function TeamRecruitMgr:SendGetRecruitStateReq(RoleIDs)
    self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_QUERY, "Query", { RoleIDs = RoleIDs })
end

---查询招募状态回包
function TeamRecruitMgr:OnNetMsgQueryRecuiteList(MsgBody)
    local TeamRecruitList = MsgBody.Query.RecruitContent
    if nil == TeamRecruitList then
        return
    end

    local ClearQueryInfo = function ()
        self._QueringRoleID = nil
        self._QueryingParams = nil
    end
    local RecuritInfoToShow = nil
    local FailTipsID = (self._QueryingParams or {}).FailTipID
    local bNoLimit = (self._QueryingParams or {}).bNoLimit

    for _, v in ipairs(TeamRecruitList) do
        local RoleID = v.RoleID
        if RoleID and RoleID == self._QueringRoleID  and self.IsRecruitOpen(v) then
            ClearQueryInfo()
            RecuritInfoToShow = v
        end
    end

    if RecuritInfoToShow then
        self:ShowRecruitInfo(RecuritInfoToShow, bNoLimit)
    elseif self._QueringRoleID then
        if FailTipsID then
            MsgTipsUtil.ShowTipsByID(FailTipsID)
        else
            MsgTipsUtil.ShowErrorTips(LSTR(1310001))
        end
    end

    ClearQueryInfo()
end

function TeamRecruitMgr:ShowRecruitInfo(RecuritInfoToShow, bNoLimit)
    TeamRecruitVM:UpdateCurRecruitDetailInfo(RecuritInfoToShow)	
    --更新具体招募Item信息
    TeamRecruitVM:UpdateRecruitItem(RecuritInfoToShow)

    if not UIViewMgr:IsViewVisible(UIViewID.TeamRecruitDetail) and (UIViewMgr:IsViewVisible(UIViewID.TeamMainPanel) or UIViewMgr:IsViewVisible(UIViewID.ChatMainPanel) or bNoLimit) then
        local RoleIdList = {}
        for _, ProfData in ipairs(RecuritInfoToShow.Prof or {}) do
            if ProfData.RoleID and ProfData.RoleID > 0 and ProfData.RoleID ~= MajorUtil.GetMajorRoleID() then
                table.insert(RoleIdList, ProfData.RoleID)
            end
        end

        if #RoleIdList == 0 then
            UIViewMgr:ShowView(UIViewID.TeamRecruitDetail)
        else
            _G.RoleInfoMgr:QueryRoleSimples(RoleIdList, function(V)
                if V.RoleID == TeamRecruitVM.CurRecruitDetailVM.RoleID then
                    TeamRecruitVM:UpdateCurRecruitDetailInfo(V)
                    UIViewMgr:ShowView(UIViewID.TeamRecruitDetail)
                end
            end, RecuritInfoToShow, true)
        end
    end
end

---关闭招募
function TeamRecruitMgr:SendCloseRecruitReq(Reason)
    self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_CLOSE, "Close", {Reason = Reason or ProtoCS.Team.TeamRecruit.CloseReason.CloseReasonDefault})
end

---拉取全部信息回包
function TeamRecruitMgr:OnNetMsgGetRecruitList(MsgBody)
    local Msg = MsgBody.RecruitList
    if nil == Msg then
        return
    end

    local TypeID = Msg.TypeID
    local RelationRecruitList = self:GetRelationRecruitList(TypeID)
    local RecruitSet = {}
    self:ClearRecruitTimeoutQuery(TypeID)

    local function Fill(List)
        for _, v in ipairs(List) do
            RecruitSet[v.RoleID] = v
        end
    end

    Fill(RelationRecruitList)
    Fill(Msg.TeamRecruit or {})
    local RecruitList =  table.values(RecruitSet)
    local Offset = Msg.Offset or 0
    for i, v in ipairs(Msg.TeamRecruit or {}) do
        v.OffsetQuery = Offset + i - 1
    end

    self:LogInfo("pull recruit by page, total %s", Msg.Total)
    -- remove deplicate relation roles at last page
    if Msg.Total <= Offset + #(Msg.TeamRecruit or {}) + 1 and Offset ~= 0 then
        local RelationRoles = self:GetRelationRoleIDs()
        if Offset + 1 > #RelationRoles and #RelationRoles > 0  then
            local RelationRoleSet = table.makeset(RelationRoles)
            for i = #RecruitList, 1, -1 do
                local v = RecruitList[i]
                if RelationRoleSet[v.RoleID] then
                    table.remove(RecruitList, i)
                end
            end
        end
    end

    if #RecruitList == 0 and Offset > 0 and Offset >= Msg.Total then
        self:LogInfo("query exceeds total result in empty list!")
        return
    end

    TeamRecruitVM:UpdateRecruitItemList(RecruitList, TypeID, Offset > 0)

    -- query roles
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    local RoleIDs = {}
    for _, v in ipairs(RecruitList) do
        if v.RoleID ~= MajorRoleID then
           table.insert(RoleIDs, v.RoleID) 
        end
    end
    _G.RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
    end, nil, false)

    _G.EventMgr:SendEvent(EventID.TeamRecruitOnQueryData, Offset)
end

function TeamRecruitMgr:TryJoinRecruit(FromView, ID, Password, TeamRecruitID)
    if not _G.PWorldMatchMgr:IsMatching() then
        self:SendJoinRecruitReq(ID, Password, TeamRecruitID)
       return 
    end

    _G.MsgBoxUtil.ShowMsgBoxTwoOp(
        FromView, 
        LSTR(1310002), 
        LSTR(1310003),
        function()
            self:SendJoinRecruitReq(ID, Password, TeamRecruitID)
        end,
        nil,
        LSTR(1310004),
        LSTR(1310005)
    )
end

function TeamRecruitMgr:SendJoinRecruitReq(ID, PassWord, TeamRecruitID)
    local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
    local Cfg = TeamRecruitID and TeamRecruitCfg:FindCfgByKey(TeamRecruitID) or {}
    if next(Cfg) and Cfg.CrossWorldConfirm == 1 then
        self.CacheCaptainData = {
            RoleID = ID,
            PassWord = PassWord,
            TeamRecruitID = TeamRecruitID
        }
        _G.RoleInfoMgr:SendQueryInfoByRoleID(ID)
    else
        self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_JOIN, "Join", { ID = ID, PassWord = PassWord})
    end
end

---加入招募回包
function TeamRecruitMgr:OnNetMsgTeamRecruitJoin(MsgBody)
    if not MsgBody.ErrorCode or MsgBody.ErrorCode == 0 then
        UIViewMgr:HideView(UIViewID.TeamRecruitCode)
        UIViewMgr:HideView(UIViewID.TeamRecruitDetail)
    
        self:SetRecruitID(self.CacheTeamRecruitID)
        self.CacheTeamRecruitID = nil
    
        self:QueryBelongingRecruitInfo()
        _G.EventMgr:SendEvent(EventID.TeamRecruitJoin)
    end
end

---计算招募填充的位置
---@param Profs table<RecruitProf>
function TeamRecruitMgr:SendCalcMemberIndexReq( Profs )
    self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_INDEX, "Index", { Profs = Profs})
end

function TeamRecruitMgr:OnNetMsgCalcMemberIndex(MsgBody)
    local Msg = MsgBody.Index
    if nil == Msg then
        return
    end
    local Profs = Msg.Profs or {}
    for _, v in ipairs(Profs) do
        v.ProfID = _G.TeamMgr:GetTeamMemberProf(v.RoleID)
    end

    TeamRecruitVM:UpdateEditProfVMList(Profs)
end

function TeamRecruitMgr:OnNetMsgGetSelfRecruitMessage(MsgBody)
    local Data = MsgBody.SelfRecruit and MsgBody.SelfRecruit.Recruit or nil
    self:SetCurrentRecruitInfo(Data)
    self:SetRecruiting(self.IsRecruitOpen(Data))
    self:SetRecruitID(Data and Data.RoleID or nil)

    if self:IsRecruiting() and Data and Data.RoleID == MajorUtil.GetMajorRoleID() then
        if self.TimerIDRecruitTimeout then
           self:UnRegisterTimer(self.TimerIDRecruitTimeout)
           self.TimerIDRecruitTimeout = nil
        end
        local Secs = Data.StartTime + self:GetRecruitConfigTimeoutSeconds() - _G.TimeUtil:GetServerTime()
        local Param = { StartTime = Data.StartTime, RoleID = Data.RoleID }
        if Secs > 0 then
            self.TimerIDRecruitTimeout = self:RegisterTimer( self.OnRecruitTimeout, Secs, nil, nil, Param)
        else
            -- 立即触发超时
            self:OnRecruitTimeout(Param)
        end
    end
end

function TeamRecruitMgr:NetUpdateCurrentRecruit()
    self:QuerySelfRecruitInfo()
end

function TeamRecruitMgr.IsRecruitOpen(Data)
    return Data and Data.State == RECRUIT_STATE.RECRUIT_STATE_OPEN
end

---@private
function TeamRecruitMgr:QuerySelfRecruitInfo()
    if self.IsMouduleOpen() then
        self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_QUERY_SELF, nil, nil)
    end
end

---@private
function TeamRecruitMgr:SetCurrentRecruitInfo(Data)
    if Data then
        self:SetCachedRecruitData(Data)
        TeamRecruitVM.RecruitingDetailVM:UpdateVM(Data)
        local Cfg = TeamRecruitCfg:FindCfgByKey(Data.ID)
        if Cfg and TeamRecruitVM.CurSelectRecruitType == Cfg.TypeID and Data.State == RECRUIT_STATE.RECRUIT_STATE_OPEN then
            TeamRecruitVM:UpdateRecruitItemList({Data}, Cfg.TypeID, true)
        end
    end
    self:SetRecruitID(Data and Data.RoleID or nil)
    TeamRecruitVM:UpdateRecruitItem(Data)
    if Data and Data.RoleID == MajorUtil.GetMajorRoleID() then
        ---@private
       self.MyRecruitCacheData  = Data
    end
end

---@private
function TeamRecruitMgr:SetRecruitID(ID)
    self.RecruitID = ID
    self:LogInfo("TeamRecruitMgr:SetRecruitID %s", tostring(ID))
end

---@private
function TeamRecruitMgr:SetCachedRecruitData(Data)
    self.SelfRecruitData = Data
end

---@private
function TeamRecruitMgr:SetRecruiting(bRecruiting)
    self:LogInfo("TeamRecruitMgr:SetRecruiting %s", tostring(bRecruiting))
    TeamRecruitVM.IsRecruiting = bRecruiting
    local TeamVM = require("Game/Team/VM/TeamVM")
    TeamVM:OnTeamRecruitStateChanged(bRecruiting)

    _G.EventMgr:SendEvent(EventID.TeamRecruitStateChanged)
end

---@private
function TeamRecruitMgr:TipAndShowChat(Content)
    -- local tips
    if TeamMgr:IsInTeam() then
        MsgTipsUtil.ShowTips(Content)
    end
    -- notify to chat Channel
    if TeamMgr:IsInTeam() then
        ChatMgr:AddTeamChatMsg(Content, TeamMgr:GetTeamID(), TeamMgr:GetCaptainID())
    end
end

---创建招募通知
function TeamRecruitMgr:OnNetMsgTeamRecruitCreateNotify(MsgBody)
    self:NetUpdateCurrentRecruit()
    local Msg = MsgBody.CreateNtf
    if nil == Msg or nil == Msg.ID or Msg.ID <= 0 then
        self:SetRecruitID(nil)
        self:LogErr("invalid recruit id")
		return
	end

    self:SetRecruitID(Msg.ID)
    self:SendGetRecruitStateReq({ self.RecruitID })
    
    local Cfg = TeamRecruitCfg:FindCfgByKey(Msg.TaskID)
    if Cfg then
        TeamRecruitVM:SetCurSelectRecruitType(Cfg.TypeID)
        self.bQuerySelfRecruit = true
        self:UIRefreshCurrentRecruit()
    else
        self:LogErr("failed to find recruit cfg id: %s taskid: %s", Msg.ID, Msg.TaskID)
    end
    
    _G.EventMgr:SendEvent(EventID.RecuitCreate, table.makeconst(table.clone(Msg)))

    if Msg.IsUpdate then
        if Cfg then
            local TaskName = Cfg.TaskName
            if not TeamRecruitUtil.IsRecruitUnlocked(Msg.TaskID) then
                TaskName = LSTR(1310006)
            end
            local Msg = string.sformat(_G.LSTR(1320057), TaskName)
            _G.MsgBoxUtil.ShowMsgBoxOneOpRight(self,  _G.LSTR(1310007), Msg, nil, _G.LSTR(1310005), {})
        end
    elseif TeamMgr:IsInTeam() then
        self:TipAndShowChat(LSTR(1310008))
    else
        MsgTipsUtil.ShowTipsByID(301026)
    end

    _G.UIViewMgr:HideView(UIViewID.TeamRecruitEdit)
end

---招募完成通知
function TeamRecruitMgr:OnNetMsgTeamRecruitCompleteNotify(MsgBody)
    local Msg = MsgBody.CompleteNtf
	if nil == Msg then
		return
	end

    TeamRecruitVM:SetHasCompleteRecruit(true)

    self:NetUpdateCurrentRecruit()

    self:TipAndShowChat(LSTR(1310009))
end

---招募关闭通知
function TeamRecruitMgr:OnNetMsgTeamRecruitCloseNotify(MsgBody)
    self:NetUpdateCurrentRecruit()

    local ID = (MsgBody.CloseNtf or {}).ID
    local TipID
    local TipParams = {}
    local Ntf = MsgBody.CloseNtf
    if Ntf then
        if Ntf.ID == MajorUtil.GetMajorRoleID() then
            self.LastRecruitCloseReason = Ntf.Reason
        end

        if Ntf.Reason == ProtoCS.Team.TeamRecruit.CloseReason.CloseReasonEdit then
            TipID = 301035
        elseif Ntf.Reason == ProtoCS.Team.TeamRecruit.CloseReason.CloseReasonTimeout then
            TipID = 301048
            TipParams = { self:GetRecruitConfigTimeoutSeconds() // 60 }
        end
    end

    TeamRecruitVM:OnRecruitClose(ID)
    _G.EventMgr:SendEvent(EventID.RecruitClose, ID)
    if TipID then
        MsgTipsUtil.ShowTipsByID(TipID, nil, table.unpack(TipParams))
    else
        MsgTipsUtil.ShowTips(LSTR(1310010))
    end
end

---加入招募通知
function TeamRecruitMgr:OnNetMsgTeamRecruitJoinNotify(MsgBody)
end

function TeamRecruitMgr:GetSelfRecruitData()
    return self.SelfRecruitData
end

---@deprecated
---打开玩家所在招募详情界面
function TeamRecruitMgr:OpenSelfRecruitDetailView(Params)
    local Data = self:GetSelfRecruitData()
    if Data then
        TeamRecruitVM:UpdateCurRecruitDetailInfo(Data)
        UIViewMgr:ShowView(UIViewID.TeamRecruitDetail, Params)
    end
end

function TeamRecruitMgr:OpenEditOwingRecruitView()
    local Data = self:GetSelfRecruitData()
    if Data then
        local ClonedData = table.clone(Data)
        local Params = ClonedData
        Params.bEditUpdate = true
        self:SendCloseRecruitReq(ProtoCS.Team.TeamRecruit.CloseReason.CloseReasonEdit)
        UIViewMgr:ShowView(UIViewID.TeamRecruitEdit, Params)
    end
end

---跳转到招募详情界面  RecruitID 同招募者RoleID
function TeamRecruitMgr:ShowRecruitDetailView(RecruitID, Params)
    self:QueryRecruitInfoReq( RecruitID,  Params)
end

-------------------------------------------------------------------------------------------------------
---@see 招募分享剪切板

---@class RecruitClipboard 可能为nil
---@field public ResID number @配置表ID
---@field public RoleID number @招募者ID
---@field public IconIDs table @成员图标数组
---@field public CurMemNum table @是否

function TeamRecruitMgr:SetClipboard(RoleID, ResID, IconIDs, LocList, TaskLimit)
    self.RecruitClipboard = TeamRecruitMgr.MakeClipboardData(RoleID, ResID, IconIDs, LocList, TaskLimit)
	MsgTipsUtil.ShowTips(LSTR(1310011))
    _G.UE.UPlatformUtil.ClipboardCopy(ChatUtil.GetTeamRecruitMacro())

end

function TeamRecruitMgr.MakeClipboardData(RoleID, ResID, IconIDs, LocList, TaskLimit)
    return {
        ID = RoleID,
        ResID = ResID,
        IconIDs = IconIDs,
        LocList = LocList,
        TaskLimit = TaskLimit,
    }
end

---@return RecruitClipboard
function TeamRecruitMgr:GetClipboard()
    if self.RecruitClipboard and table.empty(self.RecruitClipboard) then
        return
    end

    return self.RecruitClipboard
end

function TeamRecruitMgr:IsRecruiting()
    return TeamRecruitVM and TeamRecruitVM.IsRecruiting
end

function TeamRecruitMgr:GetLastRecruitCloseReason()
    if not self:IsRecruiting() then
       return self.LastRecruitCloseReason 
    end
end

function TeamRecruitMgr:TryRecoverEditRecruit()
    if self:GetLastRecruitCloseReason() == ProtoCS.Team.TeamRecruit.CloseReason.CloseReasonEdit then
        self:LogInfo("recover recruit %s", MajorUtil.GetMajorRoleID())
        self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_OPEN, "Open", {})
	end
end

function TeamRecruitMgr:IsMajorRecruiting()
    return self:IsRecruiting() and self.RecruitID == MajorUtil.GetMajorRoleID()
end

function TeamRecruitMgr:QueryRelationRecruitRoles(TypeID, RoleIDs)
    if TypeID == nil or #RoleIDs == 0 then
       return 
    end

    self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_QUERY_RELATION, "Relation", {
        RoleIDs = RoleIDs,
        TypeID = TypeID
    })
end

function TeamRecruitMgr:QueryRelationRecruitInfos(TypeID, RoleIDs)
    if TypeID == nil or #RoleIDs == 0 then
       return 
    end

    self.LastTypeQueryInfo[TypeID].N2Time = os.time()
    self.LastTypeQueryInfo[TypeID].N2Roles = RoleIDs

    self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_QUERY_RELATION_INFO, "RelationInfo", {
        RoleIDs = RoleIDs,
        TypeID = TypeID
    })
end


function TeamRecruitMgr:OnNetMsgRelation(MsgBody)
    local Relation = MsgBody.Relation
    if Relation == nil then
       return
    end

    local TypeID = Relation.TypeID
    if TypeID == nil then
        self:LogErr("rev nil type id of relation recruit")
       return
    end

    self:ClearRecruitTimeoutQuery(TypeID)

    local Data = {
        Relation = Relation,
        Time = os.time()
    }

    if self.RelationContent == nil then
        self.RelationContent = {}
    end

    self.RelationContent[TypeID] = Data
    local Total = Data.Relation.Total or 0
    local Info = self.LastTypeQueryInfo and self.LastTypeQueryInfo[TypeID] or nil
    if Info == nil or Info.Offset + 1 > Total then
        if Total == 0 then
            TeamRecruitVM:UpdateRecruitItemList({}, TypeID)
        end
        self:LogWarn("quering exceeds, offset %s, total %s", Info and Info.Offset or nil, Total)
       return 
    end

    local RoleIDs = Data.Relation.RoleIDs or {}
    local N2 = #RoleIDs
    if N2 == 0 or (Info.Offset + 1) > N2 then
        Info.bBanN2 = true
        self:InnerQueryRecruitList(TypeID, Info.Offset)
    else
        local RecruitID
        if self:IsRecruiting() then
            RecruitID = self.RecruitID
        end
        table.sort(RoleIDs, function(a, b)
            if RecruitID == a then
               return true 
            end

            if RecruitID == b then
               return false 
            end

            local FA = _G.FriendMgr:IsFriend(a)
            local FB = _G.FriendMgr:IsFriend(b)
            if FA == FB then
                return a < b
            end
            return FA
        end)

        local RolesToQuery = {}
        for i = Info.Offset + 1, Info.Offset + PAGE_LIMIT * 2 +1 do
            local RoleID = RoleIDs[i]
            if not RoleID then
               break 
            end
            table.insert(RolesToQuery, RoleID)
        end
        if #RolesToQuery == 0 then
            Info.bBanN2 = true
            self:InnerQueryRecruitList(TypeID, Info.Offset)
        else
            self:QueryRelationRecruitInfos(TypeID, RolesToQuery)
            self[GetTimerIDKeyR2(TypeID)] = self:RegisterTimer(function()
                self:LogWarn("N2 query relation recruit infos timeout, type id %s", TypeID)
                self:InnerQueryRecruitList(TypeID, Info.Offset)
            end, TIMEOUT_R2)
        end
    end
end

function TeamRecruitMgr:OnNetMsgRelationRecruitInfos(MsgBody)
    local RelationInfo = MsgBody.RelationInfo
    if RelationInfo == nil then
       return
    end

    local TypeID = RelationInfo.TypeID
    if TypeID == nil then
        self:LogErr("rev nil type id of relation info recruit")
       return
    end

    self:ClearRecruitTimeoutQuery(TypeID)

    local Data = {
        RelationInfo = RelationInfo,
        Time = os.time()
    }

    if self.RelationInfoContent == nil then
       self.RelationInfoContent = {} 
    end
    self.RelationInfoContent[TypeID] = Data

    local Info = self.LastTypeQueryInfo and self.LastTypeQueryInfo[TypeID] or {}
    Info.bBanN2 = nil
    local Offset =  Info.Offset or 0
    for i, v in ipairs(Data.RelationInfo.TeamRecruit or {}) do
        v.OffsetRelationQuery = Offset + i - 1
    end

    local Count = Data.RelationInfo.TeamRecruit and #(Data.RelationInfo.TeamRecruit) or 0
    if Count > 0 then
       TeamRecruitVM:UpdateRecruitItemList(Data.RelationInfo.TeamRecruit, TypeID, true) 
    end
    if Count < PAGE_LIMIT then
        self:InnerQueryRecruitList(TypeID, Offset) 
    end
end

---@private
function TeamRecruitMgr:ClearRecruitTimeoutQuery(TypeID)
    local TimerIDKeyR1 = GetTimerIDKeyR1(TypeID)
    if self[TimerIDKeyR1] then
        self:UnRegisterTimer(self[TimerIDKeyR1])
        self[TimerIDKeyR1] = nil
    end

    local TimerIDKeyR2 = GetTimerIDKeyR2(TypeID)
    if self[TimerIDKeyR2] then
        self:UnRegisterTimer(self[TimerIDKeyR2])
        self[TimerIDKeyR2] = nil
    end
end

function TeamRecruitMgr:GetRelationRecruitList(TypeID)
    if TypeID == nil or self.RelationInfoContent == nil then
       return {} 
    end

    local Data =  self.RelationInfoContent[TypeID]
    if Data == nil or Data.Time == nil or (os.time() - Data.Time) > 3 then
       return {} 
    end

    return Data.RelationInfo.TeamRecruit
end

---@private
---@param SubMsgID number
---@param Key string | nil
---@param Body table
---@param MsgID number | nil
function TeamRecruitMgr:EasySendMsg(SubMsgID, Key, Body, MsgID)
    local Data = {SubCmd = SubMsgID,}
    if Key then
        Data[Key] = Body
    end
    _G.GameNetworkMgr:SendMsg(MsgID or CS_CMD.CS_CMD_TEAM_RECRUIT, SubMsgID, Data)
end

function TeamRecruitMgr:GetRelationRoleIDs()
    local function InsertFunc(t, RoleID)
        local MajorID = MajorUtil.GetMajorRoleID()
        if not TeamMgr:IsTeamMemberByRoleID(RoleID) and RoleID ~= MajorID then
			table.insert(t, RoleID)
		end
    end

    local Friends = {}
    for _, v in ipairs(_G.FriendMgr:GetAllFriends() or {}) do
        InsertFunc(Friends, v.RoleID)
    end

    local ArmyRoles = {}
    for _, RoleID in ipairs(_G.ArmyMgr:GetArmyAllMemberRoleID() or {}) do
		InsertFunc(ArmyRoles, RoleID)
	end

    return table.keys(table.makeset(Friends, ArmyRoles))
end

---@private
function TeamRecruitMgr:GetOnlineRelationRoleIDs()
    return _G.RoleInfoMgr:GetOnlineRolesAndUpdate(self:GetRelationRoleIDs())
end

function TeamRecruitMgr.IsMouduleOpen()
    local ProtoCommon = require("Protocol/ProtoCommon")
    return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDTeamRecruit)
end

function TeamRecruitMgr:QueryRecruitList(TypeID, Offset)
    if not self.IsMouduleOpen() then
        return 
    end

    if TypeID == nil then
       return 
    end

    self:ClearRecruitTimeoutQuery(self.QueryingTypeID)
    self.QueryingTypeID = TypeID
    self:ClearRecruitTimeoutQuery(TypeID)

    if self.LastTypeQueryInfo == nil then
        self.LastTypeQueryInfo = {}
    end
    local V = self.LastTypeQueryInfo[TypeID] or {}
    self.LastTypeQueryInfo[TypeID] = V
    V.Offset = Offset
    V.N1Time = os.time()

    self.RelationRoleIDs = self:GetOnlineRelationRoleIDs()
    local N1 = #self.RelationRoleIDs
    if self.bQuerySelfRecruit or self:IsRecruiting() then
        local RecruitID = self.RecruitID
        if RecruitID ~= nil then
            table.array_add_unique(self.RelationRoleIDs, RecruitID)
        end
        if RecruitID ~= MajorUtil.GetMajorRoleID() then
            table.array_add_unique(self.RelationRoleIDs, MajorUtil.GetMajorRoleID())
        end
       self.bQuerySelfRecruit = nil 
    end

    if N1 == 0 or (Offset + 1 > N1) then
        if self.RelationInfoContent then
            self.RelationInfoContent[TypeID] = nil
        end
        self:InnerQueryRecruitList(TypeID, Offset)
    else
        if self:GetRecruitingTypeID() == TypeID then
            table.array_add_unique(self.RelationRoleIDs, self.RecruitID)
        end
        self:QueryRelationRecruitRoles(TypeID, self.RelationRoleIDs)
        self[GetTimerIDKeyR1(TypeID)] = self:RegisterTimer(function()
            self:LogWarn("query recruit list N1 timeout, TypeID: %s, Offset: %s", TypeID, Offset)
            self:InnerQueryRecruitList(TypeID, Offset)
        end, TIMEOUT_R1)
    end
end

---@private
function TeamRecruitMgr:InnerQueryRecruitList(TypeID, Offset, Limit)
    if TypeID then
        if self.LastTypeQueryInfo == nil then
            self.LastTypeQueryInfo = {}
        end

        if self.LastTypeQueryInfo[TypeID] == nil then
            self.LastTypeQueryInfo[TypeID] = {}
        end

        self.LastTypeQueryInfo[TypeID].PageQueryTime = os.time()
    end

    self:EasySendMsg(SUB_MSG_ID.CS_SUBMSGID_TEAM_RECRUIT_GET_LIST, "RecruitList", {
            TypeID  = TypeID,
            Offset  = Offset,
            Limit   = Limit or PAGE_LIMIT, 
        })
end

function TeamRecruitMgr:IsInRelationCacheInterval()
    return false
end

function TeamRecruitMgr:UIRefreshCurrentRecruit()
    self:QueryRecruitList(TeamRecruitVM.CurSelectRecruitType, 0)
end

function TeamRecruitMgr:GetRecruitingTypeID()
    local Cfg = self:GetRecruitingCfg()
    if Cfg then
        return Cfg.TypeID
    end
end

function TeamRecruitMgr:GetRecrutingContentID()
    if self:IsRecruiting() and self.SelfRecruitData then
        return self.SelfRecruitData.ID
     end
end

function TeamRecruitMgr:GetRecruitingCfg()
    return TeamRecruitCfg:FindCfgByKey(self:GetRecrutingContentID())
end

function TeamRecruitMgr:GetRecruitingTypeCfg()
    local TeamRecruitTypeCfg = require("TableCfg/TeamRecruitTypeCfg")
    return TeamRecruitTypeCfg:GetRecruitTypeInfo(self:GetRecruitingTypeID())
end

function TeamRecruitMgr:OnRecruitListScrollToEnd()

    local TypeID = TeamRecruitVM.CurSelectRecruitType
    if TypeID == nil then
       return 
    end

    if TeamRecruitVM.ViewingRecruitItemVMList == nil then
       return 
    end
    
    if self:IsInTimeQueryInterval(TypeID) then
       return 
    end

    local _, Offset = self:GetCurRecruitOffsetMinMax()

    self:QueryRecruitList(TypeID, Offset + 1)
end

function TeamRecruitMgr:OnRecruitListScrollToTop()
    if self:IsInTimeQueryInterval(TeamRecruitVM.CurSelectRecruitType) then
        return
    end

    self:TryScrollUp()
end

function TeamRecruitMgr:TryScrollUp()
    local TypeID = TeamRecruitVM.CurSelectRecruitType
    if TypeID == nil then
       return 
    end

    if TeamRecruitVM.ViewingRecruitItemVMList == nil then
        return 
     end

     if self:IsInTimeQueryInterval(TypeID) then
        return
    end

    local Offset = self:GetCurRecruitOffsetMinMax()

    if Offset > 0 then
        local QueryOffset = Offset - PAGE_LIMIT
        if QueryOffset < 0 then
           QueryOffset = 0 
        end
        self:QueryRecruitList(TypeID, QueryOffset)
    end
end

function TeamRecruitMgr:GetCurRecruitOffsetMinMax()
    if TeamRecruitVM.ViewingRecruitItemVMList == nil then
        return 0, 0
    end

    local Items = TeamRecruitVM.ViewingRecruitItemVMList:GetItems()
    if #Items == 0 then
        return 0, 0
    end

    local OffsetMax = 0
    local OffsetMin = math.maxinteger
    for _, v in ipairs(Items) do
        local ROff = v.OffsetQuery or v.OffsetRelationQuery  or 0
        if ROff > OffsetMax then
           OffsetMax = ROff 
        end
        if ROff < OffsetMin then
           OffsetMin = ROff 
        end
    end

    return OffsetMin, OffsetMax
end

function TeamRecruitMgr:IsCurOnRecruitLastPage(InTypeID)
    local TypeID = InTypeID or TeamRecruitVM.CurSelectRecruitType
    if TypeID == nil then
       return 
    end

    local _, Offset = self:GetCurRecruitOffsetMinMax()
    local Data = self.RelationContent and self.RelationContent[TypeID]
    local TotalNum
    if Data then
        TotalNum = Data.Relation.Total or 0
    end

    if TotalNum then
       return math.ceil(TotalNum / PAGE_LIMIT) == math.ceil((Offset +1) / PAGE_LIMIT) or math.abs(TotalNum - Offset - 1) < 3
    end
end


function TeamRecruitMgr:IsInTimeQueryInterval(TypeID)
    if TypeID == nil then
        return true
    end
    local LastQueryTime = 0
    if self.LastTypeQueryInfo then
        local V = self.LastTypeQueryInfo[TypeID] or {}
        LastQueryTime =  math.max(V.N1Time or 0, LastQueryTime)
        LastQueryTime =  math.max(V.PageQueryTime or 0, LastQueryTime)
    end

    return os.time() - LastQueryTime < 3
end

function TeamRecruitMgr:AddChatShareCallback(ChatType, RoleID, Callback)
    if type(Callback) ~= "function" then
        return
    end

    if ChatType == nil or RoleID == nil or RoleID == 0 then
       return 
    end

    if self.TimerIDTimeoutChatShare then
       self:UnRegisterTimer(self.TimerIDTimeoutChatShare) 
    end

    self.TimerIDTimeoutChatShare = self:RegisterTimer(function()
        self.ChatShareCallbackData = nil
    end, 3)
    self.ChatShareCallbackData = {
        Callback = Callback,
        ChatType = ChatType,
        RoleID = RoleID
    }
end

function TeamRecruitMgr:InChatShareThresould(RoleID)
    if self.RecruitShareToPerson and RoleID then
       local Data = self.RecruitShareToPerson[RoleID]
       if Data then
            return os.time() - Data.Time <= 5 
       end
    end
end

function TeamRecruitMgr:AddRecruitShareTipTimer(RoleID)
    if RoleID then
        if self.RecruitShareWaitTip == nil then
            self.RecruitShareWaitTip = {}
        end
        self.RecruitShareWaitTip[RoleID] = os.time()
        
        if self.TimerIDClearRecruitShareWaitTip then
            self:UnRegisterTimer(self.TimerIDClearRecruitShareWaitTip)
        end
        self.TimerIDClearRecruitShareWaitTip = self:RegisterTimer(function ()
            self.RecruitShareWaitTip = nil
        end, 5)
    end
end

function TeamRecruitMgr:OnRecruitTimeout(Param)
    if not self.SelfRecruitData or not self:IsRecruiting() then
       return 
    end

    if self.RecruitID == MajorUtil.GetMajorRoleID() and self.RecruitID == Param.RoleID and Param.StartTime == self.SelfRecruitData.StartTime then
        self:LogInfo("recruit timeout, close recruit %s start time %s", self.RecruitID, Param.StartTime)
        self:SendCloseRecruitReq(ProtoCS.Team.TeamRecruit.CloseReason.CloseReasonTimeout)
    end
end

function TeamRecruitMgr:GetRecruitConfigTimeoutSeconds()
    local Cfg = RecruitParamsCfg:FindCfgByKey(1)
    if Cfg then
        return Cfg.Value[1] or 3600
    end

    return 3600
end

return TeamRecruitMgr