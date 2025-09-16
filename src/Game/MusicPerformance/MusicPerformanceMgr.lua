--[[
Date: 2023-10-24 19:09:35
LastEditors: moody
LastEditTime: 2023-10-24 19:09:35
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local MPPerformPlayBuffer = require("Game/MusicPerformance/PlayBuffer/MPPerformPlayBuffer")
local MPEnsembleBuffer = require("Game/MusicPerformance/CommandBuffer/MPEnsembleBuffer")
local MPPerformBuffer = require("Game/MusicPerformance/CommandBuffer/MPPerformBuffer")
local MPPerformSound = require("Game/MusicPerformance/Sound/MPPerformSound")
local MPRequestWork = require("Game/MusicPerformance/MPRequestWork")
local MPEnsembleWork = require("Game/MusicPerformance/MPEnsembleWork")
local MPCharacter = require("Game/MusicPerformance/MPCharacter")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local EventID = require("Define/EventID")
local SaveKey = require("Define/SaveKey")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local TimeUtil = require("Utils/TimeUtil")
local ProfDefine = require("Game/Profession/ProfDefine")

local MPAssistant = require("Game/MusicPerformance/Assistant/MPAssistant")

local ProtoCS = require ("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local NetworkMsgConfig = require("Define/NetworkMsgConfig")

local InstrumentCfg = require("TableCfg/InstrumentCfg")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local PerformAssistantCfg = require("TableCfg/PerformAssistantCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local LoginMgr = require("Game/Login/LoginMgr")

local CS_CMD = ProtoCS.CS_CMD
local PERFORM_CMD = ProtoCS.PerformCmd

local EnsembleErrorCode1 = 168011 -- 后台定义的错误码，附近有一场景合奏正在进行，不能发起合奏
local EnsembleErrorCode2 = 101065 --后台异常，比如合奏中出现异常

local MusicPerformanceMgr = LuaClass(MgrBase)

function MusicPerformanceMgr:OnInit()
	self.CharacterBuffer = {} --演奏角色列表，在此角色离开视野后会清理
	self.PlayBuffer = {}
	for i = 0, MPDefines.PlayBufferMax - 1 do
		local NewBuffer = MPPerformPlayBuffer.New()
		self.PlayBuffer[i] = NewBuffer
	end

	self.RequestWorks = {}
	for i = 0, MPDefines.RequestMax - 1 do
		self.RequestWorks[i] = MPRequestWork.New()
	end

	self.EnsembleBuffer = MPEnsembleWork.New()
	self.EnsembleBuffer:Initialize()

	self.PerformCommand = MPPerformBuffer.New()
	self.EnsembleCommand = MPEnsembleBuffer.New()

	self.Timbre        = 0
	self.TimelineCount = 0
	self.ModeTimer     = 0.0
	self.PrepareTimer  = 0.0
	self.ReadyFlag     = false
	self.ModeFlag      = false
	self.EnsembleFlag  = false
	self.EnsemblePartyID = 0
	self.IsSwitchSelectPanel = false

	self.SelectedPerformData = nil

	self.LongClickStates = {}

	self.ToneOffset = 0

	self:ClearCommandBuffer()

	self.Assistant = nil
	self.TeamPlayerList = {}
	self.CharacterEndAnimData = {}  --记录退出演奏的动作

	self.bShortReconnect = false --是否闪断情况

	-- Debug
	self.DebugValue = 0
	self.bOpenEnsembleGM = false
end

function MusicPerformanceMgr:GetMajorSound()
	if self.Sound then
		return self.Sound
	end

	self.Sound = MPPerformSound.New()
	self.Sound:Initialize()
	self.Sound:AddPlayer(MajorUtil.GetMajorEntityID())
	self.Sound:StartRecord()

	return self.Sound
end

function MusicPerformanceMgr:ClearMajorSound()
	if self.Sound then
		self.Sound:Terminate()
		self.Sound = nil
	end
end

function MusicPerformanceMgr:OnEnd()
	self.CharacterBuffer = {}
	for _, Buffer in pairs(self.PlayBuffer) do
		Buffer:Clear()
	end

	if self.EnsembleBuffer:IsUse() then
		self.EnsembleBuffer:Clear()
	end

	self:AbortPerform()

	self:ClearMajorSound()
	if _G.MusicPerformanceVM then
		_G.MusicPerformanceVM:CancelTimer()
	end
end

function MusicPerformanceMgr:AbortPerform()
	if self.ModeFlag == false then
		return
	end

	self:AbortCommand()

	self.Timbre = 0
	self.ModeTimer = 0
	self.ModeFlag = false
	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatPerform, false)
end

function MusicPerformanceMgr:GetAssistantInst()
	-- 懒加载
	if self.Assistant then
		return self.Assistant
	end

	self.Assistant = MPAssistant.New()
	return self.Assistant
end

function MusicPerformanceMgr:IsAssistantMode()
	return self.Assistant and self.Assistant.IsWorking
end

function MusicPerformanceMgr:OnRegisterNetMsg()
	-- Enter事件表示主角回包的情感动作的即时广播
	-- Notify事件表示其他玩家回包的情感动作的即时广播
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.PerformCmdEnter, self.OnNetMsgPerformCmdEnterNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.PerformCmdExit, self.OnNetMsgPerformCmdExitNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.PerformCmdPerform, self.OnNetMsgPerformCmdPerform)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.EnsembleCmdEnsemble, self.OnNetMsgEnsembleCmdEnsemble)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.EnsembleCmdAskConfirm, self.OnNetMsgEnsembleCmdAskConfirm)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.EnsembleCmdNotifyReady, self.OnNetMsgEnsembleCmdNotifyReady)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.EnsembleCmdConfirm, self.OnNetMsgEnsembleCmdConfirm)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.EnsembleCmdExit, self.OnNetMsgEnsembleCmdExit)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERFORM, PERFORM_CMD.EnsembleCmdQuery, self.OnNetMsgEnsembleCmdQuery)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)
end

function MusicPerformanceMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MusicPerformanceToneOffset, self.OnGameEventMusicPerformanceToneOffset)
	self:RegisterGameEvent(EventID.MusicPerformanceVisionStart, self.OnOtherCharacterVisionEnter)
	self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnGameEventMajorProfSwitch)
	self:RegisterGameEvent(EventID.Avatar_Update_Master, self.OnGameEventAvatar_Update_Master)
	self:RegisterGameEvent(EventID.AttackEffectChange, self.OnGameEventAttackEffectChange)

	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
	self:RegisterGameEvent(EventID.TeamVoteEnterSceneEnd, self.OnVoteEnterSceneEnd)
	self:RegisterGameEvent(EventID.MajorFirstMove, self.MajorFirstMove)
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)

	--侦听断线重连成功的通知(由于RoleLoginRes是postEvent发送，比MusicPerformanceVisionStart晚，顺序不对用不了，直接取LoginMgr.bReconnect)
	-- self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
	--侦听闪断事件
	self:RegisterGameEvent(EventID.NetworkReconnected, self.OnNetworkReconnected)
end

--乐器演奏系统解锁
function MusicPerformanceMgr:OnModuleOpenNotify(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDPerform then
        --演奏埋点(系统解锁)
		DataReportUtil.ReportSystemFlowData("PerformanceFlow", tostring(1), tostring(0))
    end
end

--进入副本时，退出演奏
function MusicPerformanceMgr:OnVoteEnterSceneEnd(ModuleID)
	self:ReqAbortPerform()
	self:ExitPerformance(MajorUtil.GetMajorEntityID())
end

function MusicPerformanceMgr:OnGameEventMajorProfSwitch(Params)
	if Params.Reason == ProfDefine.ProfSwitchReason.MusicPerformance and Params.ProfID == ProtoCommon.prof_type.PROF_TYPE_BARD then
		MusicPerformanceUtil.Log("MusicPerformanceMgr:OnGameEventMajorProfSwitch switch success")
		_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSelectPanelView)
	end
end

function MusicPerformanceMgr:OnGameEventAvatar_Update_Master(Params)
	local EntityID = Params.ULongParam1
	if MajorUtil.IsMajor(EntityID) then
		local Work = self:GetWork(EntityID)
		if Work == nil then
			return
		end

		-- 重置摄像机状态
		if Work:IsValid() then
			local TimbreData = Work:GetTimbreData()
			if TimbreData == nil then
				return
			end
			Work:ChangeCameraOffset(EntityID, TimbreData, false)
		end
	end
end

function MusicPerformanceMgr:OnGameEventMusicPerformanceToneOffset(Offset)
	self.ToneOffset = Offset
end

function MusicPerformanceMgr:GetToneOffset()
	return self.ToneOffset
