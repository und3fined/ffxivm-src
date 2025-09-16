local ProtoCommon = require("Protocol/ProtoCommon")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local LSTR = _G.LSTR

local LeveQuestDefine = {}

LeveQuestDefine.ToggleIndex = {
	Accept = 0,
	Submit = 1,
}

LeveQuestDefine.PayType = {
	Single = 0,
	Most = 1,
}

LeveQuestDefine.LevelGroupLevel = 5

LeveQuestDefine.RedDefines = {
	TabList = 10001,
}

LeveQuestDefine.NpcHeadIconState = {
    AccpteLeveQuest = "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071241.UI_Icon_071241'",
	SubmitLeveQuestEnough = "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071245.UI_Icon_071245'",
	SubmitLeveQuestNoEnough = "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071255.UI_Icon_071255'",
}

LeveQuestDefine.TabList = {
	ProtoCommon.prof_type.PROF_TYPE_CARPENTER,
	ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH,
	ProtoCommon.prof_type.PROF_TYPE_ARMOR,
	ProtoCommon.prof_type.PROF_TYPE_GOLDSMITH,
	ProtoCommon.prof_type.PROF_TYPE_LEATHER_WORK,
	ProtoCommon.prof_type.PROF_TYPE_WEAVER,
	ProtoCommon.prof_type.PROF_TYPE_ALCHEMIST,
	ProtoCommon.prof_type.PROF_TYPE_CULINARIAN,
	ProtoCommon.prof_type.PROF_TYPE_MINER,
	ProtoCommon.prof_type.PROF_TYPE_BOTANIST,
	ProtoCommon.prof_type.PROF_TYPE_FISHER,
}

-- 策划定义的排序权重
LeveQuestDefine.CareerSortData = {
	[ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH] = 1,
	[ProtoCommon.prof_type.PROF_TYPE_ARMOR] = 2, 
	[ProtoCommon.prof_type.PROF_TYPE_CARPENTER] = 3, 
	[ProtoCommon.prof_type.PROF_TYPE_GOLDSMITH] = 4, 
	[ProtoCommon.prof_type.PROF_TYPE_WEAVER] = 5, 
	[ProtoCommon.prof_type.PROF_TYPE_LEATHER_WORK] = 6, 
	[ProtoCommon.prof_type.PROF_TYPE_ALCHEMIST] = 7, 
	[ProtoCommon.prof_type.PROF_TYPE_CULINARIAN] = 8,
	[ProtoCommon.prof_type.PROF_TYPE_MINER] = 9,
	[ProtoCommon.prof_type.PROF_TYPE_BOTANIST] = 10,
	[ProtoCommon.prof_type.PROF_TYPE_FISHER] = 11,
}

return LeveQuestDefine