local ProtoCommon = require("Protocol/ProtoCommon")

local LSTR = _G.LSTR

local ProfDefine = {}

ProfDefine.ProfClassName =
{
	[ProtoCommon.class_type.CLASS_TYPE_NULL] = LSTR(1020004),
	[ProtoCommon.class_type.CLASS_TYPE_TANK] = LSTR(1020065),
	[ProtoCommon.class_type.CLASS_TYPE_NEAR] = LSTR(1020066),
	[ProtoCommon.class_type.CLASS_TYPE_FAR] = LSTR(1020067),
	[ProtoCommon.class_type.CLASS_TYPE_MAGIC] = LSTR(1020068),
	[ProtoCommon.class_type.CLASS_TYPE_HEALTH] = LSTR(1020069),
	[ProtoCommon.class_type.CLASS_TYPE_CARPENTER] = LSTR(1020070),
	[ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER] = LSTR(1020071),
	[ProtoCommon.class_type.CLASS_TYPE_COMBAT] = LSTR(1020072),
	[ProtoCommon.class_type.CLASS_TYPE_PRODUCTION] = LSTR(1020073),
}

ProfDefine.ProfClassIconMap =
{
	[ProtoCommon.class_type.CLASS_TYPE_NULL] = "",
	[ProtoCommon.class_type.CLASS_TYPE_TANK] = "UI_Icon_900142",
	[ProtoCommon.class_type.CLASS_TYPE_NEAR] = "UI_Icon_900143",
	[ProtoCommon.class_type.CLASS_TYPE_FAR] = "UI_Icon_900144",
	[ProtoCommon.class_type.CLASS_TYPE_MAGIC] = "UI_Icon_900145",
	[ProtoCommon.class_type.CLASS_TYPE_HEALTH] = "UI_Icon_900146",
	[ProtoCommon.class_type.CLASS_TYPE_CARPENTER] = "UI_Icon_900147",
	[ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER] = "UI_Icon_900148",
}

ProfDefine.ProfClassBgPathMap =
{
	[ProtoCommon.class_type.CLASS_TYPE_NULL] = "",
	[ProtoCommon.class_type.CLASS_TYPE_TANK] = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Img_JobBlue.UI_Equipment_Img_JobBlue'",
	[ProtoCommon.class_type.CLASS_TYPE_NEAR] = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Img_JobRed.UI_Equipment_Img_JobRed'",
	[ProtoCommon.class_type.CLASS_TYPE_FAR] = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Img_JobRed.UI_Equipment_Img_JobRed'",
	[ProtoCommon.class_type.CLASS_TYPE_MAGIC] = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Img_JobRed.UI_Equipment_Img_JobRed'",
	[ProtoCommon.class_type.CLASS_TYPE_HEALTH] = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Img_JobGreen.UI_Equipment_Img_JobGreen'",
	[ProtoCommon.class_type.CLASS_TYPE_CARPENTER] = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Img_JobGray.UI_Equipment_Img_JobGray'",
	[ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER] = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Img_JobGray.UI_Equipment_Img_JobGray'",
}

ProfDefine.ProfClassColorMap =
{
	[ProtoCommon.class_type.CLASS_TYPE_NULL] = "",
	[ProtoCommon.class_type.CLASS_TYPE_TANK] = "46658B33",
	[ProtoCommon.class_type.CLASS_TYPE_NEAR] = "71404033",
	[ProtoCommon.class_type.CLASS_TYPE_FAR] = "71404033",
	[ProtoCommon.class_type.CLASS_TYPE_MAGIC] = "71404033",
	[ProtoCommon.class_type.CLASS_TYPE_HEALTH] = "5B795333",
	[ProtoCommon.class_type.CLASS_TYPE_CARPENTER] = "69696933",
	[ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER] = "69696933",
}

