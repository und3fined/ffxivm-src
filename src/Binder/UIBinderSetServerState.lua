---
--- Author: richyczhou
--- DateTime: 2024-11-2 19:02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetServerState : UIBinder
local UIBinderSetServerState = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetServerState:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetServerState:OnValueChanged(NewValue, OldValue)
	if NewValue then
	    UIUtil.ImageSetBrushFromAssetPath(self.Widget, LoginNewDefine.ServerStateConfigMap[NewValue].Icon)
	end
end

return UIBinderSetServerState