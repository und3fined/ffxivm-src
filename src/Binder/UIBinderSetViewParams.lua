--
-- Author: anypkvcai
-- Date: 2022-04-30 17:15
-- Description: 设置UIVie的Params参数
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetViewParams : UIBinder
local UIBinderSetViewParams = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UIView
function UIBinderSetViewParams:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue any
---@param OldValue any
function UIBinderSetViewParams:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Params = NewValue

	self.Widget:SetParams(Params)
end

return UIBinderSetViewParams