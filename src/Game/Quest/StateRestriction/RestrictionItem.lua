---
--- Author: lydianwang
--- DateTime: 2022-11-21
---

local LuaClass = require("Core/LuaClass")
local RestrictionBase = require("Game/Quest/BasicClass/RestrictionBase")
local BagMgr = require("Game/Bag/BagMgr")

---@class RestrictionItem
local RestrictionItem = LuaClass(RestrictionBase, true)

function RestrictionItem:Ctor(_, Properties)
    self.ItemIDList = {}
    self.ItemNumList = {}

    local ItemIDStrList = string.split(Properties[1], "|")
    for _, Str in ipairs(ItemIDStrList) do
        table.insert(self.ItemIDList, tonumber(Str))
    end

    local ItemNumStrList = string.split(Properties[1], "|")
    for _, Str in ipairs(ItemNumStrList) do
        table.insert(self.ItemNumList, tonumber(Str))
    end

    self:UpdateQuestAtEvent(_G.EventID.BagUpdate)
end

---@return boolean
function RestrictionItem:CheckPassRestriction()
    for i = 1, #self.ItemIDList do
        local ResID = self.ItemIDList[i]
        local Num = self.ItemNumList[i]
        if not (ResID and Num) then return false end

        local CurrNum = BagMgr:GetItemNum(ResID)
        if CurrNum < Num then return false end
    end

    return true
end

return RestrictionItem