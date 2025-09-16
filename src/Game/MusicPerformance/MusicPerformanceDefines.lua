--[[
Date: 2023-10-23 15:25:25
LastEditors: moody
LastEditTime: 2023-10-23 15:25:25
--]]

local ProtoRes = require("Protocol/ProtoRes")
local MusicPerformanceDefines = {
	DEBUG = false,
	PerformCommandMax = 10,
	EnsembleCommandMax = 10,
	PlayInterval = 0.05,
	EnsemblePlayLimit = 60 * 30,
	KeyScaleMax = 3,				-- 三个音阶
	KeyOff = 0,
	RequestMax = 10,				-- 请求的最大数 策划要求改成10，因为人有10根手指
	PlayBufferMax = 16,				-- 播放列表的最大数
	EnsembleMemberMax = 8,			-- 合奏最大人数
	GroupMax = 5,					-- 组内最多乐器数
	PerformBufferReceiveMax = 6,
	EnsembleBufferReceiveMax = 4,
	MotionPlayInterval = 0.4,       -- play动作的最短持续时长(timeline + looptimeline),就是能保证能最少都看到0.4秒的play动作表现，才会切到idle状态
	MotionIdleInterval = 0.1,		-- idel动作的最短持续时长
	RestLimit = 3,
	PlayLimit = 4,					-- 长按演奏的限时
	ShortPlayLimit = 1,			-- 短按演奏的限时
	SignEffectPath = "",
	BufferingTime = 0.5,			-- 接收等待时间（※如果时间较短，则无法保证在正常时间播放）
	BufferingCount = 2,				-- 接收开始缓存数量（※如果时间较短，则无法保证在正常时间播放）
	ReleaseTime = 0.5,				-- 释放的等待时间
	EnsembleReceiveRange = 5000,
	AgreeProtocolValue = "1",		-- 勾选协议时正确的值
	InstrumentValSaveKey = "InstrumentsMainPlayerVol",
	InstrumentValSaveKey2 = "InstrumentsOthersVol",
	UI_MenuSaveKey = "UISoundVol",
}

MusicPerformanceDefines.CameraSettings = {
	LagValue = 4,
	SelectPanelDistance = 180,	-- 选择界面相机的距离
}

MusicPerformanceDefines.MetronomeSettings = {
	BPMMin = 10,
	BPMEnsembleMin = 30,
	BPMMax = 200,
	BeatMin = 2,
	BeatMax = 7,
	VolumeMax = 100,
	DefaultSetting = {
		Volume = 100,
		BPM = 120,
		BeatPerBar = 4,
		Effect = 1,
		Prepare = 1,
		EffectPrepareOnly = 0,
	},
	TickSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/etc/SE_Bt_Etc_Metro_tick_01/Play_SE_Bt_Etc_Metro_tick_01.Play_SE_Bt_Etc_Metro_tick_01'",
	AccSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/etc/SE_Bt_Etc_Metro_acc_01/Play_SE_Bt_Etc_Metro_acc_01.Play_SE_Bt_Etc_Metro_acc_01'",
}

MusicPerformanceDefines.CommonSettings = {
	KeyboardMode = 1,	-- 单音阶
	KeySize = 1,		-- 小
	-- OtherMuted = false,		-- 否，不静音
}

MusicPerformanceDefines.Ensemble = {
	DefaultSettings = {
		OpenAssistant = true,
		OpenCountDown = true,
		Mode = 1,
		ReadyTime = 30,
		CountDownTime = 6,
	}
}

MusicPerformanceDefines.KeyDefines = {
	KEY_C = 0,
	KEY_C_PLUS = 1,
	KEY_D = 2,
	KEY_D_PLUS = 3,
	KEY_E = 4,
	KEY_F = 5,
	KEY_F_PLUS = 6,
	KEY_G = 7,
	KEY_G_PLUS = 8,
	KEY_A = 9,
	KEY_A_PLUS = 10,
	KEY_B = 11,
	KEY_MAX = 12,
}

MusicPerformanceDefines.TimelineIndex = {
	TIMELINE_END = 0,
	TIMELINE_IDLE = 1,
	TIMELINE_PLAY_000_START = 2,
	TIMELINE_PLAY_000_LOOP = 3,
	TIMELINE_PLAY_001_START = 4,
	TIMELINE_PLAY_001_LOOP = 5,
	TIMELINE_MAX = 6,
}

MusicPerformanceDefines.Command = {
	COMMAND_ID_INVALID = 0,			-- 无效
	COMMAND_ID_REST    = 255,		-- 空
	COMMAND_ID_KEY_OFF = 254,		-- 长按抬起
}

MusicPerformanceDefines.PlayBufferStatus = {
	STS_WAIT = 0,
	STS_PLAY = 1,
	STS_RELEASE = 2,
}

