---
--- Author: Leo
--- DateTime: 2023-08-29 14:10:42
--- Description: 
---

local LSTR = _G.LSTR

--- Param PathNumber number 	文件路径数字编号
--- return string 			返回文件路径
local function ChangeNumberPath(PathNumber)
    if type(PathNumber) == "number" then
    if PathNumber and 0 <= PathNumber and PathNumber < 10 then
            return string.format("%s%d%s%d%s", "PaperSprite'/Game/UI/Atlas/JumboCactpot/Frames/UI_JumboCact_Numb_Img_",
                PathNumber, "_png.UI_JumboCact_Numb_Img_", PathNumber, "_png")
        end
    end
    return nil
end

local Path = {
    NoTime = "PaperSprite'/Game/UI/Atlas/JumboCactpot/Frames/UI_JumboCact_Numb_Img_None_png.UI_JumboCact_Numb_Img_None_png'",
}

local MaxStage = 7  -- 仙彩最大阶段

local IconPath = {
    XCTicket = "Texture2D'/Game/Assets/Icon/ItemIcon/065000/UI_Icon_065004.UI_Icon_065004'",
    JDCoin = "Texture2D'/Game/Assets/Icon/ItemIcon/065000/UI_Icon_065025.UI_Icon_065025'",
    DialogIconPath = "PaperSprite'/Game/UI/Atlas/NPCTalk/Frames/UI_Icon_NPC_Cactus_png.UI_Icon_NPC_Cactus_png'",
    HelpExplain = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Help_png.UI_Comm_Btn_Help_png'",
    PurBtnGreyImg = "PaperSprite'/Game/UI/Atlas/JumboCactpot/Frames/UI_JumboCact_Btn_Grey_png.UI_JumboCact_Btn_Grey_png'",
    PurBtnNormalImg = "PaperSprite'/Game/UI/Atlas/JumboCactpot/Frames/UI_JumboCact_Btn_Orange_png.UI_JumboCact_Btn_Orange_png'",
}

local ColorDefine = {
    Write = "#FFFFFF",
    Red = "#af4c58",
    Orange = "Ffa500",
    ColorSelf = "#4d85b4",
    ColorFriend = "#b56728",
    Black = "#313131",
    Yellow = "BD8213",
    BuffYellow = "b56728",
    Grey = "6c6964",
    GetRewardColor = "ffd75f",
}

local TimeDefine = {
    OneDaySec = 86400, -- 一天有多少秒
    OneHourSec = 3600, -- 一小时的秒数
    OneMinSec = 60
}

local PriceDefine = {
    BasePrice = 100,
    IncrementPrice = 50, -- 每买一次下一次多加50金碟币
}


local TalkContent = {
    ShouldExchange = 1850006,   -- 存在未兑换的奖励
    NotBoughtId = 1850000,      -- 一次没买
    BoughtSome = 1850001,       -- 买了一些，但还有次数
    NoBuyCount = 1850005,       -- 消耗完所有次数
    CloseAfterBuy = 18502,      -- 对话组 购买后关闭触发
    StateAfoot = 18568, -- 开奖仪式不能领奖
}

local InteractiveID = {
    BuyJumbo = 1500,            --购买仙人仙彩
    JumbDescription = 1503,     --仙人仙彩说明

    ExchangeReward = 1505,   --兑奖
}

local DialogLibID = {
    JumbDescription = 18505,    -- 仙彩说明

    CanExchangeReward = 18507,  -- 可以领奖了                   1
    DoNotLottery = 18508,       -- 尚未开奖                     
    ShouldBuy = 18509,          -- 没买仙彩与奖品发放员对话     
    IsBuy = 18502,              -- 买过仙彩关闭购买页面对话
    IsExpired = 18567,          -- 奖券已过期对话（待修改）      2
    StateAfoot = 18568,         -- 开奖仪式不能领奖             3
    NotBoughtId = 18500,      -- 一次没买                       4
    BoughtSome = 18501,       -- 买了一些，但还有次数           5
    NoBuyCount = 18503,       -- 消耗完所有次数                 6
}

local CeremoneyShootMonsterID = {
    ShootNpc1 = 2002306,
    ShootNpc2 = 2002307,
    ShootNpc3 = 2002308,
    ShootNpc4 = 2002309,
}

