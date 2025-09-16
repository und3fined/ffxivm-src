local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PerformanceKeyStateItemVM : UIViewModel
local PerformanceKeyStateItemVM = LuaClass(UIViewModel)

---Ctor
function PerformanceKeyStateItemVM:Ctor()
	self.ImgDiamondPath = ""

	self.KeyState = 0
end

function PerformanceKeyStateItemVM:OnInit()
end

function PerformanceKeyStateItemVM:OnBegin()
end

function PerformanceKeyStateItemVM:OnEnd()
end

function PerformanceKeyStateItemVM:OnShutdown()
end

return PerformanceKeyStateItemVM