end

------------------------------------------------------断线重连-----------------------------------------------------------------
-- function MusicPerformanceMgr:OnGameEventRoleLoginRes(Params)
-- 	--bReconnect=true是断线重连 false是正常从登陆进来的
-- 	self.bReconnect = Params.bReconnect
-- 	if bReconnect == true then
-- 		self.bShortReconnect = false
-- 	end
-- end

--断线重连，重连成功时
function MusicPerformanceMgr:OnNetworkReconnected(Params)
	--bRelay=true为闪断 false则接下来是要返回登陆，走流程的
	self.bShortReconnect = Params.bRelay
end

--断线重连，重连/重登时， PWorldEnterRsp 协议通知主角是否在演奏状态，乐器
function MusicPerformanceMgr:OnNotityMajorPerformanceState(PerformID)
    self.MajorPerformID = PerformID
	local EntityID = MajorUtil.GetMajorEntityID()
	FLOG_INFO("MusicPerformance Reconnected OnNotityMajorPerformanceState, EntityID=%d  PerformID=%d", EntityID, self.MajorPerformID)
	
	--此时的self.MajorPerformID为0时，服务器说表示不在演奏状态了，比如断线超过5分钟服务器就自动退出并清空演奏数据
	if EntityID ~= 0 and self.MajorPerformID == 0 then
		self:ReqAbortPerform() --客户端主动请求一次退出演奏，防止演奏状态出问题
		self:ExitPerformance(EntityID)
		self:ReqAbortEnsemble()
	end
end

function MusicPerformanceMgr:OnGameEventMajorCreate()
    local EntityID = MajorUtil.GetMajorEntityID()
	FLOG_INFO("MusicPerformance Reconnected OnGameEventMajorCreate, EntityID=%d  PerformID=%d", EntityID, self.MajorPerformID)
	if self.MajorPerformID ~= 0 then
		self:OnMajorCharacterVisionEnter(EntityID, self.MajorPerformID)
	end
	self.MajorPerformID = 0
end

--断线重连，处理主角进入演奏视野
function MusicPerformanceMgr:OnMajorCharacterVisionEnter(EntityID, PerformID)
	local bReconnect = LoginMgr.bReconnect
	FLOG_INFO("MusicPerformance Reconnected MajorVisonEnter, EntityID=%d PerformID=%d bShortReconnect=%s,  bReconnect=%s", EntityID, PerformID, 
	(self.bShortReconnect and "true" or "false"), (bReconnect and "true" or "false"))

	-- 暂时注释掉：目前新流程貌似不会出现此情况了（闪断情况不用处理，面板不会关闭，但Start事件会进入）
	-- if self.bShortReconnect then
	-- 	return
	-- end

	--初始化红点数据
	self:InitRedDotData()

	--区别重连、重登
	if bReconnect then
		--视野进入演奏状态
		self:Start(EntityID, PerformID)

		self:GetAssistantInst():Stop()	
		-- 显示演奏主界面
		self:SetSelectedPerformData(InstrumentCfg:FindCfgByKey(PerformID))
		_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceMainPanelView,{ IsFromSelectPanel = false } )

		-- 查询演奏状态
		local MsgID = CS_CMD.CS_CMD_PERFORM
		local SubMsgID = PERFORM_CMD.EnsembleCmdQuery
		local MsgBody = {
			Cmd = SubMsgID
		}
		GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

	else
		self:ReqAbortEnsemble()
		self:ReqAbortPerform()
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceMainPanelView) then
			_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceMainPanelView)
		end
	end
end

--断线重连，处理P3其他角色进入演奏视野
function MusicPerformanceMgr:OnOtherCharacterVisionEnter(Params)
	local EntityID = Params.ULongParam1
	local PerformID = Params.IntParam1
	FLOG_INFO("MusicPerformance Reconnected OtherCharacterVisonEnter, EntityID=%d PerformID=%d", EntityID, PerformID)
	self:Start(EntityID, PerformID)
end
------------------------------------------------------断线重连-----------------------------------------------------------------

function MusicPerformanceMgr:OnNetMsgEnsembleCmdNotifyReady(MsgBody)
	FLOG_INFO("MusicPerformance Reconnected OnNetMsgEnsembleCmdNotifyReady, Status=%d", MsgBody.Ready.Status)
	if MsgBody.Ready.Status ~= ProtoCS.EnsembleStatus.EnsembleStatusEnsemble then
		-- 合奏请求超时
		self:EnsembleTeamFail()
		_G.MusicPerformanceVM.Status = MsgBody.Ready.Status or ProtoCS.EnsembleStatus.EnsembleStatusPerform
		return
	end
	
	self:EnterEnsembleStatus(MsgBody.Ready.Status or ProtoCS.EnsembleStatus.EnsembleStatusPerform, MsgBody.Ready.BeginTimeMS, MsgBody.Ready.Owner)
end

function MusicPerformanceMgr:EnterEnsembleStatus(Status, BeginTimeMS, Owner)
	local ServerTimeMS = TimeUtil.GetServerTimeMS()
	_G.MusicPerformanceVM.BeginTimeMS = BeginTimeMS or ServerTimeMS
	_G.MusicPerformanceVM.Status = Status
	self.EnsemblePartyID = Owner
	FLOG_INFO("MusicPerformance EnterEnsembleStatus, BeginTimeMS=%s ServerTimeMS=%s EnsemblePartyID=%s", tostring(BeginTimeMS), tostring(ServerTimeMS), tostring(self.EnsemblePartyID))
	if ServerTimeMS > _G.MusicPerformanceVM.BeginTimeMS then
		-- 直接进入合奏
		self:StartEnsemble()
	else
		-- 延时进入合奏
		_G.MusicPerformanceVM:BeginReady(MPDefines.Ensemble.DefaultSettings.CountDownTime,
			MPDefines.Ensemble.DefaultSettings.CountDownTime - (_G.MusicPerformanceVM.BeginTimeMS - TimeUtil.GetServerTimeMS()) / 1000,
		function()
			self:StartEnsemble()
		end)
	end
end

function MusicPerformanceMgr:OnNetMsgEnsembleCmdConfirm(MsgBody)
	local Confirm = MsgBody.Confirm or {}
	local EntityID = Confirm.EntityID
	local IsAgree = Confirm.IsAgree
	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)

	local Status = IsAgree and MPDefines.ConfirmStatus.ConfirmStatusConfirm or MPDefines.ConfirmStatus.ConfirmStatusCancel
	_G.MusicPerformanceVM.EnsembleConfirmStatus[RoleID] = Status
	
	if _G.TeamMgr:IsCaptainByRoleID(RoleID) and not IsAgree then
		-- 队长退出
		_G.MusicPerformanceVM.Status = ProtoCS.EnsembleStatus.EnsembleStatusPerform
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceEnsembleConfirmView)
		_G.MsgTipsUtil.ShowTips(_G.LSTR(830109))
	else
		--队长点"开始合奏"后也会收到此协议，此时状态为EnsembleStatusEnsemble
		if _G.MusicPerformanceVM.Status == ProtoCS.EnsembleStatus.EnsembleStatusConfirm then
			--全部同意完毕后，需要打开隐藏的组队确认界
			if self:GetTeamConfirmResult() == MPDefines.TeamConfirmResult.AllAgree then
				if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceEnsembleConfirmView) then
					_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceEnsembleConfirmView)
				end
			elseif self:GetTeamConfirmResult() == MPDefines.TeamConfirmResult.SomeoneRefused then
				self:EnsembleTeamFail()
				_G.MusicPerformanceVM.Status = ProtoCS.EnsembleStatus.EnsembleStatusPerform
			end
		end
		_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceEnsembleConfirm, {RoleID = RoleID, ConfirmStatus = Status})
	end
end

function MusicPerformanceMgr:OnNetMsgEnsembleCmdExit(MsgBody)
	local ExitEnsemble = MsgBody.ExitEnsemble or {}
	local EntityID = ExitEnsemble.EntityID
	local IsCaptain = _G.TeamMgr:IsCaptainByRoleID(ActorUtil.GetRoleIDByEntityID(EntityID))
	local IsMajor = MajorUtil.IsMajor(EntityID)

	FLOG_INFO("MusicPerformance Ensemble: OnNetMsgEnsembleCmdExit, EntityID=%s  IsCaptain=%s  IsMajor=%s", tostring(EntityID), IsCaptain and "true" or "false", IsMajor and "true" or "false")
	if IsMajor then
		self:AbortEnsemble()
	end

	local TipContent = nil
	--队长结束合奏
	if IsCaptain then
		TipContent = IsMajor and _G.LSTR(830127) or _G.LSTR(830124)
	else
		TipContent = IsMajor and _G.LSTR(830123) or ActorUtil.GetActorName(EntityID) .. _G.LSTR(830123)
	end
	if TipContent ~= nil then
		_G.MsgTipsUtil.ShowTips(TipContent)
	end
