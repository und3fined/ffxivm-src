---
--- Author: Carl
--- DateTime: 2024-1-29 11:36
--- Description:
---
local ProtoCommon = require("Protocol/ProtoCommon")

local LSTR = _G.LSTR
local ThemeNameText = LSTR(1120003)--1120003("主题：%s")
local TrackTipText = LSTR(1120008)--1120008("外观已设为目标")
local WeekHighestScoreText = LSTR(1120019)--1120019("本周最高分：%s")
local WithoutScoreText = LSTR(1120020)--1120020("本周最高分：无")
local TrackCancelTipText = LSTR(1120007)--1120007("外观取消设为目标")
local RemainTimesText = LSTR(1120018)--1120018("本周挑战次数：%s/%s")
local TrackNumFullTipText = LSTR(1120016)--1120016("时尚目标已满，请先整理清单")
local EquipNotChangeTipText = LSTR(1120009)--1120009("外观未发生变化，确认继续挑战吗？")
local EquipNotCompleteTipText = LSTR(1120011)--1120011("存在未穿戴部位，确认继续挑战吗？")
local SettlementTipTextFinish = LSTR(1120013)--1120013("已达成全部目标奖励")
local SettlementTipTextRetry = LSTR(1120004)--1120004("分数不错，可以标记外观来追踪获取")
local SettlementTipTextFaile = LSTR(1120017)--1120017("未获得奖励，再尝试一下吧")
local SearchHint = LSTR(1120068) --1120068("搜索%s")
local BagHaveUKey = 1120023--("背包拥有 %d")
local NumUKey = 1120001--("%s个")
local ChallengeConfirmUKey = 1120015--("挑战确认")
local MatchThemeUKey = 1120021--("符合主题的外观%s件")
local OwnAppearanceUKey = 1120027--("衣橱拥有的外观%s件")
local RecordTextUKey = 1120028--("记录")
local CancelUkey = 10003 --("取消")
local ConfirmUKey = 10002 --("确认")
local OwnScoreUKey = 1120054 --("拥有分")
local MatchScoreUKey = 1120055 --("主题分")
local SuperMatchScoreUKey = 1120056 --("彩蛋分")
local EvaluationNPCID = 1025176 --假面罗斯
local StartDialogID = 18300
local EvaluateDialogID = 18301
local ResultDialogID = 18302
local FeedbackDialogID = 18303
local JDMapID = 12060
local MaxCommentNum = 3 --最大弹幕显示数
local TrackTipScore = 80 --超过此分数且有外观未拥有时触发追踪提示
local CharacterClass = "Class'/Game/BluePrint/Character/UIComplexCharacter_BP.UIComplexCharacter_BP_C'"
local EquipmentLightConfig = "LightPreset'/Game/UI/Render2D/LightPresets/FashionAppreciation/FashionAppreciation_Lens02_LeadingLight.FashionAppreciation_Lens02_LeadingLight'"  


local RecommendTag = {
    Recommend = 0, -- 后台推荐外观
    All = 1, -- 所有外观
}

local PartIconMap = 
{
	[1] = "MainHand";
	[2] = "OffHand";
	[3] = "Hat";
	[4] = "Clothing";
	[5] = "Hand";
	[6] = "Pants";
	[7] = "Shoe";
	[8] = "Heck";
	[9] = "Finger";
	[10] = "Finger";
	[11] = "Wrists";
	[12] = "Ears";
}

local AudioPath = {
    ScoreUP = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_Fassioncheck_Up/Play_Zingle_Fassioncheck_Up.Play_Zingle_Fassioncheck_Up'",
    Roll = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_Fassioncheck_Roll/Play_Zingle_Fassioncheck_Roll.Play_Zingle_Fassioncheck_Roll'",
}

local EvaluationAnim = {
    [1] = {TimelineID = 715, Delay = 0},
    [2] = {TimelineID = 694, Delay = 0},
    [3] = {TimelineID = 722, Delay = 0},
}

local EquipPartName =
{
	[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] = LSTR(1120002),--1120002("主手")
	[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] = LSTR(1120005),--1120005("副手")
	[ProtoCommon.equip_part.EQUIP_PART_HEAD] = LSTR(1120010),--1120010("头部")
	[ProtoCommon.equip_part.EQUIP_PART_BODY] = LSTR(1120029),--1120029("身体")
	[ProtoCommon.equip_part.EQUIP_PART_ARM] = LSTR(1120014),--1120014("手臂")
	[ProtoCommon.equip_part.EQUIP_PART_LEG] = LSTR(1120026),--1120026("腿部")
	[ProtoCommon.equip_part.EQUIP_PART_FEET] = LSTR(1120024),--1120024("脚部")
	[ProtoCommon.equip_part.EQUIP_PART_NECK] = LSTR(1120030),--1120030("颈部")
	[ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER] = LSTR(1120012),--1120012("左指")
	[ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER] = LSTR(1120006),--1120006("右指")
	[ProtoCommon.equip_part.EQUIP_PART_WRIST] = LSTR(1120025),--1120025("腕部")
	[ProtoCommon.equip_part.EQUIP_PART_EAR] = LSTR(1120022),--1120022("耳部")
}

