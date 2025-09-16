local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")

local CS_CMD = ProtoCS.CS_CMD
local LSTR = _G.LSTR

local EventType = ProtoRes.EVENT_TYPE

-- --按随机事件EVENT_TYPE协议定义的枚举来配置	EVENT_TYPE_BOOM不用定义
-- local StateConfig = {
-- 	[EventType.EVENT_TYPE_CHAOS] = {	--混乱
-- 			ImagePath = "Texture2D'/Game/UI/Texture/Crafter/UI_Alchemist_Img_TextPurple.UI_Alchemist_Img_TextPurple'",
-- 			Text = LSTR("反应强度会发生随机变化")},
-- 	[EventType.EVENT_TYPE_INACTIVE] = {	--失活
-- 			ImagePath = "Texture2D'/Game/UI/Texture/Crafter/UI_Alchemist_Img_TextYellow.UI_Alchemist_Img_TextYellow'",
-- 			Text = LSTR("下3个工次反应强度不会改变")},
-- 	[EventType.EVENT_TYPE_OVERHEAT] = {	--过热
-- 			ImagePath = "Texture2D'/Game/UI/Texture/Crafter/UI_Alchemist_Img_TextRed.UI_Alchemist_Img_TextRed'",
-- 			Text = LSTR("反应强度会变得非常剧烈，很可能引发爆炸事故")},
-- 	[EventType.EVENT_TYPE_QUIET] = {	--内静
-- 			ImagePath = "Texture2D'/Game/UI/Texture/Crafter/UI_Carpenter_Img_InnerQuietBlue.UI_Carpenter_Img_InnerQuietBlue'",
-- 			Text = LSTR("內静")},
-- 	[EventType.EVENT_TYPE_SLACK] = {	--懈怠
-- 			ImagePath = "Texture2D'/Game/UI/Texture/Crafter/UI_Carpenter_Img_SlackRed.UI_Carpenter_Img_SlackRed'",
-- 			Text = LSTR("懈怠")},
-- }

local ArmorerBlacksmithConfig = {
    MaxTapNum = 6,  -- Tap按钮的数量

    -- 锻铁面板有4个还是6个按钮
    EPanelType = {
        Panel4 = 1,
        Panel6 = 2
    },

    -- 温度状态, 对应无热量, 低热量, 中热量, 高热量和热锻状态
    EHeatType = {
        Zero   = 0,
        Low    = 1,
        Medium = 2,
        High   = 3,
        Forge  = 4,
    },

    -- 显示的Item类型
    EItemType = {
        Weapon   = 1,
        Material = 2,
        Prop     = 3,
    },

    ConditionMaskIndexList = {
        1, 2, 5, 8,  -- 升温, 旋转, 冷却和力量控制
    }
}

