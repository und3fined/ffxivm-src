---
---@Author: ZhengJanChuan
---@Date: 2025-02-18 16:44:22
---@Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local BattlePassLevelRewardItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassLevelRewardItemVM:Ctor()
    self.GID = 0
    self.ResID = 0
    self.Num = 0
    self.BPLevel = 0
    self.BPGrade = 0

    self.Icon = ""
	self.IsValid = true
	self.NumVisible = true
	self.ItemNameVisible = false
	self.ItemName = ""
	self.IsQualityVisible = true
	self.IconReceivedVisible = false
	self.IsMask = false
	self.ItemLevelVisible = false
	self.IconChooseVisible = false
end

function BattlePassLevelRewardItemVM:OnInit()
end

function BattlePassLevelRewardItemVM:OnBegin()
end

function BattlePassLevelRewardItemVM:OnEnd()
end 

function BattlePassLevelRewardItemVM:OnShutdown()
end

function BattlePassLevelRewardItemVM:UpdateVM(Value)
	local Cfg = ItemCfg:FindCfgByKey(Value.ResID)
	if Cfg ~= nil then
		self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
		self.ItemQualityIcon = ItemUtil.GetItemColorIcon(Value.ResID)
		self.IsQualityVisible = true
		self.NumVisible = Cfg.MaxPile ~= 1
		if Value.ItemNameVisible then
			self.ItemName = ItemCfg:GetItemName(Value.ResID)
		end
	else
		self.Icon = ""
		self.ItemName = ""
		self.NumVisible = false
		self.IsQualityVisible = false
	end
	self.IsValid = true
	self.GID = 1
	self.ResID = Value.ResID
	self.Num = Value.Num
	self.IconReceivedVisible = Value.IconReceivedVisible
	self.IsMask = Value.IsMask
	self.ItemNameVisible = Value.ItemNameVisible
    self.BPLevel = Value.Level
    self.BPGrade = Value.Grade
end


return BattlePassLevelRewardItemVM
