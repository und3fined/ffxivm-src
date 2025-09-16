---
--- Author: anypkvcai
--- DateTime: 2021-04-13 20:17
--- Description:
---

--该Binder对应于常规ProgreessBar，也对应于RadialImage
--只要接口都是SetPercent就可以

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetPercent : UIBinder
local UIBinderSetPercent = LuaClass(UIBinder)

---Ctor
---@param View UUserWidget
---@param Widget UProgressBar
---@param StartPercent number 有些进度条因为资源图片边缘有空白, 实际上填不满整个空间框,
---@param EndPercent number   可以指定StartPercent/EndPercent将Percent映射到正常范围
function UIBinderSetPercent:Ctor(View, Widget, StartPercent, EndPercent)
	self.StartPercent = StartPercent
	self.EndPercent = EndPercent
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetPercent:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Percent = NewValue

	local StartPercent = self.StartPercent
	if StartPercent then
		local EndPercent = self.EndPercent or 1
		Percent = StartPercent + (EndPercent - StartPercent) * Percent
	end

	self.Widget:SetPercent(Percent)
end

return UIBinderSetPercent