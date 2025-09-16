---
--- Author: sammrli
--- DateTime: 2023-11-2
--- Description:任务日志分类item(按任务二级分类进行分类)
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local QuestGenreCfg = require("TableCfg/QuestGenreCfg")

local LSTR = _G.LSTR

---@class QuestCategorySubGenreVM : UIViewModel
local QuestCategorySubGenreVM = LuaClass(UIViewModel)

function QuestCategorySubGenreVM:Ctor(Value)
	self.GenreGroupID = 0 -- 分类ID // 100
	self.Name = LSTR(596104) --596104("未配置")

	if Value ~= nil and Value.GenreGroupID ~= nil then
		self:UpdateVM(Value)
	end
end

---@param Value TempQuestCategorySubGenreVM
function QuestCategorySubGenreVM:UpdateVM(Value)
	self.GenreGroupID = Value.GenreGroupID or 0
	local GenreID = self.GenreGroupID * 100
	local GenreCfgItem = QuestGenreCfg:FindCfgByKey(GenreID)
	if GenreCfgItem then
		self.Name = GenreCfgItem.SubGenre
	else
		GenreCfgItem = QuestGenreCfg:FindCfgByKey(GenreID + 1)
		if GenreCfgItem then
			self.Name = GenreCfgItem.SubGenre
		end
	end
end

function QuestCategorySubGenreVM:IsEqualVM(Value)
	return self.GenreGroupID == Value.GenreGroupID
end

function QuestCategorySubGenreVM:AdapterOnGetCanBeSelected()
   return false
end

function QuestCategorySubGenreVM:AdapterOnGetWidgetIndex()
   return 0
end

function QuestCategorySubGenreVM:AdapterSetCategory(ItemCategory)
	if self.GenreGroupID == ItemCategory then return end
	---@class TempQuestCategorySubGenreVM
	local TempQuestCategorySubGenreVM = {
		GenreGroupID = ItemCategory
	}
	self:UpdateVM(TempQuestCategorySubGenreVM)
end

return QuestCategorySubGenreVM