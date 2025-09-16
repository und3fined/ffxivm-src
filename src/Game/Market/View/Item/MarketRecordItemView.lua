---
--- Author: Administrator
--- DateTime: 2023-07-12 11:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class MarketRecordItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClass UFButton
---@field HorizontalPrice UFHorizontalBox
---@field ImgPriceIcon UFImage
---@field ItemSlot CommBackpackSlotView
---@field TextAmount UFTextBlock
---@field TextName UFTextBlock
---@field TextPrice UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketRecordItemView = LuaClass(UIView, true)

function MarketRecordItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClass = nil
	--self.HorizontalPrice = nil
	--self.ImgPriceIcon = nil
	--self.ItemSlot = nil
	--self.TextAmount = nil
	--self.TextName = nil
	--self.TextPrice = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketRecordItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketRecordItemView:OnInit()
	self.Binders = {
		{ "NameText", UIBinderSetText.New(self, self.TextName) },
		{ "PriceText", UIBinderSetTextFormatForMoney.New(self, self.TextPrice) },

		{ "RecordTime", UIBinderSetText.New(self, self.TextTime) },
		{ "ItemNum", UIBinderSetTextFormat.New(self, self.TextAmount, "%d") },
		
	}
end

function MarketRecordItemView:OnDestroy()

end

function MarketRecordItemView:OnShow()

end

function MarketRecordItemView:OnHide()

end

function MarketRecordItemView:OnRegisterUIEvent()

end

function MarketRecordItemView:OnRegisterGameEvent()

end

function MarketRecordItemView:OnRegisterBinder()

	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if nil == self.Binders then return end
	
	self:RegisterBinders(ViewModel, self.Binders)
	self.ItemSlot:SetParams({Data = ViewModel.CommItemSlotVM})

end

return MarketRecordItemView