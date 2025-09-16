--[[
Date: 2023-10-23 20:11:01
LastEditors: moody
LastEditTime: 2023-10-23 20:11:02
用于管理一个角色的演奏数据
--]]
local LuaClass = require("Core/LuaClass")
local MPPlayBuffer = require("Game/MusicPerformance/PlayBuffer/MPPlayBuffer")
local MPPerformBuffer = require("Game/MusicPerformance/CommandBuffer/MPPerformBuffer")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MPPerformSound = require("Game/MusicPerformance/Sound/MPPerformSound")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local MPPerformPlayBuffer = LuaClass(MPPlayBuffer)

function MPPerformPlayBuffer:Ctor()
	self.Buffer = {}
	self.Sound = MPPerformSound.New()
end

function MPPerformPlayBuffer:InitializeSound(EntityID)
	self.Sound:Initialize()
	self.Sound:AddPlayer(EntityID)
	self.Sound:StartRecord()
end

function MPPerformPlayBuffer:ClearSound()
	self.Sound:Terminate()
end

function MPPerformPlayBuffer:EnsureBuffer(Index)
	if Index < self:GetBufferCountImp() then
		if nil ~= self.Buffer[Index] then
			return self.Buffer[Index]
		else
			local Buffer = MPPerformBuffer.New()
			self.Buffer[Index] = Buffer
			return Buffer
		end
	end
	MusicPerformanceUtil.Log(" MPPerformPlayBuffer:EnsureBuffer Index invalid! " .. Index)
	return nil
end

function MPPerformPlayBuffer:Set(Data)
	if self.Count >= MPDefines.PerformBufferReceiveMax then
		self:Next()
		MusicPerformanceUtil.Log(" MPPerformPlayBuffer:Set Count Overflow! ")
	end
	local Index = self:GetBufferIndex()
	local Buffer = self:EnsureBuffer(Index)
	if Buffer then
		Buffer:Set(Data)
	end
	self:Add()
end

function MPPerformPlayBuffer:GetCommandBufferImp()
	return self.Buffer[self.Index]
end

function MPPerformPlayBuffer:GetBufferCountImp()
	return MPDefines.PerformBufferReceiveMax
end

return MPPerformPlayBuffer