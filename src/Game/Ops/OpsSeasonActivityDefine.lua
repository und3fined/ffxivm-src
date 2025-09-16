

local RedDotID = 20001
local RedDotName = "Root/SeasonActivity"

local HalloweenMiniGame = "HalloweenMiniGame"


local HalloweenActionType = {
    ClickedWonderfulBall = 1, --点击守护天劫和奇妙舞会
    ClickedHauntedManor = 2, --点击亡灵府邸闹鬼庄园
    ClickedMakeupBall = 3, --点击守护天节和化妆舞会
    ClickedSeasonShop = 4, --点击季节商店入口
    ClickPlay = 5, --点击播放按钮
}

local WonderfulBallActionType = {
    ClickedGoTo = 1, --点击前往
}

local HauntedManor1ActionType = {
    ClickedInfoBtn = 1, --点击规则
    ClickedChallenge = 2, --点击挑战
    ClickedMiniGame = 3, --点击小游戏收集
}

local HauntedManor2ActionType = {
    ClickedInfoBtn = 1, --点击规则
    ClickedChallenge = 2, --点击挑战
    ClickedMiniGame = 3, --点击小游戏收集
}

local MakeupBallActionType = {
    ClickeGoTo1 = 1, --界面状态1-点击【前往】
    ClickeGoTo2 = 2, --界面状态2-点击【前往】
}

local CeremonyActionType = {
    ClickedMysteriousVisitor = 1, --点击神秘访客入口
    ClickedSeasonShop = 2, --点击季节商店入口
    ClickedPenguinWars = 3, --点击企鹅大战入口
    ClickedCelebration = 4, --点击节日庆典入口
    ClickedFatPenguin = 5, --点击胖胖企鹅入口
    AutoPlayAnim = 6, --首次打开界面时播放视频
    ClickPlay = 7, --点击播放按钮
}

local MysteriousVisitorActionType = {
    ClickeGoTo1 = 1, --界面状态1-点击【前往】
    ClickeGoTo2 = 2, --界面状态2-点击【前往试骑】
}

local PenguinWarsActionType = {
    ClickedInfoBtn = 1, --点击规则
    ClickedGoTo1 = 2, --界面状态1-点击【前往】
    ClickedGoTo2 = 3, --界面状态2-点击【前往查看】
}

local CelebrationActionType = {
    ClickedInfoBtn = 1, --点击规则
    ClickedGoTo1 = 2, --界面状态1-点击【前往】
    ClickedGoTo2 = 3, --界面状态2-点击【前往派对】
}
local OpsSeasonActivityDefine =
{
    RedDotID = RedDotID,
    RedDotName = RedDotName,
    HalloweenMiniGame = HalloweenMiniGame,
    HalloweenActionType = HalloweenActionType,
    WonderfulBallActionType = WonderfulBallActionType,
    HauntedManor1ActionType = HauntedManor1ActionType,
    HauntedManor2ActionType = HauntedManor2ActionType,
    MakeupBallActionType = MakeupBallActionType,
    CeremonyActionType = CeremonyActionType,
    MysteriousVisitorActionType = MysteriousVisitorActionType,
    PenguinWarsActionType = PenguinWarsActionType,
    CelebrationActionType = CelebrationActionType,
}
return OpsSeasonActivityDefine