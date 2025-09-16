--
-- Author: anypkvcai
-- Date: 2022-11-08 10:54
-- Description:
--

---@class MapConstant @地图常量
local MapConstant = {
	MAP_DEFAULT_MARKER_NAME = _G.LSTR(700033), -- "标记点"

	MAP_PANEL_WIDTH = 2048, -- 地图标记点界面宽度，注意世界地图的宽高是4096
	MAP_PANEL_HEIGHT = 2048, -- 地图标记点界面高度
	MAP_PANEL_HALF_WIDTH = 1024, -- 地图标记点界面一半宽度
	WORLDMAP_PANEL_HALF_WIDTH = 2048, -- 一级地图标记点界面一半宽度
	PVPMAP_PANEL_HALF_WIDTH = 360, -- PVP小地图标记点界面一半宽度

	MAP_SCALE_ICON_VISIBLE = 0.5,
	MAP_SCALE_TEXT_VISIBLE = 1.2,
	MAP_SCALE_TEXT_BLOCK_VISIBLE = 0.75,
	MAP_SCALE_MIN = 0.6, -- 缩放下限
	MAP_SCALE_VISIBLE_LEVEL1 = 0.8, -- 地图缩放倍数等级1，用于控制该缩放情况下地图上图标、名称等信息的显示隐藏
	MAP_SCALE_VISIBLE_LEVEL2 = 1.2,
	MAP_SCALE_VISIBLE_LEVEL3 = 1.8,
	MAP_SCALE_MAX = 2.2, -- 缩放上限
	MAP_SCALE_DEFAULT = 2, -- 地图默认缩放比例
	MAP_SCALE_CHANGE_UPPER_MAP = 0.61, -- 地图缩放比例回到上一级地图
	MAP_SCALE_CHANGE_DOWN_MAP = 2.0, -- 地图缩放比例切到下一级地图

	MAP_MAX_ICON_MARKER = 20, -- 图标标记最大数量
	MAP_REGION_MARKER_RATION = 0.42,

	AREA_MAP_DEF_COMPENSATION = 512, -- 计算补偿值时用到

	MAP_MAX_UI_COORDINATE = 1024, -- 地图最大坐标

	MAP_RADIUS = 90, -- 小地图半径

	MAP_TIPS_WIDGET_SAFE_AREA_OFFSET_X = 120, -- 地图图标tips显示位置安全区xx像素
	MAP_TIPS_WIDGET_SAFE_AREA_OFFSET_Y = 150,
}

---@class MapType @地图类型
local MapType = {
	Area = 1, -- 区域地图，三级地图
	World = 2, -- 世界，一级地图
	Region = 3, -- 区，二级地图
}

---@class MapMarkerType @地图标记类型
local MapMarkerType = {
	Major = 1, -- 自己
	Placed = 2, --放置的标记点
	FixPoint = 3, --固定点(表格配置)
	Quest = 4, -- 任务
	QuestTarget = 5, -- 任务目标
	Teammate = 6, -- 队友
	Fate = 7, -- Fate玩法
	Gather = 8, -- 小地图采集物，根据视野处理
	WorldMapGather = 9, -- 世界地图采集物，根据表格处理
	Fish = 10, -- 钓鱼笔记
	Telepo = 11, -- 传送水晶 （端游命名）
	AetherCurrent = 12, -- 风脉泉 （端游命名）
	PlayStyle = 13, -- 机遇临门玩法
	FateArchive = 14, -- Fate图鉴指定标记
	GoldActivity = 15, -- 金蝶活动标记(仙彩, 幻卡大赛等)
	ChocoboStable = 16, --陆行鸟房
	ChocoboTransportPoint = 17, --陆行鸟运输点
	TreasureMine = 18, -- 挖宝位置
	FollowTarget = 19, -- 追踪目标
	ChocoboAnim = 20, -- 陆行鸟动画
	LeveQuest = 21, --理符任务
	Npc = 22, -- Npc
	SceneSign = 23, -- 场景标记
	WorldMapLocation = 24, -- 世界地图坐标定位
	GameplayLocation = 25,	-- 各玩法在地图中的位置
	Monster = 26, -- 怪物
	ChocoboRacer = 27, -- 陆行鸟竞赛玩家
	ChocoboRaceItem = 28, -- 陆行鸟竞赛宝箱
	ChocoboTransportWharf = 29, --陆行鸟运输码头
	ChocoboTransportTransferLine = 30, --陆行鸟运输传送带
	DetectTarget = 31, -- 普通探索全收集辅助探测功能目标
	Gameplay = 32, -- 地图通用玩法标记
	Tracking = 33, -- 任务追踪辅助标记

	PVPCommon = 41, -- PVP地图通用标记
	PVPPlayer = 42, -- PVP地图玩家标记

	RedPoint = 99,  -- 红点(npc查询工具)
}

