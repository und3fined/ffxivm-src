--
-- Author: anypkvcai
-- Date: 2020-11-04 16:57:14
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local TeamVM = require("Game/Team/VM/TeamVM")
local ProtoRes = require("Protocol/ProtoRes")
local PworldCfg = require("TableCfg/PworldCfg")
local MsgTipsID = require("Define/MsgTipsID")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local ATeamMgr = require("Game/Team/Abs/ATeamMgr")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local TimeUtil = require("Utils/TimeUtil")
local TableTools = require("Common/TableTools")
local GlobalCfg = require("TableCfg/GlobalCfg")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local AudioUtil = require("Utils/AudioUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local UIViewMgr
local EventMgr
local RoleInfoMgr
local PWorldMgr
local GameNetworkMgr

local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Team.Team.CS_SUBMSGID_TEAM

local TeamBroadcastType = ProtoCS.Team.Team.TeamBroadcastType
local InviteSidebarType = SidebarDefine.SidebarType.TeamInvite
local MemPropUpdateDef = ProtoCS.Team.Team.MemPropUpdate


---@class TeamMgr : ATeamMgr
local TeamMgr = LuaClass(ATeamMgr)

local TeamRecruitMgr
local TeamInviteStatus = {}
local LastTeamInviteQueryRoles = nil

function TeamMgr:OnInit()
    self.Super.OnInit(self)

	self.ChatChannelType = ChatDefine.ChatChannel.Team 

	self:SetLogName("NormalTeamMgr")
end

function TeamMgr:OnBegin()
	UIViewMgr = _G.UIViewMgr
	EventMgr = _G.EventMgr
	RoleInfoMgr = _G.RoleInfoMgr
	PWorldMgr = _G.PWorldMgr
	GameNetworkMgr = _G.GameNetworkMgr
	TeamRecruitMgr = _G.TeamRecruitMgr

    self.Super.OnBegin(self)
	self:SetTeamVM(TeamVM)
end


function TeamMgr:OnRegisterNetMsg()
    self.Super.OnRegisterNetMsg(self)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_LEAVE, self.OnNetMsgTeamLeave)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_DESTROY, self.OnNetMsgTeamDestroy)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_INVITE_JOIN, self.OnNetMsgTeamInviteJoin)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_ANSWER_INVITE, self.OnNetMsgTeamAnswerInvite)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_SET_CAPTAIN, self.OnNetMsgTeamSetCaptain)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_UPDATE_MEMBER, self.OnNetMsgTeamUpdateMember)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_KICK_MEMBER, self.OnNetMsgTeamKickMember)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_QUERY_TEAM, self.OnNetMsgTeamQueryTeam)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_BROADCAST, self.OnMsgMemStatChg)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CsSubCmdTeamQueryRoleInfo, self.OnNetMsgTeamRoleInfo)

	-- Ntf
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_JOIN_NOTIFY, self.OnNetMsgTeamJoinNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_LEAVE_NOTIFY, self.OnNetMsgTeamLeaveNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_DESTROY_NOTIFY, self.OnNetMsgTeamDestroyNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_INVITEJOIN_NOTIFY, self.OnNetMsgTeamInviteJoinNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_CAPTAINCHANGED_NOTIFY, self.OnNetMsgTeamCaptainChangeNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_TASKCHANGED_NOTIFY, self.OnNetMsgTeamTaskChangeNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_REFUSE_INVITE_NOTIFY, self.OnNetMsgTeamRefuseInviteNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CS_SUB_CMD_TEAM_MEMBER_DATA_NTF, self.OnNetMsgTeamMemberDataNotify)
end

function TeamMgr:OnRegisterGameEvent()
    self.Super.OnRegisterGameEvent(self)

    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGameEventSidebarItemTimeOut) --侧边栏Item超时
	self:RegisterGameEvent(EventID.PWorldRoleSceneData, self.OnNetMsgRoleData)
	self:RegisterGameEvent(EventID.QueryRoleInfo, self.OnQueryInviterRoleInfoDataUpdate)
end

function TeamMgr:OnGameEventSidebarItemTimeOut( Type, TransData )
    if Type ~= InviteSidebarType then
        return
    end

	self:ClearInvitePopUpInfo()
end

-------------------------------------------------------------------------------------------------------
---@see EventHandles

function TeamMgr:OnGameEventPWorldMapEnter(Params)
	self.TeamVM:UpdateTeamMembers(self.MemberList or {})
end

function TeamMgr:OnGameEventLoginRes(Params)
	self.RecvTeamMsgCount = 0
	self.LoginCount = (self.LoginCount or 0) + 1

	self:SendQueryTeamReq()
	self:SendQueryTeamRoleInfo()
