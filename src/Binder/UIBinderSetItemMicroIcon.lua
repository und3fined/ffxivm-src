---
--- Author: anypkvcai
--- DateTime: 2021-04-26 16:57
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinderSetItemIcon = require("Binder/UIBinderSetItemIcon")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class UIBinderSetItemMicroIcon : UIBinderSetItemIcon
---@deprecated @使用UIBinderSetItemIcon
local UIBinderSetItemMicroIcon = LuaClass(UIBinderSetItemIcon)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetItemMicroIcon:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetItemMicroIcon:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if NewValue == nil then
		return
	end

	local Cfg = ItemCfg:FindCfgByKey(NewValue)
	if nil == Cfg then
		return
	end

	local Path = Cfg.MicroIconName
	if nil == Path then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, Path)
end

return UIBinderSetItemMicroIcon