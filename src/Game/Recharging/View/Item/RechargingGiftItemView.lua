---
--- Author: zimuyi
--- DateTime: 2024-01-22 20:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ItemTipsUtil = require("Utils/ItemTipsUtil")
local PreviewMgr = require("Game/Preview/PreviewMgr")
local RechargingDefine = require("Game/Recharging/RechargingDefine")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local RechargeRewardCfg = require("TableCfg/RechargeRewardCfg")

local FLOG_ERROR = _G.FLOG_ERROR
local RewardItemState = RechargingDefine.RewardItemState

---@class RechargingGiftItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field BtnPreview UFButton
---@field EFFAvailable1 UFCanvasPanel
---@field EFFAvailable2 UFCanvasPanel
---@field FRetainerBox_0 UFRetainerBox
---@field ImgGot UFImage
---@field ImgItem UFImage
---@field ImgLock UFImage
---@field ImgSelectArrow UFImage
---@field ImgTag UFImage
---@field IncludeItem CommBackpackSlotView
---@field PanelContent UFCanvasPanel
---@field PanelInclude UFCanvasPanel
---@field PanelTag UFCanvasPanel
---@field TableViewInclude UTableView
---@field TextAvailable UFTextBlock
---@field TextInclude UFTextBlock
---@field TextLimit UFTextBlock
---@field TextName UFTextBlock
---@field VerticalInclude UFVerticalBox
---@field AnimCancel UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimSelect UWidgetAnimation
---@field TEMPIndex string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingGiftItemView = LuaClass(UIView, true)

function RechargingGiftItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.BtnPreview = nil
	--self.EFFAvailable1 = nil
	--self.EFFAvailable2 = nil
	--self.FRetainerBox_0 = nil
	--self.ImgGot = nil
	--self.ImgItem = nil
	--self.ImgLock = nil
	--self.ImgSelectArrow = nil
	--self.ImgTag = nil
	--self.IncludeItem = nil
	--self.PanelContent = nil
	--self.PanelInclude = nil
	--self.PanelTag = nil
	--self.TableViewInclude = nil
	--self.TextAvailable = nil
	--self.TextInclude = nil
	--self.TextLimit = nil
	--self.TextName = nil
	--self.VerticalInclude = nil
	--self.AnimCancel = nil
	--self.AnimIn = nil
	--self.AnimSelect = nil
	--self.TEMPIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingGiftItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.IncludeItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingGiftItemView:OnInit()
	self.CancelSelectTimer = 0

	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewInclude)
	self.TableViewAdapter:SetOnClickedCallback(self.OnItemSlotClicked)
	self.ViewModel = nil
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "Icon", UIBinderSetImageBrush.New(self, self.ImgItem) },
		-- { "bIsFirstRecharge", UIBinderSetIsVisible.New(self, self.PanelTag) },
		{ "bIsSelected", UIBinderSetIsVisible.New(self, self.PanelInclude) },
		{ "bIsSingleItem", UIBinderSetIsVisible.New(self, self.IncludeItem) },
		{ "bIsSingleItem", UIBinderSetIsVisible.New(self, self.TableViewInclude, true) },
		{ "bIsRestAmount", UIBinderSetIsVisible.New(self, self.TextLimit) },
		{ "State", UIBinderValueChangedCallback.New(self, nil, self.OnStateChangedCallback) },
		{ "RestAmountToApplyReward", UIBinderSetTextFormat.New(self, self.TextLimit, _G.LSTR(940012))},
		{ "ItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "TextAvailable", UIBinderSetText.New(self, self.TextAvailable) },
		{ "TextInclude", UIBinderSetText.New(self, self.TextInclude) },
	}
end

function RechargingGiftItemView:OnDestroy()

end

function RechargingGiftItemView:OnShow()

end

function RechargingGiftItemView:OnHide()

end

function RechargingGiftItemView:OnRegisterUIEvent()
	self.IncludeItem:SetClickButtonCallback(self.IncludeItem, 
		function() ItemTipsUtil.ShowTipsByResID(self.ViewModel.SingleItemVM.ResID, self.IncludeItem) end)
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnPreview, self.OnPreviewClicked)
end

function RechargingGiftItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.RechargeRewardReceived, self.OnRewardReceived)
end

function RechargingGiftItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.IncludeItem:SetParams({ Data = ViewModel.SingleItemVM })
	self:RegisterBinders(ViewModel, self.Binders)
	self.ViewModel = ViewModel
end

function RechargingGiftItemView:OnBtnClicked()
	local bIsSelectedBefore = self.ViewModel.bIsSelected
	if self.ViewModel.State == RewardItemState.Available then
		RechargingMgr:ApplyForReward(self.ViewModel.GiftID)
	else
		if self.ViewModel.bIsSelected == false then
			self.ViewModel.bIsSelected = true
			self:UnRegisterTimer(self.CancelSelectTimer)
			self:PlayAnimation(self.AnimSelect)
		else
			self:PlayAnimation(self.AnimCancel)
			self.CancelSelectTimer = self:RegisterTimer(function() self.ViewModel.bIsSelected = false end,
				self.AnimCancel:GetEndTime())
		end
	end

	if bIsSelectedBefore == false then
		RechargingMgr:PlayAnimation(RechargingMgr:GetCharacterRewardApplyAction(self.ViewModel.State))
	end
end

function RechargingGiftItemView:OnPreviewClicked()
	if nil == self.ViewModel then
		FLOG_ERROR("[RechargingGiftItemView:OnPreviewClicked] Cannot find view model")
		return
	end
	local GiftCfgData = RechargeRewardCfg:FindCfgByKey(self.ViewModel.GiftID)
	if nil == GiftCfgData then
		FLOG_ERROR("[RechargingGiftItemView:OnPreviewClicked] Cannot find gift")
		return
	end
	PreviewMgr:OpenPreviewView(GiftCfgData.PreviewID)
end

function RechargingGiftItemView:OnItemSlotClicked(Index, ItemData, ItemView)
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
end

function RechargingGiftItemView:OnStateChangedCallback(NewState)
	if nil == NewState then
		return
	end

	UIUtil.SetIsVisible(self.ImgLock, NewState == RewardItemState.Locked)
	UIUtil.SetIsVisible(self.TextAvailable, NewState == RewardItemState.Available)
	UIUtil.SetIsVisible(self.EffAvailable1, NewState == RewardItemState.Available)
	UIUtil.SetIsVisible(self.EffAvailable2, NewState == RewardItemState.Available)
	UIUtil.SetIsVisible(self.ImgGot, NewState == RewardItemState.Got)
end

function RechargingGiftItemView:OnRewardReceived(Params)
	if nil == Params or nil == self.ViewModel or nil == self.ViewModel.GiftID then
		return
	end

	if self.ViewModel.GiftID == Params.RewardID then
		self.ViewModel.State = RechargingDefine.RewardItemState.Got
	end
end

return RechargingGiftItemView