local RelatedNpcID = {
    JumboDispenser = 1010446,   -- 仙人仙彩发放员
    PrizeRedeemer = 1010451,    -- 奖品兑换员
    NpcWLD = 1011079,           -- 薇蕾达
    LadyLuck = 1010471,        -- 幸运女神
}

local OptionList = {
    Buy = 2095706,
    Exchange = 2095707,
    Explain = 2095708,
}

local AnswerContentIDList = {
    Buy = 2095706,
    Exchange = 2095707,
    Explain = 2095708,
}

local CenterDynItemState = {
    ShowLight0 = 1,
    ShowLight1 = 2,
    ShowLight2 = 3,
    ShowLight3 = 4,
    ShowLight4 = 5,
    ShowLight5 = 6,
    ShowLight6 = 7,
    ShowLight7 = 8,
    ShowLight8 = 9,
    ShowLight9 = 10,
    ShowLight10 = 11,
    ShowLight11 = 12,
    ShowLight12 = 13,
    ShowLight13 = 14,
    ShowLight14 = 15,
    ShowLight15 = 16,
}

local LottoryWheelState = {
    Down = 13,
    StopTo0 = 3,
    StopTo1 = 4,
    StopTo2 = 5,
    StopTo3 = 6,
    StopTo4 = 7,
    StopTo5 = 8,
    StopTo6 = 9,
    StopTo7 = 10,
    StopTo8 = 11,
    StopTo9 = 12,
    Up = 1,
}

local StageOrnamentState = {
    HideLight = 1,
    ShowLight1 = 2,
    ShowLight2 = 3,
    ShowLight3 = 4,
    ShowLight4 = 5,
    ShowLight5 = 6,
    ShowLight6 = 7,
    ShowLight7 = 8,
}

local CenterPoleState = {
    Default = 0,                -- 默认就是在下面的
    Down = 1,
    UpIm = 2,                   -- 立即处于在上方的状态
    Up = 3,

    DownRotate = 5,
    UpRotate = 7,
}

local StagePoleState = {
    Default = 0,                -- 默认就是在下面的
    Down = 1,
    UpIm = 2,                   -- 立即升到最上方~
    Up = 3,
}

local JumbCondVal = {
    CanLottery = 1,
    IsExpired = 2,
    IsDuringCeremoney = 3,
    NoBuy = 4,
    BuySome = 5,
    NoPurchases = 6,
    ShowExplainJumbOption = 8,
    ShowBuyJumbOption = 7,
}

local JumboCeremoneyAssetPath = {
    ThrowMoneyAtl = "AnimMontage'/Game/Assets/Character/Action/emote_sp/sp15.sp15'",
    CongratulationAtl = "AnimMontage'/Game/Assets/Character/Action/emote/praise.praise'",
    SpotLightVfx = "VfxBlueprint'/Game/Assets/Effect/Particles/Branch/HGZ/Monster/JDYLC/VBP/BP_XRXC_1_Light.BP_XRXC_1_Light_C'",
    SpotLottoryLightVfx = "VfxBlueprint'/Game/Assets/Effect/Particles/Branch/HGZ/Monster/JDYLC/VBP/BP_XRXC_1_Light.BP_XRXC_1_Light_C'",
    GetRaffleVfx = "VfxBlueprint'/Game/Assets/Effect/Particles/JDYLC/XRXC/BP_b1536_gill_u.BP_b1536_gill_u_C'",
    GetRaffleVfx2 = "VfxBlueprint'/Game/Assets/Effect/Particles/Branch/HGZ/Monster/JDYLC/VBP/BP_XRXC_2_Light.BP_XRXC_2_Light_C'"
}

local JumboCeremoneyAudioAssetPath = {
    CountDown = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_countdown_1.Play_UI_countdown_1'",                                   -- 倒计时
    -- BeginLottory = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_begin.Play_UI_Lottery_begin'",                  -- 开始抽奖（关卡编辑器播放）
    FlickeringLights = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_camera.Play_UI_Lottery_camera'",            -- 灯光闪烁
    AssertLottory = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_draw_ending.Play_UI_Lottery_draw_ending'",     -- 确认中奖结果的音效
    LottoryCoin = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_coins.Play_UI_Lottery_coins'",                   -- 中奖洒落金币的音效
}

