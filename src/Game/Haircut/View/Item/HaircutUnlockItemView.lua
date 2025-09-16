---
--- Author: jamiyang
--- DateTime: 2024-01-30 09:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HaircutUnlockItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot CommBackpackSlotView
---@field Btn CommBtnXSView
---@field BtnIcon UFButton
---@field Icon UFImage
---@field TextConsume UFTextBlock
---@field TextQuantity URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutUnlockItemView = LuaClass(UIView, true)

function HaircutUnlockItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot = nil
	--self.Btn = nil
	--self.BtnIcon = nil
	--self.Icon = nil
	--self.TextConsume = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutUnlockItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot)
	self:AddSubView(self.Btn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutUnlockItemView:OnInit()
	UIUtil.SetIsVisible(self.BackpackSlot.FImg_Icon, true)
end

function HaircutUnlockItemView:OnDestroy()

end

function HaircutUnlockItemView:OnShow()
	self.TextConsume:SetText(_G.LSTR(1250005)) --"消耗"
	self.Btn.TextContent:SetText(_G.LSTR(1250006)) --"解锁"
end

function HaircutUnlockItemView:OnHide()

end

function HaircutUnlockItemView:OnRegisterUIEvent()

end

function HaircutUnlockItemView:OnRegisterGameEvent()

end

function HaircutUnlockItemView:OnRegisterBinder()

end

return HaircutUnlockItemView