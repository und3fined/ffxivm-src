---
--- Author: Administrator
--- DateTime: 2023-11-30 14:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class BuddyUseAccelerate02WinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BtnCancel CommBtnLView
---@field Btnaccelerate CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommSlot CommBackpackSlotView
---@field PanelHighest UFCanvasPanel
---@field ProbarOrange UProgressBar
---@field ProbarYellow UProgressBar
---@field TextAccelerateCountDown UFTextBlock
---@field TextCount UFTextBlock
---@field TextSlotName UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyUseAccelerate02WinView = LuaClass(UIView, true)

function BuddyUseAccelerate02WinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BtnCancel = nil
	--self.Btnaccelerate = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommSlot = nil
	--self.PanelHighest = nil
	--self.ProbarOrange = nil
	--self.ProbarYellow = nil
	--self.TextAccelerateCountDown = nil
	--self.TextCount = nil
	--self.TextSlotName = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyUseAccelerate02WinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.Btnaccelerate)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyUseAccelerate02WinView:OnInit()

end

function BuddyUseAccelerate02WinView:OnDestroy()

end

function BuddyUseAccelerate02WinView:OnShow()

end

function BuddyUseAccelerate02WinView:OnHide()

end

function BuddyUseAccelerate02WinView:OnRegisterUIEvent()

end

function BuddyUseAccelerate02WinView:OnRegisterGameEvent()

end

function BuddyUseAccelerate02WinView:OnRegisterBinder()

end

return BuddyUseAccelerate02WinView