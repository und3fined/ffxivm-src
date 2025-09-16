---
--- Author: Sammrli
--- DateTime: 2023-12-5 16:51:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderCanvasSlotSetScale : UIBinder
local UIBinderCanvasSlotSetScale = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderCanvasSlotSetScale:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue UE.FVector2D
---@param OldValue UE.FVector2D
function UIBinderCanvasSlotSetScale:OnValueChanged(NewValue, OldValue)
	if nil == NewValue then
		return
	end

	self.Widget:SetRenderScale(NewValue)
end

return UIBinderCanvasSlotSetScale