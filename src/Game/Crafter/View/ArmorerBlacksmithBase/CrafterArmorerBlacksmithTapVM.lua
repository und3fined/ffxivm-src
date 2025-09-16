local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local EHeatType = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH].EHeatType



---@class CrafterArmorerBlacksmithTapVM : UIViewModel
local CrafterArmorerBlacksmithTapVM = LuaClass(UIViewModel)

function CrafterArmorerBlacksmithTapVM:Ctor()
    self:ResetParams()
end

function CrafterArmorerBlacksmithTapVM:ResetParams()
    self.Efficiency = 0
    self.HeatType = EHeatType.Zero
end

return CrafterArmorerBlacksmithTapVM