--[[
Date: 2023-10-24 10:31:22
LastEditors: moody
LastEditTime: 2023-10-24 10:31:22
--]]
local LuaClass = require("Core/LuaClass")

local MPPlayData = LuaClass()

function MPPlayData:Ctor()
	self:Initialize()
end

function MPPlayData:Initialize()
	self.IdleTimeline = ""
	self.KeyTimeline = ""
	self.KeyLoopTimeline = ""
	self.Loop = false
end

function MPPlayData:Set(Data, Index)
	self.IdleTimeline = Data.IdleTimeline
	print("Timeline" .. tostring(Index) .. tostring(Data["Timeline" .. tostring(Index)]))
	self.KeyTimeline = Data["Timeline" .. tostring(Index)]
	self.KeyLoopTimeline = Data["LoopTimeline" .. tostring(Index)]
	self.Loop = Data.Loop
end

return MPPlayData