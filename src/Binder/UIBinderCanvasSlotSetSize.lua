---
--- Author: Alex
--- DateTime: 2023-4-17 16:51:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderCanvasSlotSetSize : UIBinder
local UIBinderCanvasSlotSetSize = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
---@param bVector2D boolean @Value值是 BindableVector2D 还是 UE.FVector2D，建议用BindableVector2D，不用每次创建FVector2D对象，性能更好
function UIBinderCanvasSlotSetSize:Ctor(View, Widget, bVector2D)
	self.bVector2D = bVector2D
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderCanvasSlotSetSize:OnValueChanged(NewValue, OldValue)
	if nil == NewValue then
		return
	end

	local Vector = self.bVector2D and NewValue or NewValue:GetVector2D()
	UIUtil.CanvasSlotSetSize(self.Widget, Vector)
end

return UIBinderCanvasSlotSetSize