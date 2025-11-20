local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

---@class PVPColosseumStarItemVM : UIViewModel
local PVPColosseumStarItemVM = LuaClass(UIViewModel)

function PVPColosseumStarItemVM:Ctor()
    self.IsGlow = nil
end

function PVPColosseumStarItemVM:UpdateVM(Params)
    self.IsGlow = Params and Params.IsGlow
end

function PVPColosseumStarItemVM:IsEqualVM()
    return true
end

return PVPColosseumStarItemVM