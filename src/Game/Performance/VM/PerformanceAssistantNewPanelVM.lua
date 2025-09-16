--[[
Date: 2024-05-17 16:56:44
LastEditors: moody
LastEditTime: 2024-05-17 16:56:44
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PerformanceAssistantNewPanelVM : UIViewModel
local PerformanceAssistantNewPanelVM = LuaClass(UIViewModel)

---Ctor
function PerformanceAssistantNewPanelVM:Ctor()
	self:Clear()
end

function PerformanceAssistantNewPanelVM:Clear()
	self.TextSongName = ""
	self.TextScore = ""
	self.TinyMetronomeVisible = false
	self.BtnPauseVisible = false
	self.FinishPageVisible = false
	self.Percent = 0

	self.PanelTrackVisible = false
	self.PanelTrackAllVisible = false
	-- self.MonoKeyVisible = false
	-- self.MonoLargeKeyVisible = false
	-- self.PerformanceFullKeyVisible = false
	-- self.PerformanceFullLargeKeyVisible = false

	self.ImgRedBgVisible = false
	self.ImgBlueBgVisible = false
end

function PerformanceAssistantNewPanelVM:OnInit()
end

function PerformanceAssistantNewPanelVM:OnBegin()
end

function PerformanceAssistantNewPanelVM:OnEnd()
end

function PerformanceAssistantNewPanelVM:OnShutdown()
end

return PerformanceAssistantNewPanelVM