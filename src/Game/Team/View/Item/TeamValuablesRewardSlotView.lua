---
--- Author: Administrator
--- DateTime: 2025-03-07 10:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class TeamValuablesRewardSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamValuablesRewardSlotView = LuaClass(UIView, true)

function TeamValuablesRewardSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamValuablesRewardSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamValuablesRewardSlotView:OnInit()

end

function TeamValuablesRewardSlotView:OnDestroy()

end

function TeamValuablesRewardSlotView:OnShow()
	self.TextName:SetText(self.Params.Data.Name)
end

function TeamValuablesRewardSlotView:OnHide()

end

function TeamValuablesRewardSlotView:OnRegisterUIEvent()

end

function TeamValuablesRewardSlotView:OnRegisterGameEvent()

end

function TeamValuablesRewardSlotView:OnRegisterBinder()

end

return TeamValuablesRewardSlotView