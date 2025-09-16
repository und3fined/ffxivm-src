--
-- Author: anypkvcai
-- Date: 2020-12-30 10:28:36
-- Description:
--

local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local CommonDefine = require("Define/CommonDefine")
local SaveKey = require("Define/SaveKey")

local CultureName = CommonDefine.CultureName
local VoiceLangMap = {
    [CultureName.Chinese]  = "chs",
    [CultureName.English]  = "en",
    [CultureName.Japanese] = "ja",
    [CultureName.Korean]   = "ko",
    [CultureName.French]   = "fr",
    [CultureName.German]   = "de"
}

local UE = _G.UE
local EObjectGC = _G.UE.EObjectGC
local UAudioMgr

---@class AudioUtil
local AudioUtil = {}
AudioUtil.CurCultureName = nil--CultureName.Chinese

-------------------------- 异步接口 --------------------------

local GetDelegatePair = CommonUtil.GetDelegatePair

local function GetDelegate(Callback)
    if not UAudioMgr then
        UAudioMgr = UE.UAudioMgr.Get()
    end

    if not Callback then
        return nil
    end

    return GetDelegatePair(function(_, PlayingID)
        Callback(PlayingID)
    end, true)
end

AudioUtil.VoiceLangMap = VoiceLangMap

---StopAsyncAudioHandle, 停止正在播放的异步音频
---@param HandleID number
---@param Transition number 淡出时间(秒)
---@return boolean 是否成功
function AudioUtil.StopAsyncAudioHandle(HandleID, Transition)
    if not UAudioMgr then
        UAudioMgr = UE.UAudioMgr.Get()
    end
    return UAudioMgr:StopAsyncAudioHandle(HandleID, Transition or 0)
end

---LoadAndPlay2DSound, 异步加载2D音效并播放
---@param ObjectPath string
---@param LifeType EObjectGC 默认音频Event资源生命周期为LRU
---@param Callback function 回调函数, 可为nil, PlayingID会作为参数传入回调函数
---@return number 资源加载的HandleID, 可以调用StopAsyncAudioHandle停止声音
function AudioUtil.LoadAndPlay2DSound(ObjectPath, LifeType, Callback)
    if ObjectPath == nil then
        return
    end

    LifeType = LifeType or EObjectGC.Cache_LRU
    local Delegate = GetDelegate(Callback)
    return UAudioMgr:AsyncLoadAndPostEvent2D(ObjectPath, Delegate, false, LifeType)
end

---LoadAndPlayUISound, 异步加载，SyncLoadAndPlayUISound的异步版本
---建议UI音效使用, 加载的音频Event资源会永久持有, 仅限高频使用的音效
---@param ObjectPath string
---@param Callback function 回调函数, 可为nil, PlayingID会作为参数传入回调函数
---@return number 资源加载的HandleID, 可以调用StopAsyncAudioHandle停止声音
function AudioUtil.LoadAndPlayUISound(ObjectPath, Callback)
    if ObjectPath == nil then
        return
    end

    local LifeType = EObjectGC.Hold
    local Delegate = GetDelegate(Callback)

    return UAudioMgr:AsyncLoadAndPostEvent2D(ObjectPath, Delegate, false, LifeType)
end

---LoadAndPlaySoundEvent, 在某个Entity身上异步播音效
---@param EntityID number
---@param ObjectPath string
---@param bStopWhenAttachedToDestroyed boolean Actor被销毁时是否停止音效
---@param LifeType EObjectGC 默认音频Event资源生命周期为LRU
---@param Callback function 回调函数, 可为nil, PlayingID会作为参数传入回调函数
---@return number 资源加载的HandleID, 可以调用StopAsyncAudioHandle停止声音
function AudioUtil.LoadAndPlaySoundEvent(EntityID, ObjectPath, bStopWhenAttachedToDestroyed, LifeType, Callback)
    if not ObjectPath then
        return
    end

    bStopWhenAttachedToDestroyed = bStopWhenAttachedToDestroyed or false
    LifeType = LifeType or EObjectGC.Cache_LRU

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        return
    end
    local Delegate = GetDelegate(Callback)
    local HandleID = UAudioMgr:AsyncLoadAndPostEvent(ObjectPath, Actor, Delegate, bStopWhenAttachedToDestroyed, LifeType)
	return HandleID
