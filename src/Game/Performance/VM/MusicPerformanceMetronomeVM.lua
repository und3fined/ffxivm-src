local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SaveKey = require("Define/SaveKey")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class MusicPerformanceMetronomeVM : UIViewModel
local MusicPerformanceMetronomeVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceMetronomeVM:Ctor()
	self.ImgPlayVisible = false
	self.ImgCircleYellowVisible = false
	self.ImgCircleBlueVisible = false
	self.BtnMetroPlayVisible = true
	self.ImgPendulumAngle = 0

	self.Volume = 100
	self.BPM = 120
	self.BeatPerBar = 4
	self.Effect = 1 --小节振铃开关  (1开、0关)
	self.Prepare = 1 --加入两个准备小节开关  (1开、0关)
	self.EffectPrepareOnly = 0 --小节振铃仅在准备小节响起开关  (1开、0关)

	self.EnsembleBPM = 120
	self.EnsembleBeat = 4
end

function MusicPerformanceMetronomeVM:SetSaved()
	self.Volume = _G.SettingsMgr:GetValueBySaveKey(MPDefines.UI_MenuSaveKey)
	self.BPM = MusicPerformanceUtil.GetBPM()
	self.BeatPerBar = MusicPerformanceUtil.GetBeatPerBar()
	self.Effect = MusicPerformanceUtil.GetMetronomeEffect()
	self.Prepare = MusicPerformanceUtil.GetMetronomePrepare()
	self.EffectPrepareOnly = MusicPerformanceUtil.GetMetronomeEffectPrepareOnly()

	self.EnsembleBPM = MusicPerformanceUtil.GetEnsembleBPM()
	self.EnsembleBeat = MusicPerformanceUtil.GetEnsembleBeat()
end

--切换成使用合奏界面的数据
function MusicPerformanceMetronomeVM:ChangeDataFromEnsemble()
	self.BPM = self.EnsembleBPM
	self.BeatPerBar = self.EnsembleBeat
end

function MusicPerformanceMetronomeVM:OnInit()
end

function MusicPerformanceMetronomeVM:OnBegin()
end

function MusicPerformanceMetronomeVM:OnEnd()
end

function MusicPerformanceMetronomeVM:OnShutdown()
end

return MusicPerformanceMetronomeVM