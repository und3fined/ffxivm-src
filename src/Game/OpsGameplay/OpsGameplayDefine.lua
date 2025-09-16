---
--- Author: sammrli
--- DateTime: 2025-5-28
--- Description: 活动玩法定义
---

local ProtoRes = require("Protocol/ProtoRes")
local OPS_GAMEPLAY_TYPE = ProtoRes.OPS_GAMEPLAY_TYPE

local OpsGameplayDefine = {}

OpsGameplayDefine.ClassParams = {
    [OPS_GAMEPLAY_TYPE.OPS_GAMEPLAY_TYPE_HALLOWEEN] = {
        Class = "Game/OpsGameplay/Halloween/OpsGameplayHalloween",
    },
}

return OpsGameplayDefine