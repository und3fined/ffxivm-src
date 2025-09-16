---
--- Author: Administrator
--- DateTime: 2023-05-04 15:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MarketMainVM = require("Game/Market/VM/MarketMainVM")
local ProtoRes = require("Protocol/ProtoRes")
local MarketMgr = require("Game/Market/MarketMgr")
local TradeMarketSystemParamCfg = require("TableCfg/TradeMarketSystemParamCfg")
local MarketRecordWinVM = require("Game/Market/VM/MarketRecordWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MarketDefine = require("Game/Market/MarketDefine")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

---@class MarketMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BGPanel UFCanvasPanel
---@field BtnClose CommonCloseBtnView
---@field BtnRecord UFButton
---@field BuyPage MarketBuyPageView
---@field CommTabs CommTabsView
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field ImgBgLine UFImage
---@field MoneySlot1 CommMoneySlotView
---@field SellPage MarketSellPageView
---@field AnimBuyPage UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimSellPage UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketMainPanelView = LuaClass(UIView, true)

local LSTR = _G.LSTR
MarketMainPanelView.TabType =
{
	MarketTypeBuy = 1,
	MarketTypeSell = 2,
}

function MarketMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BGPanel = nil
	--self.BtnClose = nil
	--self.BtnRecord = nil
	--self.BuyPage = nil
	--self.CommTabs = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonTitle = nil
	--self.ImgBgLine = nil
	--self.MoneySlot1 = nil
	--self.SellPage = nil
	--self.AnimBuyPage = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimSellPage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BuyPage)
	self:AddSubView(self.CommTabs)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.MoneySlot1)
	self:AddSubView(self.SellPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY

end

function MarketMainPanelView:OnInit()
	
	self.Binders = {
		{ "MarketBuyVisible", UIBinderSetIsVisible.New(self, self.BuyPage) },
		{ "MarketSellVisible", UIBinderSetIsVisible.New(self, self.SellPage) },
		{ "ImgBgLineVisible", UIBinderSetIsVisible.New(self, self.ImgBgLine) },

		{ "SubTitleText", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle) },
		{ "SubTitleTextVisible", UIBinderSetIsVisible.New(self, self.CommonTitle.TextSubtitle) },
	}
end

function MarketMainPanelView:OnDestroy()

end

function MarketMainPanelView:OnShow()
	self.MoneySlot1:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE, false, nil, true)
	UIUtil.SetIsVisible(self.CommTabs.PanelSlot2, true)
	UIUtil.SetIsVisible( self.CommTabs.RedDotSlot2, true )
	self.CommTabs.RedDotSlot2:SetRedDotIDByID(MarketDefine.MarketRedDotID.Market)
	if self.Params ~= nil then
		local JumpToBuyItemID = self.Params.JumpToBuyItemID
		if JumpToBuyItemID ~= nil then
			self.CommTabs:SetSelectedIndex(MarketMainPanelView.TabType.MarketTypeBuy)
			self.BuyPage:SeekJumoToBuyItem(JumpToBuyItemID)
			MarketMainVM.JumpToBuyItemID = JumpToBuyItemID
			return
		end

		local JumpToSellItemGID = self.Params.JumpToSellItemGID
		if JumpToSellItemGID ~= nil then
			self.CommTabs:SetSelectedIndex(MarketMainPanelView.TabType.MarketTypeSell)
			self.SellPage:SeekJumoToSellItem(JumpToSellItemGID)
			return
		end

		local TabIndex = self.Params.TabIndex
		if TabIndex ~= nil then
			self.CommTabs:SetSelectedIndex(TabIndex)
			if TabIndex == MarketMainPanelView.TabType.MarketTypeBuy then
				self.BuyPage:ResetTabIndex()
				return
			end
		end
	end

	self.CommTabs:SetSelectedIndex(MarketMainPanelView.TabType.MarketTypeBuy)
	self.BuyPage:ResetTabIndex()
end

function MarketMainPanelView:OnHide()
	self.SellPage:ResetData()
	self.BuyPage:ResetData()
	MarketMgr.SaleGoodCache = {}
	MarketRecordWinVM.CurType = nil
end

function MarketMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRecord, self.OnClickedRecord)

	if self.BtnClose then
		self.BtnClose:SetCallback(self, self.OnClickButtonClose)
	end

	self.BuyPage:SetSkinAniCallback(self, self.OnSkinAniCallback)

	self.CommTabs:SetCallBack(self, self.OnCommTabIndexChanged)
end

--- 点击×关闭界面
function MarketMainPanelView:OnClickButtonClose()

	if UIViewMgr:IsViewVisible(UIViewID.LegendaryWeaponPanel) then
		-- 若是从传奇武器跳转到市场界面，则在关闭市场时需通知更新一次武器信息数据
		_G.EventMgr:SendEvent(EventID.LegendaryInnerMatClick, _G.LegendaryWeaponMainPanelVM.MaterialResID)
	end

	if UIViewMgr:IsViewVisible(UIViewID.MagicsparInlayMainPanel) then
		-- 若是从魔晶石跳转到市场界面，则在关闭市场时需通知更新一次魔晶石数据
		_G.EventMgr:SendEvent(EventID.MagicsparInlayRefresh)
	end

	self:Hide()
end

function MarketMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MarketStallInfoUpdata, self.OnStallInfoUpdata)
end

function MarketMainPanelView:OnRegisterBinder()
	
	if nil == self.Binders then return end
	self:RegisterBinders(MarketMainVM, self.Binders)

	self.CommonTitle:SetTextTitleName(LSTR(1010063))

	local TabList = {}
	table.insert(TabList, {Name = LSTR(1010064)})
	table.insert(TabList, {Name = LSTR(1010065)})
	
	self.CommTabs:UpdateItems(TabList)

	local MarketHelpCfg = TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_MARKEY_DESC)
	if nil ~= MarketHelpCfg then
		self.CommonTitle.CommInforBtn.HelpInfoID = MarketHelpCfg.Value[1]
	end
end

function MarketMainPanelView:OnStallInfoUpdata()
	if MarketMgr:HasStallExpired() or MarketMgr:GetAllStallIncome() > 0 then
		_G.RedDotMgr:AddRedDotByID(MarketDefine.MarketRedDotID.Market)
	else
		_G.RedDotMgr:DelRedDotByID(MarketDefine.MarketRedDotID.Market)
	end
end


function MarketMainPanelView:OnCommTabIndexChanged(Index)
	if Index == MarketMainPanelView.TabType.MarketTypeBuy then
		self:PlayAnimation(self.AnimBuyPage)
	else
		self:PlayAnimation(self.AnimSellPage)
	end
	MarketMainVM:SetPageTabIndex(Index)
end

function MarketMainPanelView:OnSkinAniCallback(IsEmpty)
	if IsEmpty == true then
		self:SetSkinEmpty()
	else
		self:SetSkinFull()
	end
end

function MarketMainPanelView:SetSkinEmpty()
	--self.Spine_Market_BG:SetSkin("default")
end

function MarketMainPanelView:SetSkinFull()
	--self.Spine_Market_BG:SetSkin("full")
end

function MarketMainPanelView:OnClickedRecord()
	UIViewMgr:ShowView(UIViewID.MarketRecordWin)
end

return MarketMainPanelView