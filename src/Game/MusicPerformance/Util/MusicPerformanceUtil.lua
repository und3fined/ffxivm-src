local MusicPerformanceUtil = {}

local BitUtil = require("Utils/BitUtil")
local InstrumentCfg = require("TableCfg/InstrumentCfg")
local InstrumentGroupCfg = require("TableCfg/InstrumentGroupCfg")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local SaveKey = require("Define/SaveKey")
local ProtoRes = require("Protocol/ProtoRes")
local ActorUtil = require("Utils/ActorUtil")
local AudioUtil = require("Utils/AudioUtil")

function MusicPerformanceUtil.GetPerformData(ID)
	return InstrumentCfg:FindCfgByKey(ID)
end

function MusicPerformanceUtil.GetPerformGroupData(ID)
	return InstrumentGroupCfg:FindCfgByKey(ID)
end

function MusicPerformanceUtil.IsMPMode()
	return false
end

-- 是否延迟自己的播放至与队友同步后
function MusicPerformanceUtil.IsPerformanceSyncedWithParty()
	return _G.UE.USaveMgr.GetInt(SaveKey.EnsembleMode, MPDefines.Ensemble.DefaultSettings.Mode, true)
		== MPDefines.Ensemble.DefaultSettings.Mode
end

function MusicPerformanceUtil.SavePerformanceSyncedWithParty(Mode)
	_G.UE.USaveMgr.SetInt(SaveKey.EnsembleMode, Mode, true)
end

-- function MusicPerformanceUtil.IsOtherPerformanceMuted()
-- 	return _G.UE.USaveMgr.GetInt(SaveKey.PerformanceOtherMuted, MPDefines.CommonSettings.OtherMuted and 1 or 0, true) == 1
-- end

-- -- 将偶数的Key转换为KeyOff
-- function MusicPerformanceUtil.AddKeyOff(FrameCommands, CountMax)
-- 	local Counter = {}
-- 	for FrameCommandIndex = 1, CountMax do
-- 		local FrameCommand = FrameCommands[FrameCommandIndex]

-- 		-- 用and or顺便判空FrameCommand
-- 		for CommandIndex = 1, (FrameCommand and FrameCommand:GetCount() or 0) do
-- 			local Key, Timbre, IsKeyOff = FrameCommand:GetCommand(CommandIndex)
-- 			if FrameCommandIndex and Key ~= MPDefines.Command.COMMAND_ID_KEY_OFF and Key ~= MPDefines.Command.COMMAND_ID_REST then
-- 				local Count = (Counter[Key] or 0) + 1
-- 				Counter[Key] = Count
-- 				if Count % 2 == 0 then
-- 					FrameCommand:UpdateCommand(CommandIndex, Key, Timbre, true)
-- 				end
-- 			end
-- 		end
-- 	end
-- end

function MusicPerformanceUtil.EncodeFrameCommands(FrameCommands)
	local Bytes = {}
	-- print("EncodeFrameCommands:" .. table.tostring(FrameCommands))
	for FrameIndex, FrameCommand in pairs(FrameCommands) do
		if FrameCommand then
			local CommandCount = FrameCommand:GetCount()
			for i = 1, CommandCount do
				local Command, Timbre, IsKeyOff = FrameCommand:GetCommand(i)
				if Timbre then
					-- (FrameIndex, Command, Timbre)
					table.insert(Bytes, FrameIndex)
					table.insert(Bytes, Timbre)
					table.insert(Bytes, Command)
				end
			end
		end
	end
	return BitUtil.ByteArrayToString(Bytes)
end

function MusicPerformanceUtil.DecodeFrameCommands(BytesString, CommandBuffer)
	local CommandParamsCount = 3	-- 
	local Bytes = BitUtil.StringToByteArray(BytesString)
	local BytesCount = #Bytes
	local CommandCount = math.floor(BytesCount / 3)
	if BytesCount % CommandParamsCount ~= 0 then
		MusicPerformanceUtil.Wrn("Bytes Count invalid!")
	end

	for i = 1, CommandCount do
		local CommandIndex = (i - 1) * 3
		local Index = Bytes[CommandIndex + 1]
		local Timbre = Bytes[CommandIndex + 2]
		local Command = Bytes[CommandIndex + 3]
		CommandBuffer:SetCommandImp(Index, Command, Timbre, false)	-- 这里不控制KeyOff，只写入Command信息
	end

	--print("DecodeFrameCommands:" .. table.tostring(CommandBuffer.FrameCommands))
end

