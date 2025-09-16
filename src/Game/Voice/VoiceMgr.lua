--- 语音 管理器
--- Author: xingcaicao
--- DateTime: 2023-03-13 19:53
--- Description:

local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SettingsMgr = require("Game/Settings/SettingsMgr")
local VoiceDefine = require("Game/Voice/VoiceDefine")
local CommonUtil = require("Utils/CommonUtil")
local CommonDefine = require("Define/CommonDefine")
local GCloudDefine = require("Define/GCloudDefine")

local VoiceMgr = LuaClass(MgrBase)

local AudioMgr
local AudioType
local UVoiceMgr
local MicCheckNo  = VoiceDefine.MicCheckNo
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR

local CultureName = CommonDefine.CultureName
local SpeechLanguageType = GCloudDefine.SpeechLanguageType

local MapCultureAndSpeechLanguageType = {
	[CultureName.Chinese] = SpeechLanguageType.SPEECH_LANGUAGE_ZH, 
	[CultureName.English] = SpeechLanguageType.SPEECH_LANGUAGE_EN, 
	[CultureName.Japanese] = SpeechLanguageType.SPEECH_LANGUAGE_JA, 
	[CultureName.Korean] = SpeechLanguageType.SPEECH_LANGUAGE_KO, 
	[CultureName.German] = SpeechLanguageType.SPEECH_LANGUAGE_DE, 
	[CultureName.French] = SpeechLanguageType.SPEECH_LANGUAGE_FR, 
}

function VoiceMgr:OnInit()
end

function VoiceMgr:OnBegin()
    AudioMgr    = _G.UE.UAudioMgr:Get()
    AudioType   = _G.UE.EWWiseAudioType
	UVoiceMgr 	= _G.UE.UVoiceMgr.Get()
end

function VoiceMgr:OnEnd()
end

function VoiceMgr:OnShutdown()
end

function VoiceMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GVoiceNoPermissionMic,            	self.OnEventNoPermissionMic)			-- 没有麦克风访问权限 
	self:RegisterGameEvent(EventID.GVoiceDownloadRecordError,           self.OnEventDownloadRecordError)		-- 下载录音文件出错 
	self:RegisterGameEvent(EventID.GVoiceTeamMembeDrop,                 self.OnEventTeamMembeDrop)				-- 队伍房间成员掉线
	self:RegisterGameEvent(EventID.GVoiceRecoverBeClosedAudios,         self.OnEventRecoverBeClosedAudios)		-- 恢复录音/播放录音时被关闭的音频 
end

function VoiceMgr:OnEventNoPermissionMic( )
	-- "请打开麦克风权限"
	MsgTipsUtil.ShowTips(LSTR(1510001))
end

function VoiceMgr:OnEventDownloadRecordError( )
	-- "语音消息已失效"
	MsgTipsUtil.ShowTips(LSTR(1510002))
end

---@param Params FEventParams
---Params.StringParam1, room name 
---Params.IntParam1, the player's ID in this room 
function VoiceMgr:OnEventTeamMembeDrop( Params )
	if nil == Params then
		return
	end

    FLOG_INFO("VoiceMgr:  队伍房间成员掉线, RoomName= %s MemberID= %s", Params.StringParam1, Params.IntParam1)
end

function VoiceMgr:OnEventRecoverBeClosedAudios( )
	self:RecoverBeClosedAudios()
end

---Test wheather the microphone is available or not.
---@return If microphone device is available, returns true, otherwise returns false, err tip id or message.
function VoiceMgr:CheckMicrophone()
	local Code = UVoiceMgr:CheckAndRequestMicPermission()
	FLOG_INFO("VoiceMgr:CheckMicrophone, Code:%d", Code)
	if Code == MicCheckNo.Succ then
		return true
	elseif Code == MicCheckNo.AndroidNoPermission then
		-- 10067 申请麦克风权限以便正常使用录音转文字及组队语音功能
		_G.UIViewMgr:ShowView(_G.UIViewID.PermissionTips, {TipsStr = LSTR(10067)})
	end

	if CommonUtil.IsAndroidPlatform() then
		if Code == MicCheckNo.AndroidNoPermission then
			-- "未获得麦克风权限，请在设备设置中授权"
			MsgTipsUtil.ShowTips(LSTR(1510003))
			return false
		end

	else
		if Code == MicCheckNo.NoPermission then
			-- "未获得麦克风权限，请在设备设置中授权"
			MsgTipsUtil.ShowTips(LSTR(1510003))
			return false

		elseif Code == MicCheckNo.NoMicDevice then
			-- "未检测到麦克风，打开麦克风失败"
			MsgTipsUtil.ShowTips(LSTR(1510004))
			return false
		end
	end

	FLOG_ERROR("VoiceMgr::CheckMicrophone, Occurred error (ErrorNo 0x%X)", Code)

	return false
end

---Check iPhone device mute switch state.
---@see EventID.GVoiceCheckIphoneDeviceMuteStateResult, Params->IntParam1,  Non-zero means mute state
function VoiceMgr:CheckIphoneDeviceMuteState()
	if CommonUtil.IsIOSPlatform() then
		UVoiceMgr:CheckIphoneDeviceMuteState()
	end
end

---@param RoomName: The name of The room to join, it should be a string composed by 0-9A-Za-Z._- and less than 127 bytes.
function VoiceMgr:CheckTeamRoomName( RoomName )
	if nil == RoomName then
		return false
	end

	if string.len(RoomName) <= 0 then
		FLOG_WARNING("VoiceMgr: the room name is empty string")
		return false
	end

	if string.find(RoomName or "", "[^0-9^a-z^A-Z^%-^%_]") then
		FLOG_WARNING("VoiceMgr: The room name contains illegal characters")
		return false 
	end

	if string.len(RoomName) >= 127 then
		FLOG_WARNING("VoiceMgr: the room name out of length (maximum 127 characters)")
		return false 
	end

	return true
