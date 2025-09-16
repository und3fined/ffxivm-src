--[[
Date: 2023-10-23 20:11:01
LastEditors: moody
LastEditTime: 2023-10-23 20:11:02
用于管理一个角色的合奏数据
--]]
local LuaClass = require("Core/LuaClass")
local MPPlayBuffer = require("Game/MusicPerformance/PlayBuffer/MPPlayBuffer")
local MPEnsembleBuffer = require("Game/MusicPerformance/CommandBuffer/MPEnsembleBuffer")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MPPerformSound = require("Game/MusicPerformance/Sound/MPPerformSound")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local MPEnsemblePlayBuffer = LuaClass(MPPlayBuffer)

function MPEnsemblePlayBuffer:Ctor()
	self.Buffer = {}
	self.Sound = MPPerformSound.New()
end

function MPEnsemblePlayBuffer:InitializeSound(EntityID)
	self.Sound:Initialize()
	self.Sound:AddPlayer(EntityID)
	self.Sound:StartRecord()
end

function MPEnsemblePlayBuffer:ClearSound()
	self.Sound:Terminate()
end

function MPEnsemblePlayBuffer:EnsureBuffer(Index)
	if Index < self:GetBufferCountImp() then
		if nil ~= self.Buffer[Index] then
			return self.Buffer[Index]
		else
			local Buffer = MPEnsembleBuffer.New()
			self.Buffer[Index] = Buffer
			return Buffer
		end
	end
	MusicPerformanceUtil.Log(" MPEnsemblePlayBuffer:EnsureBuffer Index invalid! " .. Index)
	return nil
end

function MPEnsemblePlayBuffer:Set(Data)
	if self.Count >= MPDefines.EnsembleBufferReceiveMax then
		-- 由于缓冲区过度，所以丢弃当前的缓冲区并将其存储
		self:Next()
		MusicPerformanceUtil.Log(" MPEnsemblePlayBuffer:Set Count Overflow! ")
	end
	local Index = self:GetBufferIndex()
	local Buffer = self:EnsureBuffer(Index)
	if Buffer then
		Buffer:Set(Data)
	end
	self:Add()
end

function MPEnsemblePlayBuffer:GetCommandBufferImp()
	return self.Buffer[self.Index]
end

function MPEnsemblePlayBuffer:GetBufferCountImp()
	return MPDefines.EnsembleBufferReceiveMax
end

return MPEnsemblePlayBuffer