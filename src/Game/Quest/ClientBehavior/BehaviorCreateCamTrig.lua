---
--- Author: lydianwang
--- DateTime: 2022-03-31
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local QuestCameraCfg = require("TableCfg/QuestCameraCfg")

---@class BehaviorCreateCamTrig
local BehaviorCreateCamTrig = LuaClass(BehaviorBase, true)

function BehaviorCreateCamTrig:Ctor(_, Properties)
    self.MapID = tonumber(Properties[1])
    self.AreaID = tonumber(Properties[2])
    self.CamCfgID = tonumber(Properties[3])

    self.CamCfg = QuestCameraCfg:FindCfgByKey(self.CamCfgID)
    if self.CamCfg == nil then
        _G.FLOG_ERROR("BehaviorChangeCamera: Wrong camera ID %d", self.CamCfgID or 0)
    end
end

function BehaviorCreateCamTrig:DoStartBehavior()
    if self.CamCfg == nil then return end
end

return BehaviorCreateCamTrig