---
--- Author: Administrator
--- DateTime: 2023-05-09 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class MarketMarketPriceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock_34 UFTextBlock
---@field TextPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketMarketPriceItemView = LuaClass(UIView, true)

function MarketMarketPriceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock_34 = nil
	--self.TextPrice = nil
		--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketMarketPriceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
		--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketMarketPriceItemView:OnInit()
	self.Binders = {
		{ "SellPriceText", UIBinderSetTextFormatForMoney.New(self, self.TextPrice) },
		{ "SellNumText", UIBinderSetText.New(self, self.FTextBlock_34) },
	}
end

function MarketMarketPriceItemView:OnDestroy()

end

function MarketMarketPriceItemView:OnShow()
end

function MarketMarketPriceItemView:OnHide()

end

function MarketMarketPriceItemView:OnRegisterUIEvent()
end

function MarketMarketPriceItemView:OnRegisterGameEvent()

end

function MarketMarketPriceItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end


	if nil == self.Binders then return end
	
	self:RegisterBinders(ViewModel, self.Binders)
end


return MarketMarketPriceItemView