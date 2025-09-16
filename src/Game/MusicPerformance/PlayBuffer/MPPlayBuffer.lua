--[[
Date: 2023-10-23 17:23:50
LastEditors: moody
LastEditTime: 2023-10-23 17:23:50
用于管理一个角色的演奏数据 
--]]
local LuaClass = require("Core/LuaClass")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local MPPlayBuffer = LuaClass()

function MPPlayBuffer:Ctor()
	self.EntityID = 0
	self.Index = 0
	self.Count = 0
	self.Timer = 0
	self.Status = MPDefines.PlayBufferStatus.STS_WAIT
	self.IsKeyOff = false
end

function MPPlayBuffer:SetWork(EntityID)
	self.EntityID = EntityID
	self.Index = 0
	self.Count = 0
	self.Timer = 0
	self.Status = MPDefines.PlayBufferStatus.STS_WAIT
	self.IsKeyOff = false
end

function MPPlayBuffer:InitializeSound(EntityID)
end

function MPPlayBuffer:ClearSound()
end

function MPPlayBuffer:Initialize(EntityID)
	self:SetWork(EntityID)
	self:InitializeSound(EntityID)
end

function MPPlayBuffer:Clear()
	self:SetWork(0)
	self:ClearSound()
end

function MPPlayBuffer:GetBufferIndex()
	return (self.Index + self.Count) % self:GetBufferCountImp()
end

function MPPlayBuffer:GetBufferCountImp()
	return 1
end

function MPPlayBuffer:GetCommandBufferImp()
	return nil
end

function MPPlayBuffer:Next()
	if self.Count == 0 then
		MusicPerformanceUtil.Log(" MPPlayBuffer:Next Count == 0")
		return false
	end

	self.Index = self.Index + 1
	if self.Index >= self:GetBufferCountImp() then
		self.Index = 0
	end

	self.Count = self.Count - 1
	return self.Count > 0
end

function MPPlayBuffer:Add()
	self.Count = self.Count + 1
	if self.Status == MPDefines.PlayBufferStatus.STS_RELEASE then
		self.Timer = 0
		self.Status = MPDefines.PlayBufferStatus.STS_WAIT
		self.IsKeyOff = false
	end
end

return MPPlayBuffer