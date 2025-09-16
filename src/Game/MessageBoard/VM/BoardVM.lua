local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class BoardVM : UIViewModel
local BoardVM = LuaClass(UIViewModel)

function BoardVM:Ctor()
    -- message Mount
    -- {
    -- int32 ResID = 1;
    -- int32 Flag = 2;
    -- MountFrom From = 3;
    -- }
    self.BoardList = {}
    self.CurObjectID = 0
    self.CurBoardTypeID  = 0
end

function BoardVM:OnInit()
end

function BoardVM:OnBegin()

end

function BoardVM:OnEnd()

end

function BoardVM:OnShutdown()

end

return BoardVM