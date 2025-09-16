--[[
Date: 2024-03-19 20:13:20
LastEditors: moody
LastEditTime: 2024-03-19 20:13:20
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class PerformanceSongDetailPageVM : UIViewModel
local PerformanceSongDetailPageVM = LuaClass(UIViewModel)

---Ctor
function PerformanceSongDetailPageVM:Ctor()
	--self.TextName = ""
	self.TextTime = ""
	self.TextBPM = ""
	self.TextBeat = ""
	self.TextSpeed = ""

	self.Speed = 1.0
	self.ToggleMetronome = false
	self.SongIndex = 0

	self.PerformName = ""
	self.SmallIconPath = ""
	self.BaseIconPath = ""
	self.BigIconPath = ""

	self.PanelElectricGuitarVisible = false
	self.ImgModePath = ""
end

function PerformanceSongDetailPageVM:OnInit()
end

function PerformanceSongDetailPageVM:OnBegin()
end

function PerformanceSongDetailPageVM:OnEnd()
end

function PerformanceSongDetailPageVM:OnShutdown()
end

return PerformanceSongDetailPageVM