end

 ---Open the player's microphone and record the player's voice.
---@param IsPrivate: is Private Chat Message.
 ---@return If success returns true, otherwise returns false.
function VoiceMgr:StartRecording(IsPrivate)
	return UVoiceMgr:StartRecording(true, IsPrivate)
end

---Stop the player's microphone and stop record the player's voice.
function VoiceMgr:StopRecording()
	UVoiceMgr:StopRecording()
end

---Get the microphone's max volume
function VoiceMgr:GetMicMaxVolume()
	return CommonUtil.IsMobilePlatform() and 32767 or 65535 
end

---Get the microphone's volume
function VoiceMgr:GetMicVolume()
	return UVoiceMgr:GetMicVolume(true)
end

---Upload the player's voice message file to the network.
---@param IsPrivate: is Private Chat Message.
function VoiceMgr:UploadRecordedFile( IsPrivate )
	UVoiceMgr:UploadRecordedFile(IsPrivate)
end

function VoiceMgr:IsUploading( )
	return UVoiceMgr.IsUploading
end

function VoiceMgr:SetIsUploading( b )
	UVoiceMgr.IsUploading = b
end

---Whether the upload file timed out
function VoiceMgr:IsUploadTimeOut( )
	return UVoiceMgr:IsUploadTimeOut()
end

---@param FileID: the ID of the file.
---@param IsPrivate: is Private Chat Message.
function VoiceMgr:PlayVoice( FileID, IsPrivate )
	if string.isnilorempty(FileID) then
		return
	end

	self:CloseSomeAudios()
	UVoiceMgr:PlayRecordedFile(FileID, IsPrivate)
end

---Stop playing the voice file.
function VoiceMgr:StopPlayingFile()
	UVoiceMgr:StopPlayFile()
end

---Stop play the voice files.
---Contains the files in the mWaitingPlayFileList
function VoiceMgr:StopPlayFiles()
	UVoiceMgr:StopPlayFiles()
end

--- Translate voice file to text, EventID.GVoiceSpeechFileToTextComplete return translated text.
---@param FileID number @the ID of the file.
---@param SrcLang GCloudDefine.SpeechLanguageType @speech language associated with fileID.fOnTextTranslate
---@param IsPrivate boolean @ is Private Chat Message.
function VoiceMgr:TranslateVoiceToText(FileID, SrcLang, IsPrivate)
	if string.isnilorempty(FileID) then
		return
	end

	SrcLang = SrcLang or SpeechLanguageType.SPEECH_LANGUAGE_ZH

	local TargetLang = self:GetCurSpeechLanguageType()
	UVoiceMgr:TranslateVoiceToText(FileID, SrcLang, TargetLang, IsPrivate)
end

--- Stop translating voice file.
function VoiceMgr:StopTranslatingVoiceFile()
	UVoiceMgr:StopTranslatingVoiceFile()
end

---@param RoomName: The name of The room to join.
---@return boolean
function VoiceMgr:JoinTeamRoom( RoomName )
	--检查房间名
	if not self:CheckTeamRoomName(RoomName) then
		return false
	end

	return UVoiceMgr:JoinTeamRoom(RoomName)
end

---@param RoomName: The name of The room to quit.
function VoiceMgr:QuitTeamRoom( RoomName )
	if string.isnilorempty(RoomName) then
		return
	end

	UVoiceMgr:QuitRoom(RoomName)
end

function VoiceMgr:OpenMic()
	local OK = self:CheckMicrophone()
	if not OK then
		return false
	end

	UVoiceMgr:OpenMic()

	return true
end

function VoiceMgr:CloseMic()
	UVoiceMgr:CloseMic()
end

---@return If success returns true, otherwise returns false.
function VoiceMgr:OpenSpeaker()
	return UVoiceMgr:OpenSpeaker()
end

function VoiceMgr:CloseSpeaker()
	UVoiceMgr:CloseSpeaker()
end

---关闭一些音频
function VoiceMgr:CloseSomeAudios()
    AudioMgr:SetAudioVolume(AudioType.Music, 0) 		-- 背景音
    AudioMgr:SetAudioVolume(AudioType.MainPlayer, 0) 	-- 音效
    AudioMgr:SetAudioVolume(AudioType.Ambient_Sound, 0) -- 环境音 
end

---恢复录音/播放录音时被关闭的音频
function VoiceMgr:RecoverBeClosedAudios()
    AudioMgr:SetAudioVolume(AudioType.Music, SettingsMgr:GetValueBySaveKey("MusicVol"))				-- 背景音
    AudioMgr:SetAudioVolume(AudioType.MainPlayer, SettingsMgr:GetValueBySaveKey("MainPlayerVol")) 	-- 音效
    AudioMgr:SetAudioVolume(AudioType.Ambient_Sound, SettingsMgr:GetValueBySaveKey("AmbientVol")) 	-- 环境音 
end

--- 获取当前语音语言类型
---@return GCloudDefine.SpeechLanguageType
function VoiceMgr:GetCurSpeechLanguageType()
	local CultureName = CommonUtil.GetCurrentCultureName()
	if string.isnilorempty(CultureName) then
		return SpeechLanguageType.SPEECH_LANGUAGE_ZH
	end

	return MapCultureAndSpeechLanguageType[CultureName] or SpeechLanguageType.SPEECH_LANGUAGE_ZH
end

return VoiceMgr