---@class MapMarkerBPType @地图标记蓝图类型。和地图标记类型不一一对应，请尽量复用已有的蓝图类型
local MapMarkerBPType = {
	Major = 1, -- Major
	Placed = 2, -- 放置的标记点
	Region = 3, -- 区域地图
	PlaceName = 4, -- 地名

	CommIconLeft = 5, -- 通用标记 左侧显示图标
	CommIconRight = 6, -- 通用标记 右侧显示图标
	CommIconTop = 7, -- 通用标记 顶部显示图标
	CommIconBottom = 8, -- 通用标记 底部显示图标
	CommTextLeft = 9, -- 左侧文字
	CommTextCenter = 10, -- 中间文字
	CommTextRight = 11, -- 右侧文字
	RegionIcon = 12, -- 二级地图大图标
	WorldIcon = 13, -- 一级地图标题
	CommGameplay = 14, -- 通用玩法标记，只有一个图标，很多地方使用

	Teammate = 21, -- 队友
	Fate = 22, -- Fate玩法
	Quest = 23, -- 任务
	QuestRange = 24, -- 区域任务
	QuestTarget = 25, -- 任务目标
	Gather = 26, -- 采集物
	FishRange = 27, -- 钓鱼笔记区域
	AetherCurrent = 28, -- 风脉泉
	TreasureMine = 30, -- 挖宝位置
	ChocoboTransportPoint = 31, -- 陆行鸟运输点
	ChocoboAnim = 32, -- 陆行鸟动画
	GatherRange = 33, -- 采集笔记区域
	GameplayLocation = 34,	-- 玩法布点
	Monster = 35, -- 怪物
	ChocoboRacer = 36, -- 陆行鸟竞赛玩家
	PVPPlayer = 37, -- PVP地图玩家标记
}


---@class MapContentType @地图内容类型
local MapContentType = {
	--All = 0, -- 所有
	WorldMap = 1, -- 世界地图
	--MiddleMap = 2, -- 中地图
	MiniMap = 3, -- 小地图
	WorldMapGather = 4, -- 采集点世界地图
	FishMap = 5, -- 钓鱼
	AetherCurrent = 6, -- 风脉泉界面
	FateArchive = 7, -- Fate图鉴地图
	Teleport = 8,	-- 传送地图
	ChocoboTransport = 9,    -- 运输陆行鸟地图
	WorldMapLocation = 10, -- 坐标定位世界地图
	EasyTrace = 11, -- 便捷追踪地图
	PVPMap = 12, -- PVP地图
}

