---
--- Author: lydianwang
--- DateTime: 2021-09-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ChapterVM = require("Game/Quest/VM/DataItemVM/ChapterVM")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local UIViewID = require("Define/UIViewID")

local QuestLogVMClass = require("Game/Quest/VM/PanelVM/QuestLogVM")
local QuestTrackVMClass = require("Game/Quest/VM/PanelVM/QuestTrackVM")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local QUEST_TYPE = ProtoRes.QUEST_TYPE
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
local CommonUtil = require("Utils/CommonUtil")

local QuestMgr = nil
local PWorldMgr = nil

---@class QuestMainVM : UIViewModel
local QuestMainVM = LuaClass(UIViewModel)

function QuestMainVM:Ctor()
	self.AllChapterVMs = UIBindableList.New(ChapterVM)

	self.AllEndChapterVMs = UIBindableList.New(ChapterVM)

	self.TargetTipInfoList = {}

	-- 给View绑定用
	self.DisplayMainlineVM = nil
end

-- function QuestMainVM:OnInit()
-- end

function QuestMainVM:OnBegin()
	if self.bModuleBegin then return end
	self.bModuleBegin = true

	QuestMgr = _G.QuestMgr
	PWorldMgr = _G.PWorldMgr
	QuestMgr:TryInitQuestData()

	self.QuestLogVM = QuestLogVMClass.New()
	self.QuestTrackVM = QuestTrackVMClass.New()

	self.bShowEndLog = false
end

function QuestMainVM:OnEnd()
	self.QuestTrackVM:OnEnd()
end

-- function QuestMainVM:OnShutdown()
-- end

-- ==================================================
-- 外部接口
-- ==================================================

function QuestMainVM:InitMainVM()
	self.QuestLogVM:PreInit()

	for ChapterID, Chapter in pairs(QuestMgr.ChapterMap) do
		self:AddChapterVM(ChapterID, Chapter.CurrQuestID)
	end

	self.QuestLogVM:PostInit()
end

function QuestMainVM:ResetVM()
	self:OnEnd()
	self:Ctor()
	self.QuestLogVM:Ctor()
	self.QuestTrackVM:Ctor()
end

function QuestMainVM:UpdateDataVM()
	self:OnBegin() -- 此接口由网络消息驱动，有可能比onbegin还早

	for ChapterID, StChange in pairs(QuestMgr:GetChapterStatusChangeMap()) do
		local OldStatus = StChange.OldStatus
		local NewStatus = StChange.NewStatus

		if OldStatus == NewStatus then
			if NewStatus == CHAPTER_STATUS.IN_PROGRESS
			or NewStatus == CHAPTER_STATUS.CAN_SUBMIT then
				if (StChange.IsTargetChanged) then
					--目标有变化才更新
					self:UpdateChapter(ChapterID)
				end
			end

		elseif NewStatus == CHAPTER_STATUS.FINISHED then
			self:FinishChapter(ChapterID, true)

		elseif NewStatus == CHAPTER_STATUS.FAILED then
			self:FailChapter(ChapterID)

		elseif OldStatus == CHAPTER_STATUS.NOT_STARTED then
			self:AcceptChapter(ChapterID)

		elseif NewStatus == CHAPTER_STATUS.NOT_STARTED then
			self:GiveUpChapter(ChapterID)

		else
			self:UpdateChapter(ChapterID)
		end
	end

	--修正使用直升道具等其他直接完成任务的情况
	local DisplayMainlineVM = self.DisplayMainlineVM
	if DisplayMainlineVM then --当前有mainline任务
		local ChapterCfgItem = QuestHelper.GetChapterCfgItem(DisplayMainlineVM.ChapterID)
		if ChapterCfgItem then
			local IsAllFinish = true
			for _, QuestID in ipairs(ChapterCfgItem.ChapterQuests) do
				if not QuestMgr.EndQuestToChapterIDMap[QuestID] then
					IsAllFinish = false
					break
				end
			end
			if IsAllFinish then --mainline任务也完成了
				--执行FinishChapter逻辑但不弹完成提示
				self:FinishChapter(DisplayMainlineVM.ChapterID)
				self:UpdateDisplayMainlineVMFromActivated()
				FLOG_INFO("[QuestMainVM] UpdateDataVM UpdateDisplayMainlineVMFromActivated")
			end
		end
	end
