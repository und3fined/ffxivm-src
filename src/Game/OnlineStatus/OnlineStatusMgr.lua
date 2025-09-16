--
-- Author: loiafeng
-- Date : 2023-03-01 09:56:38
-- Description: 维护玩家的在线状态
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local OnlineStatusDefine = require("Game/OnlineStatus/OnlineStatusDefine")
local ActorUtil = require("Utils/ActorUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local UILayer = require("UI/UILayer")
local TeamHelper = require("Game/Team/TeamHelper")

local CS_CMD = ProtoCS.CS_CMD
local ClientSetupKey = ProtoCS.ClientSetupKey
local ClientReportType = ProtoCS.ReportType
local OnlineStatusRes = ProtoRes.OnlineStatus
local CSOnlineStatusCmd =  ProtoCS.CSOnlineStatusCmd

local GameNetworkMgr
local ClientReportMgr
local LSTR = _G.LSTR

-- 表述多长时间未点击屏幕，玩家将会自动设置为离开状态，单位：秒
local AutoLeaveTime = 9 * 60 + 30 -- 9 * 60 + 30

-- 维护进入“离开”状态的Timer的更新频率，单位：秒
local LeaveStatusTimerInterval = 60

-- 主动进入“离开”状态后，防误触保护时间，单位：秒
local LeaveStatusProtectTime = 5

-- 存在异常状态时主动拉取最新在线状态的频率，单位：秒
local UpdateFrequencyTime = 5

-- 是否开启场景中显示其他玩家的“通信切断”状态
local ShowElectrocardiogramInVision = false

-- 是否开启副本中显示其他玩家的“通信切断”状态
local ShowElectrocardiogramInPWorldTeam = true

-- @class OnlineStatusMgr : MgrBase
local OnlineStatusMgr = LuaClass(MgrBase)

function OnlineStatusMgr:OnInit()
	self.MajorStatus = 0x00  -- 本地玩家状态缓存，以服务器为准
	self.MajorIdentity = 0x00  -- 本地玩家身份缓存，以服务器为准

	-- 对视野内玩家(不包括自己)的状态进行缓存
	self.VisionEntityOnlineStatus = {} -- self.VisionEntityOnlineStatus[EntityID] = Bitset

	self.LastActionTime = 0  -- 保存玩家最近一次动作（点击屏幕或移动）的时间，用于维护离开状态
	self.LastLocation = _G.UE.FVector()  -- 保存玩家位置，用于维护离开状态

	self.LeaveStatusProtectStartTime = 0  -- 离开保护的开始时间
	self.LeaveStatusMovementDetectTimerID = nil  -- “离开”状态位移监听Timer
	self.ViewStateSetting = nil     --是否正在等待根据界面设置的状态回包

	-- 客户端补充状态（包括自己）
	self.ClientSupplementaryStatus = {}    --  self.ClientSupplementaryStatus[RoleID] = Bitset
	self.InDungeon = false      --是否在副本中
end

function OnlineStatusMgr:OnBegin()
	self.LastActionTime = TimeUtil.GetServerTime()
	GameNetworkMgr = _G.GameNetworkMgr
	ClientReportMgr = _G.ClientReportMgr
end

function OnlineStatusMgr:OnEnd()
end

function OnlineStatusMgr:OnShutDown()
end

function OnlineStatusMgr:OnRegisterNetMsg()
	-- 玩家进入视野 或 主动Query场景
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_ENTER, self.OnNetMsgVisionUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_QUERY, self.OnNetMsgVisionUpdate)
	-- 视野内玩家状态发生改变
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_AVATAR_SYNC, self.OnNetMsgVisionPlayerStatusChanged)
	-- 玩家离开视野
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_LEAVE, self.OnNetMsgVisionLeave)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ONLINE_STATUS, CSOnlineStatusCmd.CSOnlineStatusCmdNotifyIdentify, self.OnNetMsgNotifyIdentify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ONLINE_STATUS, CSOnlineStatusCmd.CSOnlineStatusCmdQuery, self.OnNetMsgOverallStatus)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ONLINE_STATUS, CSOnlineStatusCmd.CSOnlineStatusCmdNotifyStatus, self.OnNetMsgNotifyStatus)
end

function OnlineStatusMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnGameEventMouseDownMarkTime)  -- 记录点击时间，维护离开状态
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnGameEventClientSetupCallback)  -- 设置在线状态成功的回调
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)  -- 玩家登录或者断线重连
	--self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventRoleLoginRes)
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
	self:RegisterGameEvent(EventID.TeamInTeamChanged, self.OnGameEventTeamInTeamChanged)
	self:RegisterGameEvent(EventID.TeamUpdateMember, self.OnGameEventTeamMemberChanged)
	self:RegisterGameEvent(EventID.TeamCaptainChanged, self.OnGameEventTeamMemberChanged)
