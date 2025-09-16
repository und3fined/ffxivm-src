---
---@Author: ZhengJanChuan
---@Date: 2023-05-11 09:43:37
---@Description: 教程常量类
---

-- 强制引导强制跳过点击次数
local SkipTutorialClickNum = 10

local TutorialStateKey = 100
local SoftTutorialKey = 101
local ForceTutorialKey = 102
local GuideTutorialKey = 103
local GuideTutorialSpecialKey = 104
local TutorialNetSyncKey = 105
local TutorialMonsterGuide = 106
local TutorialGuideStateKey = 107

--引导类型
local TutorialType = {
    Soft = 0,
    Force = 1,
    Tips = 2,
    NoFuncForce = 3,
    NoFuncSoft = 4,
}

-- 引导是否自动播放
local AutoPlayType = {
    NoPlay = 0,
    Auto = 1,
}

local OfflineType = {
    Skip = 1,
    Redo = 2,
}

-- 引导特殊ID，用来做特殊逻辑
local TutorialSpecialID = {
    Rotation = 1,
    Zoom = 2,
    Move = 3,
    FirstGuide = 14,
}

-- 引导箭头方向，左上右下
local TutorialArrowDir = {
    Top = 1,
    Bottom = 2,
    Left = 3,
    Right = 4,
}

-- 引导需要执行事件类型，按钮/列表/开关/地图/技能
local TutorialHandleType = {
    Button = 1,     
    TableView = 2,
    ToggleGroup = 3,
    Map = 4,
    Skill = 5,
}

--锚点方向
local TutorialPivotType = {
    LeftTop = 1,
    Top = 2,
    RightTop = 3,
    Left = 4,
    Center = 5,
    Right = 6,
    LeftBottom = 7,
    Bottom = 8,
    RightBottom = 9,
}

-- 弃用
local TutorialGuideType = {
    Title = 0,
    Content = 1,
}


-- 启用
local TutorialSearchType = {
    Title = 1,
    Content = 2,
}


-- 地图引导使用时，文字内容的位置
local TutorialContentPos = {
    Top = {X = 0, Y = 222},
    Left = {X = -176, Y = 124},
    Right = {X = 176, Y = 124},
    Bottom = {X = 0, Y = 22},
}

-- 新手引导开关
local TutorialSwitchType = {
    On = 1,
    Off = 2,
}

local TutorialNodeStatus = {
    None = 1, ---未开始
    Running = 2, ---进行中
    Finish = 3, ---完成
}

local NearTargetFieldType = {
    NPC = 1,
    Gather = 2,
    Mysterybusinessman = 3,
    Touring = 4,
    LimitTimeGather = 5, --限时采集
    Chocobo = 6, --陆行鸟
    DiscoverNote = 7, --探索笔记
    AetherCurrent = 8, --风脉泉
}

local GameplayType = {
    BuoyAether = 1, --风脉泉
    GoldSauser = 2, --营救小雏鸟
    Yojimbo = 3, --快刀斩魔
    JumboCactpot = 4, --仙人仙彩
    FashionCheckRecpt = 5, --时尚品鉴
    MagicCard = 6, --幻卡大赛
    MiniCactpot = 7, --仙人微彩
    Chocobo = 8, --陆行鸟竞赛
    GoldSauserMiniGames = 9, --金碟小游戏
    JiYuLingMen = 10, --机遇临门
    FantasyCard = 11, --九宫幻卡
}

local GamePlayStage = {
    MagicCardUnlock = 1, --幻卡解锁弱引导
    MagicCardMatch = 2, --幻卡匹配
    BuoyAetherFly = 3, --风暴泉飞行引导
    YojimboDuoBi = 4, --快刀躲避大五郎阶段
    GoldSauserStart = 5, --营求小雏鸟进入引导
    YojimboBambooFalls = 6, --快刀躲避竹子倒下阶段
    FashionCheckRecptRepeatEnter = 7, --时尚品鉴第N次进入
    MiniCactpotOpenThreeBox = 8, --仙人微彩打开3个格子
    MiniCactpotSelectLine = 9, --仙人微彩选择一条直线
    ChocoboSpeed = 10,--陆行鸟引导加速
    ChocoboOutSpeed = 11, --陆行鸟超速
    ChocoboGetTreasure = 12, --陆行鸟获得宝箱
    ChocoboUseSkill = 13, --陆行鸟使用技能
    ChocoboTips1 = 14, --陆行鸟玩家进茺超过90%且剩余体力大于50%时
    ChocoboTips2 = 15, --玩家达到疲备时
    MiniCactpotOpenThreeBoxNoMoney = 16, --玩家金碟币不足无法购买
    FantasyCardRuleGuide = 17, --九宫幻卡规则详情引导
    FantasyCardCardGroup = 18, --九宫幻卡卡组预览
}

