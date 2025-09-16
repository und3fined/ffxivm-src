--
-- Author: anypkvcai
-- Date: 2022-11-03 10:20
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetMaterialTextureParameterValue : UIBinder
local UIBinderSetMaterialTextureParameterValue = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetMaterialTextureParameterValue:Ctor(View, Widget, ParameterName)
	self.ParameterName = ParameterName
end

---OnValueChanged
---@param NewValue UE.UTexture
---@param OldValue UE.UTexture
function UIBinderSetMaterialTextureParameterValue:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	UIUtil.ImageSetMaterialTextureParameterValue(self.Widget, self.ParameterName, NewValue)
end

return UIBinderSetMaterialTextureParameterValue