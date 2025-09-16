--
-- Author: anypkvcai
-- Date: 2022-11-03 10:20
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetMaterialVectorParameterValue : UIBinder
local UIBinderSetMaterialVectorParameterValue = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetMaterialVectorParameterValue:Ctor(View, Widget, ParameterName)
	self.ParameterName = ParameterName
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetMaterialVectorParameterValue:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if not NewValue then
		return
	end
	
	UIUtil.ImageSetMaterialSetVectorParameterValue(self.Widget, self.ParameterName, NewValue)
end

return UIBinderSetMaterialVectorParameterValue