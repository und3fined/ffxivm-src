local PhotoEffectUtil = {}
local EffectUtil = require("Utils/EffectUtil")
local ActorUtil = require("Utils/ActorUtil")
local AnimationUtil = require("Utils/AnimationUtil")

local FadeInTime = 0
local EAvatarPartType = _G.UE.EAvatarPartType

function PhotoEffectUtil.CreateEffect(EntityID, EffRes)
    _G.FLOG_INFO(string.format('[Photo][PhotoEffectUtil][CreateEffect] EntityID = %s, EffRes = %s',
        tostring(EntityID),
        tostring(EffRes)
    ))
    -- EffRes = "VfxBlueprint'/Game/Fire_1.Fire_1_C'"
    -- EntityID = MajorUtil.GetMajorEntityID()

	local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        _G.FLOG_ERROR(string.format("[Photo][PhotoEffectUtil][CreateEffect] Entity = nil ID = %s",
                tostring(EntityID)))
        return
    end

    local VfxParameter = _G.UE.FVfxParameter()
	VfxParameter.VfxRequireData.EffectPath = EffRes
    VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_PhotoEffectUtil
    VfxParameter.VfxRequireData.VfxTransform = Actor:FGetActorTransform()
    VfxParameter:SetCaster(Actor, nil, nil, 0)
    VfxParameter:AddTarget(Actor, nil, nil, 0)
    return EffectUtil.PlayVfx(VfxParameter, FadeInTime)
end

function PhotoEffectUtil.DelEffect(VfxID)
    EffectUtil.StopVfx(VfxID)
end

function PhotoEffectUtil.PlayAvatarEffect(Actor, EffName, IsShow)
    local Avatar = Actor:GetAvatarComponent()
    if Avatar then
        Avatar:SetEffect(IsShow, EffName);
    end
end

local OtherParts = {EAvatarPartType.RIDE_MASTER, EAvatarPartType.Ornament_Umbrella, EAvatarPartType.Ornament_Wing}
function PhotoEffectUtil.PauseAnim(Actor, IsPause)
    AnimationUtil.SetPauseAnimAndOtherPart(Actor, IsPause, OtherParts)
end

---@region State function distribute

-- 石化
function PhotoEffectUtil.Rigidify(Actor)
    PhotoEffectUtil.PlayAvatarEffect(Actor, "Petrify", true)
    PhotoEffectUtil.PauseAnim(Actor, true)

    return function()
        PhotoEffectUtil.PlayAvatarEffect(Actor, "Petrify", false)
        PhotoEffectUtil.PauseAnim(Actor, false)
    end
end

-- 冰冻
function PhotoEffectUtil.Frozen(Actor)
    PhotoEffectUtil.PlayAvatarEffect(Actor, "Freeze", true)
    PhotoEffectUtil.PauseAnim(Actor, true)

    return function()
        PhotoEffectUtil.PlayAvatarEffect(Actor, "Freeze", false)
        PhotoEffectUtil.PauseAnim(Actor, false)
    end
end

-- -- 魅惑
-- function PhotoEffectUtil.Charm(Actor)
    
--     return 
-- end

function PhotoEffectUtil.PlayStat(EntityID, ID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        _G.FLOG_ERROR(string.format("[Photo][PhotoEffectUtil][PlayStat] Entity = nil ID = %s",
                tostring(EntityID)))
        return
    end

    if ID == 1 then
        return PhotoEffectUtil.Frozen(Actor)
    elseif ID == 2 then
        return PhotoEffectUtil.Rigidify(Actor)
    -- elseif ID == 5 then
    --     return PhotoEffectUtil.Charm(Actor)
    end
end

return PhotoEffectUtil