---@class MapProviderConfigs
local MapProviderConfigs = {
	[MapContentType.WorldMap] = {
		MapMarkerType.FixPoint,
		MapMarkerType.Placed,
		MapMarkerType.Fate,
		MapMarkerType.Quest,
		MapMarkerType.Major,
		MapMarkerType.PlayStyle,
		MapMarkerType.Teammate,
		MapMarkerType.GoldActivity,
		MapMarkerType.RedPoint,
		MapMarkerType.TreasureMine,
		MapMarkerType.ChocoboAnim,
		MapMarkerType.LeveQuest,
		MapMarkerType.Npc,
		MapMarkerType.SceneSign,
		MapMarkerType.WorldMapGather,
		MapMarkerType.WorldMapLocation,
		MapMarkerType.GameplayLocation,
		MapMarkerType.ChocoboRacer,
		MapMarkerType.ChocoboRaceItem,
		MapMarkerType.DetectTarget,
		MapMarkerType.Gameplay,
		MapMarkerType.Fish,
		MapMarkerType.Tracking,
	},

	--[[
	[MapContentType.MiddleMap] = {
		MapMarkerType.FixPoint,
		MapMarkerType.Placed,
		--MapMarkerType.Major,
		MapMarkerType.Quest,
	},
	--]]

	[MapContentType.MiniMap] = {
		MapMarkerType.FixPoint,
		MapMarkerType.Placed,
		MapMarkerType.Fate,
		--MapMarkerType.Major,
		MapMarkerType.Quest,
		MapMarkerType.QuestTarget,
		MapMarkerType.Gather,
		MapMarkerType.PlayStyle,
		MapMarkerType.Teammate,
		MapMarkerType.GoldActivity,
		MapMarkerType.TreasureMine,
		MapMarkerType.FollowTarget,
		MapMarkerType.LeveQuest,
		MapMarkerType.Npc,
		MapMarkerType.Monster,
		MapMarkerType.SceneSign,
		MapMarkerType.ChocoboRacer,
		MapMarkerType.ChocoboRaceItem,
		MapMarkerType.DetectTarget,
		MapMarkerType.Gameplay,
		MapMarkerType.Fish,
		MapMarkerType.Tracking,
	},

	[MapContentType.PVPMap] = {
		MapMarkerType.PVPCommon,
		MapMarkerType.PVPPlayer,
	},

	[MapContentType.WorldMapGather] = {
		MapMarkerType.FixPoint,
		MapMarkerType.Placed,
		MapMarkerType.WorldMapGather,
		MapMarkerType.Major,
	},

	[MapContentType.WorldMapLocation] = {
		MapMarkerType.FixPoint,
		MapMarkerType.Placed,
		MapMarkerType.WorldMapLocation,
		MapMarkerType.Major,
	},

	[MapContentType.FishMap] = {
		MapMarkerType.Fish,
		MapMarkerType.Telepo,
		MapMarkerType.Major
	},

	[MapContentType.AetherCurrent] = {
		MapMarkerType.Telepo,
		MapMarkerType.AetherCurrent,
		MapMarkerType.Major,
	},

	[MapContentType.FateArchive] = {
		MapMarkerType.FateArchive,
		MapMarkerType.Telepo,
	},

	[MapContentType.Teleport] = {
		MapMarkerType.FixPoint,
		MapMarkerType.Placed,
		MapMarkerType.Major,
		MapMarkerType.Telepo,
	},

	[MapContentType.ChocoboTransport] = {
		MapMarkerType.ChocoboStable,
		MapMarkerType.Major,
		MapMarkerType.FixPoint,
		MapMarkerType.ChocoboTransportPoint,
		MapMarkerType.ChocoboTransportWharf,
		MapMarkerType.ChocoboTransportTransferLine,
	},

	[MapContentType.EasyTrace] = {
		MapMarkerType.FixPoint,
		MapMarkerType.Placed,
		MapMarkerType.Fate,
		MapMarkerType.Quest,
		MapMarkerType.PlayStyle,
		MapMarkerType.GoldActivity,
		MapMarkerType.RedPoint,
		MapMarkerType.TreasureMine,
		MapMarkerType.ChocoboAnim,
		MapMarkerType.LeveQuest,
		MapMarkerType.Npc,
		MapMarkerType.SceneSign,
		MapMarkerType.WorldMapGather,
		MapMarkerType.WorldMapLocation,
	},
}

---@class MapFixPointMakerColorType @固定标记点颜色类型
local MapFixPointMakerColorType = {
	Normal = 1, -- 普通
	Blue = 2, -- 蓝色
	Orange = 3, -- 橙色
}

---@class MapTransferCategory @地图标记蓝图类型
local MapTransferCategory = {
	All = 1,
	Favor = 2,
}

