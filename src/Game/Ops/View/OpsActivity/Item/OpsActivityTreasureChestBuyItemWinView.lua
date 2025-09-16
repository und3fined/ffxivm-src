---
--- Author: yutingzhan
--- DateTime: 2024-11-07 10:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local OpsActivityTreasureChestBuyItemWinVM = require("Game/Ops/VM/OpsActivityTreasureChestBuyItemWinVM")
local OpsActivityTreasureChestPanelVM = require("Game/Ops/VM/OpsActivityTreasureChestPanelVM")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local TimeUtil = require("Utils/TimeUtil")

local LSTR = _G.LSTR

---@class OpsActivityTreasureChestBuyItemWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BtnBuyConfirm CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnGift CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommSlot CommBackpack126SlotView
---@field HorizontalCurrent1 UFHorizontalBox
---@field ImgMoney1 UFImage
---@field PanelBuySetting UFCanvasPanel
---@field RichTextBox_43 URichTextBox
---@field SlotFreebies CommBackpack126SlotView
---@field TextAmount UFTextBlock
---@field TextCurrentPrice1 UFTextBlock
---@field TextFreebiesName UFTextBlock
---@field TextGift UFTextBlock
---@field TextSlotName1 UFTextBlock
---@field TextSurplus URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityTreasureChestBuyItemWinView = LuaClass(UIView, true)

function OpsActivityTreasureChestBuyItemWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BtnBuyConfirm = nil
	--self.BtnCancel = nil
	--self.BtnGift = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommSlot = nil
	--self.HorizontalCurrent1 = nil
	--self.ImgMoney1 = nil
	--self.PanelBuySetting = nil
	--self.RichTextBox_43 = nil
	--self.SlotFreebies = nil
	--self.TextAmount = nil
	--self.TextCurrentPrice1 = nil
	--self.TextFreebiesName = nil
	--self.TextGift = nil
	--self.TextSlotName1 = nil
	--self.TextSurplus = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChestBuyItemWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BtnBuyConfirm)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnGift)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommSlot)
	self:AddSubView(self.SlotFreebies)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChestBuyItemWinView:OnInit()
	UIUtil.SetIsVisible(self.CommSlot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.SlotFreebies.RichTextLevel, false)
	UIUtil.SetIsVisible(self.CommSlot.IconChoose, false)
	UIUtil.SetIsVisible(self.SlotFreebies.IconChoose, false)
	UIUtil.SetIsVisible(self.BtnGift, false)
	UIUtil.SetIsVisible(self.BtnCancel, true)
	self.ViewModel = OpsActivityTreasureChestBuyItemWinVM.New()
	self.Binders = {
		{ "FreeImgQuality", UIBinderSetBrushFromAssetPath.New(self, self.SlotFreebies.ImgQuanlity) },
		{ "FreeImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.SlotFreebies.Icon) },
		{ "FreeSlotNum", UIBinderSetText.New(self, self.SlotFreebies.RichTextQuantity) },
		{ "FreeSlotName", UIBinderSetText.New(self, self.TextFreebiesName) },
		{ "PropsImgQuality", UIBinderSetBrushFromAssetPath.New(self, self.CommSlot.ImgQuanlity) },
		{ "PropsImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.CommSlot.Icon) },
		{ "PropsSlotNum", UIBinderSetText.New(self, self.CommSlot.RichTextQuantity) },
		{ "PropsSlotName", UIBinderSetText.New(self, self.TextSlotName1) },
		{ "PurchaseAmount", UIBinderSetText.New(self, self.TextAmount) },
		{ "PurchaseNumDesc", UIBinderSetText.New(self, self.TextSurplus) },
		{ "RemainPurchaseAmount", UIBinderSetText.New(self, self.AmountSlider.TextMax) },
		{ "Price", UIBinderSetText.New(self, self.TextCurrentPrice1) },
		{ "Title", UIBinderSetText.New(self, self.Comm2FrameM_UIBP.FText_Title) },
		{ "PriceColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCurrentPrice1) },
		{ "PurchaseDesc", UIBinderSetText.New(self, self.RichTextBox_43) },
	}
end

function OpsActivityTreasureChestBuyItemWinView:OnDestroy()

end

function OpsActivityTreasureChestBuyItemWinView:OnShow()
    self.BtnCancel.TextContent:SetText(LSTR(10003))
	self.BtnBuyConfirm.TextContent:SetText(LSTR(100027))
	self.AmountSlider:SetSliderValueMaxTips(LSTR(100028))
	self.AmountSlider:SetSliderValueMinTips(LSTR(100029))
	self.TextGift:SetText(LSTR(100068))

	self.ViewModel:SetTreasureChestBuyWinInfo()
	self.ViewModel:UpdateTreasureChestBuyWinInfo()
	self.CommSlot:SetClickButtonCallback(self, function()
		ItemTipsUtil.ShowTipsByResID(self.ViewModel.PropsSlotResID, self.CommSlot)
	end)
	self.SlotFreebies:SetClickButtonCallback(self, function()
		ItemTipsUtil.ShowTipsByResID(self.ViewModel.FreeSlotResID, self.SlotFreebies)
	end)
	self.AmountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedAmountCountSlider(v)
	end)
	self.AmountSlider:SetSliderValueMaxMin(self.ViewModel.RemainPurchaseAmount,1)
	if self.ViewModel.RemainPurchaseAmount == 1 then
		self.TextAmount:SetText(1)
		self.AmountSlider:SetBtnIsShow(false)
	else
		self.AmountSlider:SetSliderValue(self.ViewModel.PurchaseAmount)
		self.AmountSlider:SetBtnIsShow(true)
	end
end

function OpsActivityTreasureChestBuyItemWinView:OnHide()

end

function OpsActivityTreasureChestBuyItemWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
	UIUtil.AddOnClickedEvent(self, self.BtnBuyConfirm, self.OnClickBtnBuyConfirm)
end

function OpsActivityTreasureChestBuyItemWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.ShowPurchaseReward)
end

function OpsActivityTreasureChestBuyItemWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end


function OpsActivityTreasureChestBuyItemWinView:OnClickBtnBuyConfirm()
	if not self.ViewModel.CanBuy then
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(100030), LSTR(100031), function ()
			RechargingMgr:ShowMainPanel()
		end)
	else
		local LastTime = self.ClickBuyTime or 0
		local CurrentTime = TimeUtil.GetServerTime()
		if CurrentTime - LastTime >= 1 then
			self.ClickBuyTime = CurrentTime
			_G.LootMgr:SetDealyState(true)
			local Data = {Num = self.ViewModel.PurchaseAmount}
			if OpsActivityTreasureChestPanelVM and OpsActivityTreasureChestPanelVM.ExchangeNode then
				OpsActivityMgr:SendActivityNodeOperate(OpsActivityTreasureChestPanelVM.ExchangeNode.NodeID,ProtoCS.Game.Activity.NodeOpType.NodeOpTypeExchange,
			{Exchange = Data})
			end
		end
	end
end

function OpsActivityTreasureChestBuyItemWinView:OnValueChangedAmountCountSlider(Value)
	self.ViewModel:SetPurchasePrice(Value)
end

function OpsActivityTreasureChestBuyItemWinView:ShowPurchaseReward()
	EventMgr:SendEvent(EventID.UpdateLotteryInfo)
	self:Hide()
	_G.LootMgr:SetDealyState(true)
	local Params = {}
	local ItemList = {}
	table.insert(ItemList, {ResID = self.ViewModel.PropsSlotResID, Num = self.ViewModel.PropsSlotNum})
	table.insert(ItemList, {ResID = self.ViewModel.FreeSlotResID, Num = self.ViewModel.FreeSlotNum})
	Params.ItemList = ItemList
	Params.ShowBtn = false
	EventMgr:SendEvent(EventID.PurchaseLotteryProps)
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
end


return OpsActivityTreasureChestBuyItemWinView