---
--- Author: lydianwang
--- DateTime: 2022-11-21
---

local LuaClass = require("Core/LuaClass")
local RestrictionBase = require("Game/Quest/BasicClass/RestrictionBase")
local BagMgr = require("Game/Bag/BagMgr")
local QuestDefine = require("Game/Quest/QuestDefine")

---@class RestrictionBagSlot
local RestrictionBagSlot = LuaClass(RestrictionBase, true)

function RestrictionBagSlot:Ctor(_, Properties)
    self.ReqSlotNum = tonumber(Properties[1]) or 0

    self:UpdateQuestAtEvent(_G.EventID.BagUpdate)
    self:UpdateQuestAtEvent(_G.EventID.BagBuyCapacity)

    self.RestrictedDialogType = QuestDefine.RestrictedDialogType.BagSlot
end

---@return boolean
function RestrictionBagSlot:CheckPassRestriction()
    local LeftNum = BagMgr:GetBagLeftNum()
    return LeftNum >= self.ReqSlotNum
end

---@return string
function RestrictionBase:MakeRestrictedDialog()
    return string.format(_G.LSTR(596304), self.ReqSlotNum) --596304("背包剩余空格数大于或等于%d个")
end

return RestrictionBagSlot