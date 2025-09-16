---
--- Author: lydianwang
--- DateTime: 2022-04-11
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local BagMgr = require("Game/Bag/BagMgr")

local ProtoRes = require("Protocol/ProtoRes")
local ItemCondType = ProtoRes.CondType

---@class TargetUseQuestItem
local TargetUseQuestItem = LuaClass(TargetBase, true)

function TargetUseQuestItem:Ctor(_, Properties)
	self.ItemID = tonumber(Properties[1])
	self.MaxCount = tonumber(Properties[2])
	-- self.SkillRange = tonumber(Properties[3])
	-- self.UseTargetType = tonumber(Properties[4])
	self.UseTargetID = tonumber(Properties[5])

	self.CurrItemData = nil

	self.CachedNpcIDList = {}
	self.CachedEObjIDList = {}
	self.CachedMonIDList = {}
end

function TargetUseQuestItem:DoStartTarget()
	self.CurrItemData = BagMgr:GetItemByResID(self.ItemID)
end

function TargetUseQuestItem:PostStartTarget()
    _G.QuestMgr.QuestRegister:RegisterUseItemTarget(self.TargetID, self.ItemID)
end

function TargetUseQuestItem:DoClearTarget()
    _G.QuestMgr.QuestRegister:UnRegisterUseItemTarget(self.TargetID)
end

---@return table
function TargetUseQuestItem:GetNpcIDList()
	return self:GetActorIDList(self.CachedNpcIDList, ItemCondType.NpcLimit)
end

---@return table
function TargetUseQuestItem:GetEObjIDList()
	return self:GetActorIDList(self.CachedEObjIDList, ItemCondType.EobjLimit)
end

---@return table
function TargetUseQuestItem:GetMonsterIDList()
	return self:GetActorIDList(self.CachedMonIDList, ItemCondType.TargetMonsterLimit)
end

---@private
function TargetUseQuestItem:GetActorIDList(CachedList, CondType)
	if next(CachedList) ~= nil then return CachedList end

	if self.UseTargetID > 0 then -- 策划预期只对此Actor使用
		table.insert(CachedList, self.UseTargetID)
		return CachedList
	end

	if (self.CurrItemData == nil) then return {} end
	local CondCfg = BagMgr:GetItemCondCfg(self.CurrItemData.ResID)
	if (CondCfg == nil) then return {} end

	for _, Cond in pairs(CondCfg.Cond) do
		if (Cond.Type == CondType) and (Cond.Value[1] ~= nil) then
			table.insert(CachedList, Cond.Value[1])
		end
	end

	return CachedList
end

return TargetUseQuestItem