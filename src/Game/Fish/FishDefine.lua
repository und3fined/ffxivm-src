local LSTR = _G.LSTR
local ProtoCS = require("Protocol/ProtoCS")
local NoFishReason = ProtoCS.NoFishReason

---------------------捕鱼中使用的特定ID----------------

-- 捕鱼技能ID
local FishSKillID = {
    ShowBaitBagSkillID = 30303,
    Mooch_1 = 30304,
    Mooch_2 = 30313
}

-- 捕鱼相关BuffID
local FishBuffID = {
    SitBuffID = 99,
    IdenticalCastBuffID = 14,
    SurfaceSlapBuffID = 15
}

local ViewDisSettingID = 71 -- 视距设置表中ID
local MinCameraDis = 300

local SitAnim = "AnimSequence'/Game/Assets/Character/Human/Animation/c0101/a0001/lv_p_fsh/A_c0101a0001_lv_p_fsh-cblm_id1_fsc.A_c0101a0001_lv_p_fsh-cblm_id1_fsc'" -- 捕鱼站起动作资源
local StandAnim = "AnimSequence'/Game/Assets/Character/Human/Animation/c0101/a0001/lv_p_fsh/A_c0101a0001_lv_p_fsh-cblm_id1_fs.A_c0101a0001_lv_p_fsh-cblm_id1_fs'" -- 捕鱼坐下动作资源

local FishEffectDataAssetPath = "FishEffectDataAsset'/Game/BluePrint/Skill/Fish/FishEffectConfig.FishEffectConfig'" -- 钓鱼音效动作相关DA

local FishActionID = 23

---------------------捕鱼中使用的特定IDEND-----------------

---------------------捕鱼相关通知-----------------

-- 客户端判定抛竿失败原因
local ClientFishReason = {
    DisableSkill = 10,     -- 无法使用技能
    BagFull = 11,          -- 背包已满
    FishBaitExhaust = 12,  -- 鱼饵已耗尽
    LineTraceFail = 13,    -- 射线检测未通过
    DisableSetBait = 14    -- 钓鱼中无法更换鱼饵
}

-- 提竿失败原因
local FishLiftFailReason = {
    LiftTooEarly = 20,               -- 提竿过早（未到窗口期）
    LiftTooLate = 21,                -- 提竿过晚（超出窗口期）/提竿失败原因2：鱼已逃跑
    LiftLineBroken = 22,             -- 提竿失败原因1：鱼线损坏
    LiftTooLateConsumeBait = 23,     -- 提竿失败原因2：鱼已逃跑，且消耗拟饵
    LiftLineBrokenConsumeBait = 24,  -- 提竿失败原因1：鱼线损坏，且消耗拟饵
    LiftNoGathering = 25,            -- 玩家采集力不足
}

-- 客户端通知码
local FishErrorCode = {
    [NoFishReason.NoFishReason_NoMatch] = 20102,
    [NoFishReason.NoFishReason_Skill] = 20103,
    [NoFishReason.NoFishReason_TimeWeather] = 20104,
    [NoFishReason.NoFishReason_Level] = 20105,
    [NoFishReason.NoFishReason_Attr] = 20105,
    [NoFishReason.NoFishReason_BaitLevel] = 20115,
    [ClientFishReason.BagFull] = 20106,
    [ClientFishReason.DisableSkill] = 20107,
    [ClientFishReason.FishBaitExhaust] = 20129,
    [ClientFishReason.LineTraceFail] = 20132,
    [ClientFishReason.DisableSetBait] = 20133,
    [FishLiftFailReason.LiftTooEarly] = 20103,
    [FishLiftFailReason.LiftTooLate] = 20108,
    [FishLiftFailReason.LiftLineBroken] = 20109,
    [FishLiftFailReason.LiftTooLateConsumeBait] = 20110,
    [FishLiftFailReason.LiftLineBrokenConsumeBait] = 20111,
    [FishLiftFailReason.LiftNoGathering] = 20130,
}

-- 客户端buff相关通知码
-- 这里对应的是buffID，因此和上面的通知码分开配置
local FishBuffCode = {
    [FishBuffID.IdenticalCastBuffID] = 20128,
    [FishBuffID.SurfaceSlapBuffID] = 20127
}

---------------------捕鱼相关通知END-----------------

---------------------捕鱼相关文本----------------

-- 收藏品界面UI文本
local FishTipsWinText = {
    RichText = LSTR(160034),
    TextTaxRate = LSTR(160010),
    TitleText = LSTR(10032),
    ConfirmText = LSTR(10002),
    CancelText = LSTR(10003)
}

-- 自动放生UI文本
local FishNewItemTipsText = {
    TrueReleaseText = LSTR(160011),  -- 取消自动放生
    FalseReleaseText = LSTR(160008), -- 自动放生
    TextLevel = LSTR(160049)
}

-- 鱼饵背包UI文本
local FishNewWinItemText = {
    Title = LSTR(160012),
    TextUse = LSTR(160013),
    TextUsing = LSTR(160014),
    LevelText = LSTR(160051),
    TextBuy = LSTR(160069),
    TextToGet = LSTR(160067),
    TextOwn = LSTR(160068)
}

-- 获取鱼类弹出Icon文本
local FishNewThingTipsItemText = {
    TextLevel = LSTR(160054),
    TextSize = LSTR(160050)
}

-- 提竿计时面板UI
local FishNewTimeItemText = {
    TextThrow = LSTR(160052),
    TextBite = LSTR(160053)
}

---------------------捕鱼相关文本END-----------------

local FishDefine = {
    FishSKillID = FishSKillID,
    FishBuffID = FishBuffID,
    ViewDisSettingID = ViewDisSettingID,
    MinCameraDis = MinCameraDis,
    SitAnim = SitAnim,
    StandAnim = StandAnim,
    ClientFishReason = ClientFishReason,
    FishLiftFailReason = FishLiftFailReason,
    FishErrorCode = FishErrorCode,
    FishBuffCode = FishBuffCode,
    FishTipsWinText = FishTipsWinText,
    FishNewItemTipsText = FishNewItemTipsText,
    FishNewWinItemText = FishNewWinItemText,
    FishNewThingTipsItemText = FishNewThingTipsItemText,
    FishNewTimeItemText = FishNewTimeItemText,
    FishEffectDataAssetPath = FishEffectDataAssetPath,
    FishActionID = FishActionID
}

return FishDefine