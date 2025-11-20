local ProtoRes = require("Protocol/ProtoRes")
local GameID = ProtoRes.Game.GameID

local LSTR = _G.LSTR


local VfxEffectPath = {
    BelssingVfx = "VfxBlueprint'/Game/Assets/Effect/Particles/bgcommon/world/common/vfx_for_bg/b0018_trtp1y/BP_b0018_trtp1y.BP_b0018_trtp1y_C'", -- 临时
    PrepareVfx = "VfxBlueprint'/Game/Assets/Effect/Particles/Branch/DS/Monster/JDYLC/VBP/BP_CFMS_YR.BP_CFMS_YR_C'",
    BigVfx = "VfxBlueprint'/Game/Assets/Effect/Particles/Branch/DS/Monster/JDYLC/VBP/BP_CFMS_DCF.BP_CFMS_DCF_C'",
    LittleVfx = "VfxBlueprint'/Game/Assets/Effect/Particles/Branch/DS/Monster/JDYLC/VBP/BP_CFMS_XCF.BP_CFMS_XCF_C'"
}

local EBlessingState = {
    NotBegin = 1,   -- 未开始
    Prepare = 2,    -- 预热
    InBlessingNormal = 3, -- 普通进行中
    InBlessingWarning = 4,    -- 进行中临近结束 
}

--- 地图npc标记对应玩法种类
local MapMarkerNpc2GameID = {
    [29100002] = GameID.GameIDCrystalTower,
    [29100003] = GameID.GameIDMonsterBasketball,
    [29100004] = GameID.GameIDCatchBall,
    [29100005] = GameID.GameIDGilgamesh,
    [29100006] = GameID.GameIDOreSearch,
    [29100007] = GameID.GameIDAloneTree,
}

local GameID2Name = {
    [GameID.GameIDCrystalTower] = LSTR(260001),
    [GameID.GameIDMonsterBasketball] = LSTR(270001) ,
    [GameID.GameIDCatchBall] = LSTR(360001),
    [GameID.GameIDGilgamesh] = LSTR(250008),
    [GameID.GameIDOreSearch] = LSTR(380001),
    [GameID.GameIDAloneTree] = LSTR(370001),
}

local MarkerIconWithState = {
    ["Normal"] = "Texture2D'/Game/Assets/Icon/MapIconSnap/GoldSaucer/UI_Map_Icon_GoldSaucer_XYX.UI_Map_Icon_GoldSaucer_XYX'",
    ["Bless"] = "Texture2D'/Game/Assets/Icon/MapIconSnap/GoldSaucer/UI_Map_Icon_GoldSaucer_XRSF.UI_Map_Icon_GoldSaucer_XRSF'",
}

local ChallengeTargetIconPath = {
    ["BigBless"] = "Texture2D'/Game/UI/Texture/GoldSaucerGame/GoldSaucer_MonsterToss_Icon_Info_02.GoldSaucer_MonsterToss_Icon_Info_02'",
    ["LittleBless"] = "Texture2D'/Game/UI/Texture/GoldSaucerGame/GoldSaucer_MonsterToss_Icon_Info_01.GoldSaucer_MonsterToss_Icon_Info_01'"
}

local GoldSaucerBlessingDefine = {
    VfxEffectPath = VfxEffectPath,
    EBlessingState = EBlessingState,
    MapMarkerNpc2GameID = MapMarkerNpc2GameID,
    MarkerIconWithState = MarkerIconWithState,
    GameID2Name = GameID2Name,
    ChallengeTargetIconPath = ChallengeTargetIconPath,
}


return GoldSaucerBlessingDefine