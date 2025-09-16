---
--- Author: anypkvcai
--- DateTime: 2021-02-08 15:41
--- Description:
---
---
local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetOpacity : UIBinder
local UIBinderSetOpacity = LuaClass(UIBinder)

---Ctor
---@param View UUserWidget
---@param Widget UImage
function UIBinderSetOpacity:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetOpacity:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Opacity = NewValue

	self.Widget:SetOpacity(Opacity)
end

return UIBinderSetOpacity