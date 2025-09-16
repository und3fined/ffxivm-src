---
--- Author: loiafeng
--- DateTime: 2025-01-07 10:47
--- Description: 仇恨列表Panel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MainEnmityItemVM = require("Game/Main/EnmityPanel/MainEnmityItemVM")

---@class MainEnmityPanelVM : UIViewModel
local MainEnmityPanelVM = LuaClass(UIViewModel)

function MainEnmityPanelVM:Ctor()
    self.EnmityDisplayList = UIBindableList.New(MainEnmityItemVM)  ---@type UIBindableList
end

function MainEnmityPanelVM:OnInit()
end

function MainEnmityPanelVM:OnBegin()
end

function MainEnmityPanelVM:OnEnd()
end

function MainEnmityPanelVM:OnShutdown()
end

return MainEnmityPanelVM
