---
--- Author: Administrator
--- DateTime: 2024-06-24 14:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class MarketPurchaseWindowItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field BtnPreview UFButton
---@field CollectBtn UFButton
---@field IconCollectFocus UFImage
---@field IconCollectNormal UFImage
---@field ImgBG UFImage
---@field ImgHQ UFImage
---@field ImgPreview UFImage
---@field ImgThing UFImage
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketPurchaseWindowItemView = LuaClass(UIView, true)

function MarketPurchaseWindowItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.BtnPreview = nil
	--self.CollectBtn = nil
	--self.IconCollectFocus = nil
	--self.IconCollectNormal = nil
	--self.ImgBG = nil
	--self.ImgHQ = nil
	--self.ImgPreview = nil
	--self.ImgThing = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketPurchaseWindowItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketPurchaseWindowItemView:OnInit()
	self.Binders = {
		{ "CommodityQuality", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG) },
		{ "HQVisible", UIBinderSetIsVisible.New(self, self.ImgHQ)},
		{ "HQColor", UIBinderSetBrushFromAssetPath.New(self, self.ImgHQ) },
		{ "Icon", UIBinderSetBrushFromIconID.New(self, self.ImgThing) },
		{ "QuantityText", UIBinderSetText.New(self, self.TextQuantity) },
		{ "CollectVisible", UIBinderSetIsVisible.New(self, self.IconCollectNormal) },
		{ "CollectBtnVisible", UIBinderSetIsVisible.New(self, self.CollectBtn, false, true) },
		{ "CollectSelectedVisible", UIBinderSetIsVisible.New(self, self.IconCollectFocus) },
		
		{ "PreviewBtnVisible", UIBinderSetIsVisible.New(self, self.BtnPreview, false, true) },
	}
end

function MarketPurchaseWindowItemView:OnDestroy()

end

function MarketPurchaseWindowItemView:OnShow()

end

function MarketPurchaseWindowItemView:OnHide()

end

function MarketPurchaseWindowItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedHandle)
	UIUtil.AddOnClickedEvent(self, self.CollectBtn, self.OnClickedCollect)
	UIUtil.AddOnClickedEvent(self, self.BtnPreview, self.OnClickedPreview)
end

function MarketPurchaseWindowItemView:OnRegisterGameEvent()

end

function MarketPurchaseWindowItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if nil == self.Binders then return end
	
	self:RegisterBinders(ViewModel, self.Binders)
end

function MarketPurchaseWindowItemView:OnClickedHandle()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if ViewModel.ResID and ViewModel.ResID > 0 then
		ItemTipsUtil.ShowTipsByResID(ViewModel.ResID, self.ImgBG)
	end
end

function MarketPurchaseWindowItemView:OnClickedCollect()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel:OnClickedCollect()
end

function MarketPurchaseWindowItemView:OnClickedPreview()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if ViewModel.ResID and ViewModel.ResID > 0 then
		_G.PreviewMgr:OpenPreviewView(ViewModel.ResID)
	end
end

return MarketPurchaseWindowItemView