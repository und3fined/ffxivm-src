---
--- Author: Administrator
--- DateTime: 2024-06-06 19:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CompanySealTransferWinVM = require("Game/CompanySeal/View/Item/CompanySealTransferWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderCommBtnUpdateImage = require("Binder/UIBinderCommBtnUpdateImage")
local UIBinderSetIconItemAndScore = require("Binder/UIBinderSetIconItemAndScore")

local LSTR = _G.LSTR


---@class CompanySealTransferWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnSure CommBtnLView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field IconMilitaryRank UFImage
---@field IconMilitaryRankAfterTransfer UFImage
---@field IconTicket_1 UFImage
---@field ImgFlagLeft UFImage
---@field ImgFlagLeft2 UFImage
---@field ImgFlagRight UFImage
---@field ImgFlagRight2 UFImage
---@field MoneySlot CommMoneySlotView
---@field PanelTransferHint UFCanvasPanel
---@field RichText URichTextBox
---@field RichTextHint URichTextBox
---@field TextMilitaryRank UFTextBlock
---@field TextMilitaryRankAfterTransfer UFTextBlock
---@field TextQuantity_1 URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimIn_0 UWidgetAnimation
---@field AnimSure UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealTransferWinView = LuaClass(UIView, true)

function CompanySealTransferWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnSure = nil
	--self.Comm2FrameL_UIBP = nil
	--self.IconMilitaryRank = nil
	--self.IconMilitaryRankAfterTransfer = nil
	--self.IconTicket_1 = nil
	--self.ImgFlagLeft = nil
	--self.ImgFlagLeft2 = nil
	--self.ImgFlagRight = nil
	--self.ImgFlagRight2 = nil
	--self.MoneySlot = nil
	--self.PanelTransferHint = nil
	--self.RichText = nil
	--self.RichTextHint = nil
	--self.TextMilitaryRank = nil
	--self.TextMilitaryRankAfterTransfer = nil
	--self.TextQuantity_1 = nil
	--self.AnimIn = nil
	--self.AnimIn_0 = nil
	--self.AnimSure = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealTransferWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSure)
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.MoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealTransferWinView:OnInit()
	self.ViewModel = CompanySealTransferWinVM.New()
	self.Binders = {
		{ "Title", UIBinderSetText.New(self, self.Comm2FrameL_UIBP.FText_Title) },
		{ "Desc", UIBinderSetText.New(self, self.RichTextHint) },
		{ "LeftImg", UIBinderSetImageBrush.New(self, self.ImgFlagLeft) },
		{ "RightImg", UIBinderSetImageBrush.New(self, self.ImgFlagRight) },
		{ "LeftRankIcon", UIBinderSetImageBrush.New(self, self.IconMilitaryRank) },
		{ "RightRankIcon", UIBinderSetImageBrush.New(self, self.IconMilitaryRankAfterTransfer) },
		{ "LeftRankText", UIBinderSetText.New(self, self.TextMilitaryRank) },
		{ "RightRankText", UIBinderSetText.New(self, self.TextMilitaryRankAfterTransfer) },
		{ "PanelSureVisible", UIBinderSetIsVisible.New(self, self.PanelSure)},
		{ "PanelTransVisible", UIBinderSetIsVisible.New(self, self.PanelTransferHint)},
		{ "LeftIcon2", UIBinderSetImageBrush.New(self, self.ImgFlagLeft2) },
		{ "RightIcon2", UIBinderSetImageBrush.New(self, self.ImgFlagRight2) },
		{ "Tips", UIBinderSetText.New(self, self.RichText) },
		{ "TextQuantity", UIBinderSetText.New(self, self.TextQuantity_1) },	
		{ "IsSure", UIBinderValueChangedCallback.New(self, nil, self.OnSureStateChanged)},
		{ "BtnStyle", UIBinderCommBtnUpdateImage.New(self, self.BtnSure)},
		{ "IconTicket", UIBinderSetIconItemAndScore.New(self, self.IconTicket_1)},	
	}
end

function CompanySealTransferWinView:OnDestroy()

end

function CompanySealTransferWinView:OnShow()
	local ScoreID = 19000002
	self.MoneySlot:UpdateView(ScoreID, false, _G.UIViewID.MarketExchangeWin, true)
	self.ViewModel:UpdateInfo()
	UIUtil.SetIsVisible(self.PanelTransferHint, true)
	self:PlayAnimation(self.AnimIn)
	self.BtnCancel:SetBtnName(LSTR(1160058))--取消
	self.BtnSure:SetBtnName(LSTR(1160064))--确认
end

function CompanySealTransferWinView:OnSureStateChanged(NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimSure)
	end
	--self.ViewModel:UpdateSureView(NewValue)
end

function CompanySealTransferWinView:OnHide()
	self.ViewModel:UpdateSureState(false)
end

function CompanySealTransferWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnSure, self.OnClickBtnSure)
end

function CompanySealTransferWinView:OnRegisterGameEvent()

end

function CompanySealTransferWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CompanySealTransferWinView:OnClickBtnCancel()
	self:Hide()
end

function CompanySealTransferWinView:OnClickBtnSure()
	if not self.ViewModel.IsSure then
		self.ViewModel:UpdateSureState(true)
	else
		if self.ViewModel.IsCanTransfer then
			if CompanySealMgr.CurOpenTransferID ~= 0 and CompanySealMgr.CurOpenTransferID ~= CompanySealMgr.GrandCompanyID then
				if self.ViewModel.IsCDOver then
					CompanySealMgr:SendMsgTransferCompany()
				else
					local Day = self.ViewModel.SurplusCDDay
					local Tips = string.format("%s%d%s", LSTR(1160032), Day, LSTR(1160025))
					_G.MsgTipsUtil.ShowErrorTips(Tips)
				end
			end
		else
			local Tips = LSTR(1160054) 
			_G.MsgTipsUtil.ShowErrorTips(Tips)
		end
	end
end

return CompanySealTransferWinView