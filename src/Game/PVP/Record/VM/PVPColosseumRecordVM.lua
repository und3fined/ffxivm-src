--
-- Author: peterxie
-- Date:
-- Description: 水晶冲突比赛结果
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PVPColosseumRecordItemVM = require("Game/PVP/Record/VM/PVPColosseumRecordItemVM")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")


---@class PVPColosseumRecordVM : UIViewModel
local PVPColosseumRecordVM = LuaClass(UIViewModel)

function PVPColosseumRecordVM:Ctor()
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

	-- 比赛结果列表
	self.LeftTeamRecordList = UIBindableList.New(PVPColosseumRecordItemVM)
	self.RightTeamRecordList = UIBindableList.New(PVPColosseumRecordItemVM)

	-- 主角奖励列表
	self.AwardList = UIBindableList.New(ItemVM)
	-- 主角是否消极比赛
	self.PlayNegative = false

    -- 拦截快速点击多次点赞
	self.CanLike = true

	-- 是否获得比赛结果
	self.HasSetGameResult = false
end

function PVPColosseumRecordVM:Reset()
	self.ShowData = false
	self.CanLike = true
	self.PlayNegative = false
	self.HasSetGameResult = false
end

---更新比赛结果
function PVPColosseumRecordVM:UpdateVM(IsWinner, ExitEndTime, PvPColosseumGameResultRsp)
	self.SceneInstID = PvPColosseumGameResultRsp.SceneInstID
	self.PlayResult = IsWinner
	self.PlayResultText = IsWinner and _G.LSTR(810031) or _G.LSTR(810032)
	self.ExitEndTime = ExitEndTime

	local TotalTime = PvPColosseumGameResultRsp.Duration + PvPColosseumGameResultRsp.DurationDelay
	TotalTime = math.floor(TotalTime / 1000) -- 后台下发的是毫秒
	self.PlayTime = _G.DateTimeTools.TimeFormat(TotalTime, "mm:ss")

	local PvPColosseumTeam1 = PvPColosseumGameResultRsp.Teams[1]
	local PvPColosseumTeam2 = PvPColosseumGameResultRsp.Teams[2]
	-- 左边固定是蓝方，右边固定是红方，我方队伍为蓝方，我方固定在左边
	local MyTeamIndex = _G.PVPColosseumMgr:GetTeamIndex()
	local EnemyTeamIndex = _G.PVPColosseumMgr.GetOtherTeamIndex(MyTeamIndex)
	local MyTeamData
	local EnemyTeamData
    if MyTeamIndex == PVPColosseumDefine.ColosseumTeam.COLOSSEUM_TEAM_1 then
		MyTeamData = PvPColosseumTeam1
		EnemyTeamData = PvPColosseumTeam2
	else
		MyTeamData = PvPColosseumTeam2
		EnemyTeamData = PvPColosseumTeam1
	end
	self:UpdateTeamData(MyTeamData, 1)
	self:UpdateTeamData(EnemyTeamData, 2)

	for _, PvPColosseumTeamMember in ipairs(MyTeamData.Members) do
		PvPColosseumTeamMember.TeamIndex = MyTeamIndex -- 增加队伍索引字段，用于区分玩家所属队伍
	end
	for _, PvPColosseumTeamMember in ipairs(EnemyTeamData.Members) do
		PvPColosseumTeamMember.TeamIndex = EnemyTeamIndex
	end
	self.LeftTeamRecordList:UpdateByValues(MyTeamData.Members)
	self.RightTeamRecordList:UpdateByValues(EnemyTeamData.Members)

	self:UpdateTeamAward(MyTeamData)
end

---更新队伍数据
function PVPColosseumRecordVM:UpdateTeamData(PvPColosseumTeam, SideIndex)
	local ProgressPercent = PvPColosseumTeam.ProgressPercent / 10 -- 协议下发的是千分比
	local StrPercent = string.format("%.1f%%", ProgressPercent)
	if ProgressPercent == 100 or ProgressPercent == 0 then
		-- 不显示小数点
		StrPercent = string.format("%d%%", ProgressPercent)
	end
	self["Goal_Team"..SideIndex] = StrPercent

	local TotalKillCount = 0
	local TotalDeadCount = 0
	local TotalAssistCount = 0
	for _, PvPColosseumTeamMember in ipairs(PvPColosseumTeam.Members) do
		local PvPColosseumTeamMemberBtlResult = PvPColosseumTeamMember.BtlResult
		TotalKillCount = TotalKillCount + PvPColosseumTeamMemberBtlResult.K
		TotalDeadCount = TotalDeadCount + PvPColosseumTeamMemberBtlResult.D
		TotalAssistCount = TotalAssistCount + PvPColosseumTeamMemberBtlResult.A
	end

	self["TotalKillCount_Team"..SideIndex] = TotalKillCount
	self["TotalDeadCount_Team"..SideIndex] = TotalDeadCount
	self["TotalAssistCount_Team"..SideIndex] = TotalAssistCount
end

---更新奖励信息
function PVPColosseumRecordVM:UpdateTeamAward(PvPColosseumTeam)
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
function PVPColosseumRecordVM:SwitchShowData()
	self.ShowData = not self.ShowData
end

---检查是否能点赞
function PVPColosseumRecordVM:GetCanLike()
	return self.CanLike
end

---设置是否能点赞
function PVPColosseumRecordVM:SetCanLike(CanLike)
	self.CanLike = CanLike
end

---点赞玩家
function PVPColosseumRecordVM:LikeRole(LikeRoleID)
	local RecordList = self.LeftTeamRecordList
	for i = 1, RecordList:Length() do
		local ItemVM = RecordList:Get(i)
		ItemVM:UpdateLikeData(LikeRoleID)
	end

	RecordList = self.RightTeamRecordList
	for i = 1, RecordList:Length() do
		local ItemVM = RecordList:Get(i)
		ItemVM:UpdateLikeData(LikeRoleID)
	end
end

---收到点赞
function PVPColosseumRecordVM:GetLike(LikeCount)
	local RecordList = self.LeftTeamRecordList
	local ItemVM = RecordList:Find(function(VM) return VM.RoleID == MajorUtil.GetMajorRoleID() end)
	if ItemVM then
		ItemVM:UpdateLikeData(MajorUtil.GetMajorRoleID(), LikeCount)
	end
end

---隐藏玩家点赞按钮
function PVPColosseumRecordVM:HideLike(IsMyTeam, RoleID)
	local RecordList = IsMyTeam and self.LeftTeamRecordList or self.RightTeamRecordList
	local ItemVM = RecordList:Find(function(VM) return VM.RoleID == RoleID end)
	if ItemVM then
		ItemVM:HideBtnLike()
	end
end

---断线重连刷新全部点赞按钮
function PVPColosseumRecordVM:UpdateAllLikeBtn()
	local LeftTeamList = self.LeftTeamRecordList
	for i = 1, LeftTeamList:Length() do
		local ItemVM = LeftTeamList:Get(i)
		ItemVM:UpdateBtnLikeVisible()
	end

	local RightTeamList = self.RightTeamRecordList
	for i = 1, RightTeamList:Length() do
		local ItemVM = RightTeamList:Get(i)
		ItemVM:UpdateBtnLikeVisible()
	end
end

return PVPColosseumRecordVM