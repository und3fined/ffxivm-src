
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local PVPDuelVM = require("Game/PVP/Duel/VM/PVPDuelVM")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")

local ProfUtil = require("Game/Profession/ProfUtil")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

local PVP_COLOSSEUM_CMD = ProtoCS.Game.PvPColosseum.CS_PVPCOLOSSEUM_CMD
local SidebarType = SidebarDefine.SidebarType.PVPDuel
local CS_CMD = ProtoCS.CS_CMD

local GameNetworkMgr = nil
local EventMgr = nil
local PWorldMgr = nil
local ProfMgr = nil
local SidebarMgr = nil
local RoleInfoMgr = nil
local UIViewMgr = nil
local ModuleOpenMgr = nil
local LSTR = nil
local FLOG_ERROR = nil
local FLOG_INFO = nil

local StartCountDownAudio = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_countdown_1.Play_UI_countdown_1'"

local WolvesDenPierMgr = LuaClass(MgrBase)

function WolvesDenPierMgr:OnInit()
	self:ResetData()
end

function WolvesDenPierMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    EventMgr = _G.EventMgr
    PWorldMgr = _G.PWorldMgr
    UIViewMgr = _G.UIViewMgr
	SidebarMgr = _G.SidebarMgr
	ProfMgr = _G.ProfMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
	RoleInfoMgr = _G.RoleInfoMgr
    LSTR = _G.LSTR
    FLOG_ERROR = _G.FLOG_ERROR
    FLOG_INFO = _G.FLOG_INFO
end

function WolvesDenPierMgr:OnEnd()
    GameNetworkMgr = nil
    EventMgr = nil
    PWorldMgr = nil
	SidebarMgr = nil
	ProfMgr = nil
    UIViewMgr = nil
	RoleInfoMgr = nil
    ModuleOpenMgr = nil
    LSTR = nil
    FLOG_ERROR = nil
    FLOG_INFO = nil
end

function WolvesDenPierMgr:OnShutdown()
	self:ResetData()
end

function WolvesDenPierMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnPWorldMapExit)
	self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnSidebarItemTimeOut) -- 侧边栏超时
    self:RegisterGameEvent(EventID.ChaneNameNotify, self.OnChangeNameNotify) -- 改名通知
	self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfSwitch)	-- 主角职业变更
	self:RegisterGameEvent(EventID.OtherCharacterSwitch, self.OnOtherCharacterSwitch)	-- 其他玩家职业变更

end

function WolvesDenPierMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.INVITE_DUEL, self.OnNetRspInviteDuel)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.CANCLE_DUEL, self.OnNetRspCancelDuel)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.ACCEPT_DUEL, self.OnNetRspAcceptDuel)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.INVITE_NTF_TGT_DUEL, self.OnNetNtyInviteDuel)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.ACCEPT_NTF_TGT_DUEL, self.OnNetNtyAcceptDuel)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.DUEL_BEGIN_COUNTDOWN_NTF, self.OnNetNtyDuelBeginCountDown)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.DUEL_RESULT, self.OnNetNtyDuelResult)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, PVP_COLOSSEUM_CMD.GET_DUEL_INFO, self.OnNetRspGetDuelInfo)
end

-- region GameEvent

function WolvesDenPierMgr:OnPWorldMapExit()
	self:ClearDuelData()
end

function WolvesDenPierMgr:OnPWorldReady()
	if PWorldMgr:CurrIsWolvesDenPierStage() then
		self:CheckShowTips()
		self:GetDuelInfo(MajorUtil.GetMajorRoleID())
	end
end

function WolvesDenPierMgr:OnSidebarItemTimeOut(Type)
	if SidebarType ~= Type then return end

	self:OnInviteTimeout()

	EventMgr:SendEvent(EventID.PVPDuelInviteTimeout, { InviterID = PVPDuelVM:GetInviterID(), TargetID = PVPDuelVM:GetTargetID() })
end

