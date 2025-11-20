local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MusicPerformanceMainVM : UIViewModel
local MusicPerformanceMainVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceMainVM:Ctor()
	self.ToneOffset = 0
	self.PerformName = ""
	self.BPMTip = ""
	self.BeatTip = ""
	self.TempoTip = ""
	self.TempoTipColor = nil

	self.Toggle1Visible = false
	self.Toggle2Visible = false
	self.Toggle3Visible = false
	self.Toggle4Visible = false
	self.Toggle5Visible = false
	self.PanelEnsembleTipsVisible = false
	self.BtnQuitTeamVisible = false
	self.PanelBtnsVisible = false
	self.BtnMetronomeVisible = false
	self.ImgMetronomeOnVisible = false
	self.ImgMetronomeOffVisible = true
	self.TinyMetronomeVisible = false

	self.IsPlayTempoTipBgEffect = false 	   --是否播放文本背景闪烁动效(-2:1  -1:1时)
	self.IsPlayMetronomeItemBgEffect = false   --是否播放节拍器item背景闪烁动效(1:1时)

	self.Spacer4LongKeyVisible = false
	self.Spacer4LongKey1Visible = false

	-- self.FullKeyVisible = false
	-- self.FullNoBlackKeyVisible = false
	-- self.MonoKeyVisible = false
	-- self.NoBlackKeyVisible = false
	-- self.FullNoBlackLargeKeyVisible = false
	-- self.FullLargeKeyVisible = false
	-- self.NoBlackLargeKeyVisible = false
	-- self.MonoLargeKeyVisible = false

	self.PanelMetronomeVisible = false
	self.TableViewTeamVisible = false
	self.BtnCloseVisible = false
	self.PanelSwitchVisible = false
	self.PerformAssistPanelVisible = false
	self.BtnEnsembleVisible = false
	self.PanelModesVisible = false

	self.HorizontalCountDownVisible = false
	self.ImgCountDown = ""
	self.ImgPendulumAngle = 0

	self.SmallIconPath = ""
	self.BaseIconPath = ""
	self.BigIconPath = ""

	self.MetronomeSetting = nil

	self.ImgRedBgVisible = false
	self.ImgBlueBgVisible = false

	self.IsShowOtherCharacter = true --是否显示周围玩家
	self.IsCloseSceneBGM = true --是否屏蔽背景音乐
	self.IsAnimBtnEnsembleLoopPlaying = false

	self.PanelMicVoiceVisible = false --语音和喇叭的UI容器
	self.bToggleBtnPackUpChecked = false
end

function MusicPerformanceMainVM:OnInit()
end

function MusicPerformanceMainVM:OnBegin()
end

function MusicPerformanceMainVM:OnEnd()
end

function MusicPerformanceMainVM:OnShutdown()
end

return MusicPerformanceMainVM