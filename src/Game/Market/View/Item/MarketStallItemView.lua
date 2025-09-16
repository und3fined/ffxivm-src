---
--- Author: Administrator
--- DateTime: 2023-05-06 21:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIUtil = require("Utils/UIUtil")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local LocalizationUtil = require("Utils/LocalizationUtil")
local AudioUtil = require("Utils/AudioUtil")
local LSTR = _G.LSTR
---@class MarketStallItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStall UFButton
---@field CommonRedDot_UIBP CommonRedDotView
---@field EffectDecoFocus UFCanvasPanel
---@field HorizontalRetrieve UFHorizontalBox
---@field IconTime UFImage
---@field ImgBg UFImage
---@field ImgHQ UFImage
---@field ImgLock UFImage
---@field ImgRetrieveMoney UFImage
---@field ImgThing UFImage
---@field PanelCommodity UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelLock UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field TextAmount UFTextBlock
---@field TextExpired UFTextBlock
---@field TextName UFTextBlock
---@field TextRelisting UFTextBlock
---@field TextSellAmount UFTextBlock
---@field TextState UFTextBlock
---@field TextTime UFTextBlock
---@field TextWordOnly UFTextBlock
---@field AnimMonthCardUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketStallItemView = LuaClass(UIView, true)

function MarketStallItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStall = nil
	--self.CommonRedDot_UIBP = nil
	--self.EffectDecoFocus = nil
	--self.HorizontalRetrieve = nil
	--self.IconTime = nil
	--self.ImgBg = nil
	--self.ImgHQ = nil
	--self.ImgLock = nil
	--self.ImgRetrieveMoney = nil
	--self.ImgThing = nil
	--self.PanelCommodity = nil
	--self.PanelEmpty = nil
	--self.PanelLock = nil
	--self.PanelTime = nil
	--self.TextAmount = nil
	--self.TextExpired = nil
	--self.TextName = nil
	--self.TextRelisting = nil
	--self.TextSellAmount = nil
	--self.TextState = nil
	--self.TextTime = nil
	--self.TextWordOnly = nil
	--self.AnimMonthCardUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketStallItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketStallItemView:OnInit()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, "dd:hh", "%s", self.TimeOutCallback, self.TimeUpdateCallback)
	self.Binders = {
		{ "CommodityPanelVisible", UIBinderSetIsVisible.New(self, self.PanelCommodity) },
		{ "IdlePanelVisible", UIBinderSetIsVisible.New(self, self.PanelLock) },
		{ "IdleVisible", UIBinderSetIsVisible.New(self, self.PanelEmpty) },
		{ "LockVisible", UIBinderSetIsVisible.New(self, self.ImgLock) },
		{ "IdleInfoText", UIBinderSetText.New(self, self.TextWordOnly) },

		{ "CommodityQuality", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg) },
		{ "Icon", UIBinderSetBrushFromIconID.New(self, self.ImgThing) },
		{ "SellAmountText", UIBinderSetText.New(self, self.TextSellAmount) },
		{ "NameText", UIBinderSetText.New(self, self.TextName) },
		{ "RetrieveVisible", UIBinderSetIsVisible.New(self, self.HorizontalRetrieve) },
		{ "MoneyValue", UIBinderSetItemNumFormat.New(self, self.TextAmount) },
		{ "RelistingText", UIBinderSetText.New(self, self.TextRelisting) },

		{ "HasGetVisible", UIBinderSetIsVisible.New(self, self.EffectDecoFocus) },

		{ "ExpiredTextVisible", UIBinderSetIsVisible.New(self, self.TextExpired) },

		{ "TimePanelVisible", UIBinderSetIsVisible.New(self, self.PanelTime) },
		{ "ShowTimeText", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 1, true, true) },

		{ "RedDotID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRedDotID) },
	}
end

function MarketStallItemView:OnDestroy()

end

function MarketStallItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if ViewModel.PlayUnlockAni then
		self:PlayAnimMonthCardUnlock()
		ViewModel.PlayUnlockAni = nil
	end
end

function MarketStallItemView:OnHide()

end

function MarketStallItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnStall, self.OnClickButtonItem)
end

function MarketStallItemView:OnRegisterGameEvent()

end

function MarketStallItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if nil == self.Binders then return end
	
	self:RegisterBinders(ViewModel, self.Binders)

	self.TextState:SetText(LSTR(1010092))
	--self.TextRelisting:SetText(LSTR(1010093))
	self.TextExpired:SetText(LSTR(1010094))
end

function MarketStallItemView:TimeOutCallback()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end
	ViewModel:SetStallExpiredSold()
end

function MarketStallItemView:TimeUpdateCallback(LeftTime)
	return LocalizationUtil.GetCountdownTimeForSimpleTime(LeftTime, "")
end

function MarketStallItemView:OnValueChangedRedDotID(ID)
	self.CommonRedDot_UIBP:SetRedDotIDByID(ID)
end

function MarketStallItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)

	local ViewModel = Params.Data
	if ViewModel.HasGetVisible then
		local path = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/SYS/Play_SE_UI_gillfix.Play_SE_UI_gillfix'"
		AudioUtil.LoadAndPlay2DSound(path)
		local MainView = self.ParentView.ParentView
		local Fun = MainView.PlayAnimSum
		if Fun ~= nil then
			Fun(MainView)
		end
	end
end

function MarketStallItemView:PlayAnimMonthCardUnlock()
	self:PlayAnimation(self.AnimMonthCardUnlock)
end

return MarketStallItemView