---@class MapMarkerPriority @地图标记优先级，和地图标记类型不一一对应
--优先级排序：主角[100]>水晶[90]>放置标记点[80]>任务[70]>fate>[60]钓鱼[50]>采集物[40]>固定点（水晶外）[0]
local MapMarkerPriority = {
	Major = 100,
	Telepo = 90,
	Player = 85,
	Placed = 80,
	Quest = 70,
	Fate = 60,
	MiddleDefault = 50,
	Fish = 50,
	Gather = 40,
	GamePlayHigh = 30, -- 高优先级玩法标记
	GamePlayDefault = 20, -- 默认玩法标记
	FixPoint = 0,
	Default = 0,
}

local MapMarkerConfigs = {
	[MapMarkerType.Major] = { Priority = MapMarkerPriority.Major },
	[MapMarkerType.Placed] = { Priority = MapMarkerPriority.Placed },
	[MapMarkerType.FixPoint] = { Priority = MapMarkerPriority.FixPoint },
	[MapMarkerType.Quest] = { Priority = MapMarkerPriority.Quest },
	[MapMarkerType.QuestTarget] = { Priority = MapMarkerPriority.Quest },
	[MapMarkerType.Teammate] = { Priority = MapMarkerPriority.Player },
	[MapMarkerType.Fate] = { Priority = MapMarkerPriority.Fate },
	[MapMarkerType.FateArchive] = { Priority = MapMarkerPriority.Fate },
	[MapMarkerType.Gather] = { Priority = MapMarkerPriority.Gather },
	[MapMarkerType.WorldMapGather] = { Priority = MapMarkerPriority.Gather },
	[MapMarkerType.Fish] = { Priority = MapMarkerPriority.Fish },
	[MapMarkerType.Telepo] = { Priority = MapMarkerPriority.Telepo },
	[MapMarkerType.PlayStyle] = { Priority = MapMarkerPriority.GamePlayDefault },
	[MapMarkerType.GoldActivity] = { Priority = MapMarkerPriority.Default },
	[MapMarkerType.AetherCurrent] = { Priority = MapMarkerPriority.GamePlayDefault },
	[MapMarkerType.ChocoboStable] = { Priority = MapMarkerPriority.Major },
	[MapMarkerType.TreasureMine] = { Priority = MapMarkerPriority.Major },
	[MapMarkerType.FollowTarget] = { Priority = MapMarkerPriority.Quest },
	[MapMarkerType.ChocoboAnim] = { Priority = MapMarkerPriority.Major },
	[MapMarkerType.ChocoboTransportPoint] = { Priority = MapMarkerPriority.Major },
	[MapMarkerType.LeveQuest] = { Priority = MapMarkerPriority.Quest },
	[MapMarkerType.RedPoint] = { Priority = MapMarkerPriority.Major },
	[MapMarkerType.Npc] = { Priority = MapMarkerPriority.Quest },
	[MapMarkerType.SceneSign] = { Priority = MapMarkerPriority.Placed },
	[MapMarkerType.WorldMapLocation] = { Priority = MapMarkerPriority.Quest },
	[MapMarkerType.GameplayLocation] = { Priority = MapMarkerPriority.Major },
	[MapMarkerType.ChocoboRacer] = { Priority = MapMarkerPriority.Default },
	[MapMarkerType.ChocoboRaceItem] = { Priority = MapMarkerPriority.Default },
	[MapMarkerType.PVPCommon] = { Priority = MapMarkerPriority.Default },
	[MapMarkerType.PVPPlayer] = { Priority = MapMarkerPriority.Player },
	[MapMarkerType.DetectTarget] = { Priority = MapMarkerPriority.Default },
	[MapMarkerType.Gameplay] = { Priority = MapMarkerPriority.GamePlayDefault },
	[MapMarkerType.Tracking] = { Priority = MapMarkerPriority.Quest },
}