end

function OnlineStatusMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimerWaitToEnterLeaveStatus, 0, LeaveStatusTimerInterval, 0)  -- 维护离开状态
	self:RegisterTimer(self.ExceptionStatusCalibration, 0, UpdateFrequencyTime, 0)  -- 异常状态校准
end

--- SetConfig Part BEGIN ---

--设置离开状态的时间间隔
function OnlineStatusMgr:SetAutoLeaveTime(LeaveTime)
	AutoLeaveTime = LeaveTime
end

function OnlineStatusMgr:GetAutoLeaveTime()
	return AutoLeaveTime
end

--设置 场景中显示其他玩家的“通信切断”状态
function OnlineStatusMgr:SetShowElectrocardiogramInVision(ElectrocardiogramInVision)
	if ElectrocardiogramInVision ~= ShowElectrocardiogramInVision then
		ShowElectrocardiogramInVision = ElectrocardiogramInVision
		if not _G.PWorldMgr:CurrIsInDungeon() then
			_G.HUDMgr:UpdateAllActorOnlineStatusVisibility()
		end
	end
end

function OnlineStatusMgr:GetShowElectrocardiogramInVision()
	return ShowElectrocardiogramInVision
end

--设置 副本中显示其他玩家的“通信切断”状态
function OnlineStatusMgr:SetShowElectrocardiogramInPWorldTeam(ElectrocardiogramInPWorldTeam)
	if ShowElectrocardiogramInPWorldTeam ~= ElectrocardiogramInPWorldTeam then
		ShowElectrocardiogramInPWorldTeam = ElectrocardiogramInPWorldTeam
		if _G.PWorldMgr:CurrIsInDungeon() then
			_G.HUDMgr:UpdateAllActorOnlineStatusVisibility()
		end
	end
end

function OnlineStatusMgr:GetShowElectrocardiogramInPWorldTeam()
	return ShowElectrocardiogramInPWorldTeam
end
--- SetConfig Part END ---

