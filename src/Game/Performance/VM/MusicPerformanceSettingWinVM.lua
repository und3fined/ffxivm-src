local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class MusicPerformanceSettingWinVM : UIViewModel
local MusicPerformanceSettingWinVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceSettingWinVM:Ctor()
	self.KeyboardMode = 1
	self.KeySize = 1
	-- self.OtherMuted = false
	self.Volume = 100
	self.VolumeValue = "100"
	self.Volume2 = 100
	self.VolumeValue2 = "100"

	self.BtnDefaultVisible = false
	self.BtnOKEnable = false
	self.PanelAssistantIntroVisible = false

	self.ImgSelect1Visible = false
	self.ImgSelect2Visible = false
end

function MusicPerformanceSettingWinVM:SetSaved()
	self.KeyboardMode = MusicPerformanceUtil.GetKeybordMode()
	self.KeySize = MusicPerformanceUtil.GetKeySize()
	-- self.OtherMuted = MusicPerformanceUtil.IsOtherPerformanceMuted()
	self.Volume = MusicPerformanceUtil.GetVolume()
	self.Volume2 = MusicPerformanceUtil.GetVolumeOther()
end

function MusicPerformanceSettingWinVM:IsDefault()
	return MusicPerformanceUtil.IsDefaultCommonSettings(self)
end

function MusicPerformanceSettingWinVM:OnInit()
end

function MusicPerformanceSettingWinVM:OnBegin()
end

function MusicPerformanceSettingWinVM:OnEnd()
end

function MusicPerformanceSettingWinVM:OnShutdown()
end

return MusicPerformanceSettingWinVM