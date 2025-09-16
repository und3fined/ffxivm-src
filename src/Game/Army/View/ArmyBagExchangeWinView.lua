---
--- Author: Administrator
--- DateTime: 2023-11-22 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyBagExchangeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field Btnsure CommBtnLView
---@field RichTextDiscribe URichTextBox
---@field Slot1 CommBackpackSlotView
---@field Slot2 CommBackpackSlotView
---@field TextContent UFTextBlock
---@field TextContent2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyBagExchangeWinView = LuaClass(UIView, true)

function ArmyBagExchangeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.Btnsure = nil
	--self.RichTextDiscribe = nil
	--self.Slot1 = nil
	--self.Slot2 = nil
	--self.TextContent = nil
	--self.TextContent2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyBagExchangeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.Btnsure)
	self:AddSubView(self.Slot1)
	self:AddSubView(self.Slot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyBagExchangeWinView:OnInit()

end

function ArmyBagExchangeWinView:OnDestroy()

end

function ArmyBagExchangeWinView:OnShow()

end

function ArmyBagExchangeWinView:OnHide()

end

function ArmyBagExchangeWinView:OnRegisterUIEvent()

end

function ArmyBagExchangeWinView:OnRegisterGameEvent()

end

function ArmyBagExchangeWinView:OnRegisterBinder()

end

return ArmyBagExchangeWinView