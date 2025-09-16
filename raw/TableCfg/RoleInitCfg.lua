-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _9_1 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_PLD.UI_Icon_Career_Main_PLD\'',
    _9_2 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_WAR.UI_Icon_Career_Main_WAR\'',
    _9_3 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_MNK.UI_Icon_Career_Main_MNK\'',
    _9_4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_DRG.UI_Icon_Career_Main_DRG\'',
    _9_5 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_NIN.UI_Icon_Career_Main_NIN\'',
    _9_6 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_BRD.UI_Icon_Career_Main_BRD\'',
    _9_7 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_BLM.UI_Icon_Career_Main_BLM\'',
    _9_8 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_SMN.UI_Icon_Career_Main_SMN\'',
    _9_9 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_WHM.UI_Icon_Career_Main_WHM\'',
    _12_1 = '[1,2]',
    _12_2 = '[22,23]',
    _12_3 = '[20,21]',
    _12_4 = '[13,14]',
    _12_5 = '[25,26]',
    _12_6 = '[3,4]',
    _12_7 = '[11,12]',
    _12_8 = '[27,28]',
}

---@class RoleInitCfg : CfgBase
local RoleInitCfg = {
	TableName = "c_role_init_cfg",
    LruKeyType = nil,
	KeyName = "Prof",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ProfName',
            },
            {
                Name = 'ProfFuncDesc',
            },
            {
                Name = 'ProfGrowUpDesc',
            },
            {
                Name = 'ProfDesc',
            },
            {
                Name = 'ProfExplain',
            },
            {
                Name = 'ProfPVETag',
            },
		}
    },
    DefaultValues = {
        AdvancedProf = 0,
        BornPWorld = 0,
        Class = 6,
        Function = 2,
        HomePlace = 0,
        IsCanCreate = 0,
        IsShowWhenMore = 0,
        IsVersionOpen = 1,
        ListID = 0,
        LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_GLA.UI_LoginCreate_Job_GLA\'',
        MainAttr = 0,
        MainWeapon = 11,
        _NpcID = '[]',
        Prof = 1,
        ProfAbbr = '',
        ProfAssetAbbr = 'GLA',
        ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_GLA.UI_Icon_Class_GLA\'',
        ProfLevel = 1,
        _ProfPVPTag = '[{"IconType":0,"Desc":""},{"IconType":0,"Desc":""},{"IconType":0,"Desc":""},{"IconType":0,"Desc":""}]',
        ProfProbability = 0,
        ProfRename = 'Gladiator',
        SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_JSS.UI_Icon_Job_Main_JSS\'',
        SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_GLA.UI_Icon_Job_GLA\'',
        SimpleIcon3 = '',
        SimpleIcon4 = '',
        SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_GLA.UI_InfoTips_Icon_JobUnlock_GLA\'',
        SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID1.MI_DX_UI_Prof_ProfID1\'',
        _SkillGroup = '[]',
        SortOrder = 0,
        SoulCrystalIcon = '',
        SoulcrystalDesc = '',
        Specialization = 1,
        SubWeapon = 0,
        _ProfPVETagNum = 2,
    },
	LuaData = {
        {
            AdvancedProf = 10,
            Class = 1,
            Function = 1,
            HomePlace = 1412,
            IsCanCreate = 1,
            MainAttr = 1,
            ProfLevel = 0,
            ProfProbability = 10,
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_GLA.UI_Icon_Job_GLA\'',
            SimpleIcon4 = CS._9_1,
            _SkillGroup = CS._12_1,
            SubWeapon = 6,
        },
        {
            AdvancedProf = 12,
            Class = 1,
            Function = 1,
            HomePlace = 1413,
            IsCanCreate = 1,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_MRD.UI_LoginCreate_Job_MRD\'',
            MainAttr = 1,
            MainWeapon = 12,
            Prof = 2,
            ProfAssetAbbr = 'MRD',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_MRD.UI_Icon_Class_MRD\'',
            ProfLevel = 0,
            ProfProbability = 10,
            ProfRename = 'Marauder',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_FSS.UI_Icon_Job_Main_FSS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_MRD.UI_Icon_Job_MRD\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_MRD.UI_Icon_Job_MRD\'',
            SimpleIcon4 = CS._9_2,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_MRD.UI_InfoTips_Icon_JobUnlock_MRD\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID2.MI_DX_UI_Prof_ProfID2\'',
            _SkillGroup = CS._12_2,
        },
        {
            AdvancedProf = 17,
            Class = 2,
            HomePlace = 1415,
            IsCanCreate = 1,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_PGL.UI_LoginCreate_Job_PGL\'',
            MainAttr = 2,
            MainWeapon = 16,
            Prof = 3,
            ProfAssetAbbr = 'PGL',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_PGL.UI_Icon_Class_PGL\'',
            ProfLevel = 0,
            ProfProbability = 10,
            ProfRename = 'Pugilist',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_GDJ.UI_Icon_Job_Main_GDJ\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_PGL.UI_Icon_Job_PGL\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_PGL.UI_Icon_Job_PGL\'',
            SimpleIcon4 = CS._9_3,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_PGL.UI_InfoTips_Icon_JobUnlock_PGL\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID3.MI_DX_UI_Prof_ProfID3\'',
            _SkillGroup = CS._12_3,
        },
        {
            AdvancedProf = 16,
            Class = 2,
            HomePlace = 1414,
            IsCanCreate = 1,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_LNC.UI_LoginCreate_Job_LNC\'',
            MainAttr = 2,
            MainWeapon = 15,
            Prof = 4,
            ProfAssetAbbr = 'LNC',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_LNC.UI_Icon_Class_LNC\'',
            ProfLevel = 0,
            ProfProbability = 10,
            ProfRename = 'Lancer',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_QSS.UI_Icon_Job_Main_QSS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_LNC.UI_Icon_Job_LNC\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_LNC.UI_Icon_Job_LNC\'',
            SimpleIcon4 = CS._9_4,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_LNC.UI_InfoTips_Icon_JobUnlock_LNC\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID4.MI_DX_UI_Prof_ProfID4\'',
            _SkillGroup = CS._12_4,
        },
        {
            AdvancedProf = 15,
            Class = 2,
            HomePlace = 1434,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_ROG.UI_LoginCreate_Job_ROG\'',
            MainAttr = 2,
            MainWeapon = 17,
            Prof = 5,
            ProfAssetAbbr = 'ROG',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_ROG.UI_Icon_Class_ROG\'',
            ProfLevel = 0,
            ProfRename = 'Rogue',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_SJS.UI_Icon_Job_Main_SJS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_ROG.UI_Icon_Job_ROG\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_ROG.UI_Icon_Job_ROG\'',
            SimpleIcon4 = CS._9_5,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_ROG.UI_InfoTips_Icon_JobUnlock_ROG\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID5.MI_DX_UI_Prof_ProfID5\'',
            _SkillGroup = CS._12_5,
        },
        {
            AdvancedProf = 18,
            Class = 3,
            HomePlace = 1416,
            IsCanCreate = 1,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_ARC.UI_LoginCreate_Job_ARC\'',
            MainAttr = 3,
            MainWeapon = 19,
            Prof = 6,
            ProfAssetAbbr = 'ARC',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_ARC.UI_Icon_Class_ARC\'',
            ProfLevel = 0,
            ProfProbability = 10,
            ProfRename = 'Archer',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_GJS.UI_Icon_Job_Main_GJS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_ARC.UI_Icon_Job_ARC\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_ARC.UI_Icon_Job_ARC\'',
            SimpleIcon4 = CS._9_6,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_ARC.UI_InfoTips_Icon_JobUnlock_ARC\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID6.MI_DX_UI_Prof_ProfID6\'',
            _SkillGroup = CS._12_6,
        },
        {
            AdvancedProf = 21,
            Class = 4,
            HomePlace = 1419,
            IsCanCreate = 1,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_THM.UI_LoginCreate_Job_THM\'',
            MainAttr = 4,
            MainWeapon = 22,
            Prof = 7,
            ProfAssetAbbr = 'THM',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_THM.UI_Icon_Class_THM\'',
            ProfLevel = 0,
            ProfProbability = 10,
            ProfRename = 'Thaumaturge',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_ZSS.UI_Icon_Job_Main_ZSS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_THM.UI_Icon_Job_THM\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_THM.UI_Icon_Job_THM\'',
            SimpleIcon4 = CS._9_7,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_THM.UI_InfoTips_Icon_JobUnlock_THM\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID7.MI_DX_UI_Prof_ProfID7\'',
            _SkillGroup = CS._12_7,
        },
        {
            AdvancedProf = 22,
            Class = 4,
            HomePlace = 1418,
            IsCanCreate = 1,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_ACN.UI_LoginCreate_Job_ACN\'',
            MainAttr = 4,
            MainWeapon = 27,
            Prof = 8,
            ProfAssetAbbr = 'ACN',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_ACN.UI_Icon_Class_ACN\'',
            ProfLevel = 0,
            ProfProbability = 10,
            ProfRename = 'Arcanist',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_MSS.UI_Icon_Job_Main_MSS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_ACN.UI_Icon_Job_ACN\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_ACN.UI_Icon_Job_ACN\'',
            SimpleIcon4 = CS._9_8,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_ACN.UI_InfoTips_Icon_JobUnlock_ACN\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID8.MI_DX_UI_Prof_ProfID8\'',
            _SkillGroup = CS._12_8,
        },
        {
            AdvancedProf = 25,
            Class = 5,
            Function = 3,
            HomePlace = 1417,
            IsCanCreate = 1,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_CNJ.UI_LoginCreate_Job_CNJ\'',
            MainAttr = 5,
            MainWeapon = 26,
            Prof = 9,
            ProfAssetAbbr = 'CNJ',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_CNJ.UI_Icon_Class_CNJ\'',
            ProfLevel = 0,
            ProfProbability = 20,
            ProfRename = 'Conjurer',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_HSS.UI_Icon_Job_Main_HSS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_CNJ.UI_Icon_Job_CNJ\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_CNJ.UI_Icon_Job_CNJ\'',
            SimpleIcon4 = CS._9_9,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_CNJ.UI_InfoTips_Icon_JobUnlock_CNJ\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID9.MI_DX_UI_Prof_ProfID9\'',
            _SkillGroup = '[37,6]',
        },
        {
            Class = 1,
            Function = 1,
            HomePlace = 1412,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_PLD.UI_LoginCreate_Job_PLD\'',
            MainAttr = 1,
            Prof = 10,
            ProfAssetAbbr = 'PLD',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_PLD.UI_Icon_Class_PLD\'',
            ProfRename = 'Paladin',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_QS.UI_Icon_Job_Main_QS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_PLD.UI_Icon_Job_PLD\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_PLD.UI_Icon_Job_PLD\'',
            SimpleIcon4 = CS._9_1,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_PLD.UI_InfoTips_Icon_JobUnlock_PLD\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID10.MI_DX_UI_Prof_ProfID10\'',
            _SkillGroup = CS._12_1,
            SortOrder = 1,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026003.UI_Icon_026003\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代骑士的记忆和荣誉。',
            SubWeapon = 6,
        },
        {
            Class = 1,
            Function = 1,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_DRK.UI_LoginCreate_Job_DRK\'',
            MainAttr = 1,
            MainWeapon = 13,
            Prof = 11,
            ProfAssetAbbr = 'DRK',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_DRK.UI_Icon_Class_DRK\'',
            ProfRename = 'Darkknight',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_AHQS.UI_Icon_Job_Main_AHQS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_DRK.UI_Icon_Job_DRK\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_DRK.UI_Icon_Career_Main_DRK\'',
            SimpleIcon5 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_DRK.UI_Icon_Job_DRK\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID11.MI_DX_UI_Prof_ProfID11\'',
            SortOrder = 3,
            SoulcrystalDesc = '灵魂的水晶，刻有历代暗黑骑士的记忆和灵魂。',
        },
        {
            Class = 1,
            Function = 1,
            HomePlace = 1413,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_WAR.UI_LoginCreate_Job_WAR\'',
            MainAttr = 1,
            MainWeapon = 12,
            Prof = 12,
            ProfAssetAbbr = 'WAR',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_WAR.UI_Icon_Class_WAR\'',
            ProfRename = 'Warrior',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_ZS.UI_Icon_Job_Main_ZS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_WAR.UI_Icon_Job_WAR\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_WAR.UI_Icon_Job_WAR\'',
            SimpleIcon4 = CS._9_2,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_WAR.UI_InfoTips_Icon_JobUnlock_WAR\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID12.MI_DX_UI_Prof_ProfID12\'',
            _SkillGroup = CS._12_2,
            SortOrder = 2,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026005.UI_Icon_026005\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代战士的记忆和斗志。',
        },
        {
            Class = 1,
            Function = 1,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_GNB.UI_LoginCreate_Job_GNB\'',
            MainAttr = 1,
            MainWeapon = 14,
            Prof = 13,
            ProfAssetAbbr = 'GNB',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_GNB.UI_Icon_Class_GNB\'',
            ProfRename = 'Gunbreaker',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_JQZS.UI_Icon_Job_Main_JQZS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_GNB.UI_Icon_Job_GNB\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_GNB.UI_Icon_Career_Main_GNB\'',
            SimpleIcon5 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_GNB.UI_Icon_Job_GNB\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID13.MI_DX_UI_Prof_ProfID13\'',
            SortOrder = 4,
            SoulcrystalDesc = '灵魂的水晶，刻有历代绝枪战士的记忆和觉悟。',
        },
        {
            Class = 2,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_SAM.UI_LoginCreate_Job_SAM\'',
            MainAttr = 2,
            MainWeapon = 18,
            Prof = 14,
            ProfAssetAbbr = 'SAM',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_SAM.UI_Icon_Class_SAM\'',
            ProfRename = 'Samurai',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_WuShi.UI_Icon_Job_Main_WuShi\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_SAM.UI_Icon_Job_SAM\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_SAM.UI_Icon_Career_Main_SAM\'',
            SimpleIcon5 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_SAM.UI_Icon_Job_SAM\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID14.MI_DX_UI_Prof_ProfID14\'',
            SortOrder = 11,
            SoulcrystalDesc = '灵魂的水晶，刻有历代武士的记忆和大义。',
        },
        {
            Class = 2,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_NIN.UI_LoginCreate_Job_NIN\'',
            MainAttr = 2,
            MainWeapon = 17,
            Prof = 15,
            ProfAssetAbbr = 'NIN',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_NIN.UI_Icon_Class_NIN\'',
            ProfRename = 'Ninja',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_RZ.UI_Icon_Job_Main_RZ\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_NIN.UI_Icon_Job_NIN\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_NIN.UI_Icon_Job_NIN\'',
            SimpleIcon4 = CS._9_5,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_NIN.UI_InfoTips_Icon_JobUnlock_NIN\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID15.MI_DX_UI_Prof_ProfID15\'',
            _SkillGroup = CS._12_5,
            SortOrder = 10,
            SoulcrystalDesc = '灵魂的水晶，刻有历代忍者的记忆和精神。',
        },
        {
            Class = 2,
            HomePlace = 1414,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_DRG.UI_LoginCreate_Job_DRG\'',
            MainAttr = 2,
            MainWeapon = 15,
            Prof = 16,
            ProfAssetAbbr = 'DRG',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_DRG.UI_Icon_Class_DRG\'',
            ProfRename = 'Dragoon',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_LQS.UI_Icon_Job_Main_LQS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_DRG.UI_Icon_Job_DRG\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_DRG.UI_Icon_Job_DRG\'',
            SimpleIcon4 = CS._9_4,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_DRG.UI_InfoTips_Icon_JobUnlock_DRG\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID16.MI_DX_UI_Prof_ProfID16\'',
            _SkillGroup = CS._12_4,
            SortOrder = 9,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026006.UI_Icon_026006\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代龙骑士的记忆和决心。',
        },
        {
            Class = 2,
            HomePlace = 1415,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_MNK.UI_LoginCreate_Job_MNK\'',
            MainAttr = 2,
            MainWeapon = 16,
            Prof = 17,
            ProfAssetAbbr = 'MNK',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_MNK.UI_Icon_Class_MNK\'',
            ProfRename = 'Monk',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_WuSeng.UI_Icon_Job_Main_WuSeng\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_MNK.UI_Icon_Job_MNK\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_MNK.UI_Icon_Job_MNK\'',
            SimpleIcon4 = CS._9_3,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_MNK.UI_InfoTips_Icon_JobUnlock_MNK\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID17.MI_DX_UI_Prof_ProfID17\'',
            _SkillGroup = CS._12_3,
            SortOrder = 8,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026004.UI_Icon_026004\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代武僧的记忆和气概。',
        },
        {
            Class = 3,
            HomePlace = 1416,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_BRD.UI_LoginCreate_Job_BRD\'',
            MainAttr = 3,
            MainWeapon = 19,
            Prof = 18,
            ProfAssetAbbr = 'BRD',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_BRD.UI_Icon_Class_BRD\'',
            ProfRename = 'Bard',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_YYSR.UI_Icon_Job_Main_YYSR\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_BRD.UI_Icon_Job_BRD\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_BRD.UI_Icon_Job_BRD\'',
            SimpleIcon4 = CS._9_6,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_BRD.UI_InfoTips_Icon_JobUnlock_BRD\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID18.MI_DX_UI_Prof_ProfID18\'',
            _SkillGroup = CS._12_6,
            SortOrder = 12,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026007.UI_Icon_026007\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代吟游诗人的记忆和旋律。',
        },
        {
            Class = 3,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_MCH.UI_LoginCreate_Job_MCH\'',
            MainAttr = 3,
            MainWeapon = 20,
            Prof = 19,
            ProfAssetAbbr = 'MCH',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_MCH.UI_Icon_Class_MCH\'',
            ProfRename = 'Machinist',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_JGS.UI_Icon_Job_Main_JGS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_MCH.UI_Icon_Job_MCH\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_MCH.UI_Icon_Career_Main_MCH\'',
            SimpleIcon5 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_MCH.UI_Icon_Job_MCH\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID19.MI_DX_UI_Prof_ProfID19\'',
            SortOrder = 13,
            SoulcrystalDesc = '与其他灵魂水晶不同，这颗水晶上尚未刻下历史的记忆。',
        },
        {
            Class = 3,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_DNC.UI_LoginCreate_Job_DNC\'',
            MainAttr = 3,
            MainWeapon = 21,
            Prof = 20,
            ProfAssetAbbr = 'DNC',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_DNC.UI_Icon_Class_DNC\'',
            ProfRename = 'Dancer',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_WZ.UI_Icon_Job_Main_WZ\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_DMC.UI_Icon_Job_DMC\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_DNC.UI_Icon_Career_Main_DNC\'',
            SimpleIcon5 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_DMC.UI_Icon_Job_DMC\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID20.MI_DX_UI_Prof_ProfID20\'',
            SortOrder = 14,
            SoulcrystalDesc = '灵魂的水晶，刻有历代舞者的记忆和舞蹈。',
        },
        {
            Class = 4,
            HomePlace = 1419,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_BLM.UI_LoginCreate_Job_BLM\'',
            MainAttr = 4,
            MainWeapon = 22,
            Prof = 21,
            ProfAssetAbbr = 'BLM',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_BLM.UI_Icon_Class_BLM\'',
            ProfRename = 'Blackmage',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_HMFS.UI_Icon_Job_Main_HMFS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_BLM.UI_Icon_Job_BLM\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_BLM.UI_Icon_Job_BLM\'',
            SimpleIcon4 = CS._9_7,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_BLM.UI_InfoTips_Icon_JobUnlock_BLM\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID21.MI_DX_UI_Prof_ProfID21\'',
            _SkillGroup = CS._12_7,
            SortOrder = 15,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026009.UI_Icon_026009\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代黑魔法师的记忆和魔力。',
        },
        {
            Class = 4,
            HomePlace = 1418,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_SMN.UI_LoginCreate_Job_SMN\'',
            MainAttr = 4,
            MainWeapon = 27,
            Prof = 22,
            ProfAssetAbbr = 'SMN',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_SMN.UI_Icon_Class_SMN\'',
            ProfRename = 'Summoner',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_ZHS.UI_Icon_Job_Main_ZHS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_SMN.UI_Icon_Job_SMN\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_SMN.UI_Icon_Job_SMN\'',
            SimpleIcon4 = CS._9_8,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_SMN.UI_InfoTips_Icon_JobUnlock_SMN\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID22.MI_DX_UI_Prof_ProfID22\'',
            _SkillGroup = CS._12_8,
            SortOrder = 16,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026010.UI_Icon_026010\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代召唤师的记忆和真理。',
        },
        {
            Class = 4,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_RDM.UI_LoginCreate_Job_RDM\'',
            MainAttr = 4,
            MainWeapon = 24,
            Prof = 23,
            ProfAssetAbbr = 'RDM',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_RDM.UI_Icon_Class_RDM\'',
            ProfRename = 'Redmage',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_CMFS.UI_Icon_Job_Main_CMFS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_RDM.UI_Icon_Job_RDM\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_RDM.UI_Icon_Career_Main_RDM\'',
            SimpleIcon5 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_RDM.UI_Icon_Job_RDM\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID23.MI_DX_UI_Prof_ProfID23\'',
            SortOrder = 17,
            SoulcrystalDesc = '灵魂的水晶，刻有历代赤魔法师的记忆和心血。',
        },
        {
            Class = 4,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_BLU.UI_LoginCreate_Job_BLU\'',
            MainAttr = 4,
            MainWeapon = 25,
            Prof = 24,
            ProfAssetAbbr = 'BLU',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_BLU.UI_Icon_Class_BLU\'',
            ProfRename = 'Bluemage',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_QMFS.UI_Icon_Job_Main_QMFS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_BLU.UI_Icon_Job_BLU\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_BLU.UI_Icon_Career_Main_BLU\'',
            SimpleIcon5 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_BLU.UI_Icon_Job_BLU\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID24.MI_DX_UI_Prof_ProfID24\'',
            SortOrder = 18,
            SoulcrystalDesc = '赠送给新一代青魔法师用于证明身份的特制灵魂水晶。',
        },
        {
            Class = 5,
            Function = 3,
            HomePlace = 1417,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_WHM.UI_LoginCreate_Job_WHM\'',
            MainAttr = 5,
            MainWeapon = 26,
            Prof = 25,
            ProfAssetAbbr = 'WHM',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_WHM.UI_Icon_Class_WHM\'',
            ProfRename = 'Whitemage',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_BMFS.UI_Icon_Job_Main_BMFS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_WHM.UI_Icon_Job_WHM\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_WHM.UI_Icon_Job_WHM\'',
            SimpleIcon4 = CS._9_9,
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_WHM.UI_InfoTips_Icon_JobUnlock_WHM\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID25.MI_DX_UI_Prof_ProfID25\'',
            _SkillGroup = '[5,6]',
            SortOrder = 5,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026008.UI_Icon_026008\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代白魔法师的记忆和圣迹。',
        },
        {
            Class = 5,
            Function = 3,
            HomePlace = 1432,
            IsShowWhenMore = 1,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_SCH.UI_LoginCreate_Job_SCH\'',
            MainAttr = 5,
            MainWeapon = 23,
            Prof = 26,
            ProfAssetAbbr = 'SCH',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_SCH.UI_Icon_Class_SCH\'',
            ProfRename = 'Scholar',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_XZ.UI_Icon_Job_Main_XZ\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_SCH.UI_Icon_Job_SCH\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_SCH.UI_Icon_Job_SCH\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_SCH.UI_Icon_Career_Main_SCH\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_SCH.UI_InfoTips_Icon_JobUnlock_SCH\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID26.MI_DX_UI_Prof_ProfID26\'',
            _SkillGroup = '[18,19]',
            SortOrder = 6,
            SoulCrystalIcon = 'Texture2D\'/Game/Assets/Icon/ItemIcon/026000/UI_Icon_026011.UI_Icon_026011\'',
            SoulcrystalDesc = '灵魂的水晶，刻有历代学者的记忆和学识。',
        },
        {
            Class = 5,
            Function = 3,
            IsVersionOpen = 0,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/LoginCreate/UI_LoginCreate_Job_AST.UI_LoginCreate_Job_AST\'',
            MainAttr = 5,
            MainWeapon = 28,
            Prof = 27,
            ProfAssetAbbr = 'AST',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_AST.UI_Icon_Class_AST\'',
            ProfRename = 'Astrologian',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_ZXSS.UI_Icon_Job_Main_ZXSS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_AST.UI_Icon_Job_AST\'',
            SimpleIcon4 = 'Texture2D\'/Game/Assets/Icon/Skill/SkillJob/UI_Icon_Career_Main_AST.UI_Icon_Career_Main_AST\'',
            SimpleIcon5 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_AST.UI_Icon_Job_AST\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID27.MI_DX_UI_Prof_ProfID27\'',
            SortOrder = 7,
            SoulcrystalDesc = '灵魂的水晶，刻有历代占星术士的记忆和知识。',
        },
        {
            Function = 4,
            HomePlace = 1421,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_BSM.UI_Icon_Career_Second_BSM\'',
            MainWeapon = 32,
            Prof = 28,
            ProfAbbr = 'blk',
            ProfAssetAbbr = 'BSM',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_BSM.UI_Icon_Class_BSM\'',
            ProfRename = 'Blacksmith',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_DTJ.UI_Icon_Job_Second_DTJ\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_BSM.UI_Icon_Job_BSM\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_BSM.UI_Icon_Job_BSM\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_BSM.UI_InfoTips_Icon_JobUnlock_BSM\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID28.MI_DX_UI_Prof_ProfID28\'',
            _SkillGroup = '[29,29]',
            SortOrder = 20,
            Specialization = 2,
            SubWeapon = 43,
        },
        {
            Function = 4,
            HomePlace = 1422,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_ARM.UI_Icon_Career_Second_ARM\'',
            MainWeapon = 33,
            Prof = 29,
            ProfAbbr = 'arm',
            ProfAssetAbbr = 'ARM',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_ARM.UI_Icon_Class_ARM\'',
            ProfRename = 'Armorer',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_DuanJiaJiang.UI_Icon_Job_Second_DuanJiaJiang\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_ARM.UI_Icon_Job_ARM\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_ARM.UI_Icon_Job_ARM\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_ARM.UI_InfoTips_Icon_JobUnlock_ARM\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID29.MI_DX_UI_Prof_ProfID29\'',
            _SkillGroup = '[30,30]',
            SortOrder = 21,
            Specialization = 2,
            SubWeapon = 44,
        },
        {
            Function = 4,
            HomePlace = 1423,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_CRP.UI_Icon_Career_Second_CRP\'',
            MainWeapon = 31,
            Prof = 30,
            ProfAbbr = 'wod',
            ProfAssetAbbr = 'CRP',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_CRP.UI_Icon_Class_CRP\'',
            ProfRename = 'Carpenter',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_KMG.UI_Icon_Job_Second_KMG\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_CRP.UI_Icon_Job_CRP\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_CRP.UI_Icon_Job_CRP\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_CRP.UI_InfoTips_Icon_JobUnlock_CRP\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID30.MI_DX_UI_Prof_ProfID30\'',
            _SkillGroup = '[31,31]',
            SortOrder = 19,
            Specialization = 2,
            SubWeapon = 42,
        },
        {
            Function = 4,
            HomePlace = 1424,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_GSM.UI_Icon_Career_Second_GSM\'',
            MainWeapon = 34,
            Prof = 31,
            ProfAbbr = 'gld',
            ProfAssetAbbr = 'GSM',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_GSM.UI_Icon_Class_GSM\'',
            ProfRename = 'Goldsmith',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_DiaoJinJiang.UI_Icon_Job_Second_DiaoJinJiang\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_GSM.UI_Icon_Job_GSM\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_GSM.UI_Icon_Job_GSM\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_GSM.UI_InfoTips_Icon_JobUnlock_GSM\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID31.MI_DX_UI_Prof_ProfID31\'',
            _SkillGroup = '[32,32]',
            SortOrder = 22,
            Specialization = 2,
            SubWeapon = 45,
        },
        {
            Function = 4,
            HomePlace = 1425,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_WVR.UI_Icon_Career_Second_WVR\'',
            MainWeapon = 36,
            Prof = 32,
            ProfAbbr = 'sew',
            ProfAssetAbbr = 'WVR',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_WVR.UI_Icon_Class_WVR\'',
            ProfRename = 'Weaver',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_ZYJ.UI_Icon_Job_Second_ZYJ\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_WVR.UI_Icon_Job_WVR\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_WVR.UI_Icon_Job_WVR\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_WVR.UI_InfoTips_Icon_JobUnlock_WVR\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID32.MI_DX_UI_Prof_ProfID32\'',
            _SkillGroup = '[33,33]',
            SortOrder = 24,
            Specialization = 2,
            SubWeapon = 47,
        },
        {
            Function = 4,
            HomePlace = 1426,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_LTW.UI_Icon_Career_Second_LTW\'',
            MainWeapon = 35,
            Prof = 33,
            ProfAbbr = 'lth',
            ProfAssetAbbr = 'LTW',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_LTW.UI_Icon_Class_LTW\'',
            ProfRename = 'Leatherworker',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_ZGJ.UI_Icon_Job_Second_ZGJ\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_LTW.UI_Icon_Job_LTW\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_LTW.UI_Icon_Job_LTW\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_LTW.UI_InfoTips_Icon_JobUnlock_LTW\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID33.MI_DX_UI_Prof_ProfID33\'',
            _SkillGroup = '[34,34]',
            SortOrder = 23,
            Specialization = 2,
            SubWeapon = 46,
        },
        {
            Function = 4,
            HomePlace = 1427,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_ALC.UI_Icon_Career_Second_ALC\'',
            MainWeapon = 29,
            Prof = 34,
            ProfAbbr = 'alc',
            ProfAssetAbbr = 'ALC',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_ALC.UI_Icon_Class_ALC\'',
            ProfRename = 'Alchemist',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_LJSS.UI_Icon_Job_Second_LJSS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_ALC.UI_Icon_Job_ALC\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_ALC.UI_Icon_Job_ALC\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_ALC.UI_InfoTips_Icon_JobUnlock_ALC\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID34.MI_DX_UI_Prof_ProfID34\'',
            _SkillGroup = '[24,24]',
            SortOrder = 25,
            Specialization = 2,
            SubWeapon = 40,
        },
        {
            Function = 4,
            HomePlace = 1428,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_CUL.UI_Icon_Career_Second_CUL\'',
            MainWeapon = 30,
            Prof = 35,
            ProfAbbr = 'cok',
            ProfAssetAbbr = 'CUL',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_CUL.UI_Icon_Class_CUL\'',
            ProfRename = 'Culinarian',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_PTS.UI_Icon_Job_Second_PTS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_CUL.UI_Icon_Job_CUL\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_CUL.UI_Icon_Job_CUL\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_CUL.UI_InfoTips_Icon_JobUnlock_CUL\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID35.MI_DX_UI_Prof_ProfID35\'',
            _SkillGroup = '[35,35]',
            SortOrder = 26,
            Specialization = 2,
            SubWeapon = 41,
        },
        {
            Class = 7,
            Function = 5,
            HomePlace = 1429,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_MIN.UI_Icon_Career_Second_MIN\'',
            MainWeapon = 37,
            Prof = 36,
            ProfAbbr = 'min',
            ProfAssetAbbr = 'MIN',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_MIN.UI_Icon_Class_MIN\'',
            ProfRename = 'Miner',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_CKG.UI_Icon_Job_Second_CKG\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_MIN.UI_Icon_Job_MIN\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_MIN.UI_Icon_Job_MIN\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_MIN.UI_InfoTips_Icon_JobUnlock_MIN\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID36.MI_DX_UI_Prof_ProfID36\'',
            _SkillGroup = '[8,16]',
            SortOrder = 27,
            Specialization = 2,
            SubWeapon = 48,
        },
        {
            Class = 7,
            Function = 5,
            HomePlace = 1430,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/AdventureUI_Icon_Career_Second_BTN.UI_Icon_Career_Second_BTN\'',
            MainWeapon = 38,
            Prof = 37,
            ProfAbbr = 'fel',
            ProfAssetAbbr = 'BTN',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_BTN.UI_Icon_Class_BTN\'',
            ProfRename = 'Botanist',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_YYS.UI_Icon_Job_Second_YYS\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_BTN.UI_Icon_Job_BTN\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_BTN.UI_Icon_Job_BTN\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_BTN.UI_InfoTips_Icon_JobUnlock_BTN\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID37.MI_DX_UI_Prof_ProfID37\'',
            _SkillGroup = '[9,36]',
            SortOrder = 28,
            Specialization = 2,
            SubWeapon = 49,
        },
        {
            Class = 7,
            Function = 5,
            HomePlace = 1431,
            LoginCreateProfIcon = 'Texture2D\'/Game/UI/Texture/Adventure/UI_Icon_Career_Second_FSH.UI_Icon_Career_Second_FSH\'',
            MainWeapon = 39,
            Prof = 38,
            ProfAbbr = 'fsh',
            ProfAssetAbbr = 'FSH',
            ProfIcon = 'Texture2D\'/Game/Assets/Icon/Class/UI_Icon_Class_FSH.UI_Icon_Class_FSH\'',
            ProfRename = 'Fisher',
            SimpleIcon = 'Texture2D\'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Second_BYR.UI_Icon_Job_Second_BYR\'',
            SimpleIcon2 = 'Texture2D\'/Game/Assets/Icon/Job/UI_Icon_Job_FSH.UI_Icon_Job_FSH\'',
            SimpleIcon3 = 'Texture2D\'/Game/UI/Texture/Icon/Job/UI_Icon_Job_FSH.UI_Icon_Job_FSH\'',
            SimpleIcon5 = 'Texture2D\'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_FSH.UI_InfoTips_Icon_JobUnlock_FSH\'',
            SimpleIcon6 = 'MaterialInstanceConstant\'/Game/UMG/UI_Effect/Material/MI_DX_UI/MI_DX_UI_Prof/MI_DX_UI_Prof_ProfID38.MI_DX_UI_Prof_ProfID38\'',
            _SkillGroup = '[10,15]',
            SortOrder = 29,
            Specialization = 2,
        },
	},
}

