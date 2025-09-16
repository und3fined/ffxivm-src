--
-- Author: anypkvcai
-- Date: 2020-12-22 14:10:40
-- Description: 技能蓄力
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SkillUtil = require("Utils/SkillUtil")
local SkillStorageSync = require("Game/Skill/SkillStorage/SkillStorageSync")
local StorageSkillCfg = require("TableCfg/StorageSkillCfg")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillCastType = SkillCommonDefine.SkillCastType
local MsgTipsID = require("Define/MsgTipsID")

local LSTR

---@class SkillStorageMgr : MgrBase
local SkillStorageMgr = LuaClass(MgrBase)

local StorageStateTag = "Storage"

---@field SkillIndex number                 @技能按钮索引
---@field SkillID number                    @初始技能ID
---@field BeginTime number                  @蓄力开始时间
---@field StorageCfg table                  @c_storage_skill_cfg配置
---@field Level number                      @蓄力阶段
function SkillStorageMgr:OnInit()
	self.EntityID = 0

	self.SkillIndex = 0
	self.SkillID = 0
	self.BeginTime = 0
	self.StorageCfg = nil
	self.Level = 0
	self.IsLimitTime = false
	self.SkillIDMap = {}

	self.StorageSkillCfgCache = {}
end

function SkillStorageMgr:OnBegin()
	LSTR = _G.LSTR
end

function SkillStorageMgr:OnEnd()
end

function SkillStorageMgr:OnShutdown()

end

function SkillStorageMgr:OnRegisterNetMsg()

end

function SkillStorageMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BreakStorageSkill, self.OnBreakStorage)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
--	self:RegisterGameEvent(EventID.TrivialCombatStateUpdate, self.OnControlStateChange)
end

function SkillStorageMgr:OnPWorldExit()
	if self.SkillID ~= 0 then
		self:OnSkillEnd(false, false)
	end
end

--状态中断技能蓄力调用 (不使用传入的SkillID进行Break)
function SkillStorageMgr:OnControlStateChange(EntityID)
	if MajorUtil.GetMajorEntityID() ~= EntityID then
		return
	end
	if self.SkillID == 0 then
		return
	end
	--local MajorStateComp = MajorUtil.GetMajorStateComponent()
	--if MajorStateComp:GetActorControlState(_G.UE.EActorControllStat.CanUseSkill) == false or MajorStateComp:GetActorControlState(_G.UE.EActorControllStat.CanContinueSkill) == false then
	--	local IsStorage = self:IsStorageSkillCfg(self.SkillID)
	--	print(self.SkillID)
	--	print(IsStorage)
	--	if IsStorage == true then
	self:BreakStorageSkill(self.SkillID,true)
	--	end
	--end
end
--当前是否正在蓄力
function SkillStorageMgr:IsStorage(EntityID)
	if self.EntityID == EntityID and self.SkillID > 0 then
		return true
	end
	return false
end

function SkillStorageMgr:OnBreakStorage(Params)
	if self.EntityID ~= 0 and MajorUtil.IsMajor(self.EntityID) then
		local SkillID = Params.IntParam1
		if SkillID == self.SkillID then
			if self.StorageCfg.IsCancel == 0 then
				self:CastSkillInternal()
			else
				self:OnSkillEnd(false, true)
			end
			self.SkillID = 0
			self.IsBreak = true
		end
	end
end

function SkillStorageMgr:BreakStorageSkill(SkillID, bSimulateCD)
	if SkillID ~= 0 and SkillID == self.SkillID then
		self:OnSkillEnd(false, bSimulateCD)
	end
end

function SkillStorageMgr:BreakCurStorageSkill(bSimulateCD)
	if self.SkillID ~= 0 then
		self:OnSkillEnd(false, bSimulateCD)
	end
end

function SkillStorageMgr:IsStorageSkill(SkillID, BaseSkillID)
	if BaseSkillID ~= nil then
		if BaseSkillID == SkillID then
			return true, BaseSkillID
		end
		local StorageSkillList = self.SkillIDMap[BaseSkillID]
		if StorageSkillList ~= nil then
			for _, value in ipairs(StorageSkillList) do
				if value == SkillID then
					return true, BaseSkillID
				end
			end
		end
	else
		for key, value in pairs(self.SkillIDMap) do
			if key == SkillID then
				return true, key
			end
			local StorageSkillList = value
			for _, value1 in ipairs(StorageSkillList) do
				if value1 == SkillID then
					return true, key
				end
			end
		end
	end
	return false
end

function SkillStorageMgr:IsStorageSkillCfg(SkillID)
	local Cfg = StorageSkillCfg:FindCfgByKey(SkillID)
	if Cfg ~= nil then
		return true
	else
		return false
	end
end

