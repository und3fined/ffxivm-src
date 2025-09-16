--
-- Author: anypkvcai
-- Date: 2020-08-14 14:44:42
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetRenderOpacity : UIBinder
local UIBinderSetRenderOpacity = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderSetRenderOpacity:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetRenderOpacity:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local RenderOpacity = NewValue

	self.Widget:SetRenderOpacity(RenderOpacity)
end

return UIBinderSetRenderOpacity