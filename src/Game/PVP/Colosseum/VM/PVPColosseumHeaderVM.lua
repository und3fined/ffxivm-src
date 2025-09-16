--
-- Author: peterxie
-- Date:
-- Description: 战场态势
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ColosseumTeam = PVPColosseumDefine.ColosseumTeam
local ColosseumCrystalState = PVPColosseumDefine.ColosseumCrystalState
local ColosseumHeaderCrystalState = PVPColosseumDefine.ColosseumHeaderCrystalState
local ColosseumHeaderCrystalIcon = PVPColosseumDefine.ColosseumHeaderCrystalIcon
local ColosseumHeaderCheckState = PVPColosseumDefine.ColosseumHeaderCheckState
local ColosseumHeaderCheckIcon = PVPColosseumDefine.ColosseumHeaderCheckIcon


---@class PVPColosseumHeaderVM : UIViewModel
local PVPColosseumHeaderVM = LuaClass(UIViewModel)

function PVPColosseumHeaderVM:Ctor()
	-- 是否显示战场态势面板。目前水晶冲突主界面没有VM，变量先放这里，后面主界面功能多了，再独立出来
	self.HeaderPanelVisible = true

	-- 当前阶段结束时间戳
	self.EndTime = 0
	-- 是否显示加时赛
	self.IsSuddenDeath = false

	-- 水晶信息 --
	-- 水晶位置
	self.CrystalPos = 0 -- 原始数据
	-- 水晶UI状态
	self.CrystalState = 0 ---@type ColosseumHeaderCrystalState
	self.IconCrystal = "" -- 水晶图标
	self.IconCrystalLeft = "" -- 水晶左方向图标
	self.IconCrystalRight = "" -- 水晶右方向图标
	self.IconCrystalBreaking = "" -- 水晶突破图标

	-- 双方队伍信息 --
	-- 水晶最长推进进度
	self.Goal_Team1 = 0 -- 原始数据
	self.Goal_Team2 = 0
	-- 水晶范围内人数（手游未使用）
	self.CountInRange_Team1 = 0
	self.CountInRange_Team2 = 0
	-- 检查点状态
	self.CheckState_Team1 = 0 -- 原始数据
	self.CheckState_Team2 = 0
	self.IconCheckState_Team1 = ""
	self.IconCheckState_Team2 = ""
	-- 检查点突破进度
	self.CheckProgress_Team1 = 0 -- 原始数据
	self.CheckProgress_Team2 = 0
	self.StrCheckProgress_Team1 = ""
	self.StrCheckProgress_Team2 = ""
	self.VisibleCheckProgress_Team1 = false
	self.VisibleCheckProgress_Team2 = false

	-- 加时赛信息 --
	-- 劣势方队伍索引
	self.OvertimeBehindTeamIndex = 0
	-- 劣势方获胜需要达到的推进进度
	self.OvertimeBehindTargetProgress = 0
end

function PVPColosseumHeaderVM:Reset()
	self.HeaderPanelVisible = true

	self.CrystalPos = 0

	self.Goal_Team1 = 0
	self.Goal_Team2 = 0
	self.CheckState_Team1 = 0
	self.CheckState_Team2 = 0
	self.CheckProgress_Team1 = 0
	self.CheckProgress_Team2 = 0

	self.OvertimeBehindTeamIndex = 0
	self.OvertimeBehindTargetProgress = 0
end

function PVPColosseumHeaderVM:BattleStart()
	self:Reset()
	self:UpdateVM()
end

---战场倒计时
function PVPColosseumHeaderVM:SetCountDownTime(EndTime, IsSuddenDeath)
	self.EndTime = EndTime
	self.IsSuddenDeath = IsSuddenDeath
end

---设置加时赛劣势方信息
function PVPColosseumHeaderVM:SetOvertimeBehindInfo(BehindTeamIndex, BehindTargetProgress)
	self.OvertimeBehindTeamIndex = BehindTeamIndex
	self.OvertimeBehindTargetProgress = BehindTargetProgress
end

function PVPColosseumHeaderVM:SetHeaderPanelVisible(Visible)
	self.HeaderPanelVisible = Visible
end


function PVPColosseumHeaderVM:UpdateVM()
	self:UpdateCrystal()
	self:UpdateTeam()
end

