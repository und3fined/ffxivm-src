---
--- Author: v_vvxinchen
--- DateTime: 2025-02-27 18:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SCORE_TYPE = ProtoRes.SCORE_TYPE

local TextColor = {
	"d1ba8e",--黄
	"dc5868",--红
	"#828282",--灰
	"d5d5d5", -- 白
}

---@class CraftingLogShopWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnSubtractTen1 UFButton
---@field BtnSubtractTen2 UFButton
---@field CommAmountSlider CommAmountSliderView
---@field CommBtnM CommBtnMView
---@field CommMoneyBar CommMoneyBarView
---@field FCanvasPanel1 UFCanvasPanel
---@field FCanvasPanel2 UFCanvasPanel
---@field FTextBlock_60 UFTextBlock
---@field ImgSubtractTenDisab UFImage
---@field ImgSubtractTenDisab2 UFImage
---@field ImgSubtractTenNormal UFImage
---@field ImgSubtractTenNormal2 UFImage
---@field Money1 CommMoneySlotView
---@field PanelMoney UFCanvasPanel
---@field PanelText UFCanvasPanel
---@field RichTextTips URichTextBox
---@field TableViewList UTableView
---@field TextSubtractTen UFTextBlock
---@field TextSubtractTen2 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogShopWinView = LuaClass(UIView, true)

function CraftingLogShopWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnSubtractTen1 = nil
	--self.BtnSubtractTen2 = nil
	--self.CommAmountSlider = nil
	--self.CommBtnM = nil
	--self.CommMoneyBar = nil
	--self.FCanvasPanel1 = nil
	--self.FCanvasPanel2 = nil
	--self.FTextBlock_60 = nil
	--self.ImgSubtractTenDisab = nil
	--self.ImgSubtractTenDisab2 = nil
	--self.ImgSubtractTenNormal = nil
	--self.ImgSubtractTenNormal2 = nil
	--self.Money1 = nil
	--self.PanelMoney = nil
	--self.PanelText = nil
	--self.RichTextTips = nil
	--self.TableViewList = nil
	--self.TextSubtractTen = nil
	--self.TextSubtractTen2 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogShopWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CommAmountSlider)
	self:AddSubView(self.CommBtnM)
	self:AddSubView(self.CommMoneyBar)
	self:AddSubView(self.Money1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CraftingLogShopWinView:OnInit()
	self.ViewModel = _G.CraftingLogShopWinVM
	self.TextTitle:SetText(_G.LSTR(80070))--整组购买
	self.CommBtnM:SetButtonText(_G.LSTR(240080))--购买
	self.TextSubtractTen:SetText("-10")-- 不需要多语言
	self.TextSubtractTen2:SetText("+10")
	self.Adapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money1, true)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money2,  false )
	UIUtil.SetIsVisible(self.CommMoneyBar.Money3,  false)
end

function CraftingLogShopWinView:OnDestroy()
	
end

function CraftingLogShopWinView:OnShow()
	self.BG:SetTitleText(_G.LSTR(80069))--一键商会购买
	self.CommMoneyBar.Money1:UpdateView(SCORE_TYPE.SCORE_TYPE_GOLD_CODE, false, nil, true)
	self.CommAmountSlider:SetValueChangedCallback(function (v) self.ViewModel:SetGroupNum(v) end)
	self.CommAmountSlider:SetSliderValueMaxMin(99, 1)
	self.CommAmountSlider:SetSliderValue(1)
	self.ViewModel:UpdataShoppingList()
end

function CraftingLogShopWinView:OnHide()

end

function CraftingLogShopWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnM, self.OnClickedBuyBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnSubtractTen1, self.OnClickedSubTen)
	UIUtil.AddOnClickedEvent(self, self.BtnSubtractTen2, self.OnClickedAddTen)
end

function CraftingLogShopWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.UpdateScore, self.OnUpdateScoreValue)
end

