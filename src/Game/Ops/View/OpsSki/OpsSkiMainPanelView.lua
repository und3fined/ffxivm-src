---
--- Author: v_vvxinchen
--- DateTime: 2025-06-30 09:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsSkiPanelVM = require("Game/Ops/VM/OpsSkiPanelVM")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR

---@class OpsSkiMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy OpsCommBtnLView
---@field BtnFullScreen UFButton
---@field BtnSet UFButton
---@field ImgBtnMask UFImage
---@field ImgTextChooseBG UFImage
---@field OpsActivityTime OpsActivityTimeItemView
---@field OpsMoneySlot OpsCommMoneySlotView
---@field PanelArrow UFCanvasPanel
---@field PanelSetBtn UFHorizontalBox
---@field ShareTips OpsActivityShareTipsItemView
---@field SkiSlot1 OpsSkiSlotItemView
---@field SkiSlot2 OpsSkiSlotItemView
---@field SkiSlot3 OpsSkiSlotItemView
---@field TextArrow UFTextBlock
---@field TextBuy UFTextBlock
---@field TextChoose UFTextBlock
---@field TextDescribe UFTextBlock
---@field TextSet UFTextBlock
---@field TextTitle UFTextBlock
---@field UMGVideoPlayer UMGVideoPlayerView
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkiMainPanelView = LuaClass(UIView, true)

function OpsSkiMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnFullScreen = nil
	--self.BtnSet = nil
	--self.ImgBtnMask = nil
	--self.ImgTextChooseBG = nil
	--self.OpsActivityTime = nil
	--self.OpsMoneySlot = nil
	--self.PanelArrow = nil
	--self.PanelSetBtn = nil
	--self.ShareTips = nil
	--self.SkiSlot1 = nil
	--self.SkiSlot2 = nil
	--self.SkiSlot3 = nil
	--self.TextArrow = nil
	--self.TextBuy = nil
	--self.TextChoose = nil
	--self.TextDescribe = nil
	--self.TextSet = nil
	--self.TextTitle = nil
	--self.UMGVideoPlayer = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSkiMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.OpsActivityTime)
	self:AddSubView(self.OpsMoneySlot)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.SkiSlot1)
	self:AddSubView(self.SkiSlot2)
	self:AddSubView(self.SkiSlot3)
	self:AddSubView(self.UMGVideoPlayer)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSkiMainPanelView:OnInit()
	self.ViewModel = OpsSkiPanelVM.New()
	self.Binders = {
		{"TitleText", UIBinderSetText.New(self, self.TextTitle)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextDescribe)},
		{"SelectedText", UIBinderSetText.New(self, self.TextChoose)},
		{"ArrowText", UIBinderSetText.New(self, self.TextArrow)},
		{"bSuitChooseVisible", UIBinderSetIsVisible.New(self, self.TextChoose)},
		{"bImgTextChooseBGVisible", UIBinderSetIsVisible.New(self, self.ImgTextChooseBG)},
		{"bImgTextChooseBGVisible", UIBinderSetIsVisible.New(self, self.TextChoose)},
		{"bSetBtnVisible", UIBinderSetIsVisible.New(self, self.PanelSetBtn)},
		{"bDiscountTipVisible", UIBinderSetIsVisible.New(self, self.PanelArrow)},
		{"GoodsState", UIBinderValueChangedCallback.New(self, nil, self.OnGoodsStateChanged)}
    }

	self.TextBuy:SetText(LSTR(100127)) --购买三选一
	self.TextSet:SetText(LSTR(100130)) --套装自选
end

function OpsSkiMainPanelView:OnDestroy()

end

function OpsSkiMainPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end

	self.ViewModel:Update(self.Params)
	self:ShowSuitItems()
	self:SetVideoPlayer()
	self.UMGVideoPlayer:HideAllUI()
end

function OpsSkiMainPanelView:ShowSuitItems()
	local ViewModel = self.ViewModel
	for i = 1, 3 do
		self["SkiSlot"..i]:SetParams({SuitData = ViewModel.SuitData[i], ViewModel = ViewModel})
	end
