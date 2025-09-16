---
--- Author: lydianwang
--- DateTime: 2021-09-02
--- Description: 已废弃
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local QuestChapterCfg = require("TableCfg/QuestChapterCfg")

local QuestMainVM = nil

---@class QuestPopUpVM : UIViewModel
local QuestPopUpVM = LuaClass(UIViewModel)

function QuestPopUpVM:Ctor()
	self.QuestPopUpQueue = {}
	self.bViewPoppingUp = false

	QuestMainVM = _G.QuestMainVM
end

---@param ChapterID int32
---@param bShowAccept boolean
function QuestPopUpVM:QueuePush(ChapterID, bShowAccept)
	local ChapterCfgItem = QuestChapterCfg:FindCfgByKey(ChapterID)
	if ChapterCfgItem == nil then return end

	local LootID = ChapterCfgItem.LootID

	local ChapterVMItem = nil
	if (not bShowAccept) and LootID ~= 0 then
		ChapterVMItem = QuestMainVM:GetChapterVM(ChapterID)
	end

    local Params = {
        ChapterID = ChapterID,
        bShowAccept = bShowAccept,
		ChapterVMItem = ChapterVMItem,
		QuestType = ChapterCfgItem.QuestType,
		GameVersion = ChapterCfgItem.GameVersion,
    }
	table.insert(self.QuestPopUpQueue, Params)
	-- table.sort(self.QuestPopUpQueue, function(v1, v2)
	-- 	return (not v1.bShowAccept) or v2.bShowAccept
	-- end)

	if not self.bViewPoppingUp then
		self.bViewPoppingUp = true
		self:QueuePop()
	end
end

function QuestPopUpVM:QueuePop()
	if next(self.QuestPopUpQueue) == nil then
		self.bViewPoppingUp = false
		return
	end

	local Params = table.remove(self.QuestPopUpQueue, 1)
	if Params == nil then return end

	UIViewMgr:ShowView(UIViewID.QuestAcceptTips, Params)
end

function QuestPopUpVM:ClearQueue()
	self.QuestPopUpQueue = {}
end

return QuestPopUpVM