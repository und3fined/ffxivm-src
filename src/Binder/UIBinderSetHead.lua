---
--- Author: andre_lightpaw
--- DateTime: 2021-04-13 20:13
--- Description: 设置头像框
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")

---@class UIBinderSetHead : UIBinder
local UIBinderSetHead = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetHead:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetHead:OnValueChanged(NewValue, OldValue)
	if table.empty(NewValue) then
		_G.FLOG_Warning('[PersonHead][UIBinderSetHead][OnValueChanged] HeadInfo nil')
	end

	PersonPortraitHeadHelper.SetHeadByHeadInfo(self.Widget, NewValue or {})
end

return UIBinderSetHead