end

function TeamMgr:OnGameEventWorldPostLoad(Params)
	if PWorldMgr:IsTransInSameMap() then
		return
	end

	local CurrPWorldResID = PWorldMgr:GetCurrPWorldResID()
	local Type = PworldCfg:FindValue(CurrPWorldResID, "Type")
	if ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON == Type then
		self:ClearInviteInfo()

		local MapID = PworldCfg:GetFirstMapID(CurrPWorldResID)
		if MapID ~= PWorldMgr:GetCurrMapResID() then
			return
		end

		local Num = self.TeamVM:GetMemberNum()
		if Num == 4 then
			self:ShowTeamTips(true)
		elseif Num == 8 then
			local function Callback()
				self:ShowTeamTips(false)
			end
			self:ShowTeamTips(true)
			self:RegisterTimer(Callback, 2.4)
		end
	end

	--self.TeamVM:OnPostLoadWorld()
end

-------------------------------------------------------------------------------------------------------
---@see NetMsgHandles


--离开队伍操作回包 自己也会收到LeaveNotify的消息
function TeamMgr:OnNetMsgTeamLeave(MsgBody)
	local Msg = MsgBody.Leave
	if nil == Msg then
		return
	end
end

--解散队伍回包 自己也会收到DestroyNotify
function TeamMgr:OnNetMsgTeamDestroy(MsgBody)
	local Msg = MsgBody.Destroy
	if nil == Msg then
		return
	end

end

function TeamMgr:OnNetMsgTeamInviteJoin(MsgBody)
	local Msg = MsgBody.InviteJoin
	if nil == Msg then
		return
	end

	self:SendQueryTeamRoleInfo({Msg.RoleID})
	EventMgr:SendEvent(EventID.TeamInviteJoin, Msg.RoleID)

	RoleInfoMgr:QueryRoleSimple(Msg.RoleID, function(_, RVM)
        if nil == RVM or string.isnilorempty(RVM.Name) then
            return
        end

		self:ShowTipsByID(103076,RVM.Name)
	end)
end

function TeamMgr:OnNetMsgTeamAnswerInvite(MsgBody)
	local Msg = MsgBody.AnswerInvite
	if nil == Msg then
		return
	end

	local ErrCode = Msg.ErrCode or 0
	local SidebarItem = SidebarMgr:GetSidebarItemVM(InviteSidebarType)
	if ErrCode > 0 or (SidebarItem and SidebarItem.TransData and (SidebarItem.TransData.TeamID == MsgBody.TeamID or (SidebarItem.TransData.CaptainRoleID == Msg.RoleID and Msg.RoleID)))  then
		self:ClearInvitePopUpInfo()
	end

	if  Msg.IsAgree and ErrCode == 0 then
		local RVM = MajorUtil.GetMajorRoleVM(true)
		if RVM then
			self:ShowTipsByID(103068, RVM.Name)
		end

		self.CacheCheckRoleID = Msg.RoleID
		_G.RoleInfoMgr:SendQueryInfoByRoleID(self.CacheCheckRoleID)
	end

	if  ErrCode > 0 then
		MsgTipsUtil.ShowTipsByID(ErrCode)
	end
end

function TeamMgr:OnNetMsgTeamSetCaptain(MsgBody)
	local Msg = MsgBody.SetCaptain
	if nil == Msg then
		return
	end

end

function TeamMgr:OnNetMsgTeamUpdateMember(MsgBody)
	local Msg = MsgBody.UpdateMember
	if nil == Msg then
		return
	end

	self:UpdateMemberState(Msg.UpdateProp)

	EventMgr:SendEvent(EventID.TeamMemberInfoUpate, self)
end

function TeamMgr:OnNetMsgTeamKickMember(MsgBody)
	if MsgBody.TeamID ~= self.TeamID then
		return
	end

	local Msg = MsgBody.KickMemberRsp
	if nil == Msg then
		return
	end

	if TableTools.RemoveTableElement(self.MemberList, Msg.RoleID) ~= nil then
		self.TeamVM:UpdateTeamMembers(self.MemberList)
	end
end