end

function QuestMainVM:RefreshAllDataVM()
	for _, ChapterVMItem in ipairs(self.AllChapterVMs:GetItems()) do
		ChapterVMItem:UpdateLogIcon()
	end

	local LogCurrChapterVM = self.QuestLogVM.CurrChapterVM
	if LogCurrChapterVM then
		LogCurrChapterVM:UpdateLogIcon()
	end

	local DisplayMainlineVM = self.DisplayMainlineVM
	if DisplayMainlineVM then
		DisplayMainlineVM:UpdateLogIcon()
	end
end

function QuestMainVM:CollectActivatedMainlineVMList()
	if not _G.QuestMgr.bQuestDataInit then
		return
	end

	-- 追踪界面显示已接主线时无需显示未接主线
	if (self.DisplayMainlineVM ~= nil) then
		self.DisplayMainlineVM:UpdateLogIcon()
	else
		self:UpdateDisplayMainlineVMFromActivated()
	end
end

---@param ChapterID int32
function QuestMainVM:AcceptChapter(ChapterID)
    self:AddChapterVM(ChapterID)
	self.QuestTrackVM:OnQuestAccept(ChapterID)
	self:ClearTargetTips()

	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
	if ChapterCfgItem and (ChapterCfgItem.StartQuest ~= ChapterCfgItem.EndQuest) then
		QuestHelper.ShowQuestTip(ChapterID, true)
	end
end

---@param ChapterID int32
function QuestMainVM:UpdateChapter(ChapterID)
    self:UpdateChapterVM(ChapterID)
	self.QuestTrackVM:OnQuestUpdate(ChapterID)
	self:ShowTargetTips()
end

---@param ChapterID int32
---@param bShowQuestTip boolean
function QuestMainVM:FinishChapter(ChapterID, bShowQuestTip)
    self:RemoveChapterVM(ChapterID)
	self.QuestTrackVM:OnQuestFinish(ChapterID)
    self:AddEndChapterVM(ChapterID)
	self:ClearTargetTips()

	if bShowQuestTip then
		QuestHelper.ShowQuestTip(ChapterID, false)
	end
end

---@param ChapterID int32
function QuestMainVM:FailChapter(ChapterID)
    self:FinishChapter(ChapterID)
	self:ClearTargetTips()
end

---@param ChapterID int32
function QuestMainVM:GiveUpChapter(ChapterID)
    self:RemoveChapterVM(ChapterID)
	self.QuestTrackVM:OnQuestGiveUp(ChapterID)
	self:ClearTargetTips()
end

-- TODO:
-- 增加回调事件，提供给各个界面VM，在特定操作后执行
-- 2. LogVM: 删除任务VM后检查是不是已选VM，要暗选、明选还是跳转

---@param ChapterID int32
---@param QuestID int32
function QuestMainVM:AddChapterVM(ChapterID, QuestID)
	local ChapterVMItem
    do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_TryAddChapterVM")
		ChapterVMItem = self:TryAddChapterVM(ChapterID, QuestID)
	end
	if ChapterVMItem == nil then return end

	local QuestType = ChapterVMItem:GetType()
	do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_TryAddQuestTypeVM")
		self.QuestLogVM:TryAddQuestTypeVM(QuestType)
	end
	do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_SelectFirstVM")
		self.QuestLogVM:SelectFirstVM(QuestType)
	end

	self.QuestLogVM:UpdateMainlineEmpty()

	if QuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_UpdateDisplayMainlineVM")
		self:UpdateDisplayMainlineVM()
	end
end

