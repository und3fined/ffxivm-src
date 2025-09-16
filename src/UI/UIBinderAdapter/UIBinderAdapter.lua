local LuaClass = require("Core/LuaClass")

local UIBinderAdapter = LuaClass()

function UIBinderAdapter:Ctor(UIBinder)
    self.UIBinder = UIBinder
end

function UIBinderAdapter:OnValueChanged(NewValue, OldValue)
    self.UIBinder:OnValueChanged(NewValue, OldValue)
end

return UIBinderAdapter
