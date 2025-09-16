--[[
Date: 2023-10-23 16:02:12
LastEditors: moody
LastEditTime: 2023-10-23 16:02:12
用于管理一组演奏命令数据
--]]
local LuaClass = require("Core/LuaClass")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local MPFrameCommand = require("Game/MusicPerformance/CommandBuffer/MPFrameCommand")

local MPCommandBuffer = LuaClass()

function MPCommandBuffer:Ctor()
	self.Timer = 0
	-- 这里的Frame是网络帧的意思
	self.NetFrameIndexChanged = false
	self.IndexChanged = false
	-- 客户端以0.05s采样一次，由于和本地游戏帧率不一定相同，故Index未改变时，不进行采样
	self:SetCount(0)
	self.FrameIndex = 0

	self.FrameCommands = {}
end

-- function MPCommandBuffer:AddKeyOff()
-- 	MusicPerformanceUtil.AddKeyOff(self.FrameCommands, self:GetMaxCount())
-- end

function MPCommandBuffer:EnsureFrameCommand(Index)
	local FrameCommand = self.FrameCommands[Index]
	if FrameCommand == nil then
		FrameCommand = MPFrameCommand.New()
		self.FrameCommands[Index] = FrameCommand
	end
	return FrameCommand
end

function MPCommandBuffer:ClearFrameCommands()
	for _, FrameCommand in pairs(self.FrameCommands) do
		FrameCommand:Clear()
	end
end

function MPCommandBuffer:GetCount()
	return self.Count
end

function MPCommandBuffer:GetMaxCount()
	return MPDefines.PerformCommandMax
end

function MPCommandBuffer:GetIndex()
	return self.Index
end

function MPCommandBuffer:Next()
	if self.Index > self.Count then
		MusicPerformanceUtil.Log(" MPCommandBuffer:Next Index invalid")
	end
	self.Index = self.Index + 1

	return self.Index >= self.Count
end

function MPCommandBuffer:Clear()
	self:SetCount(0)
	self:ClearFrameCommands()
end

function MPCommandBuffer:SetCount(Count)
	self.Index = 0
	self.Count = Count
end

function MPCommandBuffer:CanSendImp()
	return self.NetFrameIndexChanged
end

function MPCommandBuffer:Add(Command, Timbre)
	Timbre = Timbre or 0
	self:SetCommandImp(self.Index, Command, Timbre, false)
end

-- 同帧触发按下/释放 不算长按（不知道有没有这种情况）
-- 第一帧就进行Release，直接不做上报
-- 若持续按住至FrameIndex改变，首帧就会算作长按触发
-- 即，长按时某个Key的数量为单数时，该Key为按下，为双数时为释放
function MPCommandBuffer:AddLongPress(Command, Timbre, IsRelease, IsStateChanged)
	MusicPerformanceUtil.Log(string.format("MPCommandBuffer:AddLongPress Index:%d, Command:%d, Timbre:%d, IsRelease:%s, IsStateChanged:%s",
		self.Index, Command, Timbre, tostring(IsRelease), tostring(IsStateChanged)))

	-- NetFrameIndexChanged时需要特殊处理
	if self.NetFrameIndexChanged then
		if self.Index == 0 and IsRelease then
			-- 第一帧就进行Release，直接不做上报
			return MPDefines.KeyOff
		else
			if not IsStateChanged or IsRelease then
				-- 若是持续按住至FrameIndex改变或者是主动Release，首帧就会算作长按触发
				-- 此处主要用于做断线重连时的状态更新，每个包开头都具有按下的按键的按下信息
				self:SetCommandImp(0, Command, Timbre, false)
			end
		end
	end

	if IsStateChanged then
		self:SetCommandImp(self.Index, Command, Timbre, IsRelease)
		if IsRelease then
			return MPDefines.KeyOff
		else
			return Command
		end
	end
end

function MPCommandBuffer:SendImp()
end

function MPCommandBuffer:SetCommandImp(Index, Command, Timbre, IsKeyOff)
end

---@return MPFrameCommand
function MPCommandBuffer:GetCommandImp(Index)
	return self.FrameCommands[Index], Index
end

function MPCommandBuffer:GetFrameIntervalImp()
	return MPDefines.SendInterval
end

function MPCommandBuffer:UpdateIndex(DeltaTime)
	self.Timer = self.Timer + DeltaTime
	if self.Timer < 0 then
		return false, false
	end
	--print("MPCommandBuffer:UpdateIndex", self.Timer)
	-- 网络帧的变化
	local CurFrameIndex = math.floor(self.Timer / self:GetFrameIntervalImp())
	self.NetFrameIndexChanged = CurFrameIndex ~= self.FrameIndex
	self.PrevFrameIndex = self.FrameIndex
	self.FrameIndex = CurFrameIndex
	-- 采样帧的变化
	local CurIndex = math.floor(self.Timer / MPDefines.PlayInterval) % (self:GetMaxCount() ~= 0 and self:GetMaxCount() or 1)
	self.IndexChanged = CurIndex ~= self.Index
	self.Index = CurIndex

	--print("MPCommandBuffer:UpdateIndex", self.FrameIndex, self.Index, self.NetFrameIndexChanged, self.IndexChanged, self.Timer, self.PrevFrameIndex)
	return self.IndexChanged or self.NetFrameIndexChanged
end

return MPCommandBuffer