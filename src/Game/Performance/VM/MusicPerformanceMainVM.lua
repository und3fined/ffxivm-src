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
	self.SideBarState = ""

	self.Toggle1Visible = false
	self.Toggle2Visible = false
	self.Toggle3Visible = false
	self.Toggle4Visible = false
	self.Toggle5Visible = false
	self.TextEnsembleVisible = false
	self.BtnQuitTeamVisible = false
	self.PanelBtnsVisible = false
	self.BtnMetronomeVisible = false
	self.ImgMetronomeOnVisible = false
	self.ImgMetronomeOffVisible = true
	self.TinyMetronomeVisible = false

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
	self.PanelSideBarVisible = false
	self.CountDownItemVisible = false
	self.BtnCloseVisible = false
	self.PanelSwitchVisible = false
	self.PerformAssistPanelVisible = false
	self.BtnEnsembleVisible = false

	self.HorizontalCountDownVisible = false
	self.ImgCountDown = ""
	self.ImgPendulumAngle = 0
	self.RaidalCDValue = 0

	self.SmallIconPath = ""
	self.BaseIconPath = ""
	self.BigIconPath = ""

	self.MetronomeSetting = nil

	self.ImgRedBgVisible = false
	self.ImgBlueBgVisible = false

	self.OtherCharacterVisiblity = true
	self.IsAnimBtnEnsembleLoopPlaying = false
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