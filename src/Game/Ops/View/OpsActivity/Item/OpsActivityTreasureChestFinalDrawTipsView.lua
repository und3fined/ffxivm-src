---
--- Author: yutingzhan
--- DateTime: 2024-11-06 15:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsActivityTreasureChestFinalDrawTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm74Slot CommBackpack74SlotView
---@field TextHint UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityTreasureChestFinalDrawTipsView = LuaClass(UIView, true)

function OpsActivityTreasureChestFinalDrawTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm74Slot = nil
	--self.TextHint = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChestFinalDrawTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChestFinalDrawTipsView:OnInit()

end

function OpsActivityTreasureChestFinalDrawTipsView:OnDestroy()

end

function OpsActivityTreasureChestFinalDrawTipsView:OnShow()

end

function OpsActivityTreasureChestFinalDrawTipsView:OnHide()

end

function OpsActivityTreasureChestFinalDrawTipsView:OnRegisterUIEvent()

end

function OpsActivityTreasureChestFinalDrawTipsView:OnRegisterGameEvent()

end

function OpsActivityTreasureChestFinalDrawTipsView:OnRegisterBinder()

end

return OpsActivityTreasureChestFinalDrawTipsView