---
--- Author: anypkvcai
--- DateTime: 2021-04-26 16:57
--- Description: 设置物品图标
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class UIBinderSetItemIcon : UIBinder
local UIBinderSetItemIcon = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetItemIcon:Ctor(View, Widget, IsMicroIcon)
	self.IsMicroIcon = IsMicroIcon
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetItemIcon:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Cfg = ItemCfg:FindCfgByKey(NewValue)
	if nil == Cfg then
		return
	end

	local Path = self.IsMicroIcon and Cfg.MicroIconName or Cfg.IconName
	if nil == Path then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, Path)
end

return UIBinderSetItemIcon