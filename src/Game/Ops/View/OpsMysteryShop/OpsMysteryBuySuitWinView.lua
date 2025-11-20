---
--- Author: yutingzhan
--- DateTime: 2025-06-25 09:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MysteryShopGoodsListItemVM = require("Game/Ops/VM/OpsMysteryShop/MysteryShopGoodsListItemVM")

---@class OpsMysteryBuySuitWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnBuyConfirm CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnInfor UFButton
---@field BtnView UFButton
---@field HorizontalPrice UFHorizontalBox
---@field HorizontalSpecailTips UFHorizontalBox
---@field ImgDeadline UFImage
---@field ImgGoods UFImage
---@field ImgMoney UFImage
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
---@field VerticalBoxInfo UFVerticalBox
---@field AnimNotMatchTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMysteryBuySuitWinView = LuaClass(UIView, true)

function OpsMysteryBuySuitWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnBuyConfirm = nil
	--self.BtnCancel = nil
	--self.BtnInfor = nil
	--self.BtnView = nil
	--self.HorizontalPrice = nil
	--self.HorizontalSpecailTips = nil
	--self.ImgDeadline = nil
	--self.ImgGoods = nil
	--self.ImgMoney = nil
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
	--self.VerticalBoxInfo = nil
	--self.AnimNotMatchTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMysteryBuySuitWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBuyConfirm)
	self:AddSubView(self.BtnCancel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMysteryBuySuitWinView:OnInit()
	self.ViewModel = MysteryShopGoodsListItemVM.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem, self.OnClickedSelectMemberItem, true)
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextItemName) },
		{ "ItemDescription", UIBinderSetText.New(self, self.TextItemDescription) },

		{ "SuitImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgGoods) },
		{ "TagVisible", UIBinderSetIsVisible.New(self, self.PanelDiscount) },
		{ "DiscountText", UIBinderSetText.New(self, self.TextDiscount) },
		{ "TimeVisible", UIBinderSetIsVisible.New(self, self.PanelDeadline) },
		{ "TimeText", UIBinderSetText.New(self, self.TextDeadline) },
		{ "IsCanPreView", 		UIBinderSetIsVisible.New(self, self.BtnView) },
		{ "FormatCostPrice1", UIBinderSetText.New(self, self.TextCurrentPrice) },
		{ "FormatCostPrice2", UIBinderSetText.New(self, self.TextOriginalPrice) },
		{ "CostPrice2Visiable", UIBinderSetIsVisible.New(self, self.PanelOriginal) },
		{ "MoneyImg", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgMoney) },
        { "ItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},

	}
end

function OpsMysteryBuySuitWinView:OnDestroy()

end

function OpsMysteryBuySuitWinView:OnShow()
	if self.Params == nil then
		return
	end
	self.ViewModel = self.Params
	self:RegisterBinders(self.ViewModel, self.Binders)
	UIUtil.SetIsVisible(self.HorizontalSpecailTips, false)
	UIUtil.SetIsVisible(self.BtnCancel, true, true)

	self.BG.FText_Title:SetText(_G.LSTR(950047))
	self.BtnCancel:SetText(_G.LSTR(10003))
	self.BtnBuyConfirm:SetText(_G.LSTR(1200071))
	self.TextContent:SetText(_G.LSTR(950058))

	self:SetPriceColor()
	self.BtnBuyConfirm:SetIsRecommendState(true)
	self.ViewModel.ItemVMList:UpdateByValues(self.ViewModel.ItemsData)
end

function OpsMysteryBuySuitWinView:OnHide()

end

function OpsMysteryBuySuitWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnView, self.OnClickedBtnPreview)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnBuyConfirm, self.OnClickedConfirmBtn)
end


function OpsMysteryBuySuitWinView:OnRegisterGameEvent()

end

function OpsMysteryBuySuitWinView:OnRegisterBinder()
end

function OpsMysteryBuySuitWinView:OnClickedBtnPreview()
	_G.PreviewMgr:OpenPreviewView(self.Params.SuitID)
end

function OpsMysteryBuySuitWinView:OnClickedBtnCancel()
	self:Hide()
end

function OpsMysteryBuySuitWinView:OnClickedConfirmBtn()
	if self.ViewModel.IsCanBuy then
		if self.IsMoneyEnough then
			_G.ShopMgr:SendMsgMallInfoBuy(self.ViewModel.GoodsID, 1)
		else
			if self.ViewModel.PriceItemID == ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS then
				MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(100030), _G.LSTR(100031), function ()
					_G.RechargingMgr:ShowMainPanel()
				end)
			else
				MsgTipsUtil.ShowTips(_G.LSTR(100135))
			end
		end
	else
		MsgTipsUtil.ShowTips(_G.LSTR(1200025)) -- 已售罄
	end
end

function OpsMysteryBuySuitWinView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
end

function OpsMysteryBuySuitWinView:SetPriceColor()
	local Price = self.ViewModel.CostPrice1
	local ScoreValue = _G.ScoreMgr:GetScoreValueByID(self.ViewModel.PriceItemID)
	if ScoreValue < Price then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextCurrentPrice, "dc5868")
		self.IsMoneyEnough = false
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextCurrentPrice, "d1ba8e")
		self.IsMoneyEnough = true
	end

end

return OpsMysteryBuySuitWinView