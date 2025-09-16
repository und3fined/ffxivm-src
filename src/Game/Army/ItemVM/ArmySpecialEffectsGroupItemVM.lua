--@author star
--@date 2024--06--04

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@Class ArmySpecialEffectsGroupItemVM : UIViewModel

local ArmySpecialEffectsGroupItemVM = LuaClass(UIViewModel)

function ArmySpecialEffectsGroupItemVM:Ctor()
    self.ID = nil
    self.IsSelected = nil
    self.Name = nil
    self.Desc = nil
    self.Icon = nil
    self.IsHave = nil
end

function ArmySpecialEffectsGroupItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmySpecialEffectsGroupItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.IsSelected = Value.IsSelected
    self.Icon = Value.Icon
    self.Desc = Value.Desc
    self.Name = Value.Name
    self.IsHave = Value.IsHave
    self.States = Value.States
    if Value.Count then
        self.Count = Value.Count
    else
        self.Count = 0
    end
end

function ArmySpecialEffectsGroupItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

return ArmySpecialEffectsGroupItemVM