--- Request Part BEGIN ---
---
function OnlineStatusMgr:OnNetMsgQueryReq(ReqCSOnlineStatusCmd)
	local MsgID = CS_CMD.CS_CMD_ONLINE_STATUS
	local SubMsgID = ReqCSOnlineStatusCmd
	local MsgBody = {
		Cmd = ReqCSOnlineStatusCmd
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- Request Part END ---

--- Response Part BEGIN ---

---@private
function OnlineStatusMgr:UpdateOnlineStatusFromAvatarList(EntityID, AvatarList)
	for _, Avatar in ipairs(AvatarList) do
		if Avatar.Key == ProtoCS.VDataType.DisplayTag then
			-- print("loiafeng: Vision Status changed. EntityID: ", EntityID)
			--local Value = OnlineStatusUtil.GetOnlineStatusInBase36(Avatar.Value)
			local MajorEntityID = MajorUtil.GetMajorEntityID()
			if EntityID ~= MajorEntityID then    -- 自己的状态变更只依据新赠的CS_CMD_ONLINE_STATUS协议处理 视野协议只处理其他人状态变更
				--_G.FLOG_INFO("hello OnlineStatusMgr DebugLog:  EntityID: %d, Status: %s, MajorEntityID: %s", EntityID, OnlineStatusUtil.ToString(tonumber(Avatar.Value)), MajorEntityID)
				self:SetVisionEntityOnlineStatus( EntityID, tonumber(Avatar.Value))
			end
		end
	end
end

---通过Vision协议更新视野内玩家的状态
function OnlineStatusMgr:OnNetMsgVisionUpdate(MsgBody)
	local VisionRsp = MsgBody.Enter or MsgBody.Query
	local Entities = VisionRsp and VisionRsp.Entities
	if Entities == nil then return end

	for _, Entity in ipairs(Entities) do
		local AvatarList = ((Entity.Role or {}).Avatars or {}).AvatarList
		if AvatarList ~= nil then
			self:UpdateOnlineStatusFromAvatarList(Entity.ID, AvatarList)
		end
	end
end

---视野内玩家状态改变
function OnlineStatusMgr:OnNetMsgVisionPlayerStatusChanged(MsgBody)
	local AvatarList = MsgBody.AvatarSync and MsgBody.AvatarSync.AvatarList
	if AvatarList == nil then
		return
	end

	self:UpdateOnlineStatusFromAvatarList(MsgBody.AvatarSync.EntityID, AvatarList)
end

---角色离开场景，清理缓存
function OnlineStatusMgr:OnNetMsgVisionLeave(MsgBody)
	local Leave = MsgBody.Leave
	if Leave == nil then return end
	local Entities = Leave.Entities
	if Entities == nil then return end

	for _, Value in ipairs(Entities) do
		-- print("loiafeng: OnlineStatusMgr:OnNetMsgVisionLeave EntityID: ", Value)
		self.VisionEntityOnlineStatus[Value] = nil
	end
end

--- 身份变动通知下发
function OnlineStatusMgr:OnNetMsgNotifyIdentify(MsgBody)
	if nil == MsgBody or nil == MsgBody.Identify then
		return
	end
	local Identify = MsgBody.Identify.Identify
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		RoleVM:SetIdentity(Identify)
		self:OnIdentityChanged(RoleVM)
		_G.FLOG_INFO("OnlineStatusMgr DebugLog: OnNetMsgNotifyIdentify, Identify: %s  IdentifyList: %s", 
			tostring(Identify), _G.table.concat(OnlineStatusUtil.DecodeBitset(RoleVM.Identity)))
	end
end

--- 完整状态数据通知下发
function OnlineStatusMgr:OnNetMsgOverallStatus(MsgBody)
	if nil == MsgBody or MsgBody.DisplayTag == nil then
		return
	end
	local Identify = MsgBody.DisplayTag.Identify or 0x00
	local DisplayTag = OnlineStatusUtil.RemoveMajorIgnoreStatus(MsgBody.DisplayTag.DisplayTag)
	local Setting = MsgBody.DisplayTag.Setting or 1
	local RoleVM = MajorUtil.GetMajorRoleVM()

	if RoleVM then
		_G.FLOG_INFO("OnlineStatusMgr DebugLog: Init Major Online Status:  %s. StatusStr: %s. CustomStatus: %d. Identity: %s. IdentifyList: %s", 
		tostring(DisplayTag), OnlineStatusUtil.ToString(DisplayTag), Setting, tostring(Identify), _G.table.concat(OnlineStatusUtil.DecodeBitset(RoleVM.Identity)))
		RoleVM:SetIdentity(Identify)
		RoleVM:SetOnlineStatusCustomID(Setting)
		self.MajorIdentity = Identify
	end

	self:RoleStatusChange(DisplayTag)
	self:ExceptionStatusCalibration()
end

--- 状态列表数据通知下发
function OnlineStatusMgr:OnNetMsgNotifyStatus(MsgBody)
	if nil == MsgBody or nil == MsgBody.TagNtf then
		return
	end
	local DisplayTag = OnlineStatusUtil.RemoveMajorIgnoreStatus(MsgBody.TagNtf.DisplayTag)
	_G.FLOG_INFO("OnlineStatusMgr DebugLog: OnNetMsgNotifyStatus, Status: %s  StatusStr: %s ", tostring(DisplayTag), OnlineStatusUtil.ToString(DisplayTag))
	self:RoleStatusChange(DisplayTag)
end

--- Response Part END ---


--- GameEvent Callback BEGIN ---

---监听点击事件，记录点击时间
function OnlineStatusMgr:OnGameEventMouseDownMarkTime()
	self.LastActionTime = TimeUtil.GetServerTime()
end

---监听点击事件，解除离开状态
function OnlineStatusMgr:OnGameEventMouseDownQuitLeaveStatus()
	-- 防止快速点击屏幕请求多次的情况
	local LastTime = self.LastMouseDownQuitLeaveStatusTime or 0
	local CurrentTime = TimeUtil.GetServerTime()
	if CurrentTime - LastTime > 3.0 then
		self.LastMouseDownQuitLeaveStatusTime = CurrentTime
		self:RequestQuitLeaveStatus()
	end
end

---玩家登录或者断线重连
---@param Params table
function OnlineStatusMgr:OnGameEventRoleLoginRes(Params)
	self:OnNetMsgQueryReq(CSOnlineStatusCmd.CSOnlineStatusCmdQuery)
end

 -- 设置在线状态成功的回调
function OnlineStatusMgr:OnGameEventClientSetupCallback(Params)
	if Params.IntParam1 ~= ClientSetupKey.CSOnlineStatusSet then
		return
	end

	local StringValue = Params.StringParam1 or ""
	local StatusID = _G.tonumber(_G.string.match(StringValue, "%d+"))
	-- 手动更新一下RoleVM的在线状态设置
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		RoleVM:SetOnlineStatusCustomID(StatusID)
	end
	--对于主动设置的处理一下设置标识
	if self.ViewStateSetting then 
		self:UnRegisterTimer(self.ViewStateSetting)
		self.ViewStateSetting = nil
		_G.MsgTipsUtil.ShowTips(LSTR(OnlineStatusDefine.NotifyText.StatusChanged))
		_G.UIViewMgr:HideViewByUILayer(UILayer.Normal | UILayer.AboveNormal)
	end
end

function OnlineStatusMgr:OnGameEventPWorldMapEnter()
	self:UpdateDungeonTeamRelatedStatus()
	if _G.PWorldMgr.DailyRandomID == 4 then 
		if OnlineStatusUtil.CheckBit(self.MajorIdentity, ProtoRes.OnlineStatusIdentify.OnlineStatusIdentifyBattleMentor) then
			-- 进入导随副本切为战斗指导者在线状态
			self:SetCustomStatus(OnlineStatusRes.OnlineStatusCombatMentor)
		end
	end
end

function OnlineStatusMgr:OnGameEventTeamInTeamChanged(InTeam)
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if InTeam and RoleVM and RoleVM.OnlineStatusCustomID == OnlineStatusRes.OnlineStatusHopeTeam then 
		self:SetCustomStatus(OnlineStatusRes.OnlineStatusOnline)
	end
end

-- 副本队伍相关状态处理
function OnlineStatusMgr:UpdateDungeonTeamRelatedStatus()
	local CurInDungeon = _G.PWorldMgr:CurrIsInDungeon()
	if CurInDungeon == self.InDungeon then
		return
	end
	if CurInDungeon then
		self.InDungeon = CurInDungeon
		-- 进副本
		self:AssignmentDungeonTeamRelatedStatus()
	elseif self.InDungeon then
		self.InDungeon = CurInDungeon
		-- 出副本
		self:ClearDungeonTeamRelatedStatus()
	end
end

function OnlineStatusMgr:OnGameEventTeamMemberChanged()
	if _G.PWorldMgr:CurrIsInDungeon() then
		self:ClearDungeonTeamRelatedStatus()
		self:AssignmentDungeonTeamRelatedStatus()
	end
end
--- GameEvent Callback END ---


--- Timer Callback BEGIN ---

---检测玩家移动，退出离开状态
function OnlineStatusMgr:OnTimerLeaveStatusMovementDetect()
	if OnlineStatusMgr:UpdateAndCheckMovement() then
		self:RequestQuitLeaveStatus()
	end
end

---以较低的频率检查玩家是否需要进入离开状态
function OnlineStatusMgr:OnTimerWaitToEnterLeaveStatus()
	-- 处理断线重连的追帧情况
	local LastTime = self.LastWaitToEnterLeaveStatusTime or 0
	local CurrentTime = TimeUtil.GetServerTime()
	if CurrentTime - LastTime < LeaveStatusTimerInterval - 1.0 then
		return
	end
	self.LastWaitToEnterLeaveStatusTime = CurrentTime

	-- 检查玩家位置是否发生变化，以及是否有加速度
	if self:UpdateAndCheckMovement() then
		self.LastActionTime = TimeUtil.GetServerTime()
		return
	end

	if (not self:IsLeave()) and (TimeUtil.GetServerTime() - self.LastActionTime) > AutoLeaveTime then
		-- 直接开始监听点击事件，没有防误触保护
		_G.FLOG_INFO("OnlineStatusMgr: Request LeaveStatus after not operating for a long time.")
		self:RequestEnterLeaveStatus()
	end
end

---状态设置计时
function OnlineStatusMgr:StateSettingTiming()
	if self.ViewStateSetting then
		_G.MsgTipsUtil.ShowErrorTips(LSTR(OnlineStatusDefine.NotifyText.StatusChangedFail))
		self:UnRegisterTimer(self.ViewStateSetting)
		self.ViewStateSetting = nil
	end
end

--- 异常状态校准
function OnlineStatusMgr:ExceptionStatusCalibration()
	if self:UpdateAndCheckMovement() then
		local StatusList = OnlineStatusUtil.DecodeBitset(self.MajorStatus)
		local SelectList = OnlineStatusUtil.Select(StatusList, OnlineStatusDefine.ExceptionStatus)
		if #SelectList > 0 then
			-- 如果当前存在异常状态自己主动拉取一下最新的状态信息
			self:OnNetMsgQueryReq(CSOnlineStatusCmd.CSOnlineStatusCmdQuery)
		end
	end
	if OnlineStatusUtil.CheckBit(self.MajorStatus, OnlineStatusRes.OnlineStatusCutscene) and (not _G.StoryMgr:SequenceIsPlaying()) then
		-- 存在Cutscene 状态并且没有播放 上报结束
		ClientReportMgr:SendClientReport(ProtoCS.ReportType.ReportTypeQuitCutScenes)
	end
	if OnlineStatusUtil.CheckBit(self.MajorStatus, OnlineStatusRes.OnlineStatusView) and not _G.PhotoMgr.IsOnPhoto then
		ClientReportMgr:SendClientReport(ProtoCS.ReportType.ReportTypeQuitTakePhotos)
	end
	if OnlineStatusUtil.CheckBit(self.MajorStatus, OnlineStatusRes.OnlineStatusRecollect) and not _G.MusicPlayerMgr:CheckCurRecallState() then
		ClientReportMgr:SendClientReport(ProtoCS.ReportType.ReportTypeRecollect, { Recollect = { IsRecollect = false }} )
	end

	if (OnlineStatusUtil.CheckBit(self.MajorStatus, OnlineStatusRes.OnlineStatusBandListen)
		or OnlineStatusUtil.CheckBit(self.MajorStatus, OnlineStatusRes.OnlineStatusBandListenFans))
		and (not _G.TouringBandMgr:IsListeningStatus()) then
		ClientReportMgr:SendClientReport(ProtoCS.ReportType.ReportTypeBandListen, { BandListen = { IsListening = false, IsFans = false }})
	end
end

--- Timer Callback END ---


------ Internal BEGIN ------

local function NearlyEqualXY(A, B, Bounds)
	Bounds = Bounds or 50.0
	return math.abs(A.X - B.X) < Bounds and math.abs(A.Y - B.Y) < Bounds
end

---更新玩家位置并判断玩家是否有移动
---@private
function OnlineStatusMgr:UpdateAndCheckMovement()
	local MajorActor = MajorUtil.GetMajor()
	if MajorActor == nil then
		_G.FLOG_WARNING("OnlineStatusMgr:UpdateAndCheckMovement MajorActor is nil.")
		return false
	end

	local LastLocation = self.LastLocation
	local CurrentLocation = MajorActor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	self.LastLocation = CurrentLocation
	return (not NearlyEqualXY(LastLocation, CurrentLocation)) or MajorActor.CharacterMovement.Acceleration:Size() > 0.0001
end

---请求进入离开状态
---@private
function OnlineStatusMgr:RequestEnterLeaveStatus()
	if not self:IsLeave() then
		ClientReportMgr:SendClientReport(ClientReportType.ReportTypeRoleLeave)
	end
end

---请求退出离开状态
---@private
function OnlineStatusMgr:RequestQuitLeaveStatus()
	if self:IsLeave() and TimeUtil.GetServerTime() - self.LeaveStatusProtectStartTime > LeaveStatusProtectTime then
		ClientReportMgr:SendClientReport(ClientReportType.ReportTypeRoleComeBack)
	end
end

---由服务器通知进入“离开”状态
---@private
function OnlineStatusMgr:OnEnterLeaveStatus()
	self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnGameEventMouseDownQuitLeaveStatus)
	-- 记录一次玩家的位置信息
	self:UpdateAndCheckMovement()
	self.LeaveStatusMovementDetectTimerID = self:RegisterTimer(self.OnTimerLeaveStatusMovementDetect, 0, 3.0, 0)

	if (TimeUtil.GetServerTime() - self.LastActionTime) > AutoLeaveTime then
		-- 对于自动进入的离开状态，需要弹出消息提示
		_G.MsgTipsUtil.ShowTips(LSTR(OnlineStatusDefine.NotifyText.StatusChanged))
		_G.ChatMgr:AddSysChatMsg(RichTextUtil.GetText(LSTR(OnlineStatusDefine.NotifyText.EnterLeave), "B0B0B0FF"))
	else
		--对于主动设置的处理一下设置标识
		if self.ViewStateSetting then 
			self:UnRegisterTimer(self.ViewStateSetting)
			self.ViewStateSetting = nil
			_G.MsgTipsUtil.ShowTips(LSTR(OnlineStatusDefine.NotifyText.StatusChanged))
			_G.UIViewMgr:HideViewByUILayer(UILayer.Normal | UILayer.AboveNormal)
		end
	end
