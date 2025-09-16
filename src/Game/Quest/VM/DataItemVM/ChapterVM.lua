---
--- Author: lydianwang
--- DateTime: 2021-09-07
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MajorUtil = require("Utils/MajorUtil")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")
local DialogueUtil = require("Utils/DialogueUtil")
local MapEditDataMgr = require("Game/PWorld/MapEditDataMgr")
local ItemUtil = require("Utils/ItemUtil")
local CommonUtil = require("Utils/CommonUtil")
local TimeUtil = require("Utils/TimeUtil")

local ItemVM = require("Game/Item/ItemVM")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local QuestRewardItemVM = require("Game/Quest/VM/DataItemVM/QuestRewardItemVM")
local QuestTargetVM = require("Game/Quest/VM/DataItemVM/QuestTargetVM")

local LootMappingCfg = require("TableCfg/LootMappingCfg")
local MapCfg = require("TableCfg/MapCfg")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS
local ACCEPT_TYPE = ProtoRes.QUEST_ACCEPT_TYPE
local CONNECT_TYPE = ProtoRes.target_connect_type
local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
local QUEST_TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE

local LSTR = _G.LSTR
local QuestMgr = nil
local QuestMainVM = nil
local PWorldMgr = nil
local QuestLogVM = nil

local AdapterCategoryType = {
	MatchNone = 0,
	MatchQuestName = 1, -- 搜索匹配任务名字
	MatchQuestDesc = 2, -- 搜索匹配任务描述
}

---@class ChapterVM : UIViewModel
local ChapterVM = LuaClass(UIViewModel)

function ChapterVM:Ctor()
	QuestMgr = _G.QuestMgr
	QuestMainVM = _G.QuestMainVM
	PWorldMgr = _G.PWorldMgr
	QuestLogVM = QuestMainVM.QuestLogVM
	self:Reset()
end

function ChapterVM:Reset()
	self.ChapterID = nil
	self.QuestID = nil

	-- 读表属性 --
	self.Name = nil
	self.Type = nil
	self.GenreID = nil
	self.UnAcceptText = nil
	self.LimitTime = nil

	self.QuestHistoryDesc = LSTR(390027) --390027("任务描述未生成")

	self.LogImage = nil
	self.MapID = 0
	self.MapIDList = {}

	self.MinLevel = 0

	self.LootMappingID = nil

	self.SpecialRule = nil

	self.SubmitTime = nil

	-- 主动更新属性 --
	self.Status = nil
	self.bTracking = false
	self.TrackStatus = nil
	self.TrackTargetID = nil

	-- 被动更新属性 --
	self.MapName = nil
	self.Icon = nil
	self.RewardItemVMList = UIBindableList.New(QuestRewardItemVM)
	self.TargetVMList = UIBindableList.New(QuestTargetVM)
	self.Distance = nil

	self.TargetMapID = nil
	self.TargetMapName = nil

	self.TempOneTargetName = ""

	-- 搜索高亮使用 --
	self.HighLightName = nil

	-- 日志中地图按钮使用
	self.QuestLogMapName = nil
	self.QuestLogTargetIndex = 1
	self:SetNoCheckValueChange("QuestLogTargetIndex", true)
end

---@param ChapterVMItem ChapterVM
---存在多处浅拷贝，要小心使用
function ChapterVM:ResetByVM(ChapterVMItem)
	if ChapterVMItem == nil then return end

	self.ChapterID = ChapterVMItem.ChapterID
	self.QuestID = ChapterVMItem.QuestID

	-- 读表属性 --
	self.Name = ChapterVMItem.Name
	self.Type = ChapterVMItem.Type
	self.GenreID = ChapterVMItem.GenreID
	self.UnAcceptText = ChapterVMItem.UnAcceptText
	self.LimitTime = ChapterVMItem.LimitTime

	self.QuestHistoryDesc = ChapterVMItem.QuestHistoryDesc

	self.LogImage = ChapterVMItem.LogImage

	self.MinLevel = ChapterVMItem.MinLevel

	self.LootMappingID = ChapterVMItem.LootID

	self.SpecialRule = ChapterVMItem.SpecialRule

	self.SubmitTime = ChapterVMItem.SubmitTime
	-- 主动更新属性 --
	self.Status = ChapterVMItem.Status
	self.bTracking = ChapterVMItem.bTracking
	self.TrackStatus = ChapterVMItem.TrackStatus
	self.TrackTargetID = ChapterVMItem.TrackTargetID

	-- 被动更新属性 --
	self.MapName = ChapterVMItem.MapName
	self.Icon = ChapterVMItem.Icon
	self.RewardItemVMList:UpdateByValues(ChapterVMItem.RewardItemVMList:GetItems())
	self.TargetVMList:UpdateByValues(ChapterVMItem.TargetVMList:GetItems())
	self.Distance = ChapterVMItem.Distance

	self.MapID = ChapterVMItem.MapID
	self.MapIDList = ChapterVMItem.MapIDList

	self.TargetMapID = ChapterVMItem.TargetMapID
	self.TargetMapName = ChapterVMItem.TargetMapName

	self.TempOneTargetName = ChapterVMItem.TempOneTargetName
	self.TempCountdownStr = nil

	self.QuestLogTargetIndex = 1