end

---LoadAndPlaySoundAtLocation, 在某个位置异步加载资源并播放音频
---@param ObjectPath string
---@param Location FVector 播放声音的位置
---@param Rotation FRotator 播放声音的朝向
---@param LifeType EObjectGC 默认音频Event资源生命周期为LRU
---@param Callback function 回调函数, 可为nil, PlayingID会作为参数传入回调函数
---@return number 资源加载的HandleID, 可以调用StopAsyncAudioHandle停止声音
function AudioUtil.LoadAndPlaySoundAtLocation(ObjectPath, Location, Rotation, LifeType, Callback)
    if nil == Location or nil == Rotation then return end
    LifeType = LifeType or EObjectGC.Cache_LRU
    local Delegate = GetDelegate(Callback)
    local HandleID = UAudioMgr:AsyncLoadAndPostEventAtLocation(_G.FWORLD(), ObjectPath, Location, Rotation, Delegate, LifeType)
	return HandleID
end



-------------------------- 同步接口 --------------------------

---SyncLoadAndPlay2DSound, 默认音频Event资源生命周期为LRU
---@param ObjectPath string
---@param LifeType EObjectGC
---@return number
function AudioUtil.SyncLoadAndPlay2DSound(ObjectPath, LifeType)
    if ObjectPath == nil then
        return
    end

    LifeType = LifeType or EObjectGC.Cache_LRU

    return UE.UAudioMgr.Get():LoadAndPostEvent2D(ObjectPath, false, LifeType)
end

---SyncLoadAndPlayUISound, 建议UI音效使用, 加载的音频Event资源会永久持有, 仅限高频使用的音效
---@param ObjectPath string
---@return number
function AudioUtil.SyncLoadAndPlayUISound(ObjectPath)
    if ObjectPath == nil then
        return
    end

    local LifeType = EObjectGC.Hold

    return UE.UAudioMgr.Get():LoadAndPostEvent2D(ObjectPath, false, LifeType)
end

---SyncLoadAndPlaySoundEvent, 在某个Entity身上播音效
---@param EntityID number
---@param ObjectPath string
---@param bStopWhenAttachedToDestroyed boolean Actor被销毁时是否停止音效
---@param LifeType EObjectGC 默认音频Event资源生命周期为LRU
---@return number
function AudioUtil.SyncLoadAndPlaySoundEvent(EntityID, ObjectPath, bStopWhenAttachedToDestroyed, LifeType)
    if not ObjectPath then
        return
    end

    bStopWhenAttachedToDestroyed = bStopWhenAttachedToDestroyed or false
    LifeType = LifeType or EObjectGC.Cache_LRU

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        return
    end

    local AudioMgr = UE.UAudioMgr:Get()
    local SoundID = AudioMgr:LoadAndPostEvent(ObjectPath, Actor, bStopWhenAttachedToDestroyed, LifeType)

	return SoundID
end

---SyncLoadAndPlaySoundAtLocation, 在某个位置播放音频
---@param ObjectPath string
---@param Location FVector 播放声音的位置
---@param Rotation FRotator 播放声音的朝向
---@param LifeType EObjectGC 默认音频Event资源生命周期为LRU
---@return number
function AudioUtil.SyncLoadAndPlaySoundAtLocation(ObjectPath, Location, Rotation, LifeType)
    if nil == Location or nil == Rotation then return end
    LifeType = LifeType or EObjectGC.Cache_LRU

    local AudioMgr = UE.UAudioMgr:Get()
    local SoundID = AudioMgr:LoadAndPostEventAtLocation(_G.FWORLD(), ObjectPath, Location, Rotation, LifeType)

	return SoundID
end

---Stop all audio associated with a playing ID
---@param PlayingID number
---@param TransitionDuration number - 单位毫秒ms
---@param FadeCurve number
function AudioUtil.StopSound(PlayingID, TransitionDuration, FadeCurve)
	if nil == FadeCurve then
		FadeCurve = UE.AkCurveInterpolation.AkCurveInterpolation_Linear
	end
	return UE.UAudioMgr.Get():StopPlayingID(PlayingID, TransitionDuration, FadeCurve)
end

