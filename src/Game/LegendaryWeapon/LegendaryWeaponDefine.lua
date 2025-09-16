--local chapter = require("Game.Quest.BasicClass.Chapter")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")

local LegendaryWeaponDefine = {}

--- 制作强化动画音效
LegendaryWeaponDefine.AppearSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Weapon/Play_UI_Weapon_appear.Play_UI_Weapon_appear'"
--- 切换页签武器转动音效
LegendaryWeaponDefine.SwitchSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Weapon/Play_UI_Weapon_switch.Play_UI_Weapon_switch'"
--- 场景路径
LegendaryWeaponDefine.SceneActorPath = "Blueprint'/Game/UMG/3DUI/FMWeaponMenu/BP_FMWeaponSystem.BP_FMWeaponSystem_C'"

--- 红点ID
LegendaryWeaponDefine.RedDotID = 
{
	Menu			= 1   ,		--二级菜单
	LegendaryWeapon = 1000,		--二级菜单传奇武器
	Topic1 			= 1001,		--上古武器
	Topic2 			= 1002,		--黄道武器
	Make 			= 1003,		--制作页切换
	Topic1Chapter1  = 1004,		--上古武器第一章
	Topic1Chapter2  = 1005,		--上古武器第二章
	Topic1Chapter3  = 1006,		--上古武器第三章
	Topic2Chapter1  = 1007,		--黄道武器第三章
	Topic2Chapter2  = 1008,		--黄道武器第三章
	Topic2Chapter3  = 1009,		--黄道武器第三章
	ProfChange 		= 1010,		--职业切换列表
	Knight 			= 1011,		--骑士
	Warrior 		= 1012,		--战士
	Dragon 			= 1013,		--龙骑
	Monk 			= 1014,		--武僧
	Ninja 			= 1015,		--忍者
	BLM 			= 1016,		--黑魔
	SMN 			= 1017,		--召唤
	BRD 			= 1018,		--诗人
	WHM 			= 1019,		--白魔
	SCH 			= 1020,		--学者
}

--- 获取对应主题章节的红点，这里后面如果很多应该配置红点ID到传奇武器表
function LegendaryWeaponDefine.GetTopicOrChapterRedDotID(TopicID, ChapterID)
	if TopicID == 1 then
		if ChapterID == 1 then
			return LegendaryWeaponDefine.RedDotID.Topic1Chapter1
		elseif ChapterID == 2 then
			return LegendaryWeaponDefine.RedDotID.Topic1Chapter2
		elseif ChapterID == 3 then
			return LegendaryWeaponDefine.RedDotID.Topic1Chapter3
		elseif nil == ChapterID then
			return LegendaryWeaponDefine.RedDotID.Topic1
		end
	elseif TopicID == 2 then
		if ChapterID == 1 then
			return LegendaryWeaponDefine.RedDotID.Topic2Chapter1
		elseif ChapterID == 2 then
			return LegendaryWeaponDefine.RedDotID.Topic2Chapter2
		elseif ChapterID == 3 then
			return LegendaryWeaponDefine.RedDotID.Topic2Chapter3
		elseif nil == ChapterID then
			return LegendaryWeaponDefine.RedDotID.Topic2
		end
	end
end

--- 章节ID 映射 红点ID
LegendaryWeaponDefine.ChapterRedDotID = 
{
	[1] = LegendaryWeaponDefine.RedDotID.Topic1Chapter1,
	[2] = LegendaryWeaponDefine.RedDotID.Topic1Chapter2,
	[3] = LegendaryWeaponDefine.RedDotID.Topic1Chapter3,
	[4] = LegendaryWeaponDefine.RedDotID.Topic2Chapter1,
	[5] = LegendaryWeaponDefine.RedDotID.Topic2Chapter2,
	[6] = LegendaryWeaponDefine.RedDotID.Topic2Chapter3
}

--- 主题ID 映射 红点ID
LegendaryWeaponDefine.TopicRedDotID = 
{
	[1] = LegendaryWeaponDefine.RedDotID.Topic1,
	[2] = LegendaryWeaponDefine.RedDotID.Topic2,
}

--- 职业类型 映射 红点ID
LegendaryWeaponDefine.ProfRedDotID = 
{
	[ProtoCommon.prof_type.PROF_TYPE_PALADIN] = LegendaryWeaponDefine.RedDotID.Knight,
	[ProtoCommon.prof_type.PROF_TYPE_WARRIOR] = LegendaryWeaponDefine.RedDotID.Warrior,
	[ProtoCommon.prof_type.PROF_TYPE_DRAGOON] = LegendaryWeaponDefine.RedDotID.Dragon,
	[ProtoCommon.prof_type.PROF_TYPE_MONK] = LegendaryWeaponDefine.RedDotID.Monk,
	[ProtoCommon.prof_type.PROF_TYPE_NINJA] = LegendaryWeaponDefine.RedDotID.Ninja,
	[ProtoCommon.prof_type.PROF_TYPE_BLACKMAGE] = LegendaryWeaponDefine.RedDotID.BLM,
	[ProtoCommon.prof_type.PROF_TYPE_SUMMONER] = LegendaryWeaponDefine.RedDotID.SMN,
	[ProtoCommon.prof_type.PROF_TYPE_BARD] = LegendaryWeaponDefine.RedDotID.BRD,
	[ProtoCommon.prof_type.PROF_TYPE_WHITEMAGE] = LegendaryWeaponDefine.RedDotID.WHM,
	[ProtoCommon.prof_type.PROF_TYPE_SCHOLAR] = LegendaryWeaponDefine.RedDotID.SCH,
}