function SkillStorageMgr:ClearSkill()
	self.SkillIndex = 0
	self.SkillID = 0
	self.BeginTime = 0
	self.StorageCfg = nil
	self.Level = 0
	self.IsLimitTime = false
	self.EntityID = 0
end

function SkillStorageMgr:GetFirstValidSkill(BaseSkillID)
	local Cfg = StorageSkillCfg:FindCfgByKey(BaseSkillID)
	if Cfg then
		for _, value in ipairs(Cfg.LevelList) do
			if value.SkillID ~= 0 then
				return value.SkillID
			end
		end
	end
	return 0
end

---PrepareCastSkill
---@param SkillID number
---@param SkillIndex number
function SkillStorageMgr:PrepareCastSkill(EntityID, SkillID, SkillIndex, X, Y)
	local _ <close> = CommonUtil.MakeProfileTag("SkillStorageMgr:PrepareCastSkill")
	self:ClearSkill()
	local Cfg = StorageSkillCfg:FindCfgByKey(SkillID)
	if nil == Cfg or nil == Cfg.ID or #Cfg.LevelList == 0 then
		return
	end
	local ValidSkillID = self:GetFirstValidSkill(SkillID)
	if ValidSkillID == 0 then
		return
	end

	local bMajor = MajorUtil.IsMajor(EntityID)
	if bMajor then
		--清空预输入信息
		_G.SkillPreInputMgr:ClearSkill()

		local Major = MajorUtil.GetMajor()
		local SubSkillID = SkillUtil.MainSkill2SubSkill(ValidSkillID)
		local TargetList, HaveTargetBlocked = _G.SelectTargetMgr:SelectTargets(ValidSkillID, SubSkillID, 1, Major, false, true)
		if TargetList:Length() == 0 and SkillSubCfg:FindValue(SubSkillID, "IsCastWithoutTarget") == 0 then
			if HaveTargetBlocked then
                MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillCannotSeeTarget)-- 看不见目标
			else
                MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillNoTargetOrFar)-- 没有有效目标或目标距离过远
			end
			return
		end

		--蓄力权重判断
		local StorageSkillWeight = Cfg.Weight or 0
		local CurSkillWeight = _G.SkillPreInputMgr:GetCurrentSkillWeight()
		if CurSkillWeight ~= nil then
			if StorageSkillWeight <= CurSkillWeight then
				return
			end
			local CombatComponent = MajorUtil.GetMajor():GetSkillComponent()
			if CombatComponent ~= nil then
				CombatComponent:BreakSkill()
			end
		end
	end

	local QuickAttrInvalid = SkillMainCfg:FindValue(ValidSkillID, "QuickAttrInvalid")
	local ShortenTimeCoefficient = 1
	if QuickAttrInvalid == 0 then
        local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
        if AttributeComponent then
            ShortenTimeCoefficient = 1 - AttributeComponent:GetAttrValue(ProtoCommon.attr_type.attr_shorten_action_time) / 10000
        end
    end

	self.EntityID = EntityID
	self.SkillIndex = SkillIndex
	self.StorageCfg = Cfg
	self.SkillID = SkillID
	self.BeginTime = TimeUtil.GetLocalTimeMS()
	self.LevelCount = 0
	self.MoveMultiply = Cfg.MoveMultiply
	self.IsTurn = Cfg.IsTurn
	self.ReturnTime = Cfg.ReturnCD
	self.Level = 0
	self.IsLimitTime = false
	self.IsBreak = false
	self.ShortenTimeCoefficient = ShortenTimeCoefficient
	self.SkillIDMap = {}
	self.SkillIDMap[self.SkillID] = {}
	local bFixLevel = false
	for index, value in ipairs(Cfg.LevelList) do
		if value.SkillID ~= 0 then
			self.SkillIDMap[self.SkillID][index] = value.SkillID
			--技能学习相关需求，实现方案由替换改为蓄力模块自行判断
			--这里直接修正最大蓄力次数，没学过的技能不计入次数，同时配置表里的该参数可废弃掉
			if not bMajor or (not bFixLevel and SkillUtil.IsMajorSkillLearned(value.SkillID)) then
				self.LevelCount = self.LevelCount + 1
			else
				bFixLevel = true
			end
		end
	end
	if self.LevelCount == 0 then
		self:ClearSkill()
		FLOG_WARNING("[SkillStorageMgr] Valid MaxLevelCount=0")
		return
	end
	local ValidMaxTime = Cfg.LevelList[self.LevelCount].MaxTime * ShortenTimeCoefficient

	SkillStorageSync.PlayStorageEffect(EntityID, Cfg.SingID, ShortenTimeCoefficient)

	local StateComponent = ActorUtil.GetActorStateComponent(EntityID)
	--禁用人物移动
	if self.MoveMultiply == 0 then
		if StateComponent ~= nil then
			StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, false, StorageStateTag)
		end
	end
	--禁用人物转向
	if self.IsTurn == 0 then
		if StateComponent ~= nil then
			StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanTurn, false, StorageStateTag)
		end
	end

	self:UnRegisterAllTimer()

	if Cfg.MinTime * ShortenTimeCoefficient <= 0 then
		self:OnTimerLevelEnd()
	else
		self:RegisterTimer(self.OnTimerLevelEnd, Cfg.MinTime * ShortenTimeCoefficient / 1000)
	end

	--self:SendStorageEvent(Cfg.ID, SkillID, 0, 0)

	local Params = { SkillIndex = SkillIndex, SkillID = SkillID, WeakTime = 0, ShortenTimeCoefficient = ShortenTimeCoefficient, LevelCount = self.LevelCount, LevelList = table.deepcopy(Cfg.LevelList) }

	if Cfg.IsVisible == 1 then
		_G.UIAsyncTaskMgr:ShowViewAsync(_G.UIViewID.MainSkillStorage, Params)
	elseif Cfg.IsVisible == 2 then
		self.StorageParams = Params
	end
	_G.EventMgr:SendEvent(EventID.StorageStart, {EntityID = EntityID, Index = SkillIndex, MaxTime = ValidMaxTime})

	if MajorUtil.IsMajor(EntityID) then
		local CppParams = _G.EventMgr:GetEventParams()
		CppParams.IntParam1 = Cfg.ID
		_G.EventMgr:SendCppEvent(EventID.MajorStorageStart, CppParams)

		local bEnterCombat = SkillMainCfg:FindValue(SkillID, "IsTempHoldWeapon") == 1
		if bEnterCombat and StateComponent and not StateComponent:IsInCombatNetState() then
			StateComponent:TempHoldWeapon(_G.UE.ETempHoldMask.Skill)
		end
	end
