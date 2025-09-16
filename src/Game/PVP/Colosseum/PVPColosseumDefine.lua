--
-- Author: peterxie
-- Date:
-- Description: 水晶冲突玩法数据定义
--


---常量定义
local ColosseumConstant =
{
	COLOSSEUM3_CHECK_POINT_PROGRESS_PERMIL = 500, -- 单侧最大进度是1000，检查点在中心500位置
	COLOSSEUM3_OFFENSE_CHECK_POINT_BROKEN = 1000, -- 攻击检查点突破进度最大值1000

	CRYSTAL_CIRCLE_VFX_COOLDOWN_TIME = 0.5, -- 水晶圆环特效冷却时间
	CRYSTAL_BINDING_MODEL_STATE = 11, -- 水晶绑定模型状态

	EXD_VFX_MKS_CRYSTAL_IDLE = 1263,		-- クリスタルステータス：中立_
	EXD_VFX_MKS_CRYSTAL_ALLY = 1264,		-- クリスタルステータス：味方_
	EXD_VFX_MKS_CRYSTAL_ENEMY = 1265,		-- クリスタルステータス：敵_
	EXD_VFX_MKS_CRYSTAL_OVERTIME = 1266,	-- 加时赛特效，SERes640还没有，资源是手游原创
	EXD_VFX_MKS_CRYSTAL_INACTIVE = 1299,	-- 水晶锁定特效，配合锁定动作使用，改由业务控制，目前机制直接在动作里配置衔接效果达不到策划要求

	EXD_BNPC_BASE_MKS_CRYSTAL = 13026002,	-- タクティカルクリスタル：原種：MKS：共通_

	MaxMemberNum = 5, -- 水晶冲突队伍成员最大数量
	CrystalCircleDistance = 5, -- 水晶圈内判断距离
	OverTimeCountDown = 3, -- 加时赛劣势方出圈判输倒计时3秒
}

local AudioPath =
{
	CountDown = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_countdown_1.Play_UI_countdown_1'",

	IntroductionIn = "AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/etc/SE_Bt_Etc_MKS_SE_Banner_allies_in/Play_SE_Bt_Etc_MKS_SE_Banner_allies_in.Play_SE_Bt_Etc_MKS_SE_Banner_allies_in'",
	IntroductionOut = "AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/etc/SE_Bt_Etc_MKS_SE_Banner_allies_out/Play_SE_Bt_Etc_MKS_SE_Banner_allies_out.Play_SE_Bt_Etc_MKS_SE_Banner_allies_out'",

	[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_IDLE] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/monster8/SE_Vfx_Monster_m0769_stlp02/Play_SE_Vfx_Monster_m0769_stlp02.Play_SE_Vfx_Monster_m0769_stlp02'",
	[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_ALLY] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/monster8/SE_Vfx_Monster_m0769_stlp03/Play_SE_Vfx_Monster_m0769_stlp03.Play_SE_Vfx_Monster_m0769_stlp03'",
	[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_ENEMY] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/monster8/SE_Vfx_Monster_m0769_stlp04/Play_SE_Vfx_Monster_m0769_stlp04.Play_SE_Vfx_Monster_m0769_stlp04'",
}

---队伍定义
---注：我方队伍为蓝方，敌方队伍为红方
---注：端游队伍定义里，有时候称为A队和B队，观战队伍固定为左侧蓝队
local ColosseumTeam =
{
    COLOSSEUM_TEAM_1 = 1, -- 1队即星极队，在屏幕左侧
    COLOSSEUM_TEAM_2 = 2, -- 2队即灵极队，在屏幕右侧
    COLOSSEUM_TEAM_MAX = 2,
}

local PVPCOLOSSEUM_TEAM =
{
	PVPCOLOSSEUM_TEAM_BLUE = 1,
	PVPCOLOSSEUM_TEAM_RED = 2,

	PVPCOLOSSEUM_MKS_TEAM1 = 1,
	PVPCOLOSSEUM_MKS_TEAM2 = 2,
}


--region 水晶相关

---水晶目的地定义
local ColosseumCrystalDestination =
{
    COLOSSEUM3_CRYSTAL_DESTINATION_CENTER = 0,      	-- 中央
    COLOSSEUM3_CRYSTAL_DESTINATION_TEAM_1 = 1,          -- チーム1陣地
    COLOSSEUM3_CRYSTAL_DESTINATION_TEAM_2 = 2,          -- チーム2陣地
    COLOSSEUM3_CRYSTAL_DESTINATION_DEADLOCKED = 3,      -- 膠着状態で不定
    COLOSSEUM3_CRYSTAL_DESTINATION_MAX = 4,
}