function MusicPerformanceUtil.DecodeList(ListString, CountMax, DefaultValue)
	local Bytes = BitUtil.StringToByteArray(ListString)
	local List = {}
	local BytesIndex = 1
	local IsEmpty = true
	for i = 0, CountMax - 1 do
		local CurIndex = Bytes[BytesIndex]
		if CurIndex == i then
			List[i] = Bytes[BytesIndex + 1] or DefaultValue
			BytesIndex = BytesIndex + 2
		else
			List[i] = DefaultValue
		end

		if List[i] ~= DefaultValue then
			IsEmpty = false
		end
	end

	return List, IsEmpty
end

function MusicPerformanceUtil.GetPartyID(EnsembleData)
	return EnsembleData.Owner
end

function MusicPerformanceUtil.Log(Msg)
	if MPDefines.DEBUG then
		print("[MP]" .. Msg)
	end
end

function MusicPerformanceUtil.Err(Msg)
	if MPDefines.DEBUG then
		FLOG_ERROR("[MP] " .. Msg)
	end
end

function MusicPerformanceUtil.Wrn(Msg)
	if MPDefines.DEBUG then
		FLOG_WARNING("[MP] " .. Msg)
	end
end

function MusicPerformanceUtil.GetInstrumentTypeName(Type)
	local Type2Name = {
		[0] = _G.LSTR(830050),
		[1] = _G.LSTR(830051),
		[2] = _G.LSTR(830052),
	}
	return Type2Name[Type] or ""
end

function MusicPerformanceUtil.GetBPM()
	return _G.UE.USaveMgr.GetInt(SaveKey.MetronomeBPM, MPDefines.MetronomeSettings.DefaultSetting.BPM, true)
end

function MusicPerformanceUtil.GetBeatPerBar()
	return _G.UE.USaveMgr.GetInt(SaveKey.MetronomeBeatPerBarCount, MPDefines.MetronomeSettings.DefaultSetting.BeatPerBar, 4, true)
end

function MusicPerformanceUtil.GetBarOffset(IsPrepare)
	if IsPrepare ~= nil then
		return IsPrepare == 1 and -2 or 0
	end
	return _G.UE.USaveMgr.GetInt(SaveKey.MetronomePrepare, MPDefines.MetronomeSettings.DefaultSetting.Prepare, true) == 1 and -2 or 0
end

function MusicPerformanceUtil.GetMetronomePrepare()
	return _G.UE.USaveMgr.GetInt(SaveKey.MetronomePrepare, MPDefines.MetronomeSettings.DefaultSetting.Prepare, true)
end

function MusicPerformanceUtil.GetMetronomeEffect()
	return _G.UE.USaveMgr.GetInt(SaveKey.MetronomeEffect, MPDefines.MetronomeSettings.DefaultSetting.Effect, true)
end

function MusicPerformanceUtil.GetMetronomeVolume()
	return _G.UE.USaveMgr.GetInt(SaveKey.MetronomeVolume, MPDefines.MetronomeSettings.DefaultSetting.Volume, true)
end

function MusicPerformanceUtil.GetMetronomeEffectPrepareOnly()
	return _G.UE.USaveMgr.GetInt(SaveKey.MetronomeEffectPrepareOnly, MPDefines.MetronomeSettings.DefaultSetting.EffectPrepareOnly, true)
end

-- function MusicPerformanceUtil.GetLastMusicPerformID()
-- 	return _G.UE.USaveMgr.GetInt(SaveKey.LastMusicPerformID, 1, true)
-- end

function MusicPerformanceUtil.GetKeybordMode()
	return _G.UE.USaveMgr.GetInt(SaveKey.PerformanceKeyboardMode, MPDefines.CommonSettings.KeyboardMode, true)
end

function MusicPerformanceUtil.GetKeySize()
	return _G.UE.USaveMgr.GetInt(SaveKey.PerformanceKeySize, MPDefines.CommonSettings.KeySize, true)
end

function MusicPerformanceUtil.GetVolume()
	return _G.SettingsMgr:GetValueBySaveKey(MPDefines.InstrumentValSaveKey)
	-- return _G.UE.USaveMgr.GetInt(SaveKey.InstrumentsVol, MPDefines.CommonSettings.Volume, true)
end

function MusicPerformanceUtil.GetVolumeOther()
	return _G.SettingsMgr:GetValueBySaveKey(MPDefines.InstrumentValSaveKey2)
end

function MusicPerformanceUtil.GetOpenAssistant()
	return _G.UE.USaveMgr.GetInt(SaveKey.PerformanceEnsembleAssistant, MPDefines.Ensemble.DefaultSettings.OpenAssistant and 1 or 0, true) == 1
end
---@param OpenAssistant boolean
function MusicPerformanceUtil.SaveOpenAssitant(OpenAssistant)
	_G.UE.USaveMgr.SetInt(SaveKey.PerformanceEnsembleAssistant, OpenAssistant and 1 or 0, true)
