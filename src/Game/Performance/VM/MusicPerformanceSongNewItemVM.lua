local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class MusicPerformanceSongNewItemVM : UIViewModel
local MusicPerformanceSongNewItemVM = LuaClass(UIViewModel)

---Ctor
function MusicPerformanceSongNewItemVM:Ctor()
	self.TextName = ""
	self.ImgSelectVisible = false
	self.ImgNoteLightVisible = false

	self.IsSelected = false
end

function MusicPerformanceSongNewItemVM:OnInit()
end

function MusicPerformanceSongNewItemVM:OnBegin()
end

function MusicPerformanceSongNewItemVM:OnEnd()
end

function MusicPerformanceSongNewItemVM:OnShutdown()
end

return MusicPerformanceSongNewItemVM