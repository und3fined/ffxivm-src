---
--- Author: anypkvcai
--- DateTime: 2021-03-11 14:17
--- Description:
---
local LSTR = _G.LSTR
---@class MagicCardLocalDef
local MagicCardLocalDef = {
    TextColor = {
        Red = "D85372FF",
        Blue = "0074D8FF",
        White = "FFFFFFFF"
    },

    RuleTextOutlineColor = {
        Weaken = "27B9FD66",
        Strenthen = "F14D4D66"
    },

    SettedEmoTypeDefine = {
        Salute = 1,
        Victory = 2,
        Draw = 3,
        Fail = 4
    },

    RuleEffectWeakenStrenthenColor = {
        WeakenText = "F14D4D66",
        WeakenImg = "F14D4DFF",
        StrenthenText = "27B9FD66",
        StrenthenImg = "27B9FDFF"
    },

    EditType = {
        [1] = LSTR(1130023),--"卡组一览
        [2] = LSTR(1130025),--"局内动作"
        [3] = LSTR(1130095)--"幻卡规则"
    },

    UKeyConfig = {
        CommonConfirm = 10002,--"确认"
        CommonCancel = 10003,--"取消"
        Seconds = 1130001,--"%s秒"
        TempCardGroup = 1130002,--"临时卡组（仅用于本局）"
        CardNumError = 1130003,--"卡牌数量出错，请检查
        CardGroupName = 1130004,--"卡组%d"
        CardGroupUpdate = 1130005,--"卡组内容已更新
        Round = 1130006,--"场次：%d
        Fail = 1130007,--"失败
        Draw = 1130008,--"平局
        CardCount = 1130009,--"幻卡数量：%d
        CurProgress = 1130010,--"当前进度：%d/%d
        Hint = 1130011,--"提示
        HideRule = 1130012,--"收起规则
        Salute = 1130013,--"敬礼
        None = 1130014,--"无"
        CanNotSave = 1130015,--"此为当前使用卡组，无法保存
        NoAvailableCardGroup = 1130016,--"没有可用卡组，无法开始对局
        ConfirmCD = 1130017,--"确认 （%02d:%02d）
        Victory = 1130018,--"胜利
        RuleDetail = 1130019,--"规则详情
        Exit = 1130020,--"退出
        ExitConfirm = 1130021,--"退出后会放弃所有未保存的修改内容，确定要退出吗？
        SaveFailed = 1130022,--"保存失败"
        CardsOverView = 1130023,--"卡组一览
        WeakEffectOpponent = 1130024,--"对手的大赛弱化已生效"
        AnimationInGame = 1130025,--"局内动作"
        WithNewGameOnMatchingTips = 1130026,--"幻卡匹配中无法开启新对局”
        WeakEffectPlayer = 1130027,--"玩家的大赛弱化已生效“
        ExitMagicCardGameTips = 1130028,--"现在退出视为失败，确认要退出吗？"
        CardUsedInChatText2 = 1130029,--"获得了”
        CardUsedInChatText1 = 1130030,--"通过回收：“
        CardNumLessFive = 1130031,--"<span color=\"#DC5750FF\">幻卡数量不足5张</>，无法使用本卡组进行对局，确定保存吗？"
        CardStarOverLimit = 1130032,--"<span color=\"#DC5750FF\">星级超过限制</>，无法使用本卡组进行对局，确定保存吗？"
    },

    ShowNextMoveTextDisplayTime = 1.5, -- 显示下一步是谁的等待时间
    ShowFinishTextDisplayTime = 1.5, -- 显示结束文字的等待时间
    CameraTurnTime = 0.5,--  摄像机转动时间
    TotalTimeForOneMove = 90, -- 读取表格数据，90是默认的
    ExchangeRuleDisplayAnimTime = 0.5, -- 交换卡牌的等待动画时间
    FlipToExposeCardAnimTime = 0.7,
    LerpTimeForMoveCard = 0.15,
    GameTimeForAnimChange = 90,
    NPCPutCardDelayTime = 1, -- 纯NPC的出牌延迟时间
    TimeWaitForShowWhosFirst = 1.7, -- 开局显示先后手的等待时间

    DelayTimeForEmptyMoveEffect = 0.6,
    DelayTimeForOneRuleEffect = 1,
    DelayTimeForFlipCard = 0.75,
    DelayTimeForChangePoint = 0.4,
    DelayTimeForServerData = 2,
    UIPlayCardTime = 0.5,

    BGMVolumeWhenPlaying = 35,
    CardBGMID = 253,
    -- 对战模式
    EPlayMode = {
        None = 0, -- 无对战
        PVE = 1,  -- 与NPC对战
        PVP = 2,  -- 与玩家对战
        PVPRobot = 3, -- 与模拟玩家对战
    },

    -- 框的状态
    BGFrameState = {
        NormalState = 0, -- 普通状态
        BlueState = 1, -- 蓝色状态
        YellowState = 2
    },

    -- 卡牌可能所在的位置，决定了CardItemView的各种属性
    CardItemType = {
        NotSet = 0,
        OnBoard = 1, -- 已经打出摆在牌桌上
        PlayerCard = 2, -- 自己的牌
        OpponentCard = 3, -- 对手的牌
        InfoShow = 4, -- 编辑了的用于显示的
        DragVisual = 5, -- 出牌过程中移动状态
        ShowOnDeskAtBegining = 6, -- 牌局开始前猜先时
        RewardCard = 7, -- 奖励的卡牌
        OwnedCard = 8, -- 已获得的卡牌，在卡池中
        DragVisualEdit = 9 -- 编辑过程中移动状态
    },

    FilterBtnType = {
        Star = 0, -- 根据星级过滤
        Race = 1 -- 根据种族过滤
    },

    CardItemMouseButton = {
        DelayTimeForEnlarge = 1.5,
        DistanceToTriggerDrag = 5.0
    },

    MaxCharNumForGroupName = 7,

    ClickSoundEffectEnum = {
        Put = 1,
        Select = 2,
        Cancel = 3
    },

    CardBoardSlotStatus = {
        None = 0, -- 没有被占领
        OccupyByOpponent = 1, -- 被对手占领
        OccupyByPlayer = 2, -- 被自己占领
    },

    EmotionClassifyType = {
        EmotionSolute = 1, -- 敬礼动作
        EmotionWin = 2 , -- 胜利动作
        EmotionDraw = 3, -- 平局动作
        EmotionLose = 4 -- 失败动作
    },

    ScaleForDragVisualEdit = 1.2,
    MaxScoreInGame = 10, -- 游戏中最多的分数
    CardNumToShowPerPage = 21,
    PageNumToShowPerSubPage = 6,
    CardNumToShowInEditPanel = 20, -- 局外的编辑界面的卡牌数量
    CardCountInGroup = 5, -- 一个编组中卡牌的数量
    CardGroupCount = 5, -- 卡组的数量
    ScaleForFantasyCardEditDrag = 0.7, -- 卡牌编辑界面中，拖动的卡牌显示的缩放
    ScaleForCardInGame = 0.7,
    DefualtSalutEmoID = 5, -- 默认的敬礼EMOID
    DefaultPlayerScore = 5, -- 对局时刚开始的分数
    CombatTipsID = 109015, -- 战斗状态中，无法开启对局
}

return MagicCardLocalDef