function CraftingLogShopWinView:OnUpdateScoreValue()
	self.CommMoneyBar.Money1:OnUpdateScoreValue(SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
end

function CraftingLogShopWinView:OnRegisterBinder()
	self.MultiBinders = {
		{
			ViewModel = self.ViewModel,
			Binders = {
				{"ShoppingList", UIBinderUpdateBindableList.New(self, self.Adapter)},
				{"GroupNumText", UIBinderSetText.New(self, self.FTextBlock_60)},
				{"CanGroupBuy", UIBinderValueChangedCallback.New(self, nil, self.OnGroupBuyStateChanged)},
				{"IsEnough", UIBinderValueChangedCallback.New(self, nil, self.OnCostNumIsEnoughChanged)},
			}
		},
		{
			ViewModel = self.CommAmountSlider.ViewModel,
			Binders = {
				{ "Value", UIBinderValueChangedCallback.New(self, nil, self.SetBtnTenState)},
			}
		},
	}
	self:RegisterMultiBinders(self.MultiBinders)
	self.Money1:SetParams({Data = self.ViewModel})
	self.Money1.ScoreID = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
end

function CraftingLogShopWinView:OnGroupBuyStateChanged(CanGroupBuy)
	--置灰可交互
	self.CommAmountSlider.BtnAdd:SetIsDisabledState(not CanGroupBuy)
	self.CommAmountSlider.BtnSub:SetIsDisabledState(not CanGroupBuy)
	--self:SetSliderDisableState(not CanGroupBuy)
	self:SetTenBtnDisableState(not CanGroupBuy)
end

function CraftingLogShopWinView:OnCostNumIsEnoughChanged(IsEnough)
    if IsEnough == false then
        UIUtil.TextBlockSetColorAndOpacityHex(self.Money1.TextMoneyAmount,TextColor[2])
        self:SetBuyBtnState(false, true)
    else
        UIUtil.TextBlockSetColorAndOpacityHex(self.Money1.TextMoneyAmount,TextColor[1])
        self:SetBuyBtnState(true, true)
    end
end

function CraftingLogShopWinView:SetBuyBtnState(Value, IsCanBuy)
	if IsCanBuy then
		if Value then
			self.CommBtnM:SetIsRecommendState(true)
		else
			self.CommBtnM:SetIsDisabledState(true, true)
		end
	else
		self.CommBtnM:SetIsDisabledState(true, true)
	end
end

function CraftingLogShopWinView:OnClickedBuyBtn()
	--满足购买和使用条件
	local IsEnough = self.ViewModel.IsEnough
	local BagIsEnough = self:BagCapacityIsEnough()
	if IsEnough then 
		if BagIsEnough then
			local Items = self.ViewModel.ShoppingList:GetItems()
			if not table.is_nil_empty(Items) then
				local BatchList = {}
				for _, value in pairs(Items) do
					if value.BuyNum > 0 then
						table.insert(BatchList, {GoodID = value.GoodsID, Num = value.BuyNum})
					end
				end
				_G.ShopMgr:SendMsgMallInfoBatchPruchase(BatchList)
			end
			_G.UIViewMgr:HideView(_G.UIViewID.CraftingLogShopWin, true)
		else
			MsgTipsUtil.ShowTips(_G.LSTR("背包容量不足"))
		end
	else
		MsgTipsUtil.ShowTips(_G.LSTR("金币不足"))
	end
end

function CraftingLogShopWinView:BagCapacityIsEnough()
	local BagCapacity = _G.BagMgr:GetBagLeftNum()
	local GoodsBuyBum = self.ViewModel.GoodsBuyNum
	return BagCapacity >= GoodsBuyBum
end

function CraftingLogShopWinView:OnClickedAddTen()
	local SliderVM = self.CommAmountSlider.ViewModel
	local MaxValueTips = self.CommAmountSlider.MaxValueTips
	local CurValue = SliderVM.Value
	if CurValue + 10 > SliderVM.MaxValue then
		if nil ~= MaxValueTips then
			_G.MsgTipsUtil.ShowTips(MaxValueTips)
		end
		return
	end
	SliderVM:AddSliderValue(10)
end

function CraftingLogShopWinView:OnClickedSubTen()
	local SliderVM = self.CommAmountSlider.ViewModel
	local MinValueTips = self.CommAmountSlider.MinValueTips
	local CurValue = SliderVM.Value
	if CurValue - 10 < SliderVM.MinValue then
		if nil ~= MinValueTips then
			_G.MsgTipsUtil.ShowTips(MinValueTips)
		end
		return
	end
	SliderVM:SubSliderValue(10)
end

function CraftingLogShopWinView:SetBtnTenState(CurValue)
	local SliderVM = self.CommAmountSlider.ViewModel
	if CurValue + 10 > SliderVM.MaxValue then
		self.BtnSubtractTen2:SetIsEnabled(false)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextSubtractTen2, TextColor[3])
	else
		self.BtnSubtractTen2:SetIsEnabled(true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextSubtractTen2, TextColor[1])
	end
	if CurValue - 10 < SliderVM.MinValue then
		self.BtnSubtractTen1:SetIsEnabled(false)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextSubtractTen, TextColor[3])
	else
		self.BtnSubtractTen1:SetIsEnabled(true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextSubtractTen, TextColor[1])
	end
end

function CraftingLogShopWinView:SetTenBtnDisableState(Disable)
    if not Disable then
		local SliderVM = self.CommAmountSlider.ViewModel
		local CurValue = SliderVM.CurValue or 1
		if CurValue + 10 <= SliderVM.MaxValue then
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextSubtractTen2, TextColor[1])
			UIUtil.SetIsVisible(self.ImgSubtractTenDisab, false)
			UIUtil.SetIsVisible(self.ImgSubtractTenNormal, true)
		end
		if CurValue - 10 >= SliderVM.MinValue then
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextSubtractTen, TextColor[1])
			UIUtil.SetIsVisible(self.ImgSubtractTenDisab2, false)
			UIUtil.SetIsVisible(self.ImgSubtractTenNormal2, true)
		end
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextSubtractTen, TextColor[3])
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextSubtractTen2, TextColor[3])
		UIUtil.SetIsVisible(self.ImgSubtractTenDisab, true)
		UIUtil.SetIsVisible(self.ImgSubtractTenNormal, false)
		UIUtil.SetIsVisible(self.ImgSubtractTenDisab2, true)
		UIUtil.SetIsVisible(self.ImgSubtractTenNormal2, false)
	end
end

function CraftingLogShopWinView:SetSliderDisableState(Disable)
    local SliderHorizontal = self.CommAmountSlider.SliderHorizontal
    --SliderHorizontal.Slider:SetLocked(Disable)
	local Color = Disable and "#FFFFFF00" or "#FFFFFFFF"
	local LinearColor = _G.UE.FLinearColor.FromHex(Color)
	SliderHorizontal.Slider:SetSliderHandleColor(LinearColor)
    SliderHorizontal.ProgressBar:SetIsEnabled(not Disable)
end

return CraftingLogShopWinView