---水晶状态定义
local ColosseumCrystalState =
{
    COLOSSEUM3_CRYSTAL_STATE_INACTIVE = 0,                  	-- 拘束中
    COLOSSEUM3_CRYSTAL_STATE_NEUTRAL = 1,                       -- 無人停止中/中央帰還中
    COLOSSEUM3_CRYSTAL_STATE_ALLY = 2,                          -- 味方攻撃移動中
    COLOSSEUM3_CRYSTAL_STATE_ENEMY = 3,                         -- 敵攻撃移動中
    COLOSSEUM3_CRYSTAL_STATE_ALLY_LONGEST = 4,                  -- 味方攻撃最長移動中
    COLOSSEUM3_CRYSTAL_STATE_ENEMY_LONGEST = 5,                 -- 敵攻撃最長移動中
    COLOSSEUM3_CRYSTAL_STATE_ALLY_CHECK_POINT_BREAKING = 6,     -- 味方攻撃チェックポイント攻略中
    COLOSSEUM3_CRYSTAL_STATE_ENEMY_CHECK_POINT_BREAKING = 7,    -- 敵攻撃チェックポイント攻略中
    COLOSSEUM3_CRYSTAL_STATE_DEADLOCKED = 8,                    -- 膠着状態
    COLOSSEUM3_CRYSTAL_STATE_MAX = 9,
}

---水晶圆环特效
local ColosseumCrystalVFX =
{
	[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_IDLE] = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/Common/VBP/BP_mks_cry_st_ne0t_fm001.BP_mks_cry_st_ne0t_fm001_C'",
	[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_ALLY] = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/Common/VBP/BP_mks_cry_st_ow0t_fm001.BP_mks_cry_st_ow0t_fm001_C'",
	[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_ENEMY] = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/Common/VBP/BP_mks_cry_st_en0t_fm001.BP_mks_cry_st_en0t_fm001_C'",

	[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_OVERTIME] = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/Common/VBP/BP_mks_cry_st_ow0t_gold_fm001.BP_mks_cry_st_ow0t_gold_fm001_C'",
	[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_INACTIVE] = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/Common/VBP/BP_m0769_cbbm_idle_c0g.BP_m0769_cbbm_idle_c0g_C'",
}

---水晶动作
local ColosseumCrystalActionTimeline =
{
	[0] = "battle/idle",			-- 初始封印
	[1] = "idle_sp/idle_sp_1", 		-- 移动/静止
	[2] = "idle_sp/idle_sp_1",		-- 端游代码里水晶往敌我方移动的动作有区分，策划说表现是一样
	[3] = "idle_sp/idle_sp_1",
	[4] = "mon_sp/m0769/mon_sp001", -- 解除封印
	[5] = "mon_sp/m0769/mon_sp002", -- 胜利
}

---水晶UI状态
local ColosseumHeaderCrystalState =
{
	PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_INACTIVE = 1,
	PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_NEUTRAL = 2,
	PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA = 3,
	PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA_CHECK = 4,
	PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB = 5,
	PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB_CHECK = 6,
	PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_DEADLOCK = 7,
}

---水晶UI图标
local ColosseumHeaderCrystalIcon =
{
	-- 水晶状态图标
	Default = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_CrystalLock_png.UI_PVPMain_Img_CrystalLock_png'",
	Wait = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_CrystalNo_png.UI_PVPMain_Img_CrystalNo_png'",
	DeadLock = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_CrystalVie_png.UI_PVPMain_Img_CrystalVie_png'",
	Blue = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_CrystalBlue_png.UI_PVPMain_Img_CrystalBlue_png'",
	Red = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_CrystalRed_png.UI_PVPMain_Img_CrystalRed_png'",

	-- 水晶突破图标
	Blue_Light = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_BreachBlue_png.UI_PVPMain_Img_BreachBlue_png'",
	Red_Light = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_BreachRed_png.UI_PVPMain_Img_BreachRed_png'",

	-- 水晶方向图标
	Blue_Left = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_AdvanceBlueL_png.UI_PVPMain_Img_AdvanceBlueL_png'",
	Blue_Right = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_AdvanceBlueR_png.UI_PVPMain_Img_AdvanceBlueR_png'",
	Red_Left = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_AdvanceRedL_png.UI_PVPMain_Img_AdvanceRedL_png'",
	Red_Right = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_AdvanceRedR_png.UI_PVPMain_Img_AdvanceRedR_png'",
}