local function PrepareSeekOnEventParams(ObjectPath, EntityID)
    local AudioMgr = UE.UAudioMgr:Get()
    local EventName = AudioMgr:GetEventNameByEventPath(ObjectPath)

    if nil == EventName or #EventName == 0 then
        return false
    end

    local Actor = nil
    if EntityID ~= nil then
        Actor = ActorUtil.GetActorByEntityID(EntityID)
    end

    return true, EventName, Actor
end

---SeekOnEventPercent, 按照百分比调整播放的进度
---@param ObjectPath string Event的ObjectPath
---@param PlayingID number 播放Event返回的PlayingID
---@param Percent number 期望调整的进度(0~1之间的一个百分比)
---@param EntityID number 播放在了哪个Entity上面(如果是2D音效传nil就行)
---@return number
function AudioUtil.SeekOnEventPercent(ObjectPath, PlayingID, Percent, EntityID)
    local bIsValid, EventName, Actor = PrepareSeekOnEventParams(ObjectPath, EntityID)
    if not bIsValid then
        return
    end
    UE.UAudioMgr:Get():SeekOnEventPercent(EventName, Actor, PlayingID, Percent)
end

---SeekOnEventMs, 按照时间(毫秒)调整播放的进度
---@param ObjectPath string Event的ObjectPath
---@param PlayingID number 播放Event返回的PlayingID
---@param TimeMs number 期望调整的进度(毫秒)
---@param EntityID number 播放在了哪个Entity上面(如果是2D音效传nil就行)
---@return number
function AudioUtil.SeekOnEventMs(ObjectPath, PlayingID, TimeMs, EntityID)
    local bIsValid, EventName, Actor = PrepareSeekOnEventParams(ObjectPath, EntityID)
    if not bIsValid then
        return
    end

    UE.UAudioMgr:Get():SeekOnEventMs(EventName, Actor, PlayingID, TimeMs)
end

---GetAllEnvSound, 获取当前地图所有的环境音效数据
---@return table key是ID(string类型, 如"se2052639"), value是包含各个参数的table
function AudioUtil.GetAllEnvSound()
    local AllEnvSound = UE.UEnvSoundMgr.Get():GetAllEnvSound()
    local Length = AllEnvSound:Length()
    local EnvSoundInfoList = {}

    local EEnvSoundType = UE.EEnvSoundType
    local EEnvSoundSubType = UE.EEnvSoundSubType

    for i = 1, Length do
        local Item = AllEnvSound:Get(i)
        local EnvSoundInfo = {
            SEElementName = Item.SEElementName,
            Position = Item.Position,
            SoundType = EEnvSoundType:GetNameByValue(Item.SoundType),
            SoundSubType = EEnvSoundSubType:GetNameByValue(Item.SoundSubType),
            MaxRange = Item.MaxRange,
            MinRange = Item.MinRange,
            Volume = Item.Volume,
            RangeVolume = Item.RangeVolume,
            SoundEventPath = Item.SoundEventPath:ToString(),
        }
        EnvSoundInfoList[EnvSoundInfo.SEElementName] = EnvSoundInfo
    end

    return EnvSoundInfoList
end

---SetEnvSoundDebugDrawList, 设置期望绘制的环境音效列表
---@param DebugDrawList table 期望绘制的所有EnvSound的ID(string类型, 如"se2052639")
function AudioUtil.SetEnvSoundDebugDrawList(DebugDrawList)
    local DebugDrawTArray = UE.TArray(UE.FString)
    for _, ID in pairs(DebugDrawList) do
        DebugDrawTArray:Add(ID)
    end

    UE.UEnvSoundMgr.Get():SetDebugDrawList(DebugDrawTArray)
end



-------------------------- 多语言接口 --------------------------

-- 多语言采用流式加载, 资源生命周期自动维护, 不需要考虑异步的问题, 直接播就好了

---SetCurrentCulture, 切换语言
---@param CultureName string 对应CommonDefine.CultureName
function AudioUtil.SetCurrentCulture(CultureName)
    if not UAudioMgr then
        UAudioMgr = UE.UAudioMgr.Get()
    end

    local LanguageName = VoiceLangMap[CultureName]
    if LanguageName then
        AudioUtil.CurCultureName = CultureName
        UAudioMgr:SwitchLanguage(LanguageName)
    end
end