end

function MusicPerformanceUtil.GetOpenCountDown()
	return _G.UE.USaveMgr.GetInt(SaveKey.PerformanceEnsembleCountDown, MPDefines.Ensemble.DefaultSettings.OpenCountDown and 1 or 0, true) == 1
end
---@param OpenCountDown boolean
function MusicPerformanceUtil.SaveOpenCountDown(OpenCountDown)
	_G.UE.USaveMgr.SetInt(SaveKey.PerformanceEnsembleCountDown, OpenCountDown and 1 or 0, true)
end

function MusicPerformanceUtil.GetEnsembleBPM()
	return _G.UE.USaveMgr.GetInt(SaveKey.PerformanceEnsembleBPM, MPDefines.MetronomeSettings.DefaultSetting.BPM, true)
end
---@param EnsembleBPM boolean
function MusicPerformanceUtil.SaveEnsembleBPM(EnsembleBPM)
	_G.UE.USaveMgr.SetInt(SaveKey.PerformanceEnsembleBPM, EnsembleBPM, true)
end

function MusicPerformanceUtil.GetEnsembleBeat()
	return _G.UE.USaveMgr.GetInt(SaveKey.PerformanceEnsembleBEAT, MPDefines.MetronomeSettings.DefaultSetting.BeatPerBar, true)
end
---@param EnsembleBEAT boolean
function MusicPerformanceUtil.SaveEnsembleBEAT(EnsembleBEAT)
	_G.UE.USaveMgr.SetInt(SaveKey.PerformanceEnsembleBEAT, EnsembleBEAT, true)
end

-- 遍历B中的元素，若A中存在的元素与B中都相同则返回true
function MusicPerformanceUtil.IsSameSettings(SettingsA, SettingsB)
	for Key, Value in pairs(SettingsB) do
		if SettingsA[Key] ~= nil and (SettingsA[Key] ~= Value) then
			return false
		end
	end
	return true
end

function MusicPerformanceUtil.ResetSettings(Settings, DefaultSettings)
	for Key, Value in pairs(DefaultSettings) do
		Settings[Key] = Value
	end
end

--是否默认的数据[节拍器设置界面]
function MusicPerformanceUtil.IsDefaultMetronomeSettings(Settings)
	return MusicPerformanceUtil.IsSameSettings(Settings, MPDefines.MetronomeSettings.DefaultSetting)
end

--是否默认的数据[发起合奏确认界面]
function MusicPerformanceUtil.IsDefaultEnsembleSettings(Settings)
	local EnsembleBPM = Settings["EnsembleBPM"]
	local EnsembleBeat = Settings["EnsembleBeat"]
	if EnsembleBPM ~= nil and EnsembleBPM ~= MPDefines.MetronomeSettings.DefaultSetting.BPM then
		return false
	end
	
	if EnsembleBeat ~= nil and EnsembleBeat ~= MPDefines.MetronomeSettings.DefaultSetting.BeatPerBar then
		return false
	end
	return true
end

--重置数据[节拍器设置界面]
function MusicPerformanceUtil.ResetMetronomeSettings(Settings)
	MusicPerformanceUtil.ResetSettings(Settings, MPDefines.MetronomeSettings.DefaultSetting)
end

--重置数据[发起合奏确认界面]
function MusicPerformanceUtil.ResetEnsembleSettings(Settings)
	if Settings["EnsembleBPM"] ~= nil then
		Settings["EnsembleBPM"] = MPDefines.MetronomeSettings.DefaultSetting.BPM
	end

	if Settings["EnsembleBeat"] ~= nil then
		Settings["EnsembleBeat"] = MPDefines.MetronomeSettings.DefaultSetting.BeatPerBar
	end
end

function MusicPerformanceUtil.IsDefaultCommonSettings(Settings)
	return MusicPerformanceUtil.IsSameSettings(Settings, MPDefines.CommonSettings)
end

function MusicPerformanceUtil.ResetCommonSettings(Settings)
	MusicPerformanceUtil.ResetSettings(Settings, MPDefines.CommonSettings)
end

function MusicPerformanceUtil.GetAssistantInst()
	return _G.MusicPerformanceMgr:GetAssistantInst()
end

