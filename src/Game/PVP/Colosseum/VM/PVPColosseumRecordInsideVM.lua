--
-- Author: lightpaw_Carl
-- Date:
-- Description: 水晶冲突比赛实时战绩
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PVPColosseumRecordInsideItemVM = require("Game/PVP/Colosseum/VM/PVPColosseumRecordInsideItemVM")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")


---@class PVPColosseumRecordInsideVM : UIViewModel
local PVPColosseumRecordInsideVM = LuaClass(UIViewModel)

function PVPColosseumRecordInsideVM:Ctor()
	-- 游戏实例ID
	self.SceneInstID = 0
	-- 游戏结果
	self.PlayResult = true
	self.PlayResultText = ""
	-- 游戏持续时长
	self.PlayTime = ""
	-- 退出竞技场的倒计时
	self.ExitEndTime = 0

	-- 水晶推进进度
	self.Goal_Team1 = ""
	self.Goal_Team2 = ""
	-- 总终结数
	self.TotalKillCount_Team1 = 0
	self.TotalKillCount_Team2 = 0
	-- 总死亡数
	self.TotalDeadCount_Team1 = 0
	self.TotalDeadCount_Team2 = 0
	-- 总助攻数
	self.TotalAssistCount_Team1 = 0
	self.TotalAssistCount_Team2 = 0

	-- 显示战绩还是数据，默认显示战绩
	self.ShowData = false

	-- 实时比赛结果列表
	self.LeftTeamRecordInsideList = UIBindableList.New(PVPColosseumRecordInsideItemVM)
	self.RightTeamRecordInsideList = UIBindableList.New(PVPColosseumRecordInsideItemVM)

	-- 主角奖励列表
	self.AwardList = UIBindableList.New(ItemVM)
	-- 主角是否消极比赛
	self.PlayNegative = false

    -- 拦截快速点击多次点赞
	self.CanLike = true

	-- 是否获得比赛结果
	self.HasSetGameResult = false
end

function PVPColosseumRecordInsideVM:Reset()
	self.ShowData = false
	self.CanLike = true
	self.PlayNegative = false
	self.HasSetGameResult = false
	self.Teams = nil
end

---@type 更新比赛实时数据
function PVPColosseumRecordInsideVM:UpdateVM(RecordInsideRsp)
	self:SetCompleteTeamsData(RecordInsideRsp)
	if self.Teams == nil then
		return
	end

	-- 左边固定是蓝方，右边固定是红方，我方队伍为蓝方，我方固定在左边
	local MyTeamIndex = _G.PVPColosseumMgr:GetTeamIndex()
	local EnemyTeamIndex = _G.PVPColosseumMgr.GetOtherTeamIndex(MyTeamIndex)

	local MyTeamData
	local EnemyTeamData
    if MyTeamIndex == PVPColosseumDefine.ColosseumTeam.COLOSSEUM_TEAM_1 then
		MyTeamData = self.Teams.MyTeam
		EnemyTeamData = self.Teams.EnemyTeam
	else
		MyTeamData = self.Teams.EnemyTeam
		EnemyTeamData = self.Teams.MyTeam
	end

	self:UpdateTeamData(MyTeamData, 1)
	self:UpdateTeamData(EnemyTeamData, 2)

	for _, PvPColosseumTeamMember in ipairs(MyTeamData.MemberRecordList) do
		PvPColosseumTeamMember.TeamIndex = MyTeamIndex -- 增加队伍索引字段，用于区分玩家所属队伍
	end
	for _, PvPColosseumTeamMember in ipairs(EnemyTeamData.MemberRecordList) do
		PvPColosseumTeamMember.TeamIndex = EnemyTeamIndex
	end
	self.LeftTeamRecordInsideList:UpdateByValues(MyTeamData.MemberRecordList)
	self.RightTeamRecordInsideList:UpdateByValues(EnemyTeamData.MemberRecordList)

	--self:UpdateTeamAward(MyTeamData)
end