---检查点UI状态
local ColosseumHeaderCheckState =
{
	PVPCOLOSSEUM_HEADER_CHECK_STATE_DEFAULT = 1,
	PVPCOLOSSEUM_HEADER_CHECK_STATE_ATTACK = 2, -- 正在被突破中
	PVPCOLOSSEUM_HEADER_CHECK_STATE_BREAK = 3, -- 已被突破
}

---检查点UI图标
local ColosseumHeaderCheckIcon =
{
	Blue_Attack = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_GoalBlue_png.UI_PVPMain_Img_GoalBlue_png'",
	Blue_Break = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_GoalBreachBlue_png.UI_PVPMain_Img_GoalBreachBlue_png'",
	Red_Attack = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_GoalRed_png.UI_PVPMain_Img_GoalRed_png'",
	Red_Break = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_GoalBreachRed_png.UI_PVPMain_Img_GoalBreachRed_png'",
}

--endregion


--region 地图标记相关

---地图标记图标ID定义
local ColosseumMapMarkerIcon =
{
	-- 地图水晶标记图标
	EXD_ICON_MAP_MARKER_MKS_CRYSTAL_INACTIVE = 63935,		-- マップマーカー：MKS：タクティカルクリスタル・拘束状態_
	EXD_ICON_MAP_MARKER_MKS_CRYSTAL_NEUTRAL = 63936,		-- マップマーカー：MKS：タクティカルクリスタル・待機（中立）_
	EXD_ICON_MAP_MARKER_MKS_CRYSTAL_ALLY = 63937,			-- マップマーカー：MKS：タクティカルクリスタル・自軍占有状態_
	EXD_ICON_MAP_MARKER_MKS_CRYSTAL_ENEMY = 63938,			-- マップマーカー：MKS：タクティカルクリスタル・敵軍占有状態_
	EXD_ICON_MAP_MARKER_MKS_CRYSTAL_DEADLOCKED = 63939,		-- マップマーカー：MKS：タクティカルクリスタル・膠着状態_

	-- 地图SG标记图标
	EXD_ICON_MAP_MARKER_MKS_CHECKPOINT_ALLY = 63940,		-- マップマーカー：MKS：チェックポイント・自陣・平常時_
	EXD_ICON_MAP_MARKER_MKS_CHECKPOINT_BROKEN_ALLY = 63941,	-- マップマーカー：MKS：チェックポイント・自陣・突破後_
	EXD_ICON_MAP_MARKER_MKS_CHECKPOINT_ENEMY = 63942,		-- マップマーカー：MKS：チェックポイント・敵陣・平常時_
	EXD_ICON_MAP_MARKER_MKS_CHECKPOINT_BROKEN_ENEMY = 63943,-- マップマーカー：MKS：チェックポイント・敵陣・突破後_
	EXD_ICON_MAP_MARKER_MKS_GOAL_ALLY = 63944,				-- マップマーカー：MKS：ゴール・自陣_
	EXD_ICON_MAP_MARKER_MKS_GOAL_ENEMY = 63945,				-- マップマーカー：MKS：ゴール・敵陣_
	EXD_ICON_MAP_MARKER_MKS_BASE_ALLY = 63946,				-- マップマーカー：MKS：スタート地点・自陣_
	EXD_ICON_MAP_MARKER_MKS_BASE_ENEMY = 63947,				-- マップマーカー：MKS：スタート地点・敵陣_
}


-- 关卡SG InstanceID定义，参考自端游关卡数据 s5p1.h s5p2.h s5p3.h --

local LAYOUT_S5P1_SG_STARTWALL_BLUE_01 = 9033509
local LAYOUT_S5P1_SG_STARTWALL_RED_01 = 9033510
local LAYOUT_S5P1_SG_CHECK_01 = 9056521
local LAYOUT_S5P1_SG_CHECK_02 = 9056522
local LAYOUT_S5P1_SG_GOAL_01 = 9056523
local LAYOUT_S5P1_SG_GOAL_02 = 9056525

local LAYOUT_S5P2_SG_STARTWALL_BLUE_01 = 8959097
local LAYOUT_S5P2_SG_STARTWALL_RED_01 = 8959659
local LAYOUT_S5P2_SG_CHECK_01 = 9056529
local LAYOUT_S5P2_SG_CHECK_02 = 9056530
local LAYOUT_S5P2_SG_GOAL_01 = 9056531
local LAYOUT_S5P2_SG_GOAL_02 = 9056532

local LAYOUT_S5P3_SG_STARTWALL_BLUE_01 = 9038820
local LAYOUT_S5P3_SG_STARTWALL_RED_01 = 9038818
local LAYOUT_S5P3_SG_CHECK_01 = 9060121
local LAYOUT_S5P3_SG_CHECK_02 = 9060123
local LAYOUT_S5P3_SG_GOAL_01 = 9060119
local LAYOUT_S5P3_SG_GOAL_02 = 9060120

