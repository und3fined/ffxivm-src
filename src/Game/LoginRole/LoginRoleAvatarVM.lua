local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

local ProfUtil = require("Game/Profession/ProfUtil")
local RaceCfg = require("TableCfg/RaceCfg")

---@class LoginRoleAvatarVM : UIViewModel
local LoginRoleAvatarVM = LuaClass(UIViewModel)


function LoginRoleAvatarVM:Ctor()
    --该阶段的数据
    --该阶段的数据
end

function LoginRoleAvatarVM:OnInit()
end

function LoginRoleAvatarVM:OnBegin()
end

function LoginRoleAvatarVM:OnEnd()
end

function LoginRoleAvatarVM:OnShutdown()
end

function LoginRoleAvatarVM:DiscardData()
    FLOG_INFO("LoginRoleAvatarVM:DiscardData")
end


return LoginRoleAvatarVM