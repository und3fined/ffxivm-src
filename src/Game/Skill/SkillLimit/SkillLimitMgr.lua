--极限技

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local EventMgr = _G.EventMgr
local ProtoCS = require ("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoRes = require("Protocol/ProtoRes")
local PworldCfg = require("TableCfg/PworldCfg")
local FinePlayCfg = require("TableCfg/FinePlayCfg")
local AudioUtil = require("Utils/AudioUtil")
local TimeUtil = require("Utils/TimeUtil")
local ActorUtil = require("Utils/ActorUtil")

local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_COMBAT_CMD

---@class SkillLimitMgr : MgrBase
local SkillLimitMgr = LuaClass(MgrBase)

function SkillLimitMgr:OnInit()
	self.LimitData = nil
	--极限技资源，会从LimitData，按tick计算
	self.LimitValue = 0
	--极限技数组
	self.LimitSkills = {}

	self.MaxLimitValue = 30000
	self.ValuePerPhase = 10000
	self.CurLimitSkill = 0
	self.CurPhase = 0	--0/1/2/3  
	self.MaxPhase = 1
	self.LastPhase = 0

	--是否正在处于释放技能 读条的UI循环动画中
	-- self.SkillSingUILoopAniming = false	--主角自己
	self.EntranceLoopAniming = false	--仅仅是第三方客户端

	self.LimitSkillMap = {}

	--所在副本 决定是否允许使用极限技
	self.CanUseLimitSkill = 1

	--SoundEventMap[fineplay_type] = {SoundEvent, LastPlayTime}
	self.SoundEventMap = {}

	self.bProfLevelBase = false--是否基职

	self.EntityIDLimitSkilling = 0
end

function SkillLimitMgr:OnBegin()
	--读取FinePlayCfg表中所有的fineevent-soundevent
	local FinePlayList = FinePlayCfg:FindAllCfg()
	for _, CfgItem in ipairs(FinePlayList) do
		self.SoundEventMap[CfgItem.Type] = {SoundEvent = CfgItem.SoundEvent, LastPlayTime = 0}
	end
end

function SkillLimitMgr:OnEnd()
end

function SkillLimitMgr:OnShutdown()
	self:Reset()
end

function SkillLimitMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_SUB_CMD.CS_COMBAT_CMD_SYNC_LIMIT_BREAK, self.OnNetMsgUpdateLimit)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_SUB_CMD.CS_COMBAT_CMD_LIMIT_BREAK_FINPLAY, self.OnNetMsgFinPlay)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_SUB_CMD.CS_COMBAT_CMD_LIMIT_BREAK_BEGIN, self.OnNetMsgLimitSkillBegin)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, CS_SUB_CMD.CS_COMBAT_CMD_LIMIT_BREAK_FINISH, self.OnNetMsgLimitSkillFinish)
end

function SkillLimitMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)
    self:RegisterGameEvent(EventID.AllSkillUpdateFinished, self.OnAllSkillUpdateFinished)
end

function SkillLimitMgr:Reset()
	self.LimitValue = 0
	self.LimitData = nil
	self.LimitSkills = {}

	self.CurPhase = 0	--0/1/2/3  
	self.MaxPhase = 1
	self.LastPhase = 0
	
	self:ResetEntityIDLimitSkilling()
	self.CanUseLimitSkill = 1
	self:CloseTickTimer()
end

function SkillLimitMgr:OnGameEventLoginRes(Param)
	self:ResetEntityIDLimitSkilling()

    local bReconnect = Param and Param.bReconnect
    if (bReconnect) then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		self:PullLimitBreakInfo(MajorEntityID)
    end
end

function SkillLimitMgr:OnEventMajorProfSwitch(Params)
	self.bProfLevelBase = MajorUtil.IsProfBase()
	self:ClearLimitSkills()
	FLOG_INFO("SkillLimitMgr EventProfSwitch bBaseProf:%s", tostring(self.bProfLevelBase))
end

function SkillLimitMgr:OnMajorCreate(Params)
	self.bProfLevelBase = MajorUtil.IsProfBase()
	FLOG_INFO("SkillLimitMgr OnMajorCreate bBaseProf:%s", tostring(self.bProfLevelBase))
end

function SkillLimitMgr:GetLimitValue()
	return self.LimitValue
end

function SkillLimitMgr:GetLimitMaxValue()
	if not self.LimitData then
		return 0
	end
	
	return self.LimitData.Limit
end

function SkillLimitMgr:GetLimitSkillID()
	if not self.LimitSkills or #self.LimitSkills == 0 then
		return 0
	end

	if not self.CurPhase or self.CurPhase == 0 then
		return self.LimitSkills[1].LimitSkillID
	end

	return self.CurLimitSkill or 0
end

