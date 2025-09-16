local ProtoRes = require("Protocol/ProtoRes")

local ESkillActionType = ProtoRes.ESkillActionType

local CellNameMap = {
    [ESkillActionType.ESkillActionType_SkillPlayAnimationAction] = "ActionCell",
    [ESkillActionType.ESkillActionType_SkillDamageEventAction] = "DamageCell",
    --[ESkillActionType.ESkillActionType_SkillWeightAction] = "SkillWeightCell",
    [ESkillActionType.ESkillActionType_SkillPlayVfxAction] = "SkillVfxCell",
    [ESkillActionType.ESkillActionType_SkillMoveToAction] = "DirectionalMoveCell",
    [ESkillActionType.ESkillActionType_SkillResetToAction] = "ResetDirectionalMoveCell",
    [ESkillActionType.ESkillActionType_SkillControlAction] = "SkillControlCell",
    [ESkillActionType.ESkillActionType_SkillControlTurnAction] = "SkillControlTurnCell",
    [ESkillActionType.ESkillActionType_SkillPlayWwiseAudioAction] = "SkillSoundCell",
    [ESkillActionType.ESkillActionType_CombatCameraAction] = "CombatCameraCell",
    [ESkillActionType.ESkillActionType_FadeAction] = "SkillFadeCell",
    [ESkillActionType.ESkillActionType_FadeActorAction] = "FadeActorCell",
    [ESkillActionType.ESkillActionType_FadeWeaponAction] = "FadeWeaponCell",
    [ESkillActionType.ESkillActionType_RadialBlurAction] = "RadialBlurCell",
    [ESkillActionType.ESkillActionType_SkillActiontimelineAction] = "SkillActiontimelineCell",
    [ESkillActionType.ESkillActionType_SkillCameraEffectAction] = "CameraEffectCell",
    [ESkillActionType.ESkillActionType_SkillCameraSequenceAction] = "SceneSequenceCell",
    [ESkillActionType.ESkillActionType_SkillCameraShakeAction] = "CameraShakeCell",
    [ESkillActionType.ESkillActionType_SkillChangeActorAction] = "SkillChangeActorCell",
    [ESkillActionType.ESkillActionType_SkillDamageWarningAction] = "DamageWarningCell",
    [ESkillActionType.ESkillActionType_SkillForceFeedbackAction] = "VibrationCell",
    [ESkillActionType.ESkillActionType_SkillGameEventAction] = "SkillGameEventCell",
    [ESkillActionType.ESkillActionType_SkillGhostTrailAction] = "SkillGhostTrailCell",
    [ESkillActionType.ESkillActionType_SkillPlaybackRateAction] = "SkillPlaybackRateCell",
    [ESkillActionType.ESkillActionType_SkillPlayWindEffectAction] = "SkillPlayWindEffectCell",
    [ESkillActionType.ESkillActionType_SkillSplashAction] = "SkillSplashCell",
    [ESkillActionType.ESkillActionType_SkillWeaponSwitchAction] = "SkillWeaponSwitchCell",
    [ESkillActionType.ESkillActionType_MirrorEffectAction] = "MirrorEffectCell",
}

-- 吟唱只支持下面这几种Cell
local SingCellNameMap = {
    [ESkillActionType.ESkillActionType_SkillPlayVfxAction] = "SkillVfxCell",
    [ESkillActionType.ESkillActionType_SkillPlayAnimationAction] = "ActionCell",
    [ESkillActionType.ESkillActionType_SkillCameraShakeAction]  = "CameraShakeCell",
    [ESkillActionType.ESkillActionType_SkillPlayWwiseAudioAction] = "SkillSoundCell",
    [ESkillActionType.ESkillActionType_CombatCameraAction] = "CombatCameraCell",
    [ESkillActionType.ESkillActionType_SkillCameraEffectAction] = "CameraEffectCell",
    [ESkillActionType.ESkillActionType_SkillDamageEventAction] = "SingDamageCell",
    [ESkillActionType.ESkillActionType_SkillDamageWarningAction] = "DamageWarningCell",
    [ESkillActionType.ESkillActionType_SkillSplashAction] = "SkillSplashCell",
}

