local LSTR = _G.LSTR
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local MakeLSTRAttrKey = require("Common/StringTools").MakeLSTRAttrKey
local MakeLSTRDict = require("Common/StringTools").MakeLSTRDict

local FUNCTION_TYPE = ProtoCommon.function_type
local CLASS_TYPE = ProtoCommon.class_type
local TASK_LIMIT = ProtoCS.Team.TeamRecruit.TASK_LIMIT

local DefaultRecruitType = 1
local MaxCodeLength = 4 
local MaxEquipLv = 999 
local PasswordErrorCode = 201022 
local UnknowTypeIcon = "Texture2D'/Game/Assets/Icon/061000/UI_Icon_061808.UI_Icon_061808'"


local RecruitFuncTypeName = MakeLSTRDict({
	[MakeLSTRAttrKey("None")] =  1310025,
	[MakeLSTRAttrKey("All")] =  1310026,
}, true)

--招募职能类型
local RecruitFunctionType = {
    None= 0,
    T   = 1 << FUNCTION_TYPE.FUNCTION_TYPE_GUARD, -- 防护
    N   = 1 << FUNCTION_TYPE.FUNCTION_TYPE_RECOVER, -- 治疗
    D   = 1 << FUNCTION_TYPE.FUNCTION_TYPE_ATTACK, -- 进攻
    TN  = (1 << FUNCTION_TYPE.FUNCTION_TYPE_GUARD) + (1 << FUNCTION_TYPE.FUNCTION_TYPE_RECOVER), -- 防护&治疗
    TD  = (1 << FUNCTION_TYPE.FUNCTION_TYPE_GUARD) + (1 << FUNCTION_TYPE.FUNCTION_TYPE_ATTACK), -- 防护&进攻
    ND  = (1 << FUNCTION_TYPE.FUNCTION_TYPE_ATTACK) + (1 << FUNCTION_TYPE.FUNCTION_TYPE_RECOVER), -- 进攻&治疗
    TND = (1 << FUNCTION_TYPE.FUNCTION_TYPE_GUARD) + (1 << FUNCTION_TYPE.FUNCTION_TYPE_RECOVER) + (1 << FUNCTION_TYPE.FUNCTION_TYPE_ATTACK), -- 防护&治疗&进攻
	PD = (1 << FUNCTION_TYPE.FUNCTION_TYPE_PRODUCTION), --生产
	GA = (1 << FUNCTION_TYPE.FUNCTION_TYPE_GATHER),	--采集
    All = 999, -- 全部
}

--招募职能类型图标
local FuncTypeIconConfig = {
	[RecruitFunctionType.None] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900141.UI_Icon_900141'",
	[RecruitFunctionType.T] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900133.UI_Icon_900133'",
	[RecruitFunctionType.N] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900134.UI_Icon_900134'",
	[RecruitFunctionType.D] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900135.UI_Icon_900135'",
	[RecruitFunctionType.TN] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900138.UI_Icon_900138'",
	[RecruitFunctionType.TD] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900139.UI_Icon_900139'",
	[RecruitFunctionType.ND] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900140.UI_Icon_900140'",
	[RecruitFunctionType.TND] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900137.UI_Icon_900137'",
	[RecruitFunctionType.All] 	= "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900136.UI_Icon_900136'",
}

