local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetIsAllowDoubleClick : UIBinder
local UIBinderSetIsAllowDoubleClick = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderSetIsAllowDoubleClick:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsAllowDoubleClick:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if type(NewValue) == "number" then
		NewValue = NewValue ~= 0
	end
	
	self.Widget:SetIsAllowDoubleClick(NewValue)
end

return UIBinderSetIsAllowDoubleClick