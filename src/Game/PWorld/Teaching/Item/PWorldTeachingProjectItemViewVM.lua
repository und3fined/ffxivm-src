
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TeachingType = require("Game/Pworld/Teaching/TeachingType")

local PWorldTeachingProjectItemViewVM = LuaClass(UIViewModel)

function PWorldTeachingProjectItemViewVM:Ctor()
    self.Desc = ""
    self.State = TeachingType.Item_State.UnOpened
end

function PWorldTeachingProjectItemViewVM:UpdateVM(Value)
    self.Desc = Value.Desc
    self.State = Value.State
end

return PWorldTeachingProjectItemViewVM