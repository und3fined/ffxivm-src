--@author star
--@date 2024-14-27

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GrandCompanyType = ArmyDefine.GrandCompanyType
---@Class ArmyChooseFlagItemVM : UIViewModel

local ArmyChooseFlagItemVM = LuaClass(UIViewModel)

function ArmyChooseFlagItemVM:Ctor()
    self.ID = nil
    self.Icon = nil
    self.FlagIcon = nil
    self.SelectedLabelIcon = nil
    self.LabelIcon = nil
    self.IsSelected = nil
    self.ArmyFlagName = nil
    self.NameColor = nil
end

function ArmyChooseFlagItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyChooseFlagItemVM:UpdateVM(Value)
    self.ID = Value.ID    
    --self.Icon = Value.Icon
    self.FlagIcon =  ArmyDefine.UnitedArmyTabs[self.ID].AnimFlagIcon
    self.SelectedLabelIcon =  Value.SelectedLabelIcon
    self.LabelIcon =  Value.LabelIcon
    self.ArmyFlagName = Value.Name
    if self.ID ~= GrandCompanyType.HengHui then
        self.NameColor = "020101FF"
    else
        self.NameColor = "828282FF"
    end
end

function ArmyChooseFlagItemVM:GetFlagID()
    return self.ID
end

function ArmyChooseFlagItemVM:SetIsSelected(InIsSelected)
    self.IsSelected = InIsSelected
    if self.ID ~= GrandCompanyType.HengHui then
        self.NameColor = "020101FF"
    else
        if self.IsSelected  then
            self.NameColor = "ffeebbFF"
        else
            self.NameColor = "828282FF"
        end
    end
end

return ArmyChooseFlagItemVM