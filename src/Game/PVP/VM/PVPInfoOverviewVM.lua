local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local EventID
local LSTR

---@class PVPInfoOverviewVM : UIViewModel
local PVPInfoOverviewVM = LuaClass(UIViewModel)

function PVPInfoOverviewVM:Ctor()
    
end

return PVPInfoOverviewVM