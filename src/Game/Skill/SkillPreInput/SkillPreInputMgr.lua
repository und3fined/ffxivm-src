--
-- Author: chaooren
-- Date: 2021-01-26
-- Description: 技能预输入
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local Json = require("Core/Json")
local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState
local SelectTargetBase = require ("Game/Skill/SelectTarget/SelectTargetBase")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillObjectMgr = require("Game/Skill/SkillAction/SkillObjectMgr")
local SkillButtonIndexRange = SkillCommonDefine.SkillButtonIndexRange

---@class SkillPreInputMgr : MgrBase
local SkillPreInputMgr = LuaClass(MgrBase)

local RetType = {
	Ignore = 1,
	PreInput = 2
}

function SkillPreInputMgr:OnInit()
	self.PreCastTime = 500 -- 预输入最大提前量 ms
	self.SkillID = nil	--当前保存的预输入技能ID
	self.CastTime = 0	--SkillID的有效释放时间，由定时器控制
	self.TimerID = 0	--

	self.bInField = false
end

function SkillPreInputMgr:OnBegin()
	self.bMoveBreak = false	-- 是否允许移动打断预输入
	-- TODO  俞老板的临时需求，骑士允许移动打断预输入，其他职业不允许
	local Prof = MajorUtil.GetMajorProfID()
	if Prof == ProtoCommon.prof_type.PROF_TYPE_PALADIN then
		self.bMoveBreak = true
	end
end

function SkillPreInputMgr:OnEnd()
end

function SkillPreInputMgr:OnShutdown()

end

function SkillPreInputMgr:OnRegisterNetMsg()

end

function SkillPreInputMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorFirstMove, self.MajorFirstMove)
	self:RegisterGameEvent(EventID.WorldPreLoad, self.OnWorldPreLoad)
	self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
	-- self:RegisterGameEvent(EventID.WorldPreLoad, self.OnWorldPreLoad)
	-- self:RegisterGameEvent(EventID.WorldPostLoad, self.OnWorldPostLoad)
	-- self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldMapEnter)
	-- self:RegisterGameEvent(EventID.PWorldMapExit, self.OnPWorldMapExit)
	-- self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
end

function SkillPreInputMgr:OnWorldPreLoad()
	local IsInField = _G.PWorldMgr:CurrIsInField()
	if self.bInField == IsInField then
		return
	end
	self.bInField = IsInField
	--仅野外支持
	if IsInField then
		self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
	else
		self:UnRegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
	end
end

function SkillPreInputMgr:OnSkillReplace(Params)
    if Params.RawSkill ~= nil  then
        self:ClearPreInputSkill(Params.RawSkill)
    end
end


-- function SkillPreInputMgr:OnWorldPreLoad()
-- 	print("[World]OnWorldPreLoad")
-- end

-- function SkillPreInputMgr:OnWorldPostLoad()
-- 	print("[World]OnWorldPostLoad")
-- end

-- function SkillPreInputMgr:OnPWorldMapEnter()
-- 	print("[World]OnPWorldMapEnter")
-- end

-- function SkillPreInputMgr:OnPWorldMapExit()
-- 	print("[World]OnPWorldMapExit")
-- end

-- function SkillPreInputMgr:OnPWorldExit()
-- 	print("[World]OnPWorldExit")
-- end

--获取当前最大预输入时间
function SkillPreInputMgr:GetMaxPreInputTime()
	local _, CurMainSkillID = self:GetCurrentSkillID()
	local MaxTime = self.PreCastTime
	if CurMainSkillID ~= nil then
		local SkillPreInputTime = SkillMainCfg:FindValue(CurMainSkillID, "PreInputTime") or 0
		MaxTime = math.max(MaxTime, SkillPreInputTime)
	end
	return MaxTime
end

function SkillPreInputMgr:OnNetStateUpdate(Params)
    local EntityID = Params.ULongParam1
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
    local StateType = Params.IntParam1
    if StateType ~= ProtoCommon.CommStatID.COMM_STAT_COMBAT then
        return
    end
	if Params.BoolParam1 == false then
		self:ClearSkill()
	end
end

