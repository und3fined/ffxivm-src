--[[
Date: 2024-03-14 15:42:13
LastEditors: moody
LastEditTime: 2024-03-14 15:42:13
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PerformanceRewardItemVM : UIViewModel
local PerformanceRewardItemVM = LuaClass(UIViewModel)

---Ctor
function PerformanceRewardItemVM:Ctor()
	self.TextDescriptionVisible = true
	self.TextDescriptionColor = ""
	self.TextDescription = ""
	self.ImgNextBgVisible = false
	self.ImgScorePtah = ""
	self.ImgScoreVisible = false
	self.ScoreLevel = nil
end

function PerformanceRewardItemVM:OnInit()
end

function PerformanceRewardItemVM:OnBegin()
end

function PerformanceRewardItemVM:OnEnd()
end

function PerformanceRewardItemVM:OnShutdown()
end

return PerformanceRewardItemVM