---
--- Author: daniel
--- DateTime: 2023-03-27 14:22
--- Description:TreeView ParentItem
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local DefineCategorys = ArmyDefine.DefineCategorys
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")

---@class ArmyMemPowerEditItemVM : UIViewModel
---@field Icon string @Icon
---@field Name string @Name
local ArmyMemPowerEditItemVM = LuaClass(UIViewModel)

function ArmyMemPowerEditItemVM:Ctor()
    self.Icon = nil
    self.Name = nil
    self.IsChecked = nil
    self.TextStr = nil
    self.IsAddItem = nil
    self.bSelected = nil
    self.IsNew = nil
    self.IsNoName = nil
end

function ArmyMemPowerEditItemVM:OnInit()
    self.ID = nil
    self.ShowIndex = nil
    self.TextStr = ""
    self.IsNew = false
    self.IsNoName = false
end

function ArmyMemPowerEditItemVM:OnBegin()
end

function ArmyMemPowerEditItemVM:OnEnd()
end

function ArmyMemPowerEditItemVM:OnShutdown()
    self.ID = nil
    self.ShowIndex = nil
end

function ArmyMemPowerEditItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyMemPowerEditItemVM:UpdateVM(Value)
    if nil == Value then
        return
    end
    self.ID = Value.ID
    self.ShowIndex = Value.ShowIndex
    self.Name = Value.Name
    if self.Name == "" then
        -- LSTR string:未命名新分组
        self.Name = LSTR(910158)
        self.IsNoName = true
    else
        self.IsNoName = false
    end
    self.IsClientNew = Value.IsClientNew
    self.TextStr = string.format("%d %s", self.ShowIndex, self.Name)
    self.IsAddItem = Value.IsAddItem
    self.bSelected = false
    if string.isnilorempty(self.Name) then
        local CfgCategoryName
        if self.ID == ArmyDefine.LeaderCID then
            CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMajorCategoryName)
            self.Name = CfgCategoryName or DefineCategorys.LeaderName
        else
            CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMinorCategoryName)
            self.Name = CfgCategoryName or DefineCategorys.MemName
        end
    end
    self:SetIcon(Value.IconID)
end

function ArmyMemPowerEditItemVM:SetIcon(Id)
    self.Icon = GroupMemberCategoryCfg:GetCategoryIconByID(Id)
end

function ArmyMemPowerEditItemVM:SetIsChecked(IsChecked)
    self.IsChecked = IsChecked
end

function ArmyMemPowerEditItemVM:SetIsSelected(IsSelected)
    self.bSelected = IsSelected
end

return ArmyMemPowerEditItemVM