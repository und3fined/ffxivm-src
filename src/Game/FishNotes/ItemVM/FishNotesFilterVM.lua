---
---@author Lucas
---DateTime: 2023-04-20 15:22:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FishNotesFilterVM: UIViewModel
local FishNotesFilterVM = LuaClass(UIViewModel)

function FishNotesFilterVM:Ctor()
end

function FishNotesFilterVM:InitVM(Value)
end

return FishNotesFilterVM