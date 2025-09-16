--[[
Date: 2022-07-25 14:54:07
LastEditors: moody
LastEditTime: 2022-07-25 14:54:07
--]]
local ProtoCS = require("Protocol/ProtoCS")

---@class ClientSetupID : ProtoCS.ClientSetupKey
---后台在协议中仅定义后台需要的Key，而对于那些仅客户端关心的数据，我们可以在这里定义Key，并通过ClientSetupMgr保存、获取数据
local ClientSetupID = {
	-- CSKAutoSyncVisionEnd = 20,
    -- ID段0~20的数据会随着视野包下发，有需求请咨询后台
    -- ClientSetupKeyStart = 0,
    -- CSKAutoSyncVisionEnd = 20,

    -- 客户端自己的Key从1000开始

    -- ActorUI 1001 ~ 1010
    ActorUIColorMajor = 1001,       -- Value:ColorID Major铭牌颜色ID
    ActorUIColorPlayer = 1002,      -- Value:ColorID 其他玩家铭牌颜色ID
    ActorUIColorTeamMember = 1003,  -- Value:ColorID 队友铭牌颜色ID
    ActorUIColorFriend = 1004,      -- Value:ColorID 好友铭牌颜色ID

    -- TeamTargetMarker 1011 ~ 1050
	CSTeamSceneMarker = 1011,				-- 场景标记启/禁用设置
	CSTeamTargetMarker = 1012,				-- 目标标记启/禁用设置
	CSTeamCountDown = 1013,					-- 战斗开始倒计时启/禁用设置
	CSTeamCountDownDefaultNum = 1014,		-- 战斗开始倒计时上次设置时间
	CSSceneMarkersSaveList = 1015,			-- 场景标记 1015 - 1045 30条存档会超出限制，所以区分ID来存

    --Chat 
    ChatReadGifRedDotIDs = 1040, -- 已读的Gif红点ID列表
    ChatShownChatSetTips = 1041, -- 是否已提示聊天设置

    --Friend
    FriendRecentTeam = 1050, -- 近期组队玩家RoleID列表
    FriendRecentChat = 1051, -- 近期聊天玩家RoleID列表

    --PersonPortrait
    PortraitReadRedDotIDs = 1055, -- 已读的红点ID列表
    ShownPortraitInitSaveTips = 1056, -- 是否已提示初始肖像保存
    PortraitSaveImgUrlStrategy = 1057, -- 肖像保存图片策略

    CSMapFollowInfo = 1060, -- 地图追踪信息

    SystemModulesUsed = 1070,               -- 记录使用过的系统模块

    RideShootingLastRecord = 1080,          -- 空军装甲上次未完成游戏得分
    LeapOfFaithEndGameTime = 1081,          -- 虚景跳跳乐报名后的游戏结束时间

    QuestChocoboTransportCancel = 1090,     -- 任务陆行鸟取消记录

    FogPlayClearAnimationRecord = 1100,     -- 迷雾清除动画播放记录
    PlayNewbieCutScene = 1101,              -- 新手场景过场动画播放记录

    --Tutorial 新手引导数据 1201 ~ 1300占位
    TutorialStateKey = 1201,  --新手引导开关 老逻辑，后续挪到系统开关
    SoftTutorialKey = 1202,   --软引导完成状态   stringTable
    ForceTutorialKey = 1203,  --强制引导完成状态 stringTable
    GuideTutorialKey = 1204,  --新手指南
    TutorialNetSyncKey = 1205, --新手引导完成状态 stringTable
    TutorialSpecialData = 1206, --新手引导需要储存的特殊数据 stringtable
    TutorialGuideState = 1207, -- 新手指南开关

    
    -- 设置基础 1301 ~ 1310
    MajorAutoSelectTarget= 1301,
    ShowSelectOutline= 1302,
    ShowTargetLine= 1303,
    ShowRelevanceLine= 1304,
    SwitchTargetType= 1305,
    MaxSpeedConstState= 1306,
    JoystickControlType= 1307,

    -- 设置声音 1311 ~ 1330
    CSGlobalVol = 1311,
    CSMusicVol = 1312,
    CSSfxVol = 1313,
    CSVoicesVol = 1314,
    CSUISoundVol = 1315,
    CSAmbientVol = 1316,
    CSInstrumentsVol = 1317,--废弃
    CSMainPlayerVol = 1318,
    CSTeammateVol = 1319,
    CSEnemyVol = 1320,
    CSMountBGM = 1321,
    CSInstrumentsMainPlayerVol = 1322,
    CSInstrumentsOthersVol = 1323,
    CSBgVoiceSetting = 1324,

    -- 设置界面 1331 ~ 1340
    CSTutorialState= 1330,
    AutoPathMove = 1331,
    CSTutorialGuideState = 1332,
    CSDungeonFpsState = 1333,

    -- 设置角色 1341 ~ 1360
    AutoLeaveTime= 1341,
    ResetToIdleTime= 1342,
    RandomSwitchPose= 1343,
    ShowHead= 1344,
    HelmetGimmickOn= 1345,
    ShowWeapon= 1346,
    CrafterHideOtherPlayers= 1347,
    SwitchHoldWeaponPose= 1348,
    HoldWeaponIdleTime= 1349,
    FootstepEffect= 1350,
    SummonScale = 1351, --召唤兽缩放大小

	--角色相机设置
	ViewDis = 1352,--视距
	ViewDisScaleSpeed = 1353,--视距缩放速度
	FOV = 1354,--视野大小
	CameraRotateSpeed = 1355,--旋转速率
	CameraSurround = 1356,--环绕开关
    NeedShowTips = 1357,  --显示情感动作气泡
    AutoGenAttack = 1358, --自动维持普通攻击

    -- 设置铭牌 1361 ~ 1370
    ShowSelfTitle = 1361,
    ShowTeamMemberTitle = 1362,
    ShowFriendTitle = 1363,
    ShowStrangerTitle = 1364,

    -- 设置语言 1371 ~ 1380
    CurrentCulture = 1371,
    VoiceCulture = 1372,

    --设置视野内Actor数量
    CSVisionPlayerNum = 1373,
    CSVisionPetNum = 1374,
    CSVisionNpcNum = 1375,

	--系统解锁 1381-1390
	CSNewBieGuideKey = 1381,
	ModuleOpenArmState = 1382,

    --角色转职红点
    RoleChgProfRedPoint = 1391,

    -- 过场动画 1401-1499
    BrowsedCutScene = 1401,
    AutoSkipQuestSequence = 1402,
    MinBrowsedCutScene = 1410,
    MaxBrowsedCutScene = 1499,

    --头像
    HeadGuideRedPoint = 1501,

	-- 主界面
	MainPanelIsTimeBarVisible = 1511,  -- 主界面右下角时间栏
	MainPanelIsEnmityPanelVisible = 1512,  -- 主界面仇恨列表
    --理符红点
    LeveQuestProfRedDotList = 1601,
    --理符职业解锁等级
    LeveQuestProfUnlockLevel = 1602,

    --角色头盔显隐
    RoleHatVisible = 1602,
    --角色武器显隐
    RoleWeaponVisible = 1603,

    --坐骑全局Bgm设置
    MountGlobalBGMSetting = 1604,

    --- 商城奇遇盲盒红点已读状态
	StoreMasterBoxReddot = 1605,

    -- HUD
	HUDMemberFlyTextVisible = 1611,  -- 是否显示队友造成的伤害飘字

    -- 技能栏位自定义 2000 ~ 2999
    SkillCustomIndex_Start = 2000,
    SkillCustomIndex_End   = 2999,

    -- 技能长按设置
    SkillTips = 3001,
}

setmetatable(ClientSetupID, { __index = ProtoCS.ClientSetupKey })

return ClientSetupID