end

---由服务器通知退出“离开”状态
---@private
function OnlineStatusMgr:OnQuitLeaveStatus()
	if self.LeaveStatusMovementDetectTimerID ~= nil then
		self:UnRegisterTimer(self.LeaveStatusMovementDetectTimerID)
		self.LeaveStatusMovementDetectTimerID = nil
	end
	self:UnRegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnGameEventMouseDownQuitLeaveStatus)

	_G.MsgTipsUtil.ShowTips(LSTR(OnlineStatusDefine.NotifyText.StatusChanged))
	_G.ChatMgr:AddSysChatMsg(RichTextUtil.GetText(LSTR(OnlineStatusDefine.NotifyText.QuitLeave), "B0B0B0FF"))
end

-- 设置客户端本地扩展状态
---@param RoleID number
---@param NewStatus Bitset
function OnlineStatusMgr:SetClientSupplementaryStatus(RoleID, NewStatus)
	if (RoleID or 0) == 0 then
		return
	end
	local OldStatus = self.ClientSupplementaryStatus[RoleID] or 0
	if NewStatus == OldStatus then
		return
	end
	self.ClientSupplementaryStatus[RoleID] = NewStatus

	if RoleID == MajorUtil.GetMajorRoleID() then
		self:RoleStatusChange(self:GetMajorStatus() ~ OldStatus)
		return
	end
	local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
	local OldOnlineStatus = self.VisionEntityOnlineStatus[EntityID] or 0
	if OldStatus then
		self:SetVisionEntityOnlineStatus(EntityID, OldOnlineStatus ~ OldStatus)
	end