MusicPerformanceDefines.PerformCharacterStatus = {
	STS_INVALID = 0,		-- 无效
	STS_LOAD = 1,			-- 资源加载
	STS_IDLE = 2,			-- 待机
	STS_PLAY = 3,			-- 演奏
	STS_PLAY_LOOP = 4,		-- 演奏（循环）
}

-- MusicPerformanceDefines.AnimSlotNames = {
-- 	StartTimeline = "WholeBody",
-- 	PlayTimeline = "WholeBody",
-- 	IdleTimeline = "IdleModelState"
-- }

MusicPerformanceDefines.ErrorCode = {
	ErrorCodeNone = 0,
	ErrorCodeMode = -1,		-- 模式错误
	ErrorCodeSetup = -2,	-- 正在设置中
}

MusicPerformanceDefines.KeyAnimMap = {
	[0] = 0,	-- C
	[1] = 0,	-- C+
	[2] = 1,	-- D
	[3] = 1,	-- D+
	[4] = 0,	-- E
	[5] = 1,	-- F
	[6] = 0,	-- F+
	[7] = 0,	-- G
	[8] = 1,	-- G+
	[9] = 1,	-- A
	[10] = 0,	-- A+
	[11] = 0,	-- B
}

MusicPerformanceDefines.KeyName = {
	[0] = "C",	-- C
	[1] = "C#",	-- C+
	[2] = "D",	-- D
	[3] = "Eb",	-- D+
	[4] = "E",	-- E
	[5] = "F",	-- F
	[6] = "F#",	-- F+
	[7] = "G",	-- G
	[8] = "G#",	-- G+
	[9] = "A",	-- A
	[10] = "Bb",	-- A+
	[11] = "B",	-- B
}

MusicPerformanceDefines.SendInterval = MusicPerformanceDefines.PerformCommandMax * MusicPerformanceDefines.PlayInterval
MusicPerformanceDefines.EnsembleInterval = MusicPerformanceDefines.EnsembleCommandMax * MusicPerformanceDefines.PlayInterval
MusicPerformanceDefines.EnsembleReceiveInterval = MusicPerformanceDefines.EnsembleInterval + 1.0

MusicPerformanceDefines.KeyDataMax = MusicPerformanceDefines.KeyDefines.KEY_MAX * MusicPerformanceDefines.KeyScaleMax		-- 音符的总数
MusicPerformanceDefines.KeyStart = MusicPerformanceDefines.KeyDefines.KEY_MAX * 2											-- 有效的音符的起始
MusicPerformanceDefines.KeyCenterStart = MusicPerformanceDefines.KeyDefines.KEY_MAX * 3										-- 中间8度的起始音符
MusicPerformanceDefines.KeyEnd = MusicPerformanceDefines.KeyStart + MusicPerformanceDefines.KeyDataMax						-- 有效的音符的结尾
MusicPerformanceDefines.KeyInvalid = MusicPerformanceDefines.KeyEnd + 1
MusicPerformanceDefines.EnsembleReceiveRangeSquared = MusicPerformanceDefines.EnsembleReceiveRange * MusicPerformanceDefines.EnsembleReceiveRange

MusicPerformanceDefines.ConfirmStatus = {
	ConfirmStatusNone = 0,
	ConfirmStatusConfirm = 1,
	ConfirmStatusCancel = 2,
}

MusicPerformanceDefines.AssistantScoreType = {
	None = 0,
	Perfect = 1,
	Great = 2,
	Good = 3,
	Bad = 4,
	Miss = 5
}

MusicPerformanceDefines.UIEventType = {
	None = 0,
	ShortClick = 1,
	LongClick = 2,
	LongRelease = 3
}

MusicPerformanceDefines.TeamConfirmResult = {
	None = 0,
	NotConfirm = 1, -- 有队员未确认
	AllAgree = 2,  --全部队员已同意
	SomeoneRefused = 3 --全部已确认，但有队员拒绝
}

-- 演奏助手进度各阶段的比例
MusicPerformanceDefines.UIPercent = {
	[ProtoRes.MusicAwardRank.MusicAwardRank_SPP] = 0,
	[ProtoRes.MusicAwardRank.MusicAwardRank_SP] = 0.5,
	[ProtoRes.MusicAwardRank.MusicAwardRank_S] = 0.5,
	[ProtoRes.MusicAwardRank.MusicAwardRank_A] = 0.4,
	[ProtoRes.MusicAwardRank.MusicAwardRank_B] = 0.25,
	[ProtoRes.MusicAwardRank.MusicAwardRank_C] = 0.15,
	[ProtoRes.MusicAwardRank.MusicAwardRank_D] = 0.2,
}

