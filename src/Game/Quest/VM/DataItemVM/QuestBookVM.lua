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

local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local QuestCfg = require("TableCfg/QuestCfg")
local QuestDefine = require("Game/Quest/QuestDefine")

local EndChapterVM = require("Game/Quest/VM/DataItemVM/EndChapterVM")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local QUEST_TYPE = ProtoRes.QUEST_TYPE

local QuestEndLogVM = nil
local LSTR = _G.LSTR

---@class QuestBookVM : UIViewModel
local QuestBookVM = LuaClass(UIViewModel)

function QuestBookVM:Ctor(Value)
	-- Book constants
	self.BookType = nil
	self.TotalQuestNum = 0
	self.Name = ""
	self.Cover = ""

	-- Book variables
	self.EndChapterVMList = UIBindableList.New(EndChapterVM)
	self.CurrQuestNum = 0
	self.bHaveNewQuest = false
	self.bAllFinish = false

	if Value ~= nil and next(Value) ~= nil then
		self:UpdateVM(Value)
	end

	QuestEndLogVM = QuestEndLogVM or _G.QuestMainVM.QuestEndLogVM
end

function QuestBookVM:UpdateVM(Value)
	self.BookType = Value.BookType
	self.TotalQuestNum = Value.TotalQuestNum
	self.Name = Value.Name
	self.Cover = Value.Cover
end

function QuestBookVM:GetEndChapterVM(ChapterID)
	return self.EndChapterVMList:Find(function(VMItem)
		return VMItem.ChapterID == ChapterID
	end)
end

function QuestBookVM:AddEndChapterVM(EndChapterVMItem)
	self.EndChapterVMList:Add(EndChapterVMItem)
	self.EndChapterVMList:Sort(QuestEndLogVM.GenrePredicate)
	self.bHaveNewQuest = true
	-- 当前初始化也会调用此接口，若需要特殊处理初始化，也要赋值对应数量变化
	self.CurrQuestNum = self.CurrQuestNum + 1
	-- if blablabla then self.bAllFinish = blublublu end
end

function QuestBookVM:IsEqualVM(Value)
	return self.BookType == Value.BookType
end

return QuestBookVM