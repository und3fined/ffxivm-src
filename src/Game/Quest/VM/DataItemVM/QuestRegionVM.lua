---
--- Author: lydianwang
--- DateTime: 2022-04-19
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local UIBindableList = require("UI/UIBindableList")

local QuestDefine = require("Game/Quest/QuestDefine")
local MapCfg = require("TableCfg/MapCfg")

local LSTR = _G.LSTR

---@class QuestRegionVM : UIViewModel
local QuestRegionVM = LuaClass(UIViewModel)

function QuestRegionVM:Ctor(Value)
	self.MapID = 0
	self.Name = nil

	if Value ~= nil and Value.MapID ~= nil then
		self:UpdateVM(Value)
	end
end

function QuestRegionVM:UpdateVM(Value)
	local bSameMap = (self.MapID == Value.MapID)
	local MainCityName = QuestDefine.MainCityID2Name[Value.MapID]

	self.MapID = Value.MapID or 0
	self.Name = MainCityName
		or Value.Name
		or (Value.MapID ~= 0 and (bSameMap and self.Name or MapCfg:FindValue(Value.MapID, "DisplayName")))
		or LSTR(596004) --596004("未知地图")
end

function QuestRegionVM:IsEqualVM(Value)
	return self.MapID == Value.MapID
end

function QuestRegionVM:AdapterOnGetCanBeSelected()
   return false
end

function QuestRegionVM:AdapterOnGetWidgetIndex()
   return 0
end

function QuestRegionVM:AdapterSetCategory(ItemCategory)
	if self.MapID == ItemCategory then return end
	self:UpdateVM({MapID = ItemCategory})
end

return QuestRegionVM