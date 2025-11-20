---
--- Author: Administrator
--- DateTime: 2025-06-25 17:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsLimitedTimeSlotItem02View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLimitedTimeSlotItem02View = LuaClass(UIView, true)

function OpsLimitedTimeSlotItem02View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLimitedTimeSlotItem02View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLimitedTimeSlotItem02View:OnInit()

end

function OpsLimitedTimeSlotItem02View:OnDestroy()

end

function OpsLimitedTimeSlotItem02View:OnShow()

end

function OpsLimitedTimeSlotItem02View:OnHide()

end

function OpsLimitedTimeSlotItem02View:OnRegisterUIEvent()

end

function OpsLimitedTimeSlotItem02View:OnRegisterGameEvent()

end

function OpsLimitedTimeSlotItem02View:OnRegisterBinder()

end

return OpsLimitedTimeSlotItem02View