---更新水晶信息
function PVPColosseumHeaderVM:UpdateCrystal()
	local PVPColosseumMgr = _G.PVPColosseumMgr

	self.CrystalPos = PVPColosseumMgr:GetCrystalReachProgress()

	local IsTeamB = (PVPColosseumMgr:GetTeamIndex() == ColosseumTeam.COLOSSEUM_TEAM_2)

	-- 计算水晶UI状态
	local crstate = ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_NEUTRAL
	local state = PVPColosseumMgr:GetCrystalState()
	if (state == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_INACTIVE) then
		crstate = ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_INACTIVE

	elseif (state == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_DEADLOCKED) then
		crstate = ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_DEADLOCK

	elseif (state == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY
		or state == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_LONGEST) then
		crstate = IsTeamB and ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB or ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA

	elseif (state == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_CHECK_POINT_BREAKING) then
		crstate = IsTeamB and ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB_CHECK or ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA_CHECK

	elseif (state == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY
		or state == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_LONGEST) then
		crstate = IsTeamB and ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA or ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB

	elseif (state == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_CHECK_POINT_BREAKING) then
		crstate = IsTeamB and ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA_CHECK or ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB_CHECK
	end

	self.CrystalState = crstate
	--print("state", state, "crstate", crstate)

	-- 水晶UI状态图标这块逻辑比较复杂（后面可能换成动效），这里参考端游的实现
	local CrystalIcon = ""
	local LeftIcon = ""
	local RightIcon = ""
	local BreakingIcon = ""

	if crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_INACTIVE then
		CrystalIcon = ColosseumHeaderCrystalIcon.Default

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_NEUTRAL then
		CrystalIcon = ColosseumHeaderCrystalIcon.Wait

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_DEADLOCK then
		CrystalIcon = ColosseumHeaderCrystalIcon.DeadLock

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA then
		CrystalIcon = IsTeamB and ColosseumHeaderCrystalIcon.Red or ColosseumHeaderCrystalIcon.Blue
		RightIcon = IsTeamB and ColosseumHeaderCrystalIcon.Red_Right or ColosseumHeaderCrystalIcon.Blue_Right

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA_CHECK then
		CrystalIcon = IsTeamB and ColosseumHeaderCrystalIcon.Red or ColosseumHeaderCrystalIcon.Blue
		BreakingIcon = IsTeamB and ColosseumHeaderCrystalIcon.Red_Light or ColosseumHeaderCrystalIcon.Blue_Light

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB then
		CrystalIcon = IsTeamB and ColosseumHeaderCrystalIcon.Blue or ColosseumHeaderCrystalIcon.Red
		LeftIcon = IsTeamB and ColosseumHeaderCrystalIcon.Blue_Left or ColosseumHeaderCrystalIcon.Red_Left

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB_CHECK then
		CrystalIcon = IsTeamB and ColosseumHeaderCrystalIcon.Blue or ColosseumHeaderCrystalIcon.Red
		BreakingIcon = IsTeamB and ColosseumHeaderCrystalIcon.Blue_Light or ColosseumHeaderCrystalIcon.Red_Light
	end

	self.IconCrystal = CrystalIcon
	self.IconCrystalLeft = LeftIcon
	self.IconCrystalRight = RightIcon
	self.IconCrystalBreaking = BreakingIcon
end

---更新双方队伍信息
function PVPColosseumHeaderVM:UpdateTeam()
	local PVPColosseumMgr = _G.PVPColosseumMgr

	for teamIndex = 1, 2 do
		local Goal = PVPColosseumMgr:GetCrystalLongestReachProgress(teamIndex)
		self["Goal_Team"..teamIndex] = Goal
		self["CountInRange_Team"..teamIndex] = PVPColosseumMgr:GetCrystalCountInRange(teamIndex)

		local CheckState = ColosseumHeaderCheckState.PVPCOLOSSEUM_HEADER_CHECK_STATE_DEFAULT
		if PVPColosseumMgr:IsDefenseCheckPointBreaking(teamIndex) then
			CheckState = ColosseumHeaderCheckState.PVPCOLOSSEUM_HEADER_CHECK_STATE_ATTACK
		elseif PVPColosseumMgr:IsDefenseCheckPointBroken(teamIndex) then
			CheckState = ColosseumHeaderCheckState.PVPCOLOSSEUM_HEADER_CHECK_STATE_BREAK
		end
		self["CheckState_Team"..teamIndex] = CheckState

		local bIsMyTeam = PVPColosseumMgr:IsMyTeamByTeamIndex(teamIndex)
		local CheckIcon = ""
		if CheckState == ColosseumHeaderCheckState.PVPCOLOSSEUM_HEADER_CHECK_STATE_ATTACK
			or CheckState == ColosseumHeaderCheckState.PVPCOLOSSEUM_HEADER_CHECK_STATE_DEFAULT then
			CheckIcon = bIsMyTeam and ColosseumHeaderCheckIcon.Blue_Attack or ColosseumHeaderCheckIcon.Red_Attack
		elseif CheckState == ColosseumHeaderCheckState.PVPCOLOSSEUM_HEADER_CHECK_STATE_BREAK then
			CheckIcon = bIsMyTeam and ColosseumHeaderCheckIcon.Blue_Break or ColosseumHeaderCheckIcon.Red_Break
		end
		self["IconCheckState_Team"..teamIndex] = CheckIcon

		local enemyTeamIndex = PVPColosseumMgr.GetOtherTeamIndex(teamIndex)
		local CheckProgress = PVPColosseumMgr:GetOffenseCheckPointProgress(enemyTeamIndex)
		self["CheckProgress_Team"..teamIndex] = CheckProgress
		self["StrCheckProgress_Team"..teamIndex] = string.format("%d%%", math.floor(CheckProgress / 10))
		local CheckProgressVisible = CheckProgress > 0
		-- 突破进度大于0，且未完全突破
		if CheckState == ColosseumHeaderCheckState.PVPCOLOSSEUM_HEADER_CHECK_STATE_BREAK then
			CheckProgressVisible = false
		end
		self["VisibleCheckProgress_Team"..teamIndex] = CheckProgressVisible
	end
end


return PVPColosseumHeaderVM