function SkillLimitMgr:GetLimitSkillIndex()
	local Cnt = self.LimitSkills and #self.LimitSkills or 0
	if not self.LimitSkills or Cnt == 0 then
		return 17
	end

	if not self.CurPhase or self.CurPhase == 0 then
		return self.LimitSkills[1].LimitSkillIndex
	end

	local CurPhaseSkill = self.LimitSkills[self.CurPhase]
	if not CurPhaseSkill then
		FLOG_ERROR("GetLimitSkillIndex Error: LimitSkillCnt:%d, CurPhase:%d", Cnt, self.CurPhase)
		return self.LimitSkills[Cnt].LimitSkillIndex
	end

	return CurPhaseSkill.LimitSkillIndex
end

function SkillLimitMgr:IsLimitSkill(SkillID)
	local bLimitSkill = self.LimitSkillMap[SkillID] or false

	if not bLimitSkill then
		local SkillType = SkillMainCfg:FindValue(SkillID, "Type")
		if SkillType == ProtoRes.skill_type.SKILL_TYPE_LIMIT then
			self.LimitSkillMap[SkillID] = true
			bLimitSkill = true
		end
	end
	
	return bLimitSkill
end

function SkillLimitMgr:GetCurPhase()
	return self.CurPhase
end

function SkillLimitMgr:GetLastPhase()
	return self.LastPhase
end

function SkillLimitMgr:GetValuePerPhase()
	return self.ValuePerPhase
end

function SkillLimitMgr:GetCurPhaseValue()
	local CurPhaseVal = self.LimitValue - self.CurPhase * self.ValuePerPhase
	return CurPhaseVal
end

function SkillLimitMgr:GetMaxPhase()
	return self.MaxPhase
end

--切图的时候，请求极限技数据
function SkillLimitMgr:OnPWorldEnter(Params)
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	if not MajorEntityID then
		return
	end

	self:ResetEntityIDLimitSkilling()

	self.CanUseLimitSkill = 1
	if Params and Params.CurrPWorldResID then
		local Cfg = PworldCfg:FindCfgByKey(Params.CurrPWorldResID)
		if (Cfg) then
			self.CanUseLimitSkill = PworldCfg:FindValue(Params.CurrPWorldResID, "CanLimitBreak")
			FLOG_INFO("SkillLimitMgr PWorldResID:%d  CanUseLimitSkill: %s"
				, Params.CurrPWorldResID, tostring(self.CanUseLimitSkill))
		end
	else
		FLOG_INFO("SkillLimitMgr CanUseLimitSkill: true, no Params.CurrPWorldResID")
	end

	if not self.CanUseLimitSkill or self.CanUseLimitSkill == 0 then
		return
	end

	self:PullLimitBreakInfo(MajorEntityID)
end

function SkillLimitMgr:PullLimitBreakInfo(MajorEntityID)
	local MsgID = CS_CMD.CS_CMD_COMBAT
	local SubMsgID = CS_SUB_CMD.CS_COMBAT_CMD_SYNC_LIMIT_BREAK

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.LimitBreak = {
		EntityID = MajorEntityID,
		}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function SkillLimitMgr:ClearLimitSkills()
	self.LimitSkills = {}
end

function SkillLimitMgr:OnInitLimitSkills(BtnIndex, SkillID)
	table.insert(self.LimitSkills, {LimitSkillIndex = BtnIndex, LimitSkillID = SkillID})
	FLOG_INFO("SkillLimit SkillIdx:%d, LimitSkill:%d", BtnIndex, SkillID)
end

function SkillLimitMgr:OnAllSkillUpdateFinished()
	if self.LimitDataMsg then
		FLOG_WARNING("SkillLimitMgr OnAllSkillUpdateFinished")
		self:OnNetMsgUpdateLimit(self.LimitDataMsg)
		self.LimitDataMsg = nil
	end
end

