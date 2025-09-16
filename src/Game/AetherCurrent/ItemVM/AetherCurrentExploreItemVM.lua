---
--- Author: Alex
--- DateTime: 2023-09-05 09:56:30
--- Description: 风脉泉交互点标记VM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local UIUtil = require("Utils/UIUtil")

---@class AetherCurrentExploreItemVM : UIViewModel

local AetherCurrentExploreItemVM = LuaClass(UIViewModel)

---Ctor
function AetherCurrentExploreItemVM:Ctor()
    -- Main Part
    self.ListID = 0
    self.bActived = false
    self.StateChangeToActived = false
end

function AetherCurrentExploreItemVM:IsEqualVM(Value)
    return self.ListID == Value.MarkID
end

function AetherCurrentExploreItemVM:UpdateVM(Value)
   self.ListID = Value.MarkID
   self.bActived = Value.bActived
end

function AetherCurrentExploreItemVM:SetItemActived()
    self.StateChangeToActived = true
    --self.bActived = true
end

return AetherCurrentExploreItemVM