-- 获取完整的队伍数据
function PVPColosseumRecordInsideVM:SetCompleteTeamsData(RecordInsideRsp)
	-- 数据转换处理下
	local NewMemberList = {}
	for _, MemberItem in ipairs(RecordInsideRsp) do
		local NewRecordItem = {
			RoleID = MemberItem.role_id,
			K = MemberItem.kill, --击杀
			D = MemberItem.dead,-- 死亡
			A = MemberItem.assist, --助攻
			Cure = MemberItem.healing, --治疗
			Survival = MemberItem.hurt, --生存(受伤量)
			Output = MemberItem.damage, --输出
			EscortTime = MemberItem.push_time, --押运(押运水晶时间)
			TeamID = MemberItem.team_id, -- 队伍ID
			Negative = false 
		}
		table.insert(NewMemberList, NewRecordItem)
	end

	self.Teams = {
		MyTeam = {MemberRecordList = {}, ProgressPercent = 0},
		EnemyTeam = {MemberRecordList = {}, ProgressPercent = 0},
	}

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local RecordItem = table.find_item(NewMemberList, MajorRoleID, "RoleID")
	local MyTeamID = RecordItem.TeamID
	for _, NewMember in pairs(NewMemberList) do
		-- 我方队伍
		if NewMember.TeamID == MyTeamID then
			local PlayerMemberVMList = _G.PVPTeamMgr:GetPVPTeamVM():GetTeamMemberList()
			if PlayerMemberVMList then
				local MemberVMItem = table.find_item(PlayerMemberVMList, NewMember.RoleID, "RoleID")
				if MemberVMItem then
					NewMember.PVPRankID = MemberVMItem.PVPRankID
				end
			end
			table.insert(self.Teams.MyTeam.MemberRecordList, NewMember)
		else
			-- 敌方队伍
			local EnemyMemberVMList = _G.PVPTeamMgr:GetPVPTeamVM():GetEnemyMemberList()
			if EnemyMemberVMList then
				local MemberVMItem = table.find_item(EnemyMemberVMList, NewMember.RoleID, "RoleID")
				if MemberVMItem then
					NewMember.PVPRankID = MemberVMItem.PVPRankID
				end
			end
			table.insert(self.Teams.EnemyTeam.MemberRecordList, NewMember)
		end
	end

	-- for i = 1, PlayerMemberVMList:Length() do
	-- 	local MemberVM = PlayerMemberVMList:Get(i) ---@type TeamMemberVM
	-- 	if MemberVM and MemberVM.RoleID then
	-- 		local RecordItem = table.find_item(NewMemberList, MyTeamID, "TeamID")
	-- 		if RecordItem then
	-- 			RecordItem.PVPRankID = MemberVM.PVPRankID
	-- 			table.insert(self.Teams.MyTeam.MemberRecordList, RecordItem)
	-- 		end
	-- 	end
	-- end

	-- -- 敌方队伍
	-- local EnemyMemberVMList = _G.PVPTeamMgr:GetPVPTeamVM():GetEnemyMemberList()
	-- for i = 1, EnemyMemberVMList:Length() do
	-- 	local MemberVM = EnemyMemberVMList:Get(i) ---@type TeamMemberVM
	-- 	if MemberVM and MemberVM.RoleID then
	-- 		local RecordItem = table.find_item(NewMemberList, MemberVM.RoleID, "RoleID")
	-- 		if RecordItem then
	-- 			RecordItem.PVPRankID = MemberVM.PVPRankID
	-- 			table.insert(self.Teams.EnemyTeam.MemberRecordList, RecordItem)
	-- 		end
	-- 	end
	-- end
	-- else
	-- 	-- 我方队伍
	-- 	local PlayerMemberVMList = self.Teams.MyTeam and self.Teams.MyTeam.MemberRecordList
	-- 	if PlayerMemberVMList then
	-- 		for _, PlayerMemberVM in pairs(PlayerMemberVMList) do
	-- 			local RecordItem = table.find_item(NewMemberList, PlayerMemberVM.RoleID, "RoleID")
	-- 			local PVPRankID = PlayerMemberVM.PVPRankID
	-- 			--PlayerMemberVM = table.deepcopy(RecordItem)
	-- 			--PlayerMemberVM.PVPRankID = PVPRankID
	-- 			PlayerMemberVM.RoleID = RecordItem.RoleID
	-- 			PlayerMemberVM.K = RecordItem.K
	-- 			PlayerMemberVM.D = RecordItem.D
	-- 			PlayerMemberVM.A = RecordItem.A
	-- 			PlayerMemberVM.Cure = RecordItem.Cure
	-- 			PlayerMemberVM.Survival = RecordItem.Survival
	-- 			PlayerMemberVM.Output = RecordItem.Output
	-- 			PlayerMemberVM.EscortTime = RecordItem.EscortTime
	-- 			PlayerMemberVM.Negative = RecordItem.Negative 
	-- 		end
	-- 	end
	
	-- 	-- 敌方队伍
	-- 	local EnemyMemberVMList = self.Teams.EnemyTeam and self.Teams.EnemyTeam.MemberRecordList
	-- 	if EnemyMemberVMList then
	-- 		for _, PlayerMemberVM in pairs(EnemyMemberVMList) do
	-- 			local RecordItem = table.find_item(NewMemberList, PlayerMemberVM.RoleID, "RoleID")
	-- 			local PVPRankID = PlayerMemberVM.PVPRankID
	-- 			PlayerMemberVM = table.deepcopy(RecordItem)
	-- 			PlayerMemberVM.PVPRankID = PVPRankID
	-- 		end
	-- 	end
	-- end
end

