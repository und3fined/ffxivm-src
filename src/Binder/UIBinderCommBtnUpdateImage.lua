---
---@Author: ZhengJanChuan
---@Date: 2023-07-20 15:05:32
---@Description: CommBtnLView 修改模式
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderCommBtnUpdateImage : UIBinder
local UIBinderCommBtnUpdateImage = LuaClass(UIBinder)

---Ctor
---@param View UUserWidget
---@param Widget UImage
function UIBinderCommBtnUpdateImage:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderCommBtnUpdateImage:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Opacity = NewValue

	self.Widget:UpdateImage(Opacity)
end

return UIBinderCommBtnUpdateImage