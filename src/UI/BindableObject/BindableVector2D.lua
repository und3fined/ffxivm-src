--
-- Author: anypkvcai
-- Date: 2023-12-11 22:23
-- Description:
--

local FVector2D = _G.UE.FVector2D
local LuaClass = require("Core/LuaClass")
local UIBindableObject = require("UI/UIBindableObject")

local EPSILON = 0.1

---@class BindableVector2D : UIViewModel
local BindableVector2D = LuaClass(UIBindableObject)

---Ctor
function BindableVector2D:Ctor()
	self.Vector2D = FVector2D()
end

---SetValue
---@param X number
---@param Y number
function BindableVector2D:SetValue(X, Y)
	local Vector2D = self.Vector2D
	local OldX = Vector2D.X
	local OldY = Vector2D.Y

	Vector2D:Set(X, Y)

	if math.abs(X - OldX) > EPSILON or math.abs(Y - OldY) > EPSILON then
		self:OnValueChanged()
	end
end

---GetValue
---@return number, number
function BindableVector2D:GetValue()
	local Vector2D = self.Vector2D

	return Vector2D.X, Vector2D.Y
end

---GetVector2D
---@return FVector2D
function BindableVector2D:GetVector2D()
	return self.Vector2D
end

return BindableVector2D