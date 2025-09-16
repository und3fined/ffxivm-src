---
--- Author: xingcaicao
--- DateTime: 2023-05-15 21:23
--- Description: 设置职业简化图标2（第二套）
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetProfIconSimple2nd : UIBinder
local UIBinderSetProfIconSimple2nd = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetProfIconSimple2nd:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetProfIconSimple2nd:OnValueChanged(NewValue, OldValue)
	if NewValue == nil then
		return
	end

	local ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple2nd(NewValue)
    if string.isnilorempty(ProfIcon) then
        return
    end

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, ProfIcon)
end

return UIBinderSetProfIconSimple2nd