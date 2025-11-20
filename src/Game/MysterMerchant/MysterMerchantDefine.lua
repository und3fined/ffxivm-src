---
--- Author: Carl
--- DateTime: 2024-6-09 11:36
--- Description:
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local MERCHANT = ProtoCS.Game.MysteryMerchant
local MERCHANT_CMD = MERCHANT.Cmd
local MerchantType = ProtoRes.MysteryMerchantType
local ETaskType = ProtoRes.Game.MerchantInteractiveType
local MERCHANT_TASK_STATUS = MERCHANT.MERCHANT_TASK_STATUS
local LSTR = _G.LSTR

local EBubbleType =
{
    Default = 1,
    FinishTask = 2,
    Shop = 3,
}

local TextColor = {
    Normal = "D5D5D5",
    NoEnoughRedHex = "DC5868FF",
}

--动作类型
local EATLType =
{
    DefaultIdle = 1,--默认，解围前
    Saved = 2,--获救动作
    FinishTaskIdle = 3,--解围后待机
    ShopIdle = 4, --交易待机
}

--通用提示ID
local TipID =
{
    EnterCryHelpArea = 
    {
        [1] = 330101,
        [2] = 330102,
        [3] = 330103,
    }, -- 进入求救范围,索引对应商人ID
    EnterSystemHint = 330112, -- 进入系统提示区域
    EnterArea = 330001, -- 进入触发区域
    NearEndTrade = 330104, -- 即将结束交易
    EndTrade = 330105, -- 结束交易
    InvestSuccess = 330106, -- 投资成功
    PickUpCargoTip = 330107, -- 拾取货物任务提示 （"商人的货物十分沉重，持有一定数量后将减慢移动速度！"）
    OverWeightTip = 330108, -- 货物超重提示
    InvestGoldCoinNotEnough = 330109, -- 金币不足
    EnoughEObjects = 330116, -- 已拾取足够多的货物了，交还给商人吧
}

--交互类型
local EndInteractType = 
{
    Reward = 500108, -- 投资回报
    Invest = 500109, -- 冒险投资
    SubmitItems = 500110, -- 提交任务货物
    Talk = 500111, -- 交谈
    OpenShop = 500112 -- 打开商店
}

local ItemColor = {
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_SlotWhite.UI_Shop_Img_SlotWhite'", 
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_SlotGreen.UI_Shop_Img_SlotGreen'", 
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_SlotBlue.UI_Shop_Img_SlotBlue'", 
    "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_SlotPurple.UI_Shop_Img_SlotPurple'" 
}

local SoundPath = {
    Settlement = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/TradingCaraven/Play_UI_TradingCaraven_finish.Play_UI_TradingCaraven_finish'",
    ExpUp = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/TradingCaraven/Play_UI_TradingCaraven_exp.Play_UI_TradingCaraven_exp'",
    UnlockGoods = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/TradingCaraven/Play_UI_Puzzle_Lvup.Play_UI_Puzzle_Lvup'",
    InvestTip = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Investment/Play_UI_Merchant_Investment.Play_UI_Merchant_Investment'",
    InvestRewardStart = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Investment/Play_UI_Merchant_Investment_Excavate.Play_UI_Merchant_Investment_Excavate'",
    InvestResultFailed = "",
    InvestResultSuccess = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Investment/Play_UI_Merchant_Investment_Succeed.Play_UI_Merchant_Investment_Succeed'",
    InvestResultSuperSuccess = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Investment/Play_UI_Merchant_Investment_Big_Succeed.Play_UI_Merchant_Investment_Big_Succeed'",
    InvestResultNumText = "AkAudioEvent'/Game/WwiseAudio/Events/UI/New_mod/Investment/Play_UI_Merchant_Investment_Amount.Play_UI_Merchant_Investment_Amount'"
}

local GoodsLimitBuyType = {
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER] = LSTR(1110038),--永久限购:
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_DAY] = LSTR(1110036), --每日限购:
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_WEEK] = LSTR(1110035),--每周限购:
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_MONTH] = LSTR(1110037)--每月限购:
}

local GoodsLimitBuyRemainNum = {
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER] = LSTR(1110011),--剩余数量（永久）：
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_DAY] = LSTR(1110007),--今日剩余数量：
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_WEEK] = LSTR(1110033),--本周剩余数量：
    [ProtoRes.COUNTER_TYPE.COUNTER_TYPE_MONTH] = LSTR(1110034)--本月剩余数量：
}

local TaskProgressText = {
    [ETaskType.InteractiveTypePickUpCargo] ={
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED] = LSTR(1110026),--拾取货物：%d/%d
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_WAIT_SUBMIT] = LSTR(1110021),--将货物还给商人
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH] = LSTR(1110008),--任务完成
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_NONE] = ""
    } ,
    [ETaskType.InteractiveTypeRepelMonster] ={
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED] = LSTR(1110010),--击退怪物：%d/%d
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_WAIT_SUBMIT] = "",
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH] = LSTR(1110008),--任务完成
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_NONE] = ""
    } ,
    [ETaskType.InteractiveTypeKillMonster] ={
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED] = LSTR(1110009),--击杀怪物：%d/%d
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_WAIT_SUBMIT] = LSTR(1110021),--将货物还给商人
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH] = LSTR(1110008),--任务完成
        [MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_NONE] = ""
    } ,
}

local EnumInvestResult = {
    Failed = 1,
    Success = 2,
    SpecialSuccess = 3,
}

local Title = LSTR(1110014)--商人奇遇
local EnterTipText = LSTR(1110014)--商人奇遇
local FriendlinessLevelText = LSTR(1110046) -- 1110046("友好度:%s/%s")
local MaxLevelText = LSTR(1110054) -- 1110054("友好度已满")
local InvestSuccessText = LSTR(1110055) -- 1110055("投资成功")
local InvestFailedText = LSTR(1110056) -- 1110056("投资成功")
local InvestSuccessSpecialText = LSTR(1110057) -- 1110057("点石成金")
local InvestRewardMultipleText = LSTR(1110058) -- 1110057("%s倍")

local MysterMerchantDefine = {
    Title = Title,
    EnterTipText = EnterTipText,
    MERCHANT_TASK_STATUS = MERCHANT_TASK_STATUS,
    MerchantType = MerchantType,
    ETaskType = ETaskType,
    TaskProgressText = TaskProgressText,
    ItemColor = ItemColor,
    LimitBuyType = GoodsLimitBuyType,
    LimitBuyNumTipsTitle = GoodsLimitBuyRemainNum,
    EBubbleType = EBubbleType,
    TipID = TipID,
    EATLType = EATLType,
    EndInteractType = EndInteractType,
    TextColor = TextColor,
    FriendlinessLevelText = FriendlinessLevelText,
    MaxLevelText = MaxLevelText,
    SoundPath = SoundPath,
    InvestSuccessText = InvestSuccessText,
    InvestFailedText = InvestFailedText,
    InvestSuccessSpecialText = InvestSuccessSpecialText,
    InvestRewardMultipleText = InvestRewardMultipleText,
    EnumInvestResult = EnumInvestResult,
}

return MysterMerchantDefine