function TeamMgr:OnNetMsgTeamQueryTeam(MsgBody)
	self.RecvTeamMsgCount = (self.RecvTeamMsgCount or 0) + 1

	local TeamData = MsgBody.QueryTeam
	if nil == TeamData then
		return
	end

	local Team = TeamData.T
	local bValidTeam = not (nil == Team or Team.TeamID == nil or Team.TeamID == 0)
	if bValidTeam then
		self:UpdateTeam(Team.TeamID, Team.Captain, Team.MemberList)
		if self:IsInTeam() then
			self:ClearInviteInfo()
		end
	else
		self:OnLeaveTeam()
	end

	TeamRecruitMgr:NetUpdateCurrentRecruit()

	_G.EventMgr:SendEvent(EventID.TeamQueryFinish)

	if not self:IsInTeam() then
		self.LastUpdateOnlineStatusInfo = nil
	end

	if not _G.PWorldMgr:CurrIsInDungeon() then
        local RoleIDs = self:GetMemberRoleIDList()
		table.array_remove_item_pred(RoleIDs,function(v)
			return v == MajorUtil.GetMajorRoleID()
		end)
		if #RoleIDs > 0 then
			_G.PWorldMgr:QueryRoleSceneData(RoleIDs)
		end
    end
end

function TeamMgr:OnNetMsgTeamJoinNotify(MsgBody)
	local Msg = MsgBody.JoinMemberNotify
	if nil == Msg then
		return
	end

	TeamRecruitMgr:NetUpdateCurrentRecruit()

	local NewMember = Msg.NewMember
	if nil == NewMember then
		return
	end

	if MsgBody.TeamID ~= self:GetTeamID() then
		return
	end

	self:AddTeamMember(NewMember)

	if not self:IsCaptainByRoleID(NewMember.RoleID) then
		RoleInfoMgr:QueryRoleSimple(NewMember.RoleID, function(_, VM)
			self:ShowTipsByID(103068, VM.Name)
		end)
	end
end

function TeamMgr:OnMsgMemStatChg(MsgBody)
	local Msg = MsgBody.TeamBroadcast
	if Msg.Type == TeamBroadcastType.TeamMemStateChg then
		local MemStateChg = Msg.MemStateChg
		local RoleID = MemStateChg.MemID
		local ChgType = MemStateChg.Type
		local VM = self.FindRoleVM(RoleID, true)
		local bIsMajor = RoleID == MajorUtil.GetMajorRoleID()
		self:LogInfo("set mem state for %s: %s, major?%s", RoleID, self.ToTableStringSafe(MsgBody), bIsMajor)
		if bIsMajor or RoleID == nil then
			return
		end

		local MemStateType = ProtoCS.Team.Team.MemStateType
		if ChgType == MemStateType.MemStateTypeLogin then -- 登入
			VM:SetTeamMemberOnline(true)
			self:UpdateMemberProps(RoleID, {"IsOnline",}, {true,})
		elseif ChgType == MemStateType.MemStateTypeLogout then -- 登出
			VM:SetTeamMemberOnline(false)
			self:UpdateMemberProps(RoleID, {"IsOnline",}, {false,})
		elseif ChgType == MemStateType.MemStateTypeEnterScene then -- 且场景
			if not (MemStateChg.Scene and MemStateChg.Scene.SceneResID and MemStateChg.Scene.MapResID) then
				self:LogErr('invalid scene data for role %s', RoleID)
			end
			VM:SetTeamMemberMapData(MemStateChg.Scene)
		elseif ChgType == MemStateType.MemStateTypeDie then -- 死亡
			-- nothing now
		elseif ChgType == MemStateType.MemStateTypeRevive then -- 复活
			-- nothing now
		elseif ChgType == MemStateType.MemStateDisplayTag then 
			if type(MemStateChg.DisplayTag) == 'number' then
				VM:SetOnlineStatus(MemStateChg.DisplayTag)
				_G.EventMgr:SendEvent(_G.EventID.TeamMemberOnlineStatus, RoleID, MemStateChg.DisplayTag)
				if self.LastUpdateOnlineStatusInfo == nil then
					self.LastUpdateOnlineStatusInfo = {}
				end
				self.LastUpdateOnlineStatusInfo[RoleID] = TimeUtil.GetLocalTimeMS()
			else 
				self:LogErr("invalid online status %s for role %s", MemStateChg.DisplayTag, RoleID)
			end
		end
	elseif Msg.Type == TeamBroadcastType.TeamMemCrossWorld then
		local CrossWordData = Msg.CrossWorld
		local RoleID = CrossWordData.RoleID
		local VM = self.FindRoleVM(RoleID, true)
		if VM then
			VM:SetCrossZoneWorldID(CrossWordData.CrossWorldID)
		end

		self:RegisterTimer(function()
			--- 防止被rolesimple的不及时信息覆盖 延迟重新请求下即时的
			RoleInfoMgr:SendQueryInfoByRoleID(RoleID)
		end, 1.5, 0, 1)
	end
end

function TeamMgr:GetLastOnlineStatusSyncTime(RoleID)
	if self.LastUpdateOnlineStatusInfo == nil then
		return 0
	end

	return self.LastUpdateOnlineStatusInfo[RoleID] or 0
