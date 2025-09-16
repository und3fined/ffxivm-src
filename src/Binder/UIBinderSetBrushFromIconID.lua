--
-- Author: loiafeng
-- Date: 2023-04-20 14:10:22
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetBrushFromIconID : UIBinder
local UIBinderSetBrushFromIconID = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetBrushFromIconID:Ctor(View, Widget, bIsMatchSize)
	self.bIsMatchSize = bIsMatchSize
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetBrushFromIconID:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if nil == NewValue or 0 == NewValue then
		return
	end

	local AssetPath = UIUtil.GetIconPath(NewValue)

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, AssetPath, self.bIsMatchSize)
end

return UIBinderSetBrushFromIconID