
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class StorePropsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CurrentPrice StorePropsCurrentPriceItemView
---@field HorizontalLimitation UFHorizontalBox
---@field HorizontalPrice UFHorizontalBox
---@field HorizontalSpecail UFHorizontalBox
---@field ImgBar UFImage
---@field ImgDeadline UFImage
---@field ImgGoods UFImage
---@field ImgMask UFImage
---@field ImgQuality UFImage
---@field Item01 StorePropsCurrentPriceItemView
---@field Item02 StorePropsCurrentPriceItemView
---@field Item03 StorePropsCurrentPriceItemView
---@field PanelBan UFCanvasPanel
---@field PanelDeadline UFCanvasPanel
---@field PanelDiscount UFCanvasPanel
---@field PanelHQ UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field TextAmount UFTextBlock
---@field TextDeadline UFTextBlock
---@field TextDiscount UFTextBlock
---@field TextItemName UFTextBlock
---@field TextLimitation UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextTips UFTextBlock
---@field VerticalBoxInfo UFVerticalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StorePropsItemView = LuaClass(UIView, true)

function StorePropsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CurrentPrice = nil
	--self.HorizontalLimitation = nil
	--self.HorizontalPrice = nil
	--self.HorizontalSpecail = nil
	--self.ImgBar = nil
	--self.ImgDeadline = nil
	--self.ImgGoods = nil
	--self.ImgMask = nil
	--self.ImgQuality = nil
	--self.Item01 = nil
	--self.Item02 = nil
	--self.Item03 = nil
	--self.PanelBan = nil
	--self.PanelDeadline = nil
	--self.PanelDiscount = nil
	--self.PanelHQ = nil
	--self.PanelOriginal = nil
	--self.TextAmount = nil
	--self.TextDeadline = nil
	--self.TextDiscount = nil
	--self.TextItemName = nil
	--self.TextLimitation = nil
	--self.TextOriginalPrice = nil
	--self.TextTips = nil
	--self.VerticalBoxInfo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StorePropsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CurrentPrice)
	self:AddSubView(self.Item01)
	self:AddSubView(self.Item02)
	self:AddSubView(self.Item03)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StorePropsItemView:OnInit()
	self.Binders = {
		{ "PropsGoodsBG", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "PropsGoodsIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgGoods) },
		{ "PropsNameText", UIBinderSetText.New(self, self.TextItemName) },
		{ "OriginalPriceText", UIBinderSetText.New(self, self.TextOriginalPrice) },
		{ "DiscountText", UIBinderSetText.New(self, self.TextDiscount) },
		{ "DeadlineText", UIBinderSetText.New(self, self.TextDeadline) },
		{ "LimitationText", UIBinderSetText.New(self, self.TextLimitation) },
		{ "LimitPanelVisible", UIBinderSetIsVisible.New(self, self.HorizontalLimitation) },
		{ "AmountText", UIBinderSetText.New(self, self.TextAmount) },
		{ "PanelDiscountVisible", UIBinderSetIsVisible.New(self, self.PanelDiscount) },
		{ "PanelOriginalVisible", UIBinderSetIsVisible.New(self, self.PanelOriginal) },
		{ "PanelDeadlineVisible", UIBinderSetIsVisible.New(self, self.PanelDeadline) },
		{ "PanelBanVisible", UIBinderSetIsVisible.New(self, self.PanelBan) },
		{ "TipsText", UIBinderSetText.New(self, self.TextTips) },
		{ "HorizontalSpecailVisible", UIBinderSetIsVisible.New(self, self.HorizontalSpecail) },
		{ "HorizontalPriceVisible", UIBinderSetIsVisible.New(self, self.HorizontalPrice) },
		{ "HQPanelVisible", UIBinderSetIsVisible.New(self, self.PanelHQ) },
		{ "HotSaleVisible", UIBinderSetIsVisible.New(self, self.PanelHotSale) },
		
		{ "PriceVisibleItem01", UIBinderSetIsVisible.New(self, self.Item01) },
		{ "PriceVisibleItem02", UIBinderSetIsVisible.New(self, self.Item02) },
		{ "PriceVisibleItem03", UIBinderSetIsVisible.New(self, self.Item03) },
		{ "PropsPriceType", UIBinderSetBrushFromAssetPath.New(self, self.CurrentPrice.ImgMoney) },
		{ "CurrentPriceText", UIBinderSetText.New(self, self.CurrentPrice.TextCurrentPrice) },
		{ "PropsPriceTypeItem01", UIBinderSetBrushFromAssetPath.New(self, self.Item01.ImgMoney) },
		{ "CurrentPriceTextItem01", UIBinderSetText.New(self, self.Item01.TextCurrentPrice) },
		{ "PropsPriceTypeItem02", UIBinderSetBrushFromAssetPath.New(self, self.Item02.ImgMoney) },
		{ "CurrentPriceTextItem02", UIBinderSetText.New(self, self.Item02.TextCurrentPrice) },
		{ "PropsPriceTypeItem03", UIBinderSetBrushFromAssetPath.New(self, self.Item03.ImgMoney) },
		{ "CurrentPriceTextItem03", UIBinderSetText.New(self, self.Item03.TextCurrentPrice) },
	}
end

function StorePropsItemView:OnDestroy()

end

function StorePropsItemView:OnShow()
	UIUtil.SetIsVisible(self.PanelItem, true, true)
end

function StorePropsItemView:OnHide()

end

function StorePropsItemView:OnRegisterUIEvent()

end

function StorePropsItemView:OnRegisterGameEvent()

end

function StorePropsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return StorePropsItemView