local MapMarkerBPConfigs = {
	[MapMarkerBPType.Major] = { BPName = "Map/Marker/MapMarkerMajor_UIBP" },
	[MapMarkerBPType.Placed] = { BPName = "Map/Marker/MapMarkerPlaced_UIBP" },
	[MapMarkerBPType.Region] = { BPName = "Map/Marker/MapMarkerRegion_UIBP" },
	[MapMarkerBPType.PlaceName] = { BPName = "Map/Marker/MapMarkerPlaceName_UIBP" },
	[MapMarkerBPType.CommIconLeft] = { BPName = "Map/Marker/MapMarkerCommIconLeft_UIBP" },
	[MapMarkerBPType.CommIconRight] = { BPName = "Map/Marker/MapMarkerCommIconRight_UIBP" },
	[MapMarkerBPType.CommIconTop] = { BPName = "Map/Marker/MapMarkerCommIconTop_UIBP" },
	[MapMarkerBPType.CommIconBottom] = { BPName = "Map/Marker/MapMarkerCommIconBottom_UIBP" },
	[MapMarkerBPType.CommTextLeft] = { BPName = "Map/Marker/MapMarkerCommTextLeft_UIBP" },
	[MapMarkerBPType.CommTextCenter] = { BPName = "Map/Marker/MapMarkerCommTextCenter_UIBP" },
	[MapMarkerBPType.CommTextRight] = { BPName = "Map/Marker/MapMarkerCommTextRight_UIBP" },
	[MapMarkerBPType.RegionIcon] = { BPName = "Map/Marker/MapMarkerRegionIcon_UIBP" },
	[MapMarkerBPType.WorldIcon] = { BPName = "Map/Marker/MapMarkerLocationTitle_UIBP" },
	[MapMarkerBPType.CommGameplay] = { BPName = "Map/Marker/MapMarkerCommGameplay_UIBP" },

	[MapMarkerBPType.Teammate] = { BPName = "Map/Marker/MapMarkerTeammate_UIBP" },
	[MapMarkerBPType.Fate] = { BPName = "Map/Marker/MapMarkerFate_UIBP" },
	[MapMarkerBPType.Quest] = { BPName = "Map/Marker/MapMarkerQuest_UIBP" },
	[MapMarkerBPType.QuestRange] = { BPName = "Map/Marker/MapMarkerQuestRange_UIBP" },
	[MapMarkerBPType.QuestTarget] = { BPName = "Map/Marker/MapMarkerQuestTarget_UIBP" },
	[MapMarkerBPType.Gather] = { BPName = "Map/Marker/MapMarkerGather_UIBP" },
	[MapMarkerBPType.GatherRange] = { BPName = "Map/Marker/MapMarkerGatherRange_UIBP" },
	[MapMarkerBPType.FishRange] = { BPName = "Map/Marker/MapMarkerFishRange_UIBP" },
	[MapMarkerBPType.AetherCurrent] = { BPName = "AetherCurrent/Item/AetherCurrentMarkPanelItem_UIBP" },
	[MapMarkerBPType.TreasureMine] = { BPName = "Map/Marker/MapMarkerMine_UIBP" },
	[MapMarkerBPType.ChocoboAnim] = { BPName = "Map/Marker/MapMarkerChocoboAnim_UIBP" },
	[MapMarkerBPType.ChocoboTransportPoint] = { BPName = "Map/Marker/MapMarkerChocoboTransportPoint_UIBP" },
	[MapMarkerBPType.GameplayLocation] = { BPName = "Map/Marker/MapMarkerGameplayLocation_UIBP" },
	[MapMarkerBPType.Monster] = { BPName = "Map/Marker/MapMarkerMonster_UIBP" },
	[MapMarkerBPType.PVPPlayer] = { BPName = "Map/Marker/MapMarkerPVPPlayer_UIBP" },
	[MapMarkerBPType.ChocoboRacer] = { BPName = "Map/Marker/MapMarkerChocoboRacer_UIBP" },
}