end

-- 设置玩家的在线状态缓存
---@param EntityID number
---@param NewStatus Bitset
function OnlineStatusMgr:SetVisionEntityOnlineStatus(EntityID, NewStatus)
	if EntityID == 0 or NewStatus == nil then
		return
	end
	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	local ClientStatus = self.ClientSupplementaryStatus[RoleID] or 0
	local OldStatus = self.VisionEntityOnlineStatus[EntityID] or 0
	if ClientStatus then
		NewStatus = NewStatus | ClientStatus
	end

	if NewStatus ~= OldStatus then
		self.VisionEntityOnlineStatus[EntityID] = NewStatus
		local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID, false)
		if RoleVM then
			RoleVM:SetOnlineStatus(NewStatus)
		end
		self:CheckInCardGameStatus(EntityID, NewStatus, OldStatus)
		local Params = { OnlineStatus =  NewStatus, EntityID = EntityID }
		_G.EventMgr:SendEvent(EventID.OnlineStatusChangedInVision, Params)
	end
end

---主角状态列表变动
---@private
function OnlineStatusMgr:RoleStatusChange(NewStatus)
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local ClientStatus = self.ClientSupplementaryStatus[MajorRoleID]
	local OldStatus = self:GetMajorStatus()
	if ClientStatus then
		NewStatus = NewStatus | ClientStatus
	end
	if NewStatus ~= OldStatus then
		self.MajorStatus = NewStatus
		local Difference = OnlineStatusUtil.GetDiff(NewStatus, OldStatus)
		if OnlineStatusUtil.CheckBit(Difference, OnlineStatusRes.OnlineStatusLeave) then
			if self:IsLeave() then
				self:OnEnterLeaveStatus()
			else
				self:OnQuitLeaveStatus()
			end
		end
		local RoleVM = MajorUtil.GetMajorRoleVM()
		if RoleVM then
			RoleVM:SetOnlineStatus(NewStatus)
		end
		_G.EventMgr:SendEvent(EventID.OnlineStatusMajorChanged, NewStatus, OldStatus)
	end
