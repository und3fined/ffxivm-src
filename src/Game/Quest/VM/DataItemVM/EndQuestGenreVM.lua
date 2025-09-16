---
--- Author: lydianwang
--- DateTime: 2021-09-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local QuestGenreCfg = require("TableCfg/QuestGenreCfg")

local LSTR = _G.LSTR

---@class EndQuestGenreVM : UIViewModel
local EndQuestGenreVM = LuaClass(UIViewModel)

function EndQuestGenreVM:Ctor(Value)
	self.GenreID = nil
	self.Name = nil

	if Value ~= nil and next(Value) ~= nil then
		self:UpdateVM(Value)
	end
end

function EndQuestGenreVM:UpdateVM(Value)
	if Value == nil then return end

	local GenreCfgItem = QuestGenreCfg:FindCfgByKey(Value.GenreID)
	if GenreCfgItem == nil then return end

	self.GenreID = Value.GenreID
	self.Name = GenreCfgItem.DetailedGenre
end

function EndQuestGenreVM:IsEqualVM(Value)
	return self.GenreID == Value.GenreID
end

function EndQuestGenreVM:AdapterOnGetCanBeSelected()
   return false
end

function EndQuestGenreVM:AdapterOnGetWidgetIndex()
   return 0
end

function EndQuestGenreVM:AdapterSetCategory(ItemCategory)
	if self.GenreID == ItemCategory then return end
	self:UpdateVM({GenreID = ItemCategory})
end

return EndQuestGenreVM