---
--- Author: Administrator
--- DateTime: 2023-12-04 14:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyDepotSlotRecoveryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field IconCancel UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyDepotSlotRecoveryItemView = LuaClass(UIView, true)

function ArmyDepotSlotRecoveryItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.IconCancel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyDepotSlotRecoveryItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyDepotSlotRecoveryItemView:OnInit()

end

function ArmyDepotSlotRecoveryItemView:OnDestroy()

end

function ArmyDepotSlotRecoveryItemView:OnShow()

end

function ArmyDepotSlotRecoveryItemView:OnHide()

end

function ArmyDepotSlotRecoveryItemView:OnRegisterUIEvent()

end

function ArmyDepotSlotRecoveryItemView:OnRegisterGameEvent()

end

function ArmyDepotSlotRecoveryItemView:OnRegisterBinder()

end

return ArmyDepotSlotRecoveryItemView