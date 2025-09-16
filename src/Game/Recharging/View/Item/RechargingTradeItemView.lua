---
--- Author: zimuyi
--- DateTime: 2024-01-22 18:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR
local RechargingMgr = require("Game/Recharging/RechargingMgr")

---@class RechargingTradeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field EFF_1 UFCanvasPanel
---@field EFF_2 UFCanvasPanel
---@field EFF_3 UFCanvasPanel
---@field EFF_4 UFCanvasPanel
---@field EFF_5 UFCanvasPanel
---@field EFF_6 UFCanvasPanel
---@field ImgCrystal UFImage
---@field ImgCrystalIcon UFImage
---@field PanelCount UFCanvasPanel
---@field PanelGive UFCanvasPanel
---@field RichTextNum URichTextBox
---@field TextGiveNum UFTextBlock
---@field TextGiveTIps UFTextBlock
---@field TextItemNum UFTextBlock
---@field TextMoney UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLight1 UWidgetAnimation
---@field AnimLight2 UWidgetAnimation
---@field AnimLight3 UWidgetAnimation
---@field AnimLight4 UWidgetAnimation
---@field AnimLight5 UWidgetAnimation
---@field AnimLight6 UWidgetAnimation
---@field AnimLight7 UWidgetAnimation
---@field AnimLight8 UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field TEMPIndex string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingTradeItemView = LuaClass(UIView, true)

function RechargingTradeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.EFF_1 = nil
	--self.EFF_2 = nil
	--self.EFF_3 = nil
	--self.EFF_4 = nil
	--self.EFF_5 = nil
	--self.EFF_6 = nil
	--self.ImgCrystal = nil
	--self.ImgCrystalIcon = nil
	--self.PanelCount = nil
	--self.PanelGive = nil
	--self.RichTextNum = nil
	--self.TextGiveNum = nil
	--self.TextGiveTIps = nil
	--self.TextItemNum = nil
	--self.TextMoney = nil
	--self.AnimIn = nil
	--self.AnimLight1 = nil
	--self.AnimLight2 = nil
	--self.AnimLight3 = nil
	--self.AnimLight4 = nil
	--self.AnimLight5 = nil
	--self.AnimLight6 = nil
	--self.AnimLight7 = nil
	--self.AnimLight8 = nil
	--self.AnimOut = nil
	--self.TEMPIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingTradeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingTradeItemView:OnInit()
	self.ViewModel = nil
end

function RechargingTradeItemView:OnDestroy()

end

function RechargingTradeItemView:OnShow()

end

function RechargingTradeItemView:OnHide()

end

function RechargingTradeItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnItemClicked)
end

function RechargingTradeItemView:OnRegisterGameEvent()

end

function RechargingTradeItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgCrystal) },
		{ "Order", UIBinderValueChangedCallback.New(self, nil, self.OnOrderChanged) },
		{ "CrystasFormatted", UIBinderSetTextFormat.New(self, self.TextItemNum, LSTR(940013)) },
		{ "BonusFormatted", UIBinderSetTextFormat.New(self, self.TextGiveNum, LSTR(940013)) },
		{ "PhysicalCurrency", UIBinderSetTextFormat.New(self, self.TextMoney, "￥%d") },
		-- { "BonusRate", UIBinderSetTextFormat.New(self, self.RichTextNum, "<span size=\"16\">+</>%d<span size=\"14\">%%</>") },
		-- { "DoDisplayBonusRate", UIBinderSetIsVisible.New(self, self.PanelCount) },
		{ "DoDisplayBonusRate", UIBinderSetIsVisible.New(self, self.PanelGive) },
		{ "BonusTips", UIBinderSetText.New(self, self.TextGiveTIps) },
	}

	self:RegisterBinders(ViewModel, Binders)
	self.ViewModel = ViewModel
end

function RechargingTradeItemView:OnItemClicked()
	local RechargingUtil = require("Game/Recharging/RechargingUtil")
	local UIViewMgr = require("UI/UIViewMgr")
	local Cost = RechargingUtil.Crystas2PhysicalCurrency(self.ViewModel.Crystas)
	--检查优惠券数量和优惠券开关
	if RechargingMgr:CheckCanUseVoucher() then
		local IsEnough = RechargingMgr:CheckVoucherIsEnough(Cost)
		--代金券不足弹tips return
		if not IsEnough then return end
		local Params = {
			ProductID = self.ViewModel.ProductID,
			CostInfo =  math.ceil(Cost)
		}
		UIViewMgr:ShowView(UIViewID.RechargingVoucherWin,Params)
	else
		RechargingMgr:Recharge(self.ViewModel.Order, self.ViewModel.Crystas, self.ViewModel.Bonus, self)
	end
end

function RechargingTradeItemView:OnOrderChanged(Order)
	local EffStr = string.format("EFF_%d", Order)
	UIUtil.SetIsVisible(self[EffStr], true)
end

return RechargingTradeItemView