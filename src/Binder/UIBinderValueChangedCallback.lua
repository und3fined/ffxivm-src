---
--- Author: anypkvcai
--- DateTime: 2021-08-17 16:14
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local CommonUtil = require("Utils/CommonUtil")

---@class UIBinderValueChangedCallback : UIBinder
local UIBinderValueChangedCallback = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
---@param OnValueChangedCallback function
function UIBinderValueChangedCallback:Ctor(View, Widget, OnValueChangedCallback, Param)
	self.OnValueChangedCallback = OnValueChangedCallback
	self.Param = Param
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderValueChangedCallback:OnValueChanged(NewValue, OldValue)
	CommonUtil.XPCall(self.View, self.OnValueChangedCallback, NewValue, OldValue, self.Param)
end

return UIBinderValueChangedCallback