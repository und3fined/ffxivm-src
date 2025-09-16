---
--- Author: Administrator
--- DateTime: 2025-02-19 09:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MountCodexNewSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommLight126SlotView
---@field ImgWearable UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountCodexNewSlotView = LuaClass(UIView, true)

function MountCodexNewSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm126Slot = nil
	--self.ImgWearable = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountCodexNewSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountCodexNewSlotView:OnInit()

end

function MountCodexNewSlotView:OnDestroy()

end

function MountCodexNewSlotView:OnShow()

end

function MountCodexNewSlotView:OnHide()

end

function MountCodexNewSlotView:OnRegisterUIEvent()

end

function MountCodexNewSlotView:OnRegisterGameEvent()

end

function MountCodexNewSlotView:OnRegisterBinder()

end

return MountCodexNewSlotView