MusicPerformanceDefines.AssistantFallingDownConfig = {
	TopOffset = 80,
	--BottomOffset = 80,
	BottomOffset = 120,
	BottomOffsets = {
		LongOffset1 = 140,		-- 长按拖尾的Offset
		AllLongOffset1 = 160,	-- 全音阶长按拖尾的Offset
		LongOffset2 = 64,		-- 长按方块的Offset
		ShortOffset	= 200,		-- 短按方块的Offset
		EffectOffset = 0,		-- 特效的Offset

	},
	SizeOffsets = {
		Black = 230,
		All_Black = 240,
		White = 180,
		All_White = 280,
	},
	MinSize = {
		Black = 300,
		All_Black = 360,
		White = 330,
		All_White = 350,
	},
	KeyStates = {
		None = 0,
		Grey = 1,
		Red  = 2,
		Blue = 3,
	},
	UnitPerMs = 0.5,				-- 每毫秒对应的单位长度
	EarlyAppearOffsetMS = 2000,		-- 提前出现时间的offset
	CheckTimeRangeMS	= 1500,		-- 演奏助手响应的时间范围
	StartDelayTime = 6,				-- 开启演奏助手倒计时的时间
	AssistantDoneDelayTimeMS = 1200,	-- 演奏助手停止Tick的事件（缓冲UI更新）
	AssistantItemDestoryTimeOffsetMS = 1000,	-- 演奏助手停止Tick的事件（缓冲UI更新）

	MinSpeedRate = 0.1,
	MaxSpeedRate = 2.0,

	ScoreTipsUIIntervalTimeMS	= 200,	-- 计分提醒间隔时间（避免一直更新UI）
	ComboUIHideDelayTime				= 1,	-- Combo提示UI清空时间

	BarWSizeX = 164,
	BarBSizeX = 128,
	BarNormalSizeX = 180,
	RecycleTimeOffsetMS = 400,

	UINoteTypes = {
		None = 0,
		BlackNormal = 1,
		BlackUp = 2,
		BlackDown = 3,
		WhiteNormal = 4,
		WhiteUp = 5,
		WhiteDown = 6,
	},

	KeybroadSize = {
		BGY = 274,
		LargeBGY = 325,
	},

	IsWhiteKey = {
		[MusicPerformanceDefines.KeyDefines.KEY_C] = true,
		[MusicPerformanceDefines.KeyDefines.KEY_C_PLUS] = false,
		[MusicPerformanceDefines.KeyDefines.KEY_D] = true,
		[MusicPerformanceDefines.KeyDefines.KEY_D_PLUS] = false,
		[MusicPerformanceDefines.KeyDefines.KEY_E] = true,
		[MusicPerformanceDefines.KeyDefines.KEY_F] = true,
		[MusicPerformanceDefines.KeyDefines.KEY_F_PLUS] = false,
		[MusicPerformanceDefines.KeyDefines.KEY_G] = true,
		[MusicPerformanceDefines.KeyDefines.KEY_G_PLUS] = false,
		[MusicPerformanceDefines.KeyDefines.KEY_A] = true,
		[MusicPerformanceDefines.KeyDefines.KEY_A_PLUS] = false,
		[MusicPerformanceDefines.KeyDefines.KEY_B] = true,
		[MusicPerformanceDefines.KeyDefines.KEY_MAX] = true,
	},

	UIStates = {
		None = 0,
		Falling = 1,
		Miss = 2,
		Press = 3,
		WaitDestory = 4,
	},

	MissOpacity = 0.4,
	AssistItemOffset = 128,
	AssistItemOffsetIndex = {
		[MusicPerformanceDefines.KeyDefines.KEY_C] = -6,
		[MusicPerformanceDefines.KeyDefines.KEY_C_PLUS] = -5,
		[MusicPerformanceDefines.KeyDefines.KEY_D] = -4,
		[MusicPerformanceDefines.KeyDefines.KEY_D_PLUS] = -3,
		[MusicPerformanceDefines.KeyDefines.KEY_E] = -2,
		[MusicPerformanceDefines.KeyDefines.KEY_F] = -1,
		[MusicPerformanceDefines.KeyDefines.KEY_F_PLUS] = 0,
		[MusicPerformanceDefines.KeyDefines.KEY_G] = 1,
		[MusicPerformanceDefines.KeyDefines.KEY_G_PLUS] = 2,
		[MusicPerformanceDefines.KeyDefines.KEY_A] = 3,
		[MusicPerformanceDefines.KeyDefines.KEY_A_PLUS] = 4,
		[MusicPerformanceDefines.KeyDefines.KEY_B] = 5,
		[MusicPerformanceDefines.KeyDefines.KEY_MAX] = 6,
	},
	AnimCommentNames = {
		[MusicPerformanceDefines.AssistantScoreType.Bad] = "Mistake",
		[MusicPerformanceDefines.AssistantScoreType.Good] = "Good",
		[MusicPerformanceDefines.AssistantScoreType.Great] = "Great",
		[MusicPerformanceDefines.AssistantScoreType.Miss] = "Miss",
		[MusicPerformanceDefines.AssistantScoreType.Perfect] = "Perfect",
	},
}

return MusicPerformanceDefines