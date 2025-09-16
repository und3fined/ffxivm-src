---
--- Author: Carl
--- DateTime: 2023-10-09 11:36
--- Description:
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR
local ProtoCommon = require("Protocol/ProtoCommon")
local RaceType = ProtoCommon.race_type
local TribeType = ProtoCommon.tribe_type

---大赛报名相关
local MatchBtnColor = 
{
    DefaultTextColor = "#FFFFFFFF",
    DefaultBtnColor = "#FFFFFFFF",
    TextColorGray = "#777777F3",
    BtnColorGray = "#B8B8B867",
}

local EMatchState ={
    Default = 1,
    Matching = 2,
    EnterCD = 3,
    Finished = 4,
    Confirm = 5,
}

local StageName =
{
    [1] = LSTR(1150052),
    [2] = LSTR(1150054),
    [3] = LSTR(1150053),
    [4] = LSTR(1150056),
}

local EffectStatusText = {
    [ProtoCS.EFFECT_STATUS.EFFECT_STATUS_IN_PROGRESS] = LSTR(1150051),
    [ProtoCS.EFFECT_STATUS.EFFECT_STATUS_FAIL] = LSTR(1150013),
    [ProtoCS.EFFECT_STATUS.EFFECT_STATUS_SUCCESS] = LSTR(1150012),
}

--本地测试用，需删除
local GlobalCfgID = {
    StageNameID = 1045,

}

-- 机器人保底NPC头像ID
local NPCHeadIconPath = {
    [RaceType.RACE_TYPE_Hyur] = {[TribeType.TRIBE_TYPE_MIDDLE] = 1}, -- 人族中原之民男 
    [RaceType.RACE_TYPE_Elezen] = {[TribeType.TRIBE_TYPE_FOREST] = 5}, -- 精灵族森林之民男
}

local ImgPath = {
    Score = "Texture2D'/Game/Assets/Icon/ItemIcon/065000/UI_Icon_065026.UI_Icon_065026",
    MagicCardReadinessBGTourney = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Readiness_BigBGGreen.UI_Cards_Img_Readiness_BigBGGreen",
    MagicCardReadinessBGNormal = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Readiness_BigBG.UI_Cards_Img_Readiness_BigBG'",
    MagicCardReadinessRuleBGTourney = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Readiness_BookGreen.UI_Cards_Img_Readiness_BookGreen'",
    MagicCardReadinessRuleBGNormal = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Readiness_Book.UI_Cards_Img_Readiness_Book'",
    MagicCardBG = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Main_BGGreen.UI_Cards_Img_Main_BGGreen'"
}

local SoundPath = {
    SignOpenView = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Card/Play_FM_UI_BAOMING.Play_FM_UI_BAOMING'",
    EffectsOppenView = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Card/Play_FM_UI_FANPAI.Play_FM_UI_FANPAI'",
    EffectRefresh = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Card/Play_FM_UI_SHUAXING.Play_FM_UI_SHUAXING'",
    EffectSelected = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Card/Play_FM_UI_XUANPAI.Play_FM_UI_XUANPAI'",
    Common = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Card/Play_FM_UI_JIESUAN.Play_FM_UI_JIESUAN'"
}

local RankIndexAsset = 
{
    [1] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Chocobo_Icon_Player_Self_01_png.UI_Chocobo_Icon_Player_Self_01_png'",
    [2] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Chocobo_Icon_Player_Self_02_png.UI_Chocobo_Icon_Player_Self_02_png'",
    [3] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Chocobo_Icon_Player_Self_03_png.UI_Chocobo_Icon_Player_Self_03_png'",
    [4] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Chocobo_Icon_Player_Self_04_png.UI_Chocobo_Icon_Player_Self_04_png'",
    [5] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Chocobo_Icon_Player_Self_05_png.UI_Chocobo_Icon_Player_Self_05_png'",
    [6] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Chocobo_Icon_Player_Self_06_png.UI_Chocobo_Icon_Player_Self_06_png'",
    [7] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Chocobo_Icon_Player_Self_07_png.UI_Chocobo_Icon_Player_Self_07_png'",
    [8] = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Chocobo_Icon_Player_Self_08_png.UI_Chocobo_Icon_Player_Self_08_png'",
}

local CupIconPath = {
    [1] = "PaperSprite'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Tourney_WinRank01_png.UI_Cards_Icon_Tourney_WinRank01_png'",
    [2] = "PaperSprite'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Tourney_WinRank02_png.UI_Cards_Icon_Tourney_WinRank02_png'",
    [3] = "PaperSprite'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Tourney_WinRank03_png.UI_Cards_Icon_Tourney_WinRank03_png'",
    [4] = "PaperSprite'/Game/UI/Atlas/Cards/Frames/UI_Cards_Icon_Tourney_WinRank04_png.UI_Cards_Icon_Tourney_WinRank04_png'"
}