function WolvesDenPierMgr:OnChangeNameNotify(RoleID, EntityID, Name)
	if RoleID == nil then return end

	if PVPDuelVM:GetInviterID() == RoleID then
		local RoleVM = PVPDuelVM:GetInviter()
		RoleVM.Name = Name
		return
	end

	if PVPDuelVM:GetTargetID() == RoleID then
		local RoleVM = PVPDuelVM:GetTarget()
		RoleVM.Name = Name
		return
	end
end

function WolvesDenPierMgr:OnMajorProfSwitch(Params)
	if Params == nil then return end

	local NewProf = Params.ProfID
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if PVPDuelVM:GetInviterID() == MajorRoleID then
		local RoleVM = PVPDuelVM:GetInviter()
		RoleVM.ProfID = NewProf
		return
	end

	if PVPDuelVM:GetTargetID() == MajorRoleID then
		local RoleVM = PVPDuelVM:GetTarget()
		RoleVM.ProfID = NewProf
		return
	end
end

function WolvesDenPierMgr:OnOtherCharacterSwitch(Params)
	if Params == nil then return end

	local EntityID = Params.ULongParam1
	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	local NewProf = Params.IntParam1
	if PVPDuelVM:GetInviterID() == RoleID then
		local RoleVM = PVPDuelVM:GetInviter()
		RoleVM.ProfID = NewProf
		return
	end

	if PVPDuelVM:GetTargetID() == RoleID then
		local RoleVM = PVPDuelVM:GetTarget()
		RoleVM.ProfID = NewProf
		return
	end
end

-- endregion GameEvent

-- region NetMsgReq

--- 请求决斗
function WolvesDenPierMgr:InviteDuel(TargetID)
	if TargetID == nil or TargetID == 0 then
		FLOG_ERROR("[WolvesDenPierMgr][InviteDuel]Invalid target")
		return
	end

	if not self:CheckCanDuel(TargetID) then return end

	local PvPColosseumInviteDuelReq = {
		TgtID = TargetID
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.INVITE_DUEL, "InviteDuelReq", PvPColosseumInviteDuelReq)
end

--- 取消决斗
function WolvesDenPierMgr:CancelDuel(TargetID)
	if TargetID == nil or TargetID == 0 then
		FLOG_ERROR("[WolvesDenPierMgr][CancelDuel]Invalid target")
		return
	end
	
	local PvPColosseumCancleDuelReq = {
		TgtID = TargetID
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.CANCLE_DUEL, "CancleDuelReq", PvPColosseumCancleDuelReq)
end

--- 回应决斗
function WolvesDenPierMgr:ReplyDuel(InviterID, IsAccept)
	if InviterID == nil or InviterID == 0 then
		FLOG_ERROR("[WolvesDenPierMgr][ReplyDuel]Invalid inviter")
		return
	end
	if IsAccept == nil then
		FLOG_ERROR("[WolvesDenPierMgr][ReplyDuel]Invalid isAccept")
		return
	end
	
	if not self:CheckCanDuel(InviterID) then return end


	local PvPColosseumAcceptDuelReq = {
		InviterID = InviterID,
		IsAccept = IsAccept
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.ACCEPT_DUEL, "AcceptDuelReq", PvPColosseumAcceptDuelReq)
end

--- 获取决斗邀请信息
---@param RoleID uint64 角色ID
function WolvesDenPierMgr:GetDuelInfo(RoleID)
	local PvPColosseumGetDuelInfoReq = {
		RoleID = RoleID
	}
	self:SendPVPNetMsg(PVP_COLOSSEUM_CMD.GET_DUEL_INFO, "PvPColosseumGetDuelInfoReq", PvPColosseumGetDuelInfoReq)
end

function WolvesDenPierMgr:SendPVPNetMsg(SubMsgID, DataKey, Data)
	local CsReq = {
		Cmd = SubMsgID
	}

    if DataKey ~= nil then
        CsReq[DataKey] = Data
    end

	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PvPColosseum, SubMsgID, CsReq)
end

-- endregion NetMsgReq

-- region NetMsgRes

