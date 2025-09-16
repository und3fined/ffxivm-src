local ActorUtil = require("Utils/ActorUtil")
local EffectUtil = require("Utils/EffectUtil")

local LineEffectInterval = 600
local DefaultRelevanceLineEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/PlayerCommon/VBP/BP_Common_HatredArrow_2.BP_Common_HatredArrow_2_C'"
local RecentlyStartTime = -1

---@class RelevanceLineEffectPlayer
local RelevanceLineEffectPlayer = {}

function RelevanceLineEffectPlayer:Start(StartActor, DstTargetIDs)


    if (DstTargetIDs == nil or #DstTargetIDs == 0) then
        return
    end
    if (StartActor == nil) then
        return
    end
    local NowTime = _G.TimeUtil.GetServerTimeMS()
    if ((NowTime - RecentlyStartTime) < LineEffectInterval) then
        return
    end
    RecentlyStartTime = NowTime

    local AttrComponent = StartActor:GetAttributeComponent()
    if (AttrComponent == nil) then
        return
    end

    for _, DstTargetID in ipairs(DstTargetIDs) do
        local DstTarget = ActorUtil.GetActorByEntityID(DstTargetID)
        if (DstTarget ~= nil) then
            local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
            local VfxParameter = _G.UE.FVfxParameter()
            VfxParameter.VfxRequireData.EffectPath = DefaultRelevanceLineEffectPath
            VfxParameter:SetCaster(StartActor, _G.UE.EVFXEID.EID_HEAD_CENTER, AttachPointType_Body, 0)
            VfxParameter:AddTarget(DstTarget, _G.UE.EVFXEID.EID_CHEST, AttachPointType_Body, 0)
            EffectUtil.PlayVfx(VfxParameter)
        end
    end
end

return RelevanceLineEffectPlayer