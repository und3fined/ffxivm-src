--
-- Author: jianweili
-- Date:
-- Description: 一些无规则的、特殊的预加载资源，写在此处
--

local ObjectGCType = require("Define/ObjectGCType")

--@class PreLoadConfig
local PreLoadConfig =
{
    --************************************************************************************
    --***注意：填写完整路径，是蓝图类的应加_C后缀，非蓝图类不加后缀，如：
    --***蓝图类："WidgetBlueprint'/Game/UI/BP/Common/Btn/Comm1BtnL_UIBP.Comm1BtnL_UIBP_C'"
    --***非蓝图类："Texture2D'/Game/UI/Atlas/HUD/Textures/HUD_Atlas.HUD_Atlas'"
    --************************************************************************************
    [ObjectGCType.Map] =
    {
        --[[
        --预警所用贴图，临时预加载，后续逻辑改为异步
        "Texture2D'/Game/Assets/Effect/Textures/Water/T_Water_12.T_Water_12'",
        "Texture2D'/Game/Assets/Effect/Textures/Fire/T_Fire_15.T_Fire_15'",
        --]]
    },

    [ObjectGCType.Hold] =
    {
        --预加载Buff图标
        --已根据Buff表加载

        --预加载HUD
	    --已根据HUDConfig加载

        --预加载通用Texture
        --"Texture2D'/Game/UI/Texture/CommonBkg/UI_Config_Img_Bkg.UI_Config_Img_Bkg'",

        --预加载公共图集
        "Texture2D'/Game/UI/Atlas/HUD/Textures/HUD_Atlas_0.HUD_Atlas_0'",
        "Texture2D'/Game/UI/Atlas/HUD/Textures/HUD_Atlas_1.HUD_Atlas_1'",
        "Texture2D'/Game/UI/Atlas/HUDQuest/Textures/HUDQuest_Atlas_0.HUDQuest_Atlas_0'",
        "Texture2D'/Game/UI/Atlas/HUDQuest/Textures/HUDQuest_Atlas_1.HUDQuest_Atlas_1'",
        "Texture2D'/Game/UI/Atlas/HUDSigns/Textures/HUDSigns_Atlas_0.HUDSigns_Atlas_0'",
        "Texture2D'/Game/UI/Atlas/HUDSigns/Textures/HUDSigns_Atlas_1.HUDSigns_Atlas_1'",
        "Texture2D'/Game/UI/Atlas/HUDSigns/Textures/HUDSigns_Atlas_2.HUDSigns_Atlas_2'",

        --预加载公共字体
        "Font'/Game/UI/Fonts/HingashiExtended_Font.HingashiExtended_Font'",
        "Font'/Game/UI/Fonts/Main_Font.Main_Font'",
        "Font'/Game/UI/Fonts/MiedingerMediumW00-Regular_Font.MiedingerMediumW00-Regular_Font'",
        "Font'/Game/UI/Fonts/Title_Font.Title_Font'",
        "Font'/Game/UI/Fonts/TrumpGothicPro-Medium_Font.TrumpGothicPro-Medium_Font'",
        "Font'/Game/UI/Fonts/XIVJupiterCondensedSCOsF-Re_Font.XIVJupiterCondensedSCOsF-Re_Font'",

        --预加载公共、常驻UI蓝图
        "WidgetBlueprint'/Game/UI/BP/Common/Menu/CommMenu_UIBP.CommMenu_UIBP_C'",
        "WidgetBlueprint'/Game/UI/BP/Common/DropDownList/CommDropDownListNew_UIBP.CommDropDownListNew_UIBP_C'",
        "WidgetBlueprint'/Game/UI/BP/Common/Tips/CommMsgBoxNew_UIBP.CommMsgBoxNew_UIBP'",
        "WidgetBlueprint'/Game/UI/BP/Common/Tips/CommDropTips_UIBP.CommDropTips_UIBP_C'",
        "WidgetBlueprint'/Game/UI/BP/InfoTips/AreaTips_UIBP.AreaTips_UIBP_C'",
        "WidgetBlueprint'/Game/UI/BP/InfoTips/CommonTips_UIBP.CommonTips_UIBP_C'",
        "WidgetBlueprint'/Game/UI/BP/InfoTips/ErrorTips_UIBP.ErrorTips_UIBP_C'",
        "WidgetBlueprint'/Game/UI/BP/InfoTips/MissionTips_UIBP.MissionTips_UIBP_C'",
        "WidgetBlueprint'/Game/UI/BP/Chat/ChatMainPanel_UIBP.ChatMainPanel_UIBP_C'",

        --[[

        --预加载动画、模型、武器等蓝图
        "AnimBlueprint'/Game/BluePrint/Animation/AnimBP_Human_IK.AnimBP_Human_IK_C'",
        "AnimBlueprint'/Game/BluePrint/Animation/FaceAnimBlueprint.FaceAnimBlueprint_C'",
        "AnimBlueprint'/Game/BluePrint/Animation/MajorAnimBlueprint.MajorAnimBlueprint_C'",
        "AnimBlueprint'/Game/BluePrint/Animation/MajorAnimDynamics.MajorAnimDynamics_C'",
        "AnimBlueprint'/Game/BluePrint/Animation/MajorPreviewAnimBlueprint.MajorPreviewAnimBlueprint_C'",
        "AnimBlueprint'/Game/BluePrint/Animation/FacePreviewAnimBlueprint.FacePreviewAnimBlueprint_C'",
        "AnimBlueprint'/Game/BluePrint/Animation/MonsterAnimBlueprint.MonsterAnimBlueprint_C'",
        "AnimBlueprint'/Game/BluePrint/Animation/NpcAnimBlueprint.NpcAnimBlueprint_C'",
        "AnimBlueprint'/Game/BluePrint/Animation/SlotLinkedAnimBlueprint.SlotLinkedAnimBlueprint_C'",
        "Blueprint'/Game/BluePrint/Character/GatherBlueprint.GatherBlueprint_C'",
        "Blueprint'/Game/BluePrint/Character/MajorBluePrint.MajorBlueprint_C'",
        "Blueprint'/Game/BluePrint/Character/MonsterBlueprint.MonsterBlueprint_C'",
        "Blueprint'/Game/BluePrint/Character/NPCBlueprint.NPCBlueprint_C'",
        "Blueprint'/Game/BluePrint/Character/PlayerBlueprint.PlayerBlueprint_C'",
        "AnimBlueprint'/Game/BluePrint/Weapon/WeaponAnimBlueprint.WeaponAnimBlueprint_C'",
        "AnimBlueprint'/Game/BluePrint/Weapon/AnimLayer/w622AnimBP.w622AnimBP_C'",
        "AnimBlueprint'/Game/BluePrint/Weapon/AnimLayer/w7201AnimBP.w7201AnimBP_C'",

        --预加载怪物淡入淡出所需的材质
        "Material'/Game/MaterialLibrary/MasterMaterial/Character/M_Character_DitherFade.M_Character_DitherFade'",


        --其它模块

        --技能相关的曲线：临时把所有的都预加载上
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1010101.1010101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1010201.1010201'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1010301.1010301'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1010501.1010501'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1010701.1010701'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1011001.1011001'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1011301.1011301'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1011601.1011601'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1011801.1011801'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1012101.1012101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1012201.1012201'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1012301.1012301'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1012401.1012401'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1012501.1012501'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1012601.1012601'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/PLD/1012801.1012801'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/WHM/1020401.1020401'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/WHM/1020701.1020701'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/WHM/1020801.1020801'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1030001.1030001'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1030001_2.1030001_2'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/BRD/1031001.1031001'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1031001_1.1031001_1'",
        "CurveLinearColor'/Game/BluePrint/Skill/MoveCurve/BRD/1031001_2.1031001_2'",
        "CurveLinearColor'/Game/BluePrint/Skill/MoveCurve/BRD/1031001_3.1031001_3'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1031301_1.1031301_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1031301_2.1031301_2'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1031301_3.1031301_3'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1031301_4.1031301_4'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1031301_5.1031301_5'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1031301_6.1031301_6'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BRD/1031301_7.1031301_7'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BLM/1050901_1.1050901_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/BLM/1051401_1.1051401_1'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/BLM/1052001.1052001'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106010101.106010101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106020101.106020101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106030101.106030101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106040101.106040101'",
        "CurveLinearColor'/Game/BluePrint/Skill/MoveCurve/DRG/1060901.1060901'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/DRG/1060901_1.1060901_1'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106090101.106090101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106150101.106150101'",
        "CurveLinearColor'/Game/BluePrint/Skill/MoveCurve/DRG/1061701_1.1061701_1'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106170101.106170101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106180101.106180101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/106190101.106190101'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/SCH/1070301_1.1070301_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/SCH/1070301_2.1070301_2'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/SCH/1070301_3.1070301_3'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/111010401.111010401'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/111010402.111010402'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/111010403.111010403'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/111010404.111010404'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/111010501.111010501'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/111030601.111030601'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/111061501.111061501'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/117021601.117021601'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/123456789.123456789'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/70000.70000'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/XZZN/7013501.7013501'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/XZZN/7013601.7013601'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/XZZN/7013701.7013701'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7020101_1.7020101_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7020101_2.7020101_2'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7020101_3.7020101_3'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7020401_4.7020401_4'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7020401_5.7020401_5'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7013501.7020401_5'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7020401_6.7020401_6'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7030501_3.7030501_3'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7030901_4.7030901_4'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZCQYJS/7031001_1.7031001_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7035301_3.7035301_3'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/7035401_3.7035401_3'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/704000101.704000101'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZCQYJS/7041401_1.7041401_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZCQYJS/7041601_1.7041601_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZCQYJS/7041601_2.7041601_2'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZCQYJS/7041701_1.7041701_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/XZZN/9304401_3.9304401_3'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/930560101.930560101'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/ServerDirven/987654321.987654321'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/AddSpeed_1.AddSpeed_1'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/Climb/Climb.Climb'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/DRG/drg1.drg1'",
        "CurveLinearColor'/Game/BluePrint/Skill/MoveCurve/WHM/GhostTailer_Color.GhostTailer_Color'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/WHM/GhostTailer_Fade.GhostTailer_Fade'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/MoveToCommon.MoveToCommon'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/NewCurveBase.NewCurveBase'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/NormalSpeed.NormalSpeed'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/NormalSpeed_2.NormalSpeed_2'",
        "CurveVector'/Game/BluePrint/Skill/MoveCurve/SpecMoveTo.SpecMoveTo'",
        "CurveFloat'/Game/BluePrint/Skill/MoveCurve/Climb/ThrowOver.ThrowOver'",
        --]]
    },
}

return PreLoadConfig