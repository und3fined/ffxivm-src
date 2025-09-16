---
--- Author: Alex
--- DateTime: 2023-09-05 09:50:30
--- Description: 风脉泉任务标记VM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local UIUtil = require("Utils/UIUtil")

---@class AetherCurrentTaskItemVM : UIViewModel

local AetherCurrentTaskItemVM = LuaClass(UIViewModel)

---Ctor
function AetherCurrentTaskItemVM:Ctor()
    -- Main Part
    self.QuestID = 0
    self.bActived = false
    self.StateChangeToActived = false
end

function AetherCurrentTaskItemVM:IsEqualVM(Value)
    return self.QuestID == Value.MarkID
end

function AetherCurrentTaskItemVM:UpdateVM(Value)
    self.QuestID = Value.MarkID
    self.bActived = Value.bActived
end

function AetherCurrentTaskItemVM:SetItemActived()
    self.StateChangeToActived = true
end

return AetherCurrentTaskItemVM
