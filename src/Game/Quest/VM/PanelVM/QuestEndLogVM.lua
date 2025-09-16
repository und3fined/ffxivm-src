---
--- Author: lydianwang
--- DateTime: 2021-09-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIUtil = require("Utils/UIUtil")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")

local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local QuestGenreCfg = require("TableCfg/QuestGenreCfg")

local QuestTypeVM = require("Game/Quest/VM/DataItemVM/QuestTypeVM")
local QuestBookVM = require("Game/Quest/VM/DataItemVM/QuestBookVM")
local EndChapterVM = require("Game/Quest/VM/DataItemVM/EndChapterVM")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local QUEST_TYPE = ProtoRes.QUEST_TYPE

local LSTR = _G.LSTR
local QuestMgr = nil
local QuestMainVM = nil

---@class QuestEndLogVM : UIViewModel
local QuestEndLogVM = LuaClass(UIViewModel)

function QuestEndLogVM:Ctor()
	self.EndLogPanelName = LSTR(390004) --390004("日志")
	self.EndLogPageName = LSTR(390026) --390005("已完成任务")

	self.EndQuestTypeVMList = UIBindableList.New(QuestTypeVM)
	self.CurrEndQuestType = nil

	self.BookVMListMap = {} -- < ChapterType, BookVMList >
	for _, QuestType in pairs(QUEST_TYPE) do
		self.BookVMListMap[QuestType] = UIBindableList.New(QuestBookVM)
	end
	self.CurrBookVMList = nil

	self.EndChapterVMList = nil
	self.SelectedEndChapterVM = EndChapterVM.New()

	QuestMgr = _G.QuestMgr
end

function QuestEndLogVM:Init()
	QuestMainVM = require("Game/Quest/VM/QuestMainVM")
	self:SelectEndQuestType(QUEST_TYPE.QUEST_TYPE_MAIN)
end

function QuestEndLogVM:ResetTitle()
	self.EndLogPanelName = LSTR(390004) --390004("日志")
	self.EndLogPageName = LSTR(390026) --390026("已完成任务")
	QuestMainVM:UpdateMemberCrossLog(true)
end

-- ==================================================
-- 外部接口
-- ==================================================

---@param ChapterID int32
function QuestEndLogVM:AddEndChapterVM(ChapterID)
	QuestHelper.PrintQuestInfo("AddEndChapterVM #%d", ChapterID)
	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
	if ChapterCfgItem == nil then return end

	local QuestGenreID = ChapterCfgItem.QuestGenreID
	if QuestGenreID == 0 then QuestGenreID = 10100 end -- 临时用，等策划完善配置
	local GenreCfgItem = QuestGenreCfg:FindCfgByKey(QuestGenreID)
	if GenreCfgItem == nil then
		QuestHelper.PrintQuestError("Invalid QuestGenreID %d on EndChapter #%d", QuestGenreID, ChapterID)
		return
	end

	self:TryAddEndQuestTypeVM(ChapterCfgItem.QuestType)

	local BookVMList = self.BookVMListMap[ChapterCfgItem.QuestType]
	local BookType = QuestGenreID // 100
	local BookVM = BookVMList:Find(function(VMItem)
		return VMItem.BookType == BookType
	end)
	if BookVM == nil then
		local Value = {
			BookType = BookType,
			TotalQuestNum = 999, -- 最好能在任务编辑器里计算出
			Name = GenreCfgItem.SubGenre,
			Cover = --[[GenreCfgItem.SubGenrePic]]
				"Texture2D'/Game/UI/Texture/Quest/UI_Quest_Finish_Banner_02.UI_Quest_Finish_Banner_02'",
		}
		BookVM = BookVMList:AddByValue(Value)
		BookVMList:Sort(function(Left, Right)
			return Left.BookType < Right.BookType
		end)
	end

	local EndChapterVMItem = BookVM:GetEndChapterVM(ChapterID)
	if EndChapterVMItem == nil then
		local Value = {
			ChapterID = ChapterID,
			GenreID = QuestGenreID,
			ChapterType = ChapterCfgItem.QuestType,
			Name = ChapterCfgItem.QuestName,
			MinLevel = ChapterCfgItem.MinLevel,
			LogImage = ChapterCfgItem.LogImage,
		}
		EndChapterVMItem = EndChapterVM.New(Value)
		BookVM:AddEndChapterVM(EndChapterVMItem)
	end
end

