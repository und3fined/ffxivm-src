---
--- Author: anypkvcai
--- DateTime: 2021-04-06 14:25
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local AttrType = ProtoCommon.attr_type
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local UCommonUtil = _G.UE.UCommonUtil
local Json = require("Core/Json")
local SceneEncourageNpcCfg = require("TableCfg/SceneEncourageNpcCfg")
local ActorMgr = require("Game/Actor/ActorMgr")
local ProtoRes = require("Protocol/ProtoRes")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local OnlineStatusRes = ProtoRes.OnlineStatus
local ProSkillUtil = require("Utils/ProSkillUtil")
local SkillUtil = require("Utils/SkillUtil")
local TimeUtil = require("Utils/TimeUtil")


---@class TeamMemberVM : UIViewModel
local TeamMemberVM = LuaClass(UIViewModel)

---Ctor
function TeamMemberVM:Ctor()
	self.RoleID = nil
	self.IsCaptain = false
	self:SetIsSelected(false)
	self:SetEnmityOrder(0)
	self.BGColor = "70C1FFFF"
	self.NameColor = "FFFFFFFF"
	self.HPPercent = 0
	self:SetShiedPercent(0)
	self.RenderOpacity = 1
	self.IncreasedPercent = 0
	self.ReducedPercent = 0
	self.IsMaxHPIncrease = false
	self.IsMaxHPReduce = false
	self.LBPercent = 0
	self.IsLBFull = false

	self.bShowHPPanel = false

	self:SetName("")
	self:SetProfID(0)
	self:SetLevel(0)

	---@deprecated
	self.IsMajor = false

	self.EntityID = nil

	self.BuffVMList = nil

	self.bInMajorMap = false

	self.IsSelectSyncScene = true -- 选中时是否同步给场景

	self:SetShowRevivePanel(false)
	self:SetRescureSkillRemainCD(0)
	self:SetRescureSkillRemainCDPercent(0)
	self:SetRescureDeadline(0)

	-- 在线状态
	self.HasOLStat = false
	self.OLStatIcon = ""
	self.OLStatDict = {}
	self.bDead = false

	--副本确认界面信息
	self.IsPopUpMenu = false

	-- 随从
	self.IsEntourage = false
	self.EntourageProfIcon = ""
	--Roll点
	self.AwardBelong = nil
	self.IsSmooth = false
	self.IsMajor = false
	self.RollResult = 0
	self.IsUpdateRoll = false
	self.BindableProperties["IsUpdateRoll"]:SetNoCheckValueChange(true)
	self.IsPlayWin = false
	self:SetShowRoll(false)	--标志roll点显示

	-- voice
	self:SetVoiceMemberID(0)
	self:SetIsSaying(false)
	self:SetMicSyncState(0)

	-- 是否PVP玩家
	self.IsPVPPlayer = false
	-- PVP玩法里，死亡后复活时间戳，死亡状态据此判断
	self.RespawnTime = 0
end

function TeamMemberVM:IsEqualVM(Value)
	return Value and ((Value.RoleID == self.RoleID and self.RoleID ~= nil and self.RoleID ~= 0) or (Value.EntityID == self.EntityID and self.EntityID ~= 0 and self.EntityID ~= nil))
end

function TeamMemberVM:AdapterOnGetCanBeSelected()
	return true
end

