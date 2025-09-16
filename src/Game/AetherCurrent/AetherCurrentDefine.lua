--
-- Author: Alex
-- Date: 2023-09-06 17:13
-- Description:风脉泉系统
--
local LSTR = _G.LSTR

local BaseSearchCD = 5 -- 风脉仪冷却时间

local SkillCDUpdateInterval = 0.05 -- 风脉仪cdMask刷新时间间隔

local HelpBtnDialoglibID = 111010 -- 功能说明按钮Dialog表id

local MissionTipShowDelayTime = 0.5 -- 风脉泉激活完毕延迟显示时间

local MissionTipShowDuration = 3 -- 风脉泉激活完毕显示持续时间

local TemporaryBtnConstantTime = 10 --风脉泉临时入口按钮显示持续时间

local PanelTipsShowTime = 2 --风脉泉解锁tips显示时间

local UnlockUIAnimDelayTime = 0.6 -- 动效需求延时显示时间

local UnlockMapAnimDelayTime = 1.8 -- 动效需求延时显示时间

local UnlockMapAnimConstantTime = 4 -- 动效需求持续显示时间

local OpenLinkedQuest = 140283 -- 风脉泉功能开启任务ID

local MapActiveItemID = 66700287 -- 风脉地图解锁道具ID

local TutorialGroupID = 5 -- 风脉泉引导组ID

local TutorialTriggerRange = 4000 -- 风脉泉引导触发范围

local DirText = {
    LSTR(310002),
    LSTR(310003),
    LSTR(310004),
    LSTR(310005),
    LSTR(310006),
    LSTR(310007),
    LSTR(310008),
    LSTR(310009),
}

-- 不同类型风脉泉地图标记图片资源
local MarkerIconPath = {
    ["Interact"] = "PaperSprite'/Game/UI/Atlas/AetherCurrent/Frames/UI_AetherCurrent_Icon_Green_png.UI_AetherCurrent_Icon_Green_png'",
    ["Task"] = "PaperSprite'/Game/UI/Atlas/AetherCurrent/Frames/UI_AetherCurrent_Icon_Yellow_png.UI_AetherCurrent_Icon_Yellow_png'",
}

local MapAllPointActivateState = {
    InvalidMap = 0,
    AllComp = 1,
    NotComp = 2,
}

local function SortQuestMarkPredicate(Left, Right)
    local LActiveState = Left.bActived or false
    local RActiveState = Right.bActived or false
    if LActiveState == RActiveState then
        return false
    else
        return LActiveState == false
    end
end

local RangeAlarmState = {
    ["None"] = 0,
    ["Less30"] = 1,
    ["Less100"] = 2,
    ["More100"] = 3,
}

--- 风脉仪探测标准
local MachineDetectRange = {
    30, 70, 100
}

local MachineDetectDef = {
    { 
        FormatContent = LSTR(310010),
        bFormatReplace = false,
        TipsExistTime = 4,
        bShowBuoy = false,
        bShowSkillPanelDisContent = true,
        bShowDisNumOrText = false,
        SkillPanelDisContentExistTime = 20,
        bShowMachineEffect = true,
        RangeAlarmState = RangeAlarmState.Less30,
        AudioValue = 2,
    }, 
    { 
        FormatContent = LSTR(310011),
        bFormatReplace = false,
        TipsExistTime = 4,
        bShowBuoy = false,
        bShowSkillPanelDisContent = true,
        SkillPanelDisContentExistTime = 20,
        bShowMachineEffect = true,
        RangeAlarmState = RangeAlarmState.Less100,
        AudioValue = 1,
    }, 
    { 
        FormatContent = LSTR(310011),
        bFormatReplace = false,
        TipsExistTime = 4,
        bShowBuoy = false,
        bShowSkillPanelDisContent = false,
        bShowDisNumOrText = true,
        SkillPanelDisContentExistTime = 20,
        bShowMachineEffect = true,
        RangeAlarmState = RangeAlarmState.Less100,
        AudioValue = 0,
    },
    { 
        FormatContent = LSTR(310012),
        bFormatReplace = true,
        TipsExistTime = 4,
        bShowBuoy = false,
        bShowSkillPanelDisContent = true,
        bShowDisNumOrText = true,
        SkillPanelDisContentExistTime = 20,
        bShowMachineEffect = false,
        RangeAlarmState = RangeAlarmState.More100,
    }, 
    { 
        FormatContent = LSTR(310013),
        bFormatReplace = true,
        TipsExistTime = 4,
        bShowBuoy = true,
        bNormalBuoyExistTime = 30,
        bShowSkillPanelDisContent = true,
        SkillPanelDisContentExistTime = 30,
        bShowMachineEffect = false,
    }, 
}

