---
--- Author: henghaoli
--- DateTime: 2024-11-28 16:02
--- Description:
---

local UIUtil = require("Utils/UIUtil")
local UIBinderSetFormatTextValueWithCurve = require("Binder/UIBinderSetFormatTextValueWithCurve")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local EHeatType = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH].EHeatType



local HeatTypeWidgetMap = {
    [EHeatType.Zero]   = { "ImgBtnNormal" },
    [EHeatType.Low]    = { "ImgBtnColor3" },
    [EHeatType.Medium] = { "ImgBtnColor2", "EFF_Level2" },
    [EHeatType.High]   = { "ImgBtnColor1", "EFF_Level3" },
    [EHeatType.Forge]  = { "ImgBtnColor4", "EFF_Level4" },
}

local EHammerType = {
    None = 0,
    MultipleOf_3_or_5 = 1,
    MultipleOf_15 = 2,
}

local HammerBkgTextureMap = {
    [EHammerType.MultipleOf_3_or_5] = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Arrow1.UI_Crafter_Icon_Arrow1'",
    [EHammerType.MultipleOf_15] = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Arrow2.UI_Crafter_Icon_Arrow2'",
}



---@class CrafterBlacksmithTapItemUtil
local CrafterBlacksmithTapItemUtil = {}

local OnHeatTypeChanged = function(TapView, NewHeatType, OldHeatType)
    for HeatType, WidgetList in pairs(HeatTypeWidgetMap) do
        local bVisible = HeatType == NewHeatType
        for _, WidgetName in pairs(WidgetList) do
            UIUtil.SetIsVisible(TapView[WidgetName], bVisible, false, false)
        end
    end

    if NewHeatType == EHeatType.Forge then
        TapView:PlayAnimation(TapView.AnimHotOver)
    end

    if NewHeatType and OldHeatType then
        TapView:PlayAnimation(TapView.AnimRise)
    end
end

local function UpdateHammerType(TapView, Efficiency, bHasSkillBuff)
    local NewHammerType = EHammerType.None
    if Efficiency > 0 and bHasSkillBuff then
        if Efficiency % 15 == 0 then
            NewHammerType = EHammerType.MultipleOf_15
        elseif Efficiency % 3 == 0 or Efficiency % 5 == 0 then
            NewHammerType = EHammerType.MultipleOf_3_or_5
        end
    end
    TapView.VM.HammerType = NewHammerType
end

local OnEfficiencyChanged = function(TapView, Efficiency)
    return UpdateHammerType(TapView, Efficiency, TapView.ParentView.bHasSkillBuff)
end

local OnHammerTypeChanged = function(TapView, HammerType)
    return UIUtil.ImageSetBrushFromAssetPath(TapView.ImgArrow, HammerBkgTextureMap[HammerType], true, nil, true)
end

function CrafterBlacksmithTapItemUtil.RegisterTapBinders(TapView)
    local Name = TapView:GetName()
    local Len = string.len(Name)
    local Index = tonumber(Name:sub(Len, Len))

    TapView.OnHeatTypeChanged = OnHeatTypeChanged
    TapView.OnEfficiencyChanged = OnEfficiencyChanged
    TapView.OnHammerTypeChanged = OnHammerTypeChanged
    TapView.UpdateHammerType = UpdateHammerType

    local TapBinders = {
        { "Efficiency", UIBinderSetFormatTextValueWithCurve.New(TapView, TapView.Text1, nil, 0.5, nil, "%d", 0) },
        { "Efficiency", UIBinderValueChangedCallback.New(TapView, nil, TapView.OnEfficiencyChanged) },
        { "HeatType", UIBinderValueChangedCallback.New(TapView, nil, TapView.OnHeatTypeChanged) },
        { "HammerType", UIBinderValueChangedCallback.New(TapView, nil, TapView.OnHammerTypeChanged) },
    }
    local ParentView = TapView.ParentView
    if not ParentView then
        return
    end

    local VM = ParentView.CrafterArmorerBlacksmithTapVM[Index]
    TapView.VM = VM
    TapView:RegisterBinders(VM, TapBinders)
end

return CrafterBlacksmithTapItemUtil