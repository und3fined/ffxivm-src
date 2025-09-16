---
--- Author: Leo
--- DateTime: 2023-11-09 14:10:42
--- Description: 
---

local Path = {
    MaxAward = "PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Key_Img_Select_png.UI_MiniCact_Key_Img_Select_png'",
    MiddleAward = "PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Key_Img_Select_png.UI_MiniCact_Key_Img_Select_png'",
    OtherAward = "PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Key_Img_Select_png.UI_MiniCact_Key_Img_Select_png'",
}

local AudioPath = {
    Enter = "AkAudioEvent'/Game/WwiseAudio/Events/sound/system/SE_GS/Play_SE_GS_M_1.Play_SE_GS_M_1'",
    Buy = "AkAudioEvent'/Game/WwiseAudio/Events/sound/system/SE_GS/Play_SE_GS_M_2.Play_SE_GS_M_2'",
    OpenNum = "AkAudioEvent'/Game/WwiseAudio/Events/sound/system/SE_GS/Play_SE_GS_M_3.Play_SE_GS_M_3'",
    GetReward = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Mini_Cactpot/Play_gs_result_widget.Play_gs_result_widget'",
    BestReward = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_LvUP_Get/Play_Zingle_LvUP_Get.Play_Zingle_LvUP_Get'",
    GetReward2 = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_LvUP_Get/Play_Zingle_LvUP_Get.Play_Zingle_LvUP_Get'"
}

local Color = {
    Default = "#513826",
    Red = "#af4c58",
    Write = "#FFFFFF"
}

local MiniCactpotDefine = {
    Path = Path,
    AudioPath = AudioPath,
    Color = Color
}

return MiniCactpotDefine