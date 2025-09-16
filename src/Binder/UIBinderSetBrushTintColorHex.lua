---
--- Author: anypkvcai
--- DateTime: 2021-04-13 16:43
--- Description:
---
---
local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local FLinearColor = _G.UE.FLinearColor
local FSlateColor = _G.UE.FSlateColor

---@class UIBinderSetBrushTintColorHex : UIBinder
local UIBinderSetBrushTintColorHex = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetBrushTintColorHex:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetBrushTintColorHex:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local HexColor = NewValue
	local LinearColor = FLinearColor.FromHex(HexColor)
	local SlateColor = FSlateColor(LinearColor)

	self.Widget:SetBrushTintColor(SlateColor)
end

return UIBinderSetBrushTintColorHex