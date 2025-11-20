--
-- Author: Alex
-- Date: 2024-02-28 16:06
-- Description:探索笔记
--

local FLinearColor = _G.UE.FLinearColor

local RedDotBaseName = "Root/Menu/AtlasEntrance/SightSeeing"

local NoteCompleteVfxEffectCommonID = 244

local TutorialTriggerRange = 500 -- 探索笔记新手指南触发范围

local GuideID = 44 -- 探索笔记新手引导组ID

local NpcLeaveSpeed = 250 -- Npc离场速度

local NpcLeaveWaitMaxTime = 5 -- Npc离场最大等待时间

local NoteUnlockType = {
    ["Locked"] = 0,
    ["NormalUnlock"] = 1,
    ["PerfectUnlock"] = 2,
    ["UnlockFail"] = 3,
}

local TextureColoredColorParam = {
    Color = FLinearColor.FromHex("ffffffff"),
    Int = 1,
    Tint = 0
}

local TextureGreyColorParam = {
    Color = FLinearColor.FromHex("ffdca3ff"),
    Int = 1,
    Tint = 1
}

local TextureColoredOpacityParam = {
    Opacity = 1
}

local TextureGreyOpacityParam =  {
    Opacity = 0.9
}

local NoteClueType = {
    ["Weather"] = 1,
    ["Time"] = 2,
    ["Emotion"] = 3,
}

local NoteClueSrcType = {
    ["Config"] = 0,
    ["Loot"] = 1,
    ["TreasureBox"] = 2,
    ["Monster"] = 3,
    ["NpcDialog"] = 4,
}

local RegionTabRedDotUpdateReason = {
    ["NewRegionOpen"] = 1, -- 新页签开放（强红点）
    ["PassByNoteItem"] = 2, -- 笔记红点传递(弱红点)
}

local DiscoverNoteDefine = {
    RedDotBaseName = RedDotBaseName,
    NoteCompleteVfxEffectCommonID = NoteCompleteVfxEffectCommonID,
    NoteUnlockType = NoteUnlockType,
    TextureColoredColorParam = TextureColoredColorParam,
    TextureGreyColorParam = TextureGreyColorParam,
    TextureColoredOpacityParam = TextureColoredOpacityParam,
    TextureGreyOpacityParam = TextureGreyOpacityParam,
    NoteClueType = NoteClueType,
    NoteClueSrcType = NoteClueSrcType,
    TutorialTriggerRange = TutorialTriggerRange,
    GuideID = GuideID,
    NpcLeaveSpeed = NpcLeaveSpeed,
    NpcLeaveWaitMaxTime = NpcLeaveWaitMaxTime,
    RegionTabRedDotUpdateReason = RegionTabRedDotUpdateReason,
}

return DiscoverNoteDefine