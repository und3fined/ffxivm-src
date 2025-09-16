--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:挑战记录索引ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FashionHistoryIndexItevVM : UIViewModel
local FashionHistoryIndexItevVM = LuaClass(UIViewModel)

function FashionHistoryIndexItevVM:Ctor()
    self.EquipGroupIndex = 1
end


function FashionHistoryIndexItevVM:IsEqualVM(Value)
    return Value ~= nil and Value == self.Index
end

function FashionHistoryIndexItevVM:UpdateVM(Value)
    self.EquipGroupIndex = Value
end

return FashionHistoryIndexItevVM