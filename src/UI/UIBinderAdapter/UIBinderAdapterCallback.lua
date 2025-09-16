local LuaClass = require("Core/LuaClass")

local UIBinderAdapter = require("UI/UIBinderAdapter/UIBinderAdapter")

local UIBinderAdapterCallback = LuaClass(UIBinderAdapter)

function UIBinderAdapterCallback:Ctor(UIBinder, Callback)
    self.Callback = Callback
end

function UIBinderAdapterCallback:OnValueChanged(NewValue, OldValue)
    NewValue, OldValue = self.Callback(NewValue, OldValue)
    self.UIBinder:OnValueChanged(NewValue, OldValue)
end

return UIBinderAdapterCallback