end

---CastSkill
---@field SkillID number                       @初始技能ID
---@field SkillIndex number                    @技能按钮索引
---@return boolean                             @蓄力技能是否是否成功
function SkillStorageMgr:CastSkill(EntityID, SkillID, SkillIndex, Params)
	if self.IsLimitTime then
		self.IsLimitTime = false
		self.SkillID = 0
		return true
	end
	local _ <close> = CommonUtil.MakeProfileTag("SkillStorageMgr:CastSkill")
	if self.SkillID == SkillID then
		if self.IsBreak == true then
			self.SkillID = 0
			return true
		end
		self.SkillIndex = SkillIndex
		local RetTemp = self:CastSkillInternal(Params)
		return RetTemp
	else
		if self.SkillID > 0 then
			self:OnSkillEnd(false, true)
		else
			local Cfg = StorageSkillCfg:FindCfgByKey(SkillID)
			if nil ~= Cfg and nil ~= Cfg.ID then
				return true
			end
		end
	end
	return false
end

---CastSkillInternal
function SkillStorageMgr:CastSkillInternal(Params)
	local Cfg = self.StorageCfg
	if nil == Cfg then return false end

	local SkillLevel = Cfg.LevelList[self.Level]
	if nil == SkillLevel then
		self:OnSkillEnd(true)
		return true
	end
	if MajorUtil.IsMajor(self.EntityID) then
		--提交技能前先处理收拔刀状态
		local StateComponent = ActorUtil.GetActorStateComponent(self.EntityID)
		local bEnterCombat = SkillMainCfg:FindValue(self.SkillID, "IsTempHoldWeapon") == 1
		if bEnterCombat and StateComponent and not StateComponent:IsInCombatNetState() then
			StateComponent:ClearTempHoldWeapon(_G.UE.ETempHoldMask.Skill, true)
		end

		SkillUtil.SendCastSkillEvent(SkillCastType.StorageType, Cfg.ID, self.SkillID, self.Level, SkillLevel.SkillID, self.SkillIndex, Params)
	else
		SkillUtil.PlayerCastSkillFinal(self.EntityID, SkillCastType.StorageType, self.SkillID, SkillLevel.SkillID, self.SkillIndex)
	end
	self:OnSkillEnd(true, nil, true)

	return true
end

---OnTimerLevelEnd
function SkillStorageMgr:OnTimerLevelEnd()
	if self.Level < self.LevelCount then
		self.Level = self.Level + 1
		self:StartLevel()
	else
		local Cfg = self.StorageCfg
		if nil == Cfg then return end

		local Time = TimeUtil.GetLocalTimeMS() - self.BeginTime

		self:UnRegisterAllTimer()
		self:RegisterTimer(self.OnTimerLimitTime, (Cfg.LimitTime * self.ShortenTimeCoefficient - Time) / 1000)
	end
end

