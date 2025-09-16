--
-- Author: anypkvcai
-- Date: 2020-08-14 14:09:45
-- Description: 一般建议用 UIBinderSetIsVisible，只用boolean值就可以，更简单。
--



local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetVisibility : UIBinder
local UIBinderSetVisibility = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderSetVisibility:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue ESlateVisibility
---@param OldValue ESlateVisibility
function UIBinderSetVisibility:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Visibility = NewValue

	self.Widget:SetVisibility(Visibility)
end

return UIBinderSetVisibility