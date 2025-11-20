---
--- Author: v_vvxinchen
--- DateTime: 2025-07-28 14:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR

---@class OpsLolitaGiftCardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field Giveaway1 OpsLolitaGiveawayItemView
---@field Giveaway2 OpsLolitaGiveawayItemView
---@field Giveaway3 OpsLolitaGiveawayItemView
---@field IconMoney UFImage
---@field PanelHint UFCanvasPanel
---@field PanelMoney UFHorizontalBox
---@field TextCheck UFTextBlock
---@field TextGiveaway UFTextBlock
---@field TextGiveawayTag UFTextBlock
---@field TextHint UFTextBlock
---@field TextPrice UFTextBlock
---@field TextPricePre UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLolitaGiftCardItemView = LuaClass(UIView, true)

function OpsLolitaGiftCardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.Giveaway1 = nil
	--self.Giveaway2 = nil
	--self.Giveaway3 = nil
	--self.IconMoney = nil
	--self.PanelHint = nil
	--self.PanelMoney = nil
	--self.TextCheck = nil
	--self.TextGiveaway = nil
	--self.TextGiveawayTag = nil
	--self.TextHint = nil
	--self.TextPrice = nil
	--self.TextPricePre = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLolitaGiftCardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Giveaway1)
	self:AddSubView(self.Giveaway2)
	self:AddSubView(self.Giveaway3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLolitaGiftCardItemView:OnInit()
	self.Binders = {
		{"PurchaseNum", UIBinderValueChangedCallback.New(self, nil, self.OnPurchaseNumChanged)},
		{"RewardStatus", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStatusChanged)}
    }
	self.TextCheck:SetText(LSTR(10025)) --查看
end

function OpsLolitaGiftCardItemView:OnDestroy()

end

function OpsLolitaGiftCardItemView:OnShow()
	self.TextGiveawayTag:SetText(LSTR(100137)) --"赠"
	self.TextGiveaway:SetText(LSTR(100138)) --"满5件 加赠6件!"
	self.TextPricePre:SetText(LSTR(100139)) --"价值"

	local ViewModel = self.Params and self.Params.Data
	if ViewModel == nil then
		return
	end
	self.ViewModel = ViewModel
	local Rewards = ViewModel.Rewards
	for i = 1, 3 do
		self["Giveaway"..i]:SetParams({Rewards = Rewards[i]})
	end
	self.TextPrice:SetText(ViewModel.RewardsPrice)
end

function OpsLolitaGiftCardItemView:OnHide()

end

function OpsLolitaGiftCardItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickedBtnCheck)
end

function OpsLolitaGiftCardItemView:OnClickedBtnCheck()
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsLolitaGiftWin, {Data = self.ViewModel})
end

function OpsLolitaGiftCardItemView:OnRegisterGameEvent()

end

function OpsLolitaGiftCardItemView:OnRegisterBinder()
	local ViewModel = self.Params and self.Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsLolitaGiftCardItemView:OnPurchaseNumChanged()
	local ViewModel = self.Params and self.Params.Data
	if ViewModel == nil then
		return
	end
	local RewardStatus = ViewModel.RewardStatus
	local IsRewardStatusNo = RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo

	--奖励表述
	local PurchaseNum, TotalNum = ViewModel.PurchaseNum, ViewModel.TotalNum
	self.TextQuantity:SetText(string.format("(%s/%s)", PurchaseNum, TotalNum))
	if IsRewardStatusNo then
		local PanelHintVisible = TotalNum - PurchaseNum == 1
		UIUtil.SetIsVisible(self.PanelHint, PanelHintVisible)
		self.TextHint:SetText(LSTR(100143)) --"再购1件，获得全部奖励"
	else
		UIUtil.SetIsVisible(self.PanelHint, true)
		self.TextHint:SetText(LSTR(100023)) --已获得
	end
end

function OpsLolitaGiftCardItemView:OnRewardStatusChanged(RewardStatus)
	for i = 1, 3 do
		self["Giveaway"..i]:SetReceiveVisible(RewardStatus ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusNo)
	end
end

return OpsLolitaGiftCardItemView