--
-- Author: anypkvcai
-- Date: 2022-07-13 16:42
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetSelectedItem : UIBinder
local UIBinderSetSelectedItem = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UIAdapterTableView
function UIBinderSetSelectedItem:Ctor(View, Widget)

end

---OnValueChanged
function UIBinderSetSelectedItem:OnValueChanged(NewValue, OldValue)
	self.Widget:SetSelectedItem(NewValue)
end

return UIBinderSetSelectedItem