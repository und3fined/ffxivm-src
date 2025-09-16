local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MusicPerformanceEnsembleWinVM : UIViewModel
local MusicPerformanceEnsembleWinVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceEnsembleWinVM:Ctor()
	self.PanelAssistantIntroVisible = false
	self.PanelProBarVisible = false
	self.TextTipsVisible = false
	self.PanelEnsembleListenVisible = false
	self.TextELVisible = false

	self.BtnStartIsEnable = false
	self.BtnKeepIsEnable = false
	self.BtnCancelIsEnable = false

	self.PlayerList = {}
	self.ProBarValue = 0
	self.Time = 0
	self.TextBPM = ""
	self.TextBEAT = ""
	self.TextAssistant = ""
	self.TextTips = ""
	self.TextBtnStart = ""
	self.TextEL = ""
end

function MusicPerformanceEnsembleWinVM:OnInit()
end

function MusicPerformanceEnsembleWinVM:OnBegin()
end

function MusicPerformanceEnsembleWinVM:OnEnd()
end

function MusicPerformanceEnsembleWinVM:OnShutdown()
end

return MusicPerformanceEnsembleWinVM