---@param QuestType QUEST_TYPE
function QuestEndLogVM:SelectEndQuestType(QuestType)
	QuestType = QuestType or self.CurrEndQuestType

	if QuestType == nil then
		local TypeVMItem = self.EndQuestTypeVMList:Get(1)
		if TypeVMItem then
			QuestType = TypeVMItem:GetType()
		else
			return
		end
	end
	self.CurrEndQuestType = QuestType

	self.CurrBookVMList = self.BookVMListMap[QuestType]
end

---显示已完成任务细节面板
---@param BookVM QuestBookVM
---@param SearchText string
function QuestEndLogVM:ShowDetailPanel(BookVM, SearchText)
	local LogMainPanel = UIViewMgr:FindVisibleView(UIViewID.QuestLogMainPanel)
	if LogMainPanel == nil then return end

	if BookVM ~= nil then -- 打开任务书
		self.EndLogPanelName = BookVM.Name
		self.EndLogPageName = ""
		self:UpdateDetailByBookVM(BookVM)
		self.EndChapterVMList = BookVM.EndChapterVMList

	elseif SearchText ~= nil then -- 搜索任务
		self.EndLogPanelName = LSTR(390026) --390026("已完成任务")
		self.EndLogPageName = LSTR(390030) --390030("搜索结果")
		LogMainPanel.FinishDetailPanel:DoSearchExternal(SearchText)

	else
		QuestHelper.PrintQuestWarning("QuestEndLogVM:ShowDetailPanel get wrong params")
		return
	end

	QuestMainVM:UpdateMemberCrossLog(true)
	UIUtil.SetIsVisible(LogMainPanel.FinishDetailPanel, true)
end

function QuestEndLogVM.GenrePredicate(Left, Right)
	return (Left.GenreID or 0) < (Right.GenreID or 0)
end

-- ==================================================
-- 内部功能
-- ==================================================

-- --------------------------------------------------
-- 任务类型栏
-- --------------------------------------------------

---@param QuestType QUEST_TYPE
---@return QuestTypeVM
function QuestEndLogVM:GetEndQuestTypeVM(QuestType)
	if QuestType == nil then return nil end
	local TypeVMItem = self.EndQuestTypeVMList:Find(function(VMItem)
		return QuestType == VMItem:GetType()
	end)
	return TypeVMItem
end

---新增已完成任务类型VM
---@param QuestType QUEST_TYPE
function QuestEndLogVM:TryAddEndQuestTypeVM(QuestType)
	local TypeVMItem = self:GetEndQuestTypeVM(QuestType)
	if TypeVMItem ~= nil then return end

	local QuestTypeTab = {
		Type = QuestType,
		Name = QuestDefine.QuestTypeInfo[QuestType].Name,
		Icon = QuestMgr:GetQuestIconAtLog(nil, QuestType),
		-- QuestNum = 0,
	}
	local function QuestTypePredicate(Left, Right)
		return Left:GetType() < Right:GetType()
	end
	self.EndQuestTypeVMList:AddByValue(QuestTypeTab)
	self.EndQuestTypeVMList:Sort(QuestTypePredicate)
end

-- --------------------------------------------------
-- 任务细节面板
-- --------------------------------------------------

function QuestEndLogVM:SelectEndChapterVM(EndChapterVM)
	if EndChapterVM == nil then return end
	self.SelectedEndChapterVM:UpdateVM(EndChapterVM)
end

function QuestEndLogVM:UpdateDetailByBookVM(BookVM)
	if BookVM == nil then return end
	self.EndChapterVMList = BookVM.EndChapterVMList
	self.SelectedEndChapterVM:UpdateVM(BookVM.EndChapterVMList:Get(1))
end

function QuestEndLogVM:UpdateBySearchText(SearchText)
	if SearchText == nil or SearchText == "" then
		-- 清空内容
		return
	end

	-- 逐BookVM搜索
	-- 判空、判满逻辑，及时return

	-- local QuestNameCatParams = {
	-- 	CategoryType = 111,
	-- 	Name = LSTR(string.format("任务名字包含“%s”", SearchText)),
	-- }
	-- local QuestDescCatParams = {
	-- 	CategoryType = 222,
	-- 	Name = LSTR(string.format("任务描述包含“%s”", SearchText)),
	-- }

	-- local FirstVM = NameEndQuestVMList:Get(1) or DescEndQuestVMList:Get(1)
	-- self.SelectedEndChapterVM:UpdateVM(FirstVM)
end

-- 几种情况：
-- 1. 主线简单显示任务书内所有任务
-- 2. 按照特定筛选条件，按类别显示任务
--    任务书和任务都需要配置类别信息
-- 3. 按搜索词筛选任务

return QuestEndLogVM