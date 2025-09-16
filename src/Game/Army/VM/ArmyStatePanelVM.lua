---
--- Author: Star
--- DateTime: 2023-11-24 16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local GroupUplevelpermissionCfg = require("TableCfg/GroupUplevelpermissionCfg")
local ArmyStateListItemVM = require("Game/Army/ItemVM/ArmyStateListItemVM")
local ArmyDefine = require("Game/Army/ArmyDefine")

local ArmyMgr

---@class ArmyStatePanelVM : UIViewModel
---@field GroupPermissionList table @权限列表数据
---@field GroupPermissionTable table @权限数据
local ArmyStatePanelVM = LuaClass(UIViewModel)

--- 部队权限排序 等级>ID
---@param A any
---@param B any
local ArmyStateSortFunc = function(A, B)
    if A.Level == B.Level then
        return A.ID < B.ID
    else
        return A.Level < B.Level
    end
end

---Ctor
function ArmyStatePanelVM:Ctor()
    self.GroupPermissionList = nil
    self.GroupPermissionTable = nil
end

function ArmyStatePanelVM:OnInit()
    ArmyMgr = _G.ArmyMgr
    self.GroupPermissionList = UIBindableList.New(ArmyStateListItemVM)
    self.GroupPermissionTable = GroupUplevelpermissionCfg:FindAllCfg()
end

function ArmyStatePanelVM:UpdateArmyStateInfo()
    self:UpdateSelfData()
    self:UpdateGroupPermissionList()
end

function ArmyStatePanelVM:UpdateSelfData()

end

function ArmyStatePanelVM:UpdateGroupPermissionList()
    if nil == self.GroupPermissionTable then
        return
    end
    self.GroupPermissionList:Clear()
    local ArmyLevel = ArmyMgr:GetArmyLevel()
    for _, GroupPermission in ipairs(self.GroupPermissionTable) do
        --GroupPermission.IsUnlock = GroupPermission.Level <= ArmyLevel
        local GroupPermissionData = {}
        GroupPermissionData.IsUnlock = GroupPermission.Level <= ArmyLevel
        GroupPermissionData.ID = GroupPermission.ID
        GroupPermissionData.Level = GroupPermission.Level
        GroupPermissionData.Permission = GroupPermission.Permission 
        GroupPermissionData.Describe = GroupPermission.Describe
        GroupPermissionData.Icon = GroupPermission.Icon 
        self.GroupPermissionList:AddByValue(GroupPermissionData)
    end
    self.GroupPermissionList:Sort(ArmyStateSortFunc)
end

function ArmyStatePanelVM:OnBegin()
end

function ArmyStatePanelVM:OnEnd()
end

function ArmyStatePanelVM:OnShutdown()
    self.GroupPermissionList:Clear()
    self.GroupPermissionList = nil
end

return ArmyStatePanelVM