---@class MapListItemIconPath 三级地图中分层地图的显示图标
local MapListItemIconPath = {
	Default = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_Info03_png.UI_Map_Icon_Info03_png'",
	MajorLocation = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_Loction_png.UI_Map_Icon_Loction_png'",
	FollowQuest = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_Info01_png.UI_Map_Icon_Info01_png'",
	MapFollow = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_Info02_png.UI_Map_Icon_Info02_png'",
}

---@class MapFollowStateIconPath 地图追踪状态图标
local MapFollowStateIconPath = {
	Following = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_PlaceTips04_png.UI_Map_Icon_PlaceTips04_png'",
	UnFollow = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_PlaceTips03_png.UI_Map_Icon_PlaceTips03_png'",
	AutoPathing = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_AutoPathMove02_png.UI_Map_Icon_AutoPathMove02_png'",
	UnAutoPath = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_AutoPathMove_png.UI_Map_Icon_AutoPathMove_png'",
}

---@class MapFollowTargetType 地图追踪目标类型
local MapFollowTargetType =
{
	QuestTarget = 1, -- 任务目标
	AetherCurrent = 2, -- 风脉泉
	FollowByPlayer = 3, -- 自主追踪点
	UnActivatedCrystal = 4, -- 附近未解锁水晶
	GoldGameNPC = 5, -- 金蝶地图机遇任务开启时NPC
}

---@class MapFollowTargetConfigs 地图追踪目标类型的显示配置，包括图标箭头等，目前主要是小地图追踪标记使用
local MapFollowTargetConfigs =
{
	[MapFollowTargetType.QuestTarget] =
	{
		Icon = "",
		Arrow = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_TaskTrack_Icon_Arrow5_png.UI_TaskTrack_Icon_Arrow5_png'",
	},

	[MapFollowTargetType.AetherCurrent] =
	{
		Icon = "",
		Arrow = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Hud_AetherCurrentTrack_Arrow_png.UI_Icon_Hud_AetherCurrentTrack_Arrow_png'",
	},

	[MapFollowTargetType.FollowByPlayer] =
	{
		Icon = "",
		Arrow = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Hud_LandmarkTrack_Arrow_png.UI_Icon_Hud_LandmarkTrack_Arrow_png'",
	},

	[MapFollowTargetType.UnActivatedCrystal] =
	{
		Icon = "",
		Arrow = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Hud_CrystalTrack_Arrow_png.UI_Icon_Hud_CrystalTrack_Arrow_png'",
	},

	[MapFollowTargetType.GoldGameNPC] =
	{
		Icon = "",
		Arrow = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Hud_GoldSaucerTrack_Arrow_png.UI_Icon_Hud_GoldSaucerTrack_Arrow_png'",
	}
}


---@class MapIconConfigs 地图常见图标配置
local MapIconConfigs =
{
	DefaultIcon = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060453_png.060453_png'",

	MonsterBoss = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060401.UI_Icon_060401'",
	MonsterNormal = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060422.UI_Icon_060422'",

	Teammate = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_Teammate_png.UI_Map_Icon_Teammate_png'",
	WorldMapLocation = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Icon_MarkPurple_png.UI_Map_Icon_MarkPurple_png'",

	-- PVP地图玩家标记红蓝方背景
	PVPPlayerBlueBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMap_Icon_TeamBlueBg_png.UI_PVPMap_Icon_TeamBlueBg_png'",
	PVPPlayerRedBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMap_Icon_TeamRedBg_png.UI_PVPMap_Icon_TeamRedBg_png'",

	DiscoverNotePerfect = "Texture2D'/Game/Assets/Icon/MapIconSnap/PlayStyle/UI_Map_Icon_PlayStyle_SightSeeingLog_01.UI_Map_Icon_PlayStyle_SightSeeingLog_01'",
	DiscoverNoteCommon = "Texture2D'/Game/Assets/Icon/MapIconSnap/PlayStyle/UI_Map_Icon_PlayStyle_SightSeeingLog_02.UI_Map_Icon_PlayStyle_SightSeeingLog_02'",

	WildBox = "Texture2D'/Game/Assets/Icon/MapIconSnap/PlayStyle/UI_Map_Icon_PlayStyle_TreasureBox.UI_Map_Icon_PlayStyle_TreasureBox'",

	AetherCurrent = "PaperSprite'/Game/UI/Atlas/AetherCurrent/Frames/UI_AetherCurrent_Icon_Green_png.UI_AetherCurrent_Icon_Green_png'",

	OpsPWorldBoxEObj = "Texture2D'/Game/Assets/Icon/MapIconSnap/PlayStyle/UI_Map_Icon_PlayStyle_TreasureBox.UI_Map_Icon_PlayStyle_TreasureBox'",
	OpsPWorldClueEObj = "Texture2D'/Game/Assets/Icon/MapIconSnap/PlayStyle/UI_Map_Icon_PlayStyle_SightSeeingLog_02.UI_Map_Icon_PlayStyle_SightSeeingLog_02'",
}