function AudioUtil.GetCurrentCulture()
    if not AudioUtil.CurCultureName then
        local SaveKeyID = SaveKey.PkgVoices
        local SavedCultureIdx = _G.UE.USaveMgr.GetInt(SaveKeyID, -1, true)

        local ExistList = AudioUtil.GetExistingCultureList()
        if #ExistList > 0 then
            local bExist = false
            local SettingsTabLanguages = require("Game/Settings/SettingsTabLanguages")
            local VoicePkgList = SettingsTabLanguages:GetVoicePkgsList()
            if SavedCultureIdx > 0 and SavedCultureIdx < #VoicePkgList then
                local SaveCultureName = VoicePkgList[SavedCultureIdx].LanguageName
                FLOG_INFO("setting SavedCulture Idx:%d, Name: %s", SavedCultureIdx, SaveCultureName)
                for index = 1, #ExistList do
                    if SaveCultureName == ExistList[index] then
                        bExist = true
                        FLOG_INFO("setting SavedCulture Exist")
                        AudioUtil.CurCultureName = ExistList[1]
                        break
                    end
                end
            else
                FLOG_INFO("setting SavedCulture Error Idx:%d, PkgListNum:%d", SavedCultureIdx, #VoicePkgList)
            end

            if not bExist then
                AudioUtil.CurCultureName = ExistList[1]
                FLOG_INFO("setting no SavedCulture, FirstName: %s", AudioUtil.CurCultureName)
            end
        end
    end
    
    return AudioUtil.CurCultureName
end

---Play2DVoice, 播放2D多语言音频
---@param VoiceName string 语音的名字
---@return number PlayingID
function AudioUtil.Play2DVoice(VoiceName)
    if not UAudioMgr then
        UAudioMgr = UE.UAudioMgr.Get()
    end

    return UAudioMgr:PostVoiceEvent2D(VoiceName)
end

---PlayVoiceEvent, 在某个Entity身上播放多语言音频
---@param EntityID number
---@param VoiceName string 语音的名字
---@param bStopWhenAttachedToDestroyed boolean Actor被销毁时是否停止音效
---@return number PlayingID
function AudioUtil.PlayVoiceEvent(EntityID, VoiceName, bStopWhenAttachedToDestroyed)
    if not UAudioMgr then
        UAudioMgr = UE.UAudioMgr.Get()
    end

    bStopWhenAttachedToDestroyed = bStopWhenAttachedToDestroyed or false
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        return
    end

    return UAudioMgr:PostVoiceEvent(VoiceName, Actor, bStopWhenAttachedToDestroyed)
end

---PlayVoiceAtLocation, 在某个位置播放多语言音频
---@param VoiceName string 语音的名字
---@param Location FVector 播放声音的位置
---@param Rotation FRotator 播放声音的朝向
---@return number 资源加载的HandleID, 可以调用StopAsyncAudioHandle停止声音
function AudioUtil.PlayVoiceAtLocation(VoiceName, Location, Rotation)
    if not UAudioMgr then
        UAudioMgr = UE.UAudioMgr.Get()
    end

    return UAudioMgr:PostVoiceEventAtLocation(_G.FWORLD(), VoiceName, Location, Rotation)
end

---GetVoiceLength, 获取多语言音频在当前语言下的长度
---@param VoiceName string 语音的名字
---@return number 音频长度(秒)
function AudioUtil.GetVoiceLength(VoiceName)
    if not UAudioMgr then
        UAudioMgr = UE.UAudioMgr.Get()
    end

    return UAudioMgr:GetVoiceLength(VoiceName)
end



local UPathMgr = _G.UE.UPathMgr
local VoiceDir = UPathMgr.ContentDir(false) .. "WwiseAudio/ScenarioVoice/"

---GetExistingCultureList, 获取当前已经下载的语言包列表
---@return table 一个CommonDefine.CultureName中语言组成的列表
function AudioUtil.GetExistingCultureList()
    local ExistFile = UPathMgr.ExistFile
    local ExistingList = {}
    for CultureName, LangName in pairs(VoiceLangMap) do
        if ExistFile(VoiceDir .. LangName .. "/Placeholder.txt") then
            table.insert(ExistingList, CultureName)
        end
    end
    return ExistingList
end

return AudioUtil