--招募职能类型简易图标
local FuncTypeSimpleIconConfig = {
	[RecruitFunctionType.T] 	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Icon_FangHu_png.UI_Team_Function_Icon_FangHu_png'",
	[RecruitFunctionType.N] 	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Icon_ZhiLiao_png.UI_Team_Function_Icon_ZhiLiao_png'",
	[RecruitFunctionType.D] 	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Icon_JinGong_png.UI_Team_Function_Icon_JinGong_png'",
	[RecruitFunctionType.TN] 	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Icon_1T1N_png.UI_Team_Function_Icon_1T1N_png'",
	[RecruitFunctionType.TD] 	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Icon_1T1D_png.UI_Team_Function_Icon_1T1D_png'",
	[RecruitFunctionType.ND] 	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Icon_1D1N_png.UI_Team_Function_Icon_1D1N_png'",
	[RecruitFunctionType.TND] 	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Icon_1T1D1N_png.UI_Team_Function_Icon_1T1D1N_png'",
	[RecruitFunctionType.All] 	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Img_Empty_png.UI_Team_Function_Img_Empty_png'",
	[RecruitFunctionType.PD]	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Img_Empty_png.UI_Team_Function_Img_Empty_png'",
	[RecruitFunctionType.GA]	= "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Function_Img_Empty_png.UI_Team_Function_Img_Empty_png'",
}

--招募职能编辑配置
local RecruitFunctionEditConfig = {
	MakeLSTRDict({
		ClassType = CLASS_TYPE.CLASS_TYPE_TANK,
		[MakeLSTRAttrKey("Name")] = 1310027,
		Icon = "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900142.UI_Icon_900142'",
	}),
	MakeLSTRDict({
		ClassType = CLASS_TYPE.CLASS_TYPE_HEALTH,
		[MakeLSTRAttrKey("Name")] = 1310028,
		Icon = "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900146.UI_Icon_900146'",
	}),
	MakeLSTRDict({
		ClassType = CLASS_TYPE.CLASS_TYPE_NEAR,
		[MakeLSTRAttrKey("Name")] = 1310029,
		Icon = "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900143.UI_Icon_900143'",
	}),
	MakeLSTRDict({
		ClassType = CLASS_TYPE.CLASS_TYPE_FAR,
		[MakeLSTRAttrKey("Name")] = 1310030,
		Icon = "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900144.UI_Icon_900144'",
	}),
	MakeLSTRDict({
		ClassType = CLASS_TYPE.CLASS_TYPE_MAGIC,
		[MakeLSTRAttrKey("Name")] = 1310031,
		Icon = "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900145.UI_Icon_900145'",
		IsLastItem = true,
	}),
}

local TaskLimitIcon = {
	-- "常规"
	[TASK_LIMIT.TASK_LIMIT_UNKNOW] = "/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_Style_CG_png.UI_PWorld_Icon_Style_CG_png",

	-- "挑战模式"
	[TASK_LIMIT.TASK_LIMIT_CHALLENGE] = "/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_Style_TZ_png.UI_PWorld_Icon_Style_TZ_png",

	-- "解除限制模式"
	[TASK_LIMIT.TASK_LIMIT_FREE_UNLIMITED] = "/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_Style_JCXZ_png.UI_PWorld_Icon_Style_JCXZ_png",

	-- "自由探索模式"
	[TASK_LIMIT.TASK_LIMIT_FREE_ORIENTATION] = "/Game/UI/Atlas/Team/Frames/UI_Team_Search_Icon_ZYTS_png.UI_Team_Search_Icon_ZYTS_png",
}

local TeamRecruitDefine = MakeLSTRDict({
	DefaultRecruitType 	= DefaultRecruitType,
	MaxCodeLength 		= MaxCodeLength,
	MaxEquipLv 			= MaxEquipLv,
	PasswordErrorCode 	= PasswordErrorCode,
	[MakeLSTRAttrKey("CompleteTaskWord")] 	= 1310112,
	UnknowTypeIcon 		= UnknowTypeIcon,
	RecruitFuncTypeName = RecruitFuncTypeName,
	RecruitFunctionType = RecruitFunctionType,
	FuncTypeIconConfig 	= FuncTypeIconConfig,

	FuncTypeSimpleIconConfig  = FuncTypeSimpleIconConfig,
	RecruitFunctionEditConfig = RecruitFunctionEditConfig,
	TaskLimitIcon = TaskLimitIcon,
}, true)

return TeamRecruitDefine