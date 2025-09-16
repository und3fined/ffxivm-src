---
--- Author: sammrli
--- DateTime: 2025-02-21
--- 目标：完成Fate
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

local FateMainCfg = require("TableCfg/FateMainCfg")

---@class TargetFinishFate
local TargetFinishFate = LuaClass(TargetBase, true)

function TargetFinishFate:Ctor(_, Properties)
    self.FateID = tonumber(Properties[1]) or 0
end

function TargetFinishFate:DoStartTarget()
end

return TargetFinishFate