---
--- Author: bowxiong
--- DateTime: 2024-11-08 15:25
--- Description: 单一类型消息提示的通用队列, 如果有需要特殊处理的消息类型, 自行实现子类
---

local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local TipsUnit = require("Game/TipsQueue/TipsUnit")
local CustomTipsUnit = require("Game/TipsQueue/CustomTipsUnit")
local TutorialTipsUnit = require("Game/TipsQueue/TutorialTipsUnit")

---@class TipsQueue
---
local TipsQueue = LuaClass()

function TipsQueue:Ctor(Config)
	self.Config = Config
	self.Type = Config and Config.Type or ProtoRes.tip_class_type.TIP_NONE --默认类型为TIP_NONE
	self.Priority = Config and Config.Priority or 0
	self.Queue = {}
end

function TipsQueue:MergeConfigs(Config)
	if not self.Config then
		return
	end
	for key, value in pairs(self.Config) do
		if not Config[key] then
			Config[key] = value
		end
	end
end

function TipsQueue:IsEmpty()
	return #self.Queue == 0
end

function TipsQueue:GetQueueSize()
	return #self.Queue
end

function TipsQueue:ClearQueue()
	table.clear(self.Queue)
end

function TipsQueue:GetUnitType()
	if self.Type == ProtoRes.tip_class_type.TIP_EASY_USE or
		self.Type == ProtoRes.tip_class_type.TIP_SYS_UNLOCK or
		self.Type == ProtoRes.tip_class_type.TIP_SKILL_UNLOCK then
		return CustomTipsUnit
	elseif self.Type == ProtoRes.tip_class_type.TIP_SYS_GUIDE then
		return TutorialTipsUnit
	end
	return TipsUnit
end

function TipsQueue:PushTipsToQueue(Config)
	if Config == nil then
		return false
	end

	local Key = Config.Key

	if Key and (#self.Queue > 0) then
		-- 如果指定了Key值, 并且队列里面已经有消息提示, 处理重复的提示
		-- 这里只处理最后一个提示
		local LastTipUnit = self.Queue[#self.Queue]
		if LastTipUnit:IsEqual(Config) then
			LastTipUnit:RefreshTimer()
			return false
		end
	end
	-- 合并一下提示类型的配置参数
	self:MergeConfigs(Config)
	local UnitType = self:GetUnitType()
	local NewTipUnit = UnitType.New(Config)
	-- 加入顶替类型的消息提示, 先清掉消息队列
	if Config.InterRule == ProtoRes.tip_rule_type.TIP_RULE_REPLACE then
		table.clear(self.Queue)
	end
	table.insert(self.Queue, NewTipUnit)
	return true
end

function TipsQueue:PopTipsFromQueue()
	if self:IsEmpty() then
		return nil
	end
	local CurrentTipUnit = self.Queue[1]
	table.remove(self.Queue, 1)
	return CurrentTipUnit
end

return TipsQueue