---@author: Alex 2024-12-02 15:51:46
---@金蝶主界面的常量定义
local ProtoCS =  require("Protocol/ProtoCS")
local ProtoRes =  require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = require("Define/UIViewID")
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local ModuleID = ProtoCommon.ModuleID

local GoldSauserCurrencyID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE

local GoldSauserMapID = 12060
local ChocoboMapID = 12061
local function IsInGoldSauserSysMap(MapResID)
    return MapResID and (MapResID == GoldSauserMapID or MapResID == ChocoboMapID)
end

local AirShipPlatformMarkerID = 795 -- 乌尔达哈飞空艇标记ID
local AirShipPlatformUIMapID = 70 -- 乌尔达哈飞空艇地图UI ID

local TeleportTicketItemResID = 67000001 -- 金碟游乐场传送网使用券表格配置id

local TipsDistance = 300

local RedDotBaseName = "GoldSauserMain" 

local LockQuestColor = "313131ff"
local HintColor = "b56728ff"

local KingDeeShopID = 2002 -- 金碟币商店ID

local RandomStartLevel = 6 -- 小游戏终关随机关卡开始关卡

local RandomNeedRoundNum = 5 -- 终关小游戏需要的轮数

local AirplaneEndSpeed = 6 -- 小飞机游戏结束飞行速度

local BirdGameBombCapacity = 11 -- 拯救雏鸟游戏炸弹总量

local MainPanelItemState = 
{
    Default = 1,
    Selected = 2,
    Highlight = 3,
    NotOpen = 4, -- 未开放（待定）
}

local MiniGameEndCondition = 
{
    Interrupt = 1,
    Fail = 2,
    Succeed = 3,
}

---@enum  机遇临门子类型
local GameGateSubType = 
{
    AirplaneGame = GoldSauserGameClientType.GoldSauserGameTypeGateCircle, ---@param number 圆型广场
    EventSquare = GoldSauserGameClientType.GoldSauserGameTypeGateShow,  ---@param number 演出广场 
    BirdGame = GoldSauserGameClientType.GoldSauserGameTypeGateMagic, ---@param number 奇妙广场
}

---@enum  陆行鸟子类型
local GameChocoboSubType = 
{
    ChocoboTournament = GoldSauserGameClientType.GoldSauserGameTypeChocoboRace,  ---@param number 陆行鸟大赛
    ChocoboRaces = GoldSauserGameClientType.GoldSauserGameTypeChocobo, ---@param number 陆行鸟竞赛
}

---@enum 仙人仙彩
local GameFairyColorSubType = 
{
    JumboCactpot = GoldSauserGameClientType.GoldSauserGameTypeFairyColor,  ---@param number 仙人仙彩
}

---@enum  幻卡子类型
local GameFantasyCardSubType = 
{
    TripleTriadCard = GoldSauserGameClientType.GoldSauserGameTypeFantasyCard,  ---@param number 九宫幻卡
    NextTripleTriadTornament = GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace, ---@param number 幻卡大赛
}

---@enum 仙人微彩
local GameMiniCactpotSubType =
{
    MiniCactpot = GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot, ---@param number 仙人微彩
}

