---
--- Author: Administrator
--- DateTime: 2024-06-13 11:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CompanySealPromotionWinVM = require("Game/CompanySeal/View/Item/CompanySealPromotionWinVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local UIBinderCommBtnUpdateImage = require("Binder/UIBinderCommBtnUpdateImage")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local EventID = require("Define/EventID")

local LSTR = _G.LSTR

---@class CompanySealPromotionWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnClose CommonCloseBtnView
---@field BtnSure CommBtnLView
---@field CommMoneySlot_UIBP_59 CommMoneySlotView
---@field IconMilitaryRank UFImage
---@field IconMilitaryRankAfterPromotion UFImage
---@field IconTicket_1 UFImage
---@field ImgCompanySeal_1 UFImage
---@field ImgCompanySeal_2 UFImage
---@field ImgCompanySeal_3 UFImage
---@field MI_DX_Common_CompanySeal_4_a UFImage
---@field MI_DX_Common_CompanySeal_5_a UFImage
---@field MI_DX_Common_CompanySeal_6_a UFImage
---@field TableViewLeft UTableView
---@field TableViewRight UTableView
---@field TextMilitaryRank UFTextBlock
---@field TextMilitaryRankAfterPromotion UFTextBlock
---@field TextQuantity_1 URichTextBox
---@field TextTitle URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimLevelUp UWidgetAnimation
---@field AnimLevelUp_backup UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealPromotionWinView = LuaClass(UIView, true)

function CompanySealPromotionWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnClose = nil
	--self.BtnSure = nil
	--self.CommMoneySlot_UIBP_59 = nil
	--self.IconMilitaryRank = nil
	--self.IconMilitaryRankAfterPromotion = nil
	--self.IconTicket_1 = nil
	--self.ImgCompanySeal_1 = nil
	--self.ImgCompanySeal_2 = nil
	--self.ImgCompanySeal_3 = nil
	--self.MI_DX_Common_CompanySeal_4_a = nil
	--self.MI_DX_Common_CompanySeal_5_a = nil
	--self.MI_DX_Common_CompanySeal_6_a = nil
	--self.TableViewLeft = nil
	--self.TableViewRight = nil
	--self.TextMilitaryRank = nil
	--self.TextMilitaryRankAfterPromotion = nil
	--self.TextQuantity_1 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLevelUp = nil
	--self.AnimLevelUp_backup = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealPromotionWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnSure)
	self:AddSubView(self.CommMoneySlot_UIBP_59)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealPromotionWinView:OnInit()
	self.ViewModel = CompanySealPromotionWinVM.New()
	self.LeftRankTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewLeft)
	self.RightRankTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRight)
	self.Binders = {
		{ "LeftRankList", UIBinderUpdateBindableList.New(self, self.LeftRankTableViewAdapter) },
		{ "RightRankList", UIBinderUpdateBindableList.New(self, self.RightRankTableViewAdapter) },
		{ "LeftText", UIBinderSetText.New(self, self.TextMilitaryRank) },
		{ "RightText", UIBinderSetText.New(self, self.TextMilitaryRankAfterPromotion) },
		{ "LeftIcon", UIBinderSetImageBrush.New(self, self.IconMilitaryRank) },
		{ "RightIcon", UIBinderSetImageBrush.New(self, self.IconMilitaryRankAfterPromotion) },
		{ "TextQuantity", UIBinderSetText.New(self, self.TextQuantity_1) },	
		{ "BtnStyle", UIBinderCommBtnUpdateImage.New(self, self.BtnSure)},
		--{ "Img", UIBinderSetImageBrush.New(self, self.ImgCompanySeal) },
		{ "Title", UIBinderSetText.New(self, self.TextTitle) },		
		{ "GrandImg1", UIBinderSetIsVisible.New(self, self.ImgCompanySeal_2) },
		{ "GrandImg2", UIBinderSetIsVisible.New(self, self.ImgCompanySeal_3) },
		{ "GrandImg3", UIBinderSetIsVisible.New(self, self.ImgCompanySeal_1) },
		{ "IconTicket", UIBinderSetImageBrush.New(self, self.IconTicket_1) },
	}
end

function CompanySealPromotionWinView:OnDestroy()

end

function CompanySealPromotionWinView:OnShow()
	local ScoreID = CompanySealMgr:GetScoreInfo()
	self.CommMoneySlot_UIBP_59:UpdateView(ScoreID, false, _G.UIViewID.MarketExchangeWin, true)
	self.ViewModel:UpdateTitleText()
	self.BtnSure.TextContent:SetText(LSTR(1160037))
	self.BtnSure:SetColorType(self.ViewModel.BtnStyle or 1)
	self.BtnCancel.TextContent:SetText(LSTR(1160058))
	self:PlayAnimation(self.AnimLoop, 0, 0)
end

function CompanySealPromotionWinView:OnHide()

end

function CompanySealPromotionWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnSure, self.OnClickBtnSure)
end

function CompanySealPromotionWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CompanySealPlayLvUPAni, self.PlayLvUpAni)
end

function CompanySealPromotionWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CompanySealPromotionWinView:OnClickBtnCancel()
	self:Hide()
end

function CompanySealPromotionWinView:OnClickBtnSure()
	if self.ViewModel.IsCanPromoted and CompanySealMgr.IsCanPromoted then
		CompanySealMgr:SendMilitaryUpgrade()
	elseif not self.ViewModel.IsCanPromoted then
		local Tips = LSTR(1160007) 
		_G.MsgTipsUtil.ShowTips(Tips)
	end
end

function CompanySealPromotionWinView:PlayLvUpAni(Data)
	CompanySealMgr.IsCanPromoted = false
	self:PlayAnimation(self.AnimLevelUp)
	local function DelayClose()
		self:Hide()
		CompanySealMgr:ShowGrandCompanyTips(Data)
	end
	self.DelayTimerID = self:RegisterTimer(DelayClose, 0.3, 0, 0)
end

return CompanySealPromotionWinView