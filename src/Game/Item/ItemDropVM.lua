---
--- Author: anypkvcai
--- DateTime: 2021-09-28 10:35
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local ItemCfg = require("TableCfg/ItemCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")

local LOOT_TYPE = ProtoCS.LOOT_TYPE

---@class ItemDropVM : UIViewModel
local ItemDropVM = LuaClass(UIViewModel)

---Ctor
function ItemDropVM:Ctor()
	self.GID = nil
	self.ResID = nil
	self.Num = nil
	self.Name = ""
	self.Icon = nil
	self.Color = 0
	self.QualityVisible = true
end

---UpdateVM
---@param Value CommonLootItem
function ItemDropVM:UpdateVM(Value)
	local LootItem = Value

	if LootItem.Type == LOOT_TYPE.LOOT_TYPE_ITEM then
		local Item = LootItem.Item
		local ResID = Item.ResID
		local ItemValue = Item.Value

		self.GID = Item.GID
		self.ResID = ResID
		self.Num = ItemValue
		self.QualityVisible = true

		local Cfg = ItemCfg:FindCfgByKey(ResID)
		if nil ~= Cfg then
			self.Color = Cfg.ItemColor
			self.Icon = ItemCfg.GetIconPath(Cfg.IconID)

			if ItemValue > 1 then
				self.Name = string.format("%s x%d", ItemCfg:GetItemName(ResID), ItemValue)
			else
				self.Name = ItemCfg:GetItemName(ResID)
			end
		end

	else
		local Score = LootItem.Score
		local ScoreResID = Score.ResID
		local ScoreValue = Score.Value
		self.GID = 0
		self.ResID = ScoreResID
		self.Num = ScoreValue
		self.QualityVisible = false

		local Cfg = ScoreCfg:FindCfgByKey(ScoreResID)
		if nil ~= Cfg then
			self.Icon = ItemCfg.GetIconPath(Cfg.IconID)

			self.Name = string.format("%s %d", Cfg.NameText, ScoreValue)
		end
	end
end

---CreateVM
---@param LootItem CommonLootItem
function ItemDropVM.CreateVM(LootItem)
	local ViewModel = ItemDropVM.New()
	ViewModel:UpdateVM(LootItem)
	return ViewModel
end

return ItemDropVM