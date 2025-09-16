--[[
Date: 2023-10-23 16:37:50
LastEditors: moody
LastEditTime: 2023-10-23 16:37:50
用于管理一组演奏命令数据
--]]
local LuaClass = require("Core/LuaClass")
local MPCommandBuffer = require("Game/MusicPerformance/CommandBuffer/MPCommandBuffer")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local ProtoCS = require ("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local CS_CMD = ProtoCS.CS_CMD
local PERFORM_CMD = ProtoCS.PerformCmd

local MPPerformBuffer = LuaClass(MPCommandBuffer)

function MPPerformBuffer:Ctor()
end

function MPPerformBuffer:Set(MsgBody)
	-- if Data.Count > MPDefines.PerformCommandMax then
	-- 	MusicPerformanceUtil.Log(" MPPerformBuffer:Set Data.Count error " .. Data.Count)
	-- 	return
	-- end

	self:Clear()
	MusicPerformanceUtil.DecodeFrameCommands(MsgBody.Data.Command, self)

	self:SetCount(MPDefines.PerformCommandMax)
end

function MPPerformBuffer:SetCommandImp(Index, Command, Timbre, IsKeyOff)
	if Index > MPDefines.PerformCommandMax then
		MusicPerformanceUtil.Log(" MPPerformBuffer:SetCommand Index error " .. Index)
		return
	end
	-- print("MPPerformBuffer:SetCommandImp", Index, Command)

	local FrameCommand = self:EnsureFrameCommand(Index)
	if FrameCommand then
		FrameCommand:AddCommand(Command, Timbre, IsKeyOff)
	end
end

---@return MPFrameCommand
function MPPerformBuffer:GetCommandImp(Index)
	Index = Index or self.Index
	return self.FrameCommands[Index], Index
end

-- function MPPerformBuffer:CanSendImp()
-- 	return self:GetCount() == MPDefines.PerformCommandMax
-- end

function MPPerformBuffer:SendImp()
	local Count = self:GetMaxCount()
	if Count == 0 then
		return
	end

	if Count <= MPDefines.PerformCommandMax then
		-- local Encode = MusicPerformanceUtil.EncodeList(self.Command, self:GetMaxCount(), MPDefines.Command.COMMAND_ID_REST)
		-- local Decode = MusicPerformanceUtil.DecodeList(Encode, MPDefines.PerformCommandMax, MPDefines.Command.COMMAND_ID_REST)
		-- print("Command:" .. table.tostring(self.Command))
		-- print("Decode:" .. table.tostring(Decode))
		--print("#Command:" .. tostring(#Decode))

		-- for i = Count, MPDefines.PerformCommandMax - 1 do
		-- 	Command[i] = 0
		-- 	Timbre[i] = 0
		-- end

		-- DO Send
		local MsgID = CS_CMD.CS_CMD_PERFORM
		local SubID = PERFORM_CMD.PerformCmdPerform
		local MsgBody = {
			Cmd = SubID,
			Perform = {
				Data = {
					Command = MusicPerformanceUtil.EncodeFrameCommands(self.FrameCommands)
				}
			}
		}

		GameNetworkMgr:SendMsg(MsgID, SubID, MsgBody)
	else
		MusicPerformanceUtil.Log(" MPPerformBuffer:SendImp Count error " .. Count)
	end
	self:Clear()
end

function MPPerformBuffer:Initialize()
	self:Clear()
	self.FrameIndex = 0
end

return MPPerformBuffer