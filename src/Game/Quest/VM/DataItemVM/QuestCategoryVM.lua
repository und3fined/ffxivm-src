---
--- Author: lydianwang
--- DateTime: 2022-04-19
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local QuestDefine = require("Game/Quest/QuestDefine")
local MapCfg = require("TableCfg/MapCfg")

local LSTR = _G.LSTR

-- local CategoryType = {
-- 	Map = 1,
-- 	SubGenre = 2,
-- }

---@class QuestCategoryVM : UIViewModel
local QuestCategoryVM = LuaClass(UIViewModel)

function QuestCategoryVM:Ctor(Value)
	self.MapID = 0 -- 可能是地图ID，或任务二级分类ID
	self.Name = LSTR(596104) --596104("未配置")

	if Value ~= nil and Value.MapID ~= nil then
		self:UpdateVM(Value)
	end
end

function QuestCategoryVM:UpdateVM(Value)
	local bSameMap = (self.MapID == Value.MapID)
	local MainCityName = QuestDefine.MainCityID2Name[Value.MapID]

	self.MapID = Value.MapID or 0
	self.Name = MainCityName
		or Value.Name
		or (Value.MapID ~= 0 and (bSameMap and self.Name or MapCfg:FindValue(Value.MapID, "DisplayName")))
		or LSTR(596004) --596004("未知地图")
end

function QuestCategoryVM:IsEqualVM(Value)
	return self.MapID == Value.MapID
end

function QuestCategoryVM:AdapterOnGetCanBeSelected()
   return false
end

function QuestCategoryVM:AdapterOnGetWidgetIndex()
   return 0
end

function QuestCategoryVM:AdapterSetCategory(ItemCategory)
	if self.MapID == ItemCategory then return end
	self:UpdateVM({MapID = ItemCategory})
end

return QuestCategoryVM