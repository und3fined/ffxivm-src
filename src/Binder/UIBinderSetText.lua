--
-- Author: anypkvcai
-- Date: 2020-08-05 15:45:51
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetText : UIBinder
local UIBinderSetText = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
---@param textFunc function | nil
function UIBinderSetText:Ctor(View, Widget, TextHandleFunc)
	self.TextHandleFunc = TextHandleFunc
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetText:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if self.TextHandleFunc then
		self.Widget:SetText(self.TextHandleFunc(NewValue, OldValue))
		return
	end

	if nil == NewValue then
		self.Widget:SetText("")
		return
	end

	local Text = NewValue

	self.Widget:SetText(Text)
end

return UIBinderSetText