function MusicPerformanceUtil.GetScoreLevelIconPath(ScoreLevel)
	local IconName = ""
	if ScoreLevel > 0 and ScoreLevel <= ProtoRes.MusicAwardRank.MusicAwardRank_SP then
		IconName = "SPlus"
	elseif ScoreLevel > 0 and ScoreLevel <= ProtoRes.MusicAwardRank.MusicAwardRank_S then
		IconName = "S"
	elseif ScoreLevel > 0 and ScoreLevel < ProtoRes.MusicAwardRank.MusicAwardRank_LAST - 1 then	-- D和MAX都是没有图片的 
		IconName = string.char(string.byte('A') + ScoreLevel - ProtoRes.MusicAwardRank.MusicAwardRank_A)
	end

	return string.isnilorempty(IconName) and "" or 
		string.format("PaperSprite'/Game/UI/Atlas/Performance/Frames/UI_Performance_Icon_%s_png.UI_Performance_Icon_%s_png'", IconName, IconName)
end

---@param IsAllKey 是否全音阶
---@param IsLongClick 是否长按按钮
---@param IsBlackKey 是否黑键
---@param KeyOffset 根据Offset决定颜色
function MusicPerformanceUtil.GetAssistantImgPath(IsAllKey, IsLongClick, IsBlackKey, KeyOffset)
	local IsAllStr = IsAllKey and "All" or ""
	local IsLongStr = IsLongClick and "Long" or "Click"
	local IsBlackStr = IsBlackKey and "BlackKey" or "WhiteKey"
	local ColorStr
	if KeyOffset == 0 then
		ColorStr = IsAllKey and "" or "_Grey"
	elseif KeyOffset < 0 then
		ColorStr = "_Blue"
	else
		ColorStr = "_Red"
	end

	if IsLongClick then
		local Path1, Path2 = string.format("UI_Performance_Img_%s%s_%s%s1_png", IsAllStr, IsLongStr, IsBlackStr, ColorStr),
				string.format("UI_Performance_Img_%s%s_%s%s2_png", IsAllStr, IsLongStr, IsBlackStr, ColorStr)
		return string.format("PaperSprite'/Game/UI/Atlas/Performance/Frames/%s.%s", Path1, Path1),
			string.format("PaperSprite'/Game/UI/Atlas/Performance/Frames/%s.%s", Path2, Path2)
	else
		local Path = string.format("UI_Performance_Img_%s%s_%s%s_png", IsAllStr, IsLongStr, IsBlackStr, ColorStr)
		return string.format("PaperSprite'/Game/UI/Atlas/Performance/Frames/%s.%s", Path, Path)
	end
end

function MusicPerformanceUtil.GetSoundFileName(SoundName)
	return SoundName .. ".sf2"
end

function MusicPerformanceUtil.IsInPerformRange(EntityIDA, EntityIDB)
	local ActorA = ActorUtil.GetActorByEntityID(EntityIDA)
	local ActorB = ActorUtil.GetActorByEntityID(EntityIDB)

	if ActorA == nil or ActorB == nil then
		return false
	end

	local SizeSquared2D = (ActorA:FGetActorLocation() - ActorB:FGetActorLocation()):SizeSquared2D()
	if SizeSquared2D >= MPDefines.EnsembleReceiveRangeSquared then
		-- 距离过远
		return false
	end

	return true
end

--播放tick振铃(右边的tick数字变化时)
function MusicPerformanceUtil.PlayMetroTickSound()
	AudioUtil.LoadAndPlay2DSound(MPDefines.MetronomeSettings.TickSoundPath)
end

--播放小节振铃(左边的小节数字变化时)
function MusicPerformanceUtil.PlayMetroAccSound()
	AudioUtil.LoadAndPlay2DSound(MPDefines.MetronomeSettings.AccSoundPath)
end

function MusicPerformanceUtil.SliderValueToAssistantSpeed(SliderValue)
	local Min = MPDefines.AssistantFallingDownConfig.MinSpeedRate
	local Max = MPDefines.AssistantFallingDownConfig.MaxSpeedRate
	return Min + (Max - Min) * SliderValue
end

function MusicPerformanceUtil.AssistantSpeedToSliderValue(Speed)
	local Min = MPDefines.AssistantFallingDownConfig.MinSpeedRate
	local Max = MPDefines.AssistantFallingDownConfig.MaxSpeedRate
	if Max > Min then
		return (Speed - Min) / (Max - Min)
	end
	return 1.0
end

function MusicPerformanceUtil.GetKeybordKeyViewMap(KeyboradView)
	if KeyboradView == nil then
		return
	end

	local KeyViewMap = {}
	for _, SubView in pairs(KeyboradView.SubViews) do
		local Key = SubView.Key
		if Key then
			KeyViewMap[Key] = SubView
		end
		local ToneOffset = SubView.ToneOffset
		if ToneOffset then
			if ToneOffset > 0 then
				KeyViewMap.Up = SubView
			elseif ToneOffset < 0 then
				KeyViewMap.Down = SubView
			end
		end
	end

	return KeyViewMap
end

return MusicPerformanceUtil