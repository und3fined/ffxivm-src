local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

---@class LoginRoleMainVM : UIViewModel
local LoginRoleMainVM = LuaClass(UIViewModel)


function LoginRoleMainVM:Ctor()
    self.TextRaceInfo = true
end

function LoginRoleMainVM:UpdateLevelValue(Params)
    local Level = MajorUtil.GetMajorLevel()
	if Params then Level = Params.RoleDetail.Simple.Level end
    self.Level = Level
end

return LoginRoleMainVM