---小游戏参数枚举
local MiniGameEnum = 
{
    AirForceOneStartTime = 1,-- 空军装甲飞机初始驻留时间
    AirForceOneEndTime = 2, -- 空军装甲飞机自然离场时间
    AirForceOneClickedSpeed = 3,-- 空军装甲飞机被点击移速
    AirForceOneClickedspeedupTime = 4, -- 空军装甲飞机被点击加速时间
    CliffHangerStartTime = 5,-- 小雏鸟初始驻留时间
    CliffHangerEndTime = 6,-- 小雏鸟自然离场时间
    CliffHangerBombExplodedTime = 7,-- 小雏鸟炸弹爆炸时间
    CliffHangerBombShowTime = 8,-- 小雏鸟每轮炸弹生成时间
    TyphonStartTime = 9,-- 提丰初始驻留时间
    TyphonEndTime = 10,-- 提丰自然离场时间
    TyphonClickedInterval = 11,-- 提丰按键响应间隔
    TyphonWarningTime = 12,-- 提丰警示时间
    TyphonJetTime = 13,-- 提丰喷风时间
    BodyGuardStartTime = 14,-- 保镖小游戏初始驻留时间
    BodyGuardEndTime = 15,-- 保镖小游戏自然离场时间
    BodyGuardInputTime = 16,-- 保镖小游戏每轮输入限时
    BodyGuardBambooGenerateInterval = 17,-- 保镖小游戏竹子创建间隔
    BodyGuardInputDeviation = 18,-- 保镖小游戏输入角度误差
    BodyGuardOneBambooPool = 19,-- 保镖小游戏第一轮竹子池
    BodyGuardTwoBambooPool = 20,-- 保镖小游戏第二轮竹子池
    BodyGuardThreeBambooPool = 21,-- 保镖小游戏第三轮竹子池
    BodyGuardFourBambooPool = 22,-- 保镖小游戏第四轮竹子池
}

local TimeLimitGameType = 
{
    GoldSauserGameClientType.GoldSauserGameTypeFairyColor, --@仙人仙彩
    GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot, --@仙人微彩
    GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace, --@幻卡大赛
    GoldSauserGameClientType.GoldSauserGameTypeFashionCheck, --@时尚品鉴
    GoldSauserGameClientType.GoldSauserGameTypeChocoboRace, --@陆行鸟大赛
}

local JionLimitGameType = 
{
    GoldSauserGameClientType.GoldSauserGameTypeFairyColor, --@仙人仙彩
    GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot, --@仙人微彩
    GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace, --@幻卡大赛
   -- GoldSauserGameType.GoldSauserGameTypeFashionCheck, --@时尚品鉴
   -- GameChocoboSubType.ChocoboTournament, --@陆行鸟大赛
}

local AssistInfoGameType = 
{
    GoldSauserGameClientType.GoldSauserGameTypeChocoboRace, --@陆行鸟大赛
    GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace, --@幻卡大赛 
}

---@金蝶游乐场水晶ID
local GoldSauserCrystalPortalID =
{
    GoldSauserMain = 62, ---@金蝶游乐场
    [GameFantasyCardSubType.TripleTriadCard] = 63, ---@幻卡广场
    [GameFantasyCardSubType.NextTripleTriadTornament] = 63, ---@幻卡广场
    [GameFairyColorSubType.JumboCactpot] = 67,---@仙人彩
    [GameMiniCactpotSubType.MiniCactpot] = 63,---@仙人彩
    [GameGateSubType.EventSquare] = 66, ---@演出广场
    [GameGateSubType.AirplaneGame] = 68, ---@圆形广场
    [GameGateSubType.BirdGame] = 65, ---@奇妙广场
    [GameChocoboSubType.ChocoboRaces] = 89, ---@陆行鸟广场
    [GameChocoboSubType.ChocoboTournament] = 89, ---@陆行鸟广场
}

---@金蝶游乐场玩法NPCID
local GoldSauserNpcID =
{
    [GameFantasyCardSubType.TripleTriadCard] = 1010479, ---@幻卡广场
    [GameFantasyCardSubType.NextTripleTriadTornament] = 1010479, ---@幻卡广场
    [GameFairyColorSubType.JumboCactpot] = 1010446,---@仙人彩
    [GameMiniCactpotSubType.MiniCactpot] = 1010445,---@仙人彩
    [GameGateSubType.EventSquare] = 1011093, ---@演出广场
    [GameGateSubType.AirplaneGame] = 1011084, ---@圆形广场
    [GameGateSubType.BirdGame] = 1011080, ---@奇妙广场
    [GameChocoboSubType.ChocoboRaces] = 1010464, ---@陆行鸟广场
    [GameChocoboSubType.ChocoboTournament] = 89, ---@陆行鸟广场(暂未配置)
    [GoldSauserGameClientType.GoldSauserGameTypeFashionCheck] = 2130, ---@时尚品鉴（非NPC）
}

