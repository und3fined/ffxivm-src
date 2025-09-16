


local VfxEffectPath = {
    BelssingVfx = "VfxBlueprint'/Game/Assets/Effect/Particles/bgcommon/world/common/vfx_for_bg/b0018_trtp1y/BP_b0018_trtp1y.BP_b0018_trtp1y_C'", -- 临时

}

local EBlessingState = {
    NotBegin = 1,   -- 未开始
    Prepare = 2,    -- 预热
    InBlessing = 3, -- 进行中
    InWarning = 4,    -- 临近结束 
}


local GoldSaucerBlessingDefine = {
    VfxEffectPath = VfxEffectPath,
    EBlessingState = EBlessingState,
}


return GoldSaucerBlessingDefine