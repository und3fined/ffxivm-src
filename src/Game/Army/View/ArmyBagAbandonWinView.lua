---
--- Author: Administrator
--- DateTime: 2023-11-22 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyBagAbandonWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BG Comm2FrameMView
---@field BtnAbandon CommBtnLView
---@field BtnCancel CommBtnLView
---@field Slot1 CommBackpackSlotView
---@field TextContent UFTextBlock
---@field TextCount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyBagAbandonWinView = LuaClass(UIView, true)

function ArmyBagAbandonWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BG = nil
	--self.BtnAbandon = nil
	--self.BtnCancel = nil
	--self.Slot1 = nil
	--self.TextContent = nil
	--self.TextCount = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyBagAbandonWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnAbandon)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.Slot1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyBagAbandonWinView:OnInit()

end

function ArmyBagAbandonWinView:OnDestroy()

end

function ArmyBagAbandonWinView:OnShow()

end

function ArmyBagAbandonWinView:OnHide()

end

function ArmyBagAbandonWinView:OnRegisterUIEvent()

end

function ArmyBagAbandonWinView:OnRegisterGameEvent()

end

function ArmyBagAbandonWinView:OnRegisterBinder()

end

return ArmyBagAbandonWinView