---@金蝶游乐场玩法解锁NPCID
local GoldSauserUnlockNpcID =
{
    [GameFantasyCardSubType.TripleTriadCard] = 1011060, ---@幻卡广场
    [GameFantasyCardSubType.NextTripleTriadTornament] = 1011060, ---@幻卡广场
    [GameFairyColorSubType.JumboCactpot] = 1010446,---@仙人彩
    [GameMiniCactpotSubType.MiniCactpot] = 1010445,---@仙人彩
    [GameChocoboSubType.ChocoboRaces] = 1010464, ---@陆行鸟竞赛
    [GameChocoboSubType.ChocoboTournament] = 89, ---@陆行鸟广场(暂未配置)
    [GoldSauserGameClientType.GoldSauserGameTypeFashionCheck] = 1011145, ---@时尚品鉴
}

---@金蝶游乐场玩法解锁任务ID
local GoldSauserUnlockQuestID =
{
    [GoldSauserGameClientType.GoldSauserGameTypeFashionCheck] = 171107, ---@时尚品鉴
}

---@金蝶游乐场所处MapID
local GoldSauserTargetMapID =
{
    [GameFantasyCardSubType.TripleTriadCard] = GoldSauserMapID, ---@幻卡广场
    [GameFantasyCardSubType.NextTripleTriadTornament] = GoldSauserMapID, ---@幻卡广场
    [GameFairyColorSubType.JumboCactpot] = GoldSauserMapID,---@仙人彩
    [GameMiniCactpotSubType.MiniCactpot] = GoldSauserMapID,---@仙人彩
    [GameGateSubType.EventSquare] = GoldSauserMapID, ---@演出广场
    [GameGateSubType.AirplaneGame] = GoldSauserMapID, ---@圆形广场
    [GameGateSubType.BirdGame] = GoldSauserMapID, ---@奇妙广场
    [GameChocoboSubType.ChocoboRaces] = ChocoboMapID, ---@陆行鸟广场
    [GameChocoboSubType.ChocoboTournament] = ChocoboMapID, ---@陆行鸟广场
    [GoldSauserGameClientType.GoldSauserGameTypeFashionCheck] = GoldSauserMapID, ---@时尚品鉴（非NPC）
}

local BambooBaseTexture = 
{
    None = 0,
    Horizontal = 1,
    Vertical = 2,
    Slashes = 3,
    Backslashes = 4,
    Other = 99,
}

--todo 后续看是否给策划来配,只能配 -90 ~ 90度
local BambooStyleList = 
{
    [1] = { [1] = -45, },
    [2] = { [1] = 45 },
    [3] = { [1] = 45, [2] = -45, },
    [4] = { [1] = 90 },
    [5] = { [1] = 45, [2] = -45,},
    [6] = { [1] = 45, [2] = 45,[3] = 45, },
    [7] = { [1] = -45, [2] = -45,[3] = -45, },
    [8] = { [1] = 0, [2] = -45, [3] = 0},
    [9] = { [1] = 45, [2] = 45,[3] = 45 },
    [10] = { [1] = 0, [2] = 45, [3] = 0 },
}



--- 小飞机运动阶段
local AirplaneMoveState = {
    ["Start"] = 1,
    ["End"] = 2,
}

--- 小飞机运动阶段
local AirplaneTailType = {
    ["SlowSmoke"] = 1,
    ["QuickSmoke"] = 2,
    ["Fire"] = 3,
}

--- 保镖小游戏广场表现动画状态
local BodyGuardSquareAnimState = {
    ["Idle"] = 1, -- 待机
    ["Act"] = 2,  -- 挥刀
    ["ActSuccess"] = 3, -- 挥刀成功
    ["ActFail"] = 4, -- 挥刀失败
    ["ChallengeSuccess"] = 5, -- 挑战成功
}

--- 异步拉取内容模块种类
local AsyncReqModuleType = {
    ["None"] = 0,
    ["Assist"] = 1, -- 辅助信息
    ["Hint"] = 2, -- 提示信息
    ["Time"] = 3, -- 时限信息
}

