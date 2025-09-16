--[[
Date: 2023-10-23 20:46:50
LastEditors: moody
LastEditTime: 2023-10-23 20:46:51
用于管理一组合奏的Buffer
--]]
local LuaClass = require("Core/LuaClass")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MPEnsemblePlayBuffer = require("Game/MusicPerformance/PlayBuffer/MPEnsemblePlayBuffer")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local MPEnsembleWork = LuaClass()

function MPEnsembleWork:Ctor()
	self.PlayBuffers = {}
	self.PartyID = 0
	self.UseFlag = false
end

---@return MPEnsemblePlayBuffer
function MPEnsembleWork:GetPlayBuffer(Index)
	if Index >= MPDefines.EnsembleMemberMax then
		MusicPerformanceUtil.Log(" MPEnsembleWork:GetPlayBuffer Index Error " .. Index)
		return
	end

	local Buffer = self.PlayBuffers[Index]
	if Buffer == nil then
		Buffer = MPEnsemblePlayBuffer.New()
		self.PlayBuffers[Index] = Buffer
	end
	return Buffer
end

function MPEnsembleWork:Initialize()
	-- for i = 0, MPDefines.EnsembleMemberMax - 1 do
	-- 	local Buffer = self:GetPlayBuffer(i)
	-- 	if Buffer then
	-- 		Buffer:Initialize()
	-- 	end
	-- end
	self.PartyID = 0
	self.UseFlag = false
end

function MPEnsembleWork:InitializeByData(MsgBody)
	for i = 0, MPDefines.EnsembleMemberMax - 1 do
		local Buffer = self:GetPlayBuffer(i)
		if Buffer then
			Buffer:Clear()
			local Ensemble = MsgBody.Ensemble[i + 1] or {}
			local EntityID = Ensemble.EntityID or 0
			if EntityID > 0 then
				Buffer:Initialize(EntityID)
				Buffer:Set(MsgBody.Ensemble[i + 1])
			end
		end
	end
	-- 以合奏的第一个角色的EntityID作为PartyID
	self.PartyID = MusicPerformanceUtil.GetPartyID(MsgBody)
	self.UseFlag = true

	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceEnsembleWorkStart)
end

function MPEnsembleWork:Clear()
	for i = 0, MPDefines.EnsembleMemberMax - 1 do
		local Buffer = self.PlayBuffers[i]
		if Buffer then
			Buffer:Clear()
		end
	end
	self.PartyID = 0
	self.UseFlag = false
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceEnsembleWorkClear)
end

function MPEnsembleWork:IsUse()
	return self.UseFlag
end

function MPEnsembleWork:GetPartyID()
	return self.PartyID
end

function MPEnsembleWork:Set(SingleCommandData)
	for i = 0, MPDefines.EnsembleMemberMax - 1 do
		local Buffer = self:GetPlayBuffer(i)
		if Buffer and Buffer.EntityID == SingleCommandData.EntityID then
			Buffer:Set(SingleCommandData)
			break
		end
	end
end

return MPEnsembleWork