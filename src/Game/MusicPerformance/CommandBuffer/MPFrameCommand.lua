--[[
Date: 2024-2-22 10:45:12
LastEditors: moody
LastEditTime: 2024-2-22 10:45:12
记录单帧的数据列表
--]]
local LuaClass = require("Core/LuaClass")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
-- local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
-- local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local MPFrameCommand = LuaClass()

function MPFrameCommand:Ctor()
	self.Commands = {}
	self:Clear()
end

function MPFrameCommand:Clear()
	self.Count = 0
	_G.TableTools.ClearTable(self.Commands)
end

function MPFrameCommand:AddCommand(Command, Timbre, IsKeyOff)
	self.Count = self.Count + 1
	table.insert(self.Commands, Timbre)
	table.insert(self.Commands, Command)
	table.insert(self.Commands, IsKeyOff)
end

function MPFrameCommand:UpdateCommand(CommandIndex, Command, Timbre, IsKeyOff)
	if self.Count < CommandIndex then
		MusicPerformanceUtil.Err("MPFrameCommand:UpdateCommand CommandIndex > Count")
	else
		local StartIndex = self:GetStartIndex(CommandIndex)
		self.Commands[StartIndex + 1], self.Commands[StartIndex + 2], self.Commands[StartIndex + 3] = Command, Timbre, IsKeyOff
	end
end

function MPFrameCommand:GetStartIndex(CommandIndex)
	return (CommandIndex - 1) * 3 -- 0 3 6
end

-- Index从1开始
-- (Command, Timbre, IsKeyOff)
function MPFrameCommand:GetCommand(CommandIndex)
	if self.Count < CommandIndex then
		MusicPerformanceUtil.Err("MPFrameCommand:GetCommand Index > Count")
		return nil
	end

	local StartIndex = self:GetStartIndex(CommandIndex)
	return self.Commands[StartIndex + 1], self.Commands[StartIndex + 2], self.Commands[StartIndex + 3] -- (1,2,3) (4,5,6) (Command, Timbre, IsKeyOff)
end

function MPFrameCommand:GetCount()
	return self.Count
end

return MPFrameCommand