---@param ChapterID int32
function QuestMainVM:UpdateChapterVM(ChapterID)
	local ChapterVMItem = self:GetChapterVM(ChapterID)
	if ChapterVMItem == nil then return end

    do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_UpdateChapterVMStatus")
		ChapterVMItem:UpdateChapterVMStatus()
	end
	do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_UpdateCurrChapteVM")
		self.QuestLogVM:UpdateCurrChapteVM(ChapterVMItem)
	end
end

---@param ChapterID int32
function QuestMainVM:RemoveChapterVM(ChapterID)
    do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_TryRemoveChapterVM")
		self:TryRemoveChapterVM(ChapterID)
	end

	local QuestType = QuestHelper.GetQuestTypeByChapterID(ChapterID)
	local TypeToSelect
	do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_TryRemoveQuestTypeVM")
		TypeToSelect = self.QuestLogVM:TryRemoveQuestTypeVM(QuestType)
			and QuestDefine.LogQuestTypeAll or QuestType
	end
	do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_SelectFirstVM")
		self.QuestLogVM:SelectFirstVM(TypeToSelect)
	end
	self.QuestLogVM:UpdateMainlineEmpty()

	if QuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
		self.DisplayMainlineVM = nil
	end
end

---@param ChapterID int32
---@param QuestID int32
function QuestMainVM:AddEndChapterVM(ChapterID)
	local ChapterVMItem
    do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_AddEndChapterVM")
		ChapterVMItem = self:TryAddEndChapterVM(ChapterID)
	end
	if ChapterVMItem == nil then return end

	local QuestType = ChapterVMItem:GetType()
	do
		local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_TryAddQuestTypeVM")
		self.QuestLogVM:TryAddQuestTypeVM(QuestType, false)
	end
	local _ <close> = CommonUtil.MakeProfileTag("QuestMainVM_SelectFirstVM")
	self.QuestLogVM:SelectFirstVM(QuestType, false)
end

---@param ChapterID int32
---@return ChapterVM
function QuestMainVM:GetChapterVM(ChapterID)
	if ChapterID == nil then return nil end

	local ChapterVMItem = self.AllChapterVMs:Find(function(VMItem)
		return VMItem.ChapterID == ChapterID
	end)
	if ChapterVMItem ~= nil then return ChapterVMItem end

	ChapterVMItem = self.AllEndChapterVMs:Find(function(VMItem)
		return VMItem.ChapterID == ChapterID
	end)
	return ChapterVMItem
end

---@param ChapterID int32
---@param TargetID int32
---@return QuestTargetVM
function QuestMainVM:GetTargetVM(ChapterID, TargetID)
	if ChapterID == nil or TargetID == nil then return nil end

	local ChapterVMItem = self:GetChapterVM(ChapterID)
	if ChapterVMItem == nil or ChapterVMItem.TargetVMList == nil then return nil end

	return ChapterVMItem:GetTargetVM(TargetID)
end

-- ==================================================
-- 内部功能
-- ==================================================

-- --------------------------------------------------
-- 任务VM维护
-- --------------------------------------------------