end

function OnlineStatusMgr:CheckInCardGameStatus(InEntityID, Status, OldState)
	local _newPlayCard = OnlineStatusUtil.CheckBit(Status, ProtoRes.OnlineStatus.OnlineStatusFantasyCard)
	local _oldPlayCard = false
	if(OldState ~= nil) then
		_oldPlayCard = OnlineStatusUtil.CheckBit(OldState, ProtoRes.OnlineStatus.OnlineStatusFantasyCard)
	end

	if(_oldPlayCard and not _newPlayCard) then
		local AnimComp = ActorUtil.GetActorAnimationComponent(InEntityID)
		if(AnimComp == nil) then
			_G.FLOG_WARNING("警告，无法获取 AnimationComponent ， EntityID 是："..InEntityID)
			return
		end
		AnimComp:StopAnimation()
	elseif(not _oldPlayCard and _newPlayCard) then
		print("我的徽章动了，附近有人在打牌")
		local AnimComp = ActorUtil.GetActorAnimationComponent(InEntityID)
		if(AnimComp == nil) then
			_G.FLOG_WARNING("警告，无法获取 AnimationComponent ， EntityID 是："..InEntityID)
			return
		end
		local AnimAsset = AnimComp:GetPalyerFantasyCardAnim(ProtoRes.fantasy_card_major_anim_enum.Major_Anim_InGame_Normal)
		if AnimAsset == nil or AnimAsset == "" then
			_G.FLOG_WARNING("错误，无法获取动作资源，GetPalyerFantasyCardAnim(ProtoRes.fantasy_card_major_anim_enum.Major_Anim_InGame_Normal)")
			return false
		end

		AnimComp:PlayAnimation(AnimAsset, 1.0, 0.25, 0.25, true)
	end