local WinDataItemBgSrcPath = {
    ["NotListed"] = "PaperSprite'/Game/UI/Atlas/GoldSauserMainPanel/Frames/UI_GoldSauserMainPanel_Img_DataListBG_Grey_png.UI_GoldSauserMainPanel_Img_DataListBG_Grey_png'", -- 未上榜
    ["Sabotender"] = "PaperSprite'/Game/UI/Atlas/GoldSauserMainPanel/Frames/UI_GoldSauserMainPanel_Img_DataListBG_Blue_png.UI_GoldSauserMainPanel_Img_DataListBG_Blue_png'", -- 仙人刺
    ["Morbol"] = "PaperSprite'/Game/UI/Atlas/GoldSauserMainPanel/Frames/UI_GoldSauserMainPanel_Img_DataListBG_Yellow_png.UI_GoldSauserMainPanel_Img_DataListBG_Yellow_png'", -- 魔界花
    ["Titan"] = "PaperSprite'/Game/UI/Atlas/GoldSauserMainPanel/Frames/UI_GoldSauserMainPanel_Img_DataListBG_Rad_png.UI_GoldSauserMainPanel_Img_DataListBG_Rad_png'", -- 泰坦
}

local TraceMarkerType = {
    ["Crystal"] = 1,
    ["Npc"] = 2,
    ["Place"] = 3, -- 时尚品鉴，非Npc，非水晶
    ["Quest"] = 4,
}

local ViewNeedCactusCheckAfterClosed = {
    [UIViewID.FashionEvaluationNPCPanel] = true,
    [UIViewID.GoldSaucerMainPanelChallengeNotesWin] = true,
    [UIViewID.GoldSauserMainPanelDataWinItem] = true,
    [UIViewID.GoldSauserMainPanelExchangeWin] = true,
    [UIViewID.JumboCactpotBuyTipsWin] = true,
    [UIViewID.PlayStyleMapWin] = true,
}

local GoldSauserMainClientType2ModuleID = {
    [GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot] = ModuleID.ModuleIDMiniCactpot,
    [GoldSauserGameClientType.GoldSauserGameTypeFairyColor] = ModuleID.ModuleIDFairyColor,
    [GoldSauserGameClientType.GoldSauserGameTypeChocobo] = ModuleID.ModuleIDChocoboRace,
    [GoldSauserGameClientType.GoldSauserGameTypeChocoboRace] = ModuleID.ModuleIDChocoboRace,
    [GoldSauserGameClientType.GoldSauserGameTypeFantasyCard] = ModuleID.ModuleIDFantasyCard,
    [GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace] = ModuleID.ModuleIDFantasyCard,
    [GoldSauserGameClientType.GoldSauserGameTypeFashionCheck] = ModuleID.ModuleIDFashionCheck,
}

local BirdBombState = {
    ["Default"] = 0, -- 不显示
    ["Created"] = 1, -- 创建初始化
    ["TurnToRed"] = 2, -- 即将爆炸
    ["Exploded"] = 3, -- 爆炸
    ["Cleared"] = 4, -- 点击清除
}

local AudioType = {
    ["EasyMap"] = 1, -- 便捷地图
    ["GetAward"] = 2, -- 领取奖励
    ["GameStart"] = 3, -- 游戏开始
    ["FlyJetStart"] = 4, -- 飞行喷气开始
    ["FlyJetStop"] = 5, -- 飞行喷气结束
    ["QTECircle"] = 6, -- QTE光圈及交互成功
    ["QTEFail"] = 7, -- 小飞机QTE失败
    ["FlyJetAcc"] = 8, -- 飞行喷气加速
    ["BombReding"] = 9, -- 炸弹引线燃烧
    ["BombExplode"] = 10, -- 炸弹爆炸
    ["SuccTip"] = 11, -- 成功tip
    ["SubView"] = 12, -- 子界面打开
    ["SideView"] = 13, -- 侧边栏界面打开
}

