--
-- Author: anypkvcai
-- Date: 2020-11-12 17:00:18
-- Description:
--


---@class MoveConfig
local MoveConfig = {
	EnableSelfLog = 0;
	EnableOthersLog = 0;
	EnableMoveFrameLog = 0;
	EnableArtPathLog = 0;
	EnableClimbLog = 0;
	OpenServerPos = 0;
	EnableArtPathVisualization = 0;
	ArtPathVisualizeInterval = 1.0 / 30.0;
	SyncTimeIdle = -1.0; --4.0;--2.0;
	SyncTimeFall = 0.5;
	SyncTimeRun = 1.0; --0.5;
	SyncTimeVault = 0.2;
	SyncTimeRunAndTurn = 0.05;
	SyncTimeArtPath = 0;
	SyncTimeMaxInterval = 500;
	MoveSyncFactor = 0.0;
	PathStateSyncFactor = 0.0;
	MovingSpeedFactor = 1.0;
	SprintSpeedF = 0.0;
	SprintSpeedFL = 0.0;
	MaxPredictTime = 1.0;
	PredictAllowFallingTime = 1.1;
	MinSyncDistance = 5.0;
	MaxSpeedToLastPos = 600.0;
	ForceToLastPos = 1;
	MaxVaultDuration = 4.0;
	EnableMotionLog = 0;
	StillSpeedThreshold = 0.01;
	bInterpAt1stStopAfterMove = 1;
	bUpdate3thPosAtStopNotify = 1;
	MoveInterpType = 1;
	MoveInterpTime = 0.1;
	MoveInterpFactor = 1.0;
	MoveInterpTanScale = 0.05;
	RotInterpTime = 0.3;
	RotInterpSpeed = 720.0;
	FallingInterpTime = 0.2;
	PathInterpType = 2;
	PathInterpTime = 0.3;
	PathInterpTanScale = 0.05;
	--调试开关
	DebugPlayer = 0;
	DebugOthers = 0;
	DebugIconScale = 1.0;
	AdjustFloorTraceRange = 200.0;
	AdjustFloorTraceDist = 100000.0;
	AdjustFloorTraceRadiusThreshold = 2.0;	--执行AdjustFloor时，减少Trace半径的大小，避免因为后台同步坐标的误差引起的碰撞问题
	DebugUnmovable = 0;
	Grounding = 0;
	EnableMoveRecord = 0;
	EnableRecordPrint = 0;
	RecordMovementComp = 1;
	MaxMoveRecordNum = 5;
	PrintLocType = 3;
	DebugGeoDuration = 10.0;
	DebugLineThickness = 2.0;
	DebugBoxWidth = 10.0;
	DebugBoxHeight = 30.0;
	DebugConeHeight = 50;
	DebugConeAngleDegree = 30;
	DebugConeSlices = 12;
	DebugArrowSize = 20;
	DebugArrowThickness = 1.5;
	Debug1 = 1;
	Debug2 = 1;
	Debug3 = 1;
	Debug4 = 1;
	EnableDebugSelfMoveLine = 0;

	bSyncUsePhyVelocity = 0;
	STFallingSpeed = 1000.0;
	FallingFeqFactor = 0.2;
	SyncThresholdYaw = 30.0;
	SkillSyncThresholdYaw = 2.0;
	SyncThresholdPitch = 15.0;
	SyncThresholdVelocityAndAcceleration = 15.0;
	SyncThresholdSpeed = 100.0;
	SyncThresholdSpeedChange = 60.0; -- 速度变化上报阈值
	ThresholdSpeedInternal = 0.33; -- 速度变化阈值检测间隔
	ThresholdMinInterval = 0.1;
	SyncHistoryInterval = 0.2; -- 上报轨迹点采样间隔时间
	SyncHistoryNum = 5; -- 上报轨迹点个数
	DefaultGravity = -980.0;
	SimulatedGravityFactor = 1.3;
	FallingPredictTime = 0.5;
	FallingSweep = 1;
    FallingAccelFactor = 1.0; --下落控制最大加速度系数，直接乘在默认最大加速度上
    FallingMaxSpeedFactor = 1.2; --下落控制最大速度系数，直接乘在默认最大速度上

	bCacheMoveMsgForClientModePlayer = true;	--如果其他玩家进入ClientMode，是否缓存最后一个移动包用于恢复

	bUsePressJumpForP3 = 1;

	bUsePlayerController = 1;
	DefaultMaxWalkSpeed = 600;
	NpcPerchRadiusThreshold = 50.0; --ENPC/BNPC移动到边缘的半径阀值
	PlayerPerchRadiusThreshold = 35.0; --玩家使用移动到边缘的半径阀值
	bUsePlaySpecialFindFloor = 1; --玩家是否使用特殊浮空判定
	SpecialMaxLineFloorDist = 1000.1; --玩家使用特殊浮空判定时的最长射线
	SpecialMaxLineHeight = 310.1; --玩家使用特殊浮空判定时两次检查的高度差决定是否浮空
	FallingPerchRadiusThreshold = 50;	--跳跃时PerchRadiusThreshold，调大可以防止跳跃时通过胶囊体边缘蹭上超过跳跃高度的平台
	JumpPerchHeightThreshold = 120;		--跳跃时超过起跳高度一定距离时才使用FallingPerchRadiusThreshold

	CapsuleHalfHeight = 100;
	CapsuleRadius = 50;
	MaxWalkDegreeUp = 70;--美术位移最大可行走角度，单位角度（初始为50，因容易起步渗透导致原地跳问题，先暂时改为70）
	DeltaHeightLimit = 100000;--射线检测高度，此高度内有落脚点则会向前移动，否则停止
	StartPosOffset = 30; --射线检测开始点的偏移
	NearFloorDeltaHeightLimit = 200;--射线检测高度，此高度内有落脚点，则会贴地
	AVG_FLOOR_DIST = 2.15;

	LineTraceUseSweepDelta = 1000;
	SprintMinSpeed = 550;--速度超过此值时开启疾驰

	PlayerMinPosOffest = 30.0;--其他玩家移动模拟时，允许的位置误差
	NpcMinPosOffest = 5.0;--Npc移动模拟时，允许的位置误差
	MajorRotatorSpeed = -1;	--主角转向速度 小于0表示不开启此项控制
	PlayerRotatorTime = 0.33; --主角和其他玩家转向的时间
	PlayerTurnMinPosOffest = 20.0;--其他玩家移动模拟时，从一个关键点转向下一个关键点的误差

	PlayerMinInputSpeed = 180;		--玩家输入的最小速度
	PlayerCombatMinInputSpeed = 520;--战斗状态下玩家输入的最小速度
	-- movepath
	MonsterStartPosOffset = 100.0;--怪物起始点和客户端当前位置允许的误差
	EnableMonsterCumulativeError = true; --是否开启怪物累计误差
	MonsterCheckIntervalTime = 200; --怪物位置检查间隔时间，单位毫秒
	MonsterOffsetTimeFactor = 0.5; --怪物允许误差的时间系数
	MonsterSpeedCorrectionFactor = 0.6;--怪物速度修正系数


	ReverseTurnTime = 2.0;			--折返跑转向时间，单位秒，也是锁定原地的时间（提前结束来做动作融合）
	ReverseCareSpeed = 500;				--折返跑关心的速度，单位厘米每秒
	ReverseMinCareTime = 400;			--折返跑关心的时间，单位毫秒

	-- LookAt相关参数Start
	bOpenLookAtLog  = 0;                    -- 通用Look At日志
	MinLookAtDist = 15.0;                   -- 通用Look At距离限制下限
	MaxLookAtDist = 1000.0;                 -- 通用Look At距离限制上限
	LookAtAngleRange = 110.0;               -- 通用Look At角度限制
	ForwardLookAtDist = 2000.0;				-- 正面朝向目标时解除Look At的距离
	LateralLookAtDist = 1000.0;				-- 侧面朝向目标时解除Look At的距离
	BackLookAtDist = 500.0;					-- 反面朝向目标时解除Look At的距离
	CombatForwardLookAtDist = 2000.0;		-- 处于战斗状态、正面朝向目标时解除Look At的距离
	CombatLateralLookAtDist = 1000.0;		-- 处于战斗状态、侧面朝向目标时解除Look At的距离
	CombatBackLookAtDist = 500.0;			-- 处于战斗状态、反面朝向目标时解除Look At的距离
	bUseCombatLookAt = 1;					-- 是否开启战斗待机的Look At功能
	LookAtSlowDownAngle = 60.0;				-- CVM 模式下Look At开启减速的角度
	NormalLookAtInterpSpeed = 3.0;			-- 通常的Look At插值速度
	SlowDownLookAtInterpSpeed = 2.0;		-- CVM 模式下减速后的Look At插值速度
	NormalLookAtAngleRange = 90.0;			-- 通常的Look At左右角度范围
	CombatLookAtAngleRange = 45.0;			-- 战斗状态中Look At左右角度范围
	bInSkillLookAt = 0;                     -- 是否开启放技能过程中LookAt

	LayDiffHeight = 20.0;                   -- 躺下时Root和Lookat挂点允许高度差
	BaseBackboneFactor = 0.85;              -- 头部和背骨分配比例
	OnlyHeadFactor = 1.0;                   -- 只转头时的比例
	
	OwnerHumanSocketBuffer = 30.0;          -- 挂点浮动允许范围
	OwnerDemiSocketBuffer = 30.0;
	OwnerLocationBuffer = 20.0;
	TargetSocketBuffer = 50.0;

	bCheckSpineLimit = 1;               -- 是否检查父骨骼导致的角度限制
	SpinePitchThreshold = 8.0;              -- 父骨骼pitch限制阈值
    -- LookAt相关参数End


	JumpCollisionSyncVelocityOffset = 1.0;	-- 跳跃模式下碰撞后速度误差(超过就同步)
	FieldOfForceOffset = 30.0;	--力场误差
	bDisableFaceToTarget = 1;	--是否关闭靶向运动
	RunVelocityValue = 200.0;	--角色脚步声判断当前是walk或者run的分界值

	--特殊跳跃
	SpecialJumpJoystickShowTime = 0;			--特殊跳跃摇杆显示的时间，0则立刻显示
	SpecialJumpJoystickDeadZoneSize = 0.05;		--特殊跳跃摇杆死区大小

	bMaxPressDurationIncludeAnimDuration = false;	--按压时长是否包含起跳动画时长，如果不包含则在达到最大按压时长后才会开始播放起跳动画，否则会提前播放起跳动画

	JumpTeleportThreshold = 1000;	--起跳时传送的距离阈值，超过此距离直接传送，否则加速移动到起跳点
	JumpFastForwardTime = 0.2;		--起跳时加速移动到起跳点的时间
	JumpFastForwardSpeed = 880;		--起跳时加速移动的速度

	--攀爬相关
	bOpenClimb = 1; --攀爬开关
	ClimbCheckInterval = 200;--攀爬与翻越检测间隔，单位毫秒
	FallingClimbCheckInterval = 50;--掉落时攀爬与翻越检测间隔，单位毫秒
	FlyCheckInterval = 100;  --飞行检测地面间隔，单位毫秒
	SwimCheckInterval = 100; --游泳检测水面间隔，单位毫秒

	FallingToFlyingInterval = -1; --坐骑状态下，若解锁了飞行，持续Falling状态一定时间以后就会进入飞行状态，单位毫秒，小于0时不启用此功能
	FlyingHighHeight = 300; --判断坐骑为高空飞行的高度，从胶囊体底部开始计算

	MaxLedgeHeight = 150.0;--角色最大胶囊体半高
	MinLedgeHeight = 50.0;--角色最小胶囊体半高，实际用到的是(MinLedgeHeight+MaxLedgeHeight)/2
	ReachDistance = 70.0;--攀爬第一步碰撞检测左右碰撞射线长度
	ForwardTraceRadius = 30.0;--攀爬第一步碰撞检测胶囊体半径
	DownwardTraceRadius = 50.0;--攀爬第二步碰撞检测射线从第一步碰撞点抬高的高度为(MaxLedgeHeight+DownwardTraceRadius)
	ThrowOverDistance = 150.0;--翻越的长度（从起始点到翻越终止点）
	ThrowOverTraceDepthDistance = 500.0;--翻越竖直碰撞的射线长度
	ThrowOverZOfset = 50.0;--如果翻越点高度小于起始坐标高度+ThrowOverZOfset，才认为是翻越
	OpenThrowOver = 0; --是否开启翻越
	ClimbTime = 2000;--攀爬时间，单位毫秒
	MaxClimbTime = 10000;--程序保护的最大攀爬时间，单位毫秒
	ClimbHighHeight = 125;--攀爬点大于ClimbHighHeight，须输入跳跃才能进行
	--

	-- ShadowTracer相关
	MaxEndureDelay = 1.0;
	RecoverDelay = 0.1;
	SpeedPredictCertainty = 0.5;
	TimeToDrag = 4.0;

	-- 飞行潜水速度相关
	FlyingMoveRunAccel = 3000;
	FlyingMoveRunSpeed = 2000;
	FlyingMoveWalkAccel = 2400;
	FlyingMoveWalkSpeed = 900;

	DivingMoveRunAccel = 3000;
	DivingMoveRunSpeed = 600;
	DivingMoveWalkAccel = 2400;
	DivingMoveWalkSpeed = 240;
	DivingMoveRunSpeedMount = 2000;
	DivingMoveWalkSpeedMount = 900;

	FlyModelOffset = 0;

	EnableMoveAudioLog = 0;--行走脚步声/飞行声音频调用日志开关

	SwimEffectFadeTime = 2.0; -- 游泳特效淡出时间

	-- MovePath相关
	UTurnAngleThreshold = 45.0;

	bOpenQueryLog = 0; --贴地日志

	--从碰撞体中脱困相关
	MaxEscapeFromGeometryCounter = 20;			--默认脱困处理等待帧数
	MaxEscapeFromGeometryCounterInDungeon = 2; 	--副本中脱困处理等待帧数


	bOpenNoVelocityTick = 1; --没有速度时的tick间隔优化开关
	NoVelocityTickInterval = 0.333;--没有速度时的tick间隔

	bOpenIKConfig = 0; -- 所有角色ik开关

	CharaSEFadeTime = 1.0; --角色音效谈出时间

	MoveDirectTypeThreshold = 10.0; --坐骑动画蓝图中判断角色向前移动的界限值  

	-- 区分走路/跑/疾跑动作
	AnimWalkSpeed = 200.0; -- 走路动作速度界限
	AnimRunSpeed = 660.0; -- 跑步动作速度界限

	SendMoveDashInterval = 1.0;

	-- 摇杆盲区比例
	JoystickBlindScale = 0.2;

	-- 自动寻路
	FindPathServerLimitDist = 1000; --后台拉扯的最大距离，超过距离会进行通知

	bEnsureMoveStrategy = 1; --保证移动策略不为空

	SummonOffsetZ = 100; --召唤物高度偏差值

	bServerRaycast = 1; -- 后台拉扯打射线

	bLogCombatState = 1; --战斗状态日志

	bSelfResIgnore = 1;  -- 客户端非控制状态保护，不响应stop包
}

return MoveConfig