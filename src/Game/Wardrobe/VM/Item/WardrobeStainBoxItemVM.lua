--
-- Author: ZhengJanChuan
-- Date: 2024-03-04 14:48
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeStainBoxItemVM : UIViewModel
local WardrobeStainBoxItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeStainBoxItemVM:Ctor()
    self.Color = nil
	self.IsMetal  = nil
	self.IsNormalcy = nil
	self.IsColorUnlock = nil
	self.IsChecked = nil
	self.IsSelected = nil
	self.ID = 0
	self.ColorVisible = nil
end

function WardrobeStainBoxItemVM:OnInit()
end

function WardrobeStainBoxItemVM:OnBegin()
end

function WardrobeStainBoxItemVM:OnEnd()
end

function WardrobeStainBoxItemVM:OnShutdown()
end

function WardrobeStainBoxItemVM:UpdateVM(Value)
    self.Color = Value.Color
	self.IsMetal  = Value.IsMetal
	self.IsNormalcy = Value.IsNormalcy
	self.IsColorUnlock = Value.IsColorUnlock
	self.IsChecked = Value.IsChecked
	self.ID = Value.ID
	self.ColorVisible = Value.ColorVisible
end

function WardrobeStainBoxItemVM:UpdateUnlockState(IsUnlock)
	if self.ID == 0 then
		return
	end
	self.IsColorUnlock = IsUnlock
end

function WardrobeStainBoxItemVM:UpdateCheckedState(IsChecked)
	if self.ID == 0 then
		return
	end
	self.IsChecked = IsChecked
end

function WardrobeStainBoxItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeStainBoxItemVM:IsEqualVM(Value)
	return false
end



--要返回当前类
return WardrobeStainBoxItemVM