end

--合奏组队失败(合奏准确确认过程，不处理合奏过程)
function MusicPerformanceMgr:EnsembleTeamFail()
	
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceEnsembleConfirmView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceEnsembleConfirmView)
	end

	--判断是不是合奏准确确认过程，因为合奏过程队长退出时也会收到
	if _G.MusicPerformanceVM.Status == ProtoCS.EnsembleStatus.EnsembleStatusConfirm then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(830116))
	end

	if _G.TeamMgr:IsCaptain() then
		_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceEnsembleMetronmeView)
	end

	-- 清除确认状态
	_G.MusicPerformanceVM.EnsembleConfirmStatus = {}
end

function MusicPerformanceMgr:SetTeamPlayerList(InTeamPlayerList)
	self.TeamPlayerList = InTeamPlayerList
end

--获取队伍所有成员的确认结果
function MusicPerformanceMgr:GetTeamConfirmResult()
	if self.TeamPlayerList.Items == nil or #self.TeamPlayerList.Items <= 0 then
		return
	end

	local IsAllConfirm = true
	local IsAllAgree = true
	for _, Player in pairs(self.TeamPlayerList.Items) do
		--队长不用检查，发起即同意
		if _G.TeamMgr:IsCaptainByRoleID(Player.RoleID) then
			goto continue
		end
		--还未选择确认结果
		if _G.MusicPerformanceVM.EnsembleConfirmStatus[Player.RoleID] == nil then
			IsAllConfirm = false
		end
		if _G.MusicPerformanceVM.EnsembleConfirmStatus[Player.RoleID] ~= MPDefines.ConfirmStatus.ConfirmStatusConfirm then
			IsAllAgree = false
		end
		::continue::
	end

	if not IsAllConfirm then
		return MPDefines.TeamConfirmResult.NotConfirm
	end
	
	return IsAllAgree and MPDefines.TeamConfirmResult.AllAgree or MPDefines.TeamConfirmResult.SomeoneRefused
end

function MusicPerformanceMgr:OnNetMsgEnsembleCmdQuery(MsgBody)
	-- 断线重连后，重新查询演奏状态
	local Query = MsgBody.Query or {}
	local Status = Query.Status or ProtoCS.EnsembleStatus.EnsembleStatusPerform
	if _G.MusicPerformanceVM == nil then
		return
	end
	_G.MusicPerformanceVM.EnsembleMetronome = Query.Metronome or {}
	local StatusTime = Query.StatusTime or 0
	FLOG_INFO("MusicPerformance EnterEnsembleStatus, tatus=%s  StatusTime=%s  Owner=%s", tostring(Status), tostring(StatusTime), tostring(Query.Owner))
	if Status == ProtoCS.EnsembleStatus.EnsembleStatusConfirm then
		if StatusTime > 0 then
			-- 恢复确认面板
			_G.MusicPerformanceVM:BeginReady(MPDefines.Ensemble.DefaultSettings.ReadyTime,
			TimeUtil.GetServerTime() - StatusTime + MPDefines.Ensemble.DefaultSettings.ReadyTime)

			-- 清除确认状态
			_G.MusicPerformanceVM.EnsembleConfirmStatus = {}
			for _, ConfirmStatus in pairs(Query.Confirm or {}) do
				_G.MusicPerformanceVM.EnsembleConfirmStatus[ConfirmStatus.RoleID] = ConfirmStatus.Status
			end
			_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceEnsembleConfirmView)
		end
	elseif Status == ProtoCS.EnsembleStatus.EnsembleStatusReady then
		-- 清除确认状态
		_G.MusicPerformanceVM.EnsembleConfirmStatus = {}
		for _, ConfirmStatus in pairs(Query.Confirm or {}) do
			_G.MusicPerformanceVM.EnsembleConfirmStatus[ConfirmStatus.RoleID] = ConfirmStatus.Status
		end
		_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceEnsembleConfirmView)
	elseif Status == ProtoCS.EnsembleStatus.EnsembleStatusEnsemble then
		local Owner = Query.Owner or 0
		-- 继续合奏
		if StatusTime > 0 then
			self:EnterEnsembleStatus(Status, StatusTime, Owner)
		end
	end
	_G.MusicPerformanceVM.Status = Status
end

function MusicPerformanceMgr:OnNetMsgError(MsgBody)
	local Msg = MsgBody
	if nil == Msg then
		return
	end

	local Cmd = Msg.Cmd
	if nil == Cmd then
		return
	end
	local SubCmd = Msg.SubCmd or 0

	FLOG_INFO("OnNetMsgError, ErrCode=%s, Cmd=%s, SubCmd=%s", tostring(Msg.ErrCode), tostring(Cmd), tostring(SubCmd))

	-- if Msg.ErrCode == EnsembleErrorCode1 then
    --     self:EnsembleTeamFail()
	-- elseif Msg.ErrCode == EnsembleErrorCode2 then
	-- 	self:ReqAbortEnsemble()
    -- end
end

-- 队长-发起合奏准备确认
function MusicPerformanceMgr:OnNetMsgEnsembleCmdAskConfirm(MsgBody)
	if MsgBody.ErrorCode then
		FLOG_INFO("OnNetMsgError(EnsembleCmdAskConfirm), ErrCode=%s", tostring(MsgBody.ErrorCode))
		if MsgBody.ErrorCode == EnsembleErrorCode1 then
			self:EnsembleTeamFail()
		end
        return 
    end

	_G.MusicPerformanceVM.EnsembleMetronome = MsgBody.AskConfirm and MsgBody.AskConfirm.Metronome or {}
	_G.MusicPerformanceVM.Status = ProtoCS.EnsembleStatus.EnsembleStatusConfirm

	_G.MusicPerformanceVM:BeginReady(MPDefines.Ensemble.DefaultSettings.ReadyTime, 
		TimeUtil.GetServerTime() - MsgBody.AskConfirm.ConfirmTimeS + MPDefines.Ensemble.DefaultSettings.ReadyTime)

	-- 清除确认状态
	_G.MusicPerformanceVM.EnsembleConfirmStatus = {}

	_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceEnsembleMetronmeView)
	_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceEnsembleConfirmView)
end

--取消/拒绝-发起合奏准备确认
function MusicPerformanceMgr:CancelEnsembleCmdConfirm()
	-- 拒绝合奏
	local MsgID = CS_CMD.CS_CMD_PERFORM
	local SubID = PERFORM_CMD.EnsembleCmdConfirm
	local MsgBody = {
		Cmd = SubID,
		Confirm = {
			IsAgree = false
		}
	}
	MusicPerformanceUtil.Log(table.tostring(MsgBody))
	GameNetworkMgr:SendMsg(MsgID, SubID, MsgBody)
	
	_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceEnsembleConfirmView)
	-- 退出确认状态
	_G.MusicPerformanceVM.Status = ProtoCS.EnsembleStatus.EnsembleStatusPerform
end

--服务器通知进入乐器演奏(切换乐器成功)
function MusicPerformanceMgr:OnNetMsgPerformCmdEnterNotify(MsgBody)
	local EntityID = MsgBody.EnterNotify.EntityID
	local Instrument = MsgBody.EnterNotify.Instrument
	MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:OnNetMsgPerformCmdEnterNotify EntityID:%d InstrumentID :%d", EntityID, Instrument))
	self:Start(EntityID, Instrument)
end

function MusicPerformanceMgr:OnNetMsgPerformCmdExitNotify(MsgBody)
	local EntityID = MsgBody.ExitNotify.EntityID
	FLOG_INFO("MusicPerformance OnNetMsgPerformCmdExitNotify, EntityID=%s", tostring(EntityID))

	self:ExitPerformance(EntityID)
end

function MusicPerformanceMgr:ExitPerformance(EntityID)
	FLOG_INFO("MusicPerformance ExitPerformance, EntityID=%s", tostring(EntityID))
	self:Exit(EntityID)
	if EntityID == MajorUtil.GetMajorEntityID() then
		-- 清空VM数据
		_G.MusicPerformanceVM:Reset()
		if not self.IsSwitchSelectPanel then
			self:CloseAllPerformancePanel()
		end
		self.IsSwitchSelectPanel = false
	end
end

