--
-- Author: anypkvcai
-- Date: 2022-05-06 15:53
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetButtonBrush : UIBinder
local UIBinderSetButtonBrush = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UButton
---@param BrushName string | nil @["Normal", "Hovered", "Pressed", "Pressed", nil]
function UIBinderSetButtonBrush:Ctor(View, Widget, BrushName)
	self.BrushName = BrushName
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetButtonBrush:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local AssetPath = NewValue
	if nil == AssetPath then
		return
	end

	UIUtil.ButtonSetBrush(self.Widget, AssetPath, self.BrushName)
end

return UIBinderSetButtonBrush