---更新队伍数据
function PVPColosseumRecordInsideVM:UpdateTeamData(PvPColosseumTeam, SideIndex)
	local Goal = _G.PVPColosseumMgr:GetCrystalLongestReachProgress(SideIndex)
	local ProgressPercent = Goal / 10 -- 协议下发的是千分比
	local StrPercent = string.format("%.1f%%", ProgressPercent)
	if ProgressPercent == 100 or ProgressPercent == 0 then
		-- 不显示小数点
		StrPercent = string.format("%d%%", ProgressPercent)
	end
	self["Goal_Team"..SideIndex] = StrPercent

	local TotalKillCount = 0
	local TotalDeadCount = 0
	local TotalAssistCount = 0
	for _, PvPColosseumTeamMember in ipairs(PvPColosseumTeam.MemberRecordList) do
		TotalKillCount = TotalKillCount + PvPColosseumTeamMember.K
		TotalDeadCount = TotalDeadCount + PvPColosseumTeamMember.D
		TotalAssistCount = TotalAssistCount + PvPColosseumTeamMember.A
	end

	self["TotalKillCount_Team"..SideIndex] = TotalKillCount
	self["TotalDeadCount_Team"..SideIndex] = TotalDeadCount
	self["TotalAssistCount_Team"..SideIndex] = TotalAssistCount
end

---更新奖励信息
function PVPColosseumRecordInsideVM:UpdateTeamAward(PvPColosseumTeam)
	local ItemList = {}

	-- 每个玩家获得奖励可以不同，比如经验类奖励涉及等级上限
	local RewardRoleExp = 0
	local RewardSeriesExp = 0
	for _, PvPColosseumTeamMember in ipairs(PvPColosseumTeam.Members) do
		if PvPColosseumTeamMember.RoleID == MajorUtil.GetMajorRoleID() then
			RewardRoleExp = PvPColosseumTeamMember.RewardRoleExp
			RewardSeriesExp = PvPColosseumTeamMember.RewardSeriesExp
			local PvPColosseumTeamMemberBtlResult = PvPColosseumTeamMember.BtlResult
			self.PlayNegative = PvPColosseumTeamMemberBtlResult.Negative
			break
		end
	end

	-- 升级经验
	if RewardRoleExp > 0 then
		local Item = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP, RewardRoleExp)
		table.insert(ItemList, Item)
	end

	-- 系列赛经验
	if RewardSeriesExp > 0 then
		local Item = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_SERIES_EXP, RewardSeriesExp)
		table.insert(ItemList, Item)
	end

	-- 狼印战绩
	if PvPColosseumTeam.RewardPvPToken and PvPColosseumTeam.RewardPvPToken > 0 then
		local Item = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_WOLF_EXP, PvPColosseumTeam.RewardPvPToken)
		table.insert(ItemList, Item)
	end

	-- 诗学神典石
	if PvPColosseumTeam.RewardPoem and PvPColosseumTeam.RewardPoem > 0 then
		local Item = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_POEM, PvPColosseumTeam.RewardPoem)
		table.insert(ItemList, Item)
	end

	-- 金币
	if PvPColosseumTeam.RewardGold and PvPColosseumTeam.RewardGold > 0 then
		local Item = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE, PvPColosseumTeam.RewardGold)
		table.insert(ItemList, Item)
	end

	self.AwardList:UpdateByValues(ItemList)
end

---切换显示战绩还是数据
function PVPColosseumRecordInsideVM:SwitchShowData()
	self.ShowData = not self.ShowData
end

---检查是否能点赞
function PVPColosseumRecordInsideVM:GetCanLike()
	return self.CanLike
end

---设置是否能点赞
function PVPColosseumRecordInsideVM:SetCanLike(CanLike)
	self.CanLike = CanLike
end

---点赞玩家
function PVPColosseumRecordInsideVM:LikeRole(LikeRoleID)
	local RecordList = self.LeftTeamRecordInsideList
	for i = 1, RecordList:Length() do
		local ItemVM = RecordList:Get(i)
		ItemVM:UpdateLikeData(LikeRoleID)
	end

	RecordList = self.RightTeamRecordInsideList
	for i = 1, RecordList:Length() do
		local ItemVM = RecordList:Get(i)
		ItemVM:UpdateLikeData(LikeRoleID)
	end
end

---收到点赞
function PVPColosseumRecordInsideVM:GetLike(LikeCount)
	local RecordList = self.LeftTeamRecordInsideList
	local ItemVM = RecordList:Find(function(VM) return VM.RoleID == MajorUtil.GetMajorRoleID() end)
	if ItemVM then
		ItemVM:UpdateLikeData(MajorUtil.GetMajorRoleID(), LikeCount)
	end
end

---隐藏玩家点赞按钮
function PVPColosseumRecordInsideVM:HideLike(IsMyTeam, RoleID)
	local RecordList = IsMyTeam and self.LeftTeamRecordInsideList or self.RightTeamRecordInsideList
	local ItemVM = RecordList:Find(function(VM) return VM.RoleID == RoleID end)
	if ItemVM then
		ItemVM:HideBtnLike()
	end
end

---断线重连刷新全部点赞按钮
function PVPColosseumRecordInsideVM:UpdateAllLikeBtn()
	local LeftTeamList = self.LeftTeamRecordInsideList
	for i = 1, LeftTeamList:Length() do
		local ItemVM = LeftTeamList:Get(i)
		ItemVM:UpdateBtnLikeVisible()
	end

	local RightTeamList = self.RightTeamRecordInsideList
	for i = 1, RightTeamList:Length() do
		local ItemVM = RightTeamList:Get(i)
		ItemVM:UpdateBtnLikeVisible()
	end
end

return PVPColosseumRecordInsideVM