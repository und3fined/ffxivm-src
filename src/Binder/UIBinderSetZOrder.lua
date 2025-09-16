local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetZOrder : UIBinder
local UIBinderSetZOrder = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderSetZOrder:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetZOrder:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget or NewValue == nil then
		return
	end

	local ZOrder = NewValue

    UIUtil.CanvasSlotSetZOrder(self.Widget, ZOrder)
end

return UIBinderSetZOrder