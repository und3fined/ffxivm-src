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

local QuestTypeVM = require("Game/Quest/VM/DataItemVM/QuestTypeVM")
local ChapterVM = require("Game/Quest/VM/DataItemVM/ChapterVM")
local QuestShareVM = require("Game/Quest/VM/DataItemVM/QuestShareVM")

local ProtoRes = require("Protocol/ProtoRes")
local QUEST_TYPE = ProtoRes.QUEST_TYPE
local FilterTypeDefine = QuestDefine.FilterType

local QuestMainVM = nil
local PWorldMgr = nil

---@class LogDataContainer
local LogDataContainer = LuaClass()

function LogDataContainer:Ctor()
	---任务类型列表
	self.QuestTypeVMList = UIBindableList.New(QuestTypeVM)
	---选中的任务类型
	self.CurrQuestType = nil
	---每种任务类型都可以各自选中一个任务
	self.SelectedChapters = {}
end

---@class QuestLogVM : UIViewModel
local QuestLogVM = LuaClass(UIViewModel)

function QuestLogVM:Ctor()
	self.bLogInProgress = true
	self.InProgContainer = LogDataContainer.New()
	self.EndContainer = LogDataContainer.New()

	---任务类型列表
	self.QuestTypeVMList = UIBindableList.New(QuestTypeVM)
	---选中任务类型对应的任务列表
	self.CurrTypeChapterVMs = UIBindableList.New(ChapterVM)
	---选中的任务显示在细节面板上
	self.CurrChapterVM = ChapterVM.New()
	---控制任务类型列表选中效果
	self.HighlightSelectType = nil
	self:SetNoCheckValueChange("HighlightSelectType", true)

	self.bMainlineEmpty = true

	---强制执行回调
	self.CheckEmpty = nil
	self:SetNoCheckValueChange("CheckEmpty", true)

	-----------------------------

	self.ShareVMList = UIBindableList.New(QuestShareVM)
	self.ShareVMList:UpdateByValues(QuestDefine.ShareChannels)

	-----------------------------

	---过滤列表（筛选和搜索之后的任务id）
	self.FilterList = nil
	---过滤列表变更
	self.IsFilterChanged = false
	---过滤类型(1=筛选 2=搜索)
	self.FilterType = FilterTypeDefine.None
	---搜索关键词
	self.SearchText = nil
	---搜索临时容器
	self.AllVMsAfterScreener = UIBindableList.New(ChapterVM)

	QuestMainVM = _G.QuestMainVM
	PWorldMgr = _G.PWorldMgr
end

function QuestLogVM:PreInit()
	self:TryAddQuestTypeVM(QuestDefine.LogQuestTypeAll, true)
	self:TryAddQuestTypeVM(QuestDefine.LogQuestTypeAll, false)
	self:TryAddQuestTypeVM(QUEST_TYPE.QUEST_TYPE_MAIN, true)
	self:TryAddQuestTypeVM(QUEST_TYPE.QUEST_TYPE_MAIN, false)
	self:TryAddQuestTypeVM(QUEST_TYPE.QUEST_TYPE_IMPORTANT, true)
	self:TryAddQuestTypeVM(QUEST_TYPE.QUEST_TYPE_IMPORTANT, false)
	self:TryAddQuestTypeVM(QUEST_TYPE.QUEST_TYPE_BRANCH, true)
	self:TryAddQuestTypeVM(QUEST_TYPE.QUEST_TYPE_BRANCH, false)
end

function QuestLogVM:PostInit()
	self:SelectFirstVM(QUEST_TYPE.QUEST_TYPE_MAIN, true)
end

function QuestLogVM:UpdateMainlineEmpty()
	local AnyMainlineVM = QuestMainVM.AllChapterVMs:Find(function(VMItem)
		return VMItem.Type == QUEST_TYPE.QUEST_TYPE_MAIN
	end)
	self.bMainlineEmpty = (AnyMainlineVM == nil)
end

---@param bLogInProgress boolean|nil
---@return LogDataContainer
function QuestLogVM:GetDataContainer(bLogInProgress)
	if bLogInProgress == nil then
		bLogInProgress = self.bLogInProgress
	end
	return bLogInProgress and self.InProgContainer or self.EndContainer
end

function QuestLogVM:ClearSelectContainer()
	local InProgContainer = self.InProgContainer
	if InProgContainer then
		InProgContainer.CurrQuestType = nil
		table.clear(InProgContainer.SelectedChapters)
	end
	local EndContainer = self.EndContainer
	if EndContainer then
		EndContainer.CurrQuestType = nil
		table.clear(EndContainer.SelectedChapters)
	end
