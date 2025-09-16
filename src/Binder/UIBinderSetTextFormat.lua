--
-- Author: anypkvcai
-- Date: 2020-08-14 14:46:23
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class UIBinderSetTextFormat : UIBinderSetText
local UIBinderSetTextFormat = LuaClass(UIBinderSetText)

---Ctor
---@param View UIView
---@param Widget UTextBlock
---@param Format string
function UIBinderSetTextFormat:Ctor(View, Widget, Format)
	self.Format = Format
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetTextFormat:OnValueChanged(NewValue, OldValue)
	if nil == NewValue or nil == self.Widget then
		return
	end

	local Text = string.format(self.Format, NewValue)

	self.Widget:SetText(Text)
end

return UIBinderSetTextFormat