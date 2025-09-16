--[[
Date: 2023-10-23 19:14:46
LastEditors: moody
LastEditTime: 2023-10-23 19:14:46
用于管理音效的申请/释放
--]]
local LuaClass = require("Core/LuaClass")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local ActorUtil = require("Utils/ActorUtil")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local MajorUtil = require("Utils/MajorUtil")
local MPPerformSound = LuaClass()

function MPPerformSound:Ctor()
	self.MulPlayer = nil
	self.IsEnsemble = false		-- 为了解决合奏时队友进出视野的问题，设计上保留多个玩家用一个Sound(MultiPlayer)来播放的功能，但只作用于录制时（暂无需求），别的时候每个角色都使用自己独有的Sound(MultiPlayer)
	self.PlayerList = {}
	self.NoteIndex = 0	-- event的tick需要递增的，这个是音符的时间戳
	self.StartRecordTimeMs = 0
end

function MPPerformSound:InitMulPlayer()
	if self.MulPlayer then
		self:Terminate()
	end

	-- 保证这个事件在内存内
	local AudioUtil = require("Utils/AudioUtil")
	self.MulPlayer = _G.UE.FMusicPerformanceHandler.CreateMultipleMusicPlayer()
	local ID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), "AkAudioEvent'/Game/WwiseAudio/Events/Default_Work_Unit/Play_MusicPlayer.Play_MusicPlayer'")

	local Init = _G.UE.FMusicPerformanceHandler.InitMultiPlayer(self.MulPlayer, "Play_MusicPlayer")
	if Init ~= 0 then
		MusicPerformanceUtil.Err("InitMultiPlayer ErrCode:" .. tostring(Init))
	end

	local Prepare = _G.UE.FMusicPerformanceHandler.Prepare(self.MulPlayer)
	if Prepare ~= 0 then
		MusicPerformanceUtil.Err("PrepareMultiPlayer ErrCode:" .. tostring(Prepare))
	end
end

function MPPerformSound:FinishRecord()
	_G.UE.FMusicPerformanceHandler.Finish(self.MulPlayer)	-- 停止录制
end

function MPPerformSound:StartRecord()
	local RecordRes = _G.UE.FMusicPerformanceHandler.Record(self.MulPlayer, "", 500, 0)
	self.StartRecordTimeMs = _G.TimeUtil.GetServerTimeMS()
	if RecordRes ~= 0 then
		MusicPerformanceUtil.Err("RecordMultiPlayer ErrCode:" .. tostring(RecordRes))
	end
end

function MPPerformSound:ClearMulPlayer()
	if self.MulPlayer then
		MusicPerformanceUtil.Log("MPPerformSound:ClearMulPlayer")
		_G.UE.FMusicPerformanceHandler.Stop(self.MulPlayer)		-- 停止演奏
		_G.UE.FMusicPerformanceHandler.Finish(self.MulPlayer)	-- 停止录制
		_G.UE.FMusicPerformanceHandler.CleanUp(self.MulPlayer)	-- 模块清理
		_G.UE.FMusicPerformanceHandler.DeleteMultipleMusicPlayer(self.MulPlayer)
	end
	self.MulPlayer = nil
end

function MPPerformSound:Initialize()
	self:InitMulPlayer()
	self.PlayerList = {}
end

function MPPerformSound:AddPlayer(EntityID)
	local MaxCount = self.IsEnsemble and MPDefines.EnsembleMemberMax or 1
	if #self.PlayerList > MaxCount then
		MusicPerformanceUtil.Err("MPPerformSound:AddPlayer Count > MaxCount")
		return nil
	end

	local Player = {
		EntityID = EntityID,
		KeyTimers = {},
		MusicPlayer = nil,
		TimbreData = nil,
		TrackID = #self.PlayerList -- 起始从0开始
	}
	table.insert(self.PlayerList, Player)

	-- 创建MusicPlayer
	local MusicPlayer = _G.UE.FMusicPerformanceHandler.CreateTrackPlayer(self.MulPlayer, Player.TrackID,
		_G.UE.UAudioMgr.GetAkGameObjectID(ActorUtil.GetActorByEntityID(Player.EntityID), ""), 
		MusicPerformanceUtil.GetSoundFileName("001grandpiano")	-- 空的音色文件
	)
	Player.MusicPlayer = MusicPlayer

	return #self.PlayerList, Player
end