---@class MapBigSmallCityConfigs 大小主城配置 key是小主城UIMapID，value是对应的大主城UIMapID
local MapBigSmallCityConfigs =
{
	-- 乌尔达哈来生回廊/政府层 —— 乌尔达哈现世回廊
	[14] = 13,
	[73] = 13,

	-- 格里达尼亚旧街 —— 格里达尼亚新街
	[3] = 2,

	-- 利姆萨·罗敏萨上层甲板 —— 利姆萨·罗敏萨下层甲板
	[11] = 12,

	-- 陆行鸟广场 —— 金碟游乐场
	[197] = 196,

	-- 伊修加德砥柱层 —— 伊修加德基础层
	[219] = 218,
}

---@class MapLocationType 世界地图坐标定位的目标类型
local MapLocationType =
{
	Npc = 1,
	EObj = 2,
}

---@class MapGameplayType 地图通用玩法标记类型
local MapGameplayType =
{
	WildBox = 1, -- 野外宝箱
	AetherCurrent = 2, -- 风脉泉
	DiscoverNote = 3, -- 探索笔记
	PWorldEntity = 4, -- 副本全地图显示实体
}


-- 地图埋点上报类型
local MapReportType =
{
	MapOpen = 1,
	MapClose = 2,
	CrystalTransfer = 3,
	MapFollow = 4,
	MapSetMark = 5,
	OpenRegionMap = 6,
	OpenWorldMap = 7,
	OpenAetherCurrent = 8,
}

-- 地图打开来源
local MapOpenSource =
{
	MiniMap = 1,
	GatheringLog = 2,
	QuestLog = 3,
	QuestTrack = 4,
	RecommendTask = 5,
	MapLocation = 6,
	Fate = 7,
	ChatSend = 8,
	TreasureHunt = 9,
	Other = 99,
}

-- 水晶传送来源
local CrystalTransferSource =
{
	TransferTips = 1,
	TransferList = 2,
	TaskTrackingTips = 3,
}


---@class MapDefine
local MapDefine = {
	MapConstant = MapConstant,
	MapType = MapType,
	MapMarkerType = MapMarkerType,
	MapMarkerBPType = MapMarkerBPType,
	MapContentType = MapContentType,
	MapFixPointMakerColorType = MapFixPointMakerColorType,
	MapTransferCategory = MapTransferCategory,
	MapMarkerPriority = MapMarkerPriority,
	MapMarkerConfigs = MapMarkerConfigs,
	MapMarkerBPConfigs = MapMarkerBPConfigs,
	MapProviderConfigs = MapProviderConfigs,
	MapListItemIconPath = MapListItemIconPath,
	MapFollowStateIconPath = MapFollowStateIconPath,
	MapFollowTargetType = MapFollowTargetType,
	MapFollowTargetConfigs = MapFollowTargetConfigs,
	MapIconConfigs = MapIconConfigs,
	MapBigSmallCityConfigs = MapBigSmallCityConfigs,
	MapLocationType = MapLocationType,
	MapGameplayType = MapGameplayType,
	MapReportType = MapReportType,
	MapOpenSource = MapOpenSource,
	CrystalTransferSource = CrystalTransferSource,
}

return MapDefine