---
--- Author: sammrli
--- DateTime: 2023-11-10
--- Description:任务日志分类item(按搜索结果类型)
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local LSTR = _G.LSTR
local QuestLogVM = nil

---@class QuestCategorySearchVM : UIViewModel
local QuestCategorySearchVM = LuaClass(UIViewModel)

function QuestCategorySearchVM:Ctor(Value)
	self.GenreGroupID = 0
	self.Name = ""

	local QuestMainVM = _G.QuestMainVM
	if QuestMainVM then
		QuestLogVM = QuestMainVM.QuestLogVM
	end

	if Value ~= nil and Value.GenreGroupID ~= nil then
		self:UpdateVM(Value)
	end
end

---@param Value TempQuestCategorySearchVM
function QuestCategorySearchVM:UpdateVM(Value)
	local KeyWord = QuestLogVM and tostring(QuestLogVM.SearchText) or ""
	self.GenreGroupID = Value.GenreGroupID or 0
	if self.GenreGroupID == 1 then
		self.Name = string.format(LSTR(390031), KeyWord) --390031("任务名称中包含\"%s\"")
	elseif self.GenreGroupID == 2 then
		self.Name = string.format(LSTR(390032), KeyWord) --390032("任务描述中包含\"%s\"")
	end
end

function QuestCategorySearchVM:IsEqualVM(Value)
	return self.GenreGroupID == Value.GenreGroupID
end

function QuestCategorySearchVM:AdapterOnGetCanBeSelected()
   return false
end

function QuestCategorySearchVM:AdapterOnGetWidgetIndex()
   return 0
end

function QuestCategorySearchVM:AdapterSetCategory(ItemCategory)
	---@class TempQuestCategorySearchVM
	local TempQuestCategorySearchVM = {
		GenreGroupID = ItemCategory
	}
	self:UpdateVM(TempQuestCategorySearchVM)
end

return QuestCategorySearchVM