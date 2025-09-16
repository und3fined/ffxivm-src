---
--- Author: star
--- DateTime: 2024-05-09 14:22
--- Description:TreeView ParentItem

local UIViewModel = require("UI/UIViewModel")

---@class ArmyGroupingIconItemVM : UIViewModel
---@field Icon string @Icon
---@field Name string @Name
local ArmyGroupingIconItemVM = LuaClass(UIViewModel)

function ArmyGroupingIconItemVM:Ctor()
    self.Icon = nil
    self.ID = nil
    self.bSelected = nil
    self.bUsed = nil
end

function ArmyGroupingIconItemVM:OnInit()
    self.ID = nil
    self.Icon = ""
    self.bSelected = false
    self.bUsed = false
end

function ArmyGroupingIconItemVM:OnBegin()
end

function ArmyGroupingIconItemVM:OnEnd()
end

function ArmyGroupingIconItemVM:OnShutdown()
    self.ID = nil
end

function ArmyGroupingIconItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyGroupingIconItemVM:UpdateVM(Value)
    self.Icon = Value.Icon
    self.ID = Value.ID
    self.bSelected = false
    self.bUsed = Value.bUsed
    self.bSelected = Value.bSelected
end

function ArmyGroupingIconItemVM:SetIsSelected(IsSelected)
    self.bSelected = IsSelected
end

return ArmyGroupingIconItemVM