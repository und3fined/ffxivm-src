---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-08-01 10:39
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local RewardStatus = ProtoCS.Game.Activity.RewardStatus

local SeanceScratchTaskItemVM = LuaClass(UIViewModel)

--物品选中后的表现

SeanceScratchTaskItemVM.SelcteStatus = {Change = 1, Superposition = 2} -- 1，改变选中状态，2，叠加选中状态支持多种

---Ctor
function SeanceScratchTaskItemVM:Ctor()
    self.TaskName = ""
    self.RewardStatus = RewardStatus.RewardStatusNo
    self.RewardCount = 1
end

function SeanceScratchTaskItemVM:IsEqualVM(InValue)
    return InValue.NodeCfg.ID == self.NodeCfg.ID
end


function SeanceScratchTaskItemVM:UpdateVM(InData, Params)
    self.NodeCfg = InData.NodeCfg
    self.TaskName = InData.TaskName
    self.RewardStatus = InData.Status or RewardStatus.RewardStatusNo
    self.RewardCount = InData.RewardCount
end

function SeanceScratchTaskItemVM:UpdateParams(Params)
    if nil == Params then
        return
    end
end

return SeanceScratchTaskItemVM
