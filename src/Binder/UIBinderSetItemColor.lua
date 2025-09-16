---
--- Author: anypkvcai
--- DateTime: 2021-09-23 15:16
--- Description: 根据ITEM_COLOR_TYPE 设置物品颜色
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local ColorUtil = require("Utils/ColorUtil")
local FLinearColor = _G.UE.FLinearColor

---@class UIBinderSetItemColor : UIBinder
local UIBinderSetItemColor = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetItemColor:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number @ITEM_COLOR_TYPE
---@param OldValue number @ITEM_COLOR_TYPE
function UIBinderSetItemColor:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Color = NewValue
	local HexColor = ColorUtil.GetItemHexColor(Color)
	local LinearColor = FLinearColor.FromHex(HexColor)

	self.Widget:SetColorAndOpacity(LinearColor)
end

return UIBinderSetItemColor