function WolvesDenPierMgr:OnNetRspInviteDuel(MsgBody)
	if MsgBody == nil then return end
	local Rsp = MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	local EndTime = self:GetInviteTimeoutTime() + Rsp.InviteTime / 1000
	if EndTime > TimeUtil.GetServerLogicTime() then
		PVPDuelVM:SetInviteData(Rsp)
		self:AddCountDownTimer()
		self:ShowDuelPanel()
	end
end

function WolvesDenPierMgr:OnNetRspCancelDuel(MsgBody)
	if MsgBody == nil then return end
	local Rsp = MsgBody[MsgBody.Data]
	if Rsp then
		-- 发起人取消时双方都会收到回包，需要按角色ID决定逻辑
		local MajorRoleID = MajorUtil.GetMajorRoleID()
		if MajorRoleID == Rsp.InviteID then
			MsgTipsUtil.ShowTips(LSTR(1330006))
		elseif MajorRoleID == Rsp.BeInvitedID then
			RoleInfoMgr:QueryRoleSimple(Rsp.InviteID, function(Params, RoleVM)
				if RoleVM then
					local Text = string.format(LSTR(1330007), RoleVM.Name)
					MsgTipsUtil.ShowTips(Text)
				end
			end, nil, false)
		end
	end
	self:ClearDuelData()
end

function WolvesDenPierMgr:OnNetRspAcceptDuel(MsgBody)
	if MsgBody == nil then return end
	local Rsp = MsgBody[MsgBody.Data]
	if Rsp then
		-- 接受/拒绝双方都会收到回包，需要按角色ID决定逻辑
		local MajorRoleID = MajorUtil.GetMajorRoleID()
		if Rsp.IsAccept then
			MsgTipsUtil.ShowTips(LSTR(1330020))
		else
			if Rsp.InviterID == MajorRoleID then
				RoleInfoMgr:QueryRoleSimple(Rsp.TgtID, function(Params, RoleVM)
					if RoleVM then
						local Text = string.format(LSTR(1330018), RoleVM.Name)
						MsgTipsUtil.ShowTips(Text)
					end
				end, nil, false)
			elseif Rsp.TgtID == MajorRoleID then
				MsgTipsUtil.ShowTips(LSTR(1330017))
			end
		end
	end
	self:ClearDuelData()
end

function WolvesDenPierMgr:OnNetNtyInviteDuel(MsgBody)
	if MsgBody == nil then return end
	local Rsp = MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if MajorRoleID == Rsp.TgtRoleID then
		local EndTime = self:GetInviteTimeoutTime() + Rsp.InviteTime / 1000
		if EndTime > TimeUtil.GetServerLogicTime() then
			PVPDuelVM:SetReceiveInviteData(Rsp)
			self:AddCountDownTimer()
			self:TryAddSidebarItem()
		end
	end
end

function WolvesDenPierMgr:OnNetNtyAcceptDuel(MsgBody)
	if MsgBody == nil then return end
	local Rsp = MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	local Params = {}
	Params.FadeColorType = 1
	Params.Duration = 1
	Params.bAutoHide = true
	UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)

	EventMgr:SendEvent(EventID.PVPDuelAccept, { InviterID = Rsp.RoleID, TargetID = Rsp.TgtRoleID })
end

function WolvesDenPierMgr:OnNetNtyDuelBeginCountDown(MsgBody)
	if MsgBody == nil then return end
	local Rsp = MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	local CoundDownEndTime = Rsp.EndTime
	local ServerTimeMs = TimeUtil.GetServerLogicTimeMS()
	local RemainCountDownTime = (CoundDownEndTime - ServerTimeMs) / 1000
	self:ShowStartCountDown(RemainCountDownTime)
end

