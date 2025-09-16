--
-- Author: anypkvcai
-- Date: 2020-08-12 16:07:27
-- Description: 每个系统预留100个值 例如：Test从1001开始 Login就从1101开始 其他系统依次加100
--

---@class UIViewID
local UIViewID = {
	--Root
	RootView = 1,
	ClickFeedbackView = 2,
	WaterMark = 3,
	NetworkReconnectTips = 4,
	NetworkReconnectMsgBox = 5,
	NetworkWaiting = 6,
	HUDView = 7,
	HardLockEffect = 8,

	SampleMain = 10,
	-- --Loading
	-- Loading = 100,

	--Loading
	LoadingDefault = 1001, -- 黑屏转菊花
	LoadingMainCity = 1002, -- 主城Loading
	LoadingOther = 1003, -- 其他Loading

	--Login
	LoginMain = 1101,
	LoginServerList = 1104,
	LoginServerListItem = 1105,

	--NewLogin
	LoginRoleRender2D = 1107,
	LoginFixPage = 1106,
	LoginCreateRaceGender = 1108,	--选种族、性别
	LoginCreateTribe = 1109,		--选部族
	LoginProgressWin = 1110,		--顶部进度条的放大界面
	LoginRoleBirthday = 1111,		--选创建日
	LoginRoleGod = 1112,			--选守护神
	LoginRoleProf = 1113,			--选守职业
	LoginRoleName = 1114,			--输入昵称
	LoginDemoSkill = 1115,			--技能演示
	LoginRoleShowPage = 1116,		--试穿、动作、环境背景
	LoginSelectRoleNew = 1117,
	LoginAgeAppropriate = 1118,		-- 适龄提醒
	LoginLicensePrivacy = 1119,		-- 隐私权限

	LoginCreateAppearance = 1120,   -- 选择外貌
	LoginCreateAppearanceCustomize = 1121, -- 自定义外貌
	LoginCreateSaveWin = 1122, -- 存档、读档弹框
	-- HairCutRoleRender2D = 1123,		--理发屋专用，替代LoginRoleRender2D
	FantasiaFinishWin = 1124,		--幻想药专用，完成编辑弹窗
	LoginCreateMakeName = 1125,		--后置的角色命名ui，在sequence中的

	--局内通用登录场景的ui
	CommonLoginMapMainPanel = 1126,

	NcutLoginLogoPage = 1127,		--ncut用的logo
	-- GMLoginCreateMakeName = 1128,		--后置的角色命名ui;GM用

	--Bag
	BagPanel = 1130,
	BackpackMain = 1131,
	BackpackWareRename = 1132,
	BackpackItemTips = 1133,
	BagMain = 1151,
	BagDepotRename = 1153,
	BagExpandWin = 1154,
	DepotExpandWin = 1155,
	BagDrugsSetPanel = 1156,
	CommGetWayItem = 1157,
	BagDepotTransfer = 1158,
	BagItemActionTips = 1159,
	BagItemListActionTips = 1160,
	BagItemToNQTips = 1161,
	UseRenameCard = 1162,
	PersonFormerName = 1164,
	BagTreasureChestWin = 1165,
	UpgradeMainPanelView = 1166,
	--Main
	MainPanel = 1201,
	SkillButton = 1202,
	GMMain = 1203,
	FOVView = 1204,
	SimplePerf = 1205,
	MainSkillStorage = 1206,
	SkillCancelJoyStick = 1207,
	MainSkillButton = 1208,	--废弃
	GMButton = 1209,
	GMFilterItem = 1210,
	GMSlider = 1211,
	GMSwitch = 1212,
	MainSelectDisplay = 1213,
	MainUIMoveMask = 1214,
	CfgMainPanel = 1215,
	-- FishPanel = 1216,
	--FishBaitItem = 1217,	废弃
	-- FishBackpackPanel = 1218,
	-- FishBiteTips = 1219,
	MonsterSkillTest = 1220,
	GMMainMinimizationHud = 1221,
	ItemButton = 1222,
	HomePageItem = 1223,
	DragHud = 1224,
	GMMainHud = 1225,
	GMMonsterAIInfo = 1226,
	Main2ndPanel = 1227,
	GMTargetInfo = 1228,
	CommonDropTips = 1229,
	Main2ndHelpInfoTips = 1230,
	GMPanel = 1231,
	GMVfxInfo = 1232,
	GMFloat = 1300, -- GM漂浮用的，弄的等级会比较高，方便其他的显示
	--PWorld
	PWorldMainPanel = 1301,
	PWorldInfoWinPopUp = 1302,
	PWorldStageInfoPanel = 1303,
	PWorldConfirm = 1305,
	--PWorldMoviePlayer = 1306,
	-- 1307
	PWorldWarning = 1308,
	PWorldAreaImageTest = 1309,
	PWorldMainlinePanel = 1311,
	PWorldEntranceSelectPanel = 1312,
	PWorldMatchDetail = 1313,
	PWorldEntrancePanel = 1314,
	PWorldSettingDetailPanel = 1315,
	--  = 1316,					left
	PWorldProBarItemPanel = 1317,
	GetLevelRecordListPanel = 1318,
	PWorldTaskSetUpListItem = 1319,
	PWorldDirectorListPannel = 1320,

	-- PWorldQuest
	PWorldQuestMenu 		= 1321,
	SidebarGiveUpTaskWin	= 1322,
	PWorldExitTaskWin	= 1323,
	PWorldVoteExpelResult 	= 1324,
	PWorldVoteBest 			= 1325,
	PWorldAddMember 		= 1326,
	--						= 1327, --left

	-- Entourage
	PWorldEntouragePanel 	= 1331,
	EntourageConfirm 		= 1332,

	-- PWorldTeaching
	PWorldTeachingPanel 		= 1341,
	PWorldTeachingContentPanel 	= 1342,
	CommTextTipsBigStrongItem 	= 1343,
	PWorldSkillGuidancePanel 	= 1344,

	PWorldBranchPanel = 1351,
	PWorldBranchWin = 1352,

	--MessageBox
	MessageBox = 1401,

	--MessageTips
	CommonTips = 1501,
	ErrorTips = 1502,
	AreaTips = 1503,
	NPCTalkTips = 1504,
	ActiveTips = 1505,
	MissionTips = 1506,
	BottomTips = 1507,
	LevelUpTips = 1508,
	NPCTalkCommon = 1509,
	ItemTips = 1510,
	EquipTips = 1511,
	DropTips = 1512,
	GatherChainTips = 1513,
	ItemTipsStatus = 1514,
	CommonPopupInput = 1515,
	CommonPopupMultiLineInput = 1516,
	FateTips = 1517,
	CurrencyTips = 1519,
	BagItemTips = 1520,
	GatherSkillTip = 1521,
	CommonRunningTips = 1522,  -- 运营全服通告
	InfoAreaTips = 1523,
    InfoFateTips = 1524, -- 新的 Fate 提示
	InfoCountdownTipsView = 1525, -- 新的通用倒计时
    QuestInfoTips = 1526, -- 新的任务提示
    NewNPCTalkTips = 1527,
	InfoTextTips = 1528,
	InfoMissionTips = 1529,
	InfoAreaTipsInCutScene = 1530,
	InfoMistTips = 1531,
	InfoCrystalTips = 1532,
	InfoPVPColosseumTips = 1533,
	InfoPVPColosseumTeamTips = 1534,
	InfoPVPColosseumCommand = 1535,
	InfoPVPReviveTimeTips = 1536, -- PVP死亡复活提示信息
	ActiveSystemErrorTips = 1537,
	InfoDoubtLevelTips = 1538,
	StoryTips = 1539,
	InfoCountdownTipsForPVPView = 1540, -- PVP用的倒计时
	InfoPVPColosseumKillTips = 1541,

	--Team
	TeamApply = 1602,
	--  = 1603,
	TeamConfirm = 1604,
	TeamMenu = 1605,
	TeamInvite = 1606,
	TeamMainPanel = 1607,
	TeamCheckPlayerDetail = 1608,
	TeamAttriAddInfor = 1609,
	TeamRecruitEdit = 1610,
	TeamRecruitCode = 1611,
	TeamRecruitContentSelect = 1612,
	TeamRecruitQuickInput = 1613,
	TeamRecruitEditFunc = 1614,
	TeamRecruitDetail = 1615,
	TeamRollPanel = 1616,
	TeamDistributeItem = 1617,
	TeamRollTreasureBox = 1618,
	TeamBeginsCDWin = 1619,
	TeamBeginsCDTips = 1620,
	TeamSignsMainPanel = 1621,
	SceneMarkersMainPanel = 1622,
	MainTeamChatTip = 1623,
	TeamRollValuablesTips = 1624,
	TeamRecruitFilter = 1625,
	--QTE
	QTEMain = 1701,

	--Dialogue
	DialogueMainPanel = 1730,
	--StaffRoll
	StaffRollMainPanel = 1731,
	--剧情回顾
	NpcDialogueMainPanel = 1733,
	DialogHistoryLow = 1734,
	--ShowCGMainPanel
	CGMovieMainPanel = 1735,
	Story3DEffectPanel = 1736,

	--Deadth
	BeReviveView = 1802,
	BeDeathView = 1803,
	DeathFloatButton = 1804,
	ReviveFloatButton = 1805,

	--Common
	CommonMaskPanel = 1901,
	CommPlayerHeadSlotItem = 1902,
	COmmPlayerProfSlotItem = 1903,
	CommonMsgBox = 1904,
	CommonFadePanel = 1905,
	CommonLongMsgBox = 1906,
	CommonRewardPanel = 1907,
	CommonCostBox = 1908,
	CommDropDownListNew = 1909,
	CommMiniKeypadWin = 1910,
	CommonMsgBoxMustClick = 1911,
	CommInputCommitButton = 1912,
	SettingDropDownListNew = 1913,

	----Input
	--InputPanel = 2001,

    -- NPC
    SpeechBubble = 2000,
    SpeechBubblePanel = 2001,
	NpcTalkBubbleItem = 2002,
	NpcTalkDialoguePanel = 2004,
	NpcTalkTaskTips = 2006,
	NpcTalkTopInfoItem = 2007,
	NpcTalkMainPanel = 2003,

	--Test
	TATestPanel = 2104,
	FieldTestPanel = 2105,
	FieldTestMinimizationView = 2106,
	RecordPlayControlPanel = 2107,
	MultiLanguageTestPanel = 2108,
	NarrativeTestPanel = 2109,
	--MagicCard
	MagicCardEnterConfirmPanel = 2201,
	MagicCardMainPanel = 2202,
	MagicCardItemView = 2203,
	MagicCardGameFinishPanel = 2204,
	MagicCardEditGroupView = 2205,
	MagicCardCommMsgBoxView = 2206,
	MagicCardEditGroupNameView = 2207,
	MagicCardSaveReminderView = 2208,
	MagicCardFirstSeenCardView = 2209,
	MagicCardGameRuleView = 2210,
	MagicCardEditPanel = 2211,
	MagicCardPrepareMainPanel = 2212,
	MagicCardBigCardItem = 2213, -- 拖动的卡牌显示
	MagicCardRulePanelView = 2214, -- 幻卡对局的规则详情界面
	MagicCardShowGetWayView = 2215, -- 幻卡结算界面，提示增强幻卡的界面
	MagicCardCollectionMainPanel = 2220, -- 幻卡图鉴

	MagicCardTourneySignUpView = 2230, -- 幻卡大赛报名
	MagicCardTourneyDetailPanel = 2231, -- 幻卡大赛详情
	MagicCardTourneyEffectSelectView = 2232, -- 大赛效果选择
	MagicCardRewardView = 2233, -- 大赛奖励结算界面
	MagicCardTourneyTipView = 2234, -- 大赛通用提示
	MagicCardTourneyStageTipView = 2235, -- 阶段提示
	MagicCardTourneyMatchConfirmView = 2236, -- 匹配确认
	MagicCardTourneyStageDetailView = 2237, -- 阶段效果详情
	MagicCardStageSettlmentView = 2238, --阶段结算界面
	MagicCardTourneyRankView = 2239, -- 大赛排名
	PWorldCardsMatchPanel = 2240, --副本玩法界面匹配入口

	CollectionAwardPanel = 2250, -- 图鉴收集奖励
	--Quest
	QuestLogMainPanel = 2301,
	QuestAcceptTips = 2302,
	QuestPropPanel = 2303,
	NewQuestPropPanel = 2304,

	--Chat
	ChatMainPanel = 2351,
	ChatSettingPanel = 2352,
	ChatHyperlinkPanel = 2353,
	ChatNewbieMemberPanel = 2354,

	--Interactive
	EntranceCommonItem = 2401,
	FunctionCommonItem = 2402,
	FunctionGatherItem = 2403,
	SingBar = 2404,
	InteractiveMainPanel = 2405,
	SingBarQuestUseItem = 2406,
	SingBarAttuning = 2407,
	DialogCommonItem = 2408,

	SelectMonsterItem = 2410,	--Interactive: SelectMonster
	SelectMonsterMainPanel = 2411,

	GatheringJobPanel = 2412,	--新版采集交互面板
	GatherDrugSkillPanel = 2413,--采集喝药技能按钮

	SkillExclusiveProp = 2414,  -- 扩展技能面板(目前仅用于玩法技能)

	NewMainSkill= 2415,  -- 技能面板

	--Equipment
	EquipmentMainPanel = 2501,
	EquipmentStrongest = 2502,
	EquipmentSuitRepair = 2503,
	EquipmentRepair = 2504,
	MagicsparInlay = 2505,
	MagicsparInlayTips = 2506,
	CameraModify = 2507,
	CurrencySummary = 2508,
	MagicsparInlayMainPanel = 2509, -- 新的魔晶石界面
	MagicsparSucceedTips = 2510,
	CurrencyConvertWin = 2511,
	EquipmentExchangeWinView = 2512,
	EquipmentSwitchWinView = 2513,
	EuipmentImproveWinView = 2514,
	MagicsparSwitchPanel = 2515, -- 魔晶石切换装备面板

	EmotionMainPanel = 2601, -- 情感动作主界面（已废弃）
	EmotionUsingTips = 2602, -- 情感动作头顶提示的气泡tips
	EmoActRulesWin   = 2603, -- 情感动作帮助提示窗口

	--Collection 收藏品 采集
	CollectionPanel = 2701,
	CollectionSkillBtn = 2702,
	CollectionPassiveSkillBtn = 2703,
	GatheringJobSkillPanel = 2704,   --新版采集收藏品面板

	--社交
	SocialMainPanel = 2800,

	--好友
	FriendGroupManageWin = 2801,
	FriendScreenerWin = 2802,

	--通讯贝
	LinkShellCreateWin = 2810,
	LinkShellJoinWin = 2811,
	LinkShellActivityWin = 2812,
	LinkShellRecruitSetWin = 2813,
	LinkShellBlackListWin = 2814,
	LinkShellInviteWin = 2815,
	LinkShellNewsWin = 2816,
	LinkShellManageWin = 2817,
	LinkShellScreenerWin = 2818,

	-- 天气预报
	WeatherForecastMainPanel = 2901,
	WeatherForecastTips = 2902,

	--微彩
	MiniCactpotJoinMsgBox = 3001,
	MiniCactpotMainFrame = 3002,
	MiniCactpotRewardTip = 3003,

	-- Map
	MiddleMapPanel = 3101,
	WorldMapPanel = 3102,
	WorldMapSettingPanel = 3103,
	WorldMapPlaceMarkerPanel = 3104,
	WorldMapTransferPanel = 3105,
	WorldMapMarkerTipsList = 3106,
	WorldMapMarkerTipsTransfer = 3107,
	WorldMapMarkerFateStageInfoPanel = 3109,
	WorldMapMarkerTipsTarget = 3110,
	WorldMapMarkerTipsChocoboTransport = 3111,
	WorldMapMarkerTipsFollow = 3112,
	WorldMapMarkerPlayStyleStageInfo = 3113,
	WorldMapSetMarkPanel = 3114,
	WorldMapSendMarkWin = 3115,
	WorldMapUsePortal = 3116, -- 传送网使用券

	-- 宝箱
	TreasureOperatePanel = 3201,

	-- Adventrue
	AdventruePanel = 3301,
	AdventureCompletionPanel = 3304,
	AdventrueDetailPanel = 3305,

	--坐骑
	MountPanel = 3400,
	MountArchivePanel = 3401,
	MountSpeedPanel = 3402,
	MountSpeedWinPanel = 3403,
	MountCustomMadePanel = 3404,


	---- begin 生产职业相关---------
	-- AlchemistMainPanel = 3500,			--old tmp bp
	CrafterMainPanel = 3501,			--所有职业通用的，共用的部分（左侧、右下技能、右上关闭）
	CrafterStateTips = 3502,			--失活、混乱等事件的tips
	CrafterSkillTips = 3503,			--生产技能tips
	CrafterDetailsPanel = 3504,         --生产职业玩法详情
	--炼金
	CrafterAlchemistMainPanel = 3511,	--炼金主界面
	CrafterBottleItem = 3512,			--炼金催化剂拖拽的界面
	-- 刻木匠
	CrafterCarpenterMainPanel = 3513,   -- 刻木匠主界面
	-- 锻铁
	CrafterBlacksmithMainPanel = 3514,  -- 锻铁匠主界面
	-- 雕金
	CrafterGoldsmithMainPanel = 3515,   -- 雕金匠主界面
	-- 铸甲
	CrafterArmorerMainPanel = 3516,     -- 铸甲匠主界面
	-- 烹饪
	CrafterCulinarianMainPanel = 3517,  -- 烹调师主界面
	--裁衣
	CrafterWeaverMainPanel = 3518,      -- 裁衣匠主界面
	CrafterWeaverNeedleItem = 3519,     -- 裁衣匠拖拽界面
	--捕鱼人
	FishMainPanel = 3520,               -- 捕鱼人界面
	FishReleaseTipsPanel = 3521,        -- 捕鱼人放生界面
	FishBiteBagPanel = 3522,            -- 捕鱼人鱼饵背包界面
	FishRarefiedTipsPanel = 3524,       -- 捕鱼人收藏品界面
	-- 制革
	CrafterLeatherworkerMainPanel = 3523, -- 制革匠主界面
	---- end 生产职业相关---------

	--region 商店
	--商店
	ShopMainPanelNewView = 3601,
	ShopSearchPageView = 3602,
	ShopSearchResultPanelView = 3603,
	ShopExchangeWinView = 3604,
	ShopCurrencyTipsView = 3605,
	ShopInletPanelNewView = 3606,
	ShopMainPanelView = 3607,
	ShopBuyPropsWinNewView = 3608,
	ShopExchangeWinNew = 3609,
	ShopInletPanelView = 3610,
	ShopBuyPropsWinView = 3611,
	--endregion 商店

	--Fate
	FateFinishPanel = 3700,
	FateArchiveMainPanel = 3710,
	FateArchiveRewardWin = 3711,
	FateEventStatisticsPanel = 3712,
	FateEventStatsDetialPanel = 3713,
	FateItemSubmitPanel = 3720,
	FateActivityResultPanel = 3721, --Fate开服活动结算界面
	FateEmoTipsPanelView = 3722, --Fate活动用的专用情感头顶图标
	FateCelebrateFinishPanel = 3723, -- 庆典活动中，企鹅BOSS的结算界面

	--SDK Test
	SDKMainPanel = 3800,

	-- 设置
	Settings 		= 3900,
	SettingsColor	= 3901,
	SettingsVoiceResPanel = 3902,
	SettingsPkgDownLoadPanel = 3903,
	CDKeyExchangeView = 3904,
	SettingsFPSMode = 3905,
	--省电模式
	PowerSavingMode = 3920,

	-- 通用留言板
	MessageBoardPanel = 4000,
	MessageBoardPublishWin = 4001,

	-- 充值
	RechargingMainPanel = 4100,
	RechargingBgModelPanel = 4101,
	RechargingRewardWin = 4102,
	RechargingServiceWin = 4103,
	RechargingHelpWin = 4104,
	RechargingGiftPanel = 4106,
	RechargingVoucherWin = 4107,

	-- 在线状态
	OnlineStatusSettingsPanel = 4200,
	OnlineStatusSettingsTips = 4201,

	--个人信息
	PersonInfoMainPanel = 4300,
	PersonInfoSimplePanel = 4301,
	PersonInfoHeadPanel = 4302,
	PersonInfoPerferredProfPanel = 4303,
	PersonInfoGameStylePanel = 4304,
	PersonInfoHoursPanel = 4305,
	PersonInfoSignPanel = 4306,
	PersonInfoArmyPanel = 4307,
	PersonHeadMainPanel = 4408,
	PersonInfoHeadHistoryPanel = 4409,
	PersonInfoSetTipsPanel = 4310,

	--个人信息（肖像）
	PersonPortraitMainPanel = 4400,
	PersonPortraitSaveSetWin = 4401,

	--举报
	ReportPlayerPanel = 4500,
	ReportPanel = 4501,
	ReportTips = 4502,

	--侧边栏
	SidebarMain = 4600,
	SidebarLeft = 4601,
	SidebarCommon = 4602,
	SidebarTeamInvite = 4603,
	SidebarFishClock = 4604,
	SidebarPrivateChat = 4605,

	--侧边弹出框
	SidePopUpEasyUse = 4610,

	--侧边穿戴任务栏
	SidebarTaskEquipmentWin = 4620,

	--交易所
	MarketMainPanel = 4701,
	MarketOnSaleWin = 4702,
	MarketOnSaleRuleWin = 4703,
	MarketExchangeWin = 4704,
	MarketRemoveWin = 4705,
	MarketSaleSuccessWin = 4706,
	MarketBuyWin = 4707,
	MarketIncreaseWin = 4708,
	MarketRecordWin = 4709,

	-- 筛选
	ScreenerWin = 4800,

	-- 切职
	ProfessionToggleJobTab = 4900,
	InfoJobNulockTipsView = 4901,
	InfoDoubtNulockTips = 4902,

	-- 相机设置
	CameraSettingsPanel = 5000,

	-- GM子菜单
	GMCharacterInfo = 5100,

	-- GM天气信息面板
	GMWeatherInfoPanel = 5200,

	--传奇武器
	LegendaryWeaponPanel = 5300,
	LegendaryWeaponSystemPopUp = 5301,
	LegendaryWeaponCraftPopUp = 5302,
	LegendaryWeaponDeBugUI = 5303,

	-- 旅行笔记
	TravelLogPanel = 5400,

	-- 运输陆行鸟地图
	ChocoboTransportPanel = 5500,
	-- 运输陆行鸟提示
	ChocoboTransportTip = 5501,
	-- 运输陆行鸟技能面板
	ChocoboTransportSkill = 5502,
	-- 运输陆行鸟任务面板
	ChocoboTransportQuest = 5503,
	-- 运输陆行鸟QTE
	ChocoboFeeDingMainPanelView = 5504,

	-- 模型展示示例界面
	ShowModelPanel = 5599,

	-- NPC对话
	NPCDialogGMPanel = 5600,

	--MysterMerchant  神秘商人
	MysterShopMainPanelView = 5700, --神秘商店界面
	MysterMerchantSettlementView = 5701, -- 任务完成结算界面
	MysterMerchantBuyPropsWinView = 5702, -- 购买界面

	--每个系统用一个ID段

	--5800 -- 登录二期
	LoginMainNew = 5800,			-- 登录二期-国内登录界面
	LoginMainOversea = 5801,		-- 登录二期-海外登录界面
	TxUserProtocol = 5804,			-- 登录二期-腾讯游戏用户协议
	RequirePermission = 5805,		-- 登录二期-权限申请
	LoginSplash = 5806,				-- 登录二期-闪屏
	LoginMoreWin = 5807,			-- 登录二期-海外登录界面-更多弹窗
	LoginLanguageWin = 5818,		-- 登录二期-海外登录界面-语言
	LoginAgreementsWin = 5819,		-- 登录二期-海外登录界面-隐私合规
	LoginCG = 5810,					-- 登录二期-CG
	LoginNotice = 5811,				-- 登录二期-公告
	LoginEmailMain = 5812,			-- 登录二期-海外登录界面-邮箱登录
	LoginPreDownload = 5813,		-- 登录二期-资源预下载
	UserAgreementUpdate = 5814,		-- 登录二期-用户协议更新
	LoginNoticeWin = 5815,			-- 登录界面公告
	LoginQueueWin = 5816,			-- 排队
	AccountCancellationWait = 5820,	-- 账号注销等待
	AccountCancellationList = 5821,	-- 账号注销检查列表
	IntegrationView = 5822,			-- 发行集成界面

    --时尚配饰
	OrnamentPanel = 5900,

	--活动系统
	OpsActivityMainPanel = 6000,
    OpsActivityTreasureChestBuyItemWinView = 6001,
	OpsActivityPrizePoolWinView = 6002,
    OpsActivityUnboxingAnimationItemView = 6003,
	CommonVideoPlayerView = 6004,
	OpsActivityBuyWin = 6005,
	OpsWhaleMonutRebatesWin = 6006,
	OpsActivityExchangeListWin = 6007,
	OpsDesertFinePanelPlanWin = 6008,
	OpsDesertFineShareCodeWin = 6009,
	OpsDesertFineRebateTaskWin = 6010,
	OpsSeasonActivityPanel = 6011,
	OpsHalloweenPromPanel = 6012,
	OpsHalloweenMancrPanel = 6013,
	OpsHalloweenGamePanel = 6014,
	OpsHalloweenGameWin = 6015,
	OpsVersionNoticeContentPanelView = 6016,
	OpsSeasonAnimView = 6017,
	OpsSkateboardRebatesWin = 6018,


	-- PVP玩法 --
	-- 水晶冲突
	PVPColosseumMain = 6100,
	PVPColosseumIntroduction = 6101,
	PVPColosseumRecord = 6102,

	-- 分享
	ShareMain = 6200,
	ShareExternalLink = 6201,
	ShareActivity = 6202,
	ShareReward = 6203,
	ShareMAX  = 6299,

    --新人攻略
	OpsNewbieStrategyLightofEtherWinView = 6300,
	OpsNewBieStrategyCommListWinView = 6301,
	OpsNewbieStrategyBraveryAwardWinView = 6302,
	OpsNewbieStrategyHintWinView = 6304,


	--面对面交易
	MeetTradeMainView = 6400,
	MeetTradeExchangeChoosePanel = 6401,
	MeetTradeConfirmationView = 6402,
	--零时排行榜
	SavageRankMainView = 6500,
	SavageRankTeamInfoWinView = 6501,

	--光之盛典开服活动
	OpsCeremonyMainPanelView = 6600,
	OpsCeremonyMysteriousVisitorPanelView = 6601,
	OpsCermonyPenguinWarsPanelView = 6602,
	OpsCeremonyCelebrationPanelView = 6603,
	OpsCeremonyFateWinView = 6604,

	--region 热更测试
	HotUpdateTest = 6701,
	--endregion

	--拉回流活动
	OpsConcertRecallWinView = 6800,

	-- Permission
	PermissionTips = 6900,

    --每个系统用一个ID段
	--7000
	--7100
	--7200
	--7300
	--7400
	--7500
	--7600
	--7700
	--7800
	--7900
	--8000
	--8100
	--8200
	--8300
	--8400
	--8500
	--8600
	--8700
	--8800
	--8900
	--9000
	--9100
	--9200
	--9300
	--9400
	--9500
	--9600
	--9700
	--9800
	--9900
	--10000
	--10100
	--10200
	--10300
	--10400
	--10500
	--10600
	--10700
	--10800
	--10900
	--11000
	--11100
	--11200
	--11300
	--11400
	--11500
	--11600
	--11700
	--11800
	--11900
	--12000
	--12100
	--12200
	--12300
	--12400
	--12500
	--12600
	--12700
	--12800
	--12900
	--13000
	--13100
	--13200
	--13300
	--13400
	--13500
	--13600
	--13700
	--13800
	--13900
	--14000
	--14100
	--14200
	--14300
	--14400
	--14500
	--14600
	--14700
	--14800
	--14900
	--15000
	--15100
	--15200
	--15300
	--15400
	--15500
	--15600
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


	-- 指导者认证
	MentorMainPanel = 200000,
	MentorAuthenticationPanel = 200010,
	MentorUpdateNoticePanel = 200020,
	--仙人仙彩
	JumboCactpotMainPanel = 200100,
	JumboCactpotExchangePanel = 200101,
	JumboCactpotBuyerPanel = 200102,
	JumboCactpotRecordPanel = 200103,
	JumboCactpotNewMainPanel = 200104,
	JumboCactpotAddChance = 200105,
	JumboCactpotBuyTipsWin = 200106,
	JumboCactpotBuyWin = 200107,
	-- JumboCactpotRewardBonus = 200108,
	JumboCactpotPlate = 200109,
	JumboCactpotGetRewardWin = 200110,
	JumboCactpotRewardResume = 200111,
	JumboCactpotHistorylottery = 200112,
	JumboCactpotFirstPrize = 200113,
	JumboCactpotRewardBonusNew = 200114,
	JumboCactpotRewardShowWin = 200115,
	JumboCactpotGetRewardNewWin = 200116,

	--金碟通用界面
	GoldSauserOpportunityPanel = 200200,
	GoldSauserMainPanel = 200201,
	GoldSauserResultPanel = 200202,
	GoldSauserGetRewardWin = 200203,
	PlayStyleCommWin = 200204,
	PlayStyleLoadingPanel = 200205,
	PlayStyleCountDownTips = 200206,
	PlayStyleCommRewardWin = 200207,
	PlayStyleSystemTips = 200208,
	GoldSauserInfoCountDownTip = 200209,
	GoldSauserMainPanelExchangeWin = 200210, -- 金碟币兑换界面
	GateLeapOfFaithTopInfo = 200211, -- 虚景跳跳乐顶部信息
	GateLeapOfFaithResultPanel = 200212, -- 虚景跳跳乐结算界面
	GateMainCountDownPanel = 200213, -- 金碟小地图倒计时

	--时尚品鉴
	FashionEvaluationMainPanel = 200300, --时尚品鉴主界面
	FashionEvaluationFittingPanel = 200301, -- 试衣界面
	FashionEvaluationNPCPanel = 200302, -- 时尚达人外观界面
	FashionEvaluationHistoryPanel = 200303, -- 挑战记录界面
	FashionEvaluationTrackerPanel = 200304, -- 外观追踪界面
	FashionEvaluationProgressPanel = 200305, -- 评分过程界面
	FashionEvaluationSettlementPanel = 200306, -- 结算界面
	FashionEvaluationLoadingPanel = 200307, -- 开场加载界面
	FashionEvaluationCelebrationEffectPanel = 200308, -- 时尚庆典动效界面

	-- 系统解锁
	SystemUnlockSkillPanel = 200404,
	InfoTipsSystemUnlockTips = 200405,
	InfoContentUnlockTips = 200406,


	--- 新手引导
	TutorialGestureFriendItem = 200501,
	TutorialGestureMainPanel = 200502,
	TutorialGestureMapItem = 200503,
	TutorialGesturePanel = 200504,
	TutorialGestureSecondaryItem = 200505,
	TutorialGestureSelectItem = 200506,
	TutorialGestureTips1Item = 200507,
	TutorialGestureTips2Item = 200508,
	TutorialGuidePanel = 200509,
	TutorialGuideShowPanel = 200510,
	TutorialEntrancePanel = 200511,
	TutorialGestureBG = 200512,

	-- 推荐任务
	AdventureRecommendTaskTips = 200601,

	--新地图
	WorldMapTaskListPanel = 200702,
	NewMapTaskDetailPanel = 200703,
	NewMapTaskTrackingTips = 200704,
	WorldMapMarkerFocusItem = 200705,
	PlayStyleMapWin = 200706,

	--新人频道相关
	ChatInvitationWinPanel = 200801,
	ChatNoviceExamPagePanel = 200802,
	ChatRemoveNewbieChannelWin = 200803,

    --帮助说明
	HelpInfoLargeWinView = 200900,
	HelpInfoMidWinView = 200901,
	HelpInfoMenuWinView = 200902,
	--CommInforBtn = 200903,

	-- 浮层通用Tips
	CommHelpInfoTipsView = 201000,     -- 纯文字Tips
	CommHelpInfoSimpleTipsView = 201001, -- 简单标题文本Tips(有黑色背景的)
	CommHelpInfoTitleTipsView = 201002,	 -- 标题多段文本的Tips
	CommHelpInfoJumpTipsView = 201003,	 -- 文本+跳转的Tips
	CommStorageTipsView = 201004,	-- 按钮组Tips
	CommGetWayTipsView = 201005,	-- 展示获取途径的Tips
	CommJumpWayTipsView = 201006,   -- 不带标题带箭头带Icon的Tips
	CommJumpWayTitleTipsView = 201007,  -- 不带标题带箭头带Icon的Tips
	CommJumpWayIconTipsView = 201008, -- icon组Tips
	CommSkillTipsView = 201009,	-- 坐骑表演技能详情Tips

	--邮件
	MailMainView = 201100,

	--称号
	TitleMainPanelView = 201200,

	--- 福利-月卡
	MonthCardMainPanel = 201300,
	--- 活动-首充测试
	FirstRechargingMainPanel = 203000,

	-- 商城2.0
	-- StoreMainPanel = 201400,				-- 商城主界面
	-- StorePropsPage = 201401,				-- 道具页面
	-- StoreGoodsExpandPage = 201402,			-- 商品列表展开页签
	StoreBuyGoodsWin = 201403,				-- 购买商品
	StoreBuyPropsWin = 201404,				-- 购买道具
	-- StoreNotMatchTips = 201405,
	StoreNewMainPanel = 201406,				--- 商城主界面  新
	StoreNewCouponsWin = 201407,				--- 商城优惠券选择界面
	StoreNewCommodityExpandPanel = 201408,		--- 道具界面  新
	StoreNewBuyWinPanel = 201409,				--- 购买弹窗
	StoreNewBlindBoxDescription = 201410,		--- ?

	-- 赠礼
	StoreGiftChooseFriendWin = 201600,		-- 赠礼选择好友界面
	StoreGiftMailWin = 201601,				-- 赠礼确认界面
	--乐谱播放器
	MusicPlayerMainPanelView = 201500,
	--乐谱图鉴
	MusicAtlasMainView = 201501,
	--图鉴入口
	GuideMainPanelView = 201502,
	--乐谱回想
	MusicAtlasRevertPanelView = 201503,

	--战令
	BattlePassMainView = 201900,			--战令主界面
	BattlePassBuyLevelWin = 201901,			--战令购买等级界面
	BattlePassAdvanceView = 201903,		    --战令进阶界面
	BattlePassRewardPanel = 201904,			--战令奖励姐买你

    -- 理符任务
	LeveQuestMainPanel = 201700,		--理符主界面
	LeveQuestPaySettingPanel = 201701,		--理符设置界面

	--成就
	AchievementMainPanel  = 201801,
	AchievementDetailWin  = 201802,

	--衣橱
	WardrobeMainPanel = 202000,        --衣橱主界面
	WardrobeAppearancePanel = 202001,  --衣橱外观收集界面
	WardrobePresetsPanel = 202002,	   --衣橱预设界面
	WardrobeUnlockPanel = 202003,	   --衣橱快捷解锁界面
	WardrobeStainPanel = 202004,	   --衣橱试染界面
	WardrobeTips = 202005,		   	   --衣橱同模tips
	WardrobeTipsWin = 202006,		   --衣橱扩充预设界面
	WardrobeProfAppListWin = 202007,   --衣橱职业收集弹窗
	WardrobeSuitPanel = 202008,		   --衣橱外观数据

	-- 钓鱼笔记
	FishGuide = 300001,
	FishInghole = 300002,
	FishNotesOtherBait = 300003,
	FishNoteClockSetWinView = 300004,
	FishIngHoleTips = 300005,
	FishIngholeInfoWin = 300006,
	ActivityPanel = 300501,

	--采集笔记
	GatheringLogMainPanelView = 300201,
	GatheringLogSearchPageView = 300202,
	GatheringLogSetAlarmClockWinView = 300203,
	SearchResultPanelView = 300204,

	--收藏品
	CollectablesMainPanelView = 300301,
	CollectablesTransactionTipsView = 300302,

	--region 部队系统
	ArmyPanel = 304401,
	ArmyEmblemEditPanel = 304402,
	ArmyRuleWinPage = 304403,
	ArmyEditNoticPanel = 304404,
	ArmyEditInfoPanel = 304405,
	ArmyEditRecruitPanel = 304406,
	ArmyInfoTrendsPanel	= 304407,
	ArmyApplyJoinPanel = 304408,
	ArmyMemClassSettingPanel = 304409,
	ArmyMemberCategoryChangePanel = 304410,
	ArmyEditCategoryIconPanel = 304411,
	ArmyEditClassNamePanel = 304412,
	ArmyDepotPanel = 304413,
	ArmyItemTips = 304414,
	ArmyDepotRename = 304415,
	ArmyExpandWin = 304416,
	ArmyCategoryEditPanel = 304417,
	ArmySEPanel = 304418,
	ArmySEBuyWin = 304419,
	ArmyDepotMoneyWin = 304420,
	ArmyJoinInfoViewWin = 304421,
	ArmyEditInformationWin = 304422,
	ArmyInviteWin = 304423,
	ArmySelectQuantityWin = 304424,
	--endregion 部队系统

	--region 制作笔记
	CraftingLog = 300601,
	CraftingLogSearchPageView = 300602,
	CraftingLogListItemView = 300603,
	CraftingLogSetCraftTimesWinView = 300604,
	CraftingLogSimpleWorkPanel = 300605,
	CraftingLogShopWin = 300606,
	--endregion 制作笔记

	--region 风脉泉
	AetherCurrentMainPanelView = 300701,
	AetherCurrentSkillPanelView = 300702,
	AetherCurrentTipsPanelView = 300703,
	AetherCurrentTips02PanelView = 300704,
	AetherCurrentMapPanelView = 300705,
	--endregion 风脉泉

	--region 金碟小游戏
	OutOnALimbMainPanel = 301101,
	OutOnALimbOkWin = 301102,
	OutOnALimbDoubleWin = 301103,
	OutOnALimbSettlementPanel = 301104,
	TheFinerMinerMainPanel = 301105,
	TheFinerMinerSettlementPanel = 301106,
	GoldSaucerCuffMainPanel = 301107,
	GoldSaucerCuffBlowTips = 301108,
	GoldSaucerMonsterTossMainPanel= 301109,
    MooglePawMainPanel = 301110,
	MooglePawOkWin = 301111,
	MooglePawDoubleWin = 301112,
	CrystalTowerStrikerMainPanel = 301113,
	GoldSaucerMonsterTossShootingTips = 301114,
	MooglePawGamePanel = 301115,
	MooglePawResultPanel = 301116,
	GoldSaucerCuffShootingTips = 301117,
	--endregion 金碟小游戏

	--region 演奏
	MusicPerformanceMainPanelView 			= 300801,  --演奏主界面
	MusicPerformanceSelectPanelView			= 300802,  --演奏选择乐器武器的界面
	MusicPerformanceMetronomeSettingView	= 300803,  --节拍器设置界面
	MusicPerformanceEnsembleMetronmeView	= 300804,  --发起合奏确认界面
	MusicPerformanceEnsembleConfirmView		= 300805,  --合奏组队的确认界面
	MusicPerformanceSettingView				= 300806,  --乐器演奏设置界面
	MusicPerformanceProtocolView			= 300807,  --乐器演奏协议界面

	-- 演奏助手
	MusicPefromanceSongPanelView			= 300821,  --歌曲选择界面
	MusicPefromanceSongDetailPanelView		= 300822,  --歌曲细节界面
	PerformanceAssistantPanelView			= 300823,  --演奏完成的界面
	PerformanceAssistantItemView			= 300824,  --音符的UI
	PerformanceAssistantPauseWinView		= 300825,  --暂停演奏的界面
	--endregion 演奏

    --region 宠物
	CompanionListPanel = 300901,
	CompanionArchivePanel = 300902,
	--endregion 宠物

	--region 陆行鸟
	ChocoboRaceMainView = 301001,
	ChocoboRaceResultPanelView = 301002,
	ChocoboWordsPanelView = 301003,
	ChocoboInfoPanelView = 301004,
	ChocoboMainPanelView = 301005,
	ChocoboOverviewPanelView = 301006,
	ChocoboSkillPanelView = 301007,
	ChocoboSkillSideWinView = 301008,
	ChocoboTitleWinView = 301009,
	ChocoboSkillDetailTips = 301010,
	ChocoboLevelUpTipsView = 301011,
	ChocoboGenealogyPanelView = 301012,
	ChocoboRelationPageView = 301013,
	ChocoboExchangeRacerPageView = 301014,
	ChocoboScreenerView = 301015,
	ChocoboRaceNpcChallengeView = 301016,
	ChocoboRaceCountDownView = 301017,
	ChocoboSelectSexView = 301018,

	ChocoboCodexArmorPanelView = 301020,
	ChocoboCodexArmorRewardWinView = 301021,
	ChocoboBorrowPanelView = 301022,
	ChocoboBreedPanelView = 301023,
	ChocoboTransferWinView = 301024,
	ChocoboNewBornPanelView = 301025,
	ChocoboNameWinView = 301026,
	ChocoboModelGMPanelView = 301027,
	ChocoboRaceGMTargetInfoView = 301028, 
	--endregion 陆行鸟

	--region 寻宝
	TreasureHuntMainPanel = 301201,
	TreasureHuntSkillPanel = 301202,
	TreasureHuntFinishPanel = 301203,
	TreasureHuntTransferPanel = 301204,
	TreasureHuntBtnItem = 301205,
	TreasureHuntHouseWinPanel = 301206,
	--endregion 寻宝

	--region 搭档
	BuddyMainPanel = 301301,
	BuddySurfacePanel = 301302,
	BuddySurfaceStainWin = 301303,
	BuddySkillDetailTips = 301304,
	BuddyUseAccelerateWin = 301305,
	--endregion 搭档

	--region 理发屋
	HaircutMainPanel = 301401,
	HaircutPreviewPanel = 301402,
	HaircutWin = 301403,
	--endregion 理发屋

	--region 拍照
	PhotoMain 				= 301501,
	PhotoAddTemplate 		= 301502,

	PhotoTemplatePanel 		= 301503,
	PhotoActionPanel 		= 301504,
	PhotoEmojiPaenl 		= 301505,
	PhotoFilterPanel 		= 301506,
	PhotoRolePanel 			= 301507,
	PhotoSetupPanel 		= 301508,
	PhotoEffectPanel 		= 301509,
	PhotoWeatherPanel 		= 301510,
	PhotoStatePanel 		= 301511,


	--endregion 拍照

    --region 金碟主界面
	GoldSauserEntranceMainPanel = 302001,
	GoldSauserMainPanelDataWinItem = 302002,
	GoldSauserMainPanelTyphonGameItem = 302003,
	GoldSauserMainPanelBodyguardGameItem = 302004,
	GoldSaucerMainPanelChallengeNotesWin = 302005,
	GoldSaucerMainPanelUsingTeleportWin = 302006,
	GoldSauserMainPanelAwardWin = 302007,
	--endregion 金蝶主界面

	-- region 探索笔记
	SightSeeingLogMainView = 301601,
	SightSeeingLogFinishPopupView = 301602,
	SightSeeingLogActChooseView = 301603,
	--endregion 探索笔记

	-- region 足迹系统
	FootPrintMainPanelView = 301801,
	FootPrintDataPanelView = 301802,
	--endregion 足迹系统

	--region 军票系统
	CompanySealMainPanelView = 301901,
	CompanySealInfoPanelView = 301902,
	CompanySealPromotionWinView = 301903,
	CompanySealTransferWinView = 301904,
	CompanySealUnsubmittableWinView = 301905,
	GrandCompanyTips = 301906,

	-- region 自动寻路
	AutoPathMoveTips = 302101,
	--endregion 自动寻路

	-- region 巡回乐团
	TouringBandGuidePanelView = 303001,
	TouringBandFanWinView = 303002,
	TouringBandSupportPanelView = 303003,
	TouringBandSupportWinView = 303004,
	-- region 巡回乐团 end

	--region 拼装剪影
	PuzzleBurritosMainPanel = 302301,
	PuzzleBurritosMoveBreadView = 302351,

	PuzzlePenguinJigsawMainView = 302352, -- 企鹅拼装主界面
	PuzzlePenguinJigsawMoveItemView = 302353, -- 企鹅拼装移动图片
	--endregion 拼装剪影

	--UMGVideoPlayer
	UMGVideoPlayerView = 304001,
	--PandoraMainPanel
	PandoraMainPanelView = 304002,
	PandoraActivityPanelView = 304003,

	--技能面板
	SkillMainPanel = 305001,

	--region 运营平台相关
	WeChatPrivilegePanel = 306001,		--微信登录特权提示界面
	OperationChannelPanel = 306002,		--二级主界面中“更多”：渠道社区入口界面
	--endregion

	--region 预览系统
	PreviewMountView = 307001,					--坐骑预览界面
	PreviewCompanionView = 307002,				--宠物伴侣预览界面
	PreviewRoleAppearanceView = 307003,			--角色外观预览界面
	--endregion 预览系统

	-- 对战资料
	PVPInfoPanel = 308001,
	PVPSeriesMalmstonePanel = 308002,
	PVPOptionListPanel = 308003,
	PVPHonorPanel = 308004,

	-- 决斗
	PVPDuelPanel = 309001,

	-- 升级途径
	PromoteLevelUpMainPanel = 309101,

	-- 跨界传送
	WorldVisitPanel = 310001,          	--- 跨界传送侧弹窗主界面
	WorldVisitWinPanel = 310002,		--- 跨界传送确认弹窗
	TeamTeleportWinPanel = 310003,		--- 组队招募跨界确认弹窗
	-- 光之启程
	DepartOfLightMainPanel = 330001,    --- 主界面
	DepartOfLightActivityDetailView = 330002,    --- 玩法说明详情
	DepartOfLightRecyclePanel = 330003,    --- 回收界面

	-- 外观便捷使用
	CommEasytoUseView = 320001,

	-- 野外探索
	WorldExploraMainPanel = 311001,
	WorldExploraWin = 311002,

	--每个系统用一个ID段
	--5800
	--5900
	--6000
	--6100
	--6200
	--6300
	--6400
	--6500
	--6600
	--6700
	--6800
	--6900
	--7000
	--7100
	--7200
	--7300
	--7400
	--7500
	--7600
	--7700
	--7800
	--7900
	--8000
	--8100
	--8200
	--8300
	--8400
	--8500
	--8600
	--8700
	--8800
	--8900
	--9000
	--9100
	--9200
	--9300
	--9400
	--9500
	--9600
	--9700
	--9800
	--9900
	--10000
	--10100
	--10200
	--10300
	--10400
	--10500
	--10600
	--10700
	--10800
	--10900
	--11000
	--11100
	--11200
	--11300
	--11400
	--11500
	--11600
	--11700
	--11800
	--11900
	--12000
	--12100
	--12200
	--12300
	--12400
	--12500
	--12600
	--12700
	--12800
	--12900
	--13000
	--13100
	--13200
	--13300
	--13400
	--13500
	--13600
	--13700
	--13800
	--13900
	--14000
	--14100
	--14200
	--14300
	--14400
	--14500
	--14600
	--14700
	--14800
	--14900
	--15000
	--15100
	--15200
	--15300
	--15400
	--15500
	--15600
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
	-- 去掉之前ID分组功能（因为仓库统一了，不用多个仓库同步，合并冲突容易解决，没有必要在分组，定义ID更方便）
	-- 新加ID可以从小到大，按预留ID段使用
}

local IdToNameMap = nil
function UIViewID:IDToName(ViewID)
	if not IdToNameMap then
		IdToNameMap = {}
		for k, v in pairs(self) do
			if type(k) == "string" and type(v) == "number" then
				IdToNameMap[v] = k
			end
		end
	end
	return IdToNameMap[ViewID] or "Unknown"
end

return UIViewID
