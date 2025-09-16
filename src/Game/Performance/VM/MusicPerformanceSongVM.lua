local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class MusicPerformanceSongVM : UIViewModel
local MusicPerformanceSongVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceSongVM:Ctor()
	self:Clear()
end

function MusicPerformanceSongVM:Clear()
	self.Config = nil
	self.ScoreLevel = 0
	self.Name = ""
	self.Time = 0
	self.Beat1 = 0
	self.Beat2 = 0
	self.BPM = 0
end

function MusicPerformanceSongVM:SetConfig(Config)
	self.Config = Config
	self.Time = Config.Time
	self.Name = Config.Name
	self.Beat1 = Config.Beat_01
	self.Beat2 = Config.Beat_02
	self.BPM = Config.BPM
end

function MusicPerformanceSongVM:OnInit()
end

function MusicPerformanceSongVM:OnBegin()
end

function MusicPerformanceSongVM:OnEnd()
end

function MusicPerformanceSongVM:OnShutdown()
end

return MusicPerformanceSongVM