local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MusicPerformanceMetronomeSettingVM : UIViewModel
local MusicPerformanceMetronomeSettingVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceMetronomeSettingVM:Ctor()
	self.BPMTip = ""
	self.BeatTip = ""
	self.TempoTip = ""

	self.VolumeValue = ""
	self.BeatValue = ""
	self.BPMValue = ""
	self.PanelBPMIntroVisible = false
	self.PanelBeatIntroVisible = false
	self.PanelAssistantIntroVisible = false
	self.BtnDefaultVisible = false
	self.PanelOnlyReadyRingVisible = false
	self.CanSave = false
end

function MusicPerformanceMetronomeSettingVM:OnInit()
end

function MusicPerformanceMetronomeSettingVM:OnBegin()
end

function MusicPerformanceMetronomeSettingVM:OnEnd()
end

function MusicPerformanceMetronomeSettingVM:OnShutdown()
end

return MusicPerformanceMetronomeSettingVM