end

function OpsSkiMainPanelView:OnGoodsStateChanged(GoodsState)
	local ViewModel = self.ViewModel
	local GoodsStateDf = ViewModel.GoodsStateDf

	--设置按钮状态
	if ViewModel.SelectedSuitGoodsID ~= 0 then
		self.BtnBuy:SetBtnPriceByGoodsID(ViewModel.SelectedSuitGoodsID, GoodsState == GoodsStateDf.Selected)
	end
	local BtnText = ViewModel.BtnText
	self.BtnBuy.BtnText = BtnText
	local IsDone = GoodsState == GoodsStateDf.IsBuy
	self.BtnBuy.CommBtnL:SetIsDoneState(IsDone, BtnText)
	if not IsDone then
		self.BtnBuy:SetBtnName(BtnText)
	end
	local MoneyVisible = GoodsState == GoodsStateDf.Selected
	self.BtnBuy.Money = MoneyVisible
	UIUtil.SetIsVisible(self.BtnBuy.PanelMoney, MoneyVisible)

	--设置3个套装购买状态
	if GoodsState == GoodsStateDf.IsBuy then
		for i = 1, 3 do
			self["SkiSlot"..i]:SetBuyState(ViewModel.SuitData[i])
		end
	end
end

function OpsSkiMainPanelView:SetVideoPlayer()
	local MoviePath = self.ViewModel.MoviePath
	if MoviePath then
		self.UMGVideoPlayer:SetVideoPath(MoviePath)
		self.UMGVideoPlayer:SetPlayMovieEndCallBack(self, self.PlayMovieEnd)
		self.UMGVideoPlayer:OnRewind()
		self.UMGVideoPlayer:SetNoUIMode(true)
		self.UMGVideoPlayer:SetPreviewMode(true)
		UIUtil.SetIsVisible(self.UMGVideoPlayer, true)
		UIUtil.SetIsVisible(self.UMGVideoPlayer.CloseButton, false)
	else
		self.UMGVideoPlayer:OnClose()
	end
end

function OpsSkiMainPanelView:PlayMovieEnd()
	self.UMGVideoPlayer:SetVolume(false)
	self.UMGVideoPlayer:OnResume()
end

function OpsSkiMainPanelView:OnClickedFullScreen()
	local MoviePath = self.ViewModel.MoviePath
	if MoviePath then
		self.UMGVideoPlayer:SetVolume(true)
		UIViewMgr:ShowView(_G.UIViewID.CommonVideoPlayerView, {VideoPath = MoviePath, SeekValue = self.UMGVideoPlayer:GetSeekValue(), HideCallBack = 
		function ()
			self:PlayMovieEnd()
		end
		})
	end
end

function OpsSkiMainPanelView:OnHide()
	self.UMGVideoPlayer:OnClose()
end

function OpsSkiMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFullScreen, self.OnClickedFullScreen)
	UIUtil.AddOnClickedEvent(self, self.BtnSet, self.ShowOpsSkiFreePanel)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy.CommBtnL, self.ShowOpsSkiFreePanel)
end

function OpsSkiMainPanelView:ShowOpsSkiFreePanel()
	local Params = self.Params
	Params.ViewModel = self.ViewModel
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsSkiFreePanel, Params)
end

function OpsSkiMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsSkiSelectSuit, self.OnSelectSuit)
	self:RegisterGameEvent(_G.EventID.StoreBuyGoodsDisplay, self.OnShowReward)
end

function OpsSkiMainPanelView:OnSelectSuit(GoodsID)
	self.BtnBuy:SetBtnPriceByGoodsID(GoodsID, true)
end

function OpsSkiMainPanelView:OnShowReward(Msg)
	self.ViewModel:AfterBuy(Msg)
	if UIViewMgr:IsViewVisible(_G.UIViewID.OpsSkiFreePanel) then
		_G.UIViewMgr:HideView(_G.UIViewID.OpsSkiFreePanel)
	end
end

function OpsSkiMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return OpsSkiMainPanelView