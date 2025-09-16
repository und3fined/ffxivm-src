---
--- Author: lydianwang
--- DateTime: 2022-03-31
---

local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local QuestCameraCfg = require("TableCfg/QuestCameraCfg")

---@class BehaviorChangeCamera
local BehaviorChangeCamera = LuaClass(BehaviorBase, true)

function BehaviorChangeCamera:Ctor(_, Properties)
    self.MapID = tonumber(Properties[1])
    self.CamCfgID = tonumber(Properties[2])

    self.CamCfg = QuestCameraCfg:FindCfgByKey(self.CamCfgID)
    if self.CamCfg == nil then
        _G.FLOG_ERROR("BehaviorChangeCamera: Wrong camera ID %d", self.CamCfgID or 0)
    end
end

function BehaviorChangeCamera:DoStartBehavior()
    if self.CamCfg == nil then return end

    local MajorActor = MajorUtil:GetMajor()
    if MajorActor == nil then return end
    local Location, Distance, _, LagValue = self:GetCamCfgInfo()
    MajorActor:GetCameraControllComponent():CameraLookAtWithOffset(
        Location, Distance, _G.UE.FVector(), LagValue, false)
end

return BehaviorChangeCamera