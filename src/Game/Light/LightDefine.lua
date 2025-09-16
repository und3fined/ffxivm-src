--
-- Author: sammrli
-- Date: 2024-3-4
-- Description:
--


local FVector = _G.UE.FVector

---灯光关卡id
local LightLevelID =
{
    LIGHT_LEVEL_ID_COMMON = 0,
    LIGHT_LEVEL_ID_RECHARGE = 1,
    LIGHT_LEVEL_ID_RECHARGE2 = 2,
    LIGHT_LEVEL_ID_EMAIL = 3,
    LIGHT_LEVEL_ID_SKILL_SYSTEM = 4,
    LIGHT_LEVEL_ID_FASHION_EVALUATION = 10,
    LIGHT_LEVEL_ID_FASHION_EVALUATION_FOCU = 11,
    LIGHT_LEVEL_ID_COMPANION_ARCHIVE = 12,
    LIGHT_LEVEL_ID_JD_MINIGAME = 13,
    LIGHT_LEVEL_ID_STORE = 14,
    LIGHT_LEVEL_ID_EQUIP = 15,
    LIGHT_LEVEL_ID_WARDROBE = 16, 
    LIGHT_LEVEL_ID_PROFCAREER = 17,
    LIGHT_LEVEL_ID_BUDDY = 18,
    LIGHT_LEVEL_ID_TEST = 99,
}

---灯光关卡路径
local LightLevelPath =
{
    [LightLevelID.LIGHT_LEVEL_ID_COMMON] = "/Game/LightManager/LightPresets/Level/UI/UniversalLightLevel/L_Universal_LightLevel_v01",
    [LightLevelID.LIGHT_LEVEL_ID_EMAIL] = "/Game/LightManager/LightPresets/Level/UI/EmailInterface/L_EmailInterface_LightLevel_v01",
    [LightLevelID.LIGHT_LEVEL_ID_RECHARGE] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODUI_Recharge.L_TODUI_Recharge",
    [LightLevelID.LIGHT_LEVEL_ID_RECHARGE2] = "/Game/LightManager/LightPresets/Level/UI/rechargeSystem/L_rechargeSystem_LightLevel_v02",
    [LightLevelID.LIGHT_LEVEL_ID_SKILL_SYSTEM] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODUI_Skill",
    [LightLevelID.LIGHT_LEVEL_ID_FASHION_EVALUATION] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODUI_FashionEvaluation_v01",
    [LightLevelID.LIGHT_LEVEL_ID_FASHION_EVALUATION_FOCU] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODUI_FashionEvaluation_v02",
    [LightLevelID.LIGHT_LEVEL_ID_JD_MINIGAME] = "/Game/LightManager/LightPresets/Level/UI/MiniGame/L_MiniGame_LightLevel_v01.L_MiniGame_LightLevel_v01'",
    [LightLevelID.LIGHT_LEVEL_ID_COMPANION_ARCHIVE] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODUI_Companion.L_TODUI_Companion",
    [LightLevelID.LIGHT_LEVEL_ID_STORE] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODUI_Store",
    [LightLevelID.LIGHT_LEVEL_ID_WARDROBE] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/TODUI_Wardrobe.TODUI_Wardrobe",
    [LightLevelID.LIGHT_LEVEL_ID_EQUIP] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODUI_Equipment",
    [LightLevelID.LIGHT_LEVEL_ID_PROFCAREER] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODI_Jobtutorial",
    [LightLevelID.LIGHT_LEVEL_ID_BUDDY] = "/Game/LightManager/LightPresets/Level/UI/UIGeneralLighting/L_TODUI_Buddy.L_TODUI_Buddy",
}

---灯光关卡创建位置(如果不定义,默认位置:RenderSceneDefine.Location)
local LightLevelCreateLocation =
{
    [LightLevelID.LIGHT_LEVEL_ID_TEST] = FVector(0, 0, 0),
    [LightLevelID.LIGHT_LEVEL_ID_SKILL_SYSTEM] = FVector(0, 0, 50000),
    [LightLevelID.LIGHT_LEVEL_ID_FASHION_EVALUATION] = FVector(0, 0, 100000),
    [LightLevelID.LIGHT_LEVEL_ID_FASHION_EVALUATION_FOCU] = FVector(0, 0, 100000),
    [LightLevelID.LIGHT_LEVEL_ID_COMPANION_ARCHIVE] = FVector(0, 0, 100000),
    [LightLevelID.LIGHT_LEVEL_ID_EMAIL] = FVector(0, 100000, 100000),
}

local LightDefine =
{
    LightLevelID = LightLevelID,
	LightLevelPath = LightLevelPath,
    LightLevelCreateLocation = LightLevelCreateLocation,
}

return LightDefine