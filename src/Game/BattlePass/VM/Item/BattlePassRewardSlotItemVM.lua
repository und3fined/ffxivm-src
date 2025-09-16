--
-- Author: ZhengJanChuan
-- Date: 2024-01-15 19:13
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class BattlePassRewardSlotItemVM : UIViewModel
local BattlePassRewardSlotItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassRewardSlotItemVM:Ctor()
	self.Num = 0
	self.ItemQualityIcon = ""
	self.ItemIcon = ""
	self.LockVisible = false
	self.GotVisible = false
	self.ImgMaskVisible = false
	self.ImgAvailableVisible = false
	self.ID = 0
	self.Grade = 0
end

function BattlePassRewardSlotItemVM:OnInit()
end

function BattlePassRewardSlotItemVM:OnBegin()
end

function BattlePassRewardSlotItemVM:OnEnd()
end

function BattlePassRewardSlotItemVM:OnShutdown()
end

function BattlePassRewardSlotItemVM:UpdateVM(Value)
	if Value == nil then
		return
	end

	self.Num = tostring(Value.Num)
	self.ItemQualityIcon = Value.ItemQualityIcon
	self.ItemIcon = Value.Icon
	self.LockVisible = Value.Locked
	self.GotVisible = Value.Got
	self.ImgMaskVisible = Value.Mask
	self.ImgAvailableVisible = Value.Available
	self.ID = Value.ID
end



--要返回当前类
return BattlePassRewardSlotItemVM