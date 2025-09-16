--[[
Date: 2024-04-30 16:03:56
LastEditors: moody
LastEditTime: 2024-04-30 16:03:56
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PerformanceSongNewPanelVM : UIViewModel
local PerformanceSongNewPanelVM = LuaClass(UIViewModel)

---Ctor
function PerformanceSongNewPanelVM:Ctor()
	self.TableViewSongsList = nil
	self.TextName = ""
	self.TextBPM = ""
	self.TextBeat = ""
	self.TextSpeed = ""
	self.SpeedValue = 0

	self.SelectedSong = nil
	self.ToggleMetronome = true
	self.PerformName = ""
	self.SmallIconPath = ""
	self.BaseIconPath = ""
	self.BigIconPath = ""

	self.PanelElectricGuitarVisible = false
	self.ImgModePath = ""
end

function PerformanceSongNewPanelVM:OnInit()
end

function PerformanceSongNewPanelVM:OnBegin()
end

function PerformanceSongNewPanelVM:OnEnd()
end

function PerformanceSongNewPanelVM:OnShutdown()
end

return PerformanceSongNewPanelVM