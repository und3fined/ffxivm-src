---
--- Author: anypkvcai
--- DateTime: 2021-04-26 16:57
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetBrushFromAssetPath : UIBinder
local UIBinderSetBrushFromAssetPath = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetBrushFromAssetPath:Ctor(View, Widget, bIsMatchSize, bNoCache, HideIfAssetPathIsInvalid)
	self.bIsMatchSize = bIsMatchSize
	self.bNoCache = bNoCache
	self.HideIfAssetPathIsInvalid = HideIfAssetPathIsInvalid
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetBrushFromAssetPath:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local AssetPath = NewValue

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, AssetPath, self.bIsMatchSize, self.bNoCache, self.HideIfAssetPathIsInvalid)
end

return UIBinderSetBrushFromAssetPath