end

function ChapterVM:IsEqualVM(Value)
	return self.ChapterID == Value.ChapterID
end

function ChapterVM:UpdateVM(Value)
	if Value == nil then self:Reset() return end
	if Value.ChapterID == nil and Value.QuestID == nil then
		QuestHelper.PrintQuestError("ChapterVM:UpdateVM failed")
		return
	end
	local bInit = Value.bInit

	self.QuestID = Value.QuestID
	if self.ChapterID ~= Value.ChapterID then
		self.ChapterID = Value.ChapterID
		self:ReadTable()
	end

	self.bTracking = Value.bTracking
	self.TrackStatus = Value.TrackStatus
	self.TrackTargetID = Value.TrackTargetID

	self:UpdateChapterVMStatus(bInit)
end

function ChapterVM:ReadTable()
	local Cfg = QuestHelper.GetChapterCfgItem(self.ChapterID)
	if Cfg == nil then return end

	self.Name = Cfg.QuestName
	self.Type = Cfg.QuestType
	self.GenreID = Cfg.QuestGenreID
	self.UnAcceptText = Cfg.UnAcceptText
	if Cfg.OpenDayLimit and Cfg.OpenDayLimit ~= 0 then
		self.LimitTime = TimeUtil.GetOpenServerOffsetTS(Cfg.OpenDayLimit, Cfg.OpenHourLimit)
	else
		self.LimitTime = 0
	end

	self.QuestID = self.QuestID or Cfg.StartQuest

	self.LogImage = Cfg.LogImage
	if self.LogImage == "" then
		self.LogImage = nil
	end

	self.MapID = Cfg.MapID
	local MainCityName = QuestDefine.MainCityID2Name[self.MapID]
	self.MapName = MainCityName
		or MapCfg:FindValue(self.MapID, "DisplayName")
		or LSTR(390006) --390006("未知地图"))

	self.MinLevel = Cfg.MinLevel

	-- 章节LootID作显示，任务LootID作后台发放
	-- TODO: 已完成的任务屏蔽此操作
	if self.LootMappingID ~= Cfg.LootID then
		self.LootMappingID = Cfg.LootID
		self:UpdateRewardItem()
	end

	local SpecialRuleTemp = {}
	if Cfg.ProfessionFixed == 1 then
		SpecialRuleTemp.bProfFixed = true
	end
	if next(SpecialRuleTemp) then
		self.SpecialRule = SpecialRuleTemp
	end
end

function ChapterVM:UpdateQuestDescVMList()
	local bCurrQuestEnd = (self.ChapterID == QuestMgr.EndQuestToChapterIDMap[self.QuestID])
	local QuestHistoryDesc = self:AddQuestDescVM(self.QuestID, nil, bCurrQuestEnd)
	if QuestHistoryDesc then
		QuestHistoryDesc = DialogueUtil.ParseLabel(QuestHistoryDesc)
		QuestHistoryDesc = CommonUtil.GetTextFromStringWithSpecialCharacter(QuestHistoryDesc)
	else
		QuestHistoryDesc = LSTR(390028) --390028("空任务描述")
	end
	self.QuestHistoryDesc = QuestHistoryDesc
end

