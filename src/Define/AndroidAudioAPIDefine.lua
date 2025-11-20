local EAkAndroidAudioAPI <const> = UE.EAkAndroidAudioAPI
local API_AAudio         <const> = 1 << EAkAndroidAudioAPI.AAudio
local API_OpenSL_ES      <const> = 1 << EAkAndroidAudioAPI.OpenSL_ES

--- 安卓平台AudioAPI的预案, 根据平台定义使用对应的API
---@class AndroidAudioAPIDefine
local AndroidAudioAPIDefine = {
    Default = API_AAudio | API_OpenSL_ES
}

function AndroidAudioAPIDefine.InitAndroidAudioAPI()
    -- local API = AndroidAudioAPIDefine.Default
    -- local Cmd = string.format("AkAudio.AndroidAudioAPI %d", API)
    -- UE.UKismetSystemLibrary.ExecuteConsoleCommand(FWORLD(), Cmd, nil)
end

return AndroidAudioAPIDefine