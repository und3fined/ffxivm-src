---
--- Author: lydianwang
--- DateTime: 2021-09-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local QuestHelper = require("Game/Quest/QuestHelper")
local DialogueUtil = require("Utils/DialogueUtil")

-- local LSTR = _G.LSTR
local QuestMgr = nil

---@class EndChapterVM : UIViewModel
local EndChapterVM = LuaClass(UIViewModel)

function EndChapterVM:Ctor(Value)
	self.ChapterID = nil

	self.Name = nil
	self.Type = nil
	self.GenreID = nil

	self.QuestHistoryDesc = ""

	self.LogImage = nil
	self.MapID = 0
	self.MinLevel = 1

	self.Icon = nil

	self.bFailed = false

	if Value ~= nil and next(Value) ~= nil then
		self:UpdateVM(Value)
	end

	QuestMgr = _G.QuestMgr
end

function EndChapterVM:UpdateVM(Value)
	if self.ChapterID ~= Value.ChapterID then
		self.ChapterID = Value.ChapterID
		self:ReadTable()
	end

	self.bFailed = Value.bFailed
end

function EndChapterVM:ReadTable()
	local Cfg = QuestHelper.GetChapterCfgItem(self.ChapterID)
	if Cfg == nil then return end

	self.Name = Cfg.QuestName
	self.Type = Cfg.QuestType
	self.GenreID = Cfg.QuestGenreID

	self:UpdateQuestDescVMList(Cfg.StartQuest)

	self.LogImage = Cfg.LogImage
	if self.LogImage == "" then
		self.LogImage = nil
	end

	self.MapID = Cfg.MapID
	self.MinLevel = Cfg.MinLevel

	self.Icon = QuestMgr:GetQuestIconAtLog(Cfg.EndQuest, self.Type)
end

function EndChapterVM:IsEqualVM(Value)
	return self.ChapterID == Value.ChapterID
end

function EndChapterVM:UpdateQuestDescVMList(StartQuestID)
	local QuestHistoryDesc = nil
	if self.ChapterID == QuestMgr.EndQuestToChapterIDMap[StartQuestID] then
		QuestHistoryDesc = self:AddQuestDescVM(StartQuestID)
	end
	self.QuestHistoryDesc = (QuestHistoryDesc == nil)
		and "" or DialogueUtil.ParseLabel(QuestHistoryDesc)
end

function EndChapterVM:AddQuestDescVM(QuestID, HistoryDesc)
	local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
	if QuestCfgItem then
		local QuestDesc = QuestCfgItem.TaskDesc
		if (QuestCfgItem.TaskDesc ~= nil) and (QuestCfgItem.TaskDesc ~= "") then
			HistoryDesc = (HistoryDesc == nil)
				and QuestDesc
				or string.format("%s\n%s", HistoryDesc, QuestDesc)
		end
	end

	local NextQuestIDList = QuestHelper.GetNextQuestIDs(QuestID)
	for _, NextQuestID in ipairs(NextQuestIDList) do
		if self.ChapterID == QuestMgr.EndQuestToChapterIDMap[NextQuestID] then
			HistoryDesc = self:AddQuestDescVM(NextQuestID, HistoryDesc)
		end
	end

	return HistoryDesc
end

function EndChapterVM:GetID()
   return self.ChapterID
end

function EndChapterVM:AdapterOnGetWidgetIndex()
   return 1
end

-- 非搜索时按SubGenre分类，搜索时按固定规则分类
function EndChapterVM:AdapterGetCategory()
	return self.GenreID
end

return EndChapterVM