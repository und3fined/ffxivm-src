---
--- Author: muyanli
--- DateTime: 2025-05-30 20:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HouseLandPurchaseLotteryResultsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommBackpack126SlotView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TextSlot UFTextBlock
---@field TextSlot_1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandPurchaseLotteryResultsWinView = LuaClass(UIView, true)

function HouseLandPurchaseLotteryResultsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm126Slot = nil
	--self.Comm2FrameM_UIBP = nil
	--self.TextSlot = nil
	--self.TextSlot_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseLotteryResultsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseLotteryResultsWinView:OnInit()

end

function HouseLandPurchaseLotteryResultsWinView:OnDestroy()

end

function HouseLandPurchaseLotteryResultsWinView:OnShow()

end

function HouseLandPurchaseLotteryResultsWinView:OnHide()

end

function HouseLandPurchaseLotteryResultsWinView:OnRegisterUIEvent()

end

function HouseLandPurchaseLotteryResultsWinView:OnRegisterGameEvent()

end

function HouseLandPurchaseLotteryResultsWinView:OnRegisterBinder()

end

return HouseLandPurchaseLotteryResultsWinView