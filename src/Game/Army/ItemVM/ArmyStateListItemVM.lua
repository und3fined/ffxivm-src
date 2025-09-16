--@author star
--@date 2023-11-27

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@Class ArmyStateListItemVM : UIViewModel

local ArmyStateListItemVM = LuaClass(UIViewModel)

function ArmyStateListItemVM:Ctor()
    self.ID = nil
    self.Permission = nil
    self.Level = nil
    self.Describe =  nil
    self.IsUnlock = nil
    self.Icon = nil
end

function ArmyStateListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyStateListItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.Permission = Value.Permission
    self.Level = Value.Level
    -- LSTR string:级：
    local LevelStr = LSTR(910200)
    self.Permission = string.format("%s%s%s", self.Level, LevelStr, self.Permission)
    self.Describe = Value.Describe
    self.IsUnlock = Value.IsUnlock
    self.Icon = Value.Icon
end

function ArmyStateListItemVM:AdapterOnGetCanBeSelected()
    return true
end

function ArmyStateListItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

return ArmyStateListItemVM