end

---@param bLogInProgress boolean|nil
---@return UIBindableList
function QuestLogVM:GetAllChapterVMs(bLogInProgress)
	if bLogInProgress == nil then
		bLogInProgress = self.bLogInProgress
	end
	return bLogInProgress and QuestMainVM.AllChapterVMs or QuestMainVM.AllEndChapterVMs
end

-- ==================================================
-- 上层接口
-- ==================================================

---@param ChapterVMItem ChapterVM
function QuestLogVM:UpdateCurrChapteVM(ChapterVMItem)
	if (not self.CurrChapterVM)
	or (not ChapterVMItem)
	or (self.CurrChapterVM.ChapterID ~= ChapterVMItem.ChapterID) then return end

	self.CurrChapterVM:ResetByVM(ChapterVMItem)
end

---@param QuestType QUEST_TYPE
---@param ChapterID int32
function QuestLogVM:OnRemoveChapterVM(QuestType, ChapterID)
	if (not QuestType) or (not self.bLogInProgress) then return end
	local DataContainer = self:GetDataContainer(true)

	if (QuestType == DataContainer.CurrQuestType) then
		self.CurrTypeChapterVMs:RemoveByPredicate(function(v)
			return (v.ChapterID == ChapterID)
		end, true)

	elseif (DataContainer.CurrQuestType == QuestDefine.LogQuestTypeAll) then
		-- “全部任务”页签特殊处理
		-- 这里参数2只是为了走通后续逻辑，之后看是否有必要增加参数
		self:ChangeType(QuestDefine.LogQuestTypeAll, true)
	end

	if (self.CurrTypeChapterVMs:Length() == 0)
	or self.CurrTypeChapterVMs:Get(1).bMapNoQuestMark then
		self.CurrChapterVM:Reset()
		if (DataContainer.CurrQuestType == QuestDefine.LogQuestTypeAll) then
			self.CheckEmpty = nil
		end
	end
end

---@param QuestType QUEST_TYPE
---@param bOperateInProgress boolean|nil
---@return boolean
function QuestLogVM:TryAddQuestTypeVM(QuestType, bOperateInProgress)
	bOperateInProgress = (bOperateInProgress ~= false)
	local TypeVMItem = self:GetQuestTypeVM(QuestType, bOperateInProgress)
	if TypeVMItem ~= nil then return false end

	local QuestTypeValue = {
		Type = QuestType,
	}

	local TypeVMList = self:GetDataContainer(bOperateInProgress).QuestTypeVMList
	TypeVMList:AddByValue(QuestTypeValue)
	TypeVMList:Sort(function(Left, Right)
		return Left:GetType() < Right:GetType()
	end)

	if bOperateInProgress == self.bLogInProgress then
		self.QuestTypeVMList = TypeVMList
	end

	return true
end

---@param QuestType QUEST_TYPE
---@param bOperateInProgress boolean|nil
---@return boolean
function QuestLogVM:TryRemoveQuestTypeVM(QuestType, bOperateInProgress)
	if QuestType == QuestDefine.LogQuestTypeAll then return false end
	bOperateInProgress = (bOperateInProgress ~= false)

	local AnyVM = self:GetAllChapterVMs(bOperateInProgress):Find(function(VMItem)
		return VMItem.Type == QuestType
	end)

	if AnyVM ~= nil then return false end

	local DataContainer = self:GetDataContainer(bOperateInProgress)
	local TypeVMList = DataContainer.QuestTypeVMList
	-- 任务日志保持显示所有任务类型，不需要移除空的任务类型
	-- TypeVMList:RemoveByPredicate(function(VMItem)
	-- 	return QuestType == VMItem:GetType()
	-- end)
	DataContainer.SelectedChapters[QuestType] = nil

	local CurrQuestType = DataContainer.CurrQuestType
	if QuestType == CurrQuestType then
		self:ChangeType(QuestDefine.LogQuestTypeAll)
		self.HighlightSelectType = QuestDefine.LogQuestTypeAll
	end

	if bOperateInProgress == self.bLogInProgress then
		self.QuestTypeVMList = TypeVMList
	end

	return true
end

