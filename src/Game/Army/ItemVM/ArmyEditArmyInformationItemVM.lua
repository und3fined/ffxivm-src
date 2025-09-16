local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class ArmyJoinInfoActivityItemVM : UIViewModel
local ArmyJoinInfoActivityItemVM = LuaClass(UIViewModel)
---Ctor
function ArmyJoinInfoActivityItemVM:Ctor()
    self.ID = nil
    self.Icon = nil
    self.Text = nil
    self.IsChecked = nil
    self.IsEnabled = nil
end

function ArmyJoinInfoActivityItemVM:UpdateVM(Value)
    self.ID = Value.ID
	self.Icon = Value.Icon
    self.Text = Value.Text
    self.IsChecked = Value.IsChecked
    self.IsEnabled = Value.IsEnabled
end

function ArmyJoinInfoActivityItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyJoinInfoActivityItemVM:SetIsChecked(IsChecked)
    self.IsChecked = IsChecked
end

function ArmyJoinInfoActivityItemVM:GetIsChecked()
    return self.IsChecked
end

function ArmyJoinInfoActivityItemVM:SetIsEnabled(IsEnabled)
    self.IsEnabled = IsEnabled
end
--要返回当前类
return ArmyJoinInfoActivityItemVM