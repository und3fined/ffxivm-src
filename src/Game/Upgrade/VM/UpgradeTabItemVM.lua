local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")


---@class UpgradeTabItemVM : UIViewModel
local UpgradeTabItemVM = LuaClass(UIViewModel)

---Ctor
function UpgradeTabItemVM:Ctor()
    self.TextTime = nil
    self.IsLock = nil
end

function UpgradeTabItemVM:UpdateVM(Params)
    self.TextTime = Params.TextTime
    self.IsLock = Params.IsLock
end

function UpgradeTabItemVM:IsEqualVM(Value)
    return false
end

return UpgradeTabItemVM