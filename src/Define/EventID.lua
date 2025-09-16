--
-- Author: anypkvcai
-- Date: 2020-08-06 09:56:38
-- Description: 建议每个系统预留100个值
--

local IdToNameMap

local function IDToName(ID)
	if not IdToNameMap then
		IdToNameMap = {}
		for k, v in pairs(EventID) do
			IdToNameMap[v] = k
		end
		-- for k, v in pairs(_G.UE.EEventID) do
		-- 	if type(k) == "string" and type(v) == "number" then
		-- 		IdToNameMap[v] = k
		-- 	end
		-- end
	end

	local Name = IdToNameMap[ID]
	if Name then
		return Name
	end

	Name = _G.UE.EEventID.GetNameStringByValue(ID)
	if Name then
		IdToNameMap[Name] = ID
	end

	return Name
end

---@class EventID : EEventID
local EventID = {

	NetworkConnected = 10001,
	NetworkDisConnected = 10002,
	NetworkStateChanged = 10003,
	NetworkRelayConnected = 10004,
	NetworkConnectSuccess = 10005,
	NetworkHeartBeatTimeOut = 10006,
	NetworkStartHeartBeat = 10007,
	NetworkStopHeartBeat = 10008,
	NetworkReconnectLoginFinished = 10009,
	NetworkStartWaiting = 10010,
	NetworkStopWaiting = 10011,
	NetworkReconnectStart = 10012, 		--弹出重连框事件

	ErrorCode = 10020,

	ObjectLoadNoCacheImage = 10030,

	LoginSelectServer = 10100,
	LoginSelectProf = 10101,
	LoginSelectGender = 10102,
	-- LoginServerGroup = 10103,	--废弃
	LoginRaceTribeSelect = 10104,	--创建时，选种族、选部队的item是共用的，所以报这个event上去
	LoginCurRaceCfgChange = 10105,

	LoginCreateFaceSave = 10110, -- 捏脸存档数据变化
	LoginCreatFaceServerReset = 10111, -- 后台捏脸数据重置
	LoginCreateCameraChange = 10112, -- 捏脸时相机镜头变化
	LoginUIActorFaceSet = 10113,   --创建ator后并开始设置了捏脸数据
	LoginCameraReset = 10114,		--触发了相机的重置
	HairUnlockListChange = 10115, -- 解锁发型列表变化
	HairRoleQuery = 10116, -- 理发屋获取角色信息
	HairUnlockCompleted = 10117, -- 解锁发型成功
	FantasiaSuccessChangeRole = 10118,	-- 幻想药使用成功

	StartLifePercent = 10120,
	StartLifeCompleted = 10121,
	ShutdownLifeStart = 10122,
	ShutdownLifeCompleted = 10123,

	GMEnterSubmit = 10200,
	GMLastRecord = 10201,
    GMNextRecord = 10202,
    GMShowUI = 10203,
	GMSelectFilter = 10204,
	GMButtonClick = 10205,
	GMReceiveRes = 10206,
	GMGetMonsterAIInfo = 10207,
	GMGetTargetCombatInfo = 10208,
	GMChangeWeatherTime = 10209,
	GMShowWeatherInfoPanel = 10210,
	GMShowRTT = 10211,
	GMShowTimeNow = 10212,

	SettingsMaxFPSChanged = 10250, -- 游戏设置中最大帧率变化

	SidebarItemTimeOut = 10280, --侧边栏Item超时
	SidebarPlayAnimation = 10281, --侧边栏播放指定动效
	SidebarRemoveItem = 10282, -- 侧边栏移除Item
	SidebarRemoveItemByParam = 10283, -- 侧边栏移除指定Item

	SidePopUpUpdateTime = 10290,--侧边弹出框时间倒数
	SidePopUpTaskEquipmentUpdate = 10291, -- 一键装备侧边栏更新

	TeamUpdateMember = 10300,
	TeamVoteNotify = 10301,
	TeamInviteJoin = 10302,
	TeamMemberShowSelect = 10303,
	TeamRollItemUpdateTick = 10304,
	TeamRollItemViewShowStatus = 10305,
	TeamRollItemSelectEvent = 10306,
	RollExpireNotify = 10307,
	TeamRollBoxTipsVisibleEvent = 10308,
	TeamWaitResultPlayAnimNotify = 10309,
	-- RollBelongNotify = 10311,
	TeamRecruitFuncEditUpdate = 10312,
	TeamRollStartEvent = 10313,
	TeamRollEndEvent = 10314,
	TeamRollAllGiveUp = 10315,
	TeamRollAllRandom = 10316,
	TeamRollBoxEFFEvent = 10317,
	TeamRollCheckIsAllOperated = 10318,
	TeamLeave = 10319,
	TeamJoin = 10320,
	TeamRecruitTaskSetConfirm = 10321, --组队招募任务确认
    --- 组队界面三个按钮状态变更
    TeamBtnStateChanged = 10322,
	--- 目标标记
	TeamSignsSelectedCancle = 10324,
	TeamSignsSelected = 10325,
	TeamTargetMarkStateChanged = 10326,
	TeamTargetMarkBtnUseStateChanged = 10327,
	--- 场景标记变更推送
	TeamSceneMarkAddEvent = 10328,
	TeamSceneMarkRemoveEvent = 10329,
	TeamSceneMarkPosChangedEvent = 10330,
	TeamSceneMarkSeverNotifyEvent = 10331,
	TeamCaptainChanged = 10332,
	--  = 10333,
	TeamSceneMarkMoveEvent = 10334,
	TeamSceneMarkConfirmEvent = 10335, -- 扡拽结束或者直接双击生成特效
	--- 组队邀请
	TeamInviteUpdate = 10336,
	TeamJoinReject = 10337,
	--- 组队信息更新
	TeamInfoUpdate = 10338,

	TeamIDUpdate = 10339, -- 队伍ID更新 (不指定队伍)

	-- 玩家组队状态发生变化（加入或退出队伍），目前没有区分副本内外组队 Params=RoleIDs
	TeamIdentityChanged = 10341,

	-- personinfo
	TeamNumberInfoQuerySucc = 10342,

	TeamSceneTeamDataUpdate = 10343,
	SceneTeamQueryFinish = 10344, -- 场景小队查询完成（不在副本场景时，登录游戏后，也会抛一次本事件）
	RecruitEditDifficulty = 10345,

	TeamInTeamChanged = 10346,   	-- 玩家 加入/离开 队伍的事件通知
	TeamMemberOnUpdateValue = 10347,

	RecruitClose = 10348,
	TeamQueryFinish = 10349, -- 队伍数据查询完成

	TeamMemberBeSelected = 10350,	--队员被选中
	TeamMemberInfoUpate = 10351,	--队员信息更新
	TeamRecruitJoin = 10356,
	RecuitCreate = 10352,
	TeamRecruitStateChanged = 10353, -- 招募状态改变

	TeamRecruitShareToPlayerSuc = 10354, -- 组队招募分享成功(玩家) @add by xingcaicao
	TeamRecruitOnQueryData = 10355,

	-- TeamMemberOnUpdateValue = 10361,
	TeamMemberMicSyncStateChanged = 10362,
	RecuitShareFromChild = 10363,
	TeamInviteFromChild = 10364,
	TeamRollHiTipsEvent = 10365,
	TeamVoteEnterSceneEnd = 10371,	--副本进入取消
	ChatMsgPushed = 10372,
	RecruitChatShared = 10373,
	TeamMemberOnlineStatus = 10374,


	TargetChangeMajor = 10400,
	TargetChangeActor = 10401,

	SkillUpdate = 10501,
	--SkillCast = 10502,
	SkillSpectrum_BardAnim = 10503,
	SkillSpectrumOn = 10504,
	SkillSpectrumUpdate = 10505,
	SkillSpectrumOff = 10506,
	SkillCDUpdateLua = 10507,
	SkillChargeUpdateLua = 10508,
	SkillReplace = 10509,
	AllSkillUpdateFinished = 10510,
	SkillCustomIndexReplace = 10511,
	CastPreInputChange = 10517,
	SkillBtnClick = 10518,
	SkillSpectrumSync = 10519,
	SkillSpectrumReplace = 10520,
	SkillSpectrumValueUpdate = 10521,
	--主角读条的event是 	MajorSing主角吟唱 	MajorBreakSing打断主角吟唱	SkillSingOver正常结束
	--第三方玩家的event是	ThirdPlayerSkillSing、ThirdPlayerSkillSingBreak、SkillSingOver
	ThirdPlayerSkillSing = 10522,	--只有第三方客户端的actor触发的sing
	SkillSingOver = 10523,	--释放读条技能，读条结束（不限于主角）
	ThirdPlayerSkillSingBreak = 10524,	--只有第三方客户端的actor触发的sing
	StorageStart = 10525,				--蓄力开始
	StorageEnd = 10526,					--蓄力结束
	SkillMainPanelShow = 10527,			--技能主界面显示完成
	SkillMaxChargeCountChange = 10528,	--最大充能次数改变
	SkillCDGroupUpdateLua = 10529,
	FightSkillPanelShowed = 10530,
	SkillMultiChoicePanelShowed = 10531,
	TriggerObjInteractive = 10532,
	SkillResSync = 10533,	--技能属性资源修正
	SkillUnlock = 10534,	--技能解锁
	SkillSpectrumAutoRaiseUpdate = 10535,
	SkillMedicineCDUpdate = 10536,		--技能药品CD更新
	SkillStatusUpdate = 10537,
	CastLimitSkill = 10538,			--极限技更新
	RemoveLimitSkill = 10539,			--极限技移除
	SimulateMajorSkillCast = 10541,			--模拟主角技能释放
	MajorChangeSkillWeight = 10542,
	SkillSetSkillCD = 10543,
	TriggerSkillUpdate = 10544,			--触发技能状态改变

	--SkillGameEvent
	SkillGameEventGetReward = 10545,
	SkillAssetAttrUpdate = 10546,		--技能相关属性更改事件(蓝量、采集力等)

	MajorSkillCastFailed = 10547,		--主角技能释放失败(未通过客户端校验)
	StartSkillSing = 10548,
	StopSkillSing = 10549,

	ControlPanelAttrExistChange = 10550,  -- 对应MainPanelVM中的同名变量, 一般LogicData有变化触发
	SkillSpectrumUpdateThirdPlayer = 10551,	--P3量谱值广播
	UseSkillNotSummonEvent = 10552, --无召唤兽使用需要召唤兽的技能

	SkillSpectrumForbidStatus = 10553,	--量谱禁用状态更新

	SkillChantViewShow = 10554,		--主角技能引导条显示
	SkillChantViewHide = 10555,		--主角技能引导条隐藏

	SkillGuideStart = 10556,
	SkillGuideEnd = 10557,

	--技能系统
	SkillSystemEnter = 10580,
	SkillSystemLeave = 10581,
	SkillSystemSing  = 10582,
	SkillCustomUnselected = 10583,
	SkillEditingIndexSwap = 10584,
	SkillCustomEnter = 10585,
	SkillCustomLeave = 10586,

	PlayerPrepareCastSkill = 10590,
	ExitDemoSkill = 10591,
	SkillSystemReplaceChange = 10592,
	SkillSystemClickBlank = 10593,
	SkillSystemDetailsChange = 10594,
	SkillSystemProfRedDotChange = 10595,
	SkillSystemUnselectButton = 10596,
	SkillSystemMultiChoiceFinish = 10597,
	SkillSystemPostUseSkill = 10598,
	SkillSystemReplace = 10599,


	--副本
	-- PWorldExit = 52 -- 这个是进入副本前都会调用的，不仅仅是退出副本。定义在C++那边，可以搜索一下用法
	PWorldStageInfoUpdate 		= 10601,
	PWorldReady 				= 10602,
	PWorldUpdateDynData 		= 10603,
	PWorldMapMovieSequenceEnd	= 10604,
	PWorldResult  				= 10605, -- 副本结果
	PWorldFinished				= 10606, -- 副本结束
	PWorldBegin 				= 10607,
	PWorldTransBegin 			= 10608, -- 副本内的传送开始了

	AreaTriggerBeginOverlap     = 10609, --进入区域
	AreaTriggerEndOverlap     	= 10610, --离开区域

	-- 跨服变动
	PWorldCrossWorld 			= 10611, --跨服操作通知

	-- 副本入口&匹配
	PWorldMatchTimeUpdate		= 10620, -- 匹配时间更新
	PWorldMatchUpd 	 			= 10621, -- 匹配数量更新
	PWorldMatchRandUpd   		= 10622, -- 匹配排名更新
	PWorldMatchLackProfUpd  	= 10623, -- 稀少职业更新
	PWorldRewardsUpd  			= 10624, -- 奖励更新


	--副本战斗预警
	PWorldWarningDuring			= 10625, -- 预警过程
	PWorldWarningEnd			= 10626, -- 预警结束

	PWorldEntSwitch  			= 10627, -- 副本入口变更
	PWorldMapEndTimeSwitch  	= 10628, -- 副本结束时间变更

	PWorldLineQueryResult 		= 10630, -- 副本分线查询结果

	-- 副本队伍
	PWorldTeamMemUpd  			= 10640, -- 副本队伍成员更新

	-- 副本进度槽
	PWorldProgressSlot			= 10650, -- 副本进度槽变化
	PWorldProgressSlotHide		= 10651,

	-- 副本剧情辅助器
	PWorldEntourageViewClosed   = 10652,
	PWorldUpdatePreCheck   		= 10660, -- 更新是否可参加
	ShowPromoteMainPanel   		= 10661, -- 弹出提升聚合界面

	-- 副本全地图显示实体
	PWorldEntityListSync 		= 10670,
	PWorldEntityAdd 			= 10671,
	PWorldEntityRemove 			= 10672,
	PWorldEntityUpdate 			= 10673,

	-- 副本地图
	LoadMapFinish				= 10680, -- 加载地图完成
	EnterMapFinish  			= 10681, -- 进入地图完成

	-- 副本查询
	PWorldRoleSceneData			= 10690,	--场景在线数据

	-- 副本变量
	PWorldVariableDataChange    = 10691, -- 副本变量变更通知

	--Combat
	CombatGetEnmityList = 10701,
	CombatGetRelateEnmityList = 10702,
	CombatSubscribeEnmityList = 10703,		--仇恨列表订阅事件
	CombatCancelSubscribeEnmityList = 10704,	--仇恨列表取消订阅事件
	CombatStateChanged = 10705,					--战斗状态改变

	SwitchPeacePanel = 10751,
	SwitchFightPanel = 10752,
	ForcePeacePanel = 10753,
	ForceFightPanel = 10754,
	

	--Input
	InputActionSkillPressed = 10801,
	InputActionSkillReleased = 10802,
	PreprocessedMouseButtonDown = 10803,
	PreprocessedMouseButtonUp = 10804,
	PreprocessedMouseMove = 10805,
	BlockAllInput = 10806,

	ReviveInfoUpdate = 10901,
	ReviveInfoUpdateInColosseum = 10902, -- PVP水晶冲突复活信息刷新

	-- 幻卡
	MagicCardShowNewTurn = 11001,
	MagicCardDoPlayOneCard = 11002,
	MagicCardShowBoardEffectForSpecialRule = 11003,
	MagicCardGameFinish = 11004,
	MagicCardEnlargeOneCard = 11005,
	MagicCardRefreshMainPanel = 11006,
	MagicCardOnSvrCreateAutoGroup = 11007,
	MagicCardOnNetEditGroupRsp = 11008,
	MagicCardPlayCardClickSound = 11009,
	MagicCardUpdateTimer = 11010,
	MagicCardUpdateNPCHudIcon = 11011,
	MagicCardShowFirstSeenCardEnd = 11012,
	MagicCardNewMove = 11013,
	MagicCardShowRuleEffect = 11014,
	MagicCardChangedName = 11015, -- 修改了名字，外面也要同步一下
	MagicCardShowRulePanelInBattle = 11016, -- TEAMPANEL点击了规则，显示详细规则
	MagicCardBattleRecover = 11017, -- 幻卡对局短暂断线重连了
	MagicCardGameStartReq = 11018, --幻卡规则信息请求
	MagicCardReadyNewMove = 11019, --出牌准备完成
	MagicCardRecoverPos = 11020, -- 恢复牌局打出的牌位置
	MagicCardNeedReqRecover = 11021, -- 幻卡对局需要请求重连
	MagicCardRecover = 11022, -- 幻卡对局重连
	MagicCardTourneySelectEffect = 11030, -- 幻卡大赛阶段效果选择
	MagicCardBattleQuit = 11031, -- 幻卡对局离开
	MagicCardTourneyRankUpdate = 11032, -- 幻卡大赛排名信息更新,用于头顶排名图标
	MagicCardBeforeEnterQuit = 11033, --幻卡准备阶段离开
	MagicCardTourneyLateShowLoot = 11034, -- 幻卡大赛奖励延迟显示
	MagicCardTourneyEffectSelected = 11035, -- 大赛阶段效果选择完成
	MagicCardCollectionUpdate = 11036, -- 卡牌收藏更新了
	OnMagicCardStart = 11037, -- 幻卡开始（从准备界面开始）
	OnMagicCardExit = 11038, -- 幻卡退出（包括准备界面和对局界面退出）

	-- Npc对话交互
	ClickNextDialog = 11101,
	FinishDialog = 11102,
	OnEmotionPanelClose = 11103,
	UpdateInDialogOrSeq = 11104,
	StartDialog = 11105,
	OnDialogNpcDestory = 11106,
	--交互
	ClickEntranceItems = 11150,	--一级列表的click
	PreClickFunctionItems = 11151, --二级列表的preclick
	PostClickFunctionItems = 11152, --二级列表的postclick
	MajorSingBarBegin = 11153,			--读条开始
	MajorSingBarOver = 11154,			--读条结束
	MajorSingBarBreak = 11155,			--读条打断
	EntranceItemChanged = 11156,	--一级交互入口有变化
	EnterInteractive = 11157,	--进入交互
	ExitInteractive = 11158,	--退出交互
	FunctionListCreated = 11159,    --交互列表生成
	--交互：选怪模块
	SelectMonsterIndex = 11159, --当前选择的怪物的tag index
	OthersSingBarBegin = 11160,
	OthersSingBarOver = 11161,
	OthersSingBarBreak = 11162,
	InteractiveReqEndError = 11163, --交互请求结束错误
	SingBarAllOver = 11164,	--读条+动作全部结束
	PlayItemUsedPlayATLEnd = 11165,--特殊没有读条End的动作走这个
	--采集
	ActiveGatherItemView = 11171,	--逻辑mgr激活一个采集物
	DeActiveGatherItemView = 11172,	--逻辑mgr取消激活一个采集物
	-- HideFunctionItemView = 11173,
	UpdateGatherPoints = 11174,			--采集点变化，通知小地图刷新
	UpdateNearestGatherPoint = 11175,	--最近的采集点，通知小地图刷新
	AddMiniMapGatherPoint = 11176,		--增减采集点的小地图图标
	RemoveMiniMapGatherPoint = 11177,
	CollectionSkillCDUpdate = 11178, --刷新收藏品技能CD
	OnCastSkillUpdateMask = 11179,
	--注意下面的id是否用到，不要重复了

	GatheringJobCollectionScour = 11180,  -- 采集收藏品提纯事件，用于触发HUD飘字 Params = {LastVal = number, CurrentVal = number, ValueUp = boolean}
	GatheringJobShowBarView = 11181, --显示GatheringJobPanel_UIBP界面的血条
	GatheringCollectionProBarDoMove = 11182, --采集收藏品界面进度条

	--点选交互
	FixedFunctionPanelShowed = 11182,  --显示点选交互界面
	UseWorldViewObj = 11183,	---使用世界观物件，如椅子坐下/起身
	ClickWorldViewObjEntranceItem = 11184,	--点击世界观物件交互入口

	EnterGatherState = 11185,				--进入采集状态
	ExitGatherState = 11188,				--退出采集状态
	EnterGatherCollectionState = 11189,				--进入收藏品采集状态
	ExitGatherCollectionState = 11190,				--退出收藏品采集状态
	OthersEnterGatherState = 11191,				--其他人进入采集状态
	OthersExitGatherState = 11192,				--其他人退出采集状态
	-- 等级职业
	MajorLevelUpdate = 11201,
	MajorExpUpdate = 11202,
	MajorProfActivate = 11203,
	-- MajorProfSwitch = 11204,	废弃，被挪到c++的定义中了
	MajorLevelSyncSwitch = 11205,
	-- = 11206,
	--采集相关
	AddMiniMapTimeLimitGatherPoint = 11210,		--增减限时采集点的小地图图标
	RemoveMiniMapTimeLimitGatherPoint = 11211,

	WidgetDragStart = 11301,
	WidgetDragMove = 11302,
	WidgetDragEnd = 11303,
	WidgetDragConfirm = 11304,
	WidgetDragCancel = 11305,
	ResetDragUI = 11306,

	ShowUI = 11400,
	HideUI = 11401,
	VirtualKeyboardShown = 11402,
	VirtualKeyboardHidden = 11403,
	VirtualKeyboardReturn = 11404,

	--钓鱼
	EnterFishArea = 11501,
	ExitFishArea = 11502,
	FishLift = 11503,
	FishDrop = 11505,
	FishEnd = 11506,
	EnterFishStatus = 11507,
	ExitFishStatus = 11508,
	FishBite = 11509,
	FishLiftStart = 11510,
	SelectMainTeamPanelQuest = 11512,
	SkillGenAttack = 11513,
	SelectMainStageButtonSwitch = 11514,
    FisherManFishing = 11515,

	--任务
	UpdateQuest = 11601,
	InitQuest = 11602,
	UpdateQuestTrack = 11604,
	ClearQuest = 11605,
	GetQuestTrack = 11606,
	QuestTargetEmotionStart = 11607,
	QuestTargetEmotionEnd = 11608,
	UpdateTrackQuestTarget = 11609,
	QuestErrorFarDistance = 11610,
	QuestClosePropPanel = 11611,
	QuestLimitTimeOver = 11612,

	--任务系统动态监听的事件
	ClientInteraction = 11641,
	ClientNpcMoveStart = 11644,
	ClientNpcMoveEnd = 11645,
	--任务系统新事件在此注释上方添加 ↑ ↑ ↑
	--下面事件不属于任务系统！！！对应处理人看到后需要转移到合适的ID段
	GateOppoNpcTaskIconUpdate = 11646,
	GoldActivityIconUpdate = 11647,
	FindPathFailed = 11648,		--地面指引寻路，服务器没有路径
	UpdateQuestTargetOwnItem = 11649, --更新任务拥有购买物目标
	QuestPlayRestrictedDialog = 11650, --播放不满足任务对话

	-- 背包
	BagUpdate = 11701,
	BagFreezeCD = 11702,
	Main2ndPanelMenuAnimNotify = 11703,
	BagUseItem = 11704,
	BagBuyCapacity = 11705, --背包扩容
	BagUseItemSucc = 11706,
	BagInit = 11707,
	BagUpdateNew = 11708,
	BagManualSetMedicine = 11709, --背包手动设置/取消设置药品
	RenameCardCheckRepeat = 11710,
	BagTreasureChestNumChanged = 11711,


	--装备
	AttributeDetailOpen = 12000,	---属性详情点击展开
	EquipRepairSucc = 12001,		---装备修理成功
	MagicsparInlaySucc = 12002,		---魔晶石镶嵌成功
	MagicsparUnInlaySucc = 12003,	---魔晶石卸载成功
	EquipUpdate = 12004,			---更新身上装备
	SwitchLockProf = 12005,
	StrongestEquipUpdate = 12006,
	ExchangeNumUpdate = 12007,
	ExchangeIndexChange = 12008,
	ImproveIndexChange = 12009,
	ExchangeNetEvent = 12010,
	EnduredegChange = 12011,
	EquipmentAnimFinish = 12012,
	MagicsparSwitchEquip = 12013,    ---魔晶石切换装备
	EquipDetailViewClose = 12014,
	MagicsparInlayRefresh = 12015,   ---魔晶石镶嵌刷新
	ReSelectMajorProf = 12016,
	EquipStrongestViewHide = 12017,
	
	--情感动作
	EmotionUpdateFavorite = 12100,		-- 设置收藏动作
	BreakPlayEmotion = 12101,			-- 在播放动作之前阻断（还没有开始播放）
	EmotionRefreshItemUI = 12103,		-- 刷新情感动作按钮可用性

	--Actor
	ActorVMCreate = 12200,
	ActorVMDestroy = 12201,

	--计数器
	CounterInit = 12301,
	CounterUpdate = 12302,
	CounterClear = 12303,

	--buff
	MajorInfoAddBuff = 12401,
	MajorInfoRefreshBuff = 12402,
	MajorInfoRefreshBuffTime = 12403,
	MajorInfoBuffEffectiveState = 12404,
	MajorAddBuffLife = 12405,
	MajorRemoveBuffLife = 12406,
	-- EntityLifeBuffUpdateAll = 12407, -- 原来很多业务不支持全量更新，不用全量更新事件
	MajorUpdateBuffLife = 12408,
	UpdateBuffTimeLife = 12409,
	MajorUpdateBuffTime = 12410,
	MajorUpdateBuff = 12411,		--主角buff更新，C++无法热更，因此由SkillBuffMgr响应UpdateBuff事件并转发
	MajorRemoveBuff = 12412,



	-- Chat
	ChatInsertInputText = 12500,
	ChatUpdateColor = 12501,
	OnSendChat = 12502,
	ChatMsgClickHyperLink = 12505,
	ChatHyperLinkSelectGoods = 12506,
	ChatHyperLinkAddLocation = 12507,
	ChatHyperLinkSelectHistoryItem = 12508,
	ChatQueryRoleItemInfo = 12509,
	ChatIsJoinNewbieChannelChanged = 12510,
	ChatNewbieGuiderNumChanged = 12511,
	ChatSettingComprehensiveChannelBlockGroup = 12512,
	ChatSettingComprehensiveChannelBlockGroupClear = 12513,
	ChatGetIsBlockStranger = 12514,
	ChatRefreshNewbieMember = 12515,
	ChatScroolSettingSortItemIntoView = 12516,
	ChatRefreshPioneerPanel = 12517,
	ChatOpenPrivateRedDotTipChanged = 12518,
	ChatOpenPrivateSidebarChanged = 12519,
	ChatOpenPrivateDanmakuChanged = 12520,
	ChatOpenTeamDanmakuChanged = 12521,

	-- GM系统
	MinimizationUIShow = 12601,
	ItemSelected = 12602,
	ItemIsHoverd =12603,

	--极限技
	SkillLimitOff = 12701,		--只要最大值不是0，就展示ui
	SkillLimitDel = 12702,		--隐藏极限技ui
	SkillLimitValChg = 12703,	--极限值刷新，参数有limitvalue（当前phase的1w以内的val）、curphase、技能id;  如果ui没显示，需要先显示ui
	SkillLimitCancelBtnClick = 12704, --点击离开极限技释放的按钮
	SkillLimitEntranceClick = 12705, --点击进入极限技释放的状态
	DragSkillBegin = 12706,	--副摇杆技能开始，显示右上角取消按钮时触发
	DragSkillEnd = 12707,	--副摇杆技能结束，右上角取消按钮隐藏时触发
	BeginUseLimitSkill = 12708,	--有人使用极限技
	EndUseLimitSkill = 12709,	--有人使用极限技

	-- 天气预报
	UpdateWeatherForecast = 12801,
	WeatherChange = 12802,
	WeatherMainUIExp = 12821,
	WeatherMainUIDSeltIdxChg = 12822,
	WeatherMainUIExpMapChg = 12823,
	WeatherArrowBallAnimFinished = 12824,


	-- 好友系统
	FriendUpdate = 12901,
	FriendAdd = 12902,
	FriendRemoved = 12903,
	FriendGroupInfoUpdate = 12904, -- 好友小组信息（名字、数量）更新
	FriendTransGroup = 12905,
	FriendAddBlack = 12906,
	FriendRemoveBlack = 12907,
	FriendBatchSwitchGroupUpdate = 12908,
	FriendRecentInfoUpdate = 12909,
	FriendScreenProfUpdate = 12910,
	FriendScreenPlayStyleUpdate = 12910,
	FriendAddResetDefaultState = 12911, -- 好友查找重置回默认状态
	FriendPlayUpdateFriendListAnim = 12912,
	FriendPlayAddUpdateListAnim = 12913,

	-- 通讯贝系统
	LinkShellCreateSuc = 13001,
	LinkShellCreateSelectedActIDsUpdate = 13002,
	LinkShellRefreshMemList = 13003,
	LinkShellListUpdate = 13004, -- 通讯贝更新
	LinkShellRename = 13005, -- 通讯贝修改名字
	LinkShellMgSelectedActIDsUpdate = 13006,
	LinkShellScreenActUpdate = 13007,
	LinkShellPlayJoinUpdateListAnim = 13008,
	LinkShellDestory = 13009, --退出/被踢/解散
	LinkShellInvitedListUpdate = 13010, -- 被邀请通讯贝列表更新

	-- 微彩
	MiniCactpotBuyOneSuccess = 14001,	--开局以及后续开格子
	MiniCactpotOpenRemuner = 14002, -- 打开报酬一栏
	MiniCactpotAnimOpenGrid = 14003, -- 播放左边格子动画

	--生产职业
	CrafterSkillEnable = 13100, --1次技能释放结束，制作界面上的技能释放按钮可以点击
	CrafterSkillDisable = 13101, --正在释放技能，制作界面上的技能释放按钮是禁用的，不能释放技能
	CrafterSkillCDUpdate = 13102, --工次也就是CD变化的通知
	CrafterSkillRsp = 13103, --生产职业技能回包的事件通知（仅仅是制作者本身的技能回包才会触发）
	CrafterRandomEventSkill = 13104,	--显示出：随机事件对应的技能
	CrafterOnMakeComplete = 13105,	-- 制作完成抛事件
	CrafterHotForgeStateChange = 13106,  -- 是否进入了热锻状态, 主要用于技能遮罩
	CrafterCulinaryOrigin = 13107,  -- 味之本源的通知
	CrafterOnNormalMakeStart = 13108,  -- 常规制作开始时抛事件 Params = nil
	CulinarianSpecialElement = 13110,  -- 烹调师获得特殊元素
	StartCrafter = 131111,				--正要进入制作状态
	CrafterCulinaryStorm = 13112,  -- 灵感风暴
	CrafterExitRecipeState = 13109,
	CrafterEnterRecipeState = 13113,
	CrafterRandomEvent = 13114,	--触发随机事件
	MajorCrafterRandomEvent = 13115,	--触发随机事件
	CrafterSkillCostUpdate = 13116,  -- 生产职业Cost更新
	CrafterAllEnterRecipeState = 13118,--所有人离开制作状态便会通知
	CrafterAllExitAllState=13119,--所有人离开制作状态动作结束

	-- 地图
	MapOnAddMarker = 13201,
	MapOnRemoveMarker = 13202,
	MapOnUpdateMarker = 13203,
	MapOnAddMarkerList = 13204,
	MapOnRemoveMarkerList = 13205,
	MapChanged = 13206,
	LoadWorldInCutScene = 13207,
	WorldMapSelectChanged = 13210,
	WorldMapScaleChanged = 13211,
	WorldMapUpdatePlacedMaker = 13212,
	WorldMapAddPlacedMakers = 13213,
	WorldMapRemovePlacedMakers = 13214,
	WorldMapUpdateDiscovery = 13215,
	MapFollowAdd = 13216, -- 地图追踪标记增加
	MapFollowDelete = 13217, -- 地图追踪标记删除
	MapFollowUpdate = 13218, -- 地图追踪标记更新
	MapFollowTargetUpdate = 13219, -- 地图追踪目标更新
	MapMarkerPlayAnimation = 13220,	-- 地图标记播放动画
	MapAutoPathUpdate = 13221, -- 地图自动寻路路线更新
	WorldMapUpdateAllMarker = 13222,
	WorldMapFinishChanged = 13223, -- 地图已完成切换，包括完成动画播放
	MapAutoPathProgressUpdate = 13224, -- 地图自动寻路进度刷新
	WorldMapFinishCreateMarkers = 13225, -- 已完成创建标记
	WorldMapMarkerTipsListRemove = 13226, -- 移除打开的列表
	MapMarkerPriorityUpdate = 13227, -- 更新地图标记显示优先级
	MapMarkerHighlight = 13228, -- 更新地图标记高亮效果

	-- 冒险
	GoToTaskDetailView = 13401, --随机任务前往跳转
	GetChallengeLogCollect = 13402, --挑战笔记奖励领取成功
	GetChallengeLogRewardCollect = 13403, --挑战笔记宝箱奖励领取成功
	GetRandomDailyInfo = 13404, --每日随机信息
	GetChallengeLogInfo = 13405, --获得挑花战笔记状态
	GetChallengeRewardCollect = 13406, --获得挑花战笔记宝箱状态
	AdvenCareerTaskGuide = 13407,	-- 冒险职业任务推荐气泡

	-- 宝箱
	TreasureAssign = 13501, --分配宝箱的事件

	--坐骑
	MountRefreshList = 13600,	--刷新坐骑列表
	MountFilterUpdate = 13601,	--刷新坐骑过滤列表
	MountRefreshLike = 13602,	--Like刷新
	-- MountPanelHide = 13603,     --坐骑面板隐藏
	MountSkillRelease = 13604,  --坐骑技能释放
	MountPreCallStart = 13605,  --坐骑开始召唤一瞬间
	OnShowMountPanel = 13606,   --UI显示坐骑面板
	ActionSelectChanged = 13607,--坐骑图鉴技能选中状态
	MountBgmSettingChange = 13608,
	UseMount = 13609,			--上坐骑

	--map range
	MapRangeChanged = 13701, 	--地图区域变更

---------------------------SDK分支用--------------------------------
	-- Account
	MSDKLoginRetNotify = 13801,
	MSDKBaseRetNotify = 13802,
	MSDKDeliverMessageNotify = 13803,
	MSDKQueryFriendNotify = 13804,
	MSDKWebViewOptNotify = 13805,
	MSDKInitNotify = 13805,

	AlbumPhotoSelectedNotify = 13851,	-- iOS相册图片选中
	TakePhoto = 13852,					-- 安卓相册图片选中

	-- Voice
	GVoicePlayRecordDone = 13902, 	-- 录音播放完成

	SDKEnd = 14199,	--SDK分支结束,13800~14199SDK分支占用，避免冲突
---------------------------------------------------------------------

	-- 在线状态
	OnlineStatusChangedInVision = 14201,  -- 视野内的其他玩家在线状态发生改变
	OnlineStatusMajorChanged = 14202,  -- 本地玩家在线状态发生改变
	--OnlineStatusMajorIdentityChanged = 14203,  -- 本地玩家身份发生改变 TODO(loiafeng): 这个事件后续可能会挪到指导者系统中

	-- 通用留言板
	BoardObjectChange = 14301, -- 留言板图鉴数据发生变化
	BoardRefreshList = 14302,  -- 留言板列表更新

	--交易所
	ScoreUpdate = 14401,  --积分刷新
	DepotDataRefresh = 14402, --仓库刷新
	MarketStallInfoUpdata = 14403, --摊位数据
	MarketReferencePriceUpdata = 14404, --参考价
	MarketTypeQueryGoods = 14405, --分类型查询物品列表
	MarketUpdateFollowGoods = 14406, -- 关注列表刷新
	MarketRecordList = 14407, --交易列表数据
	MarketRefreshBuyPage = 14408,  --刷新当前购买页面数据
	MarketRefreshStallBriefList = 14409, --刷新摊位检索信息
	MarketReceiveMoney = 14410,  --获取收益刷新
	MarketRefreshConcernInfo = 14411, --关注变化刷新

	--水晶
	CrystalUpdateNum = 14501,  --水晶数量更新
	CrystalActivated = 14502,  --水晶激活
	CrystalTransferReq = 14503,  --水晶传送请求发送
	PreCrystalTransferReq = 14504,  --水晶传送请求发送前

	--筛选
	ScreenerResult = 14601, -- 筛选结果通知
	ScreenerUpdateBarTag = 14602, -- 筛选标签更新

	--个人信息
	PersonGetPortraitHeadDataSuc = 14703, 	-- 获取头像
	PreShowPersonInfo = 14704,
	PersonHeadFrameUnlock = 14705,
	PersonHeadFrameUse = 14706,
	PersonHeadFrameListUpd = 14707,

	ChaneNameNotify = 14708,
	GetHistoryNameSuccess = 14709,
	QueryRoleInfo = 14710,

	-- 肖像编辑
	PersonPortraitGetDataSuc = 14750, 		-- 获取个人信息肖像数据成功
	PersonPortraitResStatusUpdate = 14751, -- 肖像编辑资源状态更新
	PersonPortraitRemoveAppearUpdateTips = 14752,	-- 移除外观更新提示

	--充值
	RechargeRewardReceived = 14801, -- 获取累充奖励
	RechargeShopkeeperPlayAction = 14802, -- 看板娘执行动作

	-- main panel
	ShowSubViews = 14901,

	--旅行笔记
	SelectTravelLogItem = 15001, -- 选中旅行日志


	--运输陆行鸟
	UpdateChocoboTransportNpcBookStatus = 15101, -- 更新运输陆行鸟Npc登记状态
	UpdateChocoboTransportFindPath = 15102,		 -- 更新运输陆行鸟寻路
	UpdateChocoboTransportPosition = 15103,		 -- 更新运输陆行鸟位置
	ChocoboTransportFinish = 15104,				 -- 陆行鸟运输流程结束
	ChocoboTransportBegin = 15105,				 -- 陆行鸟运输流程开始(未开始移动)
	ChocoboTransportArriving = 15106,			 -- 陆行鸟运输抵达终点(运输状态未结束)
	ChocoboTransportStartMove = 15107,			 -- 陆行鸟运输开始移动

	--ActorUI
	ActorUIColorConfigChanged = 15201, 	-- 玩家设置颜色配置 Params={ActorUIType = number, ColorID = number}
	ActorUITypeChanged = 15202, 		-- 角色颜色类型发生变化 Params=EntityIDs

	--片尾动画
	StaffRollBeginPlay = 15301,			-- 开始播放
	StaffRollEndPlay = 15302,			-- 结束播放
	StaffRollBackImageShow = 15303,		-- 背景显示
	StaffRollBackImageHide = 15304,		-- 背景隐藏
	StaffRollShowStaffList = 15305,		-- 显示Staff表


	--副本UI交互
	PWorldUIChange = 15401,				-- 副本UI变更
	PWorldSkillTip = 15402,				-- 副本技能提示
	PWorldItemChange = 15403,			-- 副本教学变更
	PWorldTeachingStateChange = 15404,	-- 副本教学状态变更
    --红点系统
	RedDotUpdate = 15501, -- 红点数据更新
	RedDotColorAndStyleUpdate = 15502, -- 红点颜色更新
	Update_Recording= 15503, -- 副本录制开启
	-- OnWorldPreLoad= 15504, -- 地图加载开始
	-- OnWorldPostLoad= 15505, -- 地图加载结束
	Show_RecordID= 15506, -- 显示录像ID

	WardrobeUpdate = 15600,				--衣橱更新
	WardrobeCollectUpdate = 15601, 		--衣橱收藏更新
	WardrobeUnlockUpdate = 15602, 		--衣橱解锁更新
	WardrobePresetSuitUpdate = 15603,	--衣橱预设套装信息更新
	WardrobeEnlagerPresets = 15604, 	--衣橱预设套装扩容
	WardrobeActiveStain = 15605,		--衣橱激活染色剂
	WardrobeDyeUpdate = 15606,			--衣橱染色
	WardrobeCollectReward = 15607,      --衣橱奖励领取
	WardrobeClothingUpdate = 15608,		--衣橱穿戴更新
	WardrobeActiveColorUpdate = 15609,  --衣橱染色查询
	WardrobeCharismValueUpdate = 15610, --衣橱魅力值更新
	WardrobeUnClothingUpdate = 15611,   --衣橱取消穿戴
	WardrobeTipOpenGetWayView = 15612,	--衣橱tips打开获取途径
	WardrobeUnlockIDUpdate  = 15613, 	--- 衣橱指定外观数据更新
	WardrobeUsedStainUpdate = 15614,	--- 衣橱染色试剂更新
	WardrobeRegionDyeUpdate = 15615,	--- 衣橱染色区域更新

	--迷雾
	UpdateFogInfo = 15500,				-- 迷雾数据更新

	--Bonus State 角色加成状态
	AddOrUpdateBonusState = 15701,		-- 添加或更新加成
	RemoveBonusState = 15702,

	-- 活动系统
	OpsActivityUpdate = 15800,  --活动更新
	UpdateLotteryInfo = 15801,  --更新抽奖信息
	PurchaseLotteryProps = 15802, -- 购买礼包
	ShowLoginDayReward = 15803,  --展示登录奖励
	OpsActivityUpdateInfo = 15804,	--更新活动信息
	OpsActivityNodeGetReward = 15805, --节点领奖
	RechargeActivitySuccess = 15806, --直购发货成功
	OpsActivityReportSuccess = 15807, -- 上报成功
	SeasonActivityUpdatRedDot = 15808, -- 季节活动红点更新
	PandoraShowRedot = 15809, 			-- 潘多拉发给活动系统的红点通知
	OpsActivityMainPanelShowed = 15810, -- 活动主面板显示
	SinkActivityToBottom = 15811, -- 活动面板沉底
	RemoveActivity = 15812, -- 活动结束时
	OpenAnotherOpsActivity = 15813, -- 打开另一个活动
	OpcConcertLastLoginRolesUpdate = 15814, -- 拉回流活动中好友角色更新通知
	OpsTreasureChestSkipAnimation = 15815,	--跳过动画按钮通知
	PandoraActivityClosed = 15816,                        -- 潘多拉活动关闭通知
	OpsConcertInvite = 15822, -- 通知邀请玩家

	-- 季节活动中的事件
	FatPenguinBlessUpdatRedDot = 15900, -- 胖胖企鹅红点更新
	-- PVP玩法
	PVPStart = 16000,

	-- Colosseum 水晶冲突战
	PVPColosseumSGUpdate = 16001, -- 物件状态更新
	PVPColosseumCheckPointUpdate = 16001, -- 检查点更新
	PVPColosseumCrystalStateUpdate = 16002, -- 水晶状态更新

	-- Frontline 战争前线
	PVPFrontlineStart = 16100,

	PVPEnd = 16199,

	---面对面交易
	MeetTradeLockStateChange = 16200,
	MeetTradeConfirmStateChange = 16201,
	EnterLevelConfirmView = 16202,

	-- Login
	MSDKCustomAccountNotify = 16301,
	MSDKNoticeNotify = 16302,
	PreDownloadState = 16303,
	PreDownloadProgress = 16304,
	PreDownloadFinish = 16305,
	ShowPreDownload = 16306,
	HidePreDownload = 16307,
	LoginShowMainPanel = 16308,
	PlayLoginBGM = 16309,
	LoginToRoleSuccess = 16310,		-- 登录进入游戏成功
	LoginFromGameCenter = 16311,
	LoginRefuseAgreement = 16312,
	LoginConnectEvent = 16313,
	LoginQueueFinishEvent = 16314,
	AccountCancellationEvent = 16315,
	DoLogoutEvent = 16316,
	DeepLinkNotify = 16317,
	ShowIntegration = 16318,
	GroupNotify = 16319,
	-- Maple
	MapleNotify = 16350,
	MapleAllNodeInfoNotify = 16351,
	MapleFriendServerNotify = 16352,

	-- CommonFade
	CommonFadePanelFadeOut = 16401,

	-- 主界面
	MainPanelShow = 16500,
	-- 主界面右上角入口
	MainPanelFunctionLayoutChange = 16501,
	MainPanelShowBuffTips = 16502, 

	-- 播片
	StopSequenceHalfway = 16601,

	JumpAndEndSequence = 16602,

	--仙人仙彩
	JumboCactpotCheckPlayer = 200101,	-- 查看中奖名单
	JumboCactpotBuyCallBack = 200102,
	JumboCactpotChangeTogGroup = 200103,	-- 购买成功回调
	JumboCactpotUpdateBouns = 200104,	-- 刷新主界面购买加成进度图片
	JumboCactpotShowInfo = 200105, -- 仙彩展示任务信息

	-- 拼装剪影
	PuzzleFinishNotify = 200501,
	PuzzleForceExitNotify = 200502, -- 强行退出拼装剪影，会导致任务回退

	-- 系统解锁
	ModuleOpenNotify = 200201,
	ModuleOpenGMBtnEvent = 200203,		-- GM界面用
	-- ModuleOpenAllMotionOverEvent = 200204,		-- 系统解锁当前所有表现播放完
	ModuleOpenNewBieGuideEvent = 200205,		-- 系统解锁新手指南用
	ModuleOpenSkillUnLockEvent = 200206,		-- 技能解锁动效用
	SkillUnLockView = 200207, 					-- 技能解锁展开技能组的开关，几秒后关闭
	SpectrumsUnlock = 200208, 					-- 量谱解锁开关
	ModuleOpenUpdated = 200209,	-- 系统解锁数据处理完毕后事件，确保其他系统能在数据更新完后检查系统是否开放
	ModuleOpenMainPanelFadeAnim = 200210, -- 系统解锁播放主界面动效用
	PlaySkillUnLockEffect = 200211,				-- 播放技能解锁效果


	-- 指导者/新人/回归者相关 状态变动
	NewBieChannelInviterChange = 200301,

	--- 引导开关
	TutorialSwitch = 200401,
	--TutorialReconnect = 200402,
	TutorialStart = 200403,
	TutorialEnd = 200404,
	TutorialMainPanelReActive = 200405,
	TutorialRelogin = 200407,
	TutorialGuideChanged = 200408,
	TutorialTimerEnd = 200409,
	TutorialRemoveGuideView = 200410,
	TutorialFirstPlay = 200411,
	TutorialGuideCountDownEnd = 200412,
	TutorialShowView = 200413,
	TutorialHideView = 200414,
	TutorialTriggerCondition = 200415, --新手相关触发条件
	ForceCloseTutorial = 200416,
	TutorialLoadingFinish = 200417,
	TutorialMainPanelInActive = 200418,
	TutorialGuideIdChanged = 200419,
	TutorialGuideFenMaiQuanFinish = 200420, --引导风脉泉结束
	TutorialCloseBorderView = 200421,--关闭侧边栏
	TutorialGuideSwitch = 200422,	--新手指南开关
	TutorialGuideTouringBandFinish = 200423, --引导巡回乐团结束


	--掉落提示
	DealLootItem = 200601,  --获得物品时触发掉落提示tips
	DealLootList = 200602,  --获得物品时触发掉落提示tips
	LootItemUpdateRes = 200603, -- 更新掉落物品了

	-- 推荐任务
	RecommendTaskNewTip = 200701,					-- 新的推荐任务
	RecommendTaskUpdate = 200702,					-- 用于更新推荐任务列表

	-- 相机设置
	CameraSettingsUpdate = 200703,

	--设置相关
	--画质等级里的一个特性或者和画质等级挂钩的其他特性（灯光品质、分辨率）变了，画质等级需要变为自定义
	OnePictureFeatureChg = 200710,
	QualityLevelChg = 200711,	--五档画质的变化
	OnVoicePkgDownLoad = 200712,	--语音包下载完成，刷新语音资源管理界面
	BgVoiceCloseCancel = 200713,	--后台语音取消关闭

	--货币一览
	EquipmentCurrencyConvertViewHide = 200801,
	--称号
	TitleChange = 200900,
	--成就达成
	AchievementCompeleted = 200910,

	--月卡
	MonthCardUpdate = 201000,
	MonthCardUIClose = 201001,

	--乐谱
	UpdateMusicInfo = 201100, --更新主界面信息
	UpdateUnLockInfo = 201101, --更新已解锁的信息
	RightListChose = 201102, --右侧界面已选择
	UpdateEditMusicInfo = 201103,--更新编辑状态的乐曲信息
	UpdateInfoAfterSave = 201104,--保存之后更新列表
	UpdateAtlasPlayState = 201105,--更新图鉴播放状态
	UpdatePlayerState = 201106,--更新播放器播放状态
	RestPlay = 201107, --重置播放
	ClickDrop = 201108, --下拉点击
	UpdateDropState = 201109, --更新ViewDrop状态
	UpdateCanSaveState = 201110,--更新可保存状态
	MainChosedByRight = 201111, --主界面在选择右侧乐曲后的操作
	LeftChosed = 201112,--左侧界面已选择
	UpdateMainPlayerState = 201113, --更新主播放器状态
	UpdateRightPlayerState = 201114, --更新右侧试听播放器状态
	UpdateMusicItemState = 201115, --更新播放Item状态
	UpdateRevertState = 201116, --更新回想播放状态
	ExitRevertState = 201117, --退出乐谱回想
	UpdateAtlasView = 201118,--更新乐谱图鉴界面
	UpdateAtlasItemRed = 201119,

    --理符
    LeveQuestInfoUpdate = 201200,
	LeveQuestListUpdate = 201201,
	LeveQuestUpdateNPCHudIcon = 201203, -- 更新NPCIcon
	LeveQuestMapUpdate = 201204,		-- 更新NPC地图
	LeveQuestMapEnd = 201205,           -- 移除NPC地图
	LeveQuestHideListWin = 201206,		-- 隐藏交纳一次还是多此选项
	LeveQuestAddAnim = 201207,		    -- 增加理符限额动画
	LeveQuestReduceAnim = 201208,	    -- 减少理符限额动画
	LeveQuestExpUpdate = 201209,		-- 理符职业
	LeveQuestMarkedItem = 201210,		-- 理符标记物品
	LeveQuestCancelMarkedItem = 201211, -- 理符取消标记物品

	-- 商城
	StoreRefreshGoods = 201300, -- 商城商品列表刷新
	StoreRefreshGoodsSelected = 201301, -- 商城商品列表刷新选中
	StoreBuyGoodsDisplay = 201302, -- 商城购买商品展示
	StoreHideNotMatchTips = 201303,
	StoreMailCloseEvent = 201304,
	StoreMysteryBoxRedDotEvent = 201305,	--- 奇遇盲盒上架红点
	StoreMysteryAnimEvent = 201306,	--- 奇遇盲盒Icon动效
	StoreUpdateTabListByTimer = 201307,	--- 奇遇盲盒上架事件 可能要刷新商城界面menu
	StoreUpdateBlindText = 201308,
	StoreUpdateMysterBoxRedDot = 201309,

	-- 战令主界面
	BattlePassBaseInfoUpdate = 201400, --战令基础信息更新
	BattlePassLevelRewardUpdate = 201401, --战令等级奖励更新
	BattlePassTaskUpdate = 201402, -- 战令任务更新
	BattlePassLevelUp = 201403, --战令购买等级刷新
	BattlePassGradeUpdate = 201404, --战令级别更新
	BattlePassLevelRewardItemShow = 201405, --战令奖励item显示
	BattlePassLevelRewardItemHide = 201406, --战令奖励item隐藏
	BattlePassExpUpdate = 201407, -- 战令经验变动
	BattlePassOpeningUp = 201408, -- 战令赛季开放变动

	--region 商店
	InitMallGoodsListMsg = 300000, --初始化商店商品列表刷新
	UpdateMallGoodsListMsg = 300001, --商店商品列表刷新
	ScrollToSelectedGoods = 300002, --滚动到选中的商品
	ScrollToSelectedTab = 300003, --滚动到选中的Tab
	FilterGoods = 300004,--筛选商品
	OpenShop = 300005,--打开商店
	UpdateSerchGoods = 300006, --更新搜索列表
	ShopPlayOutAni = 300007,
	--ScrollToGoods

	--region Army部队
	ArmyUpdateMainView = 300101, --- 刷新部队主界面
	ArmyAddClass = 300102, --增加阶级
	ArmyUpdateClassIcon = 300103, -- 修改阶级图标
	ArmyUpdateClassName = 300104, -- 修改阶级名称
	ArmyDelectClass = 300105, -- 删除阶级
	ArmyHideUI = 300106, -- 关闭部队界面
	ArmySelfArmyIDUpdate = 300107, --自身公会ID更新
	ArmySelfArmyAliasUpdate = 300108, --自身部队简称更新
	ArmySelfArmyEmblemUpdate = 300109, --自身部队队徽更新
	ArmySelfArmyNameUpdate = 300110, --自身部队名更新
	ArmySelfArmyNoticeUpdate = 300111, --自身部队公告更新
	ArmyInfoEditTimeUpdate = 300112, --自身部队信息编辑时间更新
	ArmyExit = 300113, ---部队退出解散时用
	ArmyLevelUpdate = 300114, ---部队等级变化
	ArmySelfArmyAliasUpdateBySelf = 300115, --自身编辑部队简称更新（专用于编辑界面更新）
	ArmySignNumToc = 300116, --部队署名人数变化
	--endregion Army部队

	-- 钓鱼笔记
	FishNoteClockSubscribeChanged = 300201, -- 钓鱼笔记闹钟订阅状态更新
	FishNoteClockListRefresh = 300202, -- 钓鱼笔记闹钟列表更新
	FishNoteSkipLocation = 300203, -- 钓鱼笔记跳转到指定位置
	FishNotesScrollLocationList = 300204, -- 钓鱼笔记滚动到指定位置列表
	FishNoteUnlockListRefresh = 300205, -- 钓鱼笔记解锁列表更新
	FishNoteRefreshGuideList = 300206, -- 钓鱼笔记解锁指定位置
	FishNoteRefreshLocationList = 300207, -- 钓鱼笔记刷新指定位置
	FishNoteRefreshFishData = 300208, -- 钓鱼笔记刷新鱼类信息
	FishNoteNotifyMapInfo = 300209, -- 钓鱼笔记通知地图信息
	FishNoteNotifyChangePointState = 300210, -- 钓鱼笔记通知切换钓点状态
	FishNoteGuideCancelSelect = 300211, -- 钓鱼笔记图鉴取消选中
	FishNoteSearchFinished = 300212, -- 钓鱼笔记搜索完成
	FishNoteSearchFishLocation = 300214, -- 查找可钓指定鱼的地点
	FishNotesScrollClockFishList = 300215, -- 钓鱼笔记闹钟列表滚动到指定位置列表
	FishNotesMapScaleChanged = 300216, --钓鱼笔记地图缩放条值改变时
	FishNoteRefreshWindowState = 300217, --钓鱼笔记刷新窗口期状态

	--收藏品
	OnExchangeRspEvent = 300301,
	SetBtnShutWinVisibleEvent = 300302,

	--采集笔记
	GatheringLogSetMapSpaceAndAnim = 300404,
	GatheringLogPlaceAnimInSearchResult = 300405,
	GatheringLogUpdateSearchResultAnim = 300406,
	GatheringLogUpdateDropDownFilter = 300408,
	GatheringLogSetFiltraSelect = 300409,
	UpdateGatherItemRedDot = 300412, --更新采集物红点
	UpdateTabRedDot = 300413, -- 更新页签的红点
	GatheringLogUpdateHorTabs = 300414, --更新水平页签及下级选中
	GatheringLogSearch = 300415, -- 在采集笔记内快捷搜索
	GatheringLogExitSearchState = 300416, -- 离开搜索状态
	GatheringLogUpdateDropDownProgress = 300417, --刷新当前下拉筛选列表右侧数字

	-- Fate玩法
	FateStart = 300501,
	FateEnd = 300502,
	FateUpdate = 300503,
	FateLateShowLoot  = 300504, -- 延迟显示获取的奖励
	FateQuit = 300505, -- 玩家退出了FATE，可以是手动点击或者走出范围
	FateFinishCondition = 300506, -- FATE完成了目标

	-- Fate图鉴
	FateMapRewardUpdate = 300511,
	FateWorldEventItemClick = 300512,
	FateOnMapSelected = 300513,
	FateOnFateSelected = 300514,
	FateOpenStatisticsPanel = 300515, -- 打开统计界面
	FateCloseStatisticsPanel = 300516, -- 关闭统计界面

	-- 传奇武器
	LegendaryChapterItemClick = 300520,		-- 在切换章节时
	LegendaryMatItemClick = 300521,			-- 在跳转材料时
	LegendaryInnerMatClick = 300522,		-- 在点击材料时
	LegendaryCompletionStatus = 300523,		-- 在查询拥有时
	LegendaryPlayCompletionAnim = 300524,	-- 在强化开始时
	LegendaryCompletionEnd = 300525,		-- 在动画结束时
	LegendaryUpdateRedDot = 300526, 		-- 在更新红点时
	LegendaryUpdateEquipTips = 300527, 		-- 跳进其他界面

	-- 制作笔记
	CraftingLogMakeSucceedBack = 300601,  	-- 制作物品成功
	CraftingLogCancelMake = 300602,			-- 取消收藏物品成功
	CraftingLogHistoryInit = 300603,		-- 初始化制作历史
	CraftingLogCollectInit = 300604,		-- 初始化收藏
	CraftingLogConvenient = 300606,			-- 便捷添加道具开关
	CraftingLogButtonState = 300607,		-- 按键状态通知
	CraftingLogFastSearch = 300609,			-- 快捷搜索
	CraftingSimpleRefreshUI = 300610,		-- 简易制作完成刷新UI
	CraftingSimpleToMake = 300611,			-- 简易制作
	CraftingLogExitSearchState = 300612,    -- 离开搜索状态
	CraftingLogUpdateHorTabs = 300613,      --更新水平页签及下级选中
	CraftingLogUpdateItemAnim = 300614,
	CraftingSimpleFinished = 300615,

	-- 机遇临门通用
	GoldSauserCommMapUpdate = 300701,
	GoldSauserCommMapEnd = 300702,
	GoldSauserCommFinishProBar = 300703,
	GoldActivityMapUpdate = 300704,
	GoldActivityMapEnd = 300705,
	GoldSauserShowInfo = 300706, -- 显示信息
	GoldSauserGameOver = 300707, -- 游戏结束
	LeapOfFaithUpdateScore = 300708, -- 虚景跳跳乐更新奖牌数量
	GoldSauserAirForceGameOver = 300721, -- 空军装甲游戏结束
	GoldSauserStateUpdate = 300722, -- 金碟游戏状态发生改变
	LeapOfFaithGameStart = 300723, -- 跳跳乐开始了
	LeapOfFaithGameEndAndLeave = 300724, -- 跳跳乐结束了，并且离开跳跳乐副本

	-- 空军装甲
	RideShootingWorldStart = 300731, -- 空军装甲副本开始
	RideShootingWorldEnd = 300732, -- 空军装甲副本结束
	RideShootingPlayCameraAnimation = 300733, -- 空军装甲播放相机动画
	RideShootingShowAllAvatarPart = 300734, -- 空军装甲播放相机动画
	-- 演奏
	MusicPerformanceUISelect = 300801,		-- 选择乐器
	MusicPerformancePerformDataChanged = 300802,	-- 演奏数据改变
	MusicPerformanceToneOffset	= 300803,			-- 演奏音调偏移
	MusicPerformanceMetronomeSettingUpdate = 300804,-- 节拍器设置更新
	MusicPerformanceEnsembleConfirm = 300805,		-- 合奏确认
	MusicPerformanceCommonSettingUpdate	= 300806,	-- 演奏通用设置更新
	MusicPerformanceEnsembleWorkStart	= 300807,	-- 合奏Work开启
	MusicPerformanceEnsembleWorkClear	= 300808,	-- 合奏Work被中断

	--MusicPerformanceSelfEnsembleStart = 300851,		-- 本地合奏开始
	--MusicPerformanceAssistantUIItemRefresh = 300852,	-- 演奏助手UI掉落更新
	MusicPerformanceAssistantItemScoreUpdate = 300853,	-- 演奏助手单项积分更新
	MusicPerformanceAssistantPause = 300854,			-- 演奏助手暂停
	MusicPerformanceAssistantResume = 300855,			-- 演奏助手恢复
	MusicPerformanceAssistantStop = 300856,				-- 演奏助手停止
	MusicPerformanceAssistantDone = 300857,				-- 演奏助手结束
	MusicPerformanceAssistantComboChanged = 300858,		-- 演奏助手Combo数量变更
	MusicPerformanceAssistantTotalScoreChanged = 300859,		-- 演奏助手得分变更
	MusicPerformanceAssistantItemUpdate	= 300860,		-- 演奏助手单项更新
	--MusicPerformanceAssistantItemFocus	= 300861,		-- 提示需要按下的按键
	MusicPerformanceEntityStart	= 300862, --角色演奏状态开始
	MusicPerformanceEntityEnd	= 300863, --角色演奏状态结束

	-- 宠物
	CompanionNewListUpdate = 300901,	-- 宠物[新]标记列表更新
	CompanionFavouriteListUpdate = 300902,	--宠物偏好列表更新
	CompanionCallingOutUpdate = 300903,	-- 宠物召唤召回更新
	CompanionQueryUpdate = 300904, -- 宠物信息更新
	CompanionArchiveFilterUpdate = 300905,	-- 宠物图鉴过滤选项更新
	CompanionArchiveModelStartRotate = 300906,	-- 宠物图鉴模型开始旋转
	CompanionArchiveModelEndRotate = 300907,	-- 宠物图鉴模型结束旋转
	CompanionArchiveNewListUpdate = 300908,	-- 宠物图鉴[新]标记列表更新

	--陆行鸟
	ChocoboRaceGameBegin = 301001,
	ChocoboRaceGamePlayBeginAni = 301002,
	ChocoboRaceStaminaChange = 301003,
	ChocoboRaceHUDUpdate = 301004,
	ChocoboFree = 301005,
	ChocoboSkillOp = 301006,
	ChocoboMainTabSelect = 301007,
	ChocoboRacerIDChange = 301008,
	ChocoboOverviewItemSelect = 301009,
	ChocoboGenealogyItemSelect = 301010,
	ChocoboRacerMapUpdate = 301011,
	ChocoboRacerMapClear = 301012,
	ChocoboRaceItemMapUpdate = 301013,
	ChocoboRaceItemMapClear = 301014,
	ChocoboMaxLevelChange = 301015,
	ChocoboNameTaskRevert = 301016,
	ChocoboRaceGameReady = 301017,
	ChocoboRaceGameGoal = 301018,
	ChocoboRaceGameQuerySuc = 301019,

	-- 陆行鸟装甲图鉴
	ChocoboCodexArmorUpdate = 301050,

	-- 金碟小游戏
	DetailMiniGameAutoSelectDifficulty = 301101,  	-- 金碟小游戏自动选择难度
	DetailMiniGameRestart = 301102,  	-- 金碟小游戏确认翻倍挑战
	DetailMiniGameEnter = 301103, -- 金碟小游戏进入协议
	MiniGameCuffSubViewOnShow = 301104, -- 重击吉尔伽美什 显示9个Blow的Canvas
	MiniGameCuffHide = 301105,	-- 重击吉尔伽美什 隐藏9个Blow的Canvas
	MonsterTossEndEvent = 301106, -- 当怪物篮球小游戏结束
	MiniGameCuffShowPunchResult = 301107,	-- 重击吉尔伽美什 展示结果
	MiniGameMainPanelPlayAnim = 301108,
    DetailMooglePawsEndMove = 301109, -- 莫古抓球机停止移动
	MiniGameCuffMainPlayAnim = 301110,
	MiniGameMajorEnterStartMode = 301111, -- 小游戏主角进入开始模式
	MiniGameMajorEnterQuitMode = 301112,  -- 小游戏主角进入离开模式

	--搭档系统
	BuddyQueryInfo = 301201, --查询搭档系统数据
	BuddyUpdateStatus = 301202, --搭档buff刷新
	BuddyUpdateAbility = 301203, --搭档能力页刷新
	BuddyCDOnTime = 301204, --CD倒计时
	BuddyDyeUpdate = 301205, --染色刷新
	BuddyEquipmentUpdate = 301206, --装备刷新
	BuddyRenameSuccess = 301207, --取名成功
	BuddyTickTime = 301208, --搭档存在时间刷新
	--endregion

	-- 时尚品鉴
	OnAppearanceTrackStateChanged = 301301, --装备追踪状态变更
	OnFashionNPCSelectedChanged = 301302, --时尚达人切换
	OnFashionEvaluationStart = 301303, -- 评分开始
	OnFashionNPCLoadingProgress = 301304, -- 时尚达人加载进度
	OnFashionEvaluationTrackUpdate = 301305, -- 追踪相关

	-- 头顶气泡
	ShowSpeechBubble = 302000, --显示
	HideSpeechBubble = 302001, --隐藏
	ShowSpeechBubbleAll = 302002, --显示所有

	-- 寻宝解读宝图成功
	TreasureHuntGetItem = 303001,
	TreasureHuntShowSkillBtn = 303002,
	TreasureHuntDropItem = 303003,
	TreasureHuntAddMapMine = 303004,
	TreasureHuntRemoveMapMine = 303005,
	TreasureHuntUpdateMapMine = 303006,
	TreasureHuntClearMapMine = 303007,
	TreasureHuntBreakAnim = 303008,

	UpdateScore = 304100,
	PlayGetScoreAni = 304101,

	--军队军票
	CompanySealUpdateTaskInfo = 304200,
	CompanySealUpdateRareChoseList = 304201,
	CompanySealCancelRareChosed = 304202,
	CompanySealUpdateRareView = 304203,
	CompanySealPlayLvUPAni = 304204,
	CompanySealPlayUpdateBtnState = 304205,
	CompanySealPlaySubAni = 304206,
	CompanySealPlaySubHQItem = 304207,
	CompanySealJionGrandCompany = 304208,
	CompanySealRankUp = 304209,

	--神秘商人
	MysteryMerchantUpdateNPCHudIcon = 304300,

	--光之启程
	DepartOfLightBaseInfoUpdate = 304400,
	DepartEntranceOpened = 304401, -- 入口开放
	DepartEntranceUpdate = 304402, -- 入口关闭
	OnDepartRecycleViewVisibleChange = 304403, -- 回收界面显隐

	-- 拍照
	PhotoStart = 305001,
	PhotoEnd = 305002,
	TakePhotoSucc = 305003,
	PhotoSeltEntChg = 305004,


	PhotoViewResetDarkEdge = 305051,
	PhotoViewHideDetailView = 305052,

	-- 巡回乐团
	TouringBandAreaEnter = 306001,
	TouringBandListenCountChange = 306002,
	TouringBandTargetMarkIconChanged = 306003,
	TouringBandMajorHudChanged = 306004,
	TouringBandStatesChange = 306005,
	TouringBandRefreshCherringBtnVisible = 306006,
	TouringBandForceExitInteractive = 306007, -- 强制退出交互状态
	TouringBandStatesNotify = 306008, -- 状态改变的通知，比TouringBandStatesChange晚

	--问卷调查
	ShowMURSurveyEntrance = 307001,
	ShowMURSurveyRedDot = 307002,

	-- 风脉泉
	AetherCurrentMapFlyOpen = 307101,
	AetherCurrentSingleActive = 307102,

	-- 金碟手册
	ExcuteAsyncInfoFromOtherModule = 307201,
	GoldSauserCactusShowOrHide = 307202,
	GoldSauserSelectedEntrance = 307203,

	-- 陆行鸟喂食Qte小游戏
	ChocoboFeedingQteFinishNotify = 307301,
	ChocoboFeedingQteRevert = 307302,
	-- 时尚配饰
	FashionDecorateUpdateData = 307401,
	FashionDecorateShowThirdPersonAll = 307402,
	-- 对战资料
	PVPSeriesRewardDataUpdate = 307501,	-- 星里路标奖励数据更新
	PVPSeriesDataUpdate = 307502,	-- 星里路标数据更新

	-- PVP决斗
	PVPDuelInviteTimeout = 307601,	-- PVP决斗申请超时
	PVPDuelAccept = 307602,	-- PVP决斗成立

	--零式排行榜
	SavageRankUpdateData = 307701,  --零式排行榜更新
	SavageRankUpdateDrop= 307702,  --零式排行榜更新下拉框

    -- 野外探索
	FateArchiveDataUpdate = 307702, -- 当拉去到Fate数据

	-- 分享功能
	ShareOpsActivitySuccess = 307801, 	-- 活动分享成功
	ShareWithoutQRCode = 307802, 		-- 分享不带二维码

	-- 探索笔记
	EnterTheDetectedTargetRange = 307900, -- 探索笔记普通全收集进入检测到的标记范围
	ExitTheDetectedTargetRange = 307901, -- 探索笔记普通全收集离开检测到的标记范围
	LoadWildBoxRangeCheckData = 307902, -- 野外宝箱加载范围检测数据
	RemoveWildBoxRangeCheckDataByBoxOpened = 307903, -- 野外宝箱移除范围检测数据
	AddTouringBandRangeCheckData = 307904, -- 巡回乐团添加范围检测数据
	RemoveTouringBandRangeCheckData = 307905, -- 巡回乐团移除范围检测数据
	LoadMysterMerchantRangeCheckData = 307906, -- 神秘商人加载范围检测数据
	RemoveMysterMerchantRangeCheckData = 307907, -- 神秘商人移除范围检测数据
	TimeToUpdateMapPointPerfectCond = 307908, -- 定时器更新当前打开地图点位完美状态
	NoteSinglePerfectActive = 307909, -- 单个点位完美探索通知事件

	-- 救助
	OnRescureInfo = 308000,
	OnRescrueNotify = 308001,
	OnBuffUpdate = 308002,


	-- 语音
	GVoiceBanned = 309001,
	-- ETC.
	GVoiceEventIDEnd = 30909,

	-- Android/iOS平台
	MicPermissionNotify = 309100,
	StoragePermissionNotify = 309101,
	ApplicationWillDeactivate = 309102,
	ApplicationHasReactivated = 309103,

	--每个系统用一个ID段
	--15700

	--15800
	--15900
	--16000
	--16100
	--16200
	--16300
	--16400
	--16500
	--16600
	--16700
	--16800
	--16900
	--17000
	--17100
	--17200
	--17300
	--17400
	--17500
	--17600
	--17700
	--17800
	--17900
	--18000
	--18100
	--18200
	--18300
	--18400
	--18500
	--18600
	--18700
	--18800
	--18900
	--19000
	--19100
	--19200
	--19300
	--19400
	--19500
	--19600
	--19700
	--19800
	--19900
	--20000
	--20100
	--20200
	--20300
	--20400
	--20500
	--20600
	--20700
	--20800
	--20900
	--21000
	--21100
	--21200
	--21300
	--21400
	--21500
	--21600
	--21700
	--21800
	--21900
	--22000
	--22100
	--22200
	--22300
	--22400
	--22500
	--22600
	--22700
	--22800
	--22900
	--23000
	--23100
	--23200
	--23300
	--23400
	--23500
	--23600
	--23700
	--23800
	--23900
	--24000
	--24100
	--24200
	--24300
	--24400
	--24500
	--24600
	--24700
	--24800
	--24900
	--25000
	--25100
	--25200
	--25300
	--25400
	--25500
	--25600
	--25700
	--25800
	--25900
	--26000
	--26100
	--26200
	--26300
	--26400
	--26500
	--26600
	--26700
	--26800
	--26900
	--27000
	--27100
	--27200
	--27300
	--27400
	--27500
	--27600
	--27700
	--27800
	--27900
	--28000
	--28100
	--28200
	--28300
	--28400
	--28500
	--28600
	--28700
	--28800
	--28900
	--29000
	--29100
	--29200
	--29300
	--29400
	--29500
	--29600
	--29700
	--29800
	--29900
	--30000
	--30100
	--30200
	--30300
	--30400
	--30500
	--30600
	--30700
	--30800
	--30900
	--31000
	--31100
	--31200
	--31300
	--31400
	--31500
	--31600
	--31700
	--31800
	--31900
	--32000
	--32100
	--32200
	--32300
	--32400
	--32500
	--32600
	--32700
	--32800
	--32900
	--33000
	--33100
	--33200
	--33300
	--33400
	--33500
	--33600
	--33700
	--33800
	--33900
	--34000
	--34100
	--34200
	--34300
	--34400
	--34500
	--34600
	--34700
	--34800
	--34900
	--35000
	--35100
	--35200
	--35300
	--35400
	--35500
	--35600
	--35700
	--35800
	--35900
	--36000
	--36100
	--36200
	--36300
	--36400
	--36500
	--36600
	--36700
	--36800
	--36900
	--37000
	--37100
	--37200
	--37300
	--37400
	--37500
	--37600
	--37700
	--37800
	--37900
	--38000
	--38100
	--38200
	--38300
	--38400
	--38500
	--38600
	--38700
	--38800
	--38900
	--39000
	--39100
	--39200
	--39300
	--39400
	--39500
	--39600
	--39700
	--39800
	--39900
	--40000
	--40100
	--40200
	--40300
	--40400
	--40500
	--40600
	--40700
	--40800
	--40900
	--41000
	--41100
	--41200
	--41300
	--41400
	--41500
	--41600
	--41700
	--41800
	--41900
	--42000
	--42100
	--42200
	--42300
	--42400
	--42500
	--42600
	--42700
	--42800
	--42900
	--43000
	--43100
	--43200
	--43300
	--43400
	--43500
	--43600
	--43700
	--43800
	--43900
	--44000
	--44100
	--44200
	--44300
	--44400
	--44500
	--44600
	--44700
	--44800
	--44900
	--45000
	--45100
	--45200
	--45300
	--45400
	--45500
	--45600
	--45700
	--45800
	--45900
	--46000
	--46100
	--46200
	--46300
	--46400
	--46500
	--46600
	--46700
	--46800
	--46900
	--47000
	--47100
	--47200
	--47300
	--47400
	--47500
	--47600
	--47700
	--47800
	--47900
	--48000
	--48100
	--48200
	--48300
	--48400
	--48500
	--48600
	--48700
	--48800
	--48900
	--49000
	--49100
	--49200
	--49300
	--49400
	--49500
	--49600
	--49700
	--49800
	--49900
	--50000
	--50100
	--50200
	--50300
	--50400
	--50500
	--50600
	--50700
	--50800
	--50900
	--51000
	--51100
	--51200
	--51300
	--51400
	--51500
	--51600
	--51700
	--51800
	--51900
	--52000
	--52100
	--52200
	--52300
	--52400
	--52500
	--52600
	--52700
	--52800
	--52900
	--53000
	--53100
	--53200
	--53300
	--53400
	--53500
	--53600
	--53700
	--53800
	--53900
	--54000
	--54100
	--54200
	--54300
	--54400
	--54500
	--54600
	--54700
	--54800
	--54900
	--55000
	--55100
	--55200
	--55300
	--55400
	--55500
	--55600
	--55700
	--55800
	--55900
	--56000
	--56100
	--56200
	--56300
	--56400
	--56500
	--56600
	--56700
	--56800
	--56900
	--57000
	--57100
	--57200
	--57300
	--57400
	--57500
	--57600
	--57700
	--57800
	--57900
	--58000
	--58100
	--58200
	--58300
	--58400
	--58500
	--58600
	--58700
	--58800
	--58900
	--59000
	--59100
	--59200
	--59300
	--59400
	--59500
	--59600
	--59700
	--59800
	--59900
	--60000
	-- 去掉之前ID分组功能（因为仓库统一了，不用多个仓库同步，合并冲突容易解决，没有必要在分组，定义ID更方便）
	-- 新加ID可以从小到大，按预留ID段使用
}

setmetatable(EventID, { __index = _G.UE.EEventID })

EventID.IDToName = IDToName

return EventID
