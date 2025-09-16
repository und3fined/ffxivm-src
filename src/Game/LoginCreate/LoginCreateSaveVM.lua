local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class LoginCreateSaveVM : UIViewModel
local LoginCreateSaveVM = LuaClass(UIViewModel)

function LoginCreateSaveVM:Ctor()
    -- message Mount
    -- {
    -- int32 ResID = 1;
    -- int32 Flag = 2;
    -- MountFrom From = 3;
    -- }
    self.SaveList = {}
    self.bSaved = false -- 存档/读档
    self.bCommited = false --是否提交
    self.bFirstShow = false -- 第一次获取，用于判断是否弹出读档提示框
end

function LoginCreateSaveVM:OnInit()
end

function LoginCreateSaveVM:OnBegin()

end

function LoginCreateSaveVM:OnEnd()

end

function LoginCreateSaveVM:OnShutdown()

end

return LoginCreateSaveVM