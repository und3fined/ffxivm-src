--@author star
--@date 2024--05--07

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@Class ArmyPrivilegeListItemVM : UIViewModel

local ArmyPrivilegeListItemVM = LuaClass(UIViewModel)

function ArmyPrivilegeListItemVM:Ctor()
    self.ID = nil
    self.Permission = nil
    self.Level = nil
    self.Describe =  nil
    self.Icon = nil
    self.IsEmpty = nil
end

function ArmyPrivilegeListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyPrivilegeListItemVM:UpdateVM(Value)
    self.ID = Value.ID
    ---空Item，占位防止Item过长
    if self.ID == 0 then
        self.IsEmpty = true
        return
    else
        self.IsEmpty = false
    end
    self.Permission = Value.Permission
    self.Level = Value.Level
    self.Describe = Value.Describe
    self.Icon = Value.Icon
end

-- function ArmyPrivilegeListItemVM:AdapterOnGetCanBeSelected()
--     return true
-- end

function ArmyPrivilegeListItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

return ArmyPrivilegeListItemVM