local EFashionView = {
    Main = 0,
    Fitting = 1,
    Record = 2,
    Progress = 3,
    NPCEquip = 4,
    Settlement = 5,
}
local PlayerScoreBG = {
    [1] = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Icon_FcLevel11_png.UI_Army_Icon_FcLevel11_png'",
    [2] = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Icon_FcLevel12_png.UI_Army_Icon_FcLevel12_png'",
    [3] = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Icon_FcLevel13_png.UI_Army_Icon_FcLevel13_png'",
    [4] = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Icon_FcLevel14_png.UI_Army_Icon_FcLevel14_png'"
}

local NPCScoreBG = {
    [1] = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Icon_FcLevel1_png.UI_Army_Icon_FcLevel1_png'",
    [2] = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Icon_FcLevel20_png.UI_Army_Icon_FcLevel20_png'",
    [3] = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Icon_FcLevel21_png.UI_Army_Icon_FcLevel21_png'",
    [4] = "PaperSprite'/Game/UI/Atlas/Army/Frames/UI_Army_Icon_FcLevel22_png.UI_Army_Icon_FcLevel22_png'"
}

-- 弹幕刷新间隔（s）
local CommentInternal = {
    [1] = 3,
    [2] = 1,
    [3] = 0.5,
    [4] = 0.5
}

local CameraIndexMap = 
{
    [EFashionView.Main] = 1,
    [EFashionView.Progress] = 1,
	[EFashionView.NPCEquip] = 2,
    [EFashionView.Record] = 2,
    [EFashionView.Fitting] = 3,
    [EFashionView.Settlement] = 4,
}

local EvaluateState = {
    Start = 1,
    FashionShow = 2,
    FashionShowEnd = 3,
    Result = 4,
}

local EvaluationDialog = {
    [EvaluateState.Start] = StartDialogID,
    [EvaluateState.FashionShow] = EvaluateDialogID,
    [EvaluateState.FashionShowEnd] = ResultDialogID,
    [EvaluateState.Result] = FeedbackDialogID,
}

local TextColor = {
    RemainTimesNotEnoughColor = "#dc5868",
    DefaultTextColor = "#D5D5D599",
}

local TrackRedDotName = "Root/FashionEvaluate"

local PartSortFun = function(a, b)
    return a.Part < b.Part
end

-- 达成奖励条件
local AwardConditionContent = {
    [1] = LSTR(1120063), -- ”参与挑战“
    [2] = LSTR(1120064), -- ”达到%s分“
    [3] = LSTR(1120064), -- ”达到%s分“
    [4] = LSTR(1120064), -- ”达到%s分“
}

-- 开场白内容
local PrologueContent = {
    [1] = LSTR(1120065), -- ”近期再金蝶游乐场中涌现了许多时尚的年轻人，其中有五位格外亮眼“
    [2] = LSTR(1120066), -- ”本周的主题是“%s”，先看看时尚达人们的表现吧“
    [3] = LSTR(1120067), -- ”也许他们的穿搭能够带给你灵感“
}

-- LCut
local LCutSequenceList = {
    [1] = {21600119,21600120,21600121}, -- 0-59分
    [2] = {21600122,21600123,21600124}, -- 60-79分
    [3] = {21600125,21600126,21600127}, -- 80-99分
    [4] = {21600128} -- 100分
}

local FashionEvaluationDefine = {
    RemainTimesText = RemainTimesText,
    WeekHighestScoreText = WeekHighestScoreText,
    WithoutScoreText = WithoutScoreText,
    ThemeNameText = ThemeNameText,
    RecommendTag = RecommendTag,
    TrackTipText = TrackTipText,
    TrackCancelTipText = TrackCancelTipText,
    TrackNumFullTipText = TrackNumFullTipText,
    EquipNotChangeTipText = EquipNotChangeTipText,
    EquipNotCompleteTipText = EquipNotCompleteTipText,
    PlayerScoreBG = PlayerScoreBG,
    NPCScoreBG = NPCScoreBG,
    CommentInternal = CommentInternal,
    EvaluationNPCID = EvaluationNPCID,
    EvaluationDialog = EvaluationDialog,
    EvaluateState = EvaluateState,
    TextColor = TextColor,
    MaxCommentNum = MaxCommentNum,
    EFashionView = EFashionView,
    CameraIndexMap = CameraIndexMap,
    CharacterClass = CharacterClass,
    EquipmentLightConfig = EquipmentLightConfig,
    TrackTipScore = TrackTipScore,
    PartSortFun = PartSortFun,
    SettlementTipTextFinish = SettlementTipTextFinish,
    SettlementTipTextRetry = SettlementTipTextRetry,
    SettlementTipTextFaile = SettlementTipTextFaile,
    PartIconMap = PartIconMap,
    AudioPath = AudioPath,
    EvaluationAnim = EvaluationAnim,
    EquipPartName = EquipPartName,
    JDMapID = JDMapID,
    BagHaveUKey = BagHaveUKey,
    NumUKey = NumUKey,
    ChallengeConfirmUKey = ChallengeConfirmUKey,
    CancelUkey = CancelUkey,
    ConfirmUKey = ConfirmUKey,
    MatchThemeUKey = MatchThemeUKey,
    OwnAppearanceUKey = OwnAppearanceUKey,
    RecordTextUKey = RecordTextUKey,
    OwnScoreUKey = OwnScoreUKey,
    MatchScoreUKey = MatchScoreUKey,
    SuperMatchScoreUKey = SuperMatchScoreUKey,
    AwardConditionContent = AwardConditionContent,
    PrologueContent = PrologueContent,
    LCutSequenceList = LCutSequenceList,
    SearchHint = SearchHint,
    TrackRedDotName = TrackRedDotName,
}

return FashionEvaluationDefine