end

function TeamMgr:OnMsgReconnectInvite(MsgBody)
	-- left empty now
end

function TeamMgr:OnNetMsgTeamLeaveNotify(MsgBody)
	local Msg = MsgBody.LeaveMemberNotify
	if nil == Msg then
		return
	end

	TeamRecruitMgr:NetUpdateCurrentRecruit()
	local LeaveMember = Msg.LeaveMember
	if nil == LeaveMember then
		return
	end

	if MsgBody.TeamID ~= self:GetTeamID() then
		return
	end

	if LeaveMember.RoleID == MajorUtil.GetMajorRoleID() then
		self:OnLeaveTeam()
		self:TipContentAndAddSysChat(LSTR(1300001))
	else
		self:RemoveTeamMember(LeaveMember)
		if TeamRecruitUtil.CanReRecruitMem() then
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1300002), LSTR(1300003), function()
				UIViewMgr:ShowView(UIViewID.TeamRecruitEdit, _G.TeamRecruitMgr:GetSelfRecruitData())
			end)
		end
	end
end

--队伍解散 服务也下发destroyTeamNotify
function TeamMgr:OnNetMsgTeamDestroyNotify(MsgBody)
	local Msg = MsgBody.DestroyTeamNotify
	if nil == Msg then
		return
	end

	TeamRecruitMgr:NetUpdateCurrentRecruit()

	if MsgBody.TeamID ~= self:GetTeamID() then
		self:LogErr("destory a non-exist team self team: %s, team to destory: %s", self:GetTeamID(), MsgBody.TeamID)
		return
	end

	self:OnLeaveTeam()

	self:TipContentAndAddSysChat(LSTR(1300004))
end

function TeamMgr:OnNetMsgTeamInviteJoinNotify(MsgBody)
	local Msg = MsgBody.InviteJoinNotify
	if nil == Msg or nil == Msg.Captain then
		return
	end

	self:ClearInvitePopUpInfo()

	if not Msg.CancelInvite then
		local Data = {}
		Data.TeamID 		= MsgBody.TeamID
		Data.CaptainRoleID 	= Msg.Captain.RoleID

		local MemberIDList = Msg.MemberID
		if #Msg.MemberID <= 0 then
			MemberIDList 	= { Data.CaptainRoleID }
		end

		local function QueryCallback()
			local ProfIDList = {}
			for _, v in ipairs(MemberIDList) do
				local RoleVM = self.FindRoleVM(v, true)
				if RoleVM then
					table.insert(ProfIDList, RoleVM.Prof)
				end
			end

			Data.MemberProfIDList = ProfIDList
			SidebarMgr:AddSidebarItem(InviteSidebarType, Msg.StartTime or TimeUtil.GetServerTime(), GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_TEAM_BE_INVITE_LIST_TIMEOUT).Value[1], Data)
			AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_notice_new.Play_SE_UI_SE_UI_notice_new'")
		end

		_G.RoleInfoMgr:QueryRoleSimples(MemberIDList, QueryCallback, nil, true)
	end
end

function TeamMgr:OnNetMsgTeamCaptainChangeNotify(MsgBody)
	local Msg = MsgBody.CaptainChangedNotify
	if nil == Msg then
		return
	end

	self:SetCaptainByRoleID(Msg.NewCaptain)

	-- tips #TODO REPLACE WITH ENUMS
	local RVM = self.FindRoleVM(Msg.NewCaptain, true)
	local TipsID = nil
	local Reason = Msg.Reason
	if Reason == 3 then
		TipsID = 103085
	elseif Reason == 2 then
		TipsID = 103086
	end

	self:ShowTipsByID(TipsID or 103064, RVM.Name)
end

function TeamMgr:OnNetMsgTeamTaskChangeNotify(MsgBody)
	local Msg = MsgBody.TaskChangedNotify
	if nil == Msg then
		return
	end
end

function TeamMgr:OnNetMsgTeamRefuseInviteNotify(MsgBody)
	local Msg = MsgBody.RefuseInviteNotify
	if nil == Msg then
		return
	end

	local function Callback(_, RVM)
		MsgTipsUtil.ShowTipsByID(103078, nil, RVM.Name)
	end

	TeamInviteVM:RemoveInvitedRole(Msg.RoleID)

	_G.EventMgr:SendEvent(EventID.TeamJoinReject, Msg.RoleID)
	self:SendQueryTeamRoleInfo({Msg.RoleID})
	RoleInfoMgr:QueryRoleSimple(Msg.RoleID, Callback)

end