-- 职能
ProfDefine.ProfFuncIconMap =
{
	[ProtoCommon.function_type.FUNCTION_TYPE_GUARD] = "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900133.UI_Icon_900133'",
	[ProtoCommon.function_type.FUNCTION_TYPE_ATTACK] = "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900135.UI_Icon_900135'",
	[ProtoCommon.function_type.FUNCTION_TYPE_RECOVER] = "Texture2D'/Game/Assets/Icon/ItemIcon/900000/UI_Icon_900134.UI_Icon_900134'",
	[ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION] = "",
	[ProtoCommon.function_type.FUNCTION_TYPE_GATHER] = "",
	[ProtoCommon.function_type.FUNCTION_TYPE_NULL] = "",
}

--- 稀缺职能
ProfDefine.LackProfFuncIconMap =
{
	[ProtoCommon.function_type.FUNCTION_TYPE_GUARD] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900142.UI_Icon_900142'",
	[ProtoCommon.function_type.FUNCTION_TYPE_ATTACK] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900180.UI_Icon_900180'",
	[ProtoCommon.function_type.FUNCTION_TYPE_RECOVER] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900146.UI_Icon_900146'",
	[ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION] = "",
	[ProtoCommon.function_type.FUNCTION_TYPE_GATHER] = "",
	[ProtoCommon.function_type.FUNCTION_TYPE_NULL] = "",
}

--- 稀缺职能
ProfDefine.LackProfFuncIconMapForMatch =
{
	[ProtoCommon.function_type.FUNCTION_TYPE_GUARD] = "PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_JobStyle_03_png.UI_PWorld_Icon_JobStyle_03_png'",
	[ProtoCommon.function_type.FUNCTION_TYPE_ATTACK] = "PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_JobStyle_01_png.UI_PWorld_Icon_JobStyle_01_png'",
	[ProtoCommon.function_type.FUNCTION_TYPE_RECOVER] = "PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_JobStyle_02_png.UI_PWorld_Icon_JobStyle_02_png'",
	[ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION] = "",
	[ProtoCommon.function_type.FUNCTION_TYPE_GATHER] = "",
	[ProtoCommon.function_type.FUNCTION_TYPE_NULL] = "",
}

ProfDefine.ProfFuncNameMap =
{
	[ProtoCommon.function_type.FUNCTION_TYPE_GUARD] = LSTR("防护职业"),
	[ProtoCommon.function_type.FUNCTION_TYPE_ATTACK] = LSTR("进攻职业"),
	[ProtoCommon.function_type.FUNCTION_TYPE_RECOVER] = LSTR("治疗职业"),
	[ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION] = LSTR("制造职业"),
	[ProtoCommon.function_type.FUNCTION_TYPE_GATHER] = LSTR("采集职业"),
	[ProtoCommon.function_type.FUNCTION_TYPE_NULL] = LSTR("空"),
}

ProfDefine.ProfBgColor =
{
	[ProtoCommon.function_type.FUNCTION_TYPE_GUARD] = "Blue",
	[ProtoCommon.function_type.FUNCTION_TYPE_ATTACK] = "Red",
	[ProtoCommon.function_type.FUNCTION_TYPE_RECOVER] = "Green",
	[ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION] = "Grey",
	[ProtoCommon.function_type.FUNCTION_TYPE_GATHER] = "Grey",
	[ProtoCommon.function_type.FUNCTION_TYPE_NULL] = "Grey",
}

ProfDefine.ProfLevelUpAssetPaths =
{
	-- FXPath = "ParticleSystem'/Game/Assets/Effect/Particles/Test/Eletric_1.Eletric_1'",
	-- SoundPath = "AkAudioEvent'/Game/WwiseEvent/Characters/Scholar/Play_SE_VFX_Abi_Sch_FairyChHeal_c.Play_SE_VFX_Abi_Sch_FairyChHeal_c'",
	FXPath = "VfxBlueprint'/Game/Assets/Effect/Particles/PlayerCommon/VBP/BP_levelup1f.BP_levelup1f_C'",
	SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_SE_VFX_LvUP.Play_SE_VFX_LvUP'",
}

ProfDefine.ProfSwitchReason = {
	MusicPerformance = 1,
}

return ProfDefine
