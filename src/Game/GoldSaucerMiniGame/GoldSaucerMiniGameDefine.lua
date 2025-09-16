---
--- Author: Alex
--- DateTime: 2023-10-08 10:53:13
--- Description: 金蝶小游戏
---

local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local ProtoCommon = require("Protocol/ProtoCommon")
local RaceType = ProtoCommon.race_type
local ACTIVITY_TYPE = ProtoCS.ACTIVITY_TYPE
local ALONE_TREE_HAND_FEEL = ProtoCS.ALONE_TREE_HAND_FEEL
local LSTR = _G.LSTR
local UE = _G.UE


local EmotionDefaultPath = "AnimMontage'/Game/Assets/Character/Action/%s'"
-- AnimMontage'/Game/Assets/Character/Action/emote/amazed.amazed'
-- 小游戏类型枚举
local MiniGameType = {
    ["None"] = 0,
    ["OutOnALimb"] = ACTIVITY_TYPE.ACTIVITY_TYPE_ALONE_TREE,  --孤树无援 1 
    ["TheFinerMiner"] = ACTIVITY_TYPE.ACTIVITY_TYPE_ORE_SEARCH,  --矿脉探索 2
    ["MonsterToss"] = 3, -- 怪物偷投篮
    ["Cuff"] = 4, -- 重击小游戏
    ["MooglesPaw"] = 5, -- 莫古抓球机
    ["CrystalTower"] = 6, -- 强袭水晶塔

}

-- 小游戏阶段枚举
local MiniGameStageType = {
    ["Enter"] = 0, -- 进入游戏
    ["DifficultySelect"] = 1, -- 难度选择
    ["Start"] = 2,  -- 游戏开始
    ["Update"] = 3,  --游戏循环
    ["End"] = 4,  --游戏循环结束
    ["Restart"] = 5,  --游戏翻倍挑战
    ["Reward"] = 6,  --游戏奖励结算
    ["FailInfoShow"] = 7, -- 失败信息展示
    ["Quit"] = 8,  --游戏退出
}

local MiniGameDifficulty = {
    ["Sabotender"] = 1, -- 仙人刺
    ["Morbol"] = 2, -- 魔界花
    ["Titan"] = 3, -- 泰坦
}

local ExtraChanceResetPolicy = {
    ["None"] = 0, -- 都不重置
    ["OnlyTime"] = 1, --仅时间重置
    ["OnlyCount"] = 2, --仅次数重置
    ["TimeAndCount"] = 3, --时间和次数都重置
}

local MiniGameProgressType = {
    ["Perfect"] = ALONE_TREE_HAND_FEEL.ALONE_TREE_HAND_FEEL_OK, -- 手感很好
    ["Nice"] = ALONE_TREE_HAND_FEEL.ALONE_TREE_HAND_FEEL_WELL, -- 手感不错
    ["Good"] = ALONE_TREE_HAND_FEEL.ALONE_TREE_HAND_FEEL_LITTLE, -- 有手感了
    ["Bad"] = ALONE_TREE_HAND_FEEL.ALONE_TREE_HAND_FEEL_FAILED, -- 失败
}

local MiniGameRoundEndState = {
    ["None"] = 0, -- 直接跳过至退出结算
    ["Success"] = 1, -- 单轮成功
    ["FailTime"] = 2, -- 失败(时间)
    ["FailChance"] = 3, -- 失败(次数)
    ["FailRule"] = 4, -- 失败(规则)
}


local MiniGameTickInterval = 0.05 -- 小游戏循环间隔时间
local DefaultSlot = "Additive_Body"
-- 时间阶段的下限
local TimeStageLimit = {
    ["Normal"] = 10,
    ["Urgent"] = 3,
}

--- 矿脉探索的圆圈类型
local TheFinerMinerCircleType = {
    ["Yellow"] = 1,
    ["Blue"] = 2,
    ["Red"] = 3,
}

local AnimTimeLineSourceKey = {
    ["FellingIdle"] = 1,
    ["FellingAct"] = 2,
    ["MiningIdle"] = 3,
    ["MiningAct"] = 4,
    ["CuffIdle"] = 5,
    ["CuffAct"] = 6,
    ["BaskIdle"] = 7,
    ["BaskAct"] = 8,
    ["CrystalTowerIdle"] = 9,
    ["CrystalTowerAct"] = 10,
    ["MooglePawIdle"] = 11,
}