function TeamMemberVM:UpdateVM(Value)
	if nil == Value then
		return
	end

	self:SetIsSelected(false)
	self.IsPopUpMenu = false
	self.IsSaying = false

	self.IsPVPPlayer = Value.IsPVPPlayer or false

	local RoleVM = _G.RoleInfoMgr:FindRoleVM(Value.RoleID, true)
	self.RoleID = Value.RoleID
	local bMajor <const> = self:IsMajorRole()
	self.JoinTime = Value.JoinTime
	self.IsMajor = bMajor
	self.IsEntourage = Value.IsEntourage or false
	self:SetEntityID(Value.EntityID and Value.EntityID or ((self.RoleID and self.RoleID ~= 0) and ActorUtil.GetEntityIDByRoleID(self.RoleID) or nil), true)
	self.CampID = Value.CampID -- 阵营ID
	self.GroupID = Value.GroupID -- 分组ID
	self.TeamID = Value.TeamID -- 队伍ID

	-- set name
	self.EntourageID = Value.IsEntourage and Value.EntourageID or nil
	local RobotCfg = SceneEncourageNpcCfg:FindCfgByKey(Value.EntourageID)
	self.EntourageProfIcon = RobotCfg and RobotCfg.ProfIcon or ""
	if self.RoleID ~= nil and self.RoleID ~= 0 then
		self:SetName(Value.Name or (RoleVM and RoleVM.Name or ""))
	elseif self.IsEntourage then
		self:SetName(RobotCfg and RobotCfg.Name or (Value.Name or ""))
	end

	local ProfID = Value.ProfID
	local Level = Value.Level
	if bMajor then
		ProfID = MajorUtil.GetMajorProfID() or 0
		Level = MajorUtil.GetMajorLevel() or 0
	end

	-- set prof
	self:SetProfID(ProfID)
	self:SetLevel(Level)

	local CliData = Value.CliData
	local VoiceID =  0
	local MicSyncState = Value.MicSyncState or 0
	if not string.isnilorempty(CliData) then
		local TransData = Json.decode(CliData)
		VoiceID = TransData.VoiceMemberID or 0
		MicSyncState = TransData.MicSyncState or 0
	end

	-- print('sound value for [copy get]', self.Name, MicSyncState)
	self:SetVoiceMemberID(VoiceID)
	self:SetMicSyncState(MicSyncState)

	self:UpdateByRoleInfo(true)

	local bNonRole = self.IsEntourage or self.RoleID == nil or self.RoleID == 0
	-- init online status
	local Bits
	if self.EntityID and self.EntityID ~= 0 and not bNonRole then
		Bits = _G.OnlineStatusMgr:GetVisionStatusByEntityID(self.EntityID)
	end

	if Bits then
		self:SetOLStatMovie(OnlineStatusUtil.CheckBit(Bits, OnlineStatusRes.OnlineStatusCutscene))
		self:SetOLStatNetUnstable(OnlineStatusUtil.CheckBit(Bits, OnlineStatusRes.OnlineStatusElectrocardiogram))
	elseif bNonRole then
		self:ClearOnlineStat()
	end

	if bMajor then
		self:SetIsOnline(true)
		self:SetOLStatNetUnstable(false)
	end

	self:SetShowRoll(_G.UIViewMgr:IsViewVisible(_G.UIViewID.TeamRollPanel))

	self:UpdateRescureDeadline()

	self:SetRescureSkillRemainCD(0)
	self:SetRescureSkillRemainCDPercent(0)

	_G.EventMgr:SendEvent(_G.EventID.TeamMemberOnUpdateValue, self)
end


function TeamMemberVM:UpdateRescureDeadline()
	local ReviveMgr = require("Game/PWorld/Death/ReviveMgr")
	local RescureInfo = ReviveMgr:GetRescureInfo(self.RoleID)
	self:SetRescureDeadline((self:IsDead() and RescureInfo) and RescureInfo.RescueDeadline or 0)
end

function TeamMemberVM:UpdateByRoleInfo(bForce)
	if self.RoleID == nil or self.RoleID == 0 then
		return
	end

	_G.RoleInfoMgr:QueryRoleSimple(self.RoleID, function(InRoleID, VM)
		if InRoleID == self.RoleID and self.RoleID ~= 0 and not self.IsEntourage then
			self:UpdateRoleInfo(VM)
		end
	end, self.RoleID, not bForce)
end

---@param Value RoleVM
function TeamMemberVM:UpdateRoleInfo(Value)
	if Value == nil then
		return
	end

	self:SetName(Value.Name)
	self:SetEntityID(ActorUtil.GetEntityIDByRoleID(Value.RoleID), true)
end

function TeamMemberVM:UpdateEntityData()
	self:UpdateAliveStats()
	self:UpdateHP()
	self:UpdateLB()
	self:UpdateColor()
	self:UpdateBuff()
