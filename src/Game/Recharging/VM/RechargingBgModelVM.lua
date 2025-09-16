local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class RechargingBgModelVM : UIViewModel
local RechargingBgModelVM = LuaClass(UIViewModel)

function RechargingBgModelVM:Ctor()
	self.bInGift = false
end

function RechargingBgModelVM:OnInit()
end

function RechargingBgModelVM:OnBegin()
end

function RechargingBgModelVM:OnEnd()
end

function RechargingBgModelVM:OnShutdown()
end

return RechargingBgModelVM