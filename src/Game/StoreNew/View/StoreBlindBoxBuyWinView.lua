---
--- Author: Administrator
--- DateTime: 2025-07-11 19:22
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local ItemVM = require("Game/Item/ItemVM")
local UIViewID = require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local StoreGoodVM = require("Game/Store/VM/ItemVM/StoreGoodVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local StoreMysteryBoxVM = _G.StoreMysteryBoxVM
local StoreBlindBoxBuyWinVM = _G.StoreBlindBoxBuyWinVM
local SCORE_TYPE = ProtoRes.SCORE_TYPE

---@class StoreBlindBoxBuyWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy CommBtnLView
---@field BtnCoupons UFButton
---@field BtnGift UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field Comm96Slot CommBackpack96SlotView
---@field Commodity StoreCommodityItemView
---@field IconCoupons UFImage
---@field Money1 CommMoneySlotView
---@field PanelCoupons UFCanvasPanel
---@field PanelMoney UFHorizontalBox
---@field PanelOriginalPrice UFCanvasPanel
---@field PanelSlot UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextCoupons UFTextBlock
---@field TextDetails URichTextBox
---@field TextHint UFTextBlock
---@field TextName UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextPrice UFTextBlock
---@field TextSlot UFTextBlock
---@field TextSlotList UFTextBlock
---@field TextType UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreBlindBoxBuyWinView = LuaClass(UIView, true)

function StoreBlindBoxBuyWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnCoupons = nil
	--self.BtnGift = nil
	--self.Comm2FrameM_UIBP = nil
	--self.Comm96Slot = nil
	--self.Commodity = nil
	--self.IconCoupons = nil
	--self.Money1 = nil
	--self.PanelCoupons = nil
	--self.PanelMoney = nil
	--self.PanelOriginalPrice = nil
	--self.PanelSlot = nil
	--self.TableViewSlot = nil
	--self.TextCoupons = nil
	--self.TextDetails = nil
	--self.TextHint = nil
	--self.TextName = nil
	--self.TextOriginalPrice = nil
	--self.TextPrice = nil
	--self.TextSlot = nil
	--self.TextSlotList = nil
	--self.TextType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreBlindBoxBuyWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.Commodity)
	self:AddSubView(self.Money1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreBlindBoxBuyWinView:OnInit()
	self.CommodityVM = StoreGoodVM.New()
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnEquipPartSelectChanged, true, false)

	self.Binders = {
		{ "ItemVMList", UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
		{ "ProductName", UIBinderSetText.New(self, self.TextName) },
		{ "TextHint", UIBinderSetText.New(self, self.TextHint) },
		{ "BuyGoodDesc", UIBinderSetText.New(self, self.TextDetails) },
	}
	self.BuyBinders = {
		{ "CurrentPriceText", UIBinderSetText.New(self, self.TextPrice) },
		{ "OriginalPriceText", UIBinderSetText.New(self, self.TextOriginalPrice) },
		{ "TextName", UIBinderSetText.New(self, self.TextName) },
		{ "OriginalPriceVisible", UIBinderSetIsVisible.New(self, self.PanelOriginalPrice) },
		{ "BuyPriceTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextPrice) },
	}
	self.MysteryBoxItemVM = ItemVM.New({IsCanBeSelected = true, IsShowNum = false, IsShowSelectStatus = false})

end

function StoreBlindBoxBuyWinView:OnDestroy()

end

function StoreBlindBoxBuyWinView:OnShow()
	self.Money1:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, UIViewID.StoreBlindBoxBuyWinPanel, true)

	self.Comm2FrameM_UIBP:SetTitleText(LSTR(StoreDefine.BuyTipTittleText))
	if nil ~= StoreMysteryBoxVM.CurBoxCfgData then
		_G.StoreBlindBoxBuyWinVM:UpdateByMysteryBoxData(StoreMysteryBoxVM.CurBoxCfgData)
	end
	local TempGoodsData = table.deepcopy(StoreMysteryBoxVM.CurBoxCfgData)
	if TempGoodsData == nil then
		return
	end
	TempGoodsData.Icon = TempGoodsData.BuyIcon
	local GoodsData = {Cfg = TempGoodsData}
	self.TextSlotList:SetText(LSTR(950084))		--- 随机获得
	self.TextSlot:SetText(LSTR(950085))	--- 必得
	if TempGoodsData ~= nil and TempGoodsData.PrizePoolID ~= nil then
		local TempRandCfg = CommercializationRandCfg:FindAllCfg(string.format("PrizePoolID=%d and ProbMode=%d", TempGoodsData.PrizePoolID, ProtoRes.PROBABILITY_TYPE.PROBABILITY_TYPE_GUARANTEED))[1]
		UIUtil.SetIsVisible(self.PanelSlot, TempRandCfg ~= nil)
		if TempRandCfg ~= nil then
			--- 没有必掉的奖励时不更新
			self.MysteryBoxItemVM:UpdateVM({ResID = TempRandCfg.DropID})
		end
	end
	self.Comm96Slot:SetParams({Data = self.MysteryBoxItemVM})

	--- 发型盲盒的Item要显示发型的图标，而不是物品图标
	local Items = StoreBlindBoxBuyWinVM.ItemVMList:GetItems()
	if StoreMysteryBoxVM.CurBoxType == ProtoRes.SpecialMysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE then
		for _, value in ipairs(Items) do
			local TempCfg = HairUnlockCfg:FindCfgByItemID(value.ResID)
			if TempCfg ~= nil then
				value:SetIconPath(_G.StoreMysteryBoxMgr:GetHairIconByHairID(TempCfg.HairID))
			end
		end
	end
	self.TextType:SetText(ProtoEnumAlias.GetAlias(ProtoRes.StoreMall, ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX))
	if nil ~= GoodsData then
		self.CommodityVM:UpdateVM({GoodData = GoodsData})
		self.CommodityVM:UpdateDiscount(GoodsData.Cfg.Discount, 1, StoreMysteryBoxVM.IsOnCountTime)
	end
	self.Commodity:SetParams({ Data = self.CommodityVM, bBottomInfoInvisible = true })

	self.BtnBuy:SetBtnName(LSTR(StoreDefine.LSTRTextKey.ConfirmPurchaseText))
	for _, value in ipairs(Items) do
		value:OnSelectedChange(false)
	end

end

function StoreBlindBoxBuyWinView:OnHide()

end

function StoreBlindBoxBuyWinView:OnEquipPartSelectChanged(Index, ItemData, ItemView)
	ItemData.IsSelect = false
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0, Y = 0})
end

function StoreBlindBoxBuyWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnClickBtnBuy)
	UIUtil.AddOnClickedEvent(self, self.Comm96Slot.Btn, self.OnClickMysteryBoxItem)

end

function StoreBlindBoxBuyWinView:OnClickMysteryBoxItem()
	if self.MysteryBoxItemVM.ResID ~= nil then
		ItemTipsUtil.ShowTipsByResID(self.MysteryBoxItemVM.ResID, self.Comm96Slot, {X = 0, Y = 0})
	end
end

function StoreBlindBoxBuyWinView:OnClickBtnBuy()
	_G.StoreMysteryBoxMgr:OwnedEnoughCurrency(StoreMysteryBoxVM.CurBoxCfgData)
end

function StoreBlindBoxBuyWinView:OnRegisterGameEvent()

end

function StoreBlindBoxBuyWinView:OnRegisterBinder()
	self:RegisterBinders(StoreBlindBoxBuyWinVM, self.Binders)
	self:RegisterBinders(StoreMysteryBoxVM, self.BuyBinders)
end

return StoreBlindBoxBuyWinView