--每个职业的配置，可以功能通用，比如从制作手册打开制作界面
local ProfConfig = 
{
    --炼金
    [ProtoCommon.prof_type.PROF_TYPE_ALCHEMIST] = {
        MainPanelID = _G.UIViewID.CrafterAlchemistMainPanel,
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_ALCHEMY,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_ALCHEMY,
        TestRecipeID = 72340000,   --按普工的时候，不同职业打开不同的制作界面   --1级恢复药
        FastMakeSkillID = 30499,
        EntranceIconID = 900177,
    },
    --烹调师
    [ProtoCommon.prof_type.PROF_TYPE_CULINARIAN] = {
        MainPanelID = _G.UIViewID.CrafterCulinarianMainPanel,
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_COOK,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_COOK,
        TestRecipeID = 2,   --按普工的时候，不同职业打开不同的制作界面
        FastMakeSkillID = 31199,
        EntranceIconID = 900179,
        -- ElementItemView的类型
        EElementItemViewType = {
            None = 0,
            TableItem = 1,     -- MainPanel下方TableView中的元素
            AfflatusItem = 2,  -- MainPanel顶部拉杆区的元素
            SourceItem = 3,    -- 味之本源的元素
            StormItem = 4,     -- 灵感风暴的元素
            DropItem = 5,      -- 拉杆区播放Drop动画的元素
        },
        MenphinaBuffID = 5005,
        InspireStormBuffID = 5006,
        TripleSkillID = 31112,    -- 没学这个技能不能触发三连特效
        ShineSkillID = 31107,     -- 厚积薄发
        PracticeSkillID = 31103,  -- 实践
    },
    --锻铁匠
    [ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH] = setmetatable({
        MainPanelID = _G.UIViewID.CrafterBlacksmithMainPanel,
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_FORGE,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_FORGE,
        TestRecipeID = 2,   --按普工的时候，不同职业打开不同的制作界面
        FastMakeSkillID = 30699,
        EntranceIconID = 900173,
    }, { __index = ArmorerBlacksmithConfig }),
    --铸甲匠
    [ProtoCommon.prof_type.PROF_TYPE_ARMOR] = setmetatable({
        MainPanelID = _G.UIViewID.CrafterArmorerMainPanel,
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_AMOR,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_AMOR,
        TestRecipeID = 2,   --按普工的时候，不同职业打开不同的制作界面
        FastMakeSkillID = 30799,
        EntranceIconID = 900176,
    }, { __index = ArmorerBlacksmithConfig }),
    --雕金匠
    [ProtoCommon.prof_type.PROF_TYPE_GOLDSMITH] = {
        MainPanelID = _G.UIViewID.CrafterGoldsmithMainPanel,
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_GOLDSMITH,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_GOLDSMITH,
        TestRecipeID = 2,   --按普工的时候，不同职业打开不同的制作界面
        FastMakeSkillID = 30899,
        EntranceIconID = 900174,
        TensionValueDefault = 50,  -- 初始的紧张值
        TensionValueMax = 100,     -- 紧张值的最大值, 用于计算Slider的Percent
        BuffID_TensionTypeMap = {
            [2551] = "bHasBuffRed",  -- 专注
            [2552] = "bHasBuffBlue"  -- 松弛
        },
        PurpleZoneBuffID = 2051      -- 眼力的BuffID
    },
    --制革匠
    [ProtoCommon.prof_type.PROF_TYPE_LEATHER_WORK] = {
        MainPanelID = _G.UIViewID.CrafterLeatherworkerMainPanel,
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_LEATHER,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_LEATHER,
        TestRecipeID = 2,   --按普工的时候，不同职业打开不同的制作界面
        FastMakeSkillID = 31099,
        EntranceIconID = 900172,
    },
    --裁衣匠
    [ProtoCommon.prof_type.PROF_TYPE_WEAVER] = {
        MainPanelID = _G.UIViewID.CrafterWeaverMainPanel,
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_CLOTH,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_CLOTH,
        TestRecipeID = 2,   --按普工的时候，不同职业打开不同的制作界面
        FastMakeSkillID = 30999,
        EntranceIconID = 900178,
    },
    --刻木匠
    [ProtoCommon.prof_type.PROF_TYPE_CARPENTER] = {
        MainPanelID = _G.UIViewID.CrafterCarpenterMainPanel,
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_CARVE,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_CARVE,
        TestRecipeID = 2,   --按普工的时候，不同职业打开不同的制作界面
        FastMakeSkillID = 30599,
        EntranceIconID = 900175,
        TensionValueDefault = 50,  -- 初始的紧张值
        TensionValueMax = 100,     -- 紧张值的最大值, 用于计算Slider的Percent
        BuffID_TensionTypeMap = {
            [2501] = "bHasBuffRed",  -- 专注
            [2502] = "bHasBuffBlue"  -- 松弛
        },
        PurpleZoneBuffID = 2001      -- 眼力的BuffID
    },
}

-- enum LIFESKILL_ACTION_TYPE {
--   LIFESKILL_ACTION_TYPE_NONE = 0 [(org.xresloader.enum_alias) = ""];
--   LIFESKILL_ACTION_TYPE_FUNCTIONAL = 1 [(org.xresloader.enum_alias) = "功能类"];
--   LIFESKILL_ACTION_TYPE_FISH_DROP = 2 [(org.xresloader.enum_alias) = "抛竿"];
--   LIFESKILL_ACTION_TYPE_FISH_LIFT = 3 [(org.xresloader.enum_alias) = "提竿"];
--   LIFESKILL_ACTION_TYPE_MINE = 4 [(org.xresloader.enum_alias) = "挖掘"];
--   LIFESKILL_ACTION_TYPE_GATHER = 5 [(org.xresloader.enum_alias) = "采集"];
--   LIFESKILL_ACTION_TYPE_CHOOSE_BAIT = 6 [(org.xresloader.enum_alias) = "选饵"];
--   LIFESKILL_ACTION_TYPE_PASSIVE = 7 [(org.xresloader.enum_alias) = "被动"];
--   LIFESKILL_ACTION_TYPE_FISHEYE = 8 [(org.xresloader.enum_alias) = "鱼眼"];
--   LIFESKILL_ACTION_TYPE_COLLECTION = 9 [(org.xresloader.enum_alias) = "收藏"];
--   LIFESKILL_ACTION_TYPE_CRAFT = 10 [(org.xresloader.enum_alias) = "制作"];
--   LIFESKILL_ACTION_TYPE_CONTROL = 11 [(org.xresloader.enum_alias) = "加工"];
--   LIFESKILL_ACTION_TYPE_SPECIAL = 12 [(org.xresloader.enum_alias) = "特殊"];
--   LIFESKILL_ACTION_TYPE_CATALYST = 13 [(org.xresloader.enum_alias) = "炼金-催化剂"];
--   LIFESKILL_ACTION_TYPE_EVENT_REPLY = 14 [(org.xresloader.enum_alias) = "炼金-事件应对"];
-- }

