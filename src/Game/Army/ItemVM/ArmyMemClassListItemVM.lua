--@author daniel
--@date 2023-03-16

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local DefineCategorys = ArmyDefine.DefineCategorys
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")

---@class ArmyMemClassListItemVM : UIViewModel
---@field CategoryIcon string @IconPath
---@field ShowIndex number @Index
---@field Name string @名称
---@field MemberNum number @成员数量
local ArmyMemClassListItemVM = LuaClass(UIViewModel)

function ArmyMemClassListItemVM:Ctor()
    self.Name = nil
    self.CategoryIcon = nil
    self.ShowIndex = nil
    self.MemberNum = nil
    self.ID = nil
    self.PermisstionTypes = nil
    self.bSelected = nil
end

function ArmyMemClassListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

---UpdateVM
---@param Value table
function ArmyMemClassListItemVM:UpdateVM(Value)
    if nil == Value then
        return
    end
    local ID = Value.ID
	self.ID = ID
    self.Name = Value.Name
    if string.isnilorempty(self.Name) then
        local CfgCategoryName
        if ID == ArmyDefine.LeaderCID then
            CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMajorCategoryName)
            self.Name = CfgCategoryName or DefineCategorys.LeaderName
        else
            CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMinorCategoryName)
            self.Name = CfgCategoryName or DefineCategorys.MemName
        end
    end
    self.ShowIndex = Value.ShowIndex
    self.PermisstionTypes = Value.PermisstionTypes
    self:SetIcon(Value.IconID)
    self:UpdateMemberNum(self.ID)
end

function ArmyMemClassListItemVM:UpdateMemberNum(ID)
    local Members = _G.ArmyMgr:GetArmyMembersByCategotyID(ID)
    self.MemberNum = #Members
end

function ArmyMemClassListItemVM:SetIcon(ID)
    self.CategoryIcon = GroupMemberCategoryCfg:GetCategoryIconByID(ID)
end

return ArmyMemClassListItemVM