--- TimeLine动画的资源路径deprecate(移至各小游戏ClientDef内配置)
local AnimTimeLineSourcePath = {
    [AnimTimeLineSourceKey.FellingIdle] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_felling_lp.cbnm_gs_felling_lp'",
    [AnimTimeLineSourceKey.FellingAct] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_act.cbnm_gs_felling_act'",
    [AnimTimeLineSourceKey.MiningIdle] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_mining_lp.cbnm_gs_mining_lp'",
    [AnimTimeLineSourceKey.MiningAct] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_act.cbnm_gs_mining_act'",
    [AnimTimeLineSourceKey.CuffIdle] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_lp.cbnm_gs_punch_lp'",
    [AnimTimeLineSourceKey.CuffAct] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_act.cbnm_gs_punch_act'",
    [AnimTimeLineSourceKey.BaskIdle] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0801/a0001/normal/timeline/base/b0001/cbnm_gs_basket_lp.cbnm_gs_basket_lp'",
    [AnimTimeLineSourceKey.BaskAct] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'",
    [AnimTimeLineSourceKey.CrystalTowerIdle] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_lp.cbnm_gs_hummer_lp'",
    [AnimTimeLineSourceKey.CrystalTowerAct] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_act.cbnm_gs_hummer_act'",
    [AnimTimeLineSourceKey.MooglePawIdle] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_ufo_lp.cbnm_gs_ufo_lp'",
}

--- 矿脉探索的圆圈UI半径（弃用，蓝图定死）
local TheFinerMinerCircleSize = {
    [TheFinerMinerCircleType.Yellow] = 440,
    [TheFinerMinerCircleType.Blue] = 350,
    [TheFinerMinerCircleType.Red] = 360,
}

--- 莫古抓球机操作按钮激活状态枚举
local MoogleActBtnActiveType ={
    ["Invalid"] = 0,
    ["Horizontal"] = 1,
    ["Vertical"] = 2,
}

--- 莫古抓球机莫古力运动方向枚举
local MoogleMoveDir ={
    ["Idle"] = 0,
    ["Horizontal"] = 1,
    ["Vertical"] = 2,
}

--- 莫古抓球机莫古力运动状态
local MoogleMoveState ={
    ["Idle"] = 0,
    ["LinerMove"] = 1,
    ["LowSpeedMoveH"] = 2,
    ["LowSpeedMoveV"] = 3,
    ["OutGame"] = 4,
}

-- 蓝图莫古力初始坐标
local MoogleInitPos = {
    ["X"] = 422,
    ["Y"] = 259,
}

-- 蓝图莫古力最大坐标
local MoogleLimitPos = {
    ["X"] = 874,
    ["Y"] = 621,
}

-- 面板坐标系原点坐标
local BallOriginVec = {
    ["X"] = 420,
    ["Y"] = 285,
}

local MoogleBallShowState = {
    ["Normal"] = 1,
    ["Strong"] = 2,
    ["Weak"] = 3,
}

local MoogleBallCaughtState = {
    ["None"] = 1,
    ["Caught"] = 2,
    ["NotCaught"] = 3,
}

local CountsLimit = 3 -- 次数提醒下限

local CutPanelBGEffectLimit = 3 -- 砍伐界面背景特效区分的次数限制 

local CutResultStage = {
    ["Weak"] = 2,
    ["Strong"] = 4,
}

local CutResultScoreChangeTime = 1 -- 结算界面金碟币变化动画时间

local FailShowConstantTime = 3 -- 失败展示界面停留时间

local NormalAnimDelayChangeNumTime = 1 -- 普通奖励获取掉落tips显示延迟时间

local CriticalAnimDelayChangeNumTime = 1.5 -- 暴击奖励获取掉落tips显示延迟时间

local SettleEmotionType2PlayTime = {
    ["Happy"] = 3,
    ["Great"] = 5,
}

local SettleEmotionID = {
    ["Happy"] = 18,
    ["Great"] = 29,
    ["Overjoyed"] = 48,
    ["Regret"] = 14 -- 49
}

local InteractResult = {
    Perfect = 1,        -- 完美
    Excellent = 2,      -- 优秀
    Fail = 3,           -- 失误
    Error = 4,
}

local DelayTime = {
    ReadyToBegin = 1,
    PerpareToBegin = 2,
    BlowAutoHide = 2,
    BlowbClickHide = 1,
    PunchTime = 0.75,
    ResultUIHideTime = 3,
}

local CuffDefine = {
    CenterBlowID = 10, -- 中间的交互物ID是10
    ResultUIPos = UE.FVector2D(600, 200), -- 挥拳结果UI出现的位置
    BlowDefaultSize = UE.FVector2D(300, 300),
}

-- local BlowType = {
--     ["Low"] = 1,
--     ["Middle"] = 2,
--     ["High"] = 3,
--     ["Other"] = 4
-- }

local ResultCfg = {
    Success = { Text = LSTR(250023), TextColor = "fff1ac" }, -- 挑战成功
    Failed = { Text = LSTR(250024), TextColor = "dfdfdf" }, -- 挑战失败
    TimeOut = { Text = LSTR(250025), TextColor = "dfesf2" }, -- 时间结束
}

local ColorType = {Blue = 1, Purple = 2, Red = 3}

