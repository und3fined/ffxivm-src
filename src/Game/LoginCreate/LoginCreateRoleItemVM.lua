local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

---@class LoginCreateRoleItemVM : UIViewModel
local LoginCreateRoleItemVM = LuaClass(UIViewModel)


function LoginCreateRoleItemVM:Ctor()
    self.bItemSelect = false
    self.bCreate = false
    self.ImgIcon = nil
    self.DataIndex = nil
    self.DataValue = nil
end

function LoginCreateRoleItemVM:UpdateData(RoleData)
    self.bCreate = RoleData.bCreate
    self.DataIndex = RoleData.DataIndex
    self.DataValue = RoleData.DataValue
    --TODO图标资源还没有
    --self.ImgIcon = string.format("Texture2D'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Appearance_Role_%03d.UI_LoginCreate_Appearance_Role_%03d'", self.DataIndex, self.DataIndex)
    self.ImgIcon = RoleData.PresetIcon
end

function LoginCreateRoleItemVM:OnSelectedChange(IsSelected)
    self.bItemSelect = IsSelected
end


return LoginCreateRoleItemVM