--返回false表示本次技能释放不进入真正的技能释放流程
function SkillPreInputMgr:OnPreInputCastSkill(SkillID, Index, SkillCD, Params)
	
	--无效技能或已作为预输入的技能直接返回
	if SkillID == nil or SkillID == self.SkillID then
		return false, {RetType = RetType.Ignore}
	end
	local _ <close> = CommonUtil.MakeProfileTag("SkillPreInputMgr:OnPreInputCastSkill")
	--OnInit PreInput
	self.SkillID = nil
	self.CastTime = 0
	if self.TimerID > 0 then
		self:UnRegisterTimer(self.TimerID)
		self.TimerID = 0
	end

	local CurrentSkillID, CurMainSkillID = self:GetCurrentSkillID()
	self.MaxPreInputTime = self.PreCastTime
	if CurMainSkillID ~= nil then
		local SkillPreInputTime = SkillMainCfg:FindValue(CurMainSkillID, "PreInputTime") or 0
		self.MaxPreInputTime = math.max(self.MaxPreInputTime, SkillPreInputTime)
	end
	
	SkillCD = SkillCD * 1000 --PreCastTime为ms，此处单位需统一
	if SkillCD > self.MaxPreInputTime then
		return false, {RetType = RetType.Ignore}
	end

	--当前正在释放的技能为空，意味着任何技能都可以被释放
	if CurrentSkillID == nil then
		if SkillCD == 0 then
			return true
		else
			if self:CanSavePreInput() == false then
				return false, {RetType = RetType.Ignore}
			end
			self.SkillID = SkillID
			self.Index = Index
			self.CastTime = SkillCD
			local SkillParams = {SkillID = self.SkillID, Index = Index, Params = Params}
			self.TimerID = self:RegisterTimer(self.UseSkill, self.CastTime / 1000, 1, 1, SkillParams)
			_G.EventMgr:SendEvent(EventID.CastPreInputChange, { SkillID = SkillID, CastTime = self.CastTime / 1000})
			return false, {RetType = RetType.PreInput, CastTime = self.CastTime / 1000}
		end
	end

	local InputSkillWeight = self:GetInputSkillWeight(SkillID)
	--当前释放技能权重小于输入技能，可立即被打断并释放输入技能
	if SkillCD == 0 and self:IsSkillUseNow(InputSkillWeight) then
		return true
	end

	--根据SkillWeight节点权重计算预输入有效性
	self.Index = Index
	if self:IsSkillWeightValid(SkillID) then
		if self:CanSavePreInput() == false then
			self.SkillID = nil
			self.CastTime = 0
			return false, {RetType = RetType.Ignore}
		end
		-- +100ms用于确保在技能真正改变权重之后释放预输入技能
		self.CastTime = self.CastTime + 100
		self.CastTime = math.max(self.CastTime, SkillCD)
		local SkillParams = {SkillID = self.SkillID, Index = Index, Params = Params}
		self.TimerID = self:RegisterTimer(self.UseSkill, self.CastTime / 1000, 1, 1, SkillParams)
		_G.EventMgr:SendEvent(EventID.CastPreInputChange, { SkillID = SkillID, CastTime = self.CastTime / 1000})
		return false, {RetType = RetType.PreInput, CastTime = self.CastTime / 1000}
	end
	self.SkillID = nil
	self.CastTime = 0
	return false, {RetType = RetType.Ignore}
end

function SkillPreInputMgr:UseSkill(Params)
	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData then
		--多选一技能，不能通过索引判断
		if (Params.Index >= SkillButtonIndexRange.Multi_Start and Params.Index <= SkillButtonIndexRange.Multi_End and LogicData:CanCastSkillbyID(Params.SkillID))
			or LogicData:CanCastSkill(Params.Index, false, SkillBtnState.SkillBtnControl) == true then
			local SkillCDMgr = _G.SkillCDMgr

			local SkillID = Params.SkillID
			local SkillCD = SkillCDMgr:GetSkillRealCDValue(SkillID)
			local ChargeCount = SkillCDMgr:GetSkillCurCharge(SkillID) or 1
			local ReChargeCD = SkillCDMgr:GetReChargeCD(SkillID)
			--技能在预输入过程会出现CD动态修改，当预输入完成时如果剩余CD超过CDMgr一个Tick时间，则认为技能不可被释放
			local bCDValid = SkillCD <= SkillCDMgr.CDTickTime
			local bChargeValid = ChargeCount > 0 or ReChargeCD <= SkillCDMgr.CDTickTime

			if bCDValid and bChargeValid then
				SkillUtil.CastSkillSuccess(SkillID, Params.Index, Params.Params)
			end
		end
	end

	self.SkillID = nil
	self.CastTime = 0
	self.TimerID = 0
