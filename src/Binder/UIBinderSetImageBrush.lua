---
--- Author: xingcaicao 
--- DateTime: 2023-04-19 17:11:05
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetImageBrush : UIBinder
local UIBinderSetImageBrush = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UFImage
function UIBinderSetImageBrush:Ctor(View, Widget, bIsMatchSize, bNoCache)
	self.bIsMatchSize = bIsMatchSize
	self.bNoCache = bNoCache
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetImageBrush:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if string.isnilorempty(NewValue) then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, NewValue, self.bIsMatchSize, self.bNoCache)
end

return UIBinderSetImageBrush