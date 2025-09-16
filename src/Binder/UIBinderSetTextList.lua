---
--- Author: frankjfwang
--- DateTime: 2021-05-16 21:26
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetTextList : UIBinder
local UIBinderSetTextList = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UCanvasPanel
function UIBinderSetTextList:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue string[]
---@param OldValue string[]
function UIBinderSetTextList:OnValueChanged(NewValue, OldValue)
	local Children = self.Widget:GetAllChildren()
	if nil == Children then
		return
	end

	for i = 1, Children:Length() do
		local TextWidget = Children:Get(i)
		if TextWidget then
			UIUtil.SetIsVisible(TextWidget, false)
		end
	end

	if not _G.table.is_array(NewValue) or type(NewValue[1]) ~= 'string' then
		return
	end

	for i = 1, math.min(#NewValue, Children:Length()) do
		local TextWidget = Children:Get(i)
		if TextWidget then
			UIUtil.SetIsVisible(TextWidget, true)
			TextWidget:SetText(NewValue[i])
		end
	end
end

return UIBinderSetTextList