---@param ChapterID int32
---@param QuestID int32
---@return ChapterVM
function QuestMainVM:TryAddChapterVM(ChapterID, QuestID)
	local Value = {
		ChapterID = ChapterID,
		QuestID = QuestID,
		bInit = true, -- 传给 ChapterVM:UpdateVM -> UpdateChapterVMStatus
	}
	if QuestID == nil then -- 这段很多余，等后面砍掉QuestID参数
		local Chapter = QuestMgr.ChapterMap[ChapterID]
		if Chapter then
			Value.QuestID = Chapter.CurrQuestID
		end
	end

	-- 检查重复添加
	local AllVMs = self.AllChapterVMs:GetItems()
	for _, VM in pairs(AllVMs) do
		if VM.ChapterID == ChapterID then
			if not CommonUtil.IsShipping() then
				FLOG_ERROR(string.format("[QuestMainVM] TryAddChapterVM Exception , ChapterID = %s is exsit ", tostring(ChapterID)))
				FLOG_ERROR("[QuestMainVM] TryAddChapterVM Exception \n"..debug.traceback())
			end
			return nil
		end
	end

	-- 检查异常添加
	if QuestMgr.EndChapterMap[ChapterID] then
		if not CommonUtil.IsShipping() then
			FLOG_ERROR(string.format("[QuestMainVM] TryAddChapterVM Exception , ChapterID = %s is Finish ", tostring(ChapterID)))
			FLOG_ERROR("[QuestMainVM] TryAddChapterVM Exception \n"..debug.traceback())
		end
		return nil
	end

	local ViewModel = self.AllChapterVMs:AddByValue(Value)
	self.AllChapterVMs:Sort(self.QuestVMSortPred)
	return ViewModel
end

---@param ChapterID int32
function QuestMainVM:TryRemoveChapterVM(ChapterID)
	if ChapterID == nil then return nil end
	local QuestType = nil
	self.AllChapterVMs:RemoveByPredicate(function(VMItem)
		QuestType = VMItem:GetType()
		return VMItem.ChapterID == ChapterID
	end)
	self.QuestLogVM:OnRemoveChapterVM(QuestType, ChapterID)
end

---@param ChapterID int32
---@return ChapterVM
function QuestMainVM:TryAddEndChapterVM(ChapterID)
	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
	if ChapterCfgItem == nil then return end

	-- 检查重复添加
	local AllVMs = self.AllEndChapterVMs:GetItems()
	for _, VM in pairs(AllVMs) do
		if VM.ChapterID == ChapterID then
			return nil
		end
	end

	local Value = {
		ChapterID = ChapterID,
		QuestID = ChapterCfgItem.EndQuest,
	}

	local ViewModel = self.AllEndChapterVMs:AddByValue(Value)
	self.AllEndChapterVMs:Sort(self.QuestVMSortByGenre)
	return ViewModel
end

---@return ChapterID int32|nil
function QuestMainVM:GetTrackingChapter()
	return self.QuestTrackVM.CurrTrackChapterID
end

---@param ChapterID int32
---@param bOnNetMsg boolean
function QuestMainVM:SetTrackChapter(ChapterID, bOnNetMsg)
	if ChapterID == 0 then ChapterID = nil end
	if ChapterID then --ChapterID不为空且没有任务状态,尝试可接取追踪
	 	local ChapterStatus = QuestMgr:GetChapterStatus(ChapterID)
		if ChapterStatus == CHAPTER_STATUS.NOT_STARTED then
			self.QuestTrackVM:TrackCanAcceptQuest(ChapterID, bOnNetMsg)
			return
		end
	end
	self.QuestTrackVM:TrackQuest(ChapterID, nil, bOnNetMsg)
end

---@param NewDisplayVM ChapterVM|nil
function QuestMainVM:UpdateDisplayMainlineVM(NewDisplayVM)
	-- 有指定用指定
	if NewDisplayVM ~= nil then
		self.DisplayMainlineVM = NewDisplayVM
		return
	end

	-- 没有指定就沿用上次设置的
	if self.DisplayMainlineVM ~= nil
	and not self.DisplayMainlineVM.bActivatedMainline
	and not self.DisplayMainlineVM.bMainlineEndedTempVM then
		return
	end

	-- 上次没设置就重新设置
	local Items = {}
	for _, Item in ipairs(self.AllChapterVMs:GetItems()) do
		if Item.Type == QUEST_TYPE.QUEST_TYPE_MAIN then
			table.insert(Items, Item)
		end
	end
	table.sort(Items, self.QuestVMSortPred)

	if Items[1] ~= nil then
		self.DisplayMainlineVM = Items[1]

	else
		self:UpdateDisplayMainlineVMFromActivated()
	end
end

