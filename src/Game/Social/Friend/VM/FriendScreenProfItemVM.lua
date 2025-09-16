---
--- Author: xingcaicao
--- DateTime: 2024-07-10 15:55
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FriendScreenProfItemVM : UIViewModel
local FriendScreenProfItemVM = LuaClass(UIViewModel)

local MaxLineProf = 11

function FriendScreenProfItemVM:Ctor()
    self.Name = "" 
    self.Icon = ""
    self.ProfInfoList = {}
end

function FriendScreenProfItemVM:UpdateVM(Value)
    self.Name = Value.Name 
    self.Icon = Value.Icon 

    local Data = {}
    local CfgList = Value.CfgList or {}

    for _, v in ipairs(CfgList) do
        table.insert(Data, {ProfID = v.Prof, Icon = v.SimpleIcon2})
    end

    self.ProfInfoList = Data
end

function FriendScreenProfItemVM:AdapterOnGetWidgetIndex()
    return #self.ProfInfoList <= MaxLineProf and 0 or 1
end

function FriendScreenProfItemVM:AdapterOnGetCanBeSelected()
    return false
end

return FriendScreenProfItemVM 