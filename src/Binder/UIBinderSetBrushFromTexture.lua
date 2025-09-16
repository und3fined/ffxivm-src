--
-- Author: anypkvcai
-- Date: 2020-08-14 14:10:22
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetBrushFromTexture : UIBinder
local UIBinderSetBrushFromTexture = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetBrushFromTexture:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue UTexture2D
---@param OldValue UTexture2D
function UIBinderSetBrushFromTexture:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local UTexture2D = NewValue

	self.Widget:SetBrushFromTexture(UTexture2D)
end

return UIBinderSetBrushFromTexture