local CellObjectPoolSizeMap = {
    [ESkillActionType.ESkillActionType_SkillPlayAnimationAction] = 20,
    [ESkillActionType.ESkillActionType_SkillPlayVfxAction] = 40,
    [ESkillActionType.ESkillActionType_CombatCameraAction] = 2,
    [ESkillActionType.ESkillActionType_FadeAction] = 5,
    [ESkillActionType.ESkillActionType_FadeActorAction] = 5,
    [ESkillActionType.ESkillActionType_FadeWeaponAction] = 5,
    [ESkillActionType.ESkillActionType_RadialBlurAction] = 5,
    [ESkillActionType.ESkillActionType_SkillActiontimelineAction] = 20,
    [ESkillActionType.ESkillActionType_SkillCameraEffectAction] = 5,
    [ESkillActionType.ESkillActionType_SkillCameraSequenceAction] = 2,
    [ESkillActionType.ESkillActionType_SkillCameraShakeAction] = 5,
    [ESkillActionType.ESkillActionType_SkillChangeActorAction] = 2,
    [ESkillActionType.ESkillActionType_SkillDamageWarningAction] = 10,
    [ESkillActionType.ESkillActionType_SkillForceFeedbackAction] = 5,
    [ESkillActionType.ESkillActionType_SkillGameEventAction] = 10,
    [ESkillActionType.ESkillActionType_SkillGhostTrailAction] = 5,
    [ESkillActionType.ESkillActionType_SkillPlaybackRateAction] = 2,
    [ESkillActionType.ESkillActionType_SkillPlayWindEffectAction] = 2,
    [ESkillActionType.ESkillActionType_SkillSplashAction] = 15,
    [ESkillActionType.ESkillActionType_SkillWeaponSwitchAction] = 5,
    [ESkillActionType.ESkillActionType_MirrorEffectAction] = 5,
}

local SingCellObjectPoolSizeMap = {
}

-- 如果配一个列表, 那么会根据配置的列表名逐个获取需要加载的资源列表
-- 如果配置一个函数, 会以CellData作为参数直接调用函数获取需要的资源列表
local PreLoadFieldsMap = {
    [ESkillActionType.ESkillActionType_MirrorEffectAction] = function(CellData)
        return table.array_concat({ CellData.EffectActorPath }, CellData.TrajCurves)
    end,
    [ESkillActionType.ESkillActionType_SkillCameraEffectAction] = {
        "m_EffectTemplate",
        "m_EffectActor",
    },
    [ESkillActionType.ESkillActionType_SkillCameraSequenceAction] = {
        "m_SequencePath",
    },
    [ESkillActionType.ESkillActionType_SkillDamageEventAction] = {
        "ActorEffect",
        "m_EffectTemplate",
        "m_Event",
    },
    [ESkillActionType.ESkillActionType_SkillDamageWarningAction] = {
        "m_WarningActor",
        "m_Texture",
        "m_EffectTemplate",
        "m_EffectActor",
    },
    [ESkillActionType.ESkillActionType_SkillForceFeedbackAction] = {
        "m_ForceFeedAsset",
    },
    [ESkillActionType.ESkillActionType_CombatCameraAction] = function(CellData)
        return { CellData.CombatCameraParam.Spline }
    end,
    [ESkillActionType.ESkillActionType_SkillGhostTrailAction] = function(CellData)
        local MatParams = CellData.MatParams
        local AssetsToLoad = { CellData.GhostMaterial, CellData.ScaleCurve }
        for _, MatParam in ipairs(MatParams) do
            table.insert(AssetsToLoad, MatParam.Curve)
            table.insert(AssetsToLoad, MatParam.ColorCurve)
        end
        return AssetsToLoad
    end,
    [ESkillActionType.ESkillActionType_SkillPlayAnimationAction] = function(CellData)
        return { CellData.CurveEditorPanel, CellData.m_AnimationAsset, CellData.m_BlendIn.CustomCurve }
    end,
    [ESkillActionType.ESkillActionType_SkillPlayWwiseAudioAction] = {
        "m_Event"
    },
    [ESkillActionType.ESkillActionType_SkillMoveToAction] = {
        "CurveEditorPanel"
    },
    [ESkillActionType.ESkillActionType_SkillPlayVfxAction] = {
        "m_VfxClass",
    }
}

local SkillActionConfig = {
    CellNameMap = CellNameMap,
    SingCellNameMap = SingCellNameMap,
    CellObjectPoolSizeMap = CellObjectPoolSizeMap,
    SingCellObjectPoolSizeMap = SingCellObjectPoolSizeMap,
    PreLoadFieldsMap = PreLoadFieldsMap,
    DefaultCellObjectPoolSize = 20,
    DefaultSingCellObjectPoolSize = 5,
    CellDataListLruCacheSize = 60,
    SingCellDataListLruCacheSize = 20,
    SkillObjectPoolSize = 20,
    SingSkillObjectPoolSize = 20,
    PreLoadInterval = 0,
    DefaultParseCellDataTimeLimit = 700,  -- 预加载解析CellData默认时间上限(微秒)
}

return SkillActionConfig
