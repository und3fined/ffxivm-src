---
--- Author: lydianwang
--- DateTime: 2022-04-19
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class QuestShareVM : UIViewModel
local QuestShareVM = LuaClass(UIViewModel)

function QuestShareVM:Ctor()
	self:Reset()
end

function QuestShareVM:Reset()
	self.ChannelName = ""
	self.ChannelType = nil
end

function QuestShareVM:UpdateVM(Value)
	if Value == nil then self:Reset() return end
	self.ChannelName = Value.ChannelName or ""
	self.ChannelType = Value.ChannelType
end

function QuestShareVM:IsEqualVM(Value)
	return self.ChannelType == Value.ChannelType
end

return QuestShareVM