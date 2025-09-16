local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MusicPerformanceSelectVM : UIViewModel
local MusicPerformanceSelectVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceSelectVM:Ctor()
	self.ToggleBtn1State = false
	self.ToggleBtn2State = false
	self.ToggleBtn3State = false

	self.NameColorTextString = nil
	self.NameColorTextWind = nil
	self.NameColorTextPercussion = nil

	self.InstrumentMap = {}
	self.CurInstrumentList = nil
	self.SelectedID = nil
	self.IsShowBackBtn = false
end

function MusicPerformanceSelectVM:OnInit()
end

function MusicPerformanceSelectVM:OnBegin()
end

function MusicPerformanceSelectVM:OnEnd()
end

function MusicPerformanceSelectVM:OnShutdown()
end

return MusicPerformanceSelectVM