function MusicPerformanceMgr:OnNetMsgPerformCmdPerform(MsgBody)
	if MsgBody and MsgBody.PerformNotify then
		local EntityID = MsgBody.PerformNotify.EntityID
		local Player = ActorUtil.GetActorByEntityID(EntityID)
		MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:OnNetMsgPerformCmdPerform EntityID : %d", EntityID))
		self:Play(EntityID, Player, MsgBody.PerformNotify)
	end
end

function MusicPerformanceMgr:OnNetMsgEnsembleCmdEnsemble(MsgBody)
	--MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:OnNetMsgEnsembleCmdEnsemble EntityID : %d", EntityID))
	if MsgBody.Ensemble then
		self:Receive(MsgBody.Ensemble)
	end
end

function MusicPerformanceMgr:GetSelectedPerformData()
	return self.SelectedPerformData
end

function MusicPerformanceMgr:GetGroupID(PerformData)
	if PerformData == nil then
		return nil
	end

	local GroupID = PerformData.InstrumentGroup or 0
	local GroupData = {}

	if GroupID ~= 0 then
		-- 获取GroupData
		GroupData = MusicPerformanceUtil.GetPerformGroupData(GroupID)
	end


	local CurID = PerformData.ID
	for Index = 0, MPDefines.GroupMax - 1 do
		local GroupItemID = GroupData["ID" .. tostring(Index)]
		if GroupItemID ~= nil and GroupItemID ~= 0 and GroupItemID == CurID then
			return Index + 1
		end
	end

	return nil
end

function MusicPerformanceMgr:SetSelectedPerformData(Data)
	self.SelectedPerformData = Data or {}
	-- _G.UE.USaveMgr.SetInt(SaveKey.LastMusicPerformID, Data.ID or 0, true)
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformancePerformDataChanged, self.SelectedPerformData)
end

function MusicPerformanceMgr:ClearCommandBuffer()
	for i = 0, MPDefines.RequestMax - 1 do
		self.RequestWorks[i]:Clear()
	end

	self.RequestIndex = 0
	self.RequestCount = 0
	self.RestTimer    = 0.0
	self.ExecFlag     = false
	self.PerformCommand:Clear()
	self.EnsembleCommand:Initialize()

	self.LongClickStates = {}
end

function MusicPerformanceMgr:AbortCommand()
	self:ClearCommandBuffer()
	self:ClearMajorSound()
end

-- TODO
function MusicPerformanceMgr:CheckError(IsModeCheck)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return MPDefines.ErrorCode.ErrorCodeSetup
	end

	-- 地图不允许
	-- 只有诗人可以演奏
	local ProfID = MajorUtil.GetMajorProfID()
	if ProfID ~= ProtoCommon.prof_type.PROF_TYPE_BARD then
		return "Error Prof"
	end

	-- 没有奖励

	if IsModeCheck == true then
		-- 演奏模式
	end

	-- 处于不能演奏的状态

	-- 没有演奏权限

	return MPDefines.ErrorCode.ErrorCodeNone
end

function MusicPerformanceMgr:IsEnable(IsModeCheck)
	local Result = false
	local ErrorID = self:CheckError(IsModeCheck)
	
	if ErrorID == MPDefines.ErrorCode.ErrorCodeNone then
		Result = true
	elseif ErrorID == MPDefines.ErrorCode.ErrorCodeMode then
	elseif ErrorID == MPDefines.ErrorCode.ErrorCodeSetup then
	else
	end
	if Result == false then
		MusicPerformanceUtil.Log(" IsEnable ErrorCode " .. ErrorID)
	end
	return Result
end

function MusicPerformanceMgr:IsValidInstrument(ID)
	if ID == 0 then
		return false
	end

	local PerformData = MusicPerformanceUtil.GetPerformData(ID)
	if PerformData == nil then
		return false
	end

	-- if PerformData.Reward ~= 0 then

	-- end

	return true
end

function MusicPerformanceMgr:SetMode(ID)
	self:SetModeLocal(ID)
end

function MusicPerformanceMgr:SetModeLocal(ID, Arg)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	if ID == 0 then
		if not MusicPerformanceUtil.IsMPMode() then
			-- 未进入演奏模式
			return
		end
	else
		if self:IsEnable(false) == false then
			return
		end

		if self:IsValidInstrument(ID) == false then
			return
		end

		if MusicPerformanceUtil.IsMPMode() then
			return
		end
	end
	
	self.PrepareTimer = 1.0
	-- 告知服务器切换乐器
	local MsgID = CS_CMD.CS_CMD_PERFORM
	local SubID = PERFORM_CMD.PerformCmdEnter
	local MsgBody = {
		Cmd = SubID,
		Enter = {
			Instrument = ID
		}
	}

	MusicPerformanceUtil.Log(table.tostring(MsgBody))
	
	GameNetworkMgr:SendMsg(MsgID, SubID, MsgBody)
end

function MusicPerformanceMgr:Request(Key)
	-- local ObjectGCType = require("Define/ObjectGCType")
	-- local Event = _G.ObjectMgr:LoadObjectSync("AkAudioEvent'/Game/WwiseAudio/Events/Default_Work_Unit/Play_MusicPlayer.Play_MusicPlayer'", ObjectGCType.Hold)
	-- local MulPlayer = _G.UE.FMusicPerformanceHandler.CreateMultipleMusicPlayer()
	-- local Init = _G.UE.FMusicPerformanceHandler.InitMultiPlayer(MulPlayer, "Play_MusicPlayer")
	-- print("start init" .. tostring(Init))
	-- local Prepare = _G.UE.FMusicPerformanceHandler.Prepare(MulPlayer)
	-- print("start parpare" .. tostring(Prepare))

	-- local TrackPlayer = _G.UE.FMusicPerformanceHandler.CreateTrackPlayer(MulPlayer, 0
	-- 	, _G.UE.UAudioMgr.GetAkGameObjectID(MajorUtil.GetMajor(), ""), "026steelguitar.sf2")
	-- print("start" .. tostring(TrackPlayer))

	-- local AudioUtil = require("Utils/AudioUtil")
	-- local ID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), "AkAudioEvent'/Game/WwiseAudio/Events/Default_Work_Unit/Play_MusicPlayer.Play_MusicPlayer'")
	-- print("test" .. tostring(ID))
	-- local RecordRes = _G.UE.FMusicPerformanceHandler.Record(MulPlayer, "", 500, 0)
	-- print("start record" .. tostring(RecordRes))
	-- local Res = _G.UE.FMusicPerformanceHandler.Press(TrackPlayer, Key, 0, -1, 10000)
	-- --_G.UE.FMusicPerformanceHandler.EndPress(TrackPlayer, 36, 10000, -1, 10000)
	-- print("Start" .. tostring(Res))
	-- --_G.UE.FMusicPerformanceHandler.DeleteMultipleMusicPlayer(MulPlayer)


	MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:Request Key : %d", Key))
	if Key ~= MPDefines.KeyOff then
		if Key < MPDefines.KeyStart or Key > MPDefines.KeyEnd then
			MusicPerformanceUtil.Log(" Request Error Key " .. Key)
			return false
		end
	end

	if self:IsEnable(true) == false then
		return false
	end

	if self.ModeFlag == false then
		-- 没进入演奏状态
		return false
	end

	if Key == MPDefines.KeyOff then
		--self.StopFlag = true
		return true
	end

	if self.RequestCount >= MPDefines.RequestMax then
		MusicPerformanceUtil.Log(" Request count overflow! ")
		return false
	end

	local Index = (self.RequestIndex + self.RequestCount) % MPDefines.RequestMax
	self.RequestWorks[Index]:Set(Key, self.Timbre)
	self.RequestCount = self.RequestCount + 1
	--self.StopFlag = false

	return true
end

--请求开始长按状态
function MusicPerformanceMgr:RequestLongPress(Key, IsPress)
	MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:RequestLongPress Key : %d IsPress = %s", Key, tostring(IsPress)))
	if Key ~= MPDefines.KeyOff then
		if Key < MPDefines.KeyStart or Key > MPDefines.KeyEnd then
			MusicPerformanceUtil.Log(" Request Error Key " .. Key)
			return false
		end
	end

	if self:IsEnable(true) == false then
		return false
	end

	if self.ModeFlag == false then
		-- 没进入演奏状态
		return false
	end

	local ClickState = self.LongClickStates[Key]
	if not IsPress and ClickState == nil then
		-- 没有按下
		return false
	end

	ClickState = ClickState or {}
	self.LongClickStates[Key] = ClickState
	-- 状态改变了才去记录
	if IsPress ~= ClickState.IsPress then
		-- 刚按下还没处理就释放了，保证第一次能够播出
		if ClickState.IsPress and ClickState.IsNewState then
			ClickState.IsReleaseAtSameFrame = true
		else
			ClickState.IsReleaseAtSameFrame = nil
		end
		ClickState.IsPress = IsPress
		ClickState.IsNewState = true
		ClickState.ReleaseTime = MPDefines.PlayLimit --长按持续时长为4秒，4秒后会自动释放变为弹起状态
		ClickState.Timbre = self.Timbre
		return true
	end

	return false