function TeamMgr:IsInInviate(RoleID)
	return TeamInviteStatus[RoleID] and TimeUtil.GetServerTime() < (TeamInviteStatus[RoleID].BeInvitedExpiredTime or 0)
end

function TeamMgr:OnQueryInviterRoleInfoDataUpdate(RoleID)
	if self.CacheCheckRoleID and self.CacheCheckRoleID == RoleID then
		local MajorRoleWorldID = (MajorUtil.GetMajorRoleVM() or {}).CurWorldID or 0 
		local CaptainRoleWorldID = (_G.RoleInfoMgr:FindRoleVM(RoleID) or {}).CurWorldID or 0 
		if MajorRoleWorldID ~= CaptainRoleWorldID then
			local CrossWorldUtil = require("Utils/CrossWorldUtil")
			CrossWorldUtil.CrossWorldWithoutCrtstal(CaptainRoleWorldID, LSTR(1530011), LSTR(1530012), nil, nil, RoleID)
		end

		self.CacheCheckRoleID = nil
	end
end

function TeamMgr:OnNetMsgTeamRoleInfo(Msg)
	local Rs = {}
	if Msg.RoleInfo and Msg.RoleInfo.RoleInfos then
		for _, v in pairs(Msg.RoleInfo.RoleInfos) do
			TeamInviteStatus[v.RoleID] = v
			Rs[v.RoleID] = v
		end
	end
	for _, RoleID in pairs(LastTeamInviteQueryRoles or {}) do
		if Rs[RoleID] == nil then
			TeamInviteStatus[RoleID] = nil
		end
	end
	_G.EventMgr:SendEvent(EventID.TeamInviteUpdate)
end

function TeamMgr:OnNetMsgRoleData(Msg)
	if Msg == nil or Msg.QueryRole == nil or Msg.QueryRole.Datas == nil then
		return
	end

	if _G.PWorldMgr:CurrIsInDungeon() then
		self:LogWarn("reject role online status while on pworld")
		return
	end

	local SceneRoles = {}
	for _, v in ipairs(Msg.QueryRole.Datas) do
		self:LogInfo("update role online status, %s: %s", v.RoleID, v.DisplayTag)
		self:InnerUpdateOnlineStatus(v.RoleID, v.DisplayTag)
		table.insert(SceneRoles, v.RoleID)
	end

	if not self:IsInTeam() then
		return
	end

	local OutRoleIDs = {}
	for _, RoleID in self:IterTeamMembers() do
		if RoleID and RoleID ~= 0 and table.find_item(SceneRoles, RoleID) == nil and RoleID ~= MajorUtil.GetMajorRoleID() then
			table.insert(OutRoleIDs, RoleID)
		end
	end
	
	if #OutRoleIDs > 0 then
		self:LogInfo("init query for role onlinestatus, login %s", self.LoginCount)
		_G.RoleInfoMgr:QueryRoleSimples(OutRoleIDs, function(Param) 
			if self.LoginCount ~= Param.LoginCount or _G.PWorldMgr:CurrIsInDungeon() or not self:IsInTeam() then
				return
			end

			local ActorUtil = require("Utils/ActorUtil")
			for _, RoleID in ipairs(Param.RoleIDs) do
				if self:IsTeamMemberByRoleID(RoleID) and self:GetLastOnlineStatusSyncTime(RoleID) < Param.Time then
					local EID = ActorUtil.GetEntityIDByRoleID(RoleID)
					if EID == nil or EID == 0 then
						local VM = self.FindRoleVM(RoleID, true)
						if VM then
							self:LogInfo("init with rolevm online status %s: %s, login %s", RoleID, VM.OnlineStatus, self.LoginCount)
							self:InnerUpdateOnlineStatus(RoleID, VM.OnlineStatus)
						end
					end
				end
			end
		end, {RoleIDs=OutRoleIDs, LoginCount=self.LoginCount, Time=TimeUtil.GetLocalTimeMS()}, false)
	end
end


local TimeQueryTeamRoleInfo = 0
function TeamMgr:QueryTeamRoleInfoTimed(RoleIDs)
	local t = TimeUtil.GetLocalTime()
	if t - TimeQueryTeamRoleInfo >= 3 then
		TimeQueryTeamRoleInfo = t
		self:SendQueryTeamRoleInfo(RoleIDs)
	end
end


