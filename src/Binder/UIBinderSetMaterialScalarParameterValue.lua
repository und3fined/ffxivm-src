--
-- Author: anypkvcai
-- Date: 2022-11-03 10:20
-- Description:  set material scalar (float) parameter value of the image
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetMaterialScalarParameterValue : UIBinder
local UIBinderSetMaterialScalarParameterValue = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetMaterialScalarParameterValue:Ctor(View, Widget, ParameterName)
	self.ParameterName = ParameterName
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetMaterialScalarParameterValue:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	UIUtil.ImageSetMaterialScalarParameterValue(self.Widget, self.ParameterName, NewValue)
end

return UIBinderSetMaterialScalarParameterValue