local RiskLevelBGPath = 
{
    [0] = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Tourney_StageWin_EffectBG01.UI_Cards_Img_Tourney_StageWin_EffectBG01'",
    [1] = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Tourney_StageWin_EffectBG02.UI_Cards_Img_Tourney_StageWin_EffectBG02'",
    [2] = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Tourney_StageWin_EffectBG03.UI_Cards_Img_Tourney_StageWin_EffectBG03'",
    [3] = "Texture2D'/Game/UI/Texture/Cards/UI_Cards_Img_Tourney_StageWin_EffectBG04.UI_Cards_Img_Tourney_StageWin_EffectBG04'",
}

local MatchText = LSTR(1150027)--"开始匹配"
local MatchingText = LSTR(1150018)--"取消 %s"
local CanNotMatchText = LSTR(1150028)--"开始匹配(%ds)"
local FinishedText = LSTR(1150022)--"已完成所有对局"
local CancelMatchTipText = LSTR(1150040)--"确认取消匹配吗？\n %d秒内不可再次匹配"
local AutoCancelMatchTipText = LSTR(1150004)--"%d秒后自动取消匹配"
local StageDescText = LSTR(1150011)--"(胜利得%d积分，失败得%d积分）"
local OpponentCancelMatchTipText = LSTR(1150021)--"对手离开匹配"
local NotOnTheListText = LSTR(1150036)--"未上榜"
local CurRankText = LSTR(1150029)--"当前排名：%s"
local EffectEndText = LSTR(1150023)--"已结束"
local EffectOngoingText = LSTR(1150051)--"进行中"
local SignUpSuccessTipText = LSTR(1150007)--"%s参赛成功"
local Title = LSTR(1150025)--"幻卡大赛"
local TournneyDesc = LSTR(1150049)----"赛事共<span color=\"#bd8213\">4</>阶段，共<span color=\"#bd8213\">20</>场"
local RoomTitle = LSTR(1150026)--"幻卡对局室"
local TourneyFinishedText = LSTR(1150019)--"大赛对局完成"
local GetRewardTimeText = LSTR(1150058)--"领奖时间：%s后"
local TourneyFinishRewardTimeText = LSTR(1150008)--"%s开奖"
local SignUpTipText = LSTR(1150038)--"火热进行中，请前往\n 大赛接待员处报名"
local EnterRoomTipText = LSTR(1150047)--"请前往幻卡对局室..."
local EnterRoomConfirmBoxTitle = LSTR(1150015)--"前往对局室"
local EnterRoomConfirmBoxText = LSTR(1150039)--"确认前往幻卡对局室参加大赛吗？"
local ReMatchTipText = LSTR(1150003)--"%d秒后可再次匹配"
local ExpectTimeText = LSTR(1150057)--"预计 %s"
local StageInfoScoreText = LSTR(1150043)--"积分：%d"
local TourneyDetailScoreText = LSTR(1150030)--"当前积分：%d"
local SignUpEndTimeText = LSTR(1150032)--"报名截止%s"
local WinCountText = LSTR(1150044)--"胜场：%d"
local DefeatCountText = LSTR(1150048)--"败场：%d"
local DrawCountText = LSTR(1150024)--"平局：%d"
local RemainTimeForAwardText = LSTR(1150016)--"剩余领取时间：%s"
local RemainTimeForEndText = LSTR(1150020)--"大赛结束剩余时间：%s"
local RemainTimeForNextText = LSTR(1150050)--"距离下一场大赛开启：%s"
local LastStageName = LSTR(1150034)--"最终阶段"
local StageSettlementText = LSTR(1150009)--"%s结束"
local StageEffectBufffText = LSTR(1150055)--"阶段加成：%s %s"
local StageProgressText = "%s(%s/%s)" --阶段名（进度/最大进度）
local EffectProgressText = "%s(%s/%s)" --效果名（进度/最大进度）
local PleaseReadyText = LSTR(1150046)--“请准备”
local CurStageDesc = LSTR(1150031)--“当前阶段：%s %s”
local RoundText = LSTR(1150002)--“%d/%d局”
local StageAndRoundText = LSTR(1150010)--“%s：%d/%d局”
local RuleText = LSTR(1150045)--“规则：%s”
local EnterMatchRoomText = LSTR(1150017)--“参加”
local AwardText = LSTR(1150035)--“最高奖金10万金碟币和稀有幻卡！”
local NumberOneAwardText = LSTR(1150014)--“一等奖幻卡奖励”
local ScoreAddText = LSTR(1150042)--“积分+%d分”
local ScoreText = LSTR(1150041)--“积分%d分”
--------------报名界面------------------------
local TourneyData = LSTR(1150037)--“比赛时间：%s~%s”
local AwardCoinAndCardText = "%s+%sx%s" -- 金碟币数 + 卡包名x数量

