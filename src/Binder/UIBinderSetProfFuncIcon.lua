---
--- Author: v_hggzhang
--- DateTime: 2023-01-05 20:13
--- Description: 设置职业职能图标
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")
local ProfUtil = require("Game/Profession/ProfUtil")

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
	local Icon = ProfUtil.Prof2FuncIcon(ProfID)
	UIUtil.ImageSetBrushFromAssetPath(self.Widget, Icon)
end

return UIBinderSetProfIcon