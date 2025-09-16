---
--- Author: sammrli
--- DateTime: 2025-04-19
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class TravelLogTypeVM : UIViewModel
local TravelLogTypeVM = LuaClass(UIViewModel)

function TravelLogTypeVM:Ctor()
	self.Type = nil
	self.IconPath = nil
end

function TravelLogTypeVM:IsEqualVM(Value)
	return self.Type == Value.Type
end

function TravelLogTypeVM:UpdateVM(Value)
	if Value == nil then return end

	self.Type = Value.Type
    self.IconPath = Value.IconPath
end

function TravelLogTypeVM:GetType()
	return self.Type
end

return TravelLogTypeVM