---递归查找前置任务的描述
function ChapterVM:AddQuestDescVM(QuestID, HistoryDesc, bCurrQuestEnd)
	local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return nil end
    local PrevQuestIDList = QuestCfgItem.PreTaskID
	if PrevQuestIDList == nil or PrevQuestIDList == "" then return nil end

	for _, PrevQuestID in ipairs(PrevQuestIDList) do
		if self.ChapterID == QuestMgr.EndQuestToChapterIDMap[PrevQuestID] then
			HistoryDesc = self:AddQuestDescVM(PrevQuestID, HistoryDesc, true)
		end
	end

	local AcceptDesc = QuestCfgItem.AcceptDesc
	if not string.isnilorempty(AcceptDesc) then --接取任务描述不用完成任务也显示
		HistoryDesc = (HistoryDesc == nil)
				and AcceptDesc
				or string.format("%s\n%s", HistoryDesc, AcceptDesc)
	end

	if bCurrQuestEnd then
		local QuestDesc = QuestCfgItem.TaskDesc
		if (QuestDesc ~= nil) and (QuestDesc ~= "") then
			HistoryDesc = (HistoryDesc == nil)
				and QuestDesc
				or string.format("%s\n%s", HistoryDesc, QuestDesc)
		end
	end

	return HistoryDesc
end

function ChapterVM:UpdateRewardItem()
	self.RewardItemVMList:Clear()

	if (self.LootMappingID or 0) == 0 then
		QuestHelper.PrintQuestWarning("Invalid LootMappingID in chapter #%d", self.ChapterID or 0)
		return
	end

	local LootMappingCfgItem = LootMappingCfg:FindCfg(string.format("ID = %d", self.LootMappingID))
	if (LootMappingCfgItem == nil) then
		QuestHelper.PrintQuestWarning("LootMappingCfg ID=%d not found in chapter #%d", self.LootMappingID, self.ChapterID or 0)
		return
	end

	local LootID = LootMappingCfgItem.Programs[1].ID -- 任务奖励规定只有一种掉落方案
	local RewardItemList = ItemUtil.GetLootItems(LootID)
	self.RewardItemVMList:UpdateByValues(RewardItemList)
end

function ChapterVM:UpdateChapterVMStatus(bInit)
	local Chapter = QuestMgr.ChapterMap[self.ChapterID]
	if Chapter == nil then Chapter = QuestMgr.EndChapterMap[self.ChapterID] end

	local OldQuestID = self.QuestID
	if Chapter ~= nil then
		self.QuestID = Chapter.CurrQuestID
		self.Status = Chapter.Status
		self.SubmitTime = Chapter.SubmitTime
	end
	self:UpdateLogIcon()

	self:UpdateTargetList(OldQuestID, bInit)

	local Cfg = QuestHelper.GetChapterCfgItem(self.ChapterID)
	if not Cfg then return end
	self:UpdateQuestDescVMList()
end

function ChapterVM:UpdateLogIcon(InQuestID)
	if self.bMainlineEndedTempVM then
		self.Icon = QuestDefine.MainlineOverIcon
	else
		self.Icon = QuestMgr:GetQuestIconAtLog(InQuestID or self.QuestID, self.Type)
	end
end

function ChapterVM:UpdateTargetList(OldQuestID, bInit)
	local Quest = QuestMgr.QuestMap[self.QuestID]
	if Quest == nil then return end

	if not bInit then
		self:OnUpdateTargetList(OldQuestID)
	end

	if Quest.Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then -- 任务进行中
		self:MakeTargetListInProgress(Quest)
	elseif Quest.Status == QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT then -- 任务待提交
		self:MakeTargetListCanSubmit(Quest)
	end

	if next(self.MapIDList) == nil then
		self.TargetMapID = nil

	else
		local NearestMapID = nil
		for MapID, _ in pairs(self.MapIDList) do
			if MapID == PWorldMgr:GetCurrMapResID() then
				NearestMapID = MapID
				break
			elseif MapEditDataMgr:IsCurrOrAdjacentMap(MapID)
			or (NearestMapID == nil) then
				NearestMapID = MapID
			end
		end
		self.TargetMapID = NearestMapID
		self.TargetMapName = MapCfg:FindValue(NearestMapID, "DisplayName")
			or LSTR(390006) --390006("未知地图")
	end

	if self.TargetVMList:Length() > 0 then
		local TempOneTarget = self.TargetVMList:Get(1)
		self.TempOneTargetName = TempOneTarget and TempOneTarget.Desc or ""
	end
end