-- 地图场地SG，直接用InstanceID
local LAYOUT_S5P1_SG_FIELD_01 = 9060224
local LAYOUT_S5P2_SG_FIELD_01 = 9060485
local LAYOUT_S5P3_SG_FIELD_01 = 9064770


---地图标记SG类型定义
local ColosseumMapMarkerLayoutType =
{
	MAP_MARKER_LAYOUT_BASE = 1,        -- 拠点扉SG
	MAP_MARKER_LAYOUT_CHECK_POINT = 2, -- チェックポイントSG
	MAP_MARKER_LAYOUT_GOAL = 3,        -- ゴールSG
	MAP_MARKER_LAYOUT_MAX = 3,
}


---地图SG标记定义，用于获取标记坐标，用MapID区分
local ColosseumMapLayouts =
{
	-- 地图S5P1
	[2017] =
	{
		-- 队伍1这边的SG
		[1] =
		{
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_BASE] = LAYOUT_S5P1_SG_STARTWALL_BLUE_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_CHECK_POINT] = LAYOUT_S5P1_SG_CHECK_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_GOAL] = LAYOUT_S5P1_SG_GOAL_01,
		},
		-- 队伍2这边的SG
		[2] =
		{
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_BASE] = LAYOUT_S5P1_SG_STARTWALL_RED_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_CHECK_POINT] = LAYOUT_S5P1_SG_CHECK_02,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_GOAL] = LAYOUT_S5P1_SG_GOAL_02,
		},
		-- 地图场地SG
		Field = LAYOUT_S5P1_SG_FIELD_01,
		-- 入场动画
		SequencePath = "LevelSequence'/Game/Assets/Cut/ffxiv/pvpmks/pvpmks06010/pvpmks06010_proj/pvpmks06010.pvpmks06010'",
	},

	-- 地图S5P2
	[2022] =
	{
		[1] =
		{
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_BASE] = LAYOUT_S5P2_SG_STARTWALL_BLUE_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_CHECK_POINT] = LAYOUT_S5P2_SG_CHECK_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_GOAL] = LAYOUT_S5P2_SG_GOAL_01,
		},
		[2] =
		{
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_BASE] = LAYOUT_S5P2_SG_STARTWALL_RED_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_CHECK_POINT] = LAYOUT_S5P2_SG_CHECK_02,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_GOAL] = LAYOUT_S5P2_SG_GOAL_02,
		},
		Field = LAYOUT_S5P2_SG_FIELD_01,
		SequencePath = "LevelSequence'/Game/Assets/Cut/ffxiv/pvpmks/pvpmks06020/pvpmks06020_proj/pvpmks06020.pvpmks06020'",
	},

	-- 地图S5P3
	[2023] =
	{
		[1] =
		{
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_BASE] = LAYOUT_S5P3_SG_STARTWALL_BLUE_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_CHECK_POINT] = LAYOUT_S5P3_SG_CHECK_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_GOAL] = LAYOUT_S5P3_SG_GOAL_01,
		},
		[2] =
		{
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_BASE] = LAYOUT_S5P3_SG_STARTWALL_RED_01,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_CHECK_POINT] = LAYOUT_S5P3_SG_CHECK_02,
			[ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_GOAL] = LAYOUT_S5P3_SG_GOAL_02,
		},
		Field = LAYOUT_S5P3_SG_FIELD_01,
		SequencePath = "LevelSequence'/Game/Assets/Cut/ffxiv/pvpmks/pvpmks06030/pvpmks06030_proj/pvpmks06030.pvpmks06030'",
	},
}

--endregion


--region 战场日志相关

---战场日志倒计时预警
local ColosseumLogInfoID =
{
	PVPCOLOSSEUM_LOG_INFO_ID_CRYSTAL = 1, -- クリスタル拘束解除
	PVPCOLOSSEUM_LOG_INFO_ID_ERUPTION_EXEC = 2, -- 噴火発動
	PVPCOLOSSEUM_LOG_INFO_ID_TORNADO_EXEC = 3, -- 突風発動
	PVPCOLOSSEUM_LOG_INFO_ID_FESTIVAL_EXEC = 4, -- 祭り発動
}