end

function TeamMemberVM:SetEntityID(EntityID, bForceUpdate)
	local bChanged = self.EntityID ~= EntityID
	self.EntityID = EntityID
	if bChanged or bForceUpdate then
		self:UpdateEntityData()
	end
end

function TeamMemberVM:SetProfID(ProfID)
	if self.ProfID ~= ProfID then
		_G.FLOG_INFO("TeamMemberVM:SetProfID %s %s %s <= %s", self.RoleID, self.Name, ProfID, self.ProfID)
	end
	self.ProfID = ProfID
end

function TeamMemberVM:SetLevel(Level)
	self.Level = Level
end

---@private
function TeamMemberVM:SetName(Value)
	self.Name = Value
end

function TeamMemberVM:IsMajorRole()
	return self.RoleID == MajorUtil.GetMajorRoleID() and self.RoleID ~= nil
end

-------------------------------------------------------------------------------------------------------
--- @see 血条Buff仇恨等战斗状态
-- 血条相关
function TeamMemberVM:SetHPPercent(Percent)
	self.HPPercent = Percent
end

function TeamMemberVM:SetShiedPercent(Percent)
	self.IsShiedVisible = Percent > 0
	self.ShiedPercent = Percent
end

function TeamMemberVM:SetReducedPercent(Percent)
	self.IsMaxHPReduce = Percent > 0
	self.ReducedPercent = Percent
end

function TeamMemberVM:SetIncreasedPercent(Percent)
	self.IsMaxHPIncrease = Percent > 0
	self.IncreasedPercent = Percent
end

function TeamMemberVM:SetRenderOpacity(RenderOpacity)
	self.RenderOpacity = RenderOpacity
end

function TeamMemberVM:UpdateHP()
	local CurHP = 0
	local MaxHP = 1
	local UnSteadyMaxHP = 0
	local Shield = 0

	local Actor = nil
	if self.RoleID ~= nil then
		Actor = ActorUtil.GetActorByRoleID(self.RoleID)
	elseif self.EntityID and self.EntityID > 0 then
		Actor = ActorUtil.GetActorByEntityID(self.EntityID)
	end
	if nil ~= Actor then
		local AttributeComponent = Actor:GetAttributeComponent()
		if nil ~= AttributeComponent then
			CurHP = AttributeComponent:GetCurHp()
			MaxHP = AttributeComponent:GetMaxHp()
			UnSteadyMaxHP = AttributeComponent:GetUnSteadyAttrValue(AttrType.attr_hp_max)
			Shield = AttributeComponent:GetAttrValue(AttrType.attr_shield)
		end
	end

	self.bShowHPPanel = Actor ~= nil and Actor:GetAttributeComponent() ~= nil

	if self.IsPVPPlayer then
		if Actor then
			-- 视野内玩家的HP等属性更新和PVE保持一致
			self:UpdateHPInfo(CurHP, MaxHP, UnSteadyMaxHP, Shield)
		else
			-- 视野外玩家的HP、位置等属性由玩法协议额外同步
			if _G.PVPTeamMgr:IsTeamMemberByRoleID(self.RoleID) or _G.PVPTeamMgr:IsEnemyTeamMemberByRoleID(self.RoleID) then
				local HPPercent = _G.PVPTeamMgr:GetTeamMemberHPPercentByRoleID(self.RoleID)
				self:SetHPPercent(HPPercent)
			end
		end
	else
		-- 原来PVE的逻辑不变
		if Actor or not self.bInMajorMap then
			self:UpdateHPInfo(CurHP, MaxHP, UnSteadyMaxHP, Shield)
		end
	end
end

