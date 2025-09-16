local LuaClass = require("Core/LuaClass")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

local MPRequestWork = LuaClass()

function MPRequestWork:Ctor()
	self.Key = 0
	self.Timbre = 0
end

function MPRequestWork:Clear()
	self.Key = 0
	self.Timbre = 0
end

function MPRequestWork:Set(Key, Timbre)
	self.Key = Key
	self.Timbre = Timbre
end

return MPRequestWork