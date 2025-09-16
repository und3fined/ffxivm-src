--
-- Author: v_hggzhang
-- Date: 2023-08-01 15:45:51
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetIsDone : UIBinder
local UIBinderSetIsDone = LuaClass(UIBinder)

---Ctor 参数列表: CommBtn:DoneText
---@param View UIView
---@param Widget UUserWidget
---@param ... 参数列表
function UIBinderSetIsDone:Ctor(View, Widget, ...)
	self.Params = table.pack(...)
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsDone:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if type(NewValue) == "number" then
		NewValue = NewValue ~= 0
	end

	local IsDone = NewValue

	if self.Widget.SetIsDone then
		self.Widget:SetIsDone(IsDone, table.unpack(self.Params))
	end
end

return UIBinderSetIsDone