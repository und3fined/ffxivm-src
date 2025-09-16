--
-- Author: anypkvcai
-- Date: 2020-08-14 10:35:28
-- Description:
--

---@class CommonDefine
local CommonDefine = {
	--CombatMgr:SendGetEnmityListReq Reason参数定义
	GetEnmityListReason = {
		MiniMap = 1,
		Target = 2,
	},

	bShowNetworkLog = true, -- 是否打印网络收发包日志
	bShowUIViewLog = true, -- 是否打印UIVIew显示或隐藏日志

	IsTestVersion = false,	--日方监修测试版
	IdleChangeTime = 30.0,	--休闲动作切换时间
    SuperArmorResetTime = 5.0,  --霸体重置等待时间
    SuperArmorRecoverTime = 1.0,  --霸体被破后，霸体值恢复时间

	UseSeamlessTravel = true; --是否启用关卡无缝切换，主角切场景不销毁

	--视野相关
	VisionCacheTime = 120.0,
	DetectRemoveVisionCacheTime = 1.0,
	--DelayDealVisionEnterTime = 0.3,
	IsShowVisionLog = false;
	IsShowAnimLog = false;
	IsShowMergeMeshLog = false;

	SelectPlayerRange = 100,

	VisionFadeOutTime = 0.2,		--视野隐藏角色时的淡出时间，负数直接隐藏
	VisionQueryTimeOut = 15,		--客户请求后台视野时，后台可能因为重启错过了收包/回包，所以需要客户端主动超时后重新请求
	bDelayCacheActorsWhenRefreshVision = false,	--客户端刷新视野时，是否等待收到回包才清理（缓存）客户端角色
	bEnableNewAsyncTaskControl = true, --视野模块是否开启新的异步任务控制机制，解决异步任务无法取消，以及异步转同步时的卡顿问题
	VisionIgnoreFadeInTime = 0.1,	--忽略淡入效果时，忽略的时间，BattleShowHide显示角色时给角色设置，避免显示后播的动画被淡入影响导致看不见

	ReasonNeedUpdateVision = {_G.UE.EHideReason.TimelineClip, },

	-- 视野数量配置已经转移到《S视野数量级别配置.xlsx》中
	-- VisionPlayerMaxCount = 20,          -- 视野中玩家最大数量
	-- VisionNPCMaxCount = 7,             -- 视野中NPC最大数量
	-- VisionMonsterMaxCount = 10,         -- 视野中怪物最大数量
	-- VisionMonsterMaxCountDungeon = 15, -- 视野中怪物最大数量（副本中）
	-- VisionCompanionMaxCount = 3,         -- 视野中宠物最大数量
	-- VisionTotalMaxCount = 30,            -- Actor总计最大数量
	-- VisionPlayerMaxCacheCount = 7,     -- 视野外能缓存模型的玩家的最大数量
	-- VisionNPCMaxCacheCount = 3,        -- 视野外能缓存模型的NPC的最大数量
	-- VisionMonsterMaxCacheCount = 5,        -- 视野外能缓存模型的怪物的最大数量
	-- VisionCompanionMaxCacheCount = 3,        -- 视野外能缓存模型的宠物的最大数量
	VisionNPCStopTickRange = 5000,     -- 关闭NPC Tick的距离
	VisionMonsterStopTickRange = 5000, -- 关闭怪物Tick的距离
	VisionBossMonsterStopTickRange = 15000, -- 关闭Boss怪物Tick的距离


	--视野更新策略和GC策略切换的条件
	PlayerCountToEnableVisionUpdateStrategy = 40,	--视野里超过（不包含等于）一定玩家数后，开启视野更新策略，按移动距离触发更新
	PlayerCountToEnableVisionGCStrategy = 40,		--视野里超过（不包含等于）一定玩家数后，开启视野GC策略，按释放玩家模型数触发GC

	--是否只根据移动距离更新，开启后，每隔VisionUpdateDeltaTime检测一次，如果距离上次更新移动超过VisionUpdateByMovementDistance则触发更新
	--或距离上次更新超过VisionUpdateByTimeInterval也触发更新
	bVisionEnableUpdateByMovement = false,
	VisionUpdateByTimeInterval = 5,				--静止不动时的更新间隔
	VisionUpdateByMovementDistance = 1000,		--移动超过多远后更新视野
	bVisionEnableReleaseMeshGC = false,			--视野释放模型触发GC开关
	VisionGCReleasedMeshCounterMax = 10,		--释放超过多少个Mesh后触发GC
	bVisionEnableAutoGC = false,				--视野自动定时GC开关
	VisionGCMaxInterval = 30,					--最多间隔30s触发1次GC
	VisionGCMinInterval = 5,					--最少间隔5s触发1次GC

	bVisionEnableBuddyControl = true,			--是否开启陆行鸟搭档的显隐控制，开启的话，只有附近陆行鸟进出视野时，会根据距离更新显示，且只显示几个（包括HUD）
	VisionBuddyShowNum = 2,						--陆行鸟搭档的最大显示数量，不包括主角的，其余不显示（包括HUD也不显示）

	--开启视野玩家的模型数量控制，同时加载的Mesh数量为VisionPlayerMaxCount + VisionPlayerMaxCacheCount + VisionExtraCachePlayerMeshCount
	bEnableVisionPlayerMeshCountControl = false,
	VisionExtraCachePlayerMeshCount = 5,		--视野模块额外保存的玩家Mesh数量，超过的会被释放

	bEnableDelayVisionShowAfterGC = false,			--强制GC后才进行新模型的显示

	VisionUpdateDeltaTime = 0.5, -- 视野数量限制更新间隔(秒)
	VisionReleaseMergedMeshDelay = 10.0, -- 离开视野释放合并模型延迟（秒）
	bEnableVisionMeshLimiter = true,       -- 是否开启视野模型数量控制
	bEnableReconnectRefreshVision = true,  -- 是否开启断线重连刷新视野
	bEnableStopTickByRange = true,       -- 是否开启根据距离关闭Tick逻辑
	bEnableHideMeshByRange = true,       -- 是否开启根据距离隐藏Actor
	bEnableTotalCountLimit = true,         -- 是否开启总数量限制

	VisionCreateActorFromMarkLeaveTimeLimit = 6,	--从MarkLeave中创建视野对象时每帧的时间上限，防止一帧初始化过多对象导致卡顿

	bEnableDelayedTask = true, --主线程异步任务开关
	bEnableDelayedTaskLog = false, --主线程异步任务Log开关

	--QualityLevel 特效LOD offset
	QualityLevelFXLOD = {
		[0] = {Major = 2, Player = 2, Boss = 2},
		[1] = {Major = 1, Player = 2, Boss = 1},
		[2] = {Major = 0, Player = 1, Boss = 0},
		[3] = {Major = 0, Player = 1, Boss = 0},
		[4] = {Major = 0, Player = 1, Boss = 0}
	},

	--QualityLevel 特效最大数量
	QualityLevelFXMaxCount = {
		[0] = 16,
		[1] = 23,
		[2] = 30,
		[3] = 32,
		[4] = 35
	},

	--战斗特效的LOD修正
	--最后一档完全看不到特效(不创建)
	CombatFXLOD = {
		[0] = 0,
		[1] = 1,
		[2] = 8,
	},

	QualityLevelActorLOD = {
		[0] = {Major = 1, Player = 2, Boss = 2, Monster = 2, NPC = 2},
		[1] = {Major = 1, Player = 2, Boss = 1, Monster = 1, NPC = 2},
		[2] = {Major = 0, Player = 1, Boss = 0, Monster = 0, NPC = 1},
		[3] = {Major = 0, Player = 1, Boss = 0, Monster = 0, NPC = 1},
		[4] = {Major = 0, Player = 1, Boss = 0, Monster = 0, NPC = 1}
	},

	-- 消息额外处理类型
	MESSAGE_PARAM_TYPE=
	{
		MESSAGE_INVALID = 0, -- 无效
		MESSAGE_GOLDSAUSER_OPPORTUNITY = 1 , -- 金蝶相关
		MESSAGE_TALKTIP_DISPLAYPOSITION = 2 , -- 副本对话类型Tip显示位置
		MESSAGE_NPC = 3, -- NPC相关相关
		MESSAGE_LOCATION = 4, -- 坐标相关
	},

	MESSAGE_GOLDSAUSER_TYPE=
	{
		MESSAGE_GOLDSAUSER_INVALID = 0, --无效
		MESSAGE_GOLDSAUSER_TO_ALL = 1, -- 对所有在金蝶里面的人
		MESSAGE_GOLDSAUSER_TO_SIGNUP = 2, -- 对报了名的
		MESSAGE_GOLDSAUSER_TO_ON_STAGE = 3,-- 对在台子上的人，目前即报名了喷风和快刀斩魔
	},

	MESSAGE_SUBTYPE =
	{
		INVALID = 0, -- 无效
		-- = 1, 目前留空
		-- = 2, 目前留空
		DISTANCE = 3, -- 距离相关
	},
 
	-- 第三类型
	MESSAGE_THIRD_TYPE =
	{
		INVALID = 0, -- 无效的
		VALUE_COMPARE = 1, -- 数值对比
	},

	VALUE_OPERATE_TYPE =
	{
		INVALIE = 0, -- 无效
		EQUAL = 1,
		LESS_EQUAL = 2,
		GREAT_EQUAL = 3,
	},

	--相机相关
	NoCreateController = true, --切换相机不创建controller

	--手动切目标相关
	SwitchTarget =
	{
		MaxZDiff = 800,
		SwitchRadius = 3000,	--30米
		SwitchRagle = 80,		--玩家朝向的80度范围内
	},

	--地面指引相关
	NaviDecal =
	{
		bNewVersion = true,
		Disable = false,			--是否禁止地面寻路
		FindPathReqInterval = 4, 	--发包频率间隔 2s
		FindPathDisMin = 800,		--发包请求的最小距离
		ShowEffHeightLimit = 200,	--高度差小于2米，并且FindPathDisMin内，则不显示指引线
		ShowEffMaxDis = 12000,		--能看到指引的最大距离，超过这个距离的不显示；也就是说特效不全部显示出来，走过去了再显示
		HeightOffset = 50,			--向上的偏移	老的是50

		EffLife = 3000,				--特效的生命期
		EffSpeed = 1500,			--1s前进多少
		--下面2个是老方案使用的
		MeshDist = 30,				--mesh之间的距离
		DefaultWidth = 40,			--
	},

	--主界面浮标
	Buoy =
	{
		Disable = false,

		HideDistanceInView = 600,	--浮标在椭圆的视野内不可见的距离
		EllipseWidthMargin = 350,	--控制椭圆的范围
		EllipseHeightMargin = 180,

		CancelTrackDistance = 300,	-- 标记自动取消追踪的距离
		TargetLocationAddZ = 50,	-- 浮标显示位置在原始位置上提高0.5米，原来提高2米会导致浮标和npc头顶本身的图标重叠
		UnActivatedCrystalDistance = 3000, -- 未解锁水晶的追踪浮标判断距离
		TurnDisplayTime = 3000, -- 浮标距离和地图名称轮流显示间隔时间 毫秒
	},

	--动画播放参数
    InjuredAnimationGapTime = 1, --每次播放怪物受击动作后，会有一定的播放间隔，这个时间暂定1秒
	bEnableCheckActionTimelineCopy = true,
	--动画性能相关
	-- bMajorOpenAnimUpdateRateOptimize = false,  --主角是否开启动画性能帧率优化
	-- bOpenAnimUpdateRateOptimize = true,  --是否开启动画性能帧率优化
	LODToFrameSkipMap0 = 0,
	LODToFrameSkipMap1 = 0,
	LODToFrameSkipMap2 = 1,
	BaseNonRenderedUpdateRate = 6,--默认为4。 意为当动画更新没有被渲染时（屏幕外或dedicated servers）。每更新1帧，跳过3帧。 这里设置为6.意为更新一帧跳过5帧
	HeadLODToFrameSkipMap0 = 0,--目前设置脸部会覆盖身体的，这个放后调研
	HeadLODToFrameSkipMap1 = 2,
	HeadLODToFrameSkipMap2 = 3,
	HeadBaseNonRenderedUpdateRate = 12,
	MinAnimUpdateRate = 0,--当游戏低于此帧率，关闭动画帧率优化
	AnimUROCheckTime = 3.0,--MinAnimUpdateRate的检测时间间隔
	bMajorAnimInstanceUseCode = true;  --开关控制主角和玩家动画蓝图使用C++代码
	bEnableForceFeedback = false;
	bWaitForTextureMips = false,		--开关控制UIActor要不要等Mips加载完后再显示
	bWaitForFaceTextureMips = true,		--开关控制角色面妆贴图是否等待Mips加载完成再显示
	bWaitForLegendaryWeaponTextureMips = true,		--开关控制角色面妆贴图是否等待Mips加载完成再显示
	bSyncRHIForFaceTextureMips = true,	--开关控制是否通过同步RHI的方式等待Mips加载完成，false则在主线程定时轮询
	bSyncRHIForLegendaryWeaponTextureMips = true,--开关控制是否通过同步RHI的方式等待传奇武器的Mips加载完成，false则在主线程定时轮询
	bActorFolderPath = false; --角色创建后再inspect窗口中是否有文件路径
	bUnInitAnimBP = true; --动画蓝图回收后
	-- 地图加载时的Loading参数增加的倍数
	bSpeedUpForLoading = true;
	s_AsyncLoadingTimeLimit = 2000;
	s_PriorityAsyncLoadingExtraTime = 3000;
	s_LevelStreamingActorsUpdateTimeLimit = 3000;
	s_PriorityLevelStreamingActorsUpdateExtraTime = 3000;
	s_LevelStreamingComponentsRegistrationGranularity = 100;
	s_LevelStreamingComponentsUnregistrationGranularity = 1000;
	s_UnregisterComponentsTimeLimit = 3000;
	-- end

	bOpenLookAtMajor = false; -- 是否开启所有怪物和NPC强制注视主角测试

	UIActorTag = "UIActorTag"; -- UI展示Actor所用的标签

	bChsVersion = true; -- 是否为国服，目前没有区分国服和国际服的接口，此处接口暂时用于测试

	--actor与移动uro帧率优化
	UroDis1 = 700;--厘米
	UroDis2 = 1000;
	UroDis3 = 2000;
	UroDis4 = 5000;
	UroInterval1 = 100;--毫秒
	UroInterval2 = 200;
	UroInterval3 = 500;
	UroInterval4 = 2000;
	UroMovDis1 = 1000;--厘米
	UroMovDis2 = 2000;
	UroMovDis3 = 3000;
	UroMovDis4 = 4000;
	UroMovInterval1 = 0;--毫秒
	UroMovInterval2 = 50;
	UroMovInterval3 = 100;
	UroMovInterval4 = 2000;

	ActorUROCheckTime = 0.2,
	bNoRenderUro = true; --是否开启不渲染降频
	NoRenderTickLevel = 4;
	NoRenderMovInterval = 1000;

	TeleportTickLevel = 3;--ticklevel大于这个，p3收到包时，进行瞬移

	--- 多语言（本地化）
	CultureName = {
		Chinese 	= "zh",
		Japanese 	= "ja",
		English 	= "en",
		Korean 		= "ko",
		French 		= "fr",
		German 		= "de",
	},

	bMergeDBCache = true;	--是否开启db合并查询

	--behavior start 执行配置，只执行配置的这些ID，方便调试
	bUseBehaviorExecCfg = false;
	bPrintBehaviorExecLog = false;
	BehaviorExecIDList = "";
	BehaviorExecNPCResIDList = "";
	--behavior end

	--特效剔除相关配置
	bEnableDistanceCull = false,                    --是否启用剔除
    VfxCullType = 0,                                --0:logic   1:count
    MajorCullDistanceTolerance = 1000,          	--主角位置变更容错值
    DistanceCullFrequency = 2,                      --剔除执行频率/s
    VfxCullDistance = {2000, 20000, 50000},   		--剔除范围分段
    DistanceRangeUpperLimit = {15, 5, 0},           --剔除范围分段数量限制
    VfxOptimizationUpdateFrequency = 1 / 10,        --降频

	--SpawnActor相关配置
	bUseFraming = true,
	MaxFrameNum = 3,
	TickInterval = 0,
	SpawnActorClasses = "BP_PortalLine.BP_PortalLine_C,TriggerCapsule.TriggerCapsule,TriggerBox.TriggerBox",

	-- 强锁效果Mask
	HardLockEffectMaskType = {
		Photo = 0,  -- 拍照
		SecondMenu = 1, --二级菜单
	},

	-- 冲刺特效相关配置
	SprintEffectBuffIDList = {999, 998},	-- 冲刺Buff列表，这个列表中的冲刺Buff才可以触发冲刺特效（拖尾、脚印，情感动作脚印等）
	EmotionFootprintBuffID = 992,			-- 情感动作播放时，如果身上有这个Buff，也可以触发脚印特效，用于冲刺结束后给玩家操作情感动作的缓冲时间
	SprintEffectFadingOutTime = 2000,		-- 冲刺Buff结束前，冲刺拖尾开始提前消失的时间

	-- TODO[chaooren] 技能定时器延时方案开关
	bUseSkillTimerDelay = true,
	bPreLoadCommRewardPannel = true,       --商城界面购买界面预加载
	bOpenUseCustomProcessLevelStreaming = true, --是否开启：使用自定义的LevelStreaming处理机制（打开带角色模型的UI时）
}
return CommonDefine