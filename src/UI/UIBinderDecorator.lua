--
-- Author: anypkvcai
-- Date: 2022-10-26 10:33
-- Description:
--

local LuaClass = require("Core/LuaClass")

local UIBinderDecorator = LuaClass()

function UIBinderDecorator:Ctor(UIBinder)
	self.UIBinder = UIBinder
end

function UIBinderDecorator:OnValueChanged(NewValue, OldValue)
	self.UIBinder:OnValueChanged(NewValue, OldValue)
end

return UIBinderDecorator
