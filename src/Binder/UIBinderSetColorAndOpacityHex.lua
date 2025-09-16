---
--- Author: anypkvcai
--- DateTime: 2021-04-13 15:23
--- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local FLinearColor = _G.UE.FLinearColor

---@class UIBinderSetColorAndOpacityHex : UIBinder
local UIBinderSetColorAndOpacityHex = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UWidget
function UIBinderSetColorAndOpacityHex:Ctor(View, Widget)
end

---OnValueChanged
---@param NewValue string @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
---@param OldValue string @"RGBA" example: Red="ff0000ff" Green="00ff00ff" Blue="0000ffff"
function UIBinderSetColorAndOpacityHex:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local HexColor = NewValue
	local LinearColor = FLinearColor.FromHex(HexColor)

	self.Widget:SetColorAndOpacity(LinearColor)
end

return UIBinderSetColorAndOpacityHex