function WolvesDenPierMgr:OnNetNtyDuelResult(MsgBody)
	if MsgBody == nil then return end
	local Rsp = MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	-- 如果还在倒计时有一方退出了，直接停止计时并显示结果
	local IsViewVisible = UIViewMgr:IsViewVisible(UIViewID.InfoCountdownTipsView)
	if IsViewVisible then
		UIViewMgr:HideView(UIViewID.InfoCountdownTipsView)
	end

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local TipsID = nil
	local IsWin = Rsp.WinnerID == MajorRoleID
	if IsWin then
		TipsID = 338007 -- 胜利
	else
		TipsID = 338008 -- 失败
	end

	if TipsID then
		MsgTipsUtil.ShowTipsByID(TipsID)
	end
end

function WolvesDenPierMgr:OnNetRspGetDuelInfo(MsgBody)
	if MsgBody == nil then return end
	local Rsp = MsgBody[MsgBody.Data]
	if Rsp == nil then return end

	-- 先清空原有数据再处理数据
	self:ClearDuelData()

	local InviteData = Rsp.Invite
	if InviteData then
		if InviteData.RoleID and InviteData.RoleID > 0 then
			local EndTime = self:GetInviteTimeoutTime() + InviteData.Time / 1000
			if EndTime - TimeUtil.GetServerLogicTime() > 1 then
				local Data = {
					TgtID = InviteData.RoleID,
					InviteTime = InviteData.Time
				}
				PVPDuelVM:SetInviteData(Data)
				self:AddCountDownTimer()
				self:ShowDuelPanel()
				return
			end
		end
	end

	local ReceiveInviteData = Rsp.Invited
	if ReceiveInviteData then
		if ReceiveInviteData.RoleID and ReceiveInviteData.RoleID > 0 then
			local EndTime = self:GetInviteTimeoutTime() + ReceiveInviteData.Time / 1000
			if EndTime - TimeUtil.GetServerLogicTime() > 1 then
				local Data = {
					RoleID = ReceiveInviteData.RoleID,
					InviteTime = ReceiveInviteData.Time
				}
				PVPDuelVM:SetReceiveInviteData(Data)
				self:AddCountDownTimer()
				self:TryAddSidebarItem()
				return
			end
		end
	end
end

-- endregion NetMsgRes

-- region Private Function

---@private
---清理Mgr数据
function WolvesDenPierMgr:ResetData()
	self.TimerID = nil
	self.InviteTimeoutTime = nil
end

---@private
function WolvesDenPierMgr:OnInviteTimeout()
	-- 超时提示
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if MajorRoleID == PVPDuelVM:GetInviterID() then
		RoleInfoMgr:QueryRoleSimple(PVPDuelVM:GetTargetID(), function(Params, RoleVM)
			if RoleVM then
				local Text = string.format(LSTR(1330018), RoleVM.Name)
				MsgTipsUtil.ShowTips(Text)
			end
		end, nil, false)
	elseif MajorRoleID == PVPDuelVM:GetTargetID() then
		MsgTipsUtil.ShowTips(LSTR(1330017))
	end

	-- 清理数据
	self:ClearDuelData()
end

---@private
---清理决斗数据
function WolvesDenPierMgr:ClearDuelData()
	self:HideDuelPanel()
	self:RemoveCountDownTimer()
	PVPDuelVM:ResetData()
	SidebarMgr:RemoveSidebarAllItem(SidebarType)
end

---@private
function WolvesDenPierMgr:CheckShowTips()
	local Text = nil
	local CurProf = MajorUtil.GetMajorProfID()
	if ProfMgr.CheckProfClass(CurProf, 22) then
		Text = LSTR(1330001)
	else
		Text = LSTR(1330002)
	end

	if not string.isnilorempty(Text) then
		MsgTipsUtil.ShowTips(Text)
	end
end

---@private
function WolvesDenPierMgr:CheckMajorState(IsNeedTips)
	return CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_DUEL, IsNeedTips)
end

---@private
function WolvesDenPierMgr:CheckTargetState(TargetRoleID)
	local TargetEntityID = ActorUtil.GetEntityIDByRoleID(TargetRoleID)
	if TargetEntityID == nil then return false end

	if ActorUtil.IsDeadState(TargetEntityID) then return false end

	return true
end

