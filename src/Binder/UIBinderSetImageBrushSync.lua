---
--- Author: loiafeng 
--- DateTime: 2024-05-17 16:21:07
--- Description: 同步加载的版本，请尽量避免使用
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetImageBrushSync : UIBinder
local UIBinderSetImageBrushSync = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UFImage
function UIBinderSetImageBrushSync:Ctor(View, Widget, bIsMatchSize, bNoCache)
	self.bIsMatchSize = bIsMatchSize
	self.bNoCache = bNoCache
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetImageBrushSync:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if string.isnilorempty(NewValue) then
		return
	end

	UIUtil.ImageSetBrushFromAssetPathSync(self.Widget, NewValue, self.bIsMatchSize, self.bNoCache)
end

return UIBinderSetImageBrushSync