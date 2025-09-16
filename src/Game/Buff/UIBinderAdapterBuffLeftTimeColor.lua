local LuaClass = require("Core/LuaClass")

local UIBinderAdapter = require("UI/UIBinderAdapter/UIBinderAdapter")
local BuffDefine = require("Game/Buff/BuffDefine")

local UIBinderAdapterBuffLeftTimeColor = LuaClass(UIBinderAdapter)

function UIBinderAdapterBuffLeftTimeColor:OnValueChanged(NewValue, OldValue)
    local Color = NewValue and BuffDefine.LeftTimeColor.FromMajor or BuffDefine.LeftTimeColor.FromOther
    self.UIBinder:OnValueChanged(Color, "000000ff")
end

return UIBinderAdapterBuffLeftTimeColor