end

--释放长按状态
function MusicPerformanceMgr:RefreshLongClickStates(DeltaTime)
	local HasNewState = false
	local HasClickState = false
	for _, ClickState in pairs(self.LongClickStates) do
		-- 按下超时，则清除状态
		-- 判断IsNewState，避免按下的第一帧就影响了ReleaseTime
		if not ClickState.IsNewState and ClickState.IsPress then
			ClickState.ReleaseTime = ClickState.ReleaseTime - DeltaTime
			if ClickState.ReleaseTime <= 0 then
				ClickState.IsPress  = false
				ClickState.IsNewState = true
			end
		end
		HasNewState = HasNewState or ClickState.IsNewState
		HasClickState = true
	end
	return HasNewState, HasClickState
end

function MusicPerformanceMgr:ShowAssistantView(SongVM, Rate,ToggleMetronome)
	_G.UIViewMgr:ShowView(_G.UIViewID.PerformanceAssistantPanelView, 
		{Data = SongVM, Rate = Rate, ToggleMetronome = ToggleMetronome})
end

function MusicPerformanceMgr:SetTimbre(Timbre)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return false
	end

	local Work = self:GetWork(MajorUtil.GetMajorEntityID())
	if Work == nil then
		return false
	end

	if Work:IsValid() == false then
		return false
	end

	if Work:IsGroup() == false then
		-- 音色切换不起作用
		return false
	end

	if Timbre >= Work:GetGroupCount() then
		-- 音色不对
		return false
	end

	self.Timbre = Timbre
	return true
end

function MusicPerformanceMgr:Play(EntityID, Chara, MsgBody)
	MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:Play EntityID : %d", EntityID))
	if not ActorUtil.IsPlayerOrMajor(EntityID) then
		return
	end

	local Index = self:FindBuffer(EntityID)

	if Index < 0 then
		if Chara == nil then
			return
		end

		local Work = self:GetWork(EntityID)
		if Work == nil or Work:IsValid() == false then
			return
		end

		Index = self:FindFreeBuffer()

		if Index >= 0 then
			local PerformBuffer = self.PlayBuffer[Index]
			PerformBuffer:Initialize(EntityID)
			PerformBuffer:Set(MsgBody)
		end
	else
		local PerformBuffer = self.PlayBuffer[Index]
		if Chara == nil then
			PerformBuffer:Clear()
		else
			PerformBuffer:Set(MsgBody)
		end
	end
end

function MusicPerformanceMgr:IsOpenEnsembleAssistant()
	return _G.MusicPerformanceVM.EnsembleMetronome.Assistant
end

function MusicPerformanceMgr:IsInEnsembleWithAssistant()
	return self.EnsembleFlag and self:IsOpenEnsembleAssistant()
end

function MusicPerformanceMgr:IsInEnsembleWithoutAssistant()
	return self.EnsembleFlag and not self:IsOpenEnsembleAssistant()
end

-- IsSelf 是指是否是本地指令调用过来的 如果经由服务器 即使是自己的指令 IsSelf也是false
function MusicPerformanceMgr:PlayKey(EntityID, Sound, Key, Timbre, IsSelf, IsKeyOff)
	MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:PlayKey EntityID : %s, Key : %s, Timbre : %s, IsSelf : %s, IsKeyOff : %s"
		, tostring(EntityID), tostring(Key), tostring(Timbre), tostring(IsSelf), tostring(IsKeyOff)))
	if Key < MPDefines.KeyStart or Key > MPDefines.KeyEnd then
		MusicPerformanceUtil.Log(" Play Key with invalid key " .. Key)
		return
	end

	local Work = self:GetWork(EntityID)
	if Work == nil then
		print("Work is Nil")
		return
	end

	if not Work:IsValid() then
		return
	end

	if not IsKeyOff then
		if Work:IsGroup() == true then
			Work:SetTimbre(EntityID, Timbre)
		end
	end

	local TimbreData = Work:GetTimbreData()
	if TimbreData == nil then
		return
	end

	local IsMotion = true
	local IsSound = true

	if IsSelf then
		if self:IsInEnsembleWithAssistant() then
			if MusicPerformanceUtil.IsPerformanceSyncedWithParty() then
				IsMotion = false
				IsSound = false
				-- 策划说不还原这里端游的特效表现
				-- if not IsKeyOff then
				-- 	-- 延迟播放声音 但是播放特效 todo
				-- 	local EffectPath = MPDefines.SignEffectPath
				-- 	local FXParam = _G.UE.FActorFXParam()
				-- 	FXParam.AttachedComponent = ActorUtil.GetActorByEntityID(EntityID):GetMeshComponent()
				-- 	FXParam.FXPath = EffectPath
				-- 	FXParam.LODMethod = 2
				-- 	FXParam.LODLevel = EffectUtil.GetMajorEffectLOD()
				-- 	FXParam.SocketName = "head_M"
				-- 	-- FXParam.RelativeLocation = _G.UE.FVector(0, 0, ZOffset)
				-- 	EffectUtil.PlayEffect(FXParam)
				-- end
			end
		end
	else
		if self:IsInEnsembleWithAssistant() then
			if MusicPerformanceUtil.IsPerformanceSyncedWithParty() == false then
				-- 合奏时仅有只听自己 / 延迟播放队伍整体声音的选项
				-- 故延迟播放关闭时 不听任何非自己的声音
				IsSound = false
				if EntityID == MajorUtil.GetMajorEntityID() then
					-- 排除自己的动作
					IsMotion = false
				end
			end
		else
			if EntityID == MajorUtil.GetMajorEntityID() then
				IsMotion = false
				IsSound = false
			-- else
			-- 	if self:IsEnable(true) == true then
			-- 		if MusicPerformanceUtil.IsOtherPerformanceMuted() then
			-- 			-- 不听别人的声音
			-- 			IsSound = false
			-- 		end
			-- 	end
			end
		end
	end

	MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:PlayKey  IsMotion:%s,   IsSound:%s", IsMotion, IsSound))
	if IsMotion then
		Work:Play(EntityID, Key, IsKeyOff)
	end

	if IsSound then
		Sound:Play(EntityID, TimbreData, Key, IsKeyOff)
	end
end


function MusicPerformanceMgr:GetWork(EntityID)
	local CharacterBuffer = self.CharacterBuffer[EntityID]
	if CharacterBuffer == nil and ActorUtil.GetActorByEntityID(EntityID) then
		CharacterBuffer = MPCharacter.New()
		CharacterBuffer:Initialize(EntityID)
		self.CharacterBuffer[EntityID] = CharacterBuffer
	end
	return CharacterBuffer
end

function MusicPerformanceMgr:IsMoveing(EntityID)
	local Character = ActorUtil.GetActorByEntityID(EntityID)
	if Character and Character.CharacterMovement then
		local CharacterVec = Character.CharacterMovement.Velocity
		if CharacterVec then
			local INF = 0.000000001
			return CharacterVec:Size() >= INF
		end
	end
	return false
end

function MusicPerformanceMgr:FindBuffer(EntityID)
	for i = 0, MPDefines.PlayBufferMax - 1 do
		if self.PlayBuffer[i].EntityID == EntityID then
			return i
		end
	end

	return -1
end

function MusicPerformanceMgr:FindFreeBuffer()
	return self:FindBuffer(0)
end

function MusicPerformanceMgr.OnTick(DeltaTime)
	local _ <close> = CommonUtil.MakeProfileTag("MusicPerformanceMgr.OnTick")
	_G.MusicPerformanceMgr:Update(DeltaTime)
	_G.MusicPerformanceMgr:CheckPlayOverForEndTimeLine()
end

function MusicPerformanceMgr:Update(DeltaTime)
	do
		local _ <close> = CommonUtil.MakeProfileTag("MusicPerformanceMgr.OnTick_Sound")
		if self.Sound then
			self.Sound:Update(DeltaTime)
		end
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("MusicPerformanceMgr.OnTick_Character")
		self:UpdateCharacter(DeltaTime)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("MusicPerformanceMgr.OnTick_PlayList")
		self:UpdatePlayList(DeltaTime)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("MusicPerformanceMgr.OnTick_Request")
		self:UpdateRequest(DeltaTime)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("MusicPerformanceMgr.OnTick_Ensemble")
		self:UpdateEnsemble(DeltaTime)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("MusicPerformanceMgr.OnTick_AllMotion")
		self:UpdateAllMotion(DeltaTime)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("MusicPerformanceMgr.OnTick_Assistant")
		if self.Assistant then
			self.Assistant:Tick()
		end
	end