---@return ChapterVM|nil
local function FindDisplayMainlineVM()
	if next(QuestMgr.ActivatedCfgPakMap) == nil then
		---简单粗暴激活第一个任务
		local FirstMainlineCfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_FIRST_MAINLINE)
		if FirstMainlineCfg then
			local FirstMainlineID = FirstMainlineCfg.Value[1]
			if nil == QuestMgr.EndQuestToChapterIDMap[FirstMainlineID] then
				local QuestCfgItem = QuestHelper.GetQuestCfgItem(FirstMainlineID)
				if QuestCfgItem then
					local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
					QuestMgr:TryActivateQuest(QuestCfgItem, ChapterCfgItem)
				end
			end
		end
	end

	local ActivatedMainlineMap = {}
	for _, CfgPak in pairs(QuestMgr.ActivatedCfgPakMap) do
		if QuestHelper.CheckIsMainline(CfgPak[2].id, CfgPak[2]) then
			ActivatedMainlineMap[CfgPak[2].id] = true--CfgPak
		end
	end

	local Items = {}
	for ChapterID, _ in pairs(ActivatedMainlineMap) do
		local ChapterVMItem = ChapterVM.New()
		ChapterVMItem:UpdateVM({ ChapterID = ChapterID })
		ChapterVMItem.bActivatedMainline = true -- 在MainQuestItemView用到

		local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
		if ChapterCfgItem then
			local QuestCfgItem = QuestHelper.GetQuestCfgItem(ChapterCfgItem.StartQuest)
			if QuestCfgItem then
				if not QuestMgr.EndQuestToChapterIDMap[ChapterCfgItem.StartQuest] then
					for _, PreQuestID in ipairs(QuestCfgItem.PreTaskID) do
						if QuestMgr:GetQuestStatus(PreQuestID) == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
							-- 理论上主线任务只有一个前置任务,能找到说明就是下一个要执行的任务
							return ChapterVMItem
						end
					end
				end
			end
		end

		table.insert(Items, ChapterVMItem)
	end
	table.sort(Items, QuestMainVM.DisplayMainlineVMSortPred)

	return Items[1]
end

---把激活(可见)的主线记录下来，给追踪界面显示
function QuestMainVM:UpdateDisplayMainlineVMFromActivated()
	if QuestMgr.bFinalMainlineFinished then
		if self.DisplayMainlineVM ~= nil
		and self.DisplayMainlineVM.bMainlineEndedTempVM then
			return
		end
	
		local ChapterVMItem = ChapterVM.New()
		ChapterVMItem.bMainlineEndedTempVM = true
		ChapterVMItem.Name = QuestDefine.MainlineOverText1
		ChapterVMItem.Icon = QuestDefine.MainlineOverIcon
	
		self.DisplayMainlineVM = ChapterVMItem
		return
	end

	local DisplayMainlineVM = FindDisplayMainlineVM()

	if DisplayMainlineVM ~= nil then
		self.DisplayMainlineVM = DisplayMainlineVM
	end
end

-- --------------------------------------------------
-- 目标提示信息
-- --------------------------------------------------

function QuestMainVM:RegisterTargetTips(Content, TipParams)
	table.insert(self.TargetTipInfoList, {Content, TipParams})
end

function QuestMainVM:ShowTargetTips()
	for _, Info in ipairs(self.TargetTipInfoList) do
		_G.UIViewMgr:HideView(UIViewID.ActiveTips)
		local SoundName = nil
		if Info[2] and Info[2].bTargetFinish then
			SoundName = QuestDefine.TargetSound
		end
		MsgTipsUtil.ShowActiveTips(Info[1], 3, SoundName, Info[2])
	end
	self.TargetTipInfoList = {}
end

function QuestMainVM:ClearTargetTips()
	self.TargetTipInfoList = {}
end

-- --------------------------------------------------
-- 其他
-- --------------------------------------------------

