local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PerformanceSongPanelVM : UIViewModel
local PerformanceSongPanelVM = LuaClass(UIViewModel)

---Ctor
function PerformanceSongPanelVM:Ctor()
	self.IsAgree = false
end

function PerformanceSongPanelVM:OnInit()
end

function PerformanceSongPanelVM:OnBegin()
end

function PerformanceSongPanelVM:OnEnd()
end

function PerformanceSongPanelVM:OnShutdown()
end

return PerformanceSongPanelVM