local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

---@class PVPPerformanceDetailItemVM : UIViewModel
local PVPPerformanceDetailItemVM = LuaClass(UIViewModel)

function PVPPerformanceDetailItemVM:Ctor()
    self.Desc = nil
    self.Value = nil
    self.Percent = nil
end

function PVPPerformanceDetailItemVM:UpdateVM(Param)
    self.Desc = Param.Desc
    self.Value = Param.Value
    self.Percent = Param.Percent
end

function PVPPerformanceDetailItemVM:IsEqualVM()
    return true
end

return PVPPerformanceDetailItemVM