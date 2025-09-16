---
--- Author: anypkvcai
--- DateTime: 2021-04-06 21:26
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local CommonUtil = require("Utils/CommonUtil")

---@class UIBinderUpdateBindableList : UIBinder
local UIBinderUpdateBindableList = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UIAdapterTableView | UIAdapterDynamicEntryBox | UIAdapterToggleGroup | UIAdapterPanelWidget
function UIBinderUpdateBindableList:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue UIBindableList | table
---@param OldValue UIBindableList | table
function UIBinderUpdateBindableList:OnValueChanged(NewValue, OldValue)
	local _ <close> = CommonUtil.MakeProfileTag(string.format("UIBinderUpdateBindableList:OnValueChanged"))
	self.Widget:UpdateAll(NewValue)
end

return UIBinderUpdateBindableList