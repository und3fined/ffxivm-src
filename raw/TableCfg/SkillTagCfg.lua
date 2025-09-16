-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_12.UI_Skill_Tag_Img_12\'',
}

---@class SkillTagCfg : CfgBase
local SkillTagCfg = {
	TableName = "c_skill_tag_cfg",
    LruKeyType = nil,
	KeyName = "TagType",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_01.UI_Skill_Tag_Img_01\'',
        TagType = 1,
    },
	LuaData = {
        {
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_02.UI_Skill_Tag_Img_02\'',
            TagType = 2,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_09.UI_Skill_Tag_Img_09\'',
            TagType = 3,
        },
        {
            TagType = 4,
        },
        {
            TagType = 5,
        },
        {
            TagType = 6,
        },
        {
            TagType = 7,
        },
        {
            TagType = 8,
        },
        {
            TagType = 9,
        },
        {
            TagType = 10,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_10.UI_Skill_Tag_Img_10\'',
            TagType = 11,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_11.UI_Skill_Tag_Img_11\'',
            TagType = 12,
        },
        {
            TagType = 13,
        },
        {
            TagType = 14,
        },
        {
            TagType = 15,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_03.UI_Skill_Tag_Img_03\'',
            TagType = 16,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_04.UI_Skill_Tag_Img_04\'',
            TagType = 17,
        },
        {
            TagType = 18,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_06.UI_Skill_Tag_Img_06\'',
            TagType = 19,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_05.UI_Skill_Tag_Img_05\'',
            TagType = 20,
        },
        {
            TagType = 21,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_07.UI_Skill_Tag_Img_07\'',
            TagType = 22,
        },
        {
            TagType = 23,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_08.UI_Skill_Tag_Img_08\'',
            TagType = 24,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_15.UI_Skill_Tag_Img_15\'',
            TagType = 25,
        },
        {
            BgImgPath = CS._1_1,
            TagType = 26,
        },
        {
            BgImgPath = CS._1_1,
            TagType = 27,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_14.UI_Skill_Tag_Img_14\'',
            TagType = 28,
        },
        {
            BgImgPath = 'Texture2D\'/Game/UI/Texture/Skill/UI_Skill_Tag_Img_13.UI_Skill_Tag_Img_13\'',
            TagType = 29,
        },
	},
}

setmetatable(SkillTagCfg, { __index = CfgBase })

SkillTagCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local ProtoRes = require("Protocol/ProtoRes")
local ESkillTagType = ProtoRes.ESkillTagType
local LIFESKILL_ACTION_TYPE = ProtoRes.LIFESKILL_ACTION_TYPE
local skill_class = ProtoRes.skill_class
local skill_tag = ProtoRes.skill_tag

local LifeskillActionTypeMap = {
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_GATHER] = ESkillTagType.SKILL_TAG_LIFESKILL_GATHER,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_FUNCTIONAL] = ESkillTagType.SKILL_TAG_LIFESKILL_FUNCTIONAL,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_FISH_DROP] = ESkillTagType.SKILL_TAG_LIFESKILL_FISH_DROP,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_FISH_LIFT] = ESkillTagType.SKILL_TAG_LIFESKILL_FISH_LIFT,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_MINE] = ESkillTagType.SKILL_TAG_LIFESKILL_MINE,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_CHOOSE_BAIT] = ESkillTagType.SKILL_TAG_LIFESKILL_CHOOSE_BAIT,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_FISHEYE] = ESkillTagType.SKILL_TAG_LIFESKILL_FISHEYE,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_COLLECTION] = ESkillTagType.SKILL_TAG_LIFESKILL_COLLECTION,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_CRAFT] = ESkillTagType.SKILL_TAG_LIFESKILL_CRAFT,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_CONTROL] = ESkillTagType.SKILL_TAG_LIFESKILL_CONTROL,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_SPECIAL] = ESkillTagType.SKILL_TAG_LIFESKILL_SPECIAL,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_CATALYST] = ESkillTagType.SKILL_TAG_LIFESKILL_CATALYST,
    [LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_EVENT_REPLY] = ESkillTagType.SKILL_TAG_LIFESKILL_EVENT_REPLY,
}

local SkillClassMap = {
    [skill_class.SKILL_CLASS_ASSIST] = ESkillTagType.SKILL_TAG_ASSIST,
    [skill_class.SKILL_CLASS_HEAL] = ESkillTagType.SKILL_TAG_HEAL,
    [skill_class.SKILL_CLASS_ATK] = ESkillTagType.SKILL_TAG_ATK,
    [skill_class.SKILL_CLASS_QUICK_STAND] = ESkillTagType.SKILL_TAG_QUICK_STAND,
    [skill_class.SKILL_CLASS_MOVE] = ESkillTagType.SKILL_TAG_MOVE,
}

local SkillTagMap = {
    [skill_tag.TAG_DAMAGE] = ESkillTagType.SKILL_TAG_DAMAGE,
    [skill_tag.TAG_CONTROL] = ESkillTagType.SKILL_TAG_CONTROL,
    [skill_tag.TAG_AOE] = ESkillTagType.SKILL_TAG_AOE,
    [skill_tag.TAG_PHYSICAL] = ESkillTagType.SKILL_TAG_PHYSICAL,
    [skill_tag.TAG_MAGIC] = ESkillTagType.SKILL_TAG_MAGIC,
    [skill_tag.TAG_DEBUFF] = ESkillTagType.SKILL_TAG_DEBUFF,
    [skill_tag.TAG_SURVIVAL] = ESkillTagType.SKILL_TAG_SURVIVAL,
    [skill_tag.TAG_REINFORCE] = ESkillTagType.SKILL_TAG_REINFORCE,
}

local LSTR = _G.LSTR
local LocalStrID = require("Game/Skill/SkillSystem/SkillSystemConfig").LocalStrID

local LabelMap = {
    [LocalStrID.Active] = ESkillTagType.SKILL_TAG_ACTIVE,
    [LocalStrID.Passive] = ESkillTagType.SKILL_TAG_PASSIVE,
    [LocalStrID.LimitSkill] = ESkillTagType.SKILL_TAG_LIMIT,
    [LocalStrID.Normal] = ESkillTagType.SKILL_TAG_ACTIVE,
    [LocalStrID.Collection] = ESkillTagType.SKILL_TAG_LIFESKILL_COLLECTION,
    [LocalStrID.FishLift] = ESkillTagType.SKILL_TAG_LIFESKILL_FISH_LIFT,
    [LocalStrID.FishDrop] = ESkillTagType.SKILL_TAG_LIFESKILL_FISH_DROP,
}

function SkillTagCfg.GetTagTypeByLifeskillActionType(ActionType)
    return LifeskillActionTypeMap[ActionType]
end

function SkillTagCfg.GetTagTypeBySkillClass(SkillClass)
    return SkillClassMap[SkillClass]
end

function SkillTagCfg.GetTagTypeBySkillTag(SkillTag)
    return SkillTagMap[SkillTag]
end

function SkillTagCfg.GetTagTypeByLabel(Label)
    return LabelMap[Label]
end

return SkillTagCfg
