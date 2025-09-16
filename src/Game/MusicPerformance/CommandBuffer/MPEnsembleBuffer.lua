--[[
Date: 2023-10-23 16:37:50
LastEditors: moody
LastEditTime: 2023-10-23 16:37:50
用于管理一组合奏命令数据
--]]
local LuaClass = require("Core/LuaClass")
local MPCommandBuffer = require("Game/MusicPerformance/CommandBuffer/MPCommandBuffer")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local ProtoCS = require ("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local GameNetworkMgr = require("Network/GameNetworkMgr")

local CS_CMD = ProtoCS.CS_CMD
local PERFORM_CMD = ProtoCS.PerformCmd

local MPEnsembleBuffer = LuaClass(MPCommandBuffer)

function MPEnsembleBuffer:Ctor()
	self.SendIndex = 0
end

--  对齐协议
function MPEnsembleBuffer:Set(MsgBody)
	-- if Data.Count > MPDefines.EnsembleCommandMax then
	-- 	MusicPerformanceUtil.Log(" MPEnsembleBuffer:Set Data.Count error " .. Data.Count)
	-- 	return
	-- end
	self:Clear()
	MusicPerformanceUtil.DecodeFrameCommands(MsgBody.Data.Command, self)
	self:SetCount(MPDefines.EnsembleCommandMax)
end

function MPEnsembleBuffer:SetCommandImp(Index, Command, Timbre, IsKeyOff)
	if Index > MPDefines.EnsembleCommandMax then
		MusicPerformanceUtil.Log(" MPEnsembleBuffer:SetCommand Index error " .. Index)
		return
	end
	local FrameCommand = self:EnsureFrameCommand(Index)
	if FrameCommand then
		FrameCommand:AddCommand(Command, Timbre, IsKeyOff)
	end
end

function MPEnsembleBuffer:Initialize()
	self:Clear()
	self.FrameIndex = 0
	self.SendIndex = 0
end

---@return MPFrameCommand
function MPEnsembleBuffer:GetCommandImp(Index)
	-- todo 因为合奏的情况下，后台可能没有及时收到指令就下发了空包，未及时清掉长按的键，后续这里需要支持多键情况下的处理
	Index = Index or self.Index
	return self.FrameCommands[Index], Index
end

function MPEnsembleBuffer:GetMaxCount()
	return MPDefines.EnsembleCommandMax
end

-- function MPEnsembleBuffer:CanSendImp()
-- 	return self:GetCount() == MPDefines.EnsembleCommandMax
-- end

function MPEnsembleBuffer:GetFrameIntervalImp()
	return MPDefines.EnsembleInterval
end

function MPEnsembleBuffer:SendImp()
	local Count = self:GetMaxCount()
	if Count == 0 then
		return
	end

	if Count <= MPDefines.EnsembleCommandMax then
		local Flag = 0
		for i = 0, Count - 1 do
			local FrameCommand = self.FrameCommands[i]

			if FrameCommand and FrameCommand:GetCount() > 0 then
				Flag = 1
			end
		end

		-- for i = Count, MPDefines.EnsembleCommandMax - 1 do
		-- 	Command[i] = 0
		-- 	Timbre[i] = 0
		-- end
		
		-- DO Send
		local MsgID = CS_CMD.CS_CMD_PERFORM
		local SubMsgID = PERFORM_CMD.EnsembleCmdEnsemble
		local MsgBody = {
			Cmd = SubMsgID,
			Ensemble = {
				Index = self.PrevFrameIndex,
				Flag = Flag,
				Data = {
					Command = MusicPerformanceUtil.EncodeFrameCommands(self.FrameCommands),
				}
			}
		}

		GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	else
		MusicPerformanceUtil.Log(" MPEnsembleBuffer:SendImp Count error " .. Count)
	end

	self:Clear()
end

return MPEnsembleBuffer