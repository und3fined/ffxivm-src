---
--- Author: v_hggzhang
--- DateTime: 2023-01-05 20:13
--- Description: 设置职业职能名称
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local ProfUtil = require("Game/Profession/ProfUtil")

---@class UIBinderSetProfName : UIBinder
local UIBinderSetProfName = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetProfName:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetProfName:OnValueChanged(NewValue, OldValue)
	local ProfID = NewValue
	local Name = ProfUtil.Prof2FuncName(ProfID)
	self.Widget:SetText(Name)
end

return UIBinderSetProfName