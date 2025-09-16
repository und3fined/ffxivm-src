--
-- Author: anypkvcai
-- Date: 2020-08-05 15:43:32
-- Description: UI绑定器
-- 		UIBindableProperty值改变时，会调用UIBinder的OnValueChanged函数，UIBinder在OnValueChanged函数里修改Widget的属性。
-- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=858300367

---@class UIBinder
local UIBinder = {}

---Ctor
---@param View UIView
---@param Widget UUserWidget | UWidget | UIView
function UIBinder:Ctor(View, Widget)
	self.View = View
	self.Widget = Widget
end

---OnValueChanged
---@param NewValue any
---@param OldValue any
function UIBinder:OnValueChanged(NewValue, OldValue)

end

return UIBinder