function TeamMgr:SendQueryTeamRoleInfo(RoleIDs)
	LastTeamInviteQueryRoles = RoleIDs
	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CsSubCmdTeamQueryRoleInfo
	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.RoleInfo = {
		RoleIDs = RoleIDs or {},
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function TeamMgr:SendCreateTeamReq(TaskID)
	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_CREATE

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = 0
	MsgBody.Create = { TaskID = TaskID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@private
function TeamMgr:SendLeaveTeamReq(RoleID, TeamID, Reason)
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_TEAM_LEAVE, true) then
		self:LogWarn("unable to leave team for behavior check failed")
		return
	end

	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_LEAVE

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = TeamID
	MsgBody.Leave = { RoleID = RoleID, Reason = Reason }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@private
function TeamMgr:SendDestroyTeamReq(TeamID)
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_TEAM_DESTROY, true) then
		self:LogWarn("unable to destroy team for behavior check failed")
		return
	end

	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_DESTROY

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = TeamID
	MsgBody.Destroy = {}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function TeamMgr:SendInviteJoinReq(TeamID, RoleID, Source)
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_TEAM_INVITE, true) then
		self:LogWarn("unable to invite for behavior check failed")
		return
	end

	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_INVITE_JOIN

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = TeamID
	MsgBody.InviteJoin = { 
		RoleID = RoleID , 
		Source = Source and Source or ProtoCS.Team.Team.ReqSource.ReqSourceUnknown
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---SendAnswerInviteReq
---@param TeamID number
---@param IsAgree boolean
function TeamMgr:SendAnswerInviteReq(TeamID, IsAgree, RoleID)
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_TEAM_ANSWER_INVITE, true) then
		self:LogWarn("unable to answer invite for behavior check failed")
		return
	end

	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_ANSWER_INVITE

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = TeamID
	MsgBody.AnswerInvite = { IsAgree = IsAgree, RoleID = RoleID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function TeamMgr:SendSetCaptainReq(TeamID, NewCaptain)
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_TEAM_SET_CAPTAIN, true) then
		self:LogWarn("unable to change captain for behavior check failed")
		return
	end

	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_SET_CAPTAIN

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = TeamID
	MsgBody.SetCaptain = { NewCaptain = NewCaptain }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function TeamMgr:SendModifyTeamTaskReq(TeamID, NewTaskID)
	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_TASKCHANGED_NOTIFY

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = TeamID
	MsgBody.ModifyTeamTask = { NewTaskID = NewTaskID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function TeamMgr:SendKickMemberReq(TeamID, RoleID)
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_TEAM_KICK_MEMBER, true) then
		self:LogWarn("unable to kick member for behavior check failed")
		return
	end

	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_KICK_MEMBER

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = TeamID
	MsgBody.KickMember = { RoleID = RoleID }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function TeamMgr:SendQueryTeamReq()
	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_QUERY_TEAM

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = 0

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function TeamMgr:ClearInvitePopUpInfo()
	--删除侧边栏VM数据
	SidebarMgr:RemoveSidebarItem(InviteSidebarType)
end

---@deprecated
function TeamMgr:ClearInviteInfo()
	self:ClearInvitePopUpInfo()
end

-- Team&Member
function TeamMgr:ShowTeamTips(Is4Player)
	if _G.PWorldMgr:CurrIsInDungeon() or (self.RecvTeamMsgCount or 0) <= 1 then
		return
	end

	if Is4Player then
		self:ShowTipsByID(MsgTipsID.TeamMemberNum4)
	else
		self:ShowTipsByID(MsgTipsID.TeamMemberNum8)
	end
end

function TeamMgr:OnLeaveTeam()
	self:QutiVoiceRoom()

	local OldTeamID = self:GetTeamID()
	self:SetTeamID(nil)
	self:SetCaptainByRoleID(nil)
	self.MemberList = {}
	self:OnUpdateMember()
	-- notify a team leave
	EventMgr:SendEvent(EventID.TeamLeave, self, OldTeamID)
end

function TeamMgr:CheckCanOpTeam(ShowTips)
	local CurrPWorldResID = PWorldMgr:GetCurrPWorldResID()

	local CanOpTeam = PworldCfg:FindValue(CurrPWorldResID, "CanOpTeam")
	CanOpTeam = nil ~= CanOpTeam and CanOpTeam > 0

	if not CanOpTeam and ShowTips then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.TeamCantOpTeam)
	end

	return CanOpTeam
end

---@private
function TeamMgr:UpdateTeam(InTeamID, InCapID, InList)
	self.MemberList = InList
	self:SetTeamID(InTeamID)
	self:OnUpdateMember()
	self:SetCaptainByRoleID(InCapID)
end

--- 跨服入队时 更新队长信息 防止RoleSimple消息缓存延迟跨服图标显示错误
function TeamMgr:DelayUpdatRoleInfo(RoleID)
	if RoleID then
		self:RegisterTimer(function()
			_G.RoleInfoMgr:SendQueryInfoByRoleID(RoleID)
		end, 2, 0, 1)
	end