end

function MusicPerformanceMgr:UpdateRequest(DeltaTime)
	-- -- 长按演奏的限时
	-- if self.LimitTimer > 0 then
	-- 	self.LimitTimer = self.LimitTimer - DeltaTime

	-- 	if self.LimitTimer <= 0 then
	-- 		self.StopFlag = true
	-- 		self.LimitTimer = 0
	-- 	end
	-- end

	local HasNewState, HasLongClick = self:RefreshLongClickStates(DeltaTime)

	if not self:IsInEnsembleWithAssistant() then
		if DeltaTime > MPDefines.SendInterval then
			-- 由于有超过发送间隔的时间经过，演奏暂时中断（无法维持正常的演奏）
			self:AbortCommand()
			return
		end

		if self.ExecFlag == true then
			if self:GetMajorSound():IsPlay() == false then
				self.RestTimer = self.RestTimer + DeltaTime
			end

			if self.RestTimer >= MPDefines.RestLimit then
				self.PerformCommand:Clear()
				self.ExecFlag = false
			end
		end

		if self.ExecFlag == false and self.RequestCount == 0 and not HasLongClick then
			return
		end
		--print(self.ExecFlag, self.RequestCount, HasLongClick)
		self:UpdateCommand(self.PerformCommand, DeltaTime)
	else
		-- if DeltaTime > MPDefines.EnsembleInterval then
		-- 	self:AbortCommand()
		-- 	return
		-- end
		self:UpdateCommand(self.EnsembleCommand, DeltaTime)
	end
end

-- 端游采集方式
-- function MusicPerformanceMgr:UpdateCommand(CommandBuffer, DeltaTime)
-- 	local Key = -1
-- 	local Timbre = 0

-- 	self.PlayTimer = self.PlayTimer - DeltaTime

-- 	while self.PlayTimer <= 0 do
-- 		Timbre = 0
-- 		if self.RequestCount == 0 and self.StopFlag == false then
-- 			CommandBuffer:Add(MPDefines.Command.COMMAND_ID_REST)
-- 		else
-- 			local Command = MPDefines.Command.COMMAND_ID_KEY_OFF
-- 			if self.RequestCount > 0 then
-- 				local RequestWork = self.RequestWorks[self.RequestIndex]
-- 				Command = RequestWork.Key
-- 				Timbre = RequestWork.Timbre
-- 				Key = Command

-- 				self.RequestIndex = (self.RequestIndex + 1) % MPDefines.RequestMax
-- 				self.RequestCount = self.RequestCount - 1
-- 			else
-- 				Key = MPDefines.KeyOff

-- 				self.StopFlag = false
-- 			end

-- 			CommandBuffer:Add(Command, Timbre)
-- 		end

-- 		if CommandBuffer:CanSendImp() then
-- 			CommandBuffer:SendImp()
-- 		end

-- 		self.PlayTimer = self.PlayTimer + MPDefines.PlayInterval
-- 	end

-- 	if Key >= 0 then
-- 		local Major = MajorUtil.GetMajor()
-- 		if Major then
-- 			self:PlayKey(MajorUtil.GetMajorEntityID(), self.Sound, Key, Timbre, true)
-- 		end

-- 		self.RestTimer = 0
-- 		if Key == MPDefines.KeyOff then
-- 			self.LimitTimer = MPDefines.PlayLimit
-- 		else
-- 			self.LimitTimer = 0
-- 		end
-- 	end

-- 	self.ExecFlag = true
-- end

function MusicPerformanceMgr:UpdateCommand(CommandBuffer, DeltaTime)
	local IndexChanged = CommandBuffer:UpdateIndex(DeltaTime)

	if IndexChanged then
		if CommandBuffer:CanSendImp() then
			CommandBuffer:SendImp()
		end

		-- 添加Key
		local Major = MajorUtil.GetMajor()
		while self.RequestCount > 0 do
			local RequestWork = self.RequestWorks[self.RequestIndex]
			local Command = RequestWork.Key
			local Timbre = RequestWork.Timbre

			self.RequestIndex = (self.RequestIndex + 1) % MPDefines.RequestMax
			self.RequestCount = self.RequestCount - 1
			CommandBuffer:Add(Command, Timbre)

			if Command >= 0 then
				if Major then
					self:PlayKey(MajorUtil.GetMajorEntityID(), self:GetMajorSound(), Command, Timbre, true, false)
				end
		
				self.RestTimer = 0
			end
		end

		local NewMap = {}
		-- 添加长按状态
		for ClickKey, LongClickState in pairs(self.LongClickStates) do
			-- 同帧抬起释放，保证触发
			if LongClickState.IsReleaseAtSameFrame then
				LongClickState.IsPress = true
			end

			-- 这里的KeyOff用于上报 MPDefines.KeyOff用于清除
			local Command = CommandBuffer:AddLongPress(ClickKey, LongClickState.Timbre, not LongClickState.IsPress, LongClickState.IsNewState)
			MusicPerformanceUtil.Log(string.format("AddLongPress Command:%s", tostring(Command)))
			if Command then
				local Timbre = LongClickState.Timbre
				LongClickState.IsNewState = false

				if Command >= 0 then
					if Major then
						self:PlayKey(MajorUtil.GetMajorEntityID(), self:GetMajorSound(), ClickKey, Timbre, true, Command == MPDefines.KeyOff)
					end
				
					self.RestTimer = 0
				end
			end
				
			if LongClickState.IsPress then
				NewMap[ClickKey] = LongClickState
			end

			-- 同帧抬起释放，还原参数，让下一帧能正确释放
			if LongClickState.IsReleaseAtSameFrame then
				MusicPerformanceUtil.Log("Long click release same frame")
				LongClickState.IsReleaseAtSameFrame = nil
				LongClickState.IsPress = false
				LongClickState.IsNewState = true
			end
		end

		-- 移除不被按压的按键
		self.LongClickStates = NewMap
	end

	self.ExecFlag = true
end

function MusicPerformanceMgr:UpdatePlayList(DeltaTime)
	for i = 0, MPDefines.PlayBufferMax - 1 do
		self:UpdatePlayCommand(self.PlayBuffer[i], DeltaTime)
	end
end

function MusicPerformanceMgr:GetKeySet(EntityID)
	local Work = self:GetWork(EntityID)
	if Work then
		return Work.KeySet
	end
	return nil
end

-- Update 其他玩家的Command
function MusicPerformanceMgr:UpdatePlayCommand(Buf, DeltaTime)
	local EntityID = Buf.EntityID
	if EntityID == 0 or EntityID == nil then
		return false
	end

	local Chara = ActorUtil.GetActorByEntityID(EntityID)
	if Chara == nil then
		-- 角色离开视野后清空数据
		Buf:Clear()
		return false
	end

	Buf.Sound:Update(DeltaTime)
	if Buf.Status == MPDefines.PlayBufferStatus.STS_WAIT then
		Buf.Timer = Buf.Timer + DeltaTime
		-- if Buf.Timer < MPDefines.BufferingTime then
		-- 	return true
		-- end

		-- 改为与时间无关，与缓存帧数量相关
		if Buf.Count < MPDefines.BufferingCount then
			return true
		end

		Buf.Timer = 0
		Buf.Status = MPDefines.PlayBufferStatus.STS_PLAY

	elseif Buf.Status == MPDefines.PlayBufferStatus.STS_PLAY then
		Buf.Timer = Buf.Timer - DeltaTime
	elseif Buf.Status == MPDefines.PlayBufferStatus.STS_RELEASE then
		-- if Buf.IsKeyOff == true then
		-- 	self:PlayKey(EntityID, Buf.Sound, MPDefines.KeyOff, 0, false, true)
		-- 	Buf.IsKeyOff = false
		-- end

		Buf.Timer = Buf.Timer + DeltaTime
		if Buf.Timer >= MPDefines.ReleaseTime then
			Buf:Clear()

			local Work = self:GetWork(EntityID)
			if Work then
				Work:Play(EntityID, MPDefines.KeyOff, true)
			end

			return false
		end
		return true
	end

	if Buf.Count == 0 then
		Buf:Clear()
		return false
	end

	while Buf.Timer <= 0 do
		local CommandBuffer = Buf:GetCommandBufferImp()
		local FrameCommand, FrameCommandIndex = CommandBuffer:GetCommandImp()

		-- 由于要做断线重连机制，在第一帧Frame内会包含其所有按下的键
		-- 所以第一帧没有包含但是本地逻辑上是按下的键要进行抬起
		local IsFirstFrame = FrameCommandIndex == 0
		local PressedKeySet = IsFirstFrame and {} or nil	-- 只在FrameCommandIndex为0时移除多余的键

		for i = 1, (FrameCommand and FrameCommand:GetCount() or 0) do
			local Command, Timbre, IsKeyOff = FrameCommand:GetCommand(i)
			
			self:PlayKey(EntityID, Buf.Sound, Command, Timbre, false, IsKeyOff)

			if IsFirstFrame then
				PressedKeySet[Command] = true
			end
		end

		if PressedKeySet then
			local KeySet = table.deepcopy(self:GetKeySet(EntityID))
			if KeySet then
				for Key, State in pairs(KeySet) do
					-- 对没有按下的键执行KeyOff
					if not PressedKeySet[Key] and State then
						self:PlayKey(EntityID, Buf.Sound, Key, 0, false, true)
					end
				end
			end
		end

		Buf.Timer = Buf.Timer + MPDefines.PlayInterval

		-- 没有后续包了 准备释放
		if CommandBuffer:Next() == true then
			if Buf:Next() == false then
				Buf.Timer = 0
				Buf.Status = MPDefines.PlayBufferStatus.STS_RELEASE
				break
			end
		end
	end

	return true
