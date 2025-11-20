---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-07-28 20:46
--- Description:
---

local UIViewModel = require("UI/UIViewModel")
local LuaClass = require("Core/LuaClass")


local ToySlotItemVM = LuaClass(UIViewModel)

function ToySlotItemVM:Ctor()
    self.ResID = 0
    self.bSelected = false
    self.bFavorite = false
    self.bInCD = false
    self.CD = 0 -- 冷却时间
    self.LastTimeStamp = 0 -- 持续时间
end

function ToySlotItemVM:UpdateVM(InValue, InParams)
    if (InValue == nil) then
        return
    end

    self.ResID = InValue.ResID -- 一定要先设置ID，其他的是基于 ID_CFG 的
    self:UpdateTimeStamp(InValue.CD or 0, InValue.Last or 0)
    self.bSelected = InValue.bSelected or false
    self.bFavorite = InValue.bFavorite or false
end

function ToySlotItemVM:UpdateTimeStamp(InCDValue, InLastTimeStamp)
    self.CD = InCDValue * 1000 -- 服务器没下发MS，这里手动乘以1000
    self.LastTimeStamp = InLastTimeStamp * 1000
end

function ToySlotItemVM:GetLastTimeStamp()
    return self.LastTimeStamp
end

function ToySlotItemVM:UpdateParams(InParams)
end

function ToySlotItemVM:IsEqualVM(InValue)
    return InValue ~= nil and InValue.ToyID == self.ToyID
end

return ToySlotItemVM
