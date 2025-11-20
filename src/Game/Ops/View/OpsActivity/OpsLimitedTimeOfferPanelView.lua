---
--- Author: Administrator
--- DateTime: 2024-12-09 10:38
--- Description:
---

local LuaClass = require("Core/LuaClass")
local OpsLimitedTimeOfferBaseView = require("Game/Ops/View/OpsActivity/OpsLimitedTimeOfferBaseView")

---@class OpsLimitedTimeOfferPanelView : OpsLimitedTimeOfferBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy OpsCommBtnLView
---@field Money CommMoneySlotView
---@field PreviewBtn OpsActivityPreviewBtnView
---@field ShareTips OpsActivityShareTipsItemView
---@field TableView_33 UTableView
---@field TextDiscount UFTextBlock
---@field TextInfo URichTextBox
---@field TextLimitedTimeOffer UFTextBlock
---@field TextPreview UFTextBlock
---@field TextPrice UFTextBlock
---@field TextUnit UFTextBlock
---@field Time OpsActivityTimeItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLimitedTimeOfferPanelView = LuaClass(OpsLimitedTimeOfferBaseView, true)

function OpsLimitedTimeOfferPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.Money = nil
	--self.PreviewBtn = nil
	--self.ShareTips = nil
	--self.TableView_33 = nil
	--self.TextDiscount = nil
	--self.TextInfo = nil
	--self.TextLimitedTimeOffer = nil
	--self.TextPreview = nil
	--self.TextPrice = nil
	--self.TextUnit = nil
	--self.Time = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLimitedTimeOfferPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.Money)
	self:AddSubView(self.PreviewBtn)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

return OpsLimitedTimeOfferPanelView