local function CheckValidMostPrevTarget(Quest, Target, bForceValid)
	local bFinished = (Target.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)
	-- 已完成但在最后一个也有效，bForceValid给连续目标弹出提示用
	if bFinished then return (bForceValid or ((Target.Cfg.NextTarget or 0) <= 0)) end

	if (Target.Cfg.PrevTarget or 0) <= 0 then return true end -- 未完成且在第一个就有效

	local PrevTarget = Quest.Targets[Target.Cfg.PrevTarget]
	return (not PrevTarget) or (PrevTarget.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)
end

---添加目标组参数
local function AddTargetGroupParams(TargetList, Index, QuestCfgItem, Target)
	if type(QuestCfgItem.TargetGroupDesc) ~= "table" then return end

	if TargetList[Index] == nil then
		TargetList[Index] = {
			QuestID = QuestCfgItem.id,
			TargetID = Index,
			GroupedTargetIDList = {},
			Desc = QuestCfgItem.TargetGroupDesc[Index],
			Status = TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS,
			Count = 0,
			MaxCount = 0,

			MapIDList = {},
			GetMapIDList = function(t) return (t and t.MapIDList or {}) end,
		}
	end
	local TargetGroup = TargetList[Index]

	table.insert(TargetGroup.GroupedTargetIDList, Target.TargetID)

	if (Target.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED) then -- 完成的目标算计数
		TargetGroup.Count = TargetGroup.Count + 1

	else -- 未完成的目标加入地点
		for MapID, _ in pairs(Target:GetMapIDList()) do
			TargetGroup.MapIDList[MapID] = true
		end
	end

	if type(QuestCfgItem.TargetGroupFinish) == "table"
	and (QuestCfgItem.TargetGroupFinish[Index] or 0) > 0 then
		TargetGroup.MaxCount = QuestCfgItem.TargetGroupFinish[Index]
	else
		TargetGroup.MaxCount = TargetGroup.MaxCount + 1
	end

	TargetGroup.Status = (TargetGroup.Count < TargetGroup.MaxCount)
		and TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS
		or TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED
end

---生成目标VM参数
local function MakeTargetVMParams(TargetList, Quest, Target, bForceValid)
	local LuaGroupIndex = (Target.Cfg.TargetGroupIndex or -1) + 1 -- Lua下标从1开始
	local ConnectType = Target.Cfg.ConnectType

	local bGrouped = (LuaGroupIndex > 0) -- 目标组
	local bCombined = (ConnectType == CONNECT_TYPE.COMBINED) -- 组合目标
	local bContinuous = (ConnectType == CONNECT_TYPE.CONTINUOUS) -- 连续目标

	if not (bGrouped or bCombined or bContinuous) then
		TargetList[Target.TargetID] = Target

	elseif bGrouped and bCombined then
		if CheckValidMostPrevTarget(Quest, Target) then
			AddTargetGroupParams(TargetList, LuaGroupIndex, Quest.Cfg, Target)
		end

	elseif bGrouped then
		AddTargetGroupParams(TargetList, LuaGroupIndex, Quest.Cfg, Target)

	elseif bCombined then
		if CheckValidMostPrevTarget(Quest, Target) then
			Target.MaxCount = nil -- 组合目标不显示计数
			TargetList[Target.TargetID] = Target
		end

	elseif bContinuous then
		if CheckValidMostPrevTarget(Quest, Target, bForceValid) then
			TargetList[Target.TargetID] = Target
		end
	end
end

