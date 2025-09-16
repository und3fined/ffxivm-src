--@author daniel
--@date 2023-03-16

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")

---@class ArmyClassAuthorityItemVM : UIViewModel
---@field PermissionsIcon string @IconPath 权限类别图标
---@field PermissionsClass number @Index 权限类别
---@field Name string @权限类别名称
---@field PermissionsStr table @权限列表字符串
local ArmyClassAuthorityItemVM = LuaClass(UIViewModel)

function ArmyClassAuthorityItemVM:Ctor()
    self.Name = nil
    self.PermissionsIcon = nil
    --self.PermissionsClass = nil
    self.PermissionsStr = nil
end

function ArmyClassAuthorityItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.PermissionsType == self.PermissionsType
end

---UpdateVM
---@param Value table
function ArmyClassAuthorityItemVM:UpdateVM(Value)
    self.Name = Value.Name or ""
    self.PermissionsIcon = Value.Icon or ""
    --self.PermissionsClass = Value.PermissionsClass
    self.PermissionsStr = Value.PermissionsStr
end



return ArmyClassAuthorityItemVM