function MPPerformSound:ChangeTimbre(Player, TimbreData)
	if Player == nil then
		MusicPerformanceUtil.Wrn("MPPerformSound:ChangeTimbre failed because of player nil")
		return
	end

	local OldTimbreID = Player.TimbreData and Player.TimbreData.ID or 0
	local CurTimbreID = TimbreData and TimbreData.ID or 0

	if OldTimbreID == CurTimbreID then
		return
	end

	print("Select " .. TimbreData.Sound)
	self:FinishRecord()		-- 切换音色要中断record
	Player.TimbreData = TimbreData
	_G.UE.FMusicPerformanceHandler.Select(Player.MusicPlayer, MusicPerformanceUtil.GetSoundFileName(TimbreData.Sound))
	self:StartRecord()		--重新Record
end

function MPPerformSound:GetPlayer(EntityID)
	for Index, Player in ipairs(self.PlayerList) do
		if Player.EntityID == EntityID then
			return Index, Player
		end
	end

	return nil
end

function MPPerformSound:Terminate()
	self:Stop()
end

function MPPerformSound:Stop()
	self:ClearMulPlayer()
	self.PlayerList = {}
end

function MPPerformSound:Press(Player, Key, IsKeyOff)
	if Player == nil then
		return
	end

	local MusicPlayer = Player.MusicPlayer
	if MusicPlayer == nil then
		return
	end

	local AffectedKeys = _G.ObjectPoolMgr:AllocCommonTable()
	if Key == MPDefines.KeyOff then
		-- 所有按下的键都EndPress
		for k in pairs(Player.KeyTimers) do
			table.insert(AffectedKeys, k)
		end
	else
		-- 只作用Key
		table.insert(AffectedKeys, Key)
	end

	local IsEndPress = (Key == MPDefines.KeyOff) or IsKeyOff
	for _, AffectedKey in ipairs(AffectedKeys) do
		local TickIndex = _G.TimeUtil.GetServerTimeMS() - self.StartRecordTimeMs
		if IsEndPress then
			self:PressHandler(MusicPlayer, AffectedKey, true, TickIndex, -1, 0)
		else
			if Player.KeyTimers[Key] ~= nil then
				self:PressHandler(MusicPlayer, AffectedKey, true, TickIndex, -1, 0)
			end
			self:PressHandler(MusicPlayer, AffectedKey, false, TickIndex, -1, 0)
		end

		Player.KeyTimers[Key] = not IsEndPress and (Player.TimbreData.Loop == 1 and MPDefines.PlayLimit or MPDefines.ShortPlayLimit) or nil
	end
	_G.ObjectPoolMgr:FreeCommonTable(AffectedKeys)
end

function MPPerformSound:PressHandler(MusicPlayer, Key, IsEndPress, TickIndex, TrackID, DurationTick)
	MusicPerformanceUtil.Log("MPPerformSound:PressHandler  " .. tostring(IsEndPress) .. " " .. tostring(Key))

	if IsEndPress then
		local Res = _G.UE.FMusicPerformanceHandler.EndPress(MusicPlayer, Key, TickIndex, TrackID, DurationTick)
		if Res ~= 0 then
			MusicPerformanceUtil.Err("MPPerformSound:Press EndPress ErrID: " .. tostring(Res) .. " " .. tostring(Key))
		end
	else
		local Res = _G.UE.FMusicPerformanceHandler.Press(MusicPlayer, Key, TickIndex, TrackID, DurationTick)
		if Res ~= 0 then
			MusicPerformanceUtil.Err("MPPerformSound:Press ErrID: " .. tostring(Res) .. " " .. tostring(Key))
		end
	end
end

function MPPerformSound:Play(EntityID, Data, Key, IsKeyOff)
	local Index, Player = self:GetPlayer(EntityID)
	if Player == nil then
		MusicPerformanceUtil.Err("MPPerformSound:Play Player is nil!")
	end
	if Key ~= MPDefines.KeyOff then
		if _G.StoryMgr:SequenceIsPlaying() then
			-- 过场不播放
			return
		end

		local Chara = ActorUtil.GetActorByEntityID(EntityID)
		-- 不在视野
		if Chara == nil then
			return
		end
	end

	-- 更变音色（若音色改变）
	self:ChangeTimbre(Player, Data)
	-- 播放音效
	self:Press(Player, Key, IsKeyOff, Data)
end

function MPPerformSound:Update(DeltaTime)
	for _, Player in ipairs(self.PlayerList) do
		for Index in pairs(Player.KeyTimers) do
			Player.KeyTimers[Index] = Player.KeyTimers[Index] - DeltaTime
			if Player.KeyTimers[Index] <= 0 then
				self:Press(Player, Index, true)	-- 移除按键
			end
		end
	end
end

function MPPerformSound:IsPlay()
	for _, Player in ipairs(self.PlayerList) do
		if table.length(Player.KeyTimers) > 0 then
			return true
		end
	end

	return false
end

return MPPerformSound