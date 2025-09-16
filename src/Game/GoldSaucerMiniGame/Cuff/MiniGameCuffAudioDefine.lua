

local AudioPath = {
    PlayFistSwish = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Fist_swish.Play_Fist_swish'",
    StopFistSwish = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Stop_Fist_swish.Stop_Fist_swish'",
    EnterGame = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_popup.Play_Mini_Gilgamesh_popup'",
    OnReady = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_prepare.Play_Mini_Gilgamesh_prepare'",
    OnBegin = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_start.Play_Mini_Gilgamesh_start'",
    Excellent = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_good.Play_Mini_Gilgamesh_good'",
    Perfect = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_perfect.Play_Mini_Gilgamesh_perfect'",
    RedPerfect = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_perfect1.Play_Mini_Gilgamesh_perfect1'",
    Miss = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_fail.Play_Mini_Gilgamesh_fail'",
    RewardCritical = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_crit.Play_Mini_Gilgamesh_crit'",
    EnterSuccessResult = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_win.Play_Mini_Gilgamesh_win'",
    EnterNextLevel = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_levelup.Play_Mini_Gilgamesh_levelup'"
}

local AudioName = {
    PlayFistSwish = "Play_Fist_swish",
    StopFistSwish = "Stop_Fist_swish",
}

local RTPCName = {
    SpeedTwirl = "Speed_twirl",
    SpeedPitch = "Speed_pitch"
}

local MiniGameCuffAudioDefine = 
{
    AudioPath = AudioPath,
    RTPCName = RTPCName,
    AudioName = AudioName,
}


return MiniGameCuffAudioDefine