end

function MusicPerformanceMgr:Start(EntityID, PerformDataID)
	MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:Start EntityID : %d PerformDataID : %d", EntityID, PerformDataID))
	self.PrepareTimer = 0

	local Work = self:GetWork(EntityID)
	if Work == nil then
		return
	end

	Work:Start(EntityID, PerformDataID)
	_G.EventMgr:SendEvent(EventID.MusicPerformanceEntityStart, EntityID)

	if EntityID == MajorUtil.GetMajorEntityID() then
		self.ModeFlag = true
		CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatPerform, true)

		self.Timbre = Work:GetTimbre()
	end
end

function MusicPerformanceMgr:Exit(EntityID)
	self.PrepareTimer = 0

	local Work = self:GetWork(EntityID)
	if Work == nil then
		return
	end

	if Work:IsValid() then
		local TimbreData = Work:End(EntityID)
		self.CharacterEndAnimData[EntityID] = TimbreData.EndTimeline
		_G.EventMgr:SendEvent(EventID.MusicPerformanceEntityEnd, EntityID)

		--正在移动中，则停止退出演奏动作；否则延迟清理等退出演奏时的动作播放完毕
		if self:IsMoveing(EntityID) then
			Work:StopMotion(EntityID, TimbreData.EndTimeline)
			self.CharacterEndAnimData[EntityID] = nil
		end
	end

	if EntityID == MajorUtil.GetMajorEntityID() then
		self:AbortPerform()
	end
end

--当角色每次从静止到移动时触发
function MusicPerformanceMgr:MajorFirstMove(EntityID)
	local EntityID = MajorUtil.GetMajorEntityID()
	local TimeLine = self.CharacterEndAnimData[EntityID]
	if TimeLine == nil then
		return
	end

	local Work = self:GetWork(EntityID)
	if Work ~= nil and Work:IsPlayingTimeline(EntityID, TimeLine) then
		Work:StopMotion(EntityID, TimeLine)
		self.CharacterEndAnimData[EntityID] = nil
	else
		self.CharacterEndAnimData[EntityID] = nil
	end
end

--清理数据-检测退出演奏时的动作是否播放完毕
function MusicPerformanceMgr:CheckPlayOverForEndTimeLine()
	for EntityID, value in pairs(self.CharacterEndAnimData) do
		local TimeLine = self.CharacterEndAnimData[EntityID]
		local Work = self:GetWork(EntityID)
		if Work ~= nil and TimeLine ~= nil  then
			if not Work:IsPlayingTimeline(EntityID, TimeLine) then
				self.CharacterEndAnimData[EntityID] = nil
			end
		end
	end
end

function MusicPerformanceMgr:UpdateAllMotion(DeltaTime)
	for k, Work in pairs(self.CharacterBuffer) do
		self:UpdateMotion(DeltaTime, Work)
	end
end

function MusicPerformanceMgr:UpdateMotion(DeltaTime, Work)
	if Work == nil then
		return
	end

	local EntityID = Work.Index

	Work:UpdateMotion(DeltaTime, EntityID)
end

function MusicPerformanceMgr:UpdateCharacter(DeltaTime)
	if self.ModeFlag == true then
		if self.ReadyFlag == false then
			if self:IsReadyTimeline() == true then
				self.ReadyFlag = true
			end
		end
	end

	
	-- todo 让主角异步加载timeline
	local InvalidWorks = nil
	for Key, Work in pairs(self.CharacterBuffer) do
		if ActorUtil.GetActorByEntityID(Key) ~= nil then
			Work:Update(DeltaTime, self.ReadyFlag)
		else
			InvalidWorks = InvalidWorks or {}
			table.insert(InvalidWorks, Key)
		end
	end

	-- 释放已经离开视野的角色信息
	if InvalidWorks then
		for _, Value in ipairs(InvalidWorks) do
			self.CharacterBuffer[Value] = nil
		end
	end
end

function MusicPerformanceMgr:IsReadyTimeline()
	return true
end

function MusicPerformanceMgr:StartEnsemble()
	if self:IsEnable(true) == false then
		return
	end

	self:AbortCommand()

	self.EnsembleBuffer:Clear()
	self.EnsembleCommand:Clear()
	-- 保持采样时间同步
	self.EnsembleCommand.Timer = (_G.MusicPerformanceVM.BeginTimeMS - TimeUtil.GetServerTimeMS()) / 1000
	MusicPerformanceUtil.Log(string.format("MusicPerformanceMgr:StartEnsemble" .. " Timer : " .. tostring(self.EnsembleBuffer.Timer)))
	self.EnsembleFlag = true

	-- Notify Start Ensemble
	local EventParams = _G.EventMgr:GetEventParams()

	_G.EventMgr:SendEvent(EventID.MusicPerformanceStartEnsemble, EventParams)
	_G.EventMgr:SendCppEvent(EventID.MusicPerformanceStartEnsemble, EventParams)
end