local MiniGameClientConfig = {
    [MiniGameType.OutOnALimb] = {
        Name = LSTR(370001), EobjID = 101, TimeLimit = 60, ExtraReset = ExtraChanceResetPolicy.OnlyCount, DifficultySpeed = 0.7,
        Cost = 1,
        DifficultyTime = 15,
        DifficultyPercentage = {
            [MiniGameDifficulty.Sabotender] = 0.7,
            [MiniGameDifficulty.Morbol] = 0.9,
            [MiniGameDifficulty.Titan] = 1.0,
        },
        DifficultyIconPath = {
            [MiniGameDifficulty.Sabotender] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_Simple.UI_OutOnALimb_Img_Simple'",
            [MiniGameDifficulty.Morbol] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_Medium.UI_OutOnALimb_Img_Medium'",
            [MiniGameDifficulty.Titan] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_Difficulty.UI_OutOnALimb_Img_Difficulty'",
        },
        ProgressLevel = {
            [MiniGameProgressType.Perfect] = {
                Value = 1, Text = LSTR(370002), SubText = LSTR(370003), MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_StateYellow_png.UI_OutOnALimb_Img_StateYellow_png'",
                DynAssetIndex = 1,
            },
            [MiniGameProgressType.Nice] = {
                Value = 1 / 3, Text = LSTR(370004), SubText = LSTR(370005), MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_StateYellow_png.UI_OutOnALimb_Img_StateYellow_png'",
                DynAssetIndex = 3,
            },
            [MiniGameProgressType.Good] = {
                Value = 1 / 8, Text = LSTR(370006), SubText = LSTR(370007), MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_State_png.UI_OutOnALimb_Img_State_png'",
                DynAssetIndex = 4,
            },
            [MiniGameProgressType.Bad] = {
                Value = 0, Text = LSTR(370008), SubText = LSTR(370009), DynAssetIndex = 2,
            },
        },
        ActBtnRecoverCondNumUpdate = 2,
        EnterMoveTime = 1,
        OKWinViewID = UIViewID.MooglePawOkWin,
        PointSourceDefine = {
            ["GreyPointerPath"] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_PointerGrey.UI_OutOnALimb_Img_PointerGrey'",
            
            ["YellowPointerPath"] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_PointerYellow.UI_OutOnALimb_Img_PointerYellow'",
            
            ["RedPointerPath"] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_PointerRed.UI_OutOnALimb_Img_PointerRed'",
        },
        OKWinContent = LSTR(370010),
        StartDelayTime = 0.75,
        DifficultyShowTime = 1.5,
        AnimPauseTime = 0.5,
        MajorStandPosOffset = 150,
        --MajorStandHeight = 80,
        DynAssetIndexDefault = 0,
        ZOffset = 22.5, -- 100,人物所站台阶厚度
        CameraParamID = 111,
        ActionPath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_act.cbnm_gs_felling_act'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_act.cbnm_gs_felling_act'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_act.cbnm_gs_felling_act'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_act.cbnm_gs_felling_act'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_felling_act.cbnm_gs_felling_act'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_felling_act.cbnm_gs_felling_act'", -- 傲龙族 ok
        },
        IdlePath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_lp.cbnm_gs_felling_lp'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_lp.cbnm_gs_felling_lp'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_lp.cbnm_gs_felling_lp'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_felling_lp.cbnm_gs_felling_lp'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_felling_lp.cbnm_gs_felling_lp'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_felling_lp.cbnm_gs_felling_lp'", -- 傲龙族 ok
        },
        IconGamePath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Icon_Game_png.UI_OutOnALimb_Icon_Game_png'",
        HelpInfoIDDifficult = 11037,
        HelpInfoIDRun = 11038,
        ReconnectStableDelayTime = 0.8,
    },
    [MiniGameType.TheFinerMiner] = {
        Name = LSTR(380001), EobjID = 102, TimeLimit = 60, ExtraReset = ExtraChanceResetPolicy.TimeAndCount, DifficultySpeed = 0.7,
        Cost = 1,
        DifficultyTime = 15,
        DifficultyPercentage = {
            [MiniGameDifficulty.Sabotender] = 0.7,
            [MiniGameDifficulty.Morbol] = 0.9,
            [MiniGameDifficulty.Titan] = 1.0,
        },
        DifficultyIconPath = {
            [MiniGameDifficulty.Sabotender] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_Simple.UI_OutOnALimb_Img_Simple'",
            [MiniGameDifficulty.Morbol] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_Medium.UI_OutOnALimb_Img_Medium'",
            [MiniGameDifficulty.Titan] = "Texture2D'/Game/UI/Texture/OutOnALimb/UI_OutOnALimb_Img_Difficulty.UI_OutOnALimb_Img_Difficulty'",
        },
        ProgressLevel = {
            [MiniGameProgressType.Perfect] = {
                Value = 1, Text = LSTR(380002), SubText = LSTR(380003), DynAssetIndex = 1,--MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_StateYellow_png.UI_OutOnALimb_Img_StateYellow_png'"
            },
            [MiniGameProgressType.Nice] = {
                Value = 1 / 3, Text = LSTR(380004), SubText = LSTR(380005), DynAssetIndex = 3,--MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_StateYellow_png.UI_OutOnALimb_Img_StateYellow_png'"
            },
            [MiniGameProgressType.Good] = {
                Value = 1 / 8, Text = LSTR(380006), SubText = LSTR(380007), DynAssetIndex = 4,--MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_State_png.UI_OutOnALimb_Img_State_png'"
            },
            [MiniGameProgressType.Bad] = {
                Value = 0, Text = LSTR(380008), SubText = LSTR(380009), DynAssetIndex = 2,
            },
        },
        OKWinViewID = UIViewID.MooglePawOkWin,
        ActBtnRecoverCondNumDifficult = 1,
        ActBtnRecoverCondNumUpdate = 2,
        EnterMoveTime = 1,
        OKWinContent = LSTR(380010),
        StartDelayTime = 0.75,
        DifficultyShowTime = 1.5,
        AnimPauseTime = 0.5,
        MajorStandPosOffset = 350,
        DynAssetIndexDefault = 0,
        --MajorStandHeight = 80,
        CameraParamID = 112,
        ZOffset = 22.5, --80, 人物所站台阶厚度
        ActionPath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_act.cbnm_gs_mining_act'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_act.cbnm_gs_mining_act'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_act.cbnm_gs_mining_act'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_act.cbnm_gs_mining_act'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_mining_act.cbnm_gs_mining_act'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_mining_act.cbnm_gs_mining_act'", -- 傲龙族 ok
        },
        IdlePath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_lp.cbnm_gs_mining_lp'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_lp.cbnm_gs_mining_lp'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_lp.cbnm_gs_mining_lp'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_mining_lp.cbnm_gs_mining_lp'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_mining_lp.cbnm_gs_mining_lp'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_mining_lp.cbnm_gs_mining_lp'", -- 傲龙族 ok
        },
        IconGamePath = "PaperSprite'/Game/UI/Atlas/TheFinerMiner/Frames/UI_TheFinerMiner_Icon_Game_png.UI_TheFinerMiner_Icon_Game_png'",
        HelpInfoIDDifficult = 11039,
        HelpInfoIDRun = 11040,
        ReconnectStableDelayTime = 0.8,
    },
    [MiniGameType.MooglesPaw] = {
        Name = LSTR(360001), EobjID = 103, HideTipTime = 2, bNeedStageTipsAutoHide = true,
        OKWinContent = LSTR(360002),
        OKWinViewID = UIViewID.MooglePawOkWin,
        Cost = 1, TimeLimit = 60, ExtraReset = ExtraChanceResetPolicy.OnlyTime,
        ProgressLevel = {
            [MiniGameProgressType.Perfect] = {
                Value = 1, Text = LSTR(360003), DynAssetIndex = 1--MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_StateYellow_png.UI_OutOnALimb_Img_StateYellow_png'"
            },
            [MiniGameProgressType.Nice] = {
                Value = 1 / 3, Text = LSTR(360004), --MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_StateYellow_png.UI_OutOnALimb_Img_StateYellow_png'"
            },
            [MiniGameProgressType.Good] = {
                Value = 1 / 8, Text = LSTR(360005), --MarkPath = "PaperSprite'/Game/UI/Atlas/OutOnALimb/Frames/UI_OutOnALimb_Img_State_png.UI_OutOnALimb_Img_State_png'"
            },
            [MiniGameProgressType.Bad] = {
                Value = 0, Text = LSTR(360006), DynAssetIndex = 3
            },
        },
        ActionPath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0801/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 傲龙族 ok
        },
        IdlePath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_ufo_lp.cbnm_gs_ufo_lp'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_ufo_lp.cbnm_gs_ufo_lp'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_ufo_lp.cbnm_gs_ufo_lp'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_ufo_lp.cbnm_gs_ufo_lp'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_ufo_lp.cbnm_gs_ufo_lp'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_ufo_lp.cbnm_gs_ufo_lp'", -- 傲龙族 ok
        },
        MajorStandPosOffset = 320,
        ZOffset = 11, -- -400,人物所站台阶厚度
        CameraParamID = 114,
        IconGamePath = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Mooglepaw/Frames/UI_MooglePaw_Icon_Game_png.UI_MooglePaw_Icon_Game_png'",
        HelpInfoID = 11043,
        ReconnectStableDelayTime = 5, -- 重连后场景恢复稳定延迟时间
    },
    [MiniGameType.MonsterToss] = {
        Name = LSTR(270001), EobjID = 103, TimeLimit = 60, -- 怪物投篮
        OKWinContent = LSTR(270002), -- 把握时机投篮得分，要挑战一下吗？
        OKWinViewID = UIViewID.MooglePawOkWin,

        Cost = 1,
        MajorStandPosOffset = 290,
        ZOffset = 30, -- 500,人物所站台阶厚度
        -- OKWinViewID = UIViewID.MooglePawOkWin,
        StageTimeList = {
            -- EnterStage1Time = 60,
            EnterStage2Time = 2,
            EnterStage3Time = 3,
            EnterStage4Time = 4,
            EnterStage5Time = 5,
            -- EndTime = 0,
        },
        Anim = {
            AnimNextBall = "AnimNextBall", 
            AnimObtainNumberIn = "AnimObtainNumberIn",
            AnimRefreshHighestScore = "AnimRefreshHighestScore",
            AnimScoreMultiplierIn2 = "AnimScoreMultiplierIn2",
            AnimScoreMultiplierIn3 = "AnimScoreMultiplierIn3",
            AnimScoreMultiplierIn5 = "AnimScoreMultiplierIn5",
            AnimConsecutiveHits1 = "AnimConsecutiveHits1",
            AnimConsecutiveHits2 = "AnimConsecutiveHits2",
            AnimConsecutiveHits3 = "AnimConsecutiveHits3",
            AnimConsecutiveHitsStop = "AnimConsecutiveHitsStop",
            AnimResult = "AnimResult",
            AnimBombReady = "AnimBombReady",
            AnimResume = "AnimResume",
            AnimIn = "AnimIn",
            AnimSuccess = "AnimSuccess",
            AnimTimesup = "AnimTimesup",
            AnimFail = "AnimFail",
            AnimProgressBar = "AnimProgressBar",
            Critical = "Critical"

        },
        BallImgPath = {
            "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/MonsterToss/Frames/GoldSaucer_MonsterToss_Img_Ball_Blue_png.GoldSaucer_MonsterToss_Img_Ball_Blue_png'",
            "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/MonsterToss/Frames/GoldSaucer_MonsterToss_Img_Ball_Purple_png.GoldSaucer_MonsterToss_Img_Ball_Purple_png'",
            "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/MonsterToss/Frames/GoldSaucer_MonsterToss_Img_Ball_Orange_png.GoldSaucer_MonsterToss_Img_Ball_Orange_png'",
            "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/MonsterToss/Frames/GoldSaucer_MonsterToss_Img_Gear_Bg5_png.GoldSaucer_MonsterToss_Img_Gear_Bg5_png'",
        },
        ColorType = ColorType,
        ZOrderData = {
            {{ColorType = ColorType.Red,  ZOrder = 1}, {ColorType = ColorType.Blue,  ZOrder = 2}, {ColorType = ColorType.Purple,  ZOrder = 3}},
            {{ColorType = ColorType.Red,  ZOrder = 1}, {ColorType = ColorType.Blue,  ZOrder = 3}, {ColorType = ColorType.Purple,  ZOrder = 2}},
            {{ColorType = ColorType.Red,  ZOrder = 2}, {ColorType = ColorType.Blue,  ZOrder = 1}, {ColorType = ColorType.Purple,  ZOrder = 3}},
            {{ColorType = ColorType.Red,  ZOrder = 2}, {ColorType = ColorType.Blue,  ZOrder = 3}, {ColorType = ColorType.Purple,  ZOrder = 1}},
            {{ColorType = ColorType.Red,  ZOrder = 3}, {ColorType = ColorType.Blue,  ZOrder = 2}, {ColorType = ColorType.Purple,  ZOrder = 1}},
            {{ColorType = ColorType.Red,  ZOrder = 3}, {ColorType = ColorType.Blue,  ZOrder = 1}, {ColorType = ColorType.Purple,  ZOrder = 2}},
        },
        ActionPath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0801/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0801/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_basket_act.cbnm_gs_basket_act'", -- 傲龙族 ok
        },
        IdlePath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_lp.cbnm_gs_basket_lp'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_lp.cbnm_gs_basket_lp'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_basket_lp.cbnm_gs_basket_lp'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0801/a0001/normal/timeline/base/b0001/cbnm_gs_basket_lp.cbnm_gs_basket_lp'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_basket_lp.cbnm_gs_basket_lp'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_basket_lp.cbnm_gs_basket_lp'", -- 傲龙族 ok
        },
        ZOrder = {Max = 3, Middle = 2, Min = 1},
        StageCfg = {First = 1, Second = 2, Third = 3, Fourth = 4, Fifth = 5},
        CameraParamID = 113,
        IconGamePath = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/MonsterToss/Frames/GoldSaucer_MonsterToss_Icon_Game_png.GoldSaucer_MonsterToss_Icon_Game_png'",
        VfxPath = {
            Explode = "VfxBlueprint'/Game/Assets/Effect/Particles/JDYLC/GWTL/BP_GWTL_1_Fire.BP_GWTL_1_Fire_C'"
        },
    },
    [MiniGameType.Cuff] = {
        Name = LSTR(250028), EobjID = 103, TimeLimit = 120, -- 250028 = 重击伽美什
        OKWinContent = LSTR(250029), -- 聚集力量, 挥出重拳击打吉尔伽美什！要挑战一下吗？
        OKWinViewID = UIViewID.MooglePawOkWin,

        Cost = 1,
        MajorStandPosOffset = 280,
        ZOffset = 9.7, -- -400人物所站台阶厚度
        OKWinViewID = UIViewID.MooglePawOkWin,
        CameraParamID = 116,
        CheckResultTime = {
            Low = { Great = 1.27, Profect = 1.53, Miss = 1.77 },
            Middle = { Great = 1.23, Profect = 1.53, Miss = 1.77 },
            High = { Great = 1.33, Profect = 1.63, Miss = 1.87 },
            Red = { Great = 1.3, Profect = 1.57, Miss = 1.80 },
            StarLight = { Great = 1.23, Profect = 1.53, Miss = 1.77 },
            Error = { Great = 1.23, Profect = 1.53, Miss = 1.77 },
        },
        EGameState = {
            InGame = 1,
            End = 2
        },
        Anim = {
            AnimSettlementIn = "AnimSettlementIn", 
            AnimBlowDown = "AnimBlowDown",
            AnimBlowHigh = "AnimBlowHigh",
            AnimIn = "AnimIn",
            AnimNormalIn = "AnimNormalIn",
            AnimTextBreathe = "AnimTextBreathe",
            AnimSuccess = "AnimSuccess",
            AnimTimesup = "AnimTimesup",
            AnimFail = "AnimFail",
            Critical = "Critical"
        },
        IdlePath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_lp.cbnm_gs_punch_lp'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_lp.cbnm_gs_punch_lp'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_lp.cbnm_gs_punch_lp'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_lp.cbnm_gs_punch_lp'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_lp.cbnm_gs_punch_lp'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_lp.cbnm_gs_punch_lp'", -- 傲龙族 ok
        }, --AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_act.cbnm_gs_punch_act'
        ActionPath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_act.cbnm_gs_punch_act'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_act.cbnm_gs_punch_act'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_act.cbnm_gs_punch_act'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_act.cbnm_gs_punch_act'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_act.cbnm_gs_punch_act'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_punch_act.cbnm_gs_punch_act'", -- 傲龙族 ok
        },
        TimeLineID = {
            Fail = 0,
            SucMin = 3, -- 一格亮起
            Suc = 1, -- 超级胜利
            Suc2 = 5, -- 一般胜利
        },
        ResultPower = {
            NoInVail = 0,
            Good = 1,
            Nice = 2,
            Profect = 3,
        },
        IconGamePath = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/Cuff/Frames/UI_GoldSaucer_Cuff_Icon_Game_png.UI_GoldSaucer_Cuff_Icon_Game_png'",
        VfxPath = {
            Fire = "VfxBlueprint'/Game/Assets/Effect/Particles/JDYLC/ZJJMS/BP_C_1_1_Rush.BP_C_1_1_Rush_C'",
            PunchWind = "VfxBlueprint'/Game/Assets/Effect/Particles/JDYLC/ZJJMS/BP_C_1_3_Rota.BP_C_1_3_Rota_C'",
            -- HitExplode = "VfxBlueprint'/Game/Assets/Effect/Particles/JDYLC/ZJJMS/BP_C_1_2_Hit.BP_C_1_2_Hit_C'"
        }
    },
    [MiniGameType.CrystalTower] = {
        Name = LSTR(260001), EobjID = 103, TimeLimit = 60, HideTipTime = 6, bNeedStageTipsAutoHide = false, -- 260001 = 强袭水晶塔
        OKWinContent = LSTR(260002), -- 聚集力量全力挥锤！要挑战一下吗？
        OKWinViewID = UIViewID.MooglePawOkWin,
        Cost = 1,
        MajorStandPosOffset = 200,
        ZOffset = 10,--450,人物所站台阶厚度
        MaxRound = 4, -- 一共四轮
        CameraParamID = 115,
        
        -- CheckResultTime = {
        --     Low = { Great = 1.27, Profect = 1.53, Miss = 1.77 },
        --     Middle = { Great = 1.23, Profect = 1.53, Miss = 1.77 },
        --     High = { Great = 1.33, Profect = 1.63, Miss = 1.87 },
        --     Other = { Great = 1.3, Profect = 1.57, Miss = 1.80 },
        -- }
        Anim = {
            AnimSettlement = "AnimSettlement", 
            AnimTipsYellow = "AnimTipsYellow",
            AnimTipsGreen = "AnimTipsGreen",
            AddScoreAnimIn = "AddScoreAnimIn",
            AnimaNormalOut = "AnimaNormalOut",
            AnimTipsBlue = "AnimTipsBlue",
            AnimTipsFail = "AnimTipsFail",
            AnimaNumber = "AnimaNumber",
            AnimTipsIn = "AnimTipsIn",
            AnimVictory = "AnimVictory",
            AnimInTimeUp = "AnimInTimeUp",
            AnimInFail = "AnimInFail",
            Critical = "Critical",
            AnimShock = "AnimShock",
        },
        TimeLineID = {
            Fail = 3,
            Suc = 1, -- 超级胜利
            Suc2 = 5, -- 一般胜利
            SucMin = 5, --
        },
        ResultPower = {
            NoInVail = 0,
            Good = 1,
            Nice = 2,
            Profect = 3,
        },
        ProviderPos = {
            Pos1 = UE.FVector2D(-199, -375),
            Pos2 = UE.FVector2D(-42, -375),
            Pos3 = UE.FVector2D(115, -375),
            Pos4 = UE.FVector2D(270, -375),
            Pos5 = UE.FVector2D(33, -375),
        },
        InteractResult = {
            Excellent = 1,
            Profect = 2,
            Error = 3,
        },
        IdlePath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_lp1.cbnm_gs_hummer_lp1'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_lp1.cbnm_gs_hummer_lp1'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_lp1.cbnm_gs_hummer_lp1'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_lp1.cbnm_gs_hummer_lp1'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_lp1.cbnm_gs_hummer_lp1'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_lp1.cbnm_gs_hummer_lp1'", -- 傲龙族 ok
        },
        ActionPath = {
            [RaceType.RACE_TYPE_Hyur] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_act1.cbnm_gs_hummer_act1'", -- 人族 ok
            [RaceType.RACE_TYPE_Elezen] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_act1.cbnm_gs_hummer_act1'", -- 精灵族 ok
            [RaceType.RACE_TYPE_Lalafell] = "AnimComposite'/Game/Assets/Character/Human/Animation/c1101/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_act1.cbnm_gs_hummer_act1'", -- 小矮子 ok
            [RaceType.RACE_TYPE_Miqote] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_act1.cbnm_gs_hummer_act1'", -- 猫魅族 ok
            [RaceType.RACE_TYPE_Roegadyn] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_act1.cbnm_gs_hummer_act1'",-- 鲁家族 ok
            [RaceType.RACE_TYPE_AuRa] = "AnimComposite'/Game/Assets/Character/Human/Animation/c0901/a0001/normal/timeline/base/b0001/cbnm_gs_hummer_act1.cbnm_gs_hummer_act1'", -- 傲龙族 ok
        },
        HidePos = UE.FVector2D(-272, -473.5),
        IconGamePath = "PaperSprite'/Game/UI/Atlas/GoldSaucerGame/CrystalTowerStriker/Frames/UI_CrystalTowerStriker_Icon_Game_png.UI_CrystalTowerStriker_Icon_Game_png'",
        VfxPath = {
            Hammer = "VfxBlueprint'/Game/Assets/Effect/Particles/JDYLC/QXSJT/BP_QXSJT_hanm_1.BP_QXSJT_hanm_1_C'",
        }
    },
    
    

}