--------------玩法匹配入口界面-----------------
local PWorldTourneyInfoWithDiableText = LSTR(1150005)--“%s-%s 敬请期待”
local PWorldTourneyInfoWithActiveText = LSTR(1150006)--"%s-%s 进行中！"
local NoExistTimeText = LSTR(1150033)--“无”
local EnterLimitLevelText = LSTR(1150001)--“%d 级”
----------------------------------------
local MaxReMatchDelay = 30 --取消后再次匹配需要等待时间
local MaxScore = 2000 --幻卡大赛可获得的最高积分
local Duration = 7 * 24 * 60 * 60 --大赛持续时间(秒)
local NPCID = 1010479 -- 大赛接待员ID
local JDMapID = 12060 --金蝶游乐场ID
local FantasyCardAreaID = 1100001
local TourneyCanSignUpDiaglogID = 18201 -- 大赛可报名
local SignUpSuccessDialogID = 18202  -- 报名成功对话ID
local TourneyNotActiveDialogID = 18203 -- 大赛未开启且没有奖励
local TourneyAwardCanGetDialogID = 18204 --有奖励未领取对话内容
local RankDynAssetID = 5421409 -- 动态物件ID：排行榜

local TipsType = {
    SignUpSuccess = 1,
    TourneyFinished = 2,
}

local TipsContent = {
    [TipsType.SignUpSuccess] = SignUpSuccessTipText,
    [TipsType.TourneyFinished] = TourneyFinishedText,
}

local TipsID = {
    SignUpSuccessTip = 40288,
    GetAwardTip = 40589,
    TourneyFinished = 40290,
}

local MagicCardTourneyDefine = {
    WinCountText = WinCountText,
    DefeatCountText = DefeatCountText,
    DrawCountText = DrawCountText,
    MatchText = MatchText,
    MatchingText = MatchingText,
    NotOnTheListText = NotOnTheListText,
    MaxScore = MaxScore,
    MatchBtnColor = MatchBtnColor,
    EffectEndText = EffectEndText,
    EffectProgressText = EffectProgressText,
    StageProgressText = StageProgressText,
    EffectOngoingText = EffectOngoingText,
    Duration = Duration,
    NPCID = NPCID,
    SignUpSuccessTipText = SignUpSuccessTipText,
    Title = Title,
    MaxReMatchDelay = MaxReMatchDelay,
    ReMatchTipText = ReMatchTipText,
    CanNotMatchText = CanNotMatchText,
    SignUpTipText = SignUpTipText,
    EnterRoomTipText = EnterRoomTipText,
    CancelMatchTipText = CancelMatchTipText,
    AutoCancelMatchTipText = AutoCancelMatchTipText,
    EMatchState = EMatchState,
    GlobalCfgID = GlobalCfgID,
    StageName = StageName,
    TourneyFinishedText = TourneyFinishedText,
    ImgPath = ImgPath,
    RankIndexAsset = RankIndexAsset,
    FinishedText = FinishedText,
    StageDescText = StageDescText,
    EffectStatusText = EffectStatusText,
    FantasyCardAreaID = FantasyCardAreaID,
    SignUpSuccessDialogID = SignUpSuccessDialogID,
    TourneyCanSignUpDiaglogID = TourneyCanSignUpDiaglogID,
    TourneyNotActiveDialogID = TourneyNotActiveDialogID,
    TourneyAwardCanGetDialogID = TourneyAwardCanGetDialogID,
    StageInfoScoreText = StageInfoScoreText,
    TourneyDetailScoreText = TourneyDetailScoreText,
    SignUpEndTimeText = SignUpEndTimeText,
    RoomTitle = RoomTitle,
    ExpectTimeText = ExpectTimeText,
    GetRewardTimeText = GetRewardTimeText,
    TipsType = TipsType,
    TipsContent = TipsContent,
    TourneyFinishRewardTimeText = TourneyFinishRewardTimeText,
    EnterRoomConfirmBoxTitle = EnterRoomConfirmBoxTitle,
    EnterRoomConfirmBoxText = EnterRoomConfirmBoxText,
    JDMapID = JDMapID,
    TournneyDesc = TournneyDesc,
    CurRankText = CurRankText,
    RemainTimeForAwardText = RemainTimeForAwardText,
    RemainTimeForEndText = RemainTimeForEndText,
    LastStageName = LastStageName,
    StageSettlementText = StageSettlementText,
    StageEffectBufffText = StageEffectBufffText,
    RemainTimeForNextText = RemainTimeForNextText,
    AwardCoinAndCardText = AwardCoinAndCardText,
    RiskLevelBGPath = RiskLevelBGPath,
    PWorldTourneyInfoWithDiableText = PWorldTourneyInfoWithDiableText,
    PWorldTourneyInfoWithActiveText = PWorldTourneyInfoWithActiveText,
    TourneyData = TourneyData,
    OpponentCancelMatchTipText = OpponentCancelMatchTipText,
    NPCHeadIconPath = NPCHeadIconPath,
    TipsID = TipsID,
    RankDynAssetID = RankDynAssetID,
    SoundPath = SoundPath,
    PleaseReadyText = PleaseReadyText,
    NoExistTimeText = NoExistTimeText,
    EnterLimitLevelText = EnterLimitLevelText,
    CurStageDesc = CurStageDesc,
    RoundText = RoundText,
    StageAndRoundText = StageAndRoundText,
    RuleText = RuleText,
    EnterMatchRoomText = EnterMatchRoomText,
    AwardText = AwardText,
    NumberOneAwardText = NumberOneAwardText,
    ScoreAddText = ScoreAddText,
    ScoreText = ScoreText,
    CupIconPath = CupIconPath
}

return MagicCardTourneyDefine