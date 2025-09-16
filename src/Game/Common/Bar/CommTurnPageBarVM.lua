local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CommTurnPageBarVM : UIViewModel
local CommTurnPageBarVM = LuaClass(UIViewModel)

function CommTurnPageBarVM:Ctor()
    self.PageText = nil
    self.PageSwitchVisible = nil
    self.PageUpEnabled = nil
    self.PageDnEnabled = nil
end

function CommTurnPageBarVM:UpdateVM(Value)

end

function CommTurnPageBarVM:UpdatePageInfo(Page, PageMax, UpEnabled, DnEnabled)
    self.PageSwitchVisible = true
    self.PageText = string.format("%d/%d", Page, PageMax)
    self.PageUpEnabled = UpEnabled
    self.PageDnEnabled = DnEnabled
end

return CommTurnPageBarVM