-- 触发条件类型
local TutorialConditionType = {
    DefaultGuide = 1, --默认提示
    TutorialTaskStart = 2, --接受任务(这里要填任务最后一个子任务ID)
    TutorialTaskEnd = 3, --完成任务(这里要填任务最后一个子任务ID)
    GetItem = 4, --获得物品
    SystemUnlock = 5, --解锁系统
    NearTargetField = 6, --接近目标范围(1 NPC,2 采集点 3 神秘商人 4 巡回乐团 5 限时采集 6 陆行鸟)
    GuideComplete = 7, --完成特定引导后直接弹后引导
    ProfChange = 8, --转职成功
    SkillUnlock = 9, --习得技能
    GatheringStatus = 10, --进入采集状态
    CollectionGatheringStatus = 11, --进入收藏品采集状态
    ProfLevel = 12, --职业升级
    ProductStatus = 13, --进行制作状态
    SpecialCookerStatus = 14, --厨师特殊条件
    Fate = 15, --Fate
    GamePlayCondition = 16, --玩法节点(双参数 玩法ID节点ID)
    GetClue = 17, --探索笔记(获得线索)(需要对应同事接入)
    UnlockGameplay = 18, --解锁玩法(需要对应同事接入)
    DiggingMound = 19, --挖土堆野外宝箱(需要对应同事接入)
    GetSightClue = 20, --获得风景点线索(需要对应同事接入)
    SpecialProfChange = 21,--转成特定职业
    SpectrumsUnlock = 22, --量谱解锁
    ChocoboRegisterSuccess = 23, --陆行鸟登记成功
    UseItem = 24, --物品使用(填大小类型不填具体ID)
    ClassLevel = 25, --职业类等级(如能工巧匠)
    UseSkill = 26, --使用技能如捕鱼挥杆
    Fog = 27, --迷雾解锁
    OpenMagicCardRoom = 28, --开启幻卡对局室
    SmallCrystal = 29, --小水晶共鸣
    MonsterNearMajor = 30, --怪物附近
    ActorVelocityUpdate = 31, --玩家速度变化
    FirstCraftedHQItem = 32, --制作笔记普通制作成功(需要对应同事接入)
    UnLockCraftingLog = 33, --解锁制作笔记(需要对应同事接入)
    ProductProfSpecialEvent = 34, --制作职业特殊事件(需要对应同事接入)
    UnlockRiderItem = 35, --解锁坐骑道具
    AdvanceFate = 36, --高危FATE
    AdvanceProf = 37, --首次转职特职
    CutFinish = 38, --Cut结束
    Interactive = 39, --主动交互
    OpenDragonTreasurebox = 40, --开启副本宝箱
    ExcludeMainQuestTaskStart = 41, --接取非主线任务
    CrafterEquipDurabilityValue = 42, --生产装备耐久度
    AetherCurrent = 43, --风脉泉
    FateLostLady = 44, -- FATE迷失少女
    FateBattleRune = 45, -- FATE战场符文
    BattleEquipDurabilityValue = 46, -- 战斗采集装备耐久度
    RiderSystem = 47, --坐骑系统引导(第一次进野外)
    EndPlayUnlockAnimation = 48, --解锁动画播放完
    UseSpecialItem = 49, --使用指定物品
    TreasureNBSP = 50, --传送魔纹
    PVPMap = 51, --pvp地图
    OpenRecruitView = 52 --打开招募界面
}

local InteractiveType = {
    NPC = 1,
    EObj = 2
}

--结束条件
local TutorialEndCondition = {
    CameraRotate = 1, --锐头旋转
    CameraScale = 2, --镜头缩放
    PlayerMovement = 3, --玩家移动
    ClickBtn = 4, --点击按扭
    SelectItem = 5, --选中列表ITEM
    PressBtn = 6, --按压按扭
}

local TutorialDefine = {
    SkipTutorialClickNum = SkipTutorialClickNum,
    TutorialType = TutorialType,
    TutorialHandleType = TutorialHandleType,
    TutorialStateKey = TutorialStateKey,
    TutorialGuideStateKey = TutorialGuideStateKey,
    TutorialArrowDir = TutorialArrowDir,
    SoftTutorialKey = SoftTutorialKey,
    ForceTutorialKey = ForceTutorialKey,
    GuideTutorialKey = GuideTutorialKey,
    GuideTutorialSpecialKey = GuideTutorialSpecialKey,
    AutoPlayType = AutoPlayType,
    TutorialGuideType = TutorialGuideType,
    TutorialSearchType = TutorialSearchType,
    TutorialSpecialID = TutorialSpecialID,
    TutorialContentPos = TutorialContentPos,
    TutorialSwitchType = TutorialSwitchType,
    TutorialConditionType = TutorialConditionType,
    TutorialEndCondition = TutorialEndCondition,
    TutorialNodeStatus = TutorialNodeStatus,
    TutorialNetSyncKey = TutorialNetSyncKey,
    OfflineType = OfflineType,
    NearTargetFieldType = NearTargetFieldType,
    TutorialPivotType = TutorialPivotType,
    GameplayType = GameplayType,
    GamePlayStage = GamePlayStage,
    TutorialMonsterGuide = TutorialMonsterGuide,
    InteractiveType = InteractiveType,

    --需要储存的数据Key
    TutorDataTypeEnum = {
        Prof = 1,      --转职
        FristEnterGather = 2,  --首次采集
        FristEnterCollection = 3,  --首次收藏品采集
        FristRecipeState = 4,
        FristCrafterRandomEvent = 5, --制作随机事件
        FirstThrowRod = 6,
        Step = 7,
    }
}


 return TutorialDefine
