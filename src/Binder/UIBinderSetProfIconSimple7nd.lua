---
--- Author: xingcaicao
--- DateTime: 2023-05-15 21:23
--- Description: 设置职业简化图标7（大图）
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetProfIconSimple7nd : UIBinder
local UIBinderSetProfIconSimple7nd = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetProfIconSimple7nd:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetProfIconSimple7nd:OnValueChanged(NewValue, OldValue)
	if NewValue == nil then
		return
	end

	local ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple7nd(NewValue)
    if string.isnilorempty(ProfIcon) then
        return
    end

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, ProfIcon)
end

return UIBinderSetProfIconSimple7nd