---OnTimerLimitTime
function SkillStorageMgr:OnTimerLimitTime()
	self.IsLimitTime = true

	local Cfg = self.StorageCfg
	if nil == Cfg then return end

	--print(" SkillStorageMgr:OnTimerLimitTime", Cfg.IsCancel)
	if Cfg.IsCancel == 0 then
		self:CastSkillInternal()
	end
end

---StartLevel
function SkillStorageMgr:StartLevel()
	local Cfg = self.StorageCfg
	if nil == Cfg then return false end

	local SkillLevel = Cfg.LevelList[self.Level]
	if nil == SkillLevel then return false end

	local Time = TimeUtil.GetLocalTimeMS() - self.BeginTime

	if Cfg.IsVisible == 2 and self.Level == 2 then
		local Params = self.StorageParams
		Params.LevelCount = Params.LevelCount - 1
		table.remove(Params.LevelList, 1)
		Params.WeakTime = Time
		_G.UIAsyncTaskMgr:ShowViewAsync(_G.UIViewID.MainSkillStorage, Params)
	end

	self:UnRegisterAllTimer()
	self:RegisterTimer(self.OnTimerLevelEnd, (SkillLevel.MaxTime * self.ShortenTimeCoefficient - Time) / 1000)
	--self:SendStorageEvent(Cfg.ID, self.SkillID, self.Level, SkillLevel.SkillID)

	return true
end

---OnSkillEnd
---@param Result boolean @本次蓄力是否成功释放
function SkillStorageMgr:OnSkillEnd(Result, bSimulateCD, HoldWeaponInValid)
	_G.UIAsyncTaskMgr:HideViewAsync(_G.UIViewID.MainSkillStorage, false, {Result = Result})

	--恢复人物移动
	if self.MoveMultiply == 0 then
		local StateComponent = ActorUtil.GetActorStateComponent(self.EntityID)
		if StateComponent ~= nil then
			StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, true, StorageStateTag)
		end
	end
	--恢复人物转向
	if self.IsTurn == 0 then
		local StateComponent = ActorUtil.GetActorStateComponent(self.EntityID)
		if StateComponent ~= nil then
			StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanTurn, true, StorageStateTag)
		end
	end

	-- 蓄力技能释放失败时存在一个返还CD
	-- 在结束蓄力技能时，如果bSimulateCD == true，则由客户端模拟一个蓄力技能CD用于表现
	if bSimulateCD == true and MajorUtil.IsMajor(self.EntityID) then
		if self.ReturnTime and self.ReturnTime > 0 then
			local SkillCDMgr = _G.SkillCDMgr
			if self.ReturnTime > 1 then	--这是一个绝对CD，ms
				local SkillCD = self.ReturnTime / 1000
				SkillCDMgr:SetSkillCD(self.SkillID, SkillCD, SkillCD)
			else -- 这是基础CD百分比
				local SkillCD = self.ReturnTime * SkillCDMgr:LoadSkillCD(self.SkillID)
				SkillCDMgr:SetSkillCD(self.SkillID, SkillCD, SkillCD)
			end
		end
	end

	
	SkillStorageSync.BreakStorageEffect(self.EntityID)
	
	self:UnRegisterAllTimer()
	_G.EventMgr:SendEvent(EventID.StorageEnd, {EntityID = self.EntityID, Index = self.SkillIndex, EndResult = Result})

	if MajorUtil.IsMajor(self.EntityID) then
		local CppParams = _G.EventMgr:GetEventParams()
		_G.EventMgr:SendCppEvent(EventID.MajorStorageEnd, CppParams)

		if not HoldWeaponInValid then
			local StateComponent = ActorUtil.GetActorStateComponent(self.EntityID)
			local bEnterCombat = SkillMainCfg:FindValue(self.SkillID, "IsTempHoldWeapon") == 1
			if bEnterCombat and StateComponent and not StateComponent:IsInCombatNetState() then
				StateComponent:ClearTempHoldWeapon(_G.UE.ETempHoldMask.Skill, true)
			end
		end
	end
	self:ClearSkill()
end

---SendStorageEvent
---@param CfgID number
---@param SkillID number
---@param Level number
---@param LevelSkillID number
---@deprecated 改用MajorStorageStart事件
function SkillStorageMgr:SendStorageEvent(CfgID, SkillID, Level, LevelSkillID)
	if MajorUtil.IsMajor(self.EntityID) ~= true then
		return
	end
	local Params = _G.EventMgr:GetEventParams()
	Params.IntParam1 = CfgID
	Params.IntParam2 = SkillID
	Params.IntParam3 = Level
	Params.IntParam4 = LevelSkillID

	_G.EventMgr:SendCppEvent(EventID.UpdateStorage, Params)
end

---GetSkillID
function SkillStorageMgr:GetSkillID()
	return self.SkillID
end

return SkillStorageMgr