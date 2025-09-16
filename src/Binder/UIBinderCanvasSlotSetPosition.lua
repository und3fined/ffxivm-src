---
--- Author: v_zanchang
--- DateTime: 2023-1-29 17:44:34
--- Description: 建议用BindableVector2D，不用每次创建FVector2D对象，性能更好
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderCanvasSlotSetPosition : UIBinder
local UIBinderCanvasSlotSetPosition = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
---@param bVector2D boolean @Value值是 BindableVector2D 还是 UE.FVector2D，建议用BindableVector2D，不用每次创建FVector2D对象，性能更好
function UIBinderCanvasSlotSetPosition:Ctor(View, Widget, bVector2D)
	self.bVector2D = bVector2D
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderCanvasSlotSetPosition:OnValueChanged(NewValue, OldValue)
	if nil == NewValue then
		return
	end

	local Vector = self.bVector2D and NewValue or NewValue:GetVector2D()
	UIUtil.CanvasSlotSetPosition(self.Widget, Vector)
end

return UIBinderCanvasSlotSetPosition