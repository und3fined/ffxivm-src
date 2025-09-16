--
-- Author: haialexzhou
-- Date: 2021-10-9
-- Description:关卡电梯
--

local LuaClass = require("Core/LuaClass")
---@class MapElevator
local MapElevator = LuaClass()

function MapElevator:Ctor()
    self.ID = 0
    self.MapElevatorController = nil
end

function MapElevator:Destroy()
    if (self.MapElevatorController ~= nil) then
        self.MapElevatorController:Destroy()
        self.MapElevatorControllerRef = nil
        self.MapElevatorController = nil
    end
end

function MapElevator:CreateElevatorController()
    self.MapElevatorController = _G.NewObject(_G.UE.UMapElevatorController)
    if (self.MapElevatorController ~= nil) then
        self.MapElevatorControllerRef = UnLua.Ref(self.MapElevatorController)
    end
end

function MapElevator:UpdateElevator(NewStatus, StartPointIndex, EndPointIndex, StartTime)
    if (self.MapElevatorController ~= nil) then
        self.MapElevatorController:UpdateElevator(NewStatus, StartPointIndex, EndPointIndex, StartTime)
    end
end

return MapElevator