local JumboUIAudioPath = {
    GetReward = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_ending.Play_UI_Lottery_ending'",                -- 领奖音效
    GetFirstPrize = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_exchange_win.Play_UI_Lottery_exchange_win'", -- 获得一等奖仙人结彩
    GetFirstPrizeCheer = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_cheer.Play_UI_Lottery_cheer'",          -- 获得一等奖仙人结彩欢呼

    UISheelUp = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_exchange_popup.Play_UI_Lottery_exchange_popup'",  -- UI轮子升起音效
    UISheelBeginRotate = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_loop_1.Play_UI_Lottery_loop_1'",          -- UI轮子开始转动
    UISheelRotateRTPCName = "Lottery_speed",                                                                                                    -- RPTC 轮子加速
    UISheelStopLoop = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Stop_UI_Lottery_loop_1.Stop_UI_Lottery_loop_1'",             -- UI轮子停止循环
    UISheelStopRotate = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_exchange_gem.Play_UI_Lottery_exchange_gem'", -- UI轮子停止转动

    RewardBouns = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_paper.Play_UI_Lottery_paper'",                     -- 打开奖励加成
    LottoryRecord = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_board.Play_UI_Lottery_board'",                    -- 打开中奖履历
    PurEffectAudio = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_halo.Play_UI_Lottery_halo'",                     -- 购买动效的音效
    LottoryPaper = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_paper.Play_UI_Lottery_paper'",                      -- 彩票翻页
    LotteryBoard = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_tear.Play_UI_Lottery_tear'",                        -- 纸张被刮开
    RandomNum = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_slot_loop.Play_UI_Lottery_slot_loop'",                  -- 随机数过程音效
    StopRandom = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Stop_UI_Lottery_slot_loop.Stop_UI_Lottery_slot_loop'",                -- 随机结束
    PurAnimInAudio = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Lottery/Play_UI_Lottery_popup.Play_UI_Lottery_popup'",                    -- 购买界面进入
}

local GetWardItemBgPath = {
    First = "Texture2D'/Game/UI/Texture/JumboCactpot/UI_JumboCactpot_SettlementWin_Orange.UI_JumboCactpot_SettlementWin_Orange'",
    Second = "Texture2D'/Game/UI/Texture/JumboCactpot/UI_JumboCactpot_SettlementWin_Purple.UI_JumboCactpot_SettlementWin_Purple'",
    Third = "Texture2D'/Game/UI/Texture/JumboCactpot/UI_JumboCactpot_SettlementWin_Purple.UI_JumboCactpot_SettlementWin_Purple'",
    Four = "Texture2D'/Game/UI/Texture/JumboCactpot/UI_JumboCactpot_SettlementWin_Cyan.UI_JumboCactpot_SettlementWin_Cyan'",
    Fifth = "Texture2D'/Game/UI/Texture/JumboCactpot/UI_JumboCactpot_SettlementWin_Green.UI_JumboCactpot_SettlementWin_Green'",
}

local JumboCactpotDefine = 
{
    CeremoneyShootMonsterID = CeremoneyShootMonsterID,
    JumboUIAudioPath = JumboUIAudioPath,
    JumboCeremoneyAudioAssetPath = JumboCeremoneyAudioAssetPath,
    ChangeNumberPath = ChangeNumberPath,
    Path = Path,
    ColorDefine = ColorDefine,
    TimeDefine = TimeDefine,
    PriceDefine = PriceDefine,
    IconPath = IconPath,
    TalkContent = TalkContent,
    InteractiveID = InteractiveID,
    DialogLibID = DialogLibID,
    RelatedNpcID = RelatedNpcID,
    LottoryWheelState = LottoryWheelState,
    CenterPoleState = CenterPoleState,
    StagePoleState = StagePoleState,
    CenterDynItemState = CenterDynItemState,
    StageOrnamentState = StageOrnamentState,
    OptionList = OptionList,
    AnswerContentIDList = AnswerContentIDList,
    JumbCondVal = JumbCondVal,
    JumboCeremoneyAssetPath = JumboCeremoneyAssetPath,
    MaxStage = MaxStage,
    GetWardItemBgPath = GetWardItemBgPath
}

return JumboCactpotDefine