function TeamMemberVM:UpdateHPInfo(CurHP, MaxHP, UnSteadyMaxHP, Shield)
	local HPPercent = 0
	local ReducedPercent = 0
	local IncreasedPercent = 0
	local ShiedPctToCal = 0
	local LowPercent = 0.2
	local bLow = false

	if UnSteadyMaxHP < 0 then
		local Total = MaxHP - UnSteadyMaxHP

		ReducedPercent = -UnSteadyMaxHP / Total

		if CurHP + Shield >= MaxHP then
			if Total > 0 and MaxHP > 0 then
				local Percent = MaxHP / Total
				HPPercent = CurHP / (CurHP + Shield) * Percent
				ShiedPctToCal = Shield > 0 and Percent or 0
			end
		else
			if Total > 0 then
				HPPercent = CurHP / Total
				ShiedPctToCal = Shield > 0 and (CurHP + Shield) / Total or 0
				bLow = HPPercent < LowPercent
			end
		end
	else
		if CurHP + Shield >= MaxHP then
			if CurHP + Shield > 0 then
				HPPercent = CurHP / (CurHP + Shield)
				ShiedPctToCal = Shield > 0 and 1 or 0
			end
		else
			if MaxHP > 0 then
				HPPercent = CurHP / MaxHP
				ShiedPctToCal = Shield > 0 and (CurHP + Shield) / MaxHP or 0
				bLow = HPPercent < LowPercent
			end
		end
	end

	self:SetHPPercent(HPPercent)
	self:SetReducedPercent(ReducedPercent)
	self:SetIncreasedPercent(IncreasedPercent)
	self:SetShiedPercent(ShiedPctToCal)
	self:SetBGColor(bLow and "FFFFFFFF" or "FFFFFFFF")
end

function TeamMemberVM:UpdateLB()
	local MainProSkillMgr = _G.MainProSkillMgr

	-- PVP量谱ID
	local SpectrumID = ProSkillUtil.GetProfSpectrumID(self.ProfID, SkillUtil.MapType.PVP)
	if not SpectrumID then
		return
	end

	local CurValue
	if self:IsMajorRole() then
		CurValue = MainProSkillMgr:GetCurrentResource(SpectrumID) or 0
	else
		CurValue = MainProSkillMgr:GetSpectrumValueByRoleID(self.RoleID, SpectrumID) or 0
	end

	local MaxValue = ProSkillUtil.GetSpectrumMaxValue(SpectrumID) or 10000

	self.LBPercent = CurValue / MaxValue
	self.IsLBFull = CurValue >= MaxValue
end

function TeamMemberVM:SetEnmityOrder(Value)
	self.EnmityOrder = Value
end

-- Buff
function TeamMemberVM:UpdateBuff()
	self:SetBuffVMList((_G.ActorMgr:FindActorVM(self.EntityID) or {}).BufferVMList)
end

function TeamMemberVM:SetBuffVMList(InBuffVMList)
	self.BuffVMList = InBuffVMList
end

function TeamMemberVM:UpdateRespawnTime(RespawnTime)
	self.RespawnTime = RespawnTime
	self:UpdateAliveStats()
end

function TeamMemberVM:IsDeadByRespawnTime()
	local ServerTime = TimeUtil.GetServerTimeMS()
	return self.RespawnTime > ServerTime
end

function TeamMemberVM:UpdateRenderOpacity()
	self:UpdateSelectAuth()
	self:SetRenderOpacity((not self:GetOLStatMovie() and self.IsSelectSyncScene) and 1 or 0.6)
end

function TeamMemberVM:TimerUpdate()
	self:UpdateRenderOpacity()
	self:UpdateAliveStats()
end

---@param bAlive boolean | nil
function TeamMemberVM:UpdateAliveStats(bAlive)
	local bDead = (bAlive ~= nil and (not bAlive) or self:IsDead())
	local bDeadChanged = self.bDead ~= bDead
	self.bDead = bDead
	self:UpdateColor()

	self:UpdateShowRevivePanel()
	if bDeadChanged then
		self:UpdateRescureDeadline()
		self:SetReviving(self.bDead and self:ContainBuff(self.RevivingBuffID))
	end
end

function TeamMemberVM:UpdateColor()
	if self:IsDead() then
		self.NameColor = "B2B2B2FF"
	else
		self.NameColor = "FFFFFFFF"
	end
end

function TeamMemberVM:SetBGColor(BGColor)
	self.BGColor = BGColor
