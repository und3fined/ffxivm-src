--[[
Date: 2022-11-17 10:19:38
LastEditors: moody
LastEditTime: 2022-11-17 10:19:39
--]]

local EmotionDefines = {
	StateDefine =
	{
		NORMAL = 1,
		ADJUST = 2,			-- 高度调整
		SIT_GROUND	= 3,	-- 坐在地上
		SIT_CHAIR	= 4,	-- 坐在椅子上
		UPPER_BODY	= 5,	-- 上半身动作
	},
	SlotNames =
	{
		WholeBody = "WholeBody",
		Head = "Head",
		UpperBody = "UpperBody",
		Face = "CurrentSlot",		--"EmoteSlot"	--"Additive_Face" --
	},
	IdlePoseType = {
		IDLE_TO_REST_TIME = 1,	-- 待机到休闲待机的时间
		NORMAL = 2,			-- 普通待机类型
		SIT_GROUND = 3,		-- 坐在地上待机类型
		SLEEP = 4,			-- 睡觉待机类型
		SIT_CHAIR = 5,		-- 坐在椅子上待机类型
	},
	AnimType = {
		EMOT = "emot",
		FACE = "face_pose",
		NORMAL = "normal",
	},
	CancelReason = {
		NONE = 1,
		SKILL = 2,	--技能中断
		SERVER_NOTIFY = 3,	--服务器通知
		DEAD = 4,
		MOVE = 5,
		SWIM = 6,	--游泳
		ChangeRole = 7,	--变身
		HIT = 8,  --被攻击
	}
}

EmotionDefines.IdlePoseDefault = {
	[EmotionDefines.IdlePoseType.IDLE_TO_REST_TIME] = 30,   --空闲到休息时间
	[EmotionDefines.IdlePoseType.NORMAL] = 0,				--默认使用第0个pose
	[EmotionDefines.IdlePoseType.SIT_GROUND] = 0,
	[EmotionDefines.IdlePoseType.SLEEP] = 0,
	[EmotionDefines.IdlePoseType.SIT_CHAIR] = 0,
}

EmotionDefines.IdlePoseMax = {
	[EmotionDefines.IdlePoseType.IDLE_TO_REST_TIME] = 30,   --空闲到休息时间
	-- 以下Type最小值是0 取值区间是[0, Max]
	[EmotionDefines.IdlePoseType.NORMAL] = 6,			--（4）	--最大使用第6个pose
	[EmotionDefines.IdlePoseType.SIT_GROUND] = 3,
	[EmotionDefines.IdlePoseType.SLEEP] = 2,
	[EmotionDefines.IdlePoseType.SIT_CHAIR] = 4,		--（2）
}

EmotionDefines.IdlePropertyNames = {
	[EmotionDefines.IdlePoseType.IDLE_TO_REST_TIME] = "IdleToRestTime",
	[EmotionDefines.IdlePoseType.NORMAL] = "NormalIdleType",
	[EmotionDefines.IdlePoseType.SIT_GROUND] = "SitGroundIdleType",
	[EmotionDefines.IdlePoseType.SLEEP] = "SleepIdleType",
	[EmotionDefines.IdlePoseType.SIT_CHAIR] = "SitChairIdleType",
}

--- 对应情感动作表的 CanUse[0]等
EmotionDefines.CanUseTypes = {
	STAND = 1,
	SIT_GROUND = 2,
	SIT_CHAIR = 3,
	RIDE = 4,
	FISHING = 5,
	SWIMMING = 6,
	DIVING = 7,
}


---最近使用、收藏
EmotionDefines.RecentFavorite = {
---最近使用
	Recent = 1,
---收藏
	Favorite = 2,
}

---情感动作类型：收藏0、一般1、持续2、表情3
EmotionDefines.EmotionTypeId = {
---收藏: 0
	collectionTab = 0,
---一般: 1
	OnceEmotionTab = 1,
---持续: 2
	LoopEmotionTab = 2,
---表情: 3
	FaceEmotionTab = 3,
---特殊: 4
	SpecialEmotionTab = 4
}

--- 情感动作界面上侧动作类型的红点路径
EmotionDefines.TabRedDots = {
	Favorite 	= "Root/FavoriteEmotionTab",
	Once 	 	= "Root/OnceEmotionTab",
	Loop 		= "Root/LoopEmotionTab",
	Face 		= "Root/FaceEmotionTab",
	Special		= "Root/SpecialEmotionTab"
}

--- 以情感动作界面上侧类型为Key , 对应 红点路径
EmotionDefines.TabKeyRedDots = {
	[0] = EmotionDefines.TabRedDots.Favorite,
	[1] = EmotionDefines.TabRedDots.Once,
	[2] = EmotionDefines.TabRedDots.Loop,
	[3] = EmotionDefines.TabRedDots.Face,
	[4] = EmotionDefines.TabRedDots.Special,
}

--- 以情感动作表的"动作类型"序号为Key , 其中2、3为持续状态的动作 , 下面这个不要和上面那个搞混淆了
EmotionDefines.MotionTypeKeyRedDots = {
	[0] = EmotionDefines.TabRedDots.Face,
	[1] = EmotionDefines.TabRedDots.Once,
	[2] = EmotionDefines.TabRedDots.Loop,
	[3] = EmotionDefines.TabRedDots.Loop,
	[4] = EmotionDefines.TabRedDots.Special,
}

EmotionDefines.AnimPathType = {
	[EmotionDefines.StateDefine.NORMAL] = "AnimPath",
--	[EmotionDefines.StateDefine.NORMAL] = "BeginAnimPath",
	[EmotionDefines.StateDefine.SIT_GROUND] = "OnGroundAnimPath",
	[EmotionDefines.StateDefine.SIT_CHAIR] = "OnChairAnimPath",
	[EmotionDefines.StateDefine.UPPER_BODY] = "UpperBodyAnimPath",
--	[EmotionDefines.StateDefine.NORMAL] = "StateAnimPath",
	[EmotionDefines.StateDefine.ADJUST] = "AdjustAnimPath",
}

EmotionDefines.Collection1 = "UI_EmoAct_Tab_Favorite_Off_png"
EmotionDefines.Collection2 = "UI_EmoAct_Tab_Favorite_On_png"
EmotionDefines.Once1 = "UI_EmoAct_Tab_Once_Off_png"
EmotionDefines.Once2 = "UI_EmoAct_Tab_Once_On_png"
EmotionDefines.Loop1 = "UI_EmoAct_Tab_Loop_Off_png"
EmotionDefines.Loop2 = "UI_EmoAct_Tab_Loop_On_png"
EmotionDefines.Face1 = "UI_EmoAct_Tab_Face_Off_png"
EmotionDefines.Face2 = "UI_EmoAct_Tab_Face_On_png"

EmotionDefines.ELog = {
	[0] = "处于特殊状态",
	[1] = "坐骑状态不可用",
	[2] = "游泳状态不可用",
	[3] = "钓鱼状态不可用",
	[4] = "生产职业不能使用战斗动作",
	[5] = "坐在椅子上",
	[6] = "坐在地面上",
	[7] = "无动作路径",
	[8] = "无CanUse使用场景",
	[9] = "表中无此ID",
	[10] = "拦截未激活的ID",
	[11] = "技能中不可用",
	[12] = "蓄力中不可用",
	[13] = "死亡中不可用",
	[14] = "变身中不可用",
}

return EmotionDefines