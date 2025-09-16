---
--- Author: loiafeng
--- DateTime: 2025-01-07 10:47
--- Description: 仇恨列表Item
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MainEnmityItemVM : UIViewModel
local MainEnmityItemVM = LuaClass(UIViewModel)

---Ctor
function MainEnmityItemVM:Ctor()
    self.EntityID = 0
    self.RankInMonsterEnmityList = 999999
    self.bLastIsDisplay = false
end

---@param Value MainEnmityItemVM
function MainEnmityItemVM:IsEqualVM(Value)
    return self.EntityID == Value.EntityID
end

---UpdateVM
---@param Value table
function MainEnmityItemVM:UpdateVM(Params)
    if nil == Params then
        _G.FLOG_ERROR("MainEnmityItemVM.UpdateVM: Invalid params")
        return
    end

    self.EntityID = Params.EntityID
    self.RankInMonsterEnmityList = Params.RankInMonsterEnmityList
    self.bLastIsDisplay = Params.bLastIsDisplay
end

return MainEnmityItemVM
