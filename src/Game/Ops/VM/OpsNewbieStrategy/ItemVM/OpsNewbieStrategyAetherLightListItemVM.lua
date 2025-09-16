local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")

---@class OpsNewbieStrategyAetherLightListItemVM : UIViewModel
local OpsNewbieStrategyAetherLightListItemVM = LuaClass(UIViewModel)

---Ctor
function OpsNewbieStrategyAetherLightListItemVM:Ctor()

end

function OpsNewbieStrategyAetherLightListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.CrystalID == self.CrystalID
end

function OpsNewbieStrategyAetherLightListItemVM:UpdateVM(Params)
    if Params then
        self.MapID = Params.MapID
        self.CrystalID = Params.CrystalID
        --self.CrystalName = Params.CrystalName
        self.CrystalIcon = Params.CrystalIcon
        self.IsActivated = Params.IsActivated
        if  self.IsActivated then
            self.CrystalName = Params.CrystalName
        else
            ---标点符号不翻译
            self.CrystalName = "???"
        end
    end
end

return OpsNewbieStrategyAetherLightListItemVM