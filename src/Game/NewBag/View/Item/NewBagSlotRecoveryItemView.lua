---
--- Author: Administrator
--- DateTime: 2023-09-28 15:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NewBagSlotRecoveryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field IconCancel UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagSlotRecoveryItemView = LuaClass(UIView, true)

function NewBagSlotRecoveryItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.IconCancel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagSlotRecoveryItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagSlotRecoveryItemView:OnInit()

end

function NewBagSlotRecoveryItemView:OnDestroy()

end

function NewBagSlotRecoveryItemView:OnShow()

end

function NewBagSlotRecoveryItemView:OnHide()

end

function NewBagSlotRecoveryItemView:OnRegisterUIEvent()
end

function NewBagSlotRecoveryItemView:OnRegisterGameEvent()

end

function NewBagSlotRecoveryItemView:OnRegisterBinder()

end

return NewBagSlotRecoveryItemView