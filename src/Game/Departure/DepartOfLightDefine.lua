---
--- Author: Carl
--- DateTime: 2025-3-06 11:36
--- Description:
---
local ProtoCommon = require("Protocol/ProtoCommon")
local EModuleID = ProtoCommon.ModuleID
local ProtoCS = require("Protocol/ProtoCS")
local Activity = ProtoCS.Game.Activity
local ERewardStatus = Activity.RewardStatus
local DEPART_GAME_ID = ProtoCS.Role.LightJourney.JourneyGameID
local LSTR = _G.LSTR


local ETaskState = {
    Unlock = 1,
    Lock = 2,
    NeedFinishPreTask = 3,
}

local TableIconPath = {
    [DEPART_GAME_ID.GameIDFate] = {
        Default = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Fate_Normal_png.UI_Departure_Icon_Tab_Fate_Normal_png'", 
        Selected = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Fate_Select_png.UI_Departure_Icon_Tab_Fate_Select_png'"},
    [DEPART_GAME_ID.GameIDCloset] = {
        Default = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Wardrobe_Normal_png.UI_Departure_Icon_Tab_Wardrobe_Normal_png'", 
        Selected = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Wardrobe_Select_png.UI_Departure_Icon_Tab_Wardrobe_Select_png'"}, 
    [DEPART_GAME_ID.GameIDGoldSauser] = {
        Default = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_GoldSauser_Normal_png.UI_Departure_Icon_Tab_GoldSauser_Normal_png'", 
        Selected = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_GoldSauser_Select_png.UI_Departure_Icon_Tab_GoldSauser_Select_png'"},
    [DEPART_GAME_ID.GameIDMakerNote] = {
        Default = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Crafter_Normal_png.UI_Departure_Icon_Tab_Crafter_Normal_png'", 
        Selected = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Crafter_Select_png.UI_Departure_Icon_Tab_Crafter_Select_png'"},
    [DEPART_GAME_ID.GameIDGatherNote] = {
        Default = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Collection_Normal_png.UI_Departure_Icon_Tab_Collection_Normal_png'", 
        Selected = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Collection_Select_png.UI_Departure_Icon_Tab_Collection_Select_png'"},
    [DEPART_GAME_ID.GameIDFisherNote] = {
        Default = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Fish_Normal_png.UI_Departure_Icon_Tab_Fish_Normal_png'", 
        Selected = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_Fish_Select_png.UI_Departure_Icon_Tab_Fish_Select_png'"},
    [DEPART_GAME_ID.GameIDCombatProf] = {
        Default = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_JobFighting_Normal_png.UI_Departure_Icon_Tab_JobFighting_Normal_png'", 
        Selected = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_Icon_Tab_JobFighting_Select_png.UI_Departure_Icon_Tab_JobFighting_Select_png'"},
}

-- 互动玩法钓鱼笔记图片
local InteractFishNoteEmotionPath = {
    [0] = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_TipsIcon_FishLevel0_png.UI_Departure_TipsIcon_FishLevel0_png'",
    [1] = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_TipsIcon_FishLevel1_png.UI_Departure_TipsIcon_FishLevel1_png'",
    [2] = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_TipsIcon_FishLevel2_png.UI_Departure_TipsIcon_FishLevel2_png'",
    [3] = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_TipsIcon_FishLevel3_png.UI_Departure_TipsIcon_FishLevel3_png'",
}

local UISoundPath = {
    EntranceAnim = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Depart/Play_FM_UI_Depart_JieSuo.Play_FM_UI_Depart_JieSuo'",
    MainPanel = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Depart/Play_FM_UI_Depart_KaiQi.Play_FM_UI_Depart_KaiQi'",
    RecycelPanel = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Depart/Play_FM_UI_Depart_KaiQi.Play_FM_UI_Depart_KaiQi'",
    ActivityDetail = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_TanChuang_2.Play_FM_UI_TanChuang_2'",
    BubbleAnim = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Depart/Play_FM_UI_Depart_QiPao.Play_FM_UI_Depart_QiPao'",
    FateAnim = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Depart/Play_FM_UI_Depart_Fate.Play_FM_UI_Depart_Fate'",
    CloseAnim = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Depart/Play_FM_UI_Depart_YiChu.Play_FM_UI_Depart_YiChu'",
    FishNote1 = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/live/SE_VFX_Live_Fish_Hit_Excite_c/Play_SE_VFX_Live_Fish_Hit_Excite_c.Play_SE_VFX_Live_Fish_Hit_Excite_c'",
    FishNote3 = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Fishman/Play_SE_VFX_Live_Fish_Hit_Bite_c.Play_SE_VFX_Live_Fish_Hit_Bite_c'",
    Battle = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Depart/Play_FM_UI_Depart_ZhanDou.Play_FM_UI_Depart_ZhanDou'",
    Switch = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Depart/Play_FM_UI_Depart_Switch.Play_FM_UI_Depart_Switch'"
}

local BubbleIconAttack = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_TipsIcon_Fate1_png.UI_Departure_TipsIcon_Fate1_png'"

-- 1620015
-- 亲爱的冒险者%s:
-- 恭喜你完成了光之启程的所有内容，过往起伏不断，掩盖不住你在艾欧泽亚不断的奋战。在过去的%s天里，你
-- %s，%s，%s。
-- 故事还在继续，请坚定地踏上更遥远的旅程吧!
local RecycleContent = LSTR(1620015)
local HighLightDescList = {
    [DEPART_GAME_ID.GameIDFate] = LSTR(1620016), --1620016("通过危命任务收获了%s双色宝石。")
    [DEPART_GAME_ID.GameIDCloset] = LSTR(1620017), --1620017("解锁了%s个衣橱外观。")
    [DEPART_GAME_ID.GameIDGoldSauser] = LSTR(1620018), --1620018("在金碟游乐场获得了%s金碟币。")
    [DEPART_GAME_ID.GameIDMakerNote] = LSTR(1620019), --1620019("标记了%s个制作笔记中记载的配方。")
    [DEPART_GAME_ID.GameIDGatherNote] = LSTR(1620020), --1620020("标记了%s个采集笔记中记载的素材。")
    [DEPART_GAME_ID.GameIDFisherNote] = LSTR(1620021), --1620021("钓上并标记了%s个钓鱼笔记中的物种。")
    [DEPART_GAME_ID.GameIDCombatProf] = LSTR(1620022), --1620022("战斗职业提升了%s级。")
}

local GoToText = LSTR(10019) --10019("前往") --鱼类图鉴/战斗职业 使用
local GoToFateText = LSTR(1620002) --1620002("危命图鉴")
local GoToFishNoteText = LSTR(1620023) --1620002("钓鱼笔记")
local GoToAdventureText = LSTR(1620024) --1620002("冒险系统")
local GoToRoleModuleText = LSTR(1620025) --1620002("角色系统")
local GoToOpenGoldSauserText = LSTR(1620003) --1620003("前往开启")
local GoToGoldSauserText = LSTR(1620005) --1620005("金蝶游乐场")
local GoldSauserOpenCondition = LSTR(1620004) --1620004("需完成11级主线任务")

local GoToClosetText = LSTR(1620006) --1620006("前往衣橱")

local MakeNoteOpenCondition = LSTR(1620007) --1620007("解锁任意能工巧匠后开启")
local GoToMakeNote = LSTR(1620008) --1620008("制作笔记")

local GatherNoteOpenCondition = LSTR(1620009) --1620009("解锁采矿工/园艺工后开启")
local GoToGatherNote = LSTR(1620010) --1620010("采集笔记")

local FishNoteOpenCondition = LSTR(1620011) --1620011("解锁捕鱼人后开启")

local RecycleText = LSTR(1620014) -- 1620014("奖励已全部领取，系统将在%s后关闭")
local GoToRecycleText = LSTR(1620026) -- 1620026("启程出发")

-- 跳转按钮名字表
local GoToBtnNameMap = 
{
    [DEPART_GAME_ID.GameIDFate] = GoToFateText, --临危危命
    [DEPART_GAME_ID.GameIDCloset] = GoToClosetText, --衣橱
    [DEPART_GAME_ID.GameIDGoldSauser] = GoToGoldSauserText, --金蝶游乐场
    [DEPART_GAME_ID.GameIDMakerNote] = GoToMakeNote, --制作笔记
    [DEPART_GAME_ID.GameIDGatherNote] = GoToGatherNote, --采集笔记
    [DEPART_GAME_ID.GameIDFisherNote] = GoToFishNoteText, --鱼类图鉴
    [DEPART_GAME_ID.GameIDCombatProf] = GoToAdventureText, --战斗职业
}

-- 玩法固定顺序
local ModuleOrderList = 
{
    [1] = DEPART_GAME_ID.GameIDFate, --临危危命
    [2] = DEPART_GAME_ID.GameIDCloset, --衣橱
    [3] = DEPART_GAME_ID.GameIDGoldSauser, --金蝶游乐场
    [4] = DEPART_GAME_ID.GameIDMakerNote, --制作笔记
    [5] = DEPART_GAME_ID.GameIDGatherNote, --采集笔记
    [6] = DEPART_GAME_ID.GameIDFisherNote, --鱼类图鉴
    [7] = DEPART_GAME_ID.GameIDCombatProf --战斗职业
}

local RedDotName = "Root/DepartOfLight"

local DepartOfLightDefine = {
    GoldSauserOpenCondition = GoldSauserOpenCondition,
    MakeNoteOpenCondition = MakeNoteOpenCondition,
    GatherNoteOpenCondition = GatherNoteOpenCondition,
    FishNoteOpenCondition = FishNoteOpenCondition,
    GoToBtnNameMap = GoToBtnNameMap,
    ModuleOrderList = ModuleOrderList,
    GoToOpenGoldSauserText = GoToOpenGoldSauserText,
    ERewardStatus = ERewardStatus,
    EModuleID = EModuleID,
    TableIconPath = TableIconPath,
    HighLightDescList = HighLightDescList,
    RecycleContent = RecycleContent,
    GoToRoleModuleText = GoToRoleModuleText,
    RedDotName = RedDotName,
    RecycleText = RecycleText,
    GoToRecycleText = GoToRecycleText,
    GoToText = GoToText,
    InteractFishNoteEmotionPath = InteractFishNoteEmotionPath,
    BubbleIconAttack = BubbleIconAttack,
    UISoundPath = UISoundPath
}

return DepartOfLightDefine