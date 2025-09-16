---
--- Author: anypkvcai
--- DateTime: 2021-04-06 21:26
--- Description:
---
--- 统一使用UIBinderUpdateListView
---

--[[
local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderUpdateTableView : UIBinder
local UIBinderUpdateTableView = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UIAdapterTableView
function UIBinderUpdateTableView:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue UIBindableList | table
---@param OldValue UIBindableList | table
function UIBinderUpdateTableView:OnValueChanged(NewValue, OldValue)
	self.Widget:UpdateAll(NewValue)
end

return UIBinderUpdateTableView
--]]