local AudioPath = {
    [AudioType.EasyMap] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_TanChuang.Play_FM_UI_TanChuang'",
    [AudioType.GetAward] = "", -- 创建初始化
    [AudioType.GameStart] = "", -- 游戏开始
    [AudioType.FlyJetStart] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_FeiXing.Play_FM_UI_FeiXing'", 
    [AudioType.FlyJetStop] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Stop_FM_UI_FeiXing.Stop_FM_UI_FeiXing'",
    [AudioType.QTECircle] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_GuangQuan.Play_FM_UI_GuangQuan'",
    [AudioType.QTEFail] = "",
    [AudioType.FlyJetAcc] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_Jiasu.Play_FM_UI_Jiasu'",
    [AudioType.BombReding] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_YinXian.Play_FM_UI_YinXian'",
    [AudioType.BombExplode] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_BaoZha.Play_FM_UI_BaoZha'",
    [AudioType.SuccTip] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_title.Play_FM_UI_title'",
    [AudioType.SubView] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_TanChuang_1.Play_FM_UI_TanChuang_1'",
    [AudioType.SideView] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Play_FM_UI_TanChuang_2.Play_FM_UI_TanChuang_2'",
} 

local GoldSauserMainPanelDefine = {
    GoldSauserCurrencyID = GoldSauserCurrencyID,
    MainPanelItemState = MainPanelItemState,
    GameGateSubType = GameGateSubType, 
    GameChocoboSubType = GameChocoboSubType, 
    GameFairyColorSubType = GameFairyColorSubType, 
    GameMiniCactpotSubType = GameMiniCactpotSubType,
    TimeLimitGameType = TimeLimitGameType,
    JionLimitGameType = JionLimitGameType,
    GoldSauserMapID = GoldSauserMapID,
    ChocoboMapID = ChocoboMapID,
    GameFantasyCardSubType = GameFantasyCardSubType,
    GoldSauserCrystalPortalID = GoldSauserCrystalPortalID,
    TipsDistance = TipsDistance,
    MiniGameEndCondition = MiniGameEndCondition,
    BambooBaseTexture = BambooBaseTexture,
    BambooStyleList = BambooStyleList,
    MiniGameEnum = MiniGameEnum,
    AirplaneMoveState = AirplaneMoveState,
    BodyGuardSquareAnimState = BodyGuardSquareAnimState,
    RedDotBaseName = RedDotBaseName,
    AssistInfoGameType = AssistInfoGameType,
    LockQuestColor = LockQuestColor,
    HintColor = HintColor,
    AsyncReqModuleType = AsyncReqModuleType,
    WinDataItemBgSrcPath = WinDataItemBgSrcPath,
    KingDeeShopID = KingDeeShopID,
    AirShipPlatformMarkerID = AirShipPlatformMarkerID,
    AirShipPlatformUIMapID = AirShipPlatformUIMapID,
    TeleportTicketItemResID = TeleportTicketItemResID,
    GoldSauserNpcID = GoldSauserNpcID,
    GoldSauserTargetMapID = GoldSauserTargetMapID,
    TraceMarkerType = TraceMarkerType,
    GoldSauserUnlockNpcID = GoldSauserUnlockNpcID,
    GoldSauserUnlockQuestID = GoldSauserUnlockQuestID,
    ViewNeedCactusCheckAfterClosed = ViewNeedCactusCheckAfterClosed,
    GoldSauserMainClientType2ModuleID = GoldSauserMainClientType2ModuleID,
    BirdBombState = BirdBombState,
    AirplaneTailType = AirplaneTailType,
    RandomStartLevel = RandomStartLevel,
    RandomNeedRoundNum = RandomNeedRoundNum,
    AirplaneEndSpeed = AirplaneEndSpeed,
    BirdGameBombCapacity = BirdGameBombCapacity,
    AudioType = AudioType,
    AudioPath = AudioPath,
    IsInGoldSauserSysMap = IsInGoldSauserSysMap,
}

return GoldSauserMainPanelDefine