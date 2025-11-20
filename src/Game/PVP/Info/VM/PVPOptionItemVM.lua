local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

---@class PVPOptionItemVM : UIViewModel
local PVPOptionItemVM = LuaClass(UIViewModel)

function PVPOptionItemVM:Ctor()
    self.Title = nil
    self.Desc = nil
    self.IsShowBtn = false
    self.Callback = nil
    self.IsDone = nil
end

function PVPOptionItemVM:UpdateVM(Params)
    if Params == nil then return end
    
    self.Title = Params.Title
    self.Desc = Params.Desc

    local IsShowBtn = Params.IsDone ~= nil
    self.IsShowBtn = IsShowBtn
    self.IsDone = Params.IsDone
    self.Callback = Params.Callback
end

return PVPOptionItemVM