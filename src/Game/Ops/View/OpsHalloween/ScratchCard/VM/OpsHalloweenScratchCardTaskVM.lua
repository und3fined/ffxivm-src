---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-07-10
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local RewardStatus = ProtoCS.Game.Activity.RewardStatus

---@class OpsHalloweenScratchCardTaskVM : UIViewModel
local OpsHalloweenScratchCardTaskVM = LuaClass(UIViewModel)

function OpsHalloweenScratchCardTaskVM:Ctor()
    self.TaskName = ""
    self.RewardStatus = RewardStatus.RewardStatusNo
    self.RewardCount = 1
end

function OpsHalloweenScratchCardTaskVM:UpdateVM(InData)
    self.TaskName = InData.TaskName
    self.RewardStatus = InData.Status or RewardStatus.RewardStatusNo
    self.RewardCount = InData.RewardCount
    self.NodeCfg = InData.NodeCfg
end

function OpsHalloweenScratchCardTaskVM:IsEqualVM(InData)
    return false
end

return OpsHalloweenScratchCardTaskVM
