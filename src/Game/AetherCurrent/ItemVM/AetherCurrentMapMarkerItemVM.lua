--
-- Author: alex
-- Date: 2024-06-20 11:50
-- Description:风脉泉地图标记
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class AetherCurrentMapMarkerItemVM
local AetherCurrentMapMarkerItemVM = LuaClass(UIViewModel)

---Ctor
function AetherCurrentMapMarkerItemVM:Ctor()
    self.SubViewMarkerPointID = 0
    self.IconPath = nil
    self.bWaitForPlayEffect = false
end

function AetherCurrentMapMarkerItemVM:UpdateVM(Value)
    self.SubViewMarkerPointID = Value.PointID
    self.IconPath = Value.IconPath
	self.bWaitForPlayEffect = Value.bWaitForPlayEffect
end

return AetherCurrentMapMarkerItemVM