--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:NPC达人索引ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FashionNPCIndexItevVM : UIViewModel
local FashionNPCIndexItevVM = LuaClass(UIViewModel)

function FashionNPCIndexItevVM:Ctor()
    self.NPCIndex = 1
end


function FashionNPCIndexItevVM:IsEqualVM(Value)
    return Value ~= nil and Value == self.NPCIndex
end

function FashionNPCIndexItevVM:UpdateVM(Value)
    self.NPCIndex = Value
end

return FashionNPCIndexItevVM