--
-- Author: ZhengJanChuan
-- Date: 2024-01-15 19:13
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class BattlePassRewardShowItemVM : UIViewModel
local BattlePassRewardShowItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassRewardShowItemVM:Ctor()
	self.ItemID = nil
	self.ItemName = ""
    self.LvText = ""
	self.ItemNameVisible = true
end

function BattlePassRewardShowItemVM:OnInit()
end

function BattlePassRewardShowItemVM:OnBegin()
end

function BattlePassRewardShowItemVM:OnEnd()
end

function BattlePassRewardShowItemVM:OnShutdown()
end

function BattlePassRewardShowItemVM:UpdateVM(Value)
	if Value == nil then
		return
	end
	self.ItemID = Value.ItemID
    self.ItemName = Value.ItemName
	self.ItemNameVisible = Value.ItemNameVisible
    self.LvText = string.format(_G.LSTR(850006), Value.Level)
end

--要返回当前类
return BattlePassRewardShowItemVM