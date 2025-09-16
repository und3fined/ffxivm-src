--
-- Author: loiafeng
-- Date: 2024-12-19 15:45:51
-- Description: buff图标层数显示
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetBuffPile : UIBinder
local UIBinderSetBuffPile = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UFTextBlock
function UIBinderSetBuffPile:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetBuffPile:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if nil == NewValue or type(NewValue) ~= "number" then
		return
	end

	if NewValue > 1 then
		UIUtil.SetIsVisible(self.Widget, true)
		self.Widget:SetText(tostring(NewValue))
	else
		UIUtil.SetIsVisible(self.Widget, false)
	end
end

return UIBinderSetBuffPile