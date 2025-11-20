local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MusicPerformanceMetronomeSettingVM : UIViewModel
local MusicPerformanceMetronomeSettingVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceMetronomeSettingVM:Ctor()
	self.BPMTip = ""
	self.BeatTip = ""
	self.TempoTip = ""
	self.TempoTipColor = nil
	self.IsPlayTempoTipBgEffect = false 	   --是否播放文本背景闪烁动效(-2:1  -1:1时)
	self.IsPlayMetronomeItemBgEffect = false   --是否播放节拍器item背景闪烁动效(1:1时)

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