local LSTR = _G.LSTR
local AudioUtil = require("Utils/AudioUtil")

local OpportunityShowTime = 4.0

local PopType = {
    Lose = 0,
    Win = 1,
    Gate = 2,
}

local TaskIcon = {
    Ended = nil,
    NoSignUp = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Yojimbo_Missed_png.UI_Icon_Hud_Yojimbo_Missed_png'",
    AlreadySignUp = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Snap_Missed_Blue_png.UI_Icon_Hud_Snap_Missed_Blue_png'",
    ChicksSignUp = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Yojimbo_Remain_png.UI_Icon_Hud_Yojimbo_Remain_png'",
    GoldActivityIcon = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Snap_Missed_Blue_png.UI_Icon_Hud_Snap_Missed_Blue_png'",
}

local BgImgPath = {
    YellowBg = "Texture2D'/Game/UI/Texture/PlayStyle/UI_PlayStyle_Img_SystemTips_CountDown02.UI_PlayStyle_Img_SystemTips_CountDown02'",
    RedBg = "Texture2D'/Game/UI/Texture/PlayStyle/UI_PlayStyle_Img_SystemTips_CountDown01.UI_PlayStyle_Img_SystemTips_CountDown01'"
}

local SignUpSuccessSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_Gate_Enc/Play_Zingle_Gate_Enc.Play_Zingle_Gate_Enc'"
local AirForceShotSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/etc/SE_VFX_Etc_MG_RideShoot_Shot/Play_SE_VFX_Etc_MG_RideShoot_Shot.Play_SE_VFX_Etc_MG_RideShoot_Shot'"

local WorldMapIconState = {
    NoSignUp = 1,
    AlreadySignUp = 2,
    Ended = 3,
}

local CreateNpcResID = {
    SprayAir = 1010476,         --喷风NpcID
    GoldSharpKnife = 1031796,       --快刀NpcID
    AirForce = 1016306,         --空军NpcID
    ChicksNpc1 = 1010473, 
    ChicksNpc2 = 1010447, 
}

local RelatedNpcID = {
    SprayAir = 1010476,         --喷风NpcID
    GoldSharpKnife = 1031796,       --快刀NpcID
    AirForce = 1016306,         --空军NpcID
    Chicks = {Npc1 = 1010473, Npc2 = 1010447},           --小鸡NpcID
    EventNarrator1 = 1011093,   --活动解说员NpcID
    EventNarrator2 = 1011080,   --活动解说员NpcID
    EventNarrator3 = 1011084,   --活动解说员NpcID
}

-- 拯救小鸟的小鸟NPCID
local RescueChickenResID = {}
RescueChickenResID[1010449] = 1
RescueChickenResID[1010450] = 1
RescueChickenResID[1010466] = 1
RescueChickenResID[1010467] = 1
RescueChickenResID[1010468] = 1
RescueChickenResID[1010469] = 1
RescueChickenResID[1010470] = 1

local NarratorDialogLib = {
    DuringInActivity = 18553,
    OutOfActivity = 18552
}

local GateRuleDesc = {
    Desc1 = LSTR("与临危受命类似，机遇临门是金碟游乐场里固定时间发生的限时事件。\n机遇临门事件在每小时0分、20分、40分(本地时间)开启 无需支付任何费用即可参与。"),
    Desc2 = LSTR("机遇临门是金碟游乐场里固定时间发生的限时事件。\n机遇临门事件在每小时0分、20分、40分(本地时间)开启 无需支付\n任何费用即可参与。")
}

local BehaviorNpcIDList = {
    JumboCactpotIssueNpc = 1010446, -- 仙人仙彩发放员
    MiniCactpotIssuerNpc = 1010445,  -- 仙人微彩发放员
    -- JumboCactpotExNpc = 1010451,     -- 仙人仙彩奖品兑换员
    MagicCardReceptNpc = 1010479,    -- 幻卡大赛接待员
    FashionCheckRecptNpc = 1025176,  -- 时尚品鉴Npc 假面·罗斯
    FashionQuestNpc = 1011145,      -- 时尚品鉴接取任务Npc
}


local BeginAndEndTimeData = {
    JumbBeginIndex = 1,
    JumbEndIndex = 2,
    MagicCardBeginIndex = 3,
    MagicCardEndIndex = 4,
    FashionCheckBeginIndex = 5,
    FashingCheckEndIndex = 6
}

local AirForceConfig = {
    Scores = { 0, 500, 1500, 4000, 5000 },
    Icons =
    {
        "Texture2D'/Game/UI/Texture/Gate/UI_Gate_Img_ResultQuality05.UI_Gate_Img_ResultQuality05'",
        "Texture2D'/Game/UI/Texture/Gate/UI_Gate_Img_ResultQuality04.UI_Gate_Img_ResultQuality04'",
        "Texture2D'/Game/UI/Texture/Gate/UI_Gate_Img_ResultQuality03.UI_Gate_Img_ResultQuality03'",
        "Texture2D'/Game/UI/Texture/Gate/UI_Gate_Img_ResultQuality02.UI_Gate_Img_ResultQuality02'",
        "Texture2D'/Game/UI/Texture/Gate/UI_Gate_Img_ResultQuality01.UI_Gate_Img_ResultQuality01'"
    },
    TextNode = { 3, 2, 2, 2, 1 },
    TextContent = { LSTR(570001), LSTR(570002), LSTR(570003), LSTR(570004), LSTR(570005) }, --凡、良、优、极、完美
    ATLs = { 590, 671, 671, 671, 683 },
}

local InteractiveDialogID = {
    ExchangeJDCoin = 1850092,
    ExchangeJDCoinFail = 1850093,
}

local NeedPlayAudioIDList = {
--     [40200] = 0, [40201] = 0, [40202] = 0, [40203] = 0, [40204] = 0, [40206] = 0, [40207] = 0, [40208] = 0, [40209] = 0, [40211] = 0, [40212] = 0, [40213] = 0, [40200] = 0, [40200] = 0, 

}

local function PlayGoldTipAudio()
    local Path = "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_057/Play_SE_Event_057.Play_SE_Event_057'"
    AudioUtil.LoadAndPlayUISound(Path)
end

local function TryPlayGoldTipAudio(ID)
    if NeedPlayAudioIDList[ID] ~= nil then
        PlayGoldTipAudio()
    end
end

----------------------------------------------End-----------------------------------------------------

local GoldSauserDefine = {
    TryPlayGoldTipAudio = TryPlayGoldTipAudio,
    PlayGoldTipAudio = PlayGoldTipAudio,
    SignUpSuccessSoundPath = SignUpSuccessSoundPath,
    OpportunityShowTime = OpportunityShowTime,
    PopType = PopType,
    TaskIcon = TaskIcon,
    BgImgPath = BgImgPath,
    WorldMapIconState = WorldMapIconState,
    RelatedNpcID = RelatedNpcID,
    GateRuleDesc = GateRuleDesc,
    NarratorDialogLib = NarratorDialogLib,
    BehaviorNpcIDList = BehaviorNpcIDList,
    BeginAndEndTimeData = BeginAndEndTimeData,
    CreateNpcResID = CreateNpcResID,
    RescueChickenResID = RescueChickenResID,
    AirForceShotSoundPath = AirForceShotSoundPath,
    AirForceConfig = AirForceConfig,
    InteractiveDialogID = InteractiveDialogID,
}

return GoldSauserDefine
