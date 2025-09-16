---
---@author Lucas
---DateTime: 2023-04-22 11:42:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FishNotesPlaceVM: UIViewModel
---@field Index number @地点下标
local FishNotesPlaceVM = LuaClass(UIViewModel)

function FishNotesPlaceVM:Ctor()
    self.Index = 0
    self.PlaceName = ""
end

function FishNotesPlaceVM:IsEqualVM(Value)
    return Value ~= nil
end

function FishNotesPlaceVM:UpdateVM(Value)
    self.Index = Value.Index
    self.PlaceName = Value.Location.Name
end

return FishNotesPlaceVM