local FVector2D = _G.UE.FVector2D

local Anchors = _G.UE.FAnchors()
Anchors.Minimum.X = 1
Anchors.Minimum.Y = 1
Anchors.Maximum.X = 1
Anchors.Maximum.Y = 1

local SkillSystemConfig = {
    SkillSystemConfigPath = "CommonSkillSystemDataAsset'/Game/BluePrint/Skill/SkillSystem/CommonConfig.CommonConfig'",
    SkillSystemRenderActor = "Blueprint'/Game/UI/Render2D/SkillSystem/BP_Render2DSkillSystemActor.BP_Render2DSkillSystemActor_C'",
    SkillSystemLevel = "/Game/UI/Render2D/SkillSystem/L_SkillSystemLevel",
    SkillExpandConfig = {
        BPName = "Skill/Item/SkillExpandItem_UIBP",
        Position = FVector2D(-555, -150),
        Size = FVector2D(100, 30),
        Alignment = FVector2D(0.5, 0),
        ZOrder = 5,
        Anchors = Anchors,
    },
    RedDotVersion = 1,

    LocalStrID = {
        Active = 170001,
        Passive = 170002,
        LimitSkill = 170003,
        Normal = 170004,
        Collection = 170005,
        FishDrop = 170006,
        FishLift = 170007,
        None = 170059,
    },

    -- 这里的Index是OriginalButtonIndex, 未进行替换的
    ReplaceShadowMap = {
        { "NewMainSkill.Able10" },                               -- ButtonIndex == 1
        { "NewMainSkill.Able8", "NewMainSkill.Able9" },          -- ButtonIndex == 2
        { "NewMainSkill.Trigger1" },                             -- ButtonIndex == 3
        { "SkillMainPanel.CommTabs", "NewMainSkill.Trigger2" },  -- ButtonIndex == 4
        { "SkillMainPanel.CommTabs" },                           -- ButtonIndex == 5
    }
}

return SkillSystemConfig