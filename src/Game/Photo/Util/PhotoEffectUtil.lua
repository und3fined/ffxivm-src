

local Util = {}
local EffectUtil = require("Utils/EffectUtil")
local FadeInTime = 0
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

function Util.CreateEffect(EntityID, EffRes)
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

function Util.DelEffect(VfxID)
    EffectUtil.StopVfx(VfxID)
end

function Util.PlayAvatarEffect(Actor, EffName, IsShow)
    local Avatar = Actor:GetAvatarComponent()
    if Avatar then
        Avatar:SetEffect(IsShow, EffName);
    end
end

function Util.PauseAnim(Actor, IsPause)
    local AnimComp = Actor:GetAnimationComponent()
    if AnimComp then
        AnimComp:PauseAnimation(IsPause);
    end
end

---@region State function distribute

-- 石化
function Util.Rigidify(Actor)
    Util.PlayAvatarEffect(Actor, "Petrify", true)
    Util.PauseAnim(Actor, true)

    return function()
        Util.PlayAvatarEffect(Actor, "Petrify", false)
        Util.PauseAnim(Actor, false)
    end
end

-- 冰冻
function Util.Frozen(Actor)
    Util.PlayAvatarEffect(Actor, "Freeze", true)
    Util.PauseAnim(Actor, true)

    return function()
        Util.PlayAvatarEffect(Actor, "Freeze", false)
        Util.PauseAnim(Actor, false)
    end
end

-- -- 魅惑
-- function Util.Charm(Actor)
    
--     return 
-- end

function Util.PlayStat(EntityID, ID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        _G.FLOG_ERROR(string.format("[Photo][PhotoEffectUtil][PlayStat] Entity = nil ID = %s",
                tostring(EntityID)))
        return
    end

    if ID == 1 then
        return Util.Frozen(Actor)
    elseif ID == 2 then
        return Util.Rigidify(Actor)
    -- elseif ID == 5 then
    --     return Util.Charm(Actor)
    end
end

return Util