end

---更新本地玩家身份
---@param RoleVM RoleVM
function OnlineStatusMgr:OnIdentityChanged(RoleVM)
	if nil == RoleVM  then
		return
	end

	local Identity = RoleVM.Identity or 0x00
	local OldIdentity = self.MajorIdentity or 0x00
	self.MajorIdentity = Identity

	local Diff = OnlineStatusUtil.GetDiff(self.MajorIdentity, OldIdentity)

	---判断是否进入某个身份
	local CheckEnter = function(TargetIdentity)
		return OnlineStatusUtil.CheckBit(Diff, TargetIdentity) and
			OnlineStatusUtil.CheckBit(self.MajorIdentity, TargetIdentity)
	end

	--进入某个身份时，需要主动设置为相应的状态
	if CheckEnter(ProtoRes.OnlineStatusIdentify.OnlineStatusIdentifyNewHand) then
		-- 激活新人身份，主动设置相关状态
		self:SetCustomStatus(OnlineStatusRes.OnlineStatusNewHand)
	elseif CheckEnter(ProtoRes.OnlineStatusIdentify.OnlineStatusIdentifyNewHandChat) then
		-- 激活新人频道的新人身份，主动设置相关状态
		self:SetCustomStatus(OnlineStatusRes.OnlineStatusJoinNewbieChannel)
	elseif CheckEnter(ProtoRes.OnlineStatusIdentify.OnlineStatusIdentifyMentor) then
		-- 激活指导者身份，主动设置相关状态
		self:SetCustomStatus(OnlineStatusRes.OnlineStatusMentor)
	elseif CheckEnter(ProtoRes.OnlineStatusIdentify.OnlineStatusIdentifyBattleMentor) then
		-- 激活战斗指导者身份，主动设置相关状态
		self:SetCustomStatus(OnlineStatusRes.OnlineStatusCombatMentor)
	elseif CheckEnter(ProtoRes.OnlineStatusIdentify.OnlineStatusIdentifyMakeMentor) then
		-- 激活采集指导者身份，主动设置相关状态
		self:SetCustomStatus(OnlineStatusRes.OnlineStatusMakeMentor)
	elseif CheckEnter(ProtoRes.OnlineStatusIdentify.OnlineStatusIdentifyReturner) then
		-- 激活回归者身份，主动设置相关状态
		self:SetCustomStatus(OnlineStatusRes.OnlineStatusReturner)
	elseif CheckEnter(ProtoRes.OnlineStatusIdentify.OnlineStatusIdentifyRedFlowerMentor) then
		-- 激活小红花指导者身份，主动设置相关状态
		self:SetCustomStatus(OnlineStatusRes.OnlineStatusRedFlowerMentor)
	end
end

--- 清除本地数据中的 副本队伍 相关状态
function OnlineStatusMgr:ClearDungeonTeamRelatedStatus()
	for RoleID, Status in pairs(self.ClientSupplementaryStatus) do
		if OnlineStatusUtil.CheckBit(Status, ProtoRes.OnlineStatus.OnlineStatusSceneCaptain) then
			Status = Status ~ OnlineStatusUtil.EncodeBitset({OnlineStatusRes.OnlineStatusSceneCaptain})
		end
		if OnlineStatusUtil.CheckBit(Status, ProtoRes.OnlineStatus.OnlineStatusSceneTeamMem) then
			Status = Status ~ OnlineStatusUtil.EncodeBitset({OnlineStatusRes.OnlineStatusSceneTeamMem})
		end
		self:SetClientSupplementaryStatus(RoleID, Status)
	end
end

--- 添加本地数据中的 副本队伍 相关状态
function OnlineStatusMgr:AssignmentDungeonTeamRelatedStatus()
	local TeamMgr = TeamHelper.GetTeamMgr()
	if not TeamMgr then
		return
	end
	for _, RoleID, _ in TeamMgr:IterTeamMembers() do
		if RoleID ~= nil then
			local CurClientStatus = self.ClientSupplementaryStatus[RoleID]
			CurClientStatus = CurClientStatus == nil and 0x00 or CurClientStatus
			if TeamMgr:IsCaptainByRoleID(RoleID) then
				CurClientStatus = CurClientStatus | OnlineStatusUtil.EncodeBitset({OnlineStatusRes.OnlineStatusSceneCaptain})
			else
				CurClientStatus = CurClientStatus | OnlineStatusUtil.EncodeBitset({OnlineStatusRes.OnlineStatusSceneTeamMem})
			end
			self:SetClientSupplementaryStatus(RoleID, CurClientStatus)
		end
	end
end
------ Internal END ------


--- Interface BEGIN ---