end
-------------------------------------------------------------------------------------------------------
--- ETC.
function TeamMemberVM:UpdateInMajorMap()
	local MajorVM = _G.RoleInfoMgr:FindRoleVM(MajorUtil.GetMajorRoleID(), true)
	local RoleVMSelf = _G.RoleInfoMgr:FindRoleVM(self.RoleID, true)
	local bOldInMajorMap = self.bInMajorMap
	if MajorVM and RoleVMSelf then
		self.bInMajorMap = MajorVM.RoleID == self.RoleID or ActorMgr:FindActorVM(self.EntityID) ~= nil or MajorVM.MapResID == RoleVMSelf.MapResID
	elseif self.IsEntourage then
		self.bInMajorMap =  true
	else
		self.bInMajorMap = false
	end

	if bOldInMajorMap ~= self.bInMajorMap then
		self:UpdateEntityData()
	end
end

function TeamMemberVM:SetIsPopUpMenu(IsPopUpMenu)
	self.IsPopUpMenu = IsPopUpMenu
end

function TeamMemberVM:SetIsSelected(IsSelected)
	self.IsSelected = IsSelected
end

function TeamMemberVM:UpdateSelectAuth()
	if self.RoleID and self.RoleID > 0 then
		self:SetEntityID(ActorUtil.GetEntityIDByRoleID(self.RoleID))
	end

	self:UpdateInMajorMap()

	local IsCanSelectStat = ActorUtil.IsInCanPlayerSelectedState(self.EntityID)
	self:SetOLStatStonePrison(not IsCanSelectStat and ActorMgr:FindActorVM(self.EntityID) ~= nil)
	self.IsSelectSyncScene = (self.IsEntourage or UCommonUtil.CheckSelectRange(self.RoleID)) and self.bInMajorMap and IsCanSelectStat
end

function TeamMemberVM:UpdateSelected(EntityID)
	-- nerver select an invalid entity
	self:SetIsSelected(self.EntityID == EntityID and EntityID and EntityID > 0)
end

function TeamMemberVM:SetIsCaptain(V)
	self.IsCaptain = V
end

function TeamMemberVM:UpdateShowRevivePanel()
	local bDead = self:IsDead()
	local bShow = false
	if bDead and not MajorUtil.IsMajorByRoleID(self.RoleID) then
		local Cfg = _G.TeamMgr.GetRescureSkillCfg(MajorUtil.GetMajorProfID())
		if Cfg then
			local SkillUtil = require("Utils/SkillUtil")
			if SkillUtil.IsMajorSkillLearned(Cfg.SkillID) then
				bShow = true
			end
		end
	end

	if MajorUtil.IsMajorDead() then
		bShow = false
	end

	self:SetShowRevivePanel(bShow)
end

function TeamMemberVM:SetShowRevivePanel(Value)
	self.bShowRevicePanel = Value
end

function TeamMemberVM:SetRescureSkillRemainCD(CD)
	self.CDRescureSkillRemain = (CD and CD > 0) and CD or 0
end

function TeamMemberVM:SetRescureSkillRemainCDPercent(Percent)
	self.CDPercentRescureSkillRemain = math.clamp(Percent or 0, 0, 1)
end

function TeamMemberVM:SetRescureDeadline(Deadline)
	self.RescureDeadline = Deadline
	self:UpdateRescureRemainTime()
end

function TeamMemberVM:UpdateRescureRemainTime()
	local t = (self.RescureDeadline or  0) - _G.TimeUtil.GetServerTime()
	if t < 0 then
		t = 0
	end

	if not self:IsDead() then
		t = 0
	end
	self.RescureRemainTime = math.ceil(t)
end

function TeamMemberVM:IsInRescureWaiting()
	return self.RescureRemainTime and self.RescureRemainTime > 0
end

function TeamMemberVM:IsDead()
	if self.EntityID then
		local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
		if Actor then
			-- 视野内玩家的死亡状态
			return ActorUtil.IsDeadState(self.EntityID) == true
		else
			-- 视野外玩家的死亡状态，由玩法协议同步
			return self:IsDeadByRespawnTime()
		end
	end
end

