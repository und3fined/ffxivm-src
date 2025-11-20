--
-- Author: lightpaw_Carl
-- Date:
-- Description: 水晶冲突比赛数据
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")

local IconLikePathMap = {
	Major = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPRecord_Icon_Good2_png.UI_PVPRecord_Icon_Good2_png'",
	Other = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPRecord_Icon_Good3_png.UI_PVPRecord_Icon_Good3_png'"
}

local PVPTeamMgr = _G.PVPTeamMgr

---@class PVPColosseumRecordInsideItemVM
local PVPColosseumRecordInsideItemVM = LuaClass(UIViewModel)

function PVPColosseumRecordInsideItemVM:Ctor()
	self.RoleID = 0
	self.Name = "" -- 玩家名字
	self.ProfID = 0 -- 玩家职业
	self.IsMajor = false -- 是否主角自己
	self.TeamIndex = 0 -- 队伍索引，用于区分玩家所属队伍
	self.PVPRankID = 0 -- 段位

	-- 战斗战绩 --
	self.KillCount = 0 -- 击杀数
	self.DeadCount = 0 -- 死亡数
	self.AssistCount = 0 -- 助攻数
	self.EscortTime = "" -- 押运水晶时长

	-- 战斗数据 --
	self.Damage = 0 -- 伤害量
	self.Damaged = 0 -- 受伤量
	self.Heal = 0 -- 治疗量

	-- 点赞相关 --
	self.ShowLikeCount = false -- 是否显示点赞数
	self.LikeCount = 0 -- 点赞数
	self.IconLikePath = ""
	self.ShowIconLike = false -- 是否显示已点赞图标
	self.ShowBtnLike = false -- 是否显示点赞按钮
end

function UIViewModel:IsEqualVM(Value)
	return Value and self.RoleID == Value.RoleID
end

function PVPColosseumRecordInsideItemVM:UpdateVM(Value)
	local PvPColosseumTeamMember = Value

	self.RoleID = PvPColosseumTeamMember.RoleID
	self.PVPRankID = Value.PVPRankID or 0
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(self.RoleID)
	if RoleVM then
		self.ProfID = RoleVM.Prof
		self.Name = RoleVM.Name
	end
	self.IsMajor = MajorUtil.GetMajorRoleID() == self.RoleID
	self.TeamIndex = PvPColosseumTeamMember.TeamIndex
	self.KillCount = PvPColosseumTeamMember.K
	self.DeadCount = PvPColosseumTeamMember.D
	self.AssistCount = PvPColosseumTeamMember.A
	local TotalTime = math.ceil(PvPColosseumTeamMember.EscortTime / 1000)
	self.EscortTime = _G.DateTimeTools.TimeFormat(TotalTime, "mm:ss")

	self.Damage = PvPColosseumTeamMember.Output
	self.Damaged = PvPColosseumTeamMember.Survival
	self.Heal = PvPColosseumTeamMember.Cure

	self.IconLikePath = self.IsMajor and IconLikePathMap["Major"] or IconLikePathMap["Other"]
	self.ShowLikeCount = false
	self.LikeCount = 0
	self.ShowIconLike = false
	self.ShowBtnLike = (not self.IsMajor) and (self.ShowIconLike ~= true) and (PVPTeamMgr:FindMemberVMByRoleID(self.RoleID) ~= nil)
end

---更新点赞按钮状态
function PVPColosseumRecordInsideItemVM:UpdateLikeData(LikeRoleID, LikeCount)
	if LikeRoleID == self.RoleID then
		self.ShowIconLike = true

		if self.IsMajor then
			self.LikeCount = LikeCount
			self.ShowLikeCount = true
		end
	end

	self.ShowBtnLike = false
end

function PVPColosseumRecordInsideItemVM:HideBtnLike()
	self.ShowBtnLike = false
end

function PVPColosseumRecordInsideItemVM:UpdateBtnLikeVisible()
	if PVPTeamMgr == nil then return end

	local SceneMemberVM = PVPTeamMgr:FindMemberVMByRoleID(self.RoleID)
	self.ShowBtnLike = (not self.IsMajor) and (self.ShowIconLike ~= true) and (SceneMemberVM ~= nil)
end

return PVPColosseumRecordInsideItemVM