---获取视野内某个玩家（可以是自己）的在线状态
---@param RoleID number
---@return Bitset 返回在线状态位集，不在视野内返回nil
---@public
function OnlineStatusMgr:GetVisionStatusByRoleID(RoleID)
	return self:GetVisionStatusByEntityID(ActorUtil.GetEntityIDByRoleID(RoleID))
end

---获取视野内某个玩家（可以是自己）的在线状态
---@param EntityID number
---@return Bitset 返回在线状态位集，不在视野内返回nil
---@public
function OnlineStatusMgr:GetVisionStatusByEntityID(EntityID)
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	if (MajorEntityID or 0) ~= 0 and MajorEntityID == EntityID then
		return self:GetMajorStatus()
	else
		return (self.VisionEntityOnlineStatus or {})[EntityID]
	end
end

---获取所有玩家的在线状态
---@param RoleID number
---@return Bitset 在线状态位集，默认为在线
---@public
function OnlineStatusMgr:GetStatusByRoleID(RoleID)
	return self:GetStatusByEntityID(ActorUtil.GetEntityIDByRoleID(RoleID))
end

---获取所有玩家的在线状态，本地玩家可以使用GetMajorStatus
---@param EntityID number
---@return Bitset 在线状态位集，默认为在线
---@public
function OnlineStatusMgr:GetStatusByEntityID(EntityID)
	local Bitset = self:GetVisionStatusByEntityID(EntityID)
	if Bitset == nil then
		local RoleId = ActorUtil.GetRoleIDByEntityID(EntityID)
		local MajorVM = _G.RoleInfoMgr:FindRoleVM(RoleId, false) or {}
		return MajorVM.OnlineStatus or OnlineStatusUtil.EncodeBitset({OnlineStatusRes.OnlineStatusOnline})
	end
	return Bitset
end

---获取自己的在线状态
---@return Bitset 在线状态位集，默认为在线
---@public
function OnlineStatusMgr:GetMajorStatus()
	return self.MajorStatus
end

---判断指定对象是否拥有某个状态，本地玩家可以使用MajorHasStatus
---@param EntityID number
---@param StatusID number
---@return boolean
---@public
function OnlineStatusMgr:HasStatus(EntityID, StatusID)
	if EntityID == MajorUtil.GetMajorEntityID() then
		return self:MajorHasStatus(StatusID)
	else
		local Bitset = self.VisionEntityOnlineStatus[EntityID]
		if Bitset ~= nil then
			return OnlineStatusUtil.CheckBit(Bitset, StatusID)
		end
	end
	return false
end

---判断本地玩家是否拥有某个身份
---@param IdentityID number
---@return boolean
---@public
function OnlineStatusMgr:MajorHasIdentity(IdentityID)
	return OnlineStatusUtil.CheckBit(self.MajorIdentity, IdentityID)
end

---判断本地玩家是否拥有某个状态
---@param StatusID number
---@return boolean
---@public
function OnlineStatusMgr:MajorHasStatus(StatusID)
	return OnlineStatusUtil.CheckBit(self.MajorStatus, StatusID)
end

---玩家通过设置界面主动设置在线状态
---@param StatusID number 在线状态ID
---@param FromView bool 是否来自设置界面
---@public
function OnlineStatusMgr:SetCustomStatus(StatusID, FromView)
	if StatusID == nil then
		_G.FLOG_WARNING("OnlineStatusMgr:SetCustomStatus: StatusID is nil.")
		return
	end
	
	if self.ViewStateSetting and FromView then
		_G.FLOG_WARNING("OnlineStatusMgr:SetCustomStatus: StateSetting is true, Failed to initiate state change.")
		return
	end
	
	-- 对于离开状态要单独处理
	if StatusID == OnlineStatusRes.OnlineStatusLeave then
		-- 走上报协议
		self:RequestEnterLeaveStatus()
		-- 开始防误触保护
		self.LeaveStatusProtectStartTime = TimeUtil.GetServerTime()
	else
		-- 不管在不在离开状态，直接退出一次，可以安全调用
		self:RequestQuitLeaveStatus()
		-- 走设置协议
		_G.ClientSetupMgr:SendSetReq(ClientSetupKey.CSOnlineStatusSet, tostring(StatusID))
	end

	if FromView then 
		self.ViewStateSetting = self:RegisterTimer(self.StateSettingTiming, 2)  -- 其他状态，加个回包时间判定
	end
end

---主角是否处于离开状态
---@return boolean
---@public
function OnlineStatusMgr:IsLeave()
	return OnlineStatusUtil.CheckBit(self.MajorStatus, OnlineStatusRes.OnlineStatusLeave)
end

--- Interface END ---


return OnlineStatusMgr