end

function TeamMgr:OnCaptainChanged()
	if self.TeamVM then
		self.TeamVM:UpdateInviteOpInfo()
	end
end

function TeamMgr:AddTeamMember(Member)
	if nil == table.find_item(self.MemberList, Member.RoleID, "RoleID") then
		table.insert(self.MemberList, Member)
		self:OnUpdateMember()
	end
end

function TeamMgr:UpdateMemberState(Prop)
	if nil == Prop then
		return
	end

	local RoleID = Prop.RoleID
	if nil == RoleID or RoleID == MajorUtil.GetMajorRoleID() then
		return
	end

	---@deprecated
	local VM = self.FindRoleVM(RoleID, true)
	if VM == nil then
		self:LogErr("no role vm when team member state change: %s", RoleID)	
	end

	local MemPropUpdate = Prop.Update
	if MemPropUpdate == MemPropUpdateDef.MemPropUpdate_EnterScene then
		VM:SetTeamMemberMapData(Prop.Scene)
	elseif MemPropUpdate == MemPropUpdateDef.MemPropUpdate_Login then
		VM:SetTeamMemberOnline(true)
		self:UpdateMemberProps(RoleID, {"IsOnline",}, {true,})
	elseif MemPropUpdate == MemPropUpdateDef.MemPropUpdate_Logout then
		VM:SetTeamMemberOnline(false)
		self:UpdateMemberProps(RoleID, {"IsOnline",}, {false,})
	elseif MemPropUpdate == MemPropUpdateDef.MemPropUpdate_Prof then
		local ProfData = Prop.Prof
		local ProfID = ProfData.Prof
		local Level = ProfData.Level

		self:LogInfo("team member prof update, role: %s, prof: %s, level: %s", RoleID, ProfID, Level)
		
		if VM and ProfID and Level then
			VM:SetProf(ProfID)
			VM:SetLevel(Level)
		else
			self:LogErr("invalid prof change for role %s", RoleID)
		end

		if ProfID and Level then
			self:UpdateMemberProps(RoleID, {"ProfID", "Level"}, {ProfID, Level})
		end
		
		if self.TeamVM then
			self.TeamVM:UpdateProfInfo()
		end
		_G.PWorldVoteVM:UpdateTeamProfInfo()
	elseif MemPropUpdate == MemPropUpdateDef.MemPropUpdate_ProfLevel then
		local Level = Prop.Level
		self:LogInfo("team member prof level update, role: %s, prof: %s, level: %s", RoleID, Level)

		if VM then
			VM.Level = Level
		end
		
		if Level then
			self:UpdateMemberProps(RoleID, {"Level",}, {Level,})
		end
		_G.PWorldVoteVM:UpdateTeamProfInfo()
	end
end

function TeamMgr:RemoveTeamMember(LeaveMember)
	table.remove_item(self.MemberList or {}, LeaveMember.RoleID, "RoleID")
	self:OnUpdateMember()
	-- tips
	local RVM = RoleInfoMgr:FindRoleVM(LeaveMember.RoleID, true)
	if RVM then
		self:ShowTipsByID(103077, RVM.Name)
	end
end

function TeamMgr:OnUpdateMember(NotShowTips)
	local OldNum = self.TeamVM:GetMemberNum()
	local AList = self.MemberList or {}
	local Num = #AList
	self.TeamVM:UpdateTeamMembers(AList)

	-- notify
	EventMgr:SendEvent(EventID.TeamInfoUpdate)

	-- tips
	local Incr = Num - OldNum
	if Incr > 0 and not NotShowTips then
		if Num == 4 then
			self:ShowTeamTips(true)
		elseif Num == 8 then
			self:ShowTeamTips(false)
			AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_lb_gauge_lv3.Play_SE_UI_SE_UI_lb_gauge_lv3'")
		end
	end

	if Incr < 0 then
		AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_lb_gauge_hide.Play_SE_UI_SE_UI_lb_gauge_hide'")
	elseif Incr > 0 and Num ~= 8 then
		AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_lb_gauge_lv1lv2.Play_SE_UI_SE_UI_lb_gauge_lv1lv2'")
	end
end

-- 队长ID，不考虑换队长
function TeamMgr:GetTeamRecruitID()
	return self:GetCaptainID()
end

---@deprecated #TODO DELETE OR REFINE
function TeamMgr:GetMemberList()
	return self.MemberList
end

function TeamMgr:GetMemberRoleIDList()
	local RoleIDList = {}

	local MemberList = self.MemberList
	if nil == MemberList then
		return RoleIDList
	end

	for i = 1, #MemberList do
		local Member = MemberList[i]
		if nil ~= Member then
			table.insert(RoleIDList, Member.RoleID)
		end
	end

	return RoleIDList