function SkillLimitMgr:OnNetMsgUpdateLimit(MsgBody)
	if not MsgBody or not MsgBody.LimitBreak then
		FLOG_ERROR("SkillLimitMgr:OnNetMsgUpdateLimit Error")
		return
	end

	if not self.CanUseLimitSkill or self.CanUseLimitSkill == 0 then
		return
	end

	if #self.LimitSkills == 0 then
		self.LimitDataMsg = MsgBody
		FLOG_WARNING("SkillLimitMgr LimitSkills is empty")
		return
	end

	if self.bProfLevelBase then
		return
	end

    self.LimitData = MsgBody.LimitBreak.LimitBreak
	-- FLOG_INFO("SkillLimit OnNetMsgUpdateLimit Incr %d", self.LimitData.Incr)
	
	local LastPhase = self.LastPhase
	if self.LimitData.IsOpen then
		self:StartTickTimer()
		-- self.LimitData.Limit = 20000
		self.MaxPhase = math.ceil(self.LimitData.Limit / self.ValuePerPhase)
		FLOG_INFO("SkillLimit Status On, MaxPhase = %d value:%d", self.MaxPhase, self.LimitData.Val)
		self:UpdateLimitVal(self.LimitData.Val)
	else
		FLOG_INFO("SkillLimit Status Off")
		self:CloseTickTimer()
		self:UpdateLimitVal(self.LimitData.Val)
	end
	
	if self.LimitData.UseSkillEntityID and self.LimitData.UseSkillEntityID > 0 and not ActorUtil.IsDeadState(self.LimitData.UseSkillEntityID) then
		FLOG_INFO("SkillLimit OnNetMsgUpdateLimit BeginUseLimitSkill %d", self.EntityIDLimitSkilling)
		_G.EventMgr:SendEvent(EventID.BeginUseLimitSkill, {EntityID = self.EntityIDLimitSkilling})
		self.EntityIDLimitSkilling = self.LimitData.UseSkillEntityID
		self:StartDeleyClearTimer()
	else
		FLOG_INFO("SkillLimit OnNetMsgUpdateLimit EndUseLimitSkill")
		_G.EventMgr:SendEvent(EventID.EndUseLimitSkill, {EntityID = 0, IsMsgUpdateLimit = true, LastPhase = LastPhase})
	end
end

function SkillLimitMgr:IsOtherLimitSkilling()
	return self.EntityIDLimitSkilling ~= nil and self.EntityIDLimitSkilling > 0 and self.EntityIDLimitSkilling ~= MajorUtil.GetMajorEntityID()
end

function SkillLimitMgr:IsMajorLimitSkilling()
	return self.EntityIDLimitSkilling ~= nil and self.EntityIDLimitSkilling > 0 and self.EntityIDLimitSkilling == MajorUtil.GetMajorEntityID()
end

function SkillLimitMgr:OnNetMsgLimitSkillBegin(MsgBody)
	if MsgBody and MsgBody.LimitBreakBegin then
		self.EntityIDLimitSkilling = MsgBody.LimitBreakBegin.EntityID
		FLOG_INFO("SkillLimit BeginUseLimitSkill %d", self.EntityIDLimitSkilling)
		_G.EventMgr:SendEvent(EventID.BeginUseLimitSkill, {EntityID = self.EntityIDLimitSkilling})
		
		AudioUtil.LoadAndPlay2DSound(
			"AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_lb_run.Play_SE_UI_SE_UI_lb_run'")
		self:StartDeleyClearTimer()
		
		self:RegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
	end
end

function SkillLimitMgr:OnSkillEnd(Params)
	local EntityID = Params and Params.ULongParam1 or 0
	local SkillID = Params and Params.IntParam1 or 0
	if self.EntityIDLimitSkilling and EntityID == self.EntityIDLimitSkilling then
		FLOG_INFO("SkillLimit %d SkillEnd:%d", self.EntityIDLimitSkilling, SkillID)
		self:OnNetMsgLimitSkillFinish()
	end
end

function SkillLimitMgr:ResetEntityIDLimitSkilling()
	self.EntityIDLimitSkilling = 0
	self:CancelClearTimer()
end

function SkillLimitMgr:StartDeleyClearTimer()
	self:CancelClearTimer()
	-- FLOG_INFO("SkillLimit StartDeleyClearTimer")

	self.ClearTimerID = self:RegisterTimer(function()
		FLOG_INFO("SkillLimit EndUseLimitSkill Timer over")
		_G.EventMgr:SendEvent(EventID.EndUseLimitSkill, {EntityID = self.EntityIDLimitSkilling})
		self.EntityIDLimitSkilling = 0
		self.ClearTimerID = nil
		self:UnRegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
	end, 8, 1, 1)
end

function SkillLimitMgr:CancelClearTimer()
	-- FLOG_INFO("SkillLimit CancelClearTimer")
	if self.ClearTimerID then
		self:UnRegisterTimer(self.ClearTimerID)
	end
	
	self.ClearTimerID = nil
end

--打断、正常结束都是 finish
function SkillLimitMgr:OnNetMsgLimitSkillFinish(MsgBody)
	FLOG_INFO("SkillLimit EndUseLimitSkill")
	_G.EventMgr:SendEvent(EventID.EndUseLimitSkill, {EntityID = self.EntityIDLimitSkilling})
	self:ResetEntityIDLimitSkilling()
	self:UnRegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
end