--- 职业初始化表中的基础职业ID将与武器对应职业关系
LegendaryWeaponDefine.ProfIdToWeaponProf = 
{
	[1] = ProtoCommon.prof_type.PROF_TYPE_PALADIN,
	[2] = ProtoCommon.prof_type.PROF_TYPE_WARRIOR,
	[3] = ProtoCommon.prof_type.PROF_TYPE_MONK,
	[4] = ProtoCommon.prof_type.PROF_TYPE_DRAGOON,
	[5] = ProtoCommon.prof_type.PROF_TYPE_NINJA,
	[6] = ProtoCommon.prof_type.PROF_TYPE_BARD,
	[7] = ProtoCommon.prof_type.PROF_TYPE_BLACKMAGE,
	[8] = ProtoCommon.prof_type.PROF_TYPE_SUMMONER,
	[9] = ProtoCommon.prof_type.PROF_TYPE_WHITEMAGE,
	[10] = ProtoCommon.prof_type.PROF_TYPE_PALADIN,
	[12] = ProtoCommon.prof_type.PROF_TYPE_WARRIOR,
	[15] = ProtoCommon.prof_type.PROF_TYPE_NINJA,
	[16] = ProtoCommon.prof_type.PROF_TYPE_DRAGOON,
	[17] = ProtoCommon.prof_type.PROF_TYPE_MONK,
	[18] = ProtoCommon.prof_type.PROF_TYPE_BARD,
	[21] = ProtoCommon.prof_type.PROF_TYPE_BLACKMAGE,
	[22] = ProtoCommon.prof_type.PROF_TYPE_SUMMONER,
	[25] = ProtoCommon.prof_type.PROF_TYPE_WHITEMAGE,
	[26] = ProtoCommon.prof_type.PROF_TYPE_SCHOLAR,
}

--- 传奇武器特殊配置的不同种族展示位置的关系
LegendaryWeaponDefine.RoleTransform = 
{
	["c0101"] = 1,
	["c0201"] = 2,
	["c0301"] = 3,
	["c0401"] = 4,
	["c0501"] = 5,
	["c0601"] = 6,
	["c0701"] = 7,
	["c0801"] = 8,
	["c0901"] = 9,
	["c1001"] = 10,
	["c1101"] = 11,
	["c1201"] = 12,
	["c1301"] = 13,
	["c1401"] = 14,
	["c1501"] = 15,
}

--- 传奇武器材料品质颜色配置
LegendaryWeaponDefine.ItemQualityColor = 
{
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = {"5F6AFFFF","7E92C3FF","3455DAFF"},	--蓝 EEF2
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = {"8DCE6EFF","71C382FF","639D5AFF"},	--绿 EEF3
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = {"7E3DFFFF","7D7DC3FF","8637FCFF"},	--紫 EEF4
}

--- 传奇武器在制作完成时播放的过场动画路径
LegendaryWeaponDefine.InterludeSeq = 
{
	[ProtoCommon.prof_type.PROF_TYPE_PALADIN] = "LevelSequence'/Game/Assets/Cut/ffxiv/getrer/getrer00010/getrer00010_proj/getrer00010.getrer00010'",
	[ProtoCommon.prof_type.PROF_TYPE_WARRIOR] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00030/getrer00030_proj/getrer00030.getrer00030'",
	[ProtoCommon.prof_type.PROF_TYPE_DRAGOON] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00040/getrer00040_proj/getrer00040.getrer00040'",
	[ProtoCommon.prof_type.PROF_TYPE_MONK] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00020/getrer00020_proj/getrer00020.getrer00020'",
	[ProtoCommon.prof_type.PROF_TYPE_NINJA] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00090/getrer00090_proj/getrer00090.getrer00090'",
	[ProtoCommon.prof_type.PROF_TYPE_BLACKMAGE] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00070/getrer00070_proj/getrer00070.getrer00070'",
	[ProtoCommon.prof_type.PROF_TYPE_SUMMONER] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00080/getrer00080_proj/getrer00080.getrer00080'",
	[ProtoCommon.prof_type.PROF_TYPE_BARD] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00050/getrer00050_proj/getrer00050.getrer00050'",
	[ProtoCommon.prof_type.PROF_TYPE_WHITEMAGE] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00060/getrer00060_proj/getrer00060.getrer00060'",
	[ProtoCommon.prof_type.PROF_TYPE_SCHOLAR] = "LevelSequence'/Game/Assets/Cut/ffxiv_m/getrer/getrer00100/getrer00100_proj/getrer00100.getrer00100'",
}

return LegendaryWeaponDefine