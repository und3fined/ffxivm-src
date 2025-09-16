---
--- Author: anypkvcai
--- DateTime: 2021-04-13 20:13
--- Description: 设置职业图标
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetProfIcon : UIBinder
local UIBinderSetProfIcon = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetProfIcon:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetProfIcon:OnValueChanged(NewValue, OldValue)
	if NewValue == nil then
		return
	end

	local ProfID = NewValue
	local ProfIcon = RoleInitCfg:FindRoleInitProfIcon(ProfID)

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, ProfIcon)
end

return UIBinderSetProfIcon