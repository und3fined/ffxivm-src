--
-- Author: anypkvcai
-- Date: 2020-08-14 10:34:28
-- Description:
--

---@class SaveKey
local SaveKey = {
	--10000以下给C++使用，以上给Lua端用，Lua端直接使用整型
	LuaMin = 10001,

	LastLoginOpenID = 10002,
	LastLoginWorldID = 10003,
	RecentUseEmotions = 10004,
	LastLoginRoleID = 10005,
	ShowPreviewPage = 10006,	--创角、幻想药、理发屋是否打开预览界面
	PreHaircutMapID = 10007,    --进入理发屋前的地图
	MajorBornRoleID = 10008,	--出生场景的主角roleid

	UserAgreement = 10010,
	RequirePermission = 10011,
	UserAgreementVersion = 10012,
	NoShowNoticeAgain = 10013,
	UserAgreementChecked = 10014,
	IsCGMute = 10020,
	LastEmail = 10021,
	VideoVolume = 10023,
	LoginFailTime = 10024,
	LoginFailCount = 10025,
	IOS26ResTipsCount = 10026,  -- IOS26资源下载提示次数

	--Source Hotfix
	SourceVersion = 10050,

	-- PreDownload
	PreDownloadFlag = 10070,
	PreDownloadRedDot = 10071,

	--SystemConfig 画面设置			跟画质等级关联的SaveKey，也就是说这些修改了，画质等级都要变为自定义的
	DefaultQualityLevel = 10099,
	QualityLevel = 10100,
	CombatFXSelf = 10101,	--战斗特效
	CombatFXTeam = 10102,
	CombatFXPlayer = 10103,
	CombatFXEnemy = 10104,
	AntiAliasingQuality = 10105,	--抗锯齿
	ShadowQuality = 10106,	--
	PostProcessQuality = 10107,
	TextureQuality = 10108,	--
	EffectQuality = 10109,	--特效质量
	FoliageQuality = 10110,	--植被
	ScaleFactor = 10124,	--缩放系数
	LightQuality = 10112,	--灯光品质
	EffectLod = 10113,
	EffectMaxNum = 10114,
	ActorLod = 10115,
	LastQualityLevel = 10116, --上一次设置的方案
	AmbientOcclusion = 10117,	--临时测试
	LightShaft = 10118,			--临时测试

    VisionPlayerNum = 10119,
    VisionPetNum = 10120,
    VisionNpcNum = 10121,
	OtherPlayerEffectSwitch = 10122,
	HighqualityBRDFds = 10123,	--临时测试
	--10124已用
	PerformanceMode = 10125,	--根据设备性能调整画质
    DungeonVisionPlayerNum = 10126,
		--新增的时候要注意要小于PictureSaveKeyMax
		--跟画质等级关联的SaveKey，也就是说这些修改了，画质等级都要变为自定义的
	PictureSaveKeyMax = 10130,
	DefaultScreenPercentage = 10131,	--记录默认的定级的那个数值--没用到
	SelectQualityLevel = 10132,	--玩家UI选择的或者默认的画质等级，不包括自定义  0-4
	PowerSavingMode = 10133,	--省电模式的设置项

	--Gather
	KeepSimpleGather = 10201,

	--性能模式相关 begin
	PerformanceTipPWorldResID1 = 10210,
	PerformanceTipPWorldResID2 = 10211,
	Fxaa = 10212, --r.DefaultFeature.AntiAliasing
	MaxFPS	= 10213,	--最大FPS的数组索引

	PM_ViewDistanceScale = 10220,
	PM_PostProcessAAQuality = 10221,
	PM_MaxCSMResolution = 10222,
	PM_ShadowQuality = 10223,
	PM_AOQuality = 10224,
	PM_FarShadowMapEnable = 10225,
	PM_HDSelfShadowMapEnable = 10226,
	PM_SpotLightShadowResolutionRate = 10227,
	PM_TonemapperQuality = 10228,
	PM_DepthOfFieldQuality = 10229,
	PM_LightShaftQuality = 10230,
	PM_ScreenPercentage = 10231,
	PM_Maxfps = 10232,
	PM_QualityLevelFXLOD = 10233,
	PM_WorldEffectMaxCount = 10234,
	--
	Lst_ViewDistanceScale = 10250,
	Lst_PostProcessAAQuality = 10251,
	Lst_MaxCSMResolution = 10252,
	Lst_ShadowQuality = 10253,
	Lst_AOQuality = 10254,
	Lst_FarShadowMapEnable = 10255,
	Lst_HDSelfShadowMapEnable = 10256,
	Lst_SpotLightShadowResolutionRate = 10257,
	Lst_TonemapperQuality = 10258,
	Lst_DepthOfFieldQuality = 10259,
	Lst_LightShaftQuality = 10260,
	Lst_ScreenPercentage = 10261,
	Lst_Maxfps = 10262,
	Lst_QualityLevelFXLOD = 10263,
	Lst_WorldEffectMaxCount = 10264,
	--性能模式相关 end

	--Chat
	--聊天频道不是按位存储，存储是以“，”分割的字符串 因为需要存储选择频道的顺序
	ChatComprehensiveChannel = 10300, -- 综合频道显示的频道
	ChatColorIndices = 10301, -- 频道颜色 ChatChannelColor索引 以“，”分割的字符串（不包含通讯贝）
	ChatComprehensiveChannelSysMsgType = 10302, -- 综合频道显示的系统消息类型
	ChatComprehensiveChannelBlockGroupID = 10303, -- 综合频道屏蔽的通讯贝ID
	ChatColorIndicesGroup = 10305, -- 通讯贝频道颜色 ChatChannelColor索引
	ChatHideChannels = 10306, -- 隐藏的频道	
	ChatChannelShowPos = 10307, -- 聊天频道显示位置
	ChatOpenPrivateRedDotTip = 10308, -- 聊天是否开启私聊红点提示, {迷宫内，迷宫外}
	ChatOpenPrivateSidebar = 10309, -- 聊天是否开启私聊侧边栏, {迷宫内，迷宫外}
	ChatOpenPrivateDanmaku = 10310, -- 聊天是否开启私聊弹幕, {迷宫内，迷宫外}
	ChatOpenTeamDanmaku = 10311, -- 聊天是否开启队伍弹幕, {迷宫内，迷宫外}

	--微彩
	MinicactpotNoBubbleTip = 10400,	--是否点击过奖励预览

	--Navi Path
	ShowNaviPath = 10401,	--是否显示导航Path

	-- 招募
	TeamRecruitMemberProfTip = 10500, -- 是否弹出队伍职业提示

	-- 摇杆
	MaxSpeedConstState = 10600, -- 摇杆推满后是否摇杆是否维持跑步状态
	MaxSpeedBlindConstState = 10601, --摇杆推满后摇杆死区是否屏蔽停止移动

	--Map
	MapShowIcon = 10700, -- 是否显示图标
	MapShowText = 10701, -- 是否显示文字
	MapShowWeather = 10702, -- 是否显示天气
	MapShowTime = 10703, -- 是否显示时间
	MapShowCrystalIcon = 10704, -- 是否显示以太之光图标
	MapWeatherType = 10705, -- 天气显示类型
	MapQuestShowType = 10706, -- 任务显示类型
	MapShowWildBox = 10707, -- 是否显示野外宝箱
	MapShowAetherCurrent = 10708, -- 是否显示风脉泉
	MapShowDiscoverNote = 10709, -- 是否显示探索笔记
	MapDransDoorHighlight = 10720, -- 地图传送门标记高亮效果

	--坐骑
	MountNewMap = 10801,
	MountCallSetting = 10802,
	MountRecentCall = 10803,
	bMountFirstMajorFall = 10804,
	CustomMadeNewMap = 10805,
	CustomMadeMountNewMap = 10806,

	--声音设置
	GlobalVol 		= 10900, 	-- 整体音量
	MusicVol 		= 10901,	-- 背景音乐音量
	MainPlayerVol 	= 10902, 	-- 主角自身音量
	VoicesVol 		= 10903, 	-- 语音音量
	UISoundVol 		= 10904, 	-- 系统音量(UI声音)
	AmbientVol 		= 10905, 	-- 环境音量
	InstrumentsVol	= 10906,	-- 乐器演奏		--废弃
	TeammateVol		= 10907,	-- 小队
	EnemyVol		= 10908,	-- 敌人
	MountBGM		= 10909,		-- 乘骑状态下播放音乐
	SfxVol			= 10918,	--音效
    InstrumentsMainPlayerVol = 10919,
    InstrumentsOthersVol = 10920,
	BgVoiceSetting = 10921,		-- 后台语音

	--基础设置
	AutoSkipCutScene = 10910,	--自动跳过进地图时看过一次的过场动画
	-- MaxFPS			= 10911,	--最大FPS的数组索引 --废弃
	AutoLeaveTime	= 10912,	--自动离开状态的时间
	MajorAutoSelectTarget = 10913,	--遭受敌对性质技能时自动选中目标
	ShowSelectOutline = 10914,	--选中目标时开启边缘高亮效果
	ShowTargetLine = 10915,		--显示目标线
	ShowRelevanceLine = 10916,	--显示联系线
	CameraShake = 10917,		--技能震屏
		--10918-10920 已用，并且预留几个给声音设置，下面的从10925开始
	SwitchTargetType = 10925,	--切换目标的排序类型  按距离、血量排序
	DungeonFpsState = 10926,	--副本帧率优化
	DungeonFpsMode = 10927,
	IsSetDungeonFpsMode = 10928,	--本地记录是否进副本的时候设置过 --废弃

	--角色设置
	ShowWeapon = 10940,			--回收武器时显示主手装备及副手装备
	ShowHead = 10941,			--显示自己的头部装备
	HelmetGimmickOn = 10942,	--调整自己的头部装备（仅限部分装备）  比如眼镜开关
	ResetToIdleTime = 10943,	--放松等待时间（秒）
	RandomSwitchPose = 10944,	--自动随机改变姿势
	CrafterHideOtherPlayers = 10945,  --制作时是否屏蔽其他玩家
	JoystickControlType = 10946,
	HoldWeaponIdleTime = 10947,		--自动收回武器时间（秒）
	SwitchHoldWeaponPose = 10948,	--自动收回武器
	SummonScale = 10949, --召唤兽缩放大小
	--角色相机设置
	ViewDis = 10950,--视距
	ViewDisScaleSpeed = 10951,--视距缩放速度
	FOV = 10952,--视野大小
	CameraRotateSpeed = 10953,--旋转速率
	CameraSurround = 10954,--环绕开关
	CameraHeightOffset = 10955, -- 高度偏移
		-- 预留几位给相机
	ShowCompanionNameplate = 10970, -- 宠物名字板显示开关
	ShowOtherCompanions = 10971, -- 他人宠物显示开关
	NeedShowTips = 10972,	--显示情感动作气泡
	EnableSpecialJump = 10973,		--是否开启特殊跳跃（跳跃副摇杆）
	AutoGenAttack = 10974,	--自动维持普通攻击

	--颜色设置
	BrandColorSelf 	= 11000, 	-- 名牌颜色（自己）

	--游戏语音
	PkgLanguage = 11050,		--语言- 游戏语言
	PkgVoices = 11051,		--语言- 游戏语音

	--充值
	RechargingInteractionTime = 11100, -- 前一次在充值界面交互的时间
	bIsShopKeeperExist = 11101, -- 充值界面看板娘是否出现

	--任务
	NavigationState = 11200, -- 导航路径显示状态
	SetMarkFollowRecord = 11201, --任务追踪打点标记记录

	--剧情
	IsAutoPlay = 11300, -- 自动播放对话内容
	AutoPlaySpeedLevel = 11301, -- 自动播放速率

	--Loading
	LoadingLastContentID = 11400, -- 上一次Loading显示的内容ID

	-- 副本入口ID
	PWEVisitState = 12001, --副本入口访问列表（Json）

	-- 角色脚步
	FootstepEffect = 13000, --角色脚步特效显示设置

	DownResDuringAuditing = 13002, --在审核阶段下载全量资源

	TeamSceneMarker = 14000,
	TeamTargetMarker = 14001,
	TeamCountDown = 14002,

    -- 通用红点
	HideRedDot = 15000, --已读红点保存

	-- 社交
	FriendHideSign = 16000, -- 隐藏签名的好友

	-- 技能
	SkillSystemRedDot = 17000,  -- 技能系统红点 (保留这部分17000 ~ 17999)
	SkillTips = 18000,

	-- 主界面
	MainPanelIsTimeBarVisible = 18001,  -- 主界面右下角时间栏
	MainPanelIsEnmityPanelVisible = 18002,  -- 主界面仇恨列表

    -- HUD
	HUDMemberFlyTextVisible = 18101,  -- 是否显示队友造成的伤害飘字

	HUDNameVisibleMajor = 18111,  -- 是否显示主角名字
	HUDNameVisibleFriend = 18112,  -- 是否显示好友名字
	HUDNameVisibleTeammate = 18113,  -- 是否显示队友名字
	HUDNameVisiblePlayer = 18114,  -- 是否显示其他玩家名字
	HUDNameVisibleOther = 18115,  -- 是否显示非玩家名字

	HUDNameVisibleMajorBuddy = 18121,  -- 是否显示主角搭档名字
	HUDNameVisibleFriendBuddy = 18122,  -- 是否显示好友搭档名字
	HUDNameVisibleTeammateBuddy = 18123,  -- 是否显示队友搭档名字
	HUDNameVisiblePlayerBuddy = 18124,  -- 是否显示其他玩家搭档名字
	HUDNameVisibleOtherBuddy = 18125,  -- 是否显示非玩家搭档名字

	-- 指导者是否可以更新通知
	MentorUpdateNoticeUI = 200000,
	MentorUpdateEdition = 200001,
	NewbieLastInviterInfo = 200002,
	MentorDailyRandomOnlineState = 200003,

	TutorialState = 200100,
	TutorialGuideState = 200101,
	RecommendTaskNewState = 200200,

	--称号
	ShowSelfTitle = 200300,
	ShowTeamMemberTitle = 200301,
	ShowBigTeamMemberTitle = 200302,
	ShowFriendTitle = 200303,
	ShowStrangerTitle = 200304,

	--收藏品
	CollectionRedDot = 200400,

	-- 情感动作
	InteractionTimeEmotions = 300000,   -- 最近使用情感动作的时间
	FavoriteEmotions = 300001,          -- 所有收藏的情感动作
	RedDotEmotions = 300002,          	-- 需要显示红点的情感动作

	-- 动画
	AnimBudgetLevel = 300021,			-- 动画预算等级

	-- 演奏
	LastMusicPerformID = 300100,   -- 最近使用演奏ID
	MetronomeVolume = 300101,   -- 演奏时播放的音量大小
	MetronomeBPM = 300102,   -- 演奏时播放的BPM
	MetronomeBeatPerBarCount = 300103,   -- 演奏时播放的拍数
	MetronomeEffect = 300104,   -- 小节振铃
	MetronomePrepare = 300105,   -- 加入两个准备小节
	MetronomeEffectPrepareOnly = 300106, -- 小节振铃仅在准备小节响起(注：优先级比小节振铃(MetronomeEffect)高)
	EnsembleMode = 3000107,		-- 合奏模式

	PerformanceKeyboardMode = 3000108,	-- 键盘演奏模式
	PerformanceKeySize = 3000109,		-- 按键大小
	-- PerformanceOtherMuted = 3000110,	-- 屏蔽其他玩家的演奏声
	PerformanceProfChangeTipSelect = 3000113,	-- 是否进行职业提醒
	PerformanceExitTipSelect = 3000114,	-- 是否退出提醒
	PerformanceSettingRestoreDefaultTipSelect = 3000115,	-- 是否提醒（设置界面恢复默认按钮tips中的不再提醒）
	MetronomeSettingRestoreDefaultTipSelect = 3000116,	-- 是否提醒（节拍器设置界面恢复默认按钮tips中的不再提醒）

	PerformanceEnsembleBPM = 3000120,		-- 发起合奏准备确认界面-BPM
	PerformanceEnsembleBEAT = 3000121,		-- 发起合奏准备确认界面-BEAT
	PerformanceEnsembleAssistant = 3000122,	-- 发起合奏准备确认界面-合奏助手
	PerformanceEnsembleCountDown = 3000123,	-- 发起合奏准备确认界面-倒计时

	-- 风脉泉
	LastRecordPointSequence = 300200,   -- 风脉泉新增加坐标点缓存序列
	LastRecordPointMap = 300201,  -- 风脉泉新增加坐标点缓存地图

	-- 足迹&探索笔记
	FootPrintCompleteItemID = 300400, 	-- 足迹系统已完成足迹ID
	DiscoverNoteRegionID = 300401, -- 探索笔记地域页签红点
	DiscoverNoteItemID = 300402, -- 探索笔记笔记新解锁红点
	DiscoverClueRecord = 300403, -- 探索笔记线索解锁记录

	-- 捕鱼
	SavedFishBaitID = 300300,  -- 上次使用的鱼饵ID

	-- 冒险
	AdventureReadTime = 300500,

	-- 陆行鸟
	ChocoboRedDot = 300600,  --陆行鸟自定义红点

	--自动寻路
	AutoPathMove = 300700,		--自动寻路本地开关

	--每个系统用一个ID段
	--16000

	--旅馆
	HotelSleep = 300700,
	HotelWake = 300701,

	-- 理符
	LeveQuestRedDot = 300800,  -- 理符红点啊

	--采集笔记制作笔记
	GatherNoteVersion = 300900,	--采集笔记制作笔记版本
	PromptedAlarmGather = 300901, --采集笔记已忽略闹钟
	AdvancePromptedAlarmGather = 300902, --采集笔记已忽略闹钟

	-- 巡回乐团
	TouringBandStoryRedDot = 301000,  --巡回乐团故事红点
	TouringBandMostRecentBandID = 301001,  --巡回乐团相遇
	TouringBandFansBandID = 301002,  --巡回乐团粉丝

	-- 问卷调查
	MURSurveyRedDot = 301100,  --问卷调查入口icon红点
	CheckedSurveyID = 301101,  --已请求过有效性的号码包问卷

	--新手引导
	TutorialLocalStep = 302000,
	--上传日志时间戳
	LastUploadLogFileTimeStap = 302001,
	--上次日志时间戳
	LastCreateLogFileTimeStap = 302002,

	--商店
	ShopRecordRedDot = 303000, --商店红点
	-- 活动
	OpsActivityRecordRedDot = 304000, --活动红点
    OpsSkipAnimation = 304001, --跳过开奖动画
	OpsActivitySroreBuyRemind = 304002, --- 商城购买后活动提醒红点
	--OpsDesertFirePrompt = 304003, --沙漠炎火提示
	OpsDesertFireTaskRate = 304004, --沙漠炎火返利任务进度
	HalloweenMancrPrompt = 304005, --守护天节提示
	NodeRecordRedDot = 304006, --节点首次红点记录

	OpenHalloweenAnimation = 304007, --守护天劫开场动画
	OpenLightCeremony = 304008, --光之盛典开场动画
	OpenLightCeremonyDaily = 304009, --光之盛典每日点击入场动画
	OpenLightCeremonyAutoPlayVideo = 304010, --光之盛典自动播放视频
	OpsHalloweenAutoPlayVideo = 304011, --守护天节自动播放视频
	LastVersion = 304011,	--上次版本
	WeChatLaunchPrivilege = 305000, --微信游戏中心启动特权
	QQLaunchPrivilege = 305001, 	--QQ游戏中心启动特权

	--搭档
	BuddyUpLevel = 306000, 	--搭档升级

	FashionDecoSetting = 307000, 	--设置
	FashionDecoLastWearWay = 307001, 	--时尚配饰上次穿戴方式

	-- 野外探索
	WilderExploreUnlock = 308000,

	--排行榜
	SavageRankTips = 307100,  --排行榜提示

	--头像
	HeadEditSaveAndUse = 308100, --保存并使用

	-- 在线状态
	ShowElectrocardiogramInVision = 309000,      -- 场景中是否显示其他玩家“心电图”状态
	ShowElectrocardiogramInPWorldTeam = 309001,  -- 副本中是否显示其他玩家“心电图”状态

	-- 金碟手册
	RewardsMarked = 310000, -- 收藏中的奖励

	-- 潘多拉活动
	FaceSlapActivityOpenStatus = 311000, -- 拍脸活动打开状态

	-- 分享活动配置数据
	ShareActivityConfigVersion = 320000,
	ShareActivityConfig = 320001,
	ShareActivityRewardConfigVersion = 320002,
	ShareActivityRewardConfig = 320003,

	--光之直升
	ShowDirectUpgradePopUp = 321000,	--直升弹窗

	--招募
	RecruitNewGuideShow = 322000,	--招募新手引导

	--18000
	--19000
	--20000
	--21000
	--22000
	--23000
	--24000
	--25000
	--26000
	--27000
	--28000
	--29000
	--30000
	--31000
	--32000
	--33000
	--34000
	--35000
	--36000
	--37000
	--38000
	--39000
	--40000
	--41000
	--42000
	--43000
	--44000
	--45000
	--46000
	--47000
	--48000
	--49000
	--50000
	--51000
	--52000
	--53000
	--54000
	--55000
	--56000
	--57000
	--58000
	--59000
	--60000
	--61000
	--62000
	--63000
	--64000
	--65000
	--66000
	--67000
	--68000
	--69000
	--70000
	--71000
	--72000
	--73000
	--74000
	--75000
	--76000
	--77000
	--78000
	--79000
	--80000
	--81000
	--82000
	--83000
	--84000
	--85000
	--86000
	--87000
	--88000
	--89000
	--90000
	--91000
	--92000
	--93000
	--94000
	--95000
	--96000
	--97000
	--98000
	--99000
	--100000
	-- 去掉之前ID分组功能（因为仓库统一了，不用多个仓库同步，合并冲突容易解决，没有必要在分组，定义ID更方便）
	-- 新加ID可以从小到大，按预留ID段使用
}

return SaveKey