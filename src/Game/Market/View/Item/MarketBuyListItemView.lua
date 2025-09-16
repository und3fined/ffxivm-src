---
--- Author: Administrator
--- DateTime: 2024-06-28 18:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MarketBuyListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBgNormal UFImage
---@field PanelFocus UFCanvasPanel
---@field TextAmount UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextQuantitySold UFTextBlock
---@field TextServerName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketBuyListItemView = LuaClass(UIView, true)

function MarketBuyListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBgNormal = nil
	--self.PanelFocus = nil
	--self.TextAmount = nil
	--self.TextPlayerName = nil
	--self.TextQuantitySold = nil
	--self.TextServerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketBuyListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketBuyListItemView:OnInit()
	self.Binders = {
		{ "PanelFocusVisible", UIBinderSetIsVisible.New(self, self.PanelFocus) },
		{ "AmountText", UIBinderSetTextFormatForMoney.New(self, self.TextAmount) },
		{ "QuantitySoldText", UIBinderSetTextFormat.New(self, self.TextQuantitySold, _G.LSTR(1010045)) },
		{ "ServerNameText", UIBinderSetText.New(self, self.TextServerName) },
		{ "PlayerNameText", UIBinderSetText.New(self, self.TextPlayerName) },
	}
end

function MarketBuyListItemView:OnDestroy()

end

function MarketBuyListItemView:OnShow()

end

function MarketBuyListItemView:OnHide()

end

function MarketBuyListItemView:OnRegisterUIEvent()

end

function MarketBuyListItemView:OnRegisterGameEvent()

end

function MarketBuyListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	if nil == self.Binders then return end
	
	self:RegisterBinders(ViewModel, self.Binders)
end

return MarketBuyListItemView