---@private
function WolvesDenPierMgr:AddCountDownTimer()
	self.TimerID = self:RegisterTimer(self.UpdateCountDownTimer, 1, 1, 0)
end

---@private
function WolvesDenPierMgr:RemoveCountDownTimer()
	if self.TimerID then
		self:UnRegisterTimer(self.TimerID)
		self.TimerID = nil
	end
end

---@private
function WolvesDenPierMgr:UpdateCountDownTimer()
	local NewRemainTime = PVPDuelVM.RemainTime - 1
	PVPDuelVM:SetRemainTime(NewRemainTime)

	if NewRemainTime <= 0 then
		-- 如果一直没有收进侧边栏，不会收到超时事件，所以主动触发一下超时逻辑，有收进侧边栏会有超时事件处理
		local SidebarItem = SidebarMgr:GetSidebarItemVM(SidebarType)
		if SidebarItem == nil then
			self:OnInviteTimeout()
		end
	end
end

---@private
function WolvesDenPierMgr:ShowStartCountDown(BeginTime)
	local function OnStartCountDownEnd()
		self:RegisterTimer(function()
			MsgTipsUtil.ShowTipsByID(338005) -- 战斗开始提示
		end, 1)
	end

	local Params = {}
	Params.BeginTime = BeginTime
	Params.TimeInterval = 1
	Params.TimeDelay = 0
	Params.StartTitleText = ""
	Params.CountDownLoopSound = StartCountDownAudio
	Params.FinishCallback = OnStartCountDownEnd
	UIViewMgr:ShowView(UIViewID.InfoCountdownTipsView, Params)
end

-- endregion Private Function

-- region Public Interface

--- 显示PVP决斗侧边栏
function WolvesDenPierMgr:TryAddSidebarItem()
	local SidebarItem = SidebarMgr:GetSidebarItemVM(SidebarType)
	if SidebarItem ~= nil then return end

	local StartTime = TimeUtil.GetServerLogicTime()
	local CountDownTime = PVPDuelVM.RemainTime
	SidebarMgr:AddSidebarItem(SidebarType, StartTime, CountDownTime)
end

--- 打开决斗界面
function WolvesDenPierMgr:ShowDuelPanel()
	UIViewMgr:ShowView(UIViewID.PVPDuelPanel)
end

--- 关闭决斗界面
function WolvesDenPierMgr:HideDuelPanel()
	local IsViewVisible = UIViewMgr:IsViewVisible(UIViewID.PVPDuelPanel)
	if IsViewVisible then
		UIViewMgr:HideView(UIViewID.PVPDuelPanel)
	end
end

--- 检查是否可以发起/回应决斗
---@param TargetID uint64 目标RoleID
---@param IsNeedTips boolean 是否需要提示，默认有提示
---@return boolean 是否允许
function WolvesDenPierMgr:CheckCanDuel(TargetID, IsNeedTips)
	IsNeedTips = IsNeedTips ~= false
	local MajorCheck = self:CheckMajorState(IsNeedTips)
	local TargetCheck = self:CheckTargetState(TargetID)
	local Result = MajorCheck and TargetCheck
	if MajorCheck and (not TargetCheck) then
		if IsNeedTips then
			MsgTipsUtil.ShowTips(LSTR(1330021))
		end
	end
	return Result
end

--- 是否决斗中
---@return boolean 是否决斗中
function WolvesDenPierMgr:IsInDuel()
	local StateComponent = MajorUtil.GetMajorStateComponent()
	if StateComponent then
		return StateComponent:IsInNetState(ProtoCommon.CommStatID.CommStatPVPDuel)
	end
	return false
end

--- 获取决斗邀请超时时间
---@return uint32 时间(秒)
function WolvesDenPierMgr:GetInviteTimeoutTime()
	if self.InviteTimeoutTime == nil then
		local TimeoutCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_DUEL_ACCEPT_TIMEOUT)
		self.InviteTimeoutTime = TimeoutCfg and TimeoutCfg.Value[1] or 45
	end

	return self.InviteTimeoutTime
end

-- endregion Public Interface

return WolvesDenPierMgr