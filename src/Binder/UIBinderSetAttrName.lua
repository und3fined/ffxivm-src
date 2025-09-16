--
-- Author: enqingchen
-- Date: 2020-1-17
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local AttrDefCfg = require("TableCfg/AttrDefCfg")

---@class UIBinderSetAttrName : UIBinder
local UIBinderSetAttrName = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetAttrName:Ctor(View, Widget)
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetAttrName:OnValueChanged(NewValue, OldValue)
	if NewValue == OldValue then
		return
	end

	local Text = AttrDefCfg:GetAttrNameByID(NewValue)

	self.Widget:SetText(Text)
end

return UIBinderSetAttrName