setmetatable(RoleInitCfg, { __index = CfgBase })

RoleInitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local ProtoCommon = require("Protocol/ProtoCommon")
local ProfClassType = ProtoCommon.class_type
local FunctionType = ProtoCommon.function_type

function RoleInitCfg:FindRoleInitSkill(Prof, Index)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	local Skill = Cfg.SkillList
	if nil == Skill then return end

	return Skill[Index + 1]
end

function RoleInitCfg:FindRoleInitProfIcon(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.ProfIcon
end

function RoleInitCfg:FindRoleInitProfIconSimple(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.SimpleIcon
end

function RoleInitCfg:FindRoleInitProfIconSimple2nd(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.SimpleIcon2
end

function RoleInitCfg:FindRoleInitProfIconSimple5nd(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.SimpleIcon5
end


function RoleInitCfg:FindRoleInitProfIconSimple6nd(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return nil end

	return Cfg.SimpleIcon6
end

--技能未学习时显示的职业图标
function RoleInitCfg:FindRoleInitProfIconSimple4(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.SimpleIcon4
end

function RoleInitCfg:FindRoleInitProfName(Prof)
	if Prof == nil then return end
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end
	if Cfg.IsVersionOpen == 0 then return end

	return Cfg.ProfName
end

function RoleInitCfg:IsProfOpen(Prof)
	if Prof == nil then return false end
    	
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return false end
	if Cfg.IsVersionOpen == nil or Cfg.IsVersionOpen == 0 then return false end

	return true
end

---GetMainAttrByProf 获取职业主属性
---@param Prof number
---@return attr_type
function RoleInitCfg:GetMainAttrByProf(Prof)	
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.MainAttr
end

---FindFunction 职能
---@param Prof number
function RoleInitCfg:FindFunction(Prof)	
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.Function
end

---FindSortOrder 排序顺序
---@param Prof number
function RoleInitCfg:FindSortOrder(Prof)	
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return 0 end

	return Cfg.SortOrder
end

---FindMainWeaponItemType 查找职业主武器的物品类型
---@param Prof number
---@return ProtoCommon.ITEM_TYPE_DETAIL
function RoleInitCfg:FindMainWeaponItemType(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.MainWeapon
end

---FindSubWeaponItemType 查找职业副武器的物品类型
---@param Prof number
---@return ProtoCommon.ITEM_TYPE_DETAIL
function RoleInitCfg:FindSubWeaponItemType(Prof)
	if nil == Prof then
		return nil
	end

	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.SubWeapon
end

---FindProfClass 查找职业类
---@param Prof number
---@return ProtoCommon.ITEM_TYPE_DETAIL
function RoleInitCfg:FindProfClass(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end	
	return Cfg.Class
end

---FindProfSpecialization 查找职业性质
---@param Prof number
---@return ProtoCommon.specialization_type
function RoleInitCfg:FindProfSpecialization(Prof)
	if nil == Prof then
		return
	end

	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.Specialization
end

---获取已开放所有职业配置数据列表
---@return table
function RoleInitCfg:GetAllOpenProfCfgList()
	local SearchConditions = string.format("IsVersionOpen=1")
	local Cfg = self:FindAllCfg(SearchConditions)
	return Cfg
end

---获取指定职业类已开放的职业配置数据列表
---@param Class ProtoCommon.class_type @职业类
---@return table
function RoleInitCfg:GetOpenProfCfgListByClass( Class )
	local SearchConditions = string.format("IsVersionOpen=1 AND Class=%d", Class)
	local Cfg = self:FindAllCfg(SearchConditions)
	return Cfg
end

---获取指定职能类已开放的职业配置数据列表
---@param FunctionType ProtoCommon.function_type @职能类型
---@return table
function RoleInitCfg:GetOpenProfCfgListByFunction( FunctionType )
	local SearchConditions = string.format("IsVersionOpen=1 AND Function=%d", FunctionType)
	local Cfg = self:FindAllCfg(SearchConditions)
	return Cfg
end

---获取进攻职业已开放的职业配置数据列表
---@return table
function RoleInitCfg:GetAttackProfCfgList()
    local SearchConditions = string.format("IsVersionOpen=1 AND Function=%d", FunctionType.FUNCTION_TYPE_ATTACK)
	local Cfg = self:FindAllCfg(SearchConditions)
	return Cfg
end

---获取指定职业性质已开放的职业配置数据列表
---@param Class ProtoCommon.specialization_type @职业性质
---@return table
function RoleInitCfg:GetOpenProfCfgListBySpecialization( Specialization )
	local SearchConditions = string.format("IsVersionOpen=1 AND Specialization=%d", Specialization)
	local Cfg = self:FindAllCfg(SearchConditions)
	return Cfg
end

---获取指定职业级别
---@param Prof number
function RoleInitCfg:FindProfLevel(Prof)
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.ProfLevel
end

function RoleInitCfg:FindProfAdvanceProf(Prof)    
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.AdvancedProf
end

--查找对应特职是否有基职
--TODO：缓存
function RoleInitCfg:FindProfForPAdvance(AdvancedProf)    
	local SearchConditions = string.format("AdvancedProf=%d", AdvancedProf)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end

	return Cfg
end

--查找对应高阶NpcID
function RoleInitCfg:FindProfForNpcID(Prof)	
	local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end

	return Cfg.NpcID
end

function RoleInitCfg:FindSoulDesc(Prof)
    local Cfg = self:FindCfgByKey(Prof)
	if nil == Cfg then return end
    
    return Cfg.SoulcrystalDesc
end
return RoleInitCfg