local MapTabListItemFlyIconPath = {
    ["Grey"] = "PaperSprite'/Game/UI/Atlas/AetherCurrent/Frames/UI_AetherCurrent_Icon_Feather_png.UI_AetherCurrent_Icon_Feather_png'",
    ["Yellow"] = "PaperSprite'/Game/UI/Atlas/AetherCurrent/Frames/UI_AetherCurrent_Icon_Feather02_png.UI_AetherCurrent_Icon_Feather02_png'",
}

local VfxEffectType = {
    ["None"] = 0,
    ["AllComplete"] = 1,
    ["UseItem1"] = 2,
    ["UseItem2"] = 3,
    ["ActiveSing"] = 4,
    ["OneTimeMapComplete"] = 5,
}

local VfxEffectPath = {
    [VfxEffectType.AllComplete] = {
        ID = 244,
        Path = "VfxBlueprint'/Game/Assets/Effect/Particles/PlayerCommon/VBP/BP_formation03f.BP_formation03f_C'",
        Time = 0,
        CasterOrTarget = true
    },
    [VfxEffectType.UseItem1] = {
        Path = "VfxBlueprint'/Game/Assets/Effect/Particles/PlayerSkill/Common/VBP/BP_quest_item0f.BP_quest_item0f_C'",
        Time = 0.3,
        CasterOrTarget = false,
    },
    [VfxEffectType.UseItem2] = {
        Path = "VfxBlueprint'/Game/Assets/Effect/Particles/PlayerSkill/Common/VBP/BP_quest_item1f.BP_quest_item1f_C'",
        Time = 1,
        CasterOrTarget = false,
    },
    [VfxEffectType.ActiveSing] = {
        ID = 173,
        Path = "VfxBlueprint'/Game/Assets/Effect/Particles/PlayerCommon/VBP/BP_aettouch_c2c.BP_aettouch_c2c_C'",
        Time = 5,
        CasterOrTarget = true,
    },
    [VfxEffectType.OneTimeMapComplete] = {
        Path = "VfxBlueprint'/Game/Assets/Effect/Particles/System/FMQ/VBP/BP_FMQ_1_SC.BP_FMQ_1_SC_C'",
        Time = 0,
        CasterOrTarget = true,
    },
    --
    --SingleComplete = "VfxBlueprint'/Game/Assets/Effect/Particles/PlayerCommon/VBP/BP_aettouch_c1c.BP_aettouch_c1c_C'",
}

local function SortRegion(A, B)
    return A < B
end

local AetherCurrentDefine = {
    BaseSearchCD = BaseSearchCD,
    EightDirectContent = DirText,
    MarkerIconPath = MarkerIconPath,
    QuestMarkSortRule = SortQuestMarkPredicate,
    HelpBtnDialoglibID = HelpBtnDialoglibID,
    MapAllPointActivateState = MapAllPointActivateState,
    MissionTipShowDelayTime = MissionTipShowDelayTime,
    MissionTipShowDuration = MissionTipShowDuration,
    SkillCDUpdateInterval = SkillCDUpdateInterval,
    MachineDetectRange = MachineDetectRange,
    MachineDetectDef = MachineDetectDef,
    TemporaryBtnConstantTime = TemporaryBtnConstantTime,
    PanelTipsShowTime = PanelTipsShowTime,
    SortRegion = SortRegion,
    MapTabListItemFlyIconPath = MapTabListItemFlyIconPath,
    RangeAlarmState = RangeAlarmState,
    UnlockUIAnimDelayTime = UnlockUIAnimDelayTime,
    UnlockMapAnimDelayTime = UnlockMapAnimDelayTime,
    UnlockMapAnimConstantTime = UnlockMapAnimConstantTime,
    OpenLinkedQuest = OpenLinkedQuest,
    VfxEffectPath = VfxEffectPath,
    VfxEffectType = VfxEffectType,
    MapActiveItemID = MapActiveItemID,
    TutorialGroupID = TutorialGroupID,
    TutorialTriggerRange = TutorialTriggerRange,
}

return AetherCurrentDefine