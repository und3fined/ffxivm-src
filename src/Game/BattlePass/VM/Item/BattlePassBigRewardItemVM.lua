--
-- Author: ZhengJanChuan
-- Date: 2024-01-15 19:13
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class BattlePassBigRewardItemVM : UIViewModel
local BattlePassBigRewardItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassBigRewardItemVM:Ctor()
	self.Num = 0
	self.ItemQualityIcon = ""
	self.Icon = ""
    self.IsSelect = false
    self.ID = 0
end

function BattlePassBigRewardItemVM:OnInit()
end

function BattlePassBigRewardItemVM:OnBegin()
end

function BattlePassBigRewardItemVM:OnEnd()
end

function BattlePassBigRewardItemVM:OnShutdown()
end

function BattlePassBigRewardItemVM:UpdateVM(Value)
	if Value == nil then
		return
	end
    self.ID = Value.ID
	self.Num = Value.Num
	self.ItemQualityIcon = Value.ItemQualityIcon
	self.Icon = Value.Icon
    self.IsSelect = Value.IsSelect
end

function BattlePassBigRewardItemVM:OnSelectedChange(IsSelected)
    self.IsSelect = IsSelected
end

--要返回当前类
return BattlePassBigRewardItemVM