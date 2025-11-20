local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

---@class PVPDanItemVM : UIViewModel
local PVPDanItemVM = LuaClass(UIViewModel)

function PVPDanItemVM:Ctor()
    self.IsAchieved = nil
end

function PVPDanItemVM:UpdateVM(Params)
    self.IsAchieved = Params and Params.IsAchieved
end

function PVPDanItemVM:IsEqualVM()
    return true
end

return PVPDanItemVM