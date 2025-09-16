---
--- Author: Administrator
--- DateTime: 2024-03-01 16:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NewMapPropsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack74Slot CommBackpack74SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewMapPropsItemView = LuaClass(UIView, true)

function NewMapPropsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack74Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewMapPropsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewMapPropsItemView:OnInit()

end

function NewMapPropsItemView:OnDestroy()

end

function NewMapPropsItemView:OnShow()

end

function NewMapPropsItemView:OnHide()

end

function NewMapPropsItemView:OnRegisterUIEvent()

end

function NewMapPropsItemView:OnRegisterGameEvent()

end

function NewMapPropsItemView:OnRegisterBinder()

end

return NewMapPropsItemView