function ChapterVM:OnUpdateTargetList(OldQuestID)
	local Quest = QuestMgr.QuestMap[OldQuestID]
	if Quest == nil then return end

	local TargetList = {}

	local function CollectGroupedTargetFullParams(TargetID, LuaGroupIndex)
		local TargetVMItem = self:GetTargetVM(TargetID)
		if TargetVMItem ~= nil then
			TargetList[LuaGroupIndex] = nil
			for _, Target in pairs(Quest.Targets) do
				if Target.Cfg and Target.Cfg.TargetGroupIndex + 1 == LuaGroupIndex then
					MakeTargetVMParams(TargetList, Quest, Target)
				end
			end

		else
			TargetVMItem = self:GetTargetVM(LuaGroupIndex)
			if TargetVMItem == nil then return end

			TargetList[LuaGroupIndex] = nil
			for _, Target in pairs(Quest.Targets) do
				if Target.Cfg and Target.Cfg.TargetGroupIndex + 1 == LuaGroupIndex then
					MakeTargetVMParams(TargetList, Quest, Target)
				end
			end
		end
	end

	for TargetID, _ in pairs(QuestMgr:GetTargetStatusChangeMap(OldQuestID) or {}) do
		local Target = Quest.Targets[TargetID]
		if Target then
			local bCombined = (Target.Cfg.ConnectType == CONNECT_TYPE.COMBINED)
			local bLast = ((Target.Cfg.NextTarget or 0) <= 0)
			local bFinished = (Target.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)
			-- 组合目标时，完成子目标不更新TargetList
			if not bCombined or (bLast and bFinished) then
				local LuaGroupIndex = (Target.Cfg.TargetGroupIndex or -1) + 1
				if LuaGroupIndex == 0 then
					MakeTargetVMParams(TargetList, Quest, Target, true)
				else -- 目标组要遍历一遍内部目标，形成完整VM参数（主要是Count）
					CollectGroupedTargetFullParams(TargetID, LuaGroupIndex)
				end
			end
		end
	end

	-- 任务目标提示信息
	for _, TargetVMParams in pairs(TargetList) do
		if (Quest.Cfg.ShowTargetTips or 0) == 1 then
			local Content = TargetVMParams.Desc and TargetVMParams.Desc or
				(TargetVMParams.Cfg and TargetVMParams.Cfg.m_szTargetDesc or "None")
			Content = DialogueUtil.ParseLabel(Content)
			Content = CommonUtil.GetTextFromStringWithSpecialCharacter(Content)
			QuestMainVM:RegisterTargetTips(Content, {
				bTargetFinish = (TargetVMParams.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED),
				Count = TargetVMParams.Count,
				MaxCount = TargetVMParams.MaxCount,
			})
		end
	end
end

local function SortByStatus(Target1, Target2)
	if Target1.Status == Target2.Status then
		return Target1.TargetID < Target2.TargetID
	end
	return Target1.Status < Target2.Status
end

function ChapterVM:MakeTargetListInProgress(Quest)
	self.TargetVMList:Clear()
	self.MapIDList = {}
	local TargetList = {}

	for _, Target in pairs(Quest.Targets) do
		MakeTargetVMParams(TargetList, Quest, Target)
	end

	for _, TargetVMParams in pairs(TargetList) do
		if (TargetVMParams.Status ~= TARGET_STATUS.CS_QUEST_NODE_STATUS_NOT_STARTED) then
			TargetVMParams.OwnerChapterVM = self
			self.TargetVMList:AddByValue(TargetVMParams)

			if (TargetVMParams.Status ~= TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)
			and TargetVMParams.GetMapIDList then
				for MapID, _ in pairs(TargetVMParams:GetMapIDList()) do
					if MapID > 0 then
						self.MapIDList[MapID] = true
					end
				end
			end
		end
	end

	-- 统一规则，完成的目标排后面
	self.TargetVMList:Sort(SortByStatus)
end

function ChapterVM:MakeTargetListCanSubmit(Quest)
	self.TargetVMList:Clear()
	self.MapIDList = {}

	if Quest.Cfg.AcceptType == ACCEPT_TYPE.QUEST_ACCEPT_TYPE_DIALOG then
		if Quest.Cfg.SubmitMapID > 0 then
			self.MapIDList[Quest.Cfg.SubmitMapID] = true
		end
	end

	--[[
	self.TargetVMList:UpdateByValues({ {
		TargetID = -1,
		Status = TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS,
		OwnerChapterVM = self,
	} })
	]]
end