---@param QuestType QUEST_TYPE
---@param bLogInProgress boolean|nil
---@return QuestTypeVM
function QuestLogVM:GetQuestTypeVM(QuestType, bLogInProgress)
	if QuestType == nil then return nil end

	local TypeVMList = self:GetDataContainer(bLogInProgress).QuestTypeVMList
	local TypeVMItem = TypeVMList:Find(function(VMItem)
		return QuestType == VMItem:GetType()
	end)
	return TypeVMItem
end

---@param bLogInProgress boolean|nil
function QuestLogVM:GetSelectedType(bLogInProgress)
	return self:GetDataContainer(bLogInProgress).CurrQuestType
end

---@param QuestType QUEST_TYPE
---@return int32 ChapterID
---@param bLogInProgress boolean|nil
function QuestLogVM:GetSelectedQuestOnType(QuestType, bLogInProgress)
	return self:GetDataContainer(bLogInProgress).SelectedChapters[QuestType]
end

---选择至某类型的首个任务（只修改类型的记录，不跳转至类型页面）
---@param QuestType QUEST_TYPE
---@param bOperateInProgress boolean|nil
function QuestLogVM:SelectFirstVM(QuestType, bOperateInProgress)
	if QuestType == nil then return nil end
	bOperateInProgress = (bOperateInProgress ~= false)

	local DataContainer = self:GetDataContainer(bOperateInProgress)
	local CurrQuestType = DataContainer.CurrQuestType
	local ChapterItem

	if (bOperateInProgress == self.bLogInProgress)
	and ((CurrQuestType == QuestDefine.LogQuestTypeAll) or (QuestType == CurrQuestType)) then
		if self.CurrTypeChapterVMs:Length() > 0 then
			ChapterItem = self.CurrTypeChapterVMs:Get(1)
		end
	else
		local AllVMs = self:GetAllChapterVMs(bOperateInProgress)
		ChapterItem = AllVMs:Find(function(v)
			return QuestType == v.Type
		end)
	end

	if CurrQuestType == QuestDefine.LogQuestTypeAll then
		QuestType = CurrQuestType
	end

	if (ChapterItem == nil) or (ChapterItem.ChapterID == nil) then
		-- QuestHelper.PrintQuestWarning("QuestLogVM:SelectFirstVM for QuestType %d failed", QuestType)
		self:ChangeType(QuestDefine.LogQuestTypeAll)

	elseif ChapterItem.ChapterID ~= DataContainer.SelectedChapters[QuestType] then
		self:ChangeQuestOnType(ChapterItem.ChapterID, QuestType)
	end
end

---@param bLogInProgress boolean
---@param ChapterID int32
---@param QuestType QUEST_TYPE
function QuestLogVM:SwitchLogData(bLogInProgress, ChapterID, QuestType)
	local bDoSelect = (ChapterID ~= nil) and (QuestType ~= nil)
	if (not bDoSelect) and (self.bLogInProgress == bLogInProgress) and (not self.IsFilterChanged) then return end

	self.IsFilterChanged = false
	self.bLogInProgress = bLogInProgress
	if not bDoSelect then
		local DataContainer = self:GetDataContainer()
		QuestType = DataContainer.CurrQuestType
		ChapterID = DataContainer.SelectedChapters[QuestType]
	end

	local TypeVMList = self:GetDataContainer(bLogInProgress).QuestTypeVMList
	self.QuestTypeVMList = TypeVMList

	self:ChangeQuestOnType(ChapterID, QuestType, true)
	self:ChangeType(QuestType, true)
end

-- ==================================================
-- 基础操作
-- ==================================================

