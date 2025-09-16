---
--- Author: lydianwang
--- DateTime: 2021-09-07
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local QuestDefine = require("Game/Quest/QuestDefine")

---@class QuestTypeVM : UIViewModel
local QuestTypeVM = LuaClass(UIViewModel)

function QuestTypeVM:Ctor()
	self.Type = nil
	self.IconPath = nil
	self.SelectIcon = nil
end

function QuestTypeVM:IsEqualVM(Value)
	return self.Type == Value.Type
end

function QuestTypeVM:UpdateVM(Value)
	if Value == nil then return end

	self.Type = Value.Type
	local Config = QuestDefine.LogTabIcon[Value.Type]
	if Config then
		self.IconPath = Config.Normal
		self.SelectIcon = Config.Select
	end
end

function QuestTypeVM:GetType()
	return self.Type
end


return QuestTypeVM