function ChapterVM:UpdateTargetDistance()
	if self.Status == CHAPTER_STATUS.FINISHED then
		self.Distance = nil
		return
	end
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		self.Distance = nil
		return
	end
	local CurrMapID = PWorldMgr:GetCurrMapResID()
	if self.MapID ~= CurrMapID then
		self.Distance = nil
		return
	end

	local QuestTrackMgr = _G.QuestTrackMgr
	local LocList = {}

	for MapID, _ in pairs(self.MapIDList) do
		if CurrMapID == MapID then
			local QuestParams = QuestTrackMgr:GetMapQuestParam(MapID, self.QuestID)
			for _, Params in ipairs(QuestParams) do
				if Params.Pos ~= nil then
					table.insert(LocList, Params.Pos)
				end
			end
			break
		end
	end

	if next(LocList) == nil then
		self.Distance = nil -- 日志条目不显示距离
		return
	end

	local MinDist = QuestDefine.QuestMaxDistance + 10 -- 初始取值略大于最大显示距离
	local MajorLocation = Major:FGetActorLocation()
	local OriginalLocation = _G.UE.UWorldMgr:Get():GetOriginLocation()

	for _, TargetLoc in ipairs(LocList) do
		local TargetDist = _G.UE.FVector.Dist(MajorLocation, TargetLoc - OriginalLocation) / 100 -- CM到M
		MinDist = (TargetDist < MinDist) and TargetDist or MinDist
	end

	self.Distance = MinDist
end

---@param TargetID int32
---@return QuestTargetVM
function ChapterVM:GetTargetVM(TargetID)
	if TargetID == nil then return nil end

	return self.TargetVMList:Find(function(VMItem)
		if TargetID == VMItem.TargetID then return true end

		for _, GroupedTargetID in ipairs(VMItem.GroupedTargetIDList) do
			if TargetID == GroupedTargetID then return true end
		end

		return false
	end)
end

function ChapterVM:GetType()
	return self.Type
end

function ChapterVM:AdapterOnGetWidgetIndex()
   return (self.ChapterID ~= nil) and 1 or 2
end

-- 进行中的任务按地图分类，已完成的任务按任务类别分类
function ChapterVM:AdapterGetCategory()
	if self.Status == CHAPTER_STATUS.FINISHED then
		-- 是否有搜索关键词
		if QuestLogVM.FilterType == 2 then
			local SearchText = QuestLogVM.SearchText
			if SearchText then
				if self.Name then
					if string.find(self.Name, SearchText, 1, true) then
						return AdapterCategoryType.MatchQuestName
					end
				end
				return AdapterCategoryType.MatchQuestDesc
			end
			return AdapterCategoryType.MatchNone
		else
			-- 按二级大类分类，取分类前三位
			return self.GenreID // 100
		end
	else
		-- 进行中的任务，文字搜索时按搜索条件分类
		if QuestLogVM.FilterType == 2 then
			local SearchText = QuestLogVM.SearchText
			if SearchText then
				if self.Name then
					if string.find(self.Name, SearchText, 1, true) then
						return AdapterCategoryType.MatchQuestName
					end
				end
				return AdapterCategoryType.MatchQuestDesc
			end
			return AdapterCategoryType.MatchNone
		else
			return self.MapID or 0
		end
	end
end

---搜索关键词是否匹配任务名称
---@return boolean
function ChapterVM:IsSearchTextMatchName()
	local SearchText = QuestLogVM.SearchText
	if SearchText then
		if self.Name then
			if string.find(self.Name, SearchText, 1, true) then
				return true
			end
		end
	end
	return false
end

---更新高亮文本
function ChapterVM:UpdateHighLightText()
	self.HighLightName = ""
	if self.Status == CHAPTER_STATUS.FINISHED and QuestLogVM.SearchText then
		if self:IsSearchTextMatchName() then
			local QuestName = string.gsub(self.Name, QuestLogVM.SearchText, string.format('<span color="#E9D7B1FF">%s</>', QuestLogVM.SearchText))
			self.HighLightName = QuestName
		else
			local QuestName = string.format('<span color="#BEB39BFF" size="16">%s</><span color="#FFF3D3FF" size="16">%s</>', LSTR(390029), QuestLogVM.SearchText) --390029("包含:")
			self.HighLightName = string.format("%s\n%s", self.Name, QuestName)
		end
	else
		self.HighLightName = self.Name
	end
end


---是否普通标题（不能推进是红色标题）
---@return boolean
function ChapterVM:IsNormalColorTitle()
	if self.bFinishedTipTempVM or self.bMainlineEndedTempVM then
		return true
	end
	return QuestHelper.CheckUnrestricted(self.QuestID)
end

---获取标题名,未接取时显示的是配置的文本
function ChapterVM:GetTitleName()
	if not string.isnilorempty(self.UnAcceptText) then
		if _G.QuestMgr:GetChapterStatus(self.ChapterID) == CHAPTER_STATUS.NOT_STARTED then
			return self.UnAcceptText
		end
	end
	return self.Name
end

return ChapterVM