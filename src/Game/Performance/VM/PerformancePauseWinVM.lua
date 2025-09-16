local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PerformancePauseWinVM : UIViewModel
local PerformancePauseWinVM = LuaClass(UIViewModel)

---Ctor
function PerformancePauseWinVM:Ctor()
	self.TextBPM = ""
	self.TextBeat = ""
	self.TextName = ""
	self.TextSpeed = ""
	self.SpeedValue = nil
	self.ToggleMetronome = false
end

function PerformancePauseWinVM:OnInit()
end

function PerformancePauseWinVM:OnBegin()
end

function PerformancePauseWinVM:OnEnd()
end

function PerformancePauseWinVM:OnShutdown()
end

return PerformancePauseWinVM