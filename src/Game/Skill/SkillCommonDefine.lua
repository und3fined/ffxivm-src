
local SkillCommonDefine = {
    --动态加载的多选一技能面板
    MultiChoicePanelBPName = "MainSkillBtn/SkillButtonMultiChoice_UIBP",
    --技能主界面
    NewMainSkillBPName = "MainSkillBtn/NewMainSkill_UIBP",
    --技能拖拽禁用颜色
	JoyStickInvalidateColor = "D75F8373",-- FF4E77FF
    --技能拖拽默认颜色
	JoyStickDefaultColor = "FFFFFFFF",

    --技能未解锁时图标
    DefaultLockIcon = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Img_Locked_png.UI_Skill_Img_Locked_png'",

    LimitDefaultIcon = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Limit_Icon_png.UI_Skill_Limit_Icon_png'",

    --长按显示tips时间
    SkillTipsClickTime = 1,

    --点击缩放反馈
    SkillBtnClickFeedback = 0.9,
}

-- NormalType UMETA(DisplayName = "普通技能"),
-- ComboType UMETA(DisplayName = "连招技能"),
-- StorageType UMETA(DisplayName = "蓄力技能"),
-- PreInputType UMETA(DisplayName = "预输入技能"),
-- SingType UMETA(DisplayName = "吟唱技能"),
SkillCommonDefine.SkillCastType = _G.UE.ESkillCastType


--技能栏位映射
local SkillButtonIndexRange = {
    Normal = 0,         --普攻
    Able_Start = 1,     --能力技
    Able_End = 5,
    Trigger_Start = 6,  --触发技
    Trigger_End = 7,
    Guard = 8,          --护身技
    Fight = 9,
    Speed = 10,
    Function = 11,
    AbleExtend_Start = 12,--能力技补充
    Limit_PVP = 12,       --pvp极限技
    Trigger_PVP = 14,     --PVP触发技
    AbleExtend_End = 15,
    Limit_Start = 16,
    Limit_End = 18,
    Spectrum_Start = 19,
    Spectrum_End = 21,
    Multi_Start = 26,
    Multi_End = 29,
    Mount_Gather = 30, --坐骑界面勘探技能
    ExclusiveProp = 31,  --专属道具杀怪技能
    Mount_Start = 32,  --坐骑技能
    Mount_End = 34,
    FindGatherPoint = 35, --采集职业 勘探  ;  从4号位(SkillCommonDefine.FindGatherPointRealIndex)的技能槽取技能id
    TeamRescure  = 36,  --队友救援
}
SkillCommonDefine.SkillButtonIndexRange = SkillButtonIndexRange
SkillCommonDefine.FindGatherPointRealIndex = 5  --采集职业5号位是勘探技能

local SkillButtonIndexType = {
    Normal = 0,
    Able = 1,
    Trigger = 2,
    Guard = 3,
    Fight = 4,
    Speed = 5,
    Function = 6,
    AbleExtend = 7,
    Limit = 8,
    Spectrum = 9,
    MultiSkill = 10,
    INVALID = 99,
}
SkillCommonDefine.SkillButtonIndexType = SkillButtonIndexType

local IndexMap = {
    [0] = SkillButtonIndexType.Normal,
    [1] = SkillButtonIndexType.Able,
    [6] = SkillButtonIndexType.Trigger,
    [8] = SkillButtonIndexType.Guard,
    [9] = SkillButtonIndexType.Fight,
    [10] = SkillButtonIndexType.Speed,
    [11] = SkillButtonIndexType.Function,
    [12] = SkillButtonIndexType.AbleExtend,
    [16] = SkillButtonIndexType.Limit,
    [19] = SkillButtonIndexType.Spectrum,
    [26] = SkillButtonIndexType.MultiSkill,
    [30] = SkillButtonIndexType.INVALID,
}
SkillCommonDefine.IndexMap = IndexMap

-- 技能Tips样式
local SkillTipsType = {
    None = 0,
    Combat = 1,   -- 战斗技能
    Crafter = 2,  -- 生产技能
    Gather = 3,   -- 采集技能
    Mount = 4,    -- 坐骑技能
    ChocoboRace = 5, -- 陆行鸟竞赛技能
}
SkillCommonDefine.SkillTipsType = SkillTipsType

-- 技能Tips内容样式
local SkillTipsContentType = {
    TextBlock = 0,
    DividerLine = 1,
    AttrItem = 2,
}
SkillCommonDefine.SkillTipsContentType = SkillTipsContentType

local SkillButtonIndexMap = setmetatable(IndexMap, {
    __index = function(SkillButtonIndexMap, key)
        local Index = key
        local Val = nil
        while(Val == nil)
        do
            Index = Index - 1
            Val = rawget(SkillButtonIndexMap, Index)
        end
        return Val
    end
})

function SkillCommonDefine.GetButtonIndexType(Index)
    return SkillButtonIndexMap[Index]
end

SkillCommonDefine.SysChatMsgBattleLimit = 3

return SkillCommonDefine