end

function SkillPreInputMgr:IsSkillUseNow(InputSkillWeight)
	local EntityID = MajorUtil.GetMajorEntityID()
	local CurrentSkillWeight = SkillObjectMgr:GetCurrentSkillWeight(EntityID)
	if InputSkillWeight > CurrentSkillWeight then
		return true
	end

	return false
end

function SkillPreInputMgr:IsSkillWeightValid(InputSkillID)
	local CurrentSubSkillID, CurrentMainSkillID = self:GetCurrentSkillID()
	
	local Cfg = SkillSubCfg:FindCfgByKey(CurrentSubSkillID)
	if Cfg == nil then
		return false
	end
	local RunningTime = self:GetCurrentSkillRunTime()
	local QuickAttrInvalid = SkillMainCfg:FindValue(CurrentMainSkillID, "QuickAttrInvalid") or 0
	local ShortenCDRate = 1
	if QuickAttrInvalid == 0 then
		local EntityID = MajorUtil.GetMajorEntityID()
		local SkillObject = SkillObjectMgr:GetOrCreateEntityData(EntityID).CurrentSkillObject
		if SkillObject then
			ShortenCDRate = SkillObject.PlayRate
		end
	end

	--ms
	local SkillWeightDegradeTime = Cfg.DegradeTime
	if SkillWeightDegradeTime == 0 then
		SkillWeightDegradeTime = Cfg.EndTime
	end

	local TimeDistance = SkillWeightDegradeTime * ShortenCDRate - RunningTime
	if TimeDistance >= 0 and TimeDistance <= self.MaxPreInputTime then
		self.SkillID = InputSkillID
		self.CastTime = TimeDistance
		return true
	end

	return false
end

function SkillPreInputMgr:GetCurrentSkillID()
	local EntityID = MajorUtil.GetMajorEntityID()
	local SkillObject = SkillObjectMgr:GetOrCreateEntityData(EntityID).CurrentSkillObject
	if SkillObject then
		return SkillObject.CurrentSubSkillID, SkillObject.CurrentSkillID
	end
	return nil
end

function SkillPreInputMgr:GetCurrentSkillRunTime()
	return SkillObjectMgr:GetCurSkillRunningTime(MajorUtil.GetMajorEntityID())
end

function SkillPreInputMgr:GetInputSkillWeight(SkillID)
	return SkillMainCfg:FindValue(SkillID, "SkillWeight") or 0
end

function SkillPreInputMgr:GetCurrentSkillWeight()
	local CurrentSkillID = self:GetCurrentSkillID()
	if CurrentSkillID == nil then
		return nil
	end

	local EntityID = MajorUtil.GetMajorEntityID()
	return SkillObjectMgr:GetCurrentSkillWeight(EntityID)
end

function SkillPreInputMgr:ClearPreInputSkill(SkillID)
	if SkillID == self.SkillID then
		self:ClearSkill()
	end
end

function SkillPreInputMgr:ClearSkill()
	self.SkillID = nil
	self.CastTime = 0
	if self.TimerID > 0 then
		self:UnRegisterTimer(self.TimerID)
		self.TimerID = 0
	end
	_G.EventMgr:SendEvent(EventID.CastPreInputChange, { SkillID = nil, CastTime = 0}) --清理技能时发送事件来停止预输入动效
end

function SkillPreInputMgr:MajorFirstMove()
	if self.bMoveBreak == false then
		return
	end
	if self.SkillID ~= nil or self.TimerID > 0 then
		self:ClearSkill()
	end
end

function SkillPreInputMgr:CanSavePreInput()
	if self.bMoveBreak == true then
		local Velocity = MajorUtil.GetMajor().CharacterMovement.Velocity
		if Velocity.X ~= 0 or Velocity.Y ~= 0 or Velocity.Z ~= 0 then
			return false
		end
	end
	return true
end

function SkillPreInputMgr:SetMoveBreak(MoveBreak)
	if MoveBreak == 1 then
		self.bMoveBreak = true
	else
		self.bMoveBreak = false
	end
end

return SkillPreInputMgr