local function GetBallImgPathByType(BallType)
    local BallImgPath = MiniGameClientConfig[MiniGameType.MonsterToss].BallImgPath
    if BallType > #BallImgPath then
        return
    end
    return BallImgPath[BallType]
end

local function GetZOrderDataByType(RandNum)
    local ZOrderData = MiniGameClientConfig[MiniGameType.MonsterToss].ZOrderData
    if RandNum > #ZOrderData then
        return
    end
    return ZOrderData[RandNum]
end

local AudioType = {
    DifficultLoop = 1,
    DifficultStop = 2,
    PointerStop = 3,
    DifficultChooseTips = 4,
    CutPanelIn = 5,
    PointerLoop = 6,
    CircleLoop = 7,
    DifficultChoosen = 8,
    PointerLoopStop = 9,
    CircleLoopStop = 10,
    MoogleMachineShow = 11,
    MoogleItemFootStep = 12,
    MoogleRoundTitle = 13,
    MoogleFailTips = 14,
    MoogleFailResult = 15,
    MoogleMachineStartTitle = 16,
    MoogleMachineReadyTitle = 17,
    MoogleFootStep = 18,
    MoogleSuccessResult = 19,
}

local AudioPath = {
    [AudioType.DifficultLoop] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/OutonaLimb/Play_Mini_OutonaLimb_difficulty_loop.Play_Mini_OutonaLimb_difficulty_loop'",
    [AudioType.DifficultStop] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/OutonaLimb/Stop_Mini_OutonaLimb_difficulty_loop.Stop_Mini_OutonaLimb_difficulty_loop'",
    [AudioType.PointerStop] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/OutonaLimb/Play_Mini_OutonaLimb_stop.Play_Mini_OutonaLimb_stop'",
    [AudioType.DifficultChooseTips] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/OutonaLimb/Play_Mini_OutonaLimb_alert.Play_Mini_OutonaLimb_alert'",
    [AudioType.CutPanelIn] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/OutonaLimb/Play_Mini_OutonaLimb_UI_appear.Play_Mini_OutonaLimb_UI_appear'",
    [AudioType.PointerLoop] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/OutonaLimb/Play_Mini_OutonaLimb_clock_hands_loop.Play_Mini_OutonaLimb_clock_hands_loop'",
    [AudioType.PointerLoopStop] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/OutonaLimb/Stop_Mini_OutonaLimb_clock_hands_loop.Stop_Mini_OutonaLimb_clock_hands_loop'",
    [AudioType.DifficultChoosen] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/OutonaLimb/Play_Mini_OutonaLimb_difficulty_chosen.Play_Mini_OutonaLimb_difficulty_chosen'",
    [AudioType.CircleLoop] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/FinerMiner/Play_Mini_FinerMiner_circle_new.Play_Mini_FinerMiner_circle_new'",
    [AudioType.CircleLoopStop] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/FinerMiner/Stop_Mini_FinerMiner_circle_new.Stop_Mini_FinerMiner_circle_new'",
    [AudioType.MoogleMachineShow] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Moogle/Play_Mini_Moogle_popup.Play_Mini_Moogle_popup'",
    [AudioType.MoogleItemFootStep] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Moogle/Play_Mini_Moogle_jump.Play_Mini_Moogle_jump'",
    [AudioType.MoogleRoundTitle] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Moogle/Play_Mini_Moogle_turn.Play_Mini_Moogle_turn'",
    [AudioType.MoogleFailTips] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Moogle/Play_Mini_Moogle_fail.Play_Mini_Moogle_fail'",
    [AudioType.MoogleSuccessResult] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Toss/Play_Mini_Toss_win.Play_Mini_Toss_win'",
    [AudioType.MoogleFailResult] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Moogle/Play_Mini_Moogle_fail_ending.Play_Mini_Moogle_fail_ending'",
    [AudioType.MoogleMachineStartTitle] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_start.Play_Mini_Gilgamesh_start'",
    [AudioType.MoogleMachineReadyTitle] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_prepare.Play_Mini_Gilgamesh_prepare'",
    [AudioType.MoogleFootStep] = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Moogle/Play_Mini_Moogle_jump.Play_Mini_Moogle_jump'",
}

