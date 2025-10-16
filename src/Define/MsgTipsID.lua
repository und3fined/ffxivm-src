--
-- Author: anypkvcai
-- Date: 2023-02-03 14:29
-- Description: 需要通过 MsgTipsUtil.ShowTipsByID 显示的TipsID，统一在此定义， ID值要和 “X系统通知表.xlsx” 表中的ID一致。
--


---@class MsgTipsID
local MsgTipsID = {

	TeamMemberNum4 = 10002,    -- 轻锐小队
	TeamMemberNum8 = 10003,    -- 满编小队
	TeamCantOpTeam = 103008,   -- 所在副本禁止相关组队操作

	OpIsQuickly = 103104,		--操作太频繁，请稍后再试

	SkillCannotUse = 106016,   -- 玩家当前状态受限, 无法使用技能
	SkillNoTargetOrFar = 106026, 	--没有有效目标或目标距离过远
	SkillCannotSeeTarget = 106032, 	--看不见目标

	EmitionArmyMatch = 128001, -- 你的军队信息不匹配
	EmitionCannotUse = 128002, -- 当前状态无法使用
	EmitionCombatUse = 128003, -- 切换为战斗职业方可使用
	EmitionFastClick = 128004, -- 本次操作频繁过快，点击无效
	EmitionMaxLike   = 128005, -- 情感动作收藏数量已达上限
	EmitionCannotUseG = 128006, -- 该动作在地面状态时不可使用
	EmitionCannotUseC = 128007, -- 该动作在坐在椅子上时不可使用
	EmitionCannotUseR = 128008, -- 该动作在坐骑上不可使用
	EmitionCannotUseS = 128009, -- 该动作在水上不可使用
	EmitionCannotUseT = 128010, -- 当前头部装备无法使用该动作

	EquipmentWithMagicsparDropOrRecycle = 136009,		--镶嵌魔晶石装备不允许回收或丢弃

	-- Parallel world entrance and matching
	PWorldMatchRandMatchOverflow 			= 146027,
	PWorldMatchNormMatchOverflow 			= 146028,
	PWorldMatchPoolTypeFromRandToNorm 		= 146029,
	PWorldMatchPoolTypeFromNormToRand 		= 146030,
	PWorldMatchJoinOrCancelNoCaptain  		= 146033,
	PWorldVoteCancelMemChg                  = 103043,
	PWorldLeaveStuck         				= 10012, -- 脱离卡死
	PWorldGuideCancel 						= 115030,

	PWorldMatchChocoboMatchOverflow         = 146041, -- 副本匹配中，无法发起陆行鸟竞赛匹配
	PWorldMatchChocoboMustInTeam         	= 103047,  -- 未组队时无法发起陆行鸟房间对局
	PWorldMatchChocoboCannotInTeam          = 304002,  -- 组队状态下，无法开启陆行鸟竞赛匹配
	
	PWorldMatchPoolTypePVPMutex = 146085,	-- PVE/陆行鸟匹配中，无法发起PVP匹配
	PWorldPVPMatchOverflow = 146086,	-- PVP副本匹配上限
	PWorldCrystallineInTeamBan = 338044,	-- 组队中不能匹配水晶冲突练习赛段位赛

	GatherPerceptionNotEnough = 109122,	--鉴别力不足
	GatheringNotEnough = 109123,		--获得力不足
	GatherStoneNoSlaveTool = 109129,	--没有配置副手武器的提示
	GatherGrassNoSlaveTool = 109128,
	GatherDurationMax = 109130,			--可采集次数已满，无法再继续增加   高产技能
	GatherStateCannotDiscover = 109165,			--采集状态下无法使用   勘探技能
	GatherHighProduceCnt = 109166,			--高产技能已用完2次
	GatherAddItemNum = 109167,			--莫非王土 生效后不能再次使用
	GatherNotInState = 109131,			--没有进入战斗状态，无法采集
	GatherMiss = 109134,				--采集miss的提示
	LifeSkillCDing = 109133,			--采集技能cding
	CollectionBeSeized = 109136,
	CollectionMax = 109137,
	ScourSkillUnUse = 109138,
	CollectionSKillLock = 109139,
	PriceUp = 109140,    --价值提升
	Collector = 109141,    --洞察
	FreeMeti = 109142,    --沉稳
	Check = 109143,
	UnableSwitchCareers = 109144,
	NoLeftCount = 109145,
	GatherCombatState = 109147,
	GatherStoping = 109146,
	GatherRltItemInfo = 109148,
	GatherRltHQItemInfo = 109164,
	GatherCurStateInvalid = 109149,
	SimpleGathering = 109150,
	CollectionSkillRlt = 109151,
	CurPosCannotGather = 109156,	--当前位置无法进行采集		空中的时候使用
	CurMapNoGatherPoint = 109160,

	CannotFightSkillPanel = 109513,
	CannotMakeCraftTips = 109514,

	--采集点地面特效的tip
	GatherCount = 150001,
	GatherItemCount = 150002,
	GatherObtainGate = 150003,
	GatherExternDrop = 150004,



	--采集笔记
	UnacquiredMiner =149001, --还未习得职业采矿工
	UnacquiredGardener =149002,
	LowLevelMiner =149003, --采矿工等级不足
	LowLevelGardener =149004,

	--钓鱼笔记
	MaxClockTip = 151001, --添加提醒闹钟数量已上限

	-- 货币兑换
	ExchangeGoldLimitExceeded = 300002,
	ExchangeSilverLimitExceeded = 300003,

	-- 地图
	MapFogUnlock = 123001,
	MapFogAllUnlock = 123002,
	MapFollowNotSupport = 123003,

	-- 任务
	QuestFaultMssItem = 70001,
	QuestFaultMssBuff = 70002,
	QuestFaultMssMount = 70003,

	--region 金碟活动飘窗
	GoldSauser_Windows			= 40227,		-- 通用飘窗
	GoldSauser_Stage_SignUpEnd	= 40228,		-- 舞台活动报名截止
	GoldSauser_ActivityEnd 		= 40229,		-- 活动结束
	GoldSauser_Other_SignUpEnd	= 40230,		-- 其他活动报名截止
	--endregion

	-- 仙人仙彩
	JumbocactOpen1 = 40231,
	JumbocactOpen2 = 40232,
	JumbocactOpen3 = 40233,
	JumbocactOpen4 = 40234,
	JumbocactOpen5 = 40235,
	JumboBeginRaffleTip = 40264,
	JumboEndRaffleTip = 40265,
	JumboLastEndRaffleTip = 40291,

	JumbStartJoinPrizeTip = 40266,
	JumbCountBeginRaffleTip = 40262,
	JumbCountOnRaffleTip = 40263,
	JumboEnterArea = 40269,
	JumboLeaveArea = 40270,
	JumboLottoryTip = 40268,
	JumboWorldVisitTip = 109114, --跨界通用提示

	-- 机遇通用
	JumbNotInvolved = 109300,
	JumbIsRemainCount = 109301,
	JumbNearEnd = 109302,
	JumbNearbFinsihed = 109303,
	JumbNoExchangeReward = 109304,

	MagicCardNotInvolved = 109305,
	MagicCardIsRemainCount = 109306,
	MagicCardNearEnd = 109307,
	MagicCardbFinsihed = 109308,
	MagicCardNoExchangeReward = 109309,

	FashionCheckNotInvolved = 109310,
	FashionCheckIsRemainCount = 109311,
	FashionCheckNearEnd = 109312,
	FashionCheckbFinsihed = 109313,

	-- 幻卡大赛
	MatchRoomRefuseEnter = 168101,
	MatchRoomRefuseExit = 168102,
	MatchRoomRefuseEnterInPworld = 168103, -- 副本中禁止进入对局室
	-- 系统解锁
	ModuleOpenTipsID = 260554,

	--region 公会飘窗
	Army_NoArmy			= 145026,		-- 未加入公会
	--endregion

	-- 生产职业相关
	CulinarianAfflatusIndexLockMask = 305101,
	CulinarianPracticeNotValid = 305102,
	CulinarianPushNotValid = 305103,
	CrafterAttrNotEnough = 305104,
	CrafterDurabilityNotEnough = 305105,
	CrafterCannotMakeWhenDead = 305106,
	CrafterCannotMakeWhenInBattle = 305107,
	CrafterCannotMakeWhenMounting = 305108,
	CrafterCannotMakeWhenSinging = 305109,
	CrafterCastSkillFailed = 305110,
	CrafterAfflatusInspireStormMask = 305111,
	FirstCraft = 305010,
	CrafterCastCatalystFailed = 305100, --催化剂失败
	CrafterCannotReEnter = 305129,	--不能重复禁止制作状态的提示

	-- 锻铁匠
	BlacksmithHotForgePhase = 305124,
	BlacksmithHotForgeEnd   = 305125,

	--region 成就
	AchievementAddTarget				= 305112,		-- 添加目标成就
	AchievementRemoveTarget				= 305113,		-- 移除目标成就
	AchieveTargetNumLimit 				= 333001,       --
	--endregion

	-- 队伍战斗开始倒计时
	TeamCancleCountDown = 103046,
	TeamMemUpdCancleCountDown = 103069,
	-- region 副本
	PWorldMatchCancelPunish_1 = 146044,
	PWorldMatchCancelPunish_2 = 146045,
	PWorldMatchCancelPunish_3 = 146046,
	PWorldMatchCancelPunish_n = 146047,
	-- endregion

	-- region 随从
	EntourageConfirmExit     = 307006,
	-- endregion

	-- region 乐谱
	MusicNoGetAtlasTips = 156017,
	MusicListNameRepetition = 156009,
	UseMusicSuccTips = 156002,		--成功收录管弦乐琴乐谱
	MusicOrderMode = 156003,
	MusicSingleMode = 156004,
	MusicRandomMode = 156005,
	MusicSaveList = 156007,
	MusicSaveListTips = 156008,
	MusicSaveListFail = 156010,
	MusicAddMusic = 156011,
	MusicStop = 156013,
	MusicPlay = 156016,
	UseBookSuccTips = 131005,		--成功收录管弦乐琴乐谱
	-- endregion

	-- region 拍照
	PhotoChangesUndo         = 172009,

    PhotoMoveUnlock          = 172011,
    PhotoMoveLock            = 172010,

    PhotoWeatherPause        = 172012,
    PhotoWeatherResume       = 172013,

    PhotoSelfPause           = 172014,
    PhotoSelfResume          = 172015,

    PhotoAllActorPause       = 172016,
    PhotoAllActorResume      = 172017,

    PhotoEnableGiveAll       = 172018,
    PhotoDisableGiveAll      = 172019,

    PhotoStartFaceLookAt     = 172001,
    PhotoStopFaceLookAt      = 172002,

    PhotoStartEyeLookAt      = 172003,
    PhotoStopEyeLookAt       = 172004,


    PhotoShowAuxLine         = 172005,
    PhotoHideAuxLine         = 172006,

    PhotoShowView            = 172007,
    PhotoHideView            = 172008,

    PhotoTemplateIsMaxNum    = 172020,
    PhotoTemplateDelete      = 172021,
	-- endregion

	DeadStateCantControls = 103070,   -- 当前在死亡状态中，无法操作
	DeadStateCantInteraction = 103071,   -- 当前在死亡状态中，无法进行交互
	GatherStateCantControls = 109163,		--采集状态中，无法操作
	
	TouringBandListenCountAdd = 306100,
	TouringBandStoryUnLock = 306101,

	--交互
	ClimbingStateCantInteraction = 108010,
	SwimmingStateCantInteraction = 108011,
	CombatStateCantInteraction = 108012,

	-- 野外宝箱
	WildBoxBagFull = 100015,	-- 背包已满

	--region 技能
	SkillLearnAdvanceTips = 106027,	--仅特职可用
	SkillDisableCombat = 106028,	--仅战斗可用
	SkillDisableNormal = 106029,	--仅脱战可用
	SkillSystemUseDrug = 106030,
	SkillSystemUseDrugProfUnlock = 106031,
	LimitSkillOtherCasting = 106033,
	LimitSkillMajorCasting = 106045,
	SkillLearnLevelTips = 106035,	--XX等级可用
	SkillLimitMoveFallingTips = 106037,	--坠落时候禁止使用位移技能
	ProfPVPUnable = 106038,         --当前职业未开放PVP内容
	ShopUnlockTipsID = 157031,


	-- endregion

	--战斗界面
	CombatBtnSwitchDisable_Fish = 20134,	 --捕鱼状态下，无法切换
	CombatBtnSwitchDisable_Gather = 109168,	 --采集状态下，无法切换
	CombatBtnSwitchDisable_Crafter = 305006, --当前未进入生产状态

	--冒险
	WeekTaskRewardTips = 350001,
	RideMountTemporaryActivityEnd = 153016, --活动已结束，已为您自动下坐骑

	-- 对战资料
	SeriesMalmstoneLevelUp = 338013,	-- 星里路标升级
}

return MsgTipsID
