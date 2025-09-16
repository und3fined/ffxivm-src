
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
local StoreMgr = require("Game/Store/StoreMgr")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local StoreDefine = require("Game/Store/StoreDefine")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")

---@class StoreBuyGoodsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnBuyConfirm CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnInfor UFButton
---@field BtnView UFButton
---@field CommInforBtn CommInforBtnView
---@field HorizontalCommTips UFHorizontalBox
---@field HorizontalPrice UFHorizontalBox
---@field HorizontalSpecailTips UFHorizontalBox
---@field ImgGoods UFImage
---@field ImgMoney UFImage
---@field NotMatchTips StoreNotMatchTipsView
---@field PanelDeadline UFCanvasPanel
---@field PanelDiscount UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field TableViewItem UTableView
---@field TextContent UFTextBlock
---@field TextCurrentPrice UFTextBlock
---@field TextDeadline UFTextBlock
---@field TextDiscount UFTextBlock
---@field TextItemDescription URichTextBox
---@field TextItemName UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextTips UFTextBlock
---@field TextTips2 UFTextBlock
---@field VerticalBoxInfo UFVerticalBox
---@field AnimNotMatchTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreBuyGoodsWinView = LuaClass(UIView, true)

function StoreBuyGoodsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnBuyConfirm = nil
	--self.BtnCancel = nil
	--self.BtnInfor = nil
	--self.BtnView = nil
	--self.CommInforBtn = nil
	--self.HorizontalCommTips = nil
	--self.HorizontalPrice = nil
	--self.HorizontalSpecailTips = nil
	--self.ImgGoods = nil
	--self.ImgMoney = nil
	--self.NotMatchTips = nil
	--self.PanelDeadline = nil
	--self.PanelDiscount = nil
	--self.PanelOriginal = nil
	--self.TableViewItem = nil
	--self.TextContent = nil
	--self.TextCurrentPrice = nil
	--self.TextDeadline = nil
	--self.TextDiscount = nil
	--self.TextItemDescription = nil
	--self.TextItemName = nil
	--self.TextOriginalPrice = nil
	--self.TextTips = nil
	--self.TextTips2 = nil
	--self.VerticalBoxInfo = nil
	--self.AnimNotMatchTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreBuyGoodsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBuyConfirm)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.NotMatchTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreBuyGoodsWinView:OnInit()
	self.ContainsItemListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem, self.OnItemSelected, true, false)
	
	self.Binders = {
		{ "BuyGoodBg", UIBinderSetBrushFromAssetPath.New(self, self.ImgItemBg) },
		-- { "BuyGoodIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgGoods) },
		{ "bBuyGoodBgVisible", UIBinderSetIsVisible.New(self, self.ImgItemBg) },
		-- { "bBuyGoodIconVisible", UIBinderSetIsVisible.New(self, self.ImgGoods) },

		{ "ProductName", UIBinderSetText.New(self, self.TextItemName) },
		-- { "BuyGoodPriceText", UIBinderSetText.New(self, self.TextCurrentPrice) },
		{ "PanelOriginalVisible", UIBinderSetIsVisible.New(self, self.PanelOriginal) },
		{ "OriginalPriceText", UIBinderSetText.New(self, self.TextOriginalPrice) },
		-- { "BuyGoodPriceType", UIBinderSetBrushFromAssetPath.New(self, self.ImgCrystal) },
		{ "CurPriceTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCurrentPrice) },

		{ "ContainsItemList", UIBinderUpdateBindableList.New(self, self.ContainsItemListAdapter) },

		{ "SpecailTipsPanelVisible", UIBinderSetIsVisible.New(self, self.HorizontalSpecailTips) },
		{ "CommTipsPanelVisible", UIBinderSetIsVisible.New(self, self.HorizontalCommTips) },

		-- 只配置text情况
		{ "CommTipsTextVisible", UIBinderSetIsVisible.New(self, self.TextTips2) },
		{ "CommTipsBtnVisible", UIBinderSetIsVisible.New(self, self.CommInforBtn) },

		-- { "TextTipsText", UIBinderSetText.New(self, self.TextTips) },
		-- { "TextTipsText", UIBinderSetText.New(self, self.TextTips2) },
	}
end

function StoreBuyGoodsWinView:OnDestroy()

end

function StoreBuyGoodsWinView:OnShow()
	self.BG:SetTitleText(LSTR(StoreDefine.BuyTipTittleText))
	self.BtnCancel:SetBtnName(LSTR(950030))			--- 取消
	self.BtnBuyConfirm:SetBtnName(LSTR(950053))		--- 确认购买
	self.TextContent:SetText(LSTR(950058))			--- 包含以下物品
	self.NotMatchTips.ItemView = self.BtnInfor
	UIUtil.SetIsVisible(self.NotMatchTips, false)
	local CanBuyForOther = false
	local ItemData = StoreMainVM.CurrentSelectedItem or StoreMgr.ProductDataList[StoreMainVM.CurrentselectedID]
	if ItemData ~= nil and ItemData.GoodID ~= nil then
		local TempData = _G.StoreMgr:GetProductDataByID(ItemData.GoodID)
		if TempData ~= nil then
			CanBuyForOther = TempData.Cfg.BuyForOther == 1 and TempData.Cfg.GoodsCounterFirst == 0
		end
	end

	UIUtil.SetIsVisible(self.PanelDiscount, ItemData.DiscountPanelVisible)
	UIUtil.SetIsVisible(self.PanelDeadline, false)
	
	UIUtil.SetIsVisible(self.BtnCancel, true, true)
	self.ContainsItemListAdapter:CancelSelected()
	if ItemData.DiscountPanelVisible then
		self.TextDiscount:SetText(ItemData.DiscountText)
		self.TextOriginalPrice:SetText(ItemData.OriginalPriceText)
	end
	if ItemData.DeadlinePanelVisible then
		self.TextDeadline:SetText(ItemData.TimeSaleText)
	end
	local NormalTipsID = StoreMainVM.NormalTipsID
	if NormalTipsID == nil then
		UIUtil.SetIsVisible(self.CommInforBtn, false, false)
	else
		if StoreMainVM.CommTipsPanelVisible then
			UIUtil.SetIsVisible(self.CommInforBtn, true, true)
			self.CommInforBtn.HelpInfoID = StoreMainVM.NormalTipsID
		end
	end

	--处理活动沙漠炎火特殊显示
	if self.Params then
		if self.Params.BuyPrice and self.Params.ScoreID then
			-- StoreMainVM.BuyGoodPriceText = _G.ScoreMgr.FormatScore(self.Params.BuyPrice)
			self.TextCurrentPrice:SetText(_G.ScoreMgr.FormatScore(self.Params.BuyPrice))

			local ScoreValue = _G.ScoreMgr:GetScoreValueByID(self.Params.ScoreID)
			if self.Params.BuyPrice > ScoreValue then
				StoreMainVM.CurPriceTextColor = "DC5868FF"
			else
				StoreMainVM.CurPriceTextColor = "D2BA8EFF"
			end
			if self.Params.OriginalPrice then
				StoreMainVM.OriginalPriceText = _G.ScoreMgr.FormatScore(self.Params.OriginalPrice)
				StoreMainVM.PanelOriginalVisible = true
			else
				StoreMainVM.PanelOriginalVisible = false
			end
		end

		if not string.isnilorempty(self.Params.ShopDesc) then
			self.TextItemDescription:SetText(self.Params.ShopDesc)
		end
		local TempCfg = self.Params.TempCfg
		if TempCfg ~= nil then
			self.TextItemDescription:SetText(ProtoEnumAlias.GetAlias(ProtoRes.Store_Label_Type, TempCfg.LabelMain))
			UIUtil.SetIsVisible(self.ImgGoods, true)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgGoods, TempCfg.Icon)
		end
	end
end

function StoreBuyGoodsWinView:OnHide()

end

function StoreBuyGoodsWinView:OnItemSelected(Index, ItemData, ItemView)
	ItemData.IsSelect = false
	ItemTipsUtil.ShowTipsByResID(StoreMainVM.ContainsItemList.Items[Index].ResID, ItemView, {X = -self.TableViewItem.EntrySpacing, Y = 0})
end

function StoreBuyGoodsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInfor, self.OnClickBtnInfor)
	UIUtil.AddOnClickedEvent(self, self.BtnBuyConfirm, self.OnClickBtnBuyConfirm)

	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
end



function StoreBuyGoodsWinView:OnClickBtnCancel()
	self:Hide()
end

function StoreBuyGoodsWinView:OnClickBtnInfor()
	self:PlayAnimation(self.AnimNotMatchTipsIn)
	UIUtil.SetIsVisible(self.NotMatchTips, true)

end

function StoreBuyGoodsWinView:OnClickBtnBuyConfirm()
	if self.Params and self.Params.ClickedBuyCallBack then
		self.Params.ClickedBuyCallBack()
		self:Hide()
		return
	end
	StoreMgr:CheckPurchasePreconditions()
end

function StoreBuyGoodsWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.StoreHideNotMatchTips, self.OnHideNotMatchTips)
end

function StoreBuyGoodsWinView:OnHideNotMatchTips()
	UIUtil.SetIsVisible(self.NotMatchTips, false)
end
function StoreBuyGoodsWinView:OnRegisterBinder()
	self:RegisterBinders(StoreMainVM, self.Binders)
end

return StoreBuyGoodsWinView