-- message LimitBreakFineplayS {
-- 	fineplay_type type = 1;
-- 	int64 EntityID = 2;
-- }
function SkillLimitMgr:OnNetMsgFinPlay(MsgBody)
	if MsgBody and MsgBody.Fineplay then
		local CurNode = self.SoundEventMap[MsgBody.Fineplay.type]
		local SoundEvent = CurNode.SoundEvent
		local EntityID = MsgBody.Fineplay.EntityID
		local CurTime = TimeUtil.GetLocalTimeMS()
		if SoundEvent and EntityID and CurTime - CurNode.LastPlayTime > 500 then
			AudioUtil.LoadAndPlaySoundEvent(EntityID, SoundEvent)
			CurNode.LastPlayTime = CurTime
		end
	end
end

--刷新ui等
function SkillLimitMgr:UpdateLimitVal(Val)
	local bSkillLimitCancelBtnClick = false
	if Val then
		if self.LimitValue >= self.ValuePerPhase and Val < self.ValuePerPhase then
			bSkillLimitCancelBtnClick = true
		end

		self.LimitValue = Val
	end

	local LastSkillID = self.CurLimitSkill
	self.CurLimitSkill = 0
	--todo
	if self.LimitValue < 0 or not self.LimitData or self.LimitData.Limit <= 0 then	--不展示极限技
		self:CloseTickTimer()
		_G.EventMgr:SendEvent(EventID.SkillLimitDel)
	elseif self.LimitValue >= 0 then --极限技开启
		if self.LimitValue >= self.MaxLimitValue then
			self.LimitValue = self.MaxLimitValue
			self:CloseTickTimer()
		end

		if self.LimitValue >= self.LimitData.Limit then
			self.LimitValue = self.LimitData.Limit

			self:CloseTickTimer()
		end

		local CurrentPhase = math.floor(self.LimitValue / self.ValuePerPhase)
		-- if self.CurPhase ~= CurrentPhase then
			self.LastPhase = self.CurPhase
		-- end

		self.CurPhase = CurrentPhase
		if self.CurPhase > 0 and self.CurPhase <= #self.LimitSkills then
			self.CurLimitSkill = self.LimitSkills[self.CurPhase].LimitSkillID or 0
		end
		
		if bSkillLimitCancelBtnClick then
			_G.EventMgr:SendEvent(EventID.SkillLimitCancelBtnClick)
		end

		local CurPhaseVal = self.LimitValue - self.CurPhase * self.ValuePerPhase

		if not self.LimitData.IsOpen then
			if self.LimitData.Limit > 0 then
				_G.EventMgr:SendEvent(EventID.SkillLimitOff, CurPhaseVal, self.CurPhase, self.CurLimitSkill)
			end
		else
			_G.EventMgr:SendEvent(EventID.SkillLimitValChg, CurPhaseVal, self.CurPhase, self.CurLimitSkill)
		end
		-- FLOG_INFO("SkillLimit curVal:%d, CurPhase:%d, CurLimitSkill:%d", CurPhaseVal, self.CurPhase, self.CurLimitSkill)

		if self.CurLimitSkill > 0 and self.CurLimitSkill ~= LastSkillID then
			FLOG_INFO("SkillLimit PlaySingID")
			_G.SkillSingEffectMgr:PlaySingEffect(MajorUtil.GetMajorEntityID(), 100102)

			if self.LimitValue >= self.LimitData.Limit then
				AudioUtil.LoadAndPlay2DSound(
					"/Game/WwiseAudio/Events/UI/UI_SYS/LIMIT/Play_se_ui_new_limit_full_3.Play_se_ui_new_limit_full_3")
			else
				AudioUtil.LoadAndPlay2DSound(
					"/Game/WwiseAudio/Events/UI/UI_SYS/LIMIT/Play_se_ui_new_limit_full.Play_se_ui_new_limit_full")
			end
		end
	end
end

function SkillLimitMgr:StartTickTimer()
	if not self.MgrTickTimerID then
		self.MgrTickTimerID = TimerMgr:AddTimer(self, self.OnTick, 0, 1, 0)
	end
end

function SkillLimitMgr:CloseTickTimer()
	if self.MgrTickTimerID then
		TimerMgr:CancelTimer(self.MgrTickTimerID)
	end
	self.MgrTickTimerID = nil
end

function SkillLimitMgr:OnTick()
	local CurServerTime = _G.TimeUtil.GetServerTimeMS()
	if self.LimitData and self.LimitData.IsOpen then
		local IncrTime = math.floor((CurServerTime - self.LimitData.UpdateTime + 300) / 1000)
		self.LimitValue = self.LimitData.Val + IncrTime * self.LimitData.Incr
		-- FLOG_INFO("SkillLimit OnTick Value:%d, LimitValue = %d, incr :%d, CurTime:%d, UpdateTime:%d"
		-- 	,self.LimitData.Val , self.LimitValue, self.LimitData.Incr, CurServerTime, self.LimitData.UpdateTime)

		self:UpdateLimitVal()
	else
		self:CloseTickTimer()
	end
end

return SkillLimitMgr