---战场日志类型
local ColosseumLogType =
{
	MKS_LOG_TYPE_KNOCKOUT = 1,
	MKS_LOG_TYPE_CRYSTAL_UNLOCKED = 2,	-- クリスタルの拘束が解除された
	MKS_LOG_TYPE_PASS_CHECKPOINT_TEAM_1 = 3,	-- チーム1がチェックポイントを通過した
	MKS_LOG_TYPE_PASS_CHECKPOINT_TEAM_2 = 4,	-- チーム2がチェックポイントを通過した
	MKS_LOG_TYPE_ERUPTION_EXEC = 5,	-- 火山噴火
	MKS_LOG_TYPE_ERUPTION_FINISH = 6,
	MKS_LOG_TYPE_TORNADO_EXEC = 7,	-- 竜巻
	MKS_LOG_TYPE_TORNADO_FINISH = 8,
	MKS_LOG_TYPE_FESTIVAL_EXEC = 9,	-- 祭り
	MKS_LOG_TYPE_FESTIVAL_FINISH = 10,
	MKS_LOG_TYPE_MAX = 11,
}

---战场日志图标配置
local ColosseumLogIcon =
{
	-- 事件日志图标
	PVPCOLOSSEUM_LOG_ICON_KNOCKOUT_BLUE = "", -- 没用到
	PVPCOLOSSEUM_LOG_ICON_KNOCKOUT_RED = "", -- 没用到
	PVPCOLOSSEUM_LOG_ICON_CRYSTAL_UNLOCKED = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_PVPMKSInfo3_png.UI_PVPMain_Img_PVPMKSInfo3_png'", -- 水晶解锁
	PVPCOLOSSEUM_LOG_ICON_CRYSTAL_UNLOCKED_2 = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_PVPMKSInfo6_png.UI_PVPMain_Img_PVPMKSInfo6_png'", -- 水晶解锁
	PVPCOLOSSEUM_LOG_ICON_PASS_CHECKPOINT_BLUE = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_PVPMKSInfo5_png.UI_PVPMain_Img_PVPMKSInfo5_png'", -- 蓝队通过检查点
	PVPCOLOSSEUM_LOG_ICON_PASS_CHECKPOINT_RED = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_PVPMKSInfo4_png.UI_PVPMain_Img_PVPMKSInfo4_png'", -- 红队通过检查点
	PVPCOLOSSEUM_LOG_ICON_ERUPTION = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_PVPMKSInfo2_png.UI_PVPMain_Img_PVPMKSInfo2_png'", -- 火山
	PVPCOLOSSEUM_LOG_ICON_TORNADO = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Img_PVPMKSInfo1_png.UI_PVPMain_Img_PVPMKSInfo1_png'", -- 暴风
	PVPCOLOSSEUM_LOG_ICON_FESTIVAL = "", -- 祭典

	-- 事件日志背景
	LeftTipsRed = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_LeftTipsRed.UI_PVPMain_Img_LeftTipsRed'",
	LeftTipsGrey = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_LeftTipsGrey.UI_PVPMain_Img_LeftTipsGrey'",
	LeftTipsBlue1 = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_LeftTipsBlue1.UI_PVPMain_Img_LeftTipsBlue1'",
	LeftTipsBlue2 = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_LeftTipsBlue2.UI_PVPMain_Img_LeftTipsBlue2'",

	-- 击杀日志职业图标背景
	ProfBlueBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Icon_KillBlue_png.UI_PVPMain_Icon_KillBlue_png'",
	ProfRedBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Icon_KillRed_png.UI_PVPMain_Icon_KillRed_png'",
}

--endregion


local PVPColosseumDefine =
{
	ColosseumConstant = ColosseumConstant,
	ColosseumTeam = ColosseumTeam,
	AudioPath = AudioPath,

	ColosseumCrystalState = ColosseumCrystalState,
	ColosseumCrystalDestination = ColosseumCrystalDestination,
	ColosseumCrystalVFX = ColosseumCrystalVFX,
	ColosseumCrystalActionTimeline = ColosseumCrystalActionTimeline,

	ColosseumHeaderCrystalState = ColosseumHeaderCrystalState,
	ColosseumHeaderCrystalIcon = ColosseumHeaderCrystalIcon,
	ColosseumHeaderCheckState = ColosseumHeaderCheckState,
	ColosseumHeaderCheckIcon = ColosseumHeaderCheckIcon,

	ColosseumMapMarkerLayoutType = ColosseumMapMarkerLayoutType,
	ColosseumMapLayouts = ColosseumMapLayouts,
	ColosseumMapMarkerIcon = ColosseumMapMarkerIcon,

	ColosseumLogInfoID = ColosseumLogInfoID,
	ColosseumLogType = ColosseumLogType,
	ColosseumLogIcon = ColosseumLogIcon,
}

return PVPColosseumDefine