function QuestMainVM.RegionPredicate(Left, Right)
	local CurrMapID = PWorldMgr:GetCurrMapResID()
	local LeftFactor = 999999
	local RightFactor = 999999
	if Left then
		LeftFactor = Left.MapID
		if Left.MapID ~= CurrMapID then
			LeftFactor = LeftFactor + 100000
		end
	end
	if Right then
		RightFactor = Right.MapID
		if Right.MapID ~= CurrMapID then
			RightFactor = RightFactor + 100000
		end
	end
	return LeftFactor < RightFactor
end

---假定两任务类型相同
---@param Left ChapterVM
---@param Right ChapterVM
---@return boolean
function QuestMainVM.QuestVMSortPred(Left, Right)
	if Left.MapID ~= Right.MapID then
		return QuestMainVM.RegionPredicate(Left, Right)
	end

	if Left.QuestID == nil or Right.QuestID == nil then
		return Left.QuestID ~= nil
	end

    if Left:GetType() ~= Right:GetType() then
        return Left:GetType() < Right:GetType()
    end

    if Left.MinLevel ~= Right.MinLevel then
        return Left.MinLevel < Right.MinLevel
    end

    local ID1, ID2 = Left.QuestID, Right.QuestID
	-- local CfgItem1 = QuestCfg:FindCfgByKey(ID1)
	-- if CfgItem1 == nil then return end
	-- local CfgItem2 = QuestCfg:FindCfgByKey(ID2)
	-- if CfgItem2 == nil then return end

    -- if CfgItem1.MinLevel ~= CfgItem2.MinLevel then
    --     return CfgItem1.MinLevel > CfgItem2.MinLevel
    -- end

    return ID1 < ID2
end

---@param Left ChapterVM
---@param Right ChapterVM
---@return boolean
function QuestMainVM.QuestVMSortByGenre(Left, Right)
	local G1 = Left.GenreID and Left.GenreID // 100 or 0
	local G2 = Right.GenreID and Right.GenreID // 100 or 0
	if G1 == G2 then
		local Time1 = Left.SubmitTime or 0
		local Time2 = Right.SubmitTime or 0
		if Time1 == Time2 then --GM完成的任务
			return Left.ChapterID < Right.ChapterID
		end
		return Time1 < Time2
	end
	return G1 < G2
end

---@param Left ChapterVM
---@param Right ChapterVM
---@return boolean
function QuestMainVM.QuestVMSortBySearchResult(Left, Right)
	local B1 = Left:IsSearchTextMatchName()
	local B2 = Right:IsSearchTextMatchName()
	if B1 == B2 then
		local L1 = Left.MinLevel or 0
		local L2 = Right.MinLevel or 0
		return L1 < L2
	end
	return B1
end

---假定两任务类型相同
---@param Left ChapterVM
---@param Right ChapterVM
---@return boolean
function QuestMainVM.DisplayMainlineVMSortPred(Left, Right)
	if Left.ChapterID == 10001 -- 森林中的威胁
	or Left.ChapterID == 11005 -- 主线任务测试
	or Left.ChapterID == 14015 -- 完成对话
	or Left.ChapterID == 16026 -- 测试任务: 跟光点eobj交互
	then
		return false
	end

	return Left.MinLevel < Right.MinLevel
end

function QuestMainVM.QuestVMSortProcess(Left, Right)
	if Left.MapID ~= Right.MapID then
		return QuestMainVM.RegionPredicate(Left, Right)
	end

	local LeftStatus = Left.Status or 0
	local RightStatus = Right.Status or 0
	if LeftStatus ~= RightStatus then
		return LeftStatus > RightStatus
	end

	local LeftProcess = QuestHelper.CheckCanProceed(Left.QuestID)
	local RightProcess = QuestHelper.CheckCanProceed(Right.QuestID)
	if LeftProcess ~= RightProcess then
		return LeftProcess
	end

	local LeftLevel = Left.MinLevel or 1
	local RightLevel = Right.MinLevel or 1
	return LeftLevel > RightLevel
end

return QuestMainVM