function TeamMemberVM:SetRevivingBuffID(BuffID)
	self.RevivingBuffID = BuffID
end

function TeamMemberVM:SetReviving(Value)
	self.bReviving = Value
end

function TeamMemberVM:ContainBuff(BuffID)
	if self.BuffVMList then
		return self.BuffVMList:ContainBuff(BuffID)
	end
end

-------------------------------------------------------------------------------------------------------
--- 在线状态
--[[
	23.02.20 v_hggzhang
	玩家在线状态，有优先级，后面大概率会拓展，先配置在代码里
	- Death 走 CS_SUB_CMD_TEAM_BROADCAST 协议
	- StonePrison 走战斗状态 不可选中
	- 走在线状态系统
		- NetUnstable
		- Movie
]]
local OLStat = {
	Death 			= 1,
	Offline			= 2,
	NetUnstable 	= 3,
	Movie 	 		= 4,
	StonePrison 	= 5,
}

local OLStatMap = {
	[OLStat.Death] = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Icon_Death_png.UI_Main_Team_Icon_Death_png'",
	[OLStat.NetUnstable] = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Icon_Wave_png.UI_Main_Team_Icon_Wave_png'",
	[OLStat.Offline] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/TargetInfo_Icon_Team_Offline_png.TargetInfo_Icon_Team_Offline_png'",
	[OLStat.Movie] = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Icon_Animation_png.UI_Main_Team_Icon_Animation_png'",
	[OLStat.StonePrison] = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Icon_Prison_png.UI_Main_Team_Icon_Prison_png'",
}

function TeamMemberVM:SetOLStatMovie(V)
	self.OLStatDict[OLStat.Movie] = V
	self:UpdOLStat()
end

function TeamMemberVM:GetOLStatMovie()
	return self:GetOLStat(OLStat.Movie)
end

function TeamMemberVM:SetOLStatNetUnstable(V)
	if self.RoleID == MajorUtil.GetMajorRoleID() then
		V = false
	end
	self.OLStatDict[OLStat.NetUnstable] = V
	self:UpdOLStat()
end

function TeamMemberVM:SetOLStatStonePrison(V)
	self.OLStatDict[OLStat.StonePrison] = V
	self:UpdOLStat()
end

function TeamMemberVM:SetIsOnline(V)
	if self.RoleID == MajorUtil.GetMajorRoleID() then
		V = true	-- always online
	end

	if self.bOnline ~= V then
		self.bOnline = V
		_G.FLOG_INFO("TeamMemberVM:SetIsOnline %s %s %s", V == true, self.RoleID, self.Name)
	end

	self.OLStatDict[OLStat.Offline] = not V
	self:UpdOLStat()
end

function TeamMemberVM:GetOLStat(Ty)
	return self.OLStatDict[Ty]
end

function TeamMemberVM:UpdOLStat()
	for k, v in ipairs(OLStatMap) do
		if self.OLStatDict[k] then
			self.HasOLStat = true
			self.OLStatIcon = v
			return
		end
	end

	self.HasOLStat = false
end

---@private
function TeamMemberVM:ClearOnlineStat()
	for k in ipairs(OLStatMap) do
		self.OLStatDict[k] = false
	end

	self.HasOLStat = false
	self.OLStatIcon = ""
end

function TeamMemberVM:SetShowRoll(Value)
	self.bShowRoll = Value
end

-------------------------------------------------------------------------------------------------------
--- 语音
function TeamMemberVM:SetVoiceMemberID( MemberID )
	self.VoiceMemberID = MemberID
end

function TeamMemberVM:SetIsSaying( Value )
	self.IsSaying = Value
end

function TeamMemberVM:SetMicSyncState(Value)
	local bChanged = self.MicSyncState ~= Value
	-- 0b01 for mic , 0b10 for speaker
	self.MicSyncState = Value

	-- print('sound value for [get]', self.Name, Value)
	if bChanged then
		_G.EventMgr:SendEvent(_G.EventID.TeamMemberMicSyncStateChanged, self, self.RoleID, self.MicSyncState)
	end
end

return TeamMemberVM
