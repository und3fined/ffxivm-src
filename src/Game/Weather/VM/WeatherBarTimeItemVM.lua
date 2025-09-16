local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local WeatherBarTimeItemVM = LuaClass(UIViewModel) 


function WeatherBarTimeItemVM:Ctor()
    self.Time = ""
end

function WeatherBarTimeItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Time == self.Time
end

function WeatherBarTimeItemVM:UpdateVM(Info)
    self.Time = Info.Time
end

return WeatherBarTimeItemVM