end

function TeamMgr:GetMemberNum()
	return #(self.MemberList or {})
end

function TeamMgr:GetTeamID()
	return self.TeamID
end

---@param FromView UIView
function TeamMgr:QuitTeamFromUI(FromView)
	if FromView == nil then
		self:LogErr("QuitTeamFromUI missing `FromView` param, trace: \n%s", debug.traceback())
		return
	end

	local function Leave()
		self:SendLeaveTeamReq(MajorUtil.GetMajorRoleID(), self:GetTeamID(), ProtoCS.Team.Team.LEAVE_TEAM_REASON.LEAVE_TEAM_SELF)
	end

	if self:IsCaptain() and _G.TeamRecruitMgr:IsRecruiting() then
		self:RegisterTimer(function ()
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(FromView, 
			PWorldHelper.GetPWorldText("POPUP_RECRUIT_CHECK_LEAVE_TEAM_TITLE"), 
			PWorldHelper.GetPWorldText("POPUP_RECRUIT_CHECK_LEAVE_TEAM_CONTENT"), Leave, nil, 
			PWorldHelper.GetPWorldText("POPUP_RECRUIT_CHECK_LEAVE_TEAM_CANCEL"), 
			PWorldHelper.GetPWorldText("POPUP_RECRUIT_CHECK_LEAVE_TEAM_OK"), nil)
		end, 0.01, nil, nil, nil)
	else
		Leave()
	end
end

---@param FromView UIView
function TeamMgr:DestroyTeamFromUI(FromView)
	if FromView == nil then
		self:LogErr("DestroyTeamFromUI missing `FromView` param, trace: \n%s", debug.traceback())
		return
	end

	local function Destroy()
		self:SendDestroyTeamReq(self:GetTeamID())
	end

	if self:IsCaptain() and _G.TeamRecruitMgr:IsRecruiting() then
		self:RegisterTimer(function ()
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, 
			PWorldHelper.GetPWorldText("POPUP_RECRUIT_CHECK_DESTROY_TEAM_TITLE"), 
			PWorldHelper.GetPWorldText("POPUP_RECRUIT_CHECK_DESTROY_TEAM_CONTENT"), Destroy, nil, 
			PWorldHelper.GetPWorldText("POPUP_RECRUIT_CHECK_DESTROY_TEAM_CANCEL"),
			PWorldHelper.GetPWorldText("POPUP_RECRUIT_CHECK_DESTROY_TEAM_OK"), nil)
		end, 0.01, nil, nil, nil)
	else
		Destroy()
	end
end

--- 邀请加入队伍
---@param RoleID number @角色ID
---@param Source number ProtoCS.Team.Team.ReqSource
function TeamMgr:InviteJoinTeam(RoleID, Source)
	if _G.TeamRecruitVM.IsRecruiting then
		MsgTipsUtil.ShowTips(LSTR(1300005))
		return
	end

	if nil == RoleID or not self:CheckCanOpTeam(true) then
		return
	end

	if _G.PWorldVoteMgr:IsVoteEnterScenePending() or _G.PWorldEntourageMgr:GetConfirmState() == true then
		MsgTipsUtil.ShowTipsByID(103094)
		return
	end

	self:SendInviteJoinReq(self:GetTeamID(), RoleID, Source)
end

---@private
function TeamMgr:ShowTipsByID(TipsID, ...)
	if self:IsUsing() then
		MsgTipsUtil.ShowTipsByID(TipsID, nil, ...)
	end
end

---@private
---@deprecated
function TeamMgr:TipContentAndAddSysChat(Content)
	if type(Content) ~= 'string' or #Content == 0 then
		return
	end

	if self:IsUsing() then
		MsgTipsUtil.ShowTips(Content, nil, nil)
	end
	_G.ChatMgr:AddSysChatMsg(Content)
end

-------------------------------------------------------------------------------------------------------
---@region 语音

-- override
function TeamMgr:SendSelfTeamData( Data )
	local MsgID = CS_CMD.CS_CMD_TEAM
	local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_TEAM_SET_SELF_DATA

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = self:GetTeamID()
	MsgBody.SetSelfData = { Data = Data }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


function TeamMgr:OnNetMsgTeamMemberDataNotify( MsgBody )
	local Msg = MsgBody.MemberData
	if nil == Msg then
		return
	end

	self:OnMemDataNtf(Msg.Member)
end

function TeamMgr:GetTeamVoiceRoomNameToJoin()
	if self:IsInTeam() then
		return string.format("T-%s", tostring(self:GetTeamID()))
	end
end

return TeamMgr

