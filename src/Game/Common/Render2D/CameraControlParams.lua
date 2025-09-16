local LuaClass = require("Core/LuaClass")

---@class ViewDistParams
local ViewDistParams = LuaClass()
function ViewDistParams:Ctor()
	self.ViewDistance = 0
	self.FOV = 0
	self.ZOffset = 0
	self.PitchOffset = 0
end

---@class CameraControlParams
local CameraControlParams = LuaClass()

function CameraControlParams:Ctor()
    self.DefaultViewDistance = 0
	self.MinPitch = 0
	self.MaxPitch = 0
	self.FocusLocation = _G.UE.FVector()
	self.FocusEID = ""
	self.MinViewDistParams = ViewDistParams.New()
	self.MaxViewDistParams = ViewDistParams.New()
end

return CameraControlParams