---跳转至任务类型
---@param QuestType QUEST_TYPE
---@param bSwitchLog boolean
function QuestLogVM:ChangeType(QuestType, bSwitchLog)
	QuestType = QuestType or QuestDefine.LogQuestTypeAll
	local DataContainer = self:GetDataContainer()
	local bSameType = (DataContainer.CurrQuestType == QuestType)
	if (not bSwitchLog) and bSameType then return end

	local bChangedToTypeAll = (QuestType == QuestDefine.LogQuestTypeAll)
	DataContainer.CurrQuestType = QuestType

	local AllVMs = self:GetAllChapterVMs()

	--过滤筛选
	self.AllVMsAfterScreener:EmptyItems()
	if self.FilterList then
		for i=1, AllVMs:Length() do
			local VM = AllVMs:Get(i)
			if self.FilterList[VM.ChapterID] then
				self.AllVMsAfterScreener:Add(VM)
			end
		end
	else
		for i=1, AllVMs:Length() do
			local VM = AllVMs:Get(i)
			self.AllVMsAfterScreener:Add(VM)
		end
	end

	self.CurrTypeChapterVMs:EmptyItems()
	local CurrMapID = PWorldMgr:GetCurrMapResID()

	-- 进行中的任务按地图分类，已完成的任务按任务类别分类
	if self.bLogInProgress then
		self.AllVMsAfterScreener:Sort(QuestMainVM.QuestVMSortProcess)
	end

	if bChangedToTypeAll then
		self.CurrTypeChapterVMs:AddRange(self.AllVMsAfterScreener:GetItems())
		--local AnyCurrMap = self.AllVMsAfterScreener:Find(function(v)
		--	return v.MapID == CurrMapID
		--end)
	else
		for _, VMItem in ipairs(self.AllVMsAfterScreener:GetItems()) do
			if VMItem:GetType() == QuestType then
				self.CurrTypeChapterVMs:Add(VMItem)
			end
		end
	end

	-- 清除临时容器引用
	self.AllVMsAfterScreener:EmptyItems()

	-- 刷新高亮文本
	for i=1, self.CurrTypeChapterVMs:Length() do
		local VM = self.CurrTypeChapterVMs:Get(i)
		VM:UpdateHighLightText()
	end

	-- 如果是搜索重新排序
	if self.FilterType == FilterTypeDefine.Search then
		self.CurrTypeChapterVMs:Sort(QuestMainVM.QuestVMSortBySearchResult)
	end

	if (DataContainer.SelectedChapters[QuestType] == nil)
	and self.CurrTypeChapterVMs:Length() > 0 then
		self:ChangeQuestOnType(self.CurrTypeChapterVMs:Get(1).ChapterID, QuestType)

	else
		self:SelectCurrQuest(QuestType)
	end
end

---修改当前log某个类型对应的选中任务
---@param ChapterID int32
---@param QuestType QUEST_TYPE
---@param bSwitchLog boolean
function QuestLogVM:ChangeQuestOnType(ChapterID, QuestType, bSwitchLog)
	if ChapterID == nil then return end
	QuestType = QuestType or QuestHelper.GetQuestTypeByChapterID(ChapterID)
	if QuestType == nil then return end

	local DataContainer = self:GetDataContainer()
	local CurrQuestType = DataContainer.CurrQuestType
	local SelectedChapters = DataContainer.SelectedChapters

	local bSameType = (CurrQuestType == QuestType)
	local bInTypeSameID = (SelectedChapters[QuestType] == ChapterID)

	if (not bInTypeSameID) then
		SelectedChapters[QuestType] = ChapterID
	end

	if bSwitchLog or (bSameType and (not bInTypeSameID)) then
		self:SelectCurrQuest(QuestType)
	end
end

---选中当前log当前类型的当前任务
---@param QuestType QUEST_TYPE
function QuestLogVM:SelectCurrQuest(QuestType)
	QuestType = QuestType or QuestDefine.LogQuestTypeAll
	local DataContainer = self:GetDataContainer()
	if QuestType ~= DataContainer.CurrQuestType then return end

	local ChapterID = DataContainer.SelectedChapters[QuestType]
	if ChapterID == self.CurrChapterVM.ChapterID then return end

	local NewCurrChapterVM = QuestMainVM:GetChapterVM(ChapterID)

	if NewCurrChapterVM == nil then
		-- 没有任务可能是：整个类型没有/有但没更新（避免后者）
		-- 切换任务界面至无任务或已完成
		return
	end

	self.CurrChapterVM:ResetByVM(NewCurrChapterVM)
end

---设置筛选列表
---@param FilterList table<number, bool> @Key=ChapterID
---@param FilterType number @1=筛选 2=搜索
function QuestLogVM:SetFilterList(FilterList, FilterType)
	if self.FilterList == nil and FilterList == nil then
		return
	end

	self.FilterList = FilterList
	self.FilterType = FilterType or FilterTypeDefine.None
	local DataContainer = self:GetDataContainer()

	if FilterList then
		--清理选择容器
		DataContainer.SelectedChapters = {}
	else
		self.SearchText = nil
	end

	self.IsFilterChanged = true
end

---设置搜索关键词
---@param Text string
function QuestLogVM:SetSearchText(Text)
	self.SearchText = Text
end

---清理搜索关键词
function QuestLogVM:ClearSearchText()
	self.SearchText = nil
end

return QuestLogVM