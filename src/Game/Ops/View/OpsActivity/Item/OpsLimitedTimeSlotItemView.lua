---
--- Author: Administrator
--- DateTime: 2024-12-16 19:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsLimitedTimeSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLimitedTimeSlotItemView = LuaClass(UIView, true)

function OpsLimitedTimeSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLimitedTimeSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLimitedTimeSlotItemView:OnInit()

end

function OpsLimitedTimeSlotItemView:OnDestroy()

end

function OpsLimitedTimeSlotItemView:OnShow()

end

function OpsLimitedTimeSlotItemView:OnHide()

end

function OpsLimitedTimeSlotItemView:OnRegisterUIEvent()

end

function OpsLimitedTimeSlotItemView:OnRegisterGameEvent()

end

function OpsLimitedTimeSlotItemView:OnRegisterBinder()

end

return OpsLimitedTimeSlotItemView