--退出演奏模式
--@param IsSwitchSelectPanel 是否切换到乐器选择界面
function MusicPerformanceMgr:ReqAbortPerform(IsSwitchSelectPanel)
	self.IsSwitchSelectPanel = IsSwitchSelectPanel and IsSwitchSelectPanel or false
	FLOG_INFO("MusicPerformance ReqAbortPerform")
	local MsgID = CS_CMD.CS_CMD_PERFORM
	local SubMsgID = PERFORM_CMD.PerformCmdExit
	local MsgBody = {
		Cmd = SubMsgID
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MusicPerformanceMgr:AbortEnsemble()
	FLOG_INFO("MusicPerformance Ensemble: AbortEnsemble")
	self:AbortCommand()

	if self.EnsembleBuffer:IsUse() == true then
		for i = 0, MPDefines.EnsembleMemberMax - 1 do
			local Buf = self.EnsembleBuffer[i]
			if Buf ~= nil then
				local EntityID = Buf.EntityID

				if EntityID ~= 0 then
					local Work = self:GetWork(EntityID)
					if Work then
						Work:Play(EntityID, MPDefines.KeyOff, true)
					end
				end
			end
		end

		self.EnsembleBuffer:Clear()
	end

	if self.EnsembleFlag then
		self.EnsembleFlag = false
		self.EnsemblePartyID = 0

		-- Notify Abort Ensemble
		local EventParams = _G.EventMgr:GetEventParams()

		_G.EventMgr:SendEvent(EventID.MusicPerformanceAbortEnsemble, EventParams)
		_G.EventMgr:SendCppEvent(EventID.MusicPerformanceAbortEnsemble, EventParams)
		_G.MusicPerformanceVM.Status = ProtoCS.EnsembleStatus.EnsembleStatusPerform
	end
end

--退出合奏
function MusicPerformanceMgr:ReqAbortEnsemble()
	FLOG_INFO("MusicPerformance ReqAbortEnsemble, EnsembleFlag=%s",  (self.EnsembleFlag and "true" or "false"))
	if self.EnsembleFlag == false then
		return
	end

	-- Send Abort Ensemble to Server
	local MsgID = CS_CMD.CS_CMD_PERFORM
	local SubMsgID = PERFORM_CMD.EnsembleCmdExit
	local MsgBody = {
		Cmd = SubMsgID
	}
	
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MusicPerformanceMgr:Receive(EnsembleData)
	local PartyID = MusicPerformanceUtil.GetPartyID(EnsembleData)
	if self:IsInEnsembleWithAssistant() then
		-- 合奏中只处理自己的数据包
		if self.EnsemblePartyID ~= PartyID then
			MusicPerformanceUtil.Log("MusicPerformanceMgr:Receive not mine")
			return
		end
	else
		if not MusicPerformanceUtil.IsInPerformRange(MajorUtil.GetMajorEntityID(), PartyID) then
			return
		end
	end

	if self.EnsembleBuffer:IsUse() == false then
		self.EnsembleBuffer:InitializeByData(EnsembleData)
	else
		if self.EnsembleBuffer:GetPartyID() ~= PartyID then
			MusicPerformanceUtil.Log("MusicPerformanceMgr:Receive not mine")
			-- 同时刻只能有一组合奏
			return
		end

		for i = 1, MPDefines.EnsembleMemberMax do
			local Command = EnsembleData.Ensemble[i]

			if Command and (Command.EntityID == 0 or ActorUtil.GetActorByEntityID(Command.EntityID) == nil) then
			elseif Command then
				self.EnsembleBuffer:Set(Command)
			end
		end
	end
end

function MusicPerformanceMgr:UpdateEnsemble(DeltaTime)
	if self.EnsembleBuffer:IsUse() == false then
		return
	end

	local IsExec = false

	for i = 0, MPDefines.EnsembleMemberMax - 1 do
		if self:UpdatePlayCommand(self.EnsembleBuffer:GetPlayBuffer(i), DeltaTime) == true then
			IsExec = true
		end
	end

	if IsExec == false then
		self.EnsembleBuffer:Clear()
	end
end

function MusicPerformanceMgr:InitRedDotData()
	local Cfgs = PerformAssistantCfg:FindAllCfg("ID > 0")
	for _, Cfg in pairs(Cfgs) do
		local RedDotName = string.format("Root/Performance/%s", Cfg.Name)
		--RedDotMgr:CleanSaveShowRedDot(RedDotName)
		local IsDel =  RedDotMgr:GetIsSaveDelRedDotByName(RedDotName);
		if not IsDel then
			RedDotMgr:AddRedDotByName(RedDotName, nil, true);
		end
	end
end

function MusicPerformanceMgr:CanPerformance()
	local ErrMsg = self:CheckState()
	if not string.isnilorempty(ErrMsg) then
		-- _G.UIViewMgr:HideView(self.ViewID, true)
		_G.MsgTipsUtil.ShowTips(ErrMsg)
		return false
	end
	-- 要选勾选协议
	if not self:CheckProtocol() then
		-- _G.UIViewMgr:HideView(self.ViewID, true)
		_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceProtocolView)
		return false
	end
	-- 再检查职业
	if not self:CheckProf() then
		-- _G.UIViewMgr:HideView(self.ViewID, true)
		return false
	end
	return true
end

function MusicPerformanceMgr:CheckState()
	local StateCom = MajorUtil.GetMajorStateComponent()
	if StateCom == nil then
		return _G.LSTR(830117)
	end

	if StateCom:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_DEAD) then
		return _G.LSTR(830115)
	end

	if StateCom:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT) then
		return _G.LSTR(830113)
	end

	local RideCom = MajorUtil.GetMajor():GetRideComponent()
	if RideCom and RideCom:IsInRide() then
		return _G.LSTR(830125)
	end

	if _G.PWorldMgr:CurrIsInDungeon() then
		return _G.LSTR(830122)
	end
end

function MusicPerformanceMgr:CheckProtocol()
	local IsArgee = _G.ClientSetupMgr:GetSetupValue(MajorUtil.GetMajorRoleID(), ProtoCS.ClientSetupKey.CSKPerformAgreement) == MPDefines.AgreeProtocolValue
	return IsArgee
end

function MusicPerformanceMgr:CheckProf()
	local ProfID = MajorUtil.GetMajorProfID()
	if ProfID ~= ProtoCommon.prof_type.PROF_TYPE_BARD then
		local Select = _G.UE.USaveMgr.GetInt(SaveKey.PerformanceProfChangeTipSelect, 0, true)
		if Select == 0 then
			local ProfLevel = MajorUtil.GetMajorLevelByProf(ProtoCommon.prof_type.PROF_TYPE_BARD)
			if ProfLevel == nil then
				_G.MsgTipsUtil.ShowTips(_G.LSTR(830120))
			else
				-- 进行提示
				MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(830107), _G.LSTR(830112),
				function(_, Params)
					local IsNeverAgain = Params.IsNeverAgain
					if IsNeverAgain then
						-- 默认转换职业
						_G.UE.USaveMgr.SetInt(SaveKey.PerformanceProfChangeTipSelect, 1, true)
					end
					
					self:TrySwitchProf()
				end,
				function(_, Params)
				end,
				_G.LSTR(830014), _G.LSTR(830038),
				{
					bUseNever = true,	-- 不再提醒
					TipsText =  string.format("%s %s",
						RichTextUtil.GetTexture("Texture2D'/Game/Assets/Icon/Profe/Career/UI_Icon_Career_Main_YYSR.UI_Icon_Career_Main_YYSR'", 54, 54, -18),
						RichTextUtil.GetText(string.format(" %d  %s", ProfLevel, _G.LSTR(830110)), "FFFFFF")),
					FontSize = 23,
					NeverMindText = _G.LSTR(830007)
				})
			end
		elseif Select == 1 then
			_G.MsgTipsUtil.ShowTips(_G.LSTR(830121))
			self:TrySwitchProf()
		end
		return false
	end
	return true
end

-- 进行转职
function MusicPerformanceMgr:TrySwitchProf()
	if _G.ProfMgr:CanChangeProf(ProtoCommon.prof_type.PROF_TYPE_BARD) then
		_G.ProfMgr:SwitchProfByID(ProtoCommon.prof_type.PROF_TYPE_BARD, nil, ProfDefine.ProfSwitchReason.MusicPerformance)
	end
end

--主角受到攻击关闭演奏系统的所有界面
function MusicPerformanceMgr:OnGameEventAttackEffectChange(Params)
	local BehitObjID = Params.BehitObjID
	-- local AttackObjID = Params.AttackObjID
	-- local EffectType = Params.EffectType or 0
	if not MajorUtil.IsMajor(BehitObjID) then
		return
	end
	--判断是否进入战斗状态
	if not MajorUtil.IsMajorCombat() then
		return
	end
	

	--防止反复进入
	if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceSelectPanelView) and 
	not _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceMainPanelView) then
		return
	end

	self:CancelEnsembleCmdConfirm()
	self:GetAssistantInst():Stop()
	self:ReqAbortEnsemble()
	self:ReqAbortPerform()
	_G.MsgTipsUtil.ShowTipsByID(168013)

	self:CloseAllPerformancePanel()
end

function MusicPerformanceMgr:CloseAllPerformancePanel()
	--先处理子面板的
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPefromanceSongPanelView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPefromanceSongPanelView)
	elseif _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPefromanceSongDetailPanelView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPefromanceSongDetailPanelView)
	elseif _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceMetronomeSettingView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceMetronomeSettingView)
	elseif _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceSettingView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceSettingView)
	elseif _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceProtocolView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceProtocolView)
	elseif _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceEnsembleMetronmeView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceEnsembleMetronmeView)
	elseif _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceEnsembleConfirmView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceEnsembleConfirmView)
	end

	--处理合奏过程中有关的界面
	if _G.MusicPerformanceVM.Status == ProtoCS.EnsembleStatus.EnsembleStatusEnsemble or 
	_G.MusicPerformanceVM.Status == ProtoCS.EnsembleStatus.EnsembleStatusResult then
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.PerformanceAssistantPanelView) then
			_G.UIViewMgr:HideView(_G.UIViewID.PerformanceAssistantPanelView)
		end
	else
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.PerformanceAssistantPauseWinView) then
			_G.UIViewMgr:HideView(_G.UIViewID.PerformanceAssistantPauseWinView)
		end

		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.PerformanceAssistantPanelView) then
			_G.UIViewMgr:HideView(_G.UIViewID.PerformanceAssistantPanelView)
		end
	end

	--选择乐曲界面
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceSelectPanelView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceSelectPanelView)
	end
	
	--主界面
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MusicPerformanceMainPanelView) then
		_G.UIViewMgr:HideView(_G.UIViewID.MusicPerformanceMainPanelView)
	end
end

--GM开启合奏
function MusicPerformanceMgr:GMOpenEnsemble()
	self.bOpenEnsembleGM = not self.bOpenEnsembleGM
end

--GM是否开启演奏调试日志
function MusicPerformanceMgr:GMOpenMusicPerformanceDebug(Val)
	MPDefines.DEBUG = Val
end

return MusicPerformanceMgr