local GoldSaucerMiniGameDefine = {
    MiniGameType = MiniGameType,
    MiniGameDifficulty = MiniGameDifficulty,
    MiniGameClientConfig = MiniGameClientConfig,
    MiniGameTickInterval = MiniGameTickInterval,
    DefaultSlot = DefaultSlot,
    MiniGameProgressType = MiniGameProgressType,
    MiniGameRoundEndState = MiniGameRoundEndState,
    ExtraChanceResetPolicy = ExtraChanceResetPolicy,
    MiniGameStageType = MiniGameStageType,
    TimeStageLimit = TimeStageLimit,
    CountsLimit = CountsLimit,
    TheFinerMinerCircleSize = TheFinerMinerCircleSize,
    TheFinerMinerCircleType = TheFinerMinerCircleType,
    AnimTimeLineSourcePath = AnimTimeLineSourcePath,
    AnimTimeLineSourceKey = AnimTimeLineSourceKey,
    CutPanelBGEffectLimit = CutPanelBGEffectLimit,
    CutResultStage = CutResultStage,
    CutResultScoreChangeTime = CutResultScoreChangeTime,
    FailShowConstantTime = FailShowConstantTime,
    MoogleActBtnActiveType = MoogleActBtnActiveType,
    MoogleMoveDir = MoogleMoveDir,
    MoogleMoveState = MoogleMoveState,
    MoogleInitPos = MoogleInitPos,
    MoogleLimitPos = MoogleLimitPos,
    BallOriginVec = BallOriginVec,
    InteractResult = InteractResult,
    DelayTime = DelayTime,
    ResultCfg = ResultCfg,
    CuffDefine = CuffDefine,
    MoogleBallShowState = MoogleBallShowState,
    MoogleBallCaughtState = MoogleBallCaughtState,
    GetBallImgPathByType = GetBallImgPathByType,
    GetZOrderDataByType = GetZOrderDataByType,
    SettleEmotionID = SettleEmotionID,
    EmotionDefaultPath = EmotionDefaultPath,
    AudioType = AudioType,
    AudioPath = AudioPath,
    NormalAnimDelayChangeNumTime = NormalAnimDelayChangeNumTime,
    CriticalAnimDelayChangeNumTime = CriticalAnimDelayChangeNumTime,
}

return GoldSaucerMiniGameDefine