local EffectPaths = {
	TargetEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_MAK_C_1.BP_MAK_C_1'",
	SkillSuccessEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_mak_ok.BP_mak_ok'",
    SkillHotForgeEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/BLK/VBP/BP_BLK_S_1.BP_BLK_S_1'",
	SkillFailedEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_mak_ng2.BP_mak_ng2'",
	ResultSuccessEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_mak_ok2.BP_mak_ok2'",
	ResultFailedEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_mak_ng.BP_mak_ng'",
	HQResultSuccessEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_mak_rg.BP_mak_rg'",
}

local SoundPaths = {
	SkillSuccessSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Tank_Jobs_Skill/Play_se_vfx_live_action_success_P.Play_se_vfx_live_action_success_P'",
	SkillFailedSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Tank_Jobs_Skill/Play_se_vfx_live_action_fail_P.Play_se_vfx_live_action_fail_P'",
	ResultSuccessSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Tank_Jobs_Skill/Play_se_vfx_live_make_finish_nq_P.Play_se_vfx_live_make_finish_nq_P'",
	ResultFailedSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Tank_Jobs_Skill/Play_se_vfx_live_make_fail_P.Play_se_vfx_live_make_fail_P'",
	HQResultSuccessSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Tank_Jobs_Skill/Play_se_vfx_live_make_finish_hq_P.Play_se_vfx_live_make_finish_hq_P'",

    --拿起催化剂瓶子
    PickUpBottleSountPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Tank_Jobs_Skill/Play_se_craft_alchemist_pickup_catalyst_bottle.Play_se_craft_alchemist_pickup_catalyst_bottle'",
    ReturnBottleSountPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Tank_Jobs_Skill/Play_se_craft_alchemist_return_catalyst_bottle.Play_se_craft_alchemist_return_catalyst_bottle'",
}

local WeaverCircleEffectPath = {
    NormalEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_MAK_C_1.BP_MAK_C_1'",
    RedEffecttPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_MAK_C_4.BP_MAK_C_4'",
    YellowEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_MAK_C_5.BP_MAK_C_5'",
    GreenEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_MAK_C_6.BP_MAK_C_6'",
    DoubleEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MAK/VBP/BP_MAK_C_8.BP_MAK_C_8'"
}

local WeaverCircleItemIconPath = {
    NormalItem = "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Leatherworker_Img_Grey_png.UI_Leatherworker_Img_Grey_png'",
    GreenItem = "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Leatherworker_Img_Green_png.UI_Leatherworker_Img_Green_png'",
    YellowItem = "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Leatherworker_Img_Yellow_png.UI_Leatherworker_Img_Yellow_png'",
    RedItem = "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Leatherworker_Img_Orange_png.UI_Leatherworker_Img_Orange_png'",
    GreenRedItem = "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Weaver_Img_StateGreenRed_png.UI_Weaver_Img_StateGreenRed_png'",
    GreenYellowItem = "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Weaver_Img_StateGreenYellow_png.UI_Weaver_Img_StateGreenYellow_png'",
    YellowRedItem = "PaperSprite'/Game/UI/Atlas/Crafter/Frames/UI_Weaver_Img_StateYellowRed_png.UI_Weaver_Img_StateYellowRed_png'"
}

local SwitchSkillMap = {
    [30615] = true,
    [30715] = true,
}

local HotForgeSkillMap = {
    [30607] = true,
    [30707] = true,
}

local IgnoreCDSkillMap = {
    [30615] = true,
    [30715] = true,
}

local SkillCheckErrorCode = {
    WaitingSkillRsp = -1,
    CD = -2,
    Cost = -3,
    SkillCondition = -4,
    SkillFirstClass = -5,
    NotCrafterProf = -6,
    SkillWeight = -7,
    CulinarianPushNotValid = -9,
    CulinarianAfflatusIndexLock = -10,
    CulinarianPracticeNotValid = -11,
    NotLeaned = -12,
    RandomEvent = -13,
    BlacksmithHotForgePhase = -20,
    BlacksmithHotForgeEnd = -21,
    UnKnown = -99
}

---@class CrafterConfig
local CrafterConfig = {
	-- StateConfig = StateConfig,
	ProfConfig = ProfConfig,
	EffectPaths = EffectPaths,
	SoundPaths = SoundPaths,
    GatheringCollectionPassiveSkillTip = GatheringCollectionPassiveSkillTip,
    WeaverCircleEffectPath = WeaverCircleEffectPath,
    WeaverCircleItemIconPath = WeaverCircleItemIconPath,
    SwitchSkillMap = SwitchSkillMap,
    HotForgeSkillMap = HotForgeSkillMap,
    IgnoreCDSkillMap = IgnoreCDSkillMap,
    SkillCheckErrorCode = SkillCheckErrorCode,
}

return CrafterConfig