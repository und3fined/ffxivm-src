--
-- Author: anypkvcai
-- Date: 2022-10-26 10:33
-- Description: Binder装饰器 可以把一个Binder和函数组成一个新的Binder
-- 例如：UIBinderSetRaceName 也可以通过UIBinderDecoratorFilter实现
-- UIBinderDecoratorFilter.New(UIBinderSetText.New(self, self.Text), RaceCfg.GetRaceName, RaceCfg)

local LuaClass = require("Core/LuaClass")

local UIBinderDecorator = require("UI/UIBinderDecorator")

local UIBinderDecoratorFilter = LuaClass(UIBinderDecorator)

---Ctor
---@param UIBinder UIBinder
---@param Filter function
---@param Object table
---@param Params any
function UIBinderDecoratorFilter:Ctor(UIBinder, Filter, Object, Params)
	self.Filter = Filter
	self.Object = Object
	self.Params = Params
end

function UIBinderDecoratorFilter:OnValueChanged(NewValue, OldValue)
	if nil ~= self.Object then
		NewValue, OldValue = self.Filter(self.Object, NewValue, self.Params)
	else
		NewValue, OldValue = self.Filter(NewValue, self.Params)
	end

	self.UIBinder:OnValueChanged(NewValue, OldValue)
end

return UIBinderDecoratorFilter