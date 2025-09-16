---
--- Author: ds_yangyumian
--- DateTime: 2023-11-16 12:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShopMgr = require("Game/Shop/ShopMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local GoodsCfg = require("TableCfg/MysteryMerchantGoodsCfgCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local CommBtnLView = require("Game/Common/Btn/CommBtnLView")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemUtil = require("Utils/ItemUtil")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local MerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local MysterMerchantUtils = require("Game/MysterMerchant/MysterMerchantUtils")
local MysterMerchantVM = require("Game/MysterMerchant/VM/MysterMerchantVM")
local CounterMgr = require("Game/Counter/CounterMgr")
local BagMgr = _G.BagMgr
local LSTR = _G.LSTR
local ScoreMgr = _G.ScoreMgr

--货币信息
local PriceValueInfo = {}
local TitleText = ""
local BtnText = ""
local ExchangeName = ""
local NotBuyTips = ""

local TextColor = {
	"d1ba8e",--黄
	"dc5868",--红
	"f3f3f399",--灰
	"d5d5d5", -- 白
}

local UpdateTextData = {}

---@class MysterMerchantBuyPropsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BG Comm2FrameMView
---@field BtnBuyConfirm CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnGift CommBtnLView
---@field BtnGoods UFButton
---@field BtnMoney1 UFButton
---@field BtnMoney2 UFButton
---@field BtnMoney3 UFButton
---@field BtnNumber1 UFButton
---@field BtnNumber2 UFButton
---@field BtnPreview UFButton
---@field BtnTips1 UFButton
---@field BtnTips1_1 UFButton
---@field BtnTips2 UFButton
---@field BtnTips2_1 UFButton
---@field FHorizontalSurplus UFHorizontalBox
---@field Goods MysterMerchantGoodsItemView
---@field HorizontalCurrent1 UFHorizontalBox
---@field HorizontalCurrent2 UFHorizontalBox
---@field HorizontalCurrent3 UFHorizontalBox
---@field HorizontalPrice UFHorizontalBox
---@field ImgMoney1 UFImage
---@field ImgMoney2 UFImage
---@field ImgMoney3 UFImage
---@field ImgPreview UFImage
---@field NumberPanel1 UFCanvasPanel
---@field NumberPanel2 UFCanvasPanel
---@field PanelBuySetting UFCanvasPanel
---@field PanelItem UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field TextAmount UFTextBlock
---@field TextCurrentPrice1 UFTextBlock
---@field TextCurrentPrice2 UFTextBlock
---@field TextCurrentPrice3 UFTextBlock
---@field TextItemDescription URichTextBox
---@field TextItemName UFTextBlock
---@field TextItemType URichTextBox
---@field TextNumWin UFTextBlock
---@field TextNumber1 UFTextBlock
---@field TextNumber2 UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextSoldout UFTextBlock
---@field TextSurplus URichTextBox
---@field TextSurplus_2 UFTextBlock
---@field TextWear UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MysterMerchantBuyPropsWinView = LuaClass(UIView, true)

function MysterMerchantBuyPropsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BG = nil
	--self.BtnBuyConfirm = nil
	--self.BtnCancel = nil
	--self.BtnGift = nil
	--self.BtnGoods = nil
	--self.BtnMoney1 = nil
	--self.BtnMoney2 = nil
	--self.BtnMoney3 = nil
	--self.BtnNumber1 = nil
	--self.BtnNumber2 = nil
	--self.BtnPreview = nil
	--self.BtnTips1 = nil
	--self.BtnTips1_1 = nil
	--self.BtnTips2 = nil
	--self.BtnTips2_1 = nil
	--self.FHorizontalSurplus = nil
	--self.Goods = nil
	--self.HorizontalCurrent1 = nil
	--self.HorizontalCurrent2 = nil
	--self.HorizontalCurrent3 = nil
	--self.HorizontalPrice = nil
	--self.ImgMoney1 = nil
	--self.ImgMoney2 = nil
	--self.ImgMoney3 = nil
	--self.ImgPreview = nil
	--self.NumberPanel1 = nil
	--self.NumberPanel2 = nil
	--self.PanelBuySetting = nil
	--self.PanelItem = nil
	--self.PanelOriginal = nil
	--self.TextAmount = nil
	--self.TextCurrentPrice1 = nil
	--self.TextCurrentPrice2 = nil
	--self.TextCurrentPrice3 = nil
	--self.TextItemDescription = nil
	--self.TextItemName = nil
	--self.TextItemType = nil
	--self.TextNumWin = nil
	--self.TextNumber1 = nil
	--self.TextNumber2 = nil
	--self.TextOriginalPrice = nil
	--self.TextSoldout = nil
	--self.TextSurplus = nil
	--self.TextSurplus_2 = nil
	--self.TextWear = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MysterMerchantBuyPropsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBuyConfirm)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnGift)
	self:AddSubView(self.Goods)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MysterMerchantBuyPropsWinView:OnInit()
	self.MaxNum = nil
	self.GoodsId = nil
	self.BoughtCount = nil
	self.CurNum = nil
	self.IsDiscount = false
	self.CurrentPanelList = {self.HorizontalCurrent1,self.HorizontalCurrent2,self.HorizontalCurrent3}
	self.MoneyImgList = {self.ImgMoney1,self.ImgMoney2,self.ImgMoney3}
	self.MoneyTextList = {self.TextCurrentPrice1,self.TextCurrentPrice2,self.TextCurrentPrice3}
	self.MoneyBtnList = {self.BtnMoney1,self.BtnMoney2,self.BtnMoney3}
	self.NumberPanelList = {self.NumberPanel1,self.NumberPanel2}
	self.BindingList = nil
	self.IsCanBuy = true
end

function MysterMerchantBuyPropsWinView:OnDestroy()

end

function MysterMerchantBuyPropsWinView:SetLSTR()
	self.BG:SetTitleText(_G.LSTR(1110019)) -- 1110019("商品购买")
	self.BtnCancel:SetButtonText(_G.LSTR(1110012)) -- 1110012("取消")
	self.BtnBuyConfirm:SetButtonText(_G.LSTR(1110040)) -- 1110040("确认购买")
	self.TextAmount:SetText(1)
end

function MysterMerchantBuyPropsWinView:OnShow()
	self:SetLSTR()
	self.AllSurplus = 0
	self.CurNum = 1
	self.GoodsId = self.Params.GoodsId
	self.BoughtCount = self.Params.BoughtCount
	self.RestrictionType = self.Params.RestrictionType
	self.LimitNum = self.Params.LimitNum -- self.Params.CounterInfo
	self.IsCanBuy = self.Params.IsCanBuy
	self.BuyDes = self.Params.bBuyDesc
	self.GoldCoinPrice = self.Params.GoldCoinPrice
	self.ItemID = self.Params.ItemID
	self.ItemName = self.Params.Name
	self.BuyCallback = self.Params.BuyCallback
	--self.ViewModel:UpdateVM(self.GoodsId,self.BoughtCount)
	UIUtil.SetIsVisible(self.TextWear, false)
	UIUtil.SetIsVisible(self.BtnGift, false, true)
	UIUtil.SetIsVisible(self.BtnCancel, true, true)
	UIUtil.SetIsVisible(self.BtnPreview, self.Params.IsCanPreView, true)
	-- UIUtil.SetIsVisible(self.BtnBuyConfirm.ImgNormal, false)
	-- UIUtil.SetIsVisible(self.BtnBuyConfirm.ImgRecommend, false)
	-- UIUtil.SetIsVisible(self.BtnBuyConfirm.ImgDisable, true)
	-- UIUtil.SetIsVisible(self.BtnBuyConfirm.ProBarLongPress, false)

	local ScoreID = MysterMerchantVM.CoinID
	--self.MoneySlot:UpdateView(ScoreID, false, nil, true)
	self:UpdateGoodsInfo()
end

function MysterMerchantBuyPropsWinView:OnHide()
	self.TextAmount:SetText(1)
	if UIViewMgr:IsViewVisible(UIViewID.ItemTipsStatus) then
		UIViewMgr:HideView(UIViewID.ItemTipsStatus)
	end

	PriceValueInfo = {}
end

function MysterMerchantBuyPropsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuyConfirm, self.OnClickedConfirmBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnGoods, self.OnClickedBtnGoods)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnNumber1, self.OnClickedBtnNumber1)
	UIUtil.AddOnClickedEvent(self, self.BtnNumber2, self.OnClickedBtnNumber2)
	UIUtil.AddOnClickedEvent(self, self.BtnTips1, self.OnClickedBtnTips1)
	UIUtil.AddOnClickedEvent(self, self.BtnTips2, self.OnClickedBtnTips2)
	UIUtil.AddOnClickedEvent(self, self.BtnTips1_1, self.OnClickedBtnTips1)
	UIUtil.AddOnClickedEvent(self, self.BtnTips2_1, self.OnClickedBtnTips2)
	UIUtil.AddOnClickedEvent(self, self.BtnPreview, self.OnClickedBtnPreview)
	for i = 1, 3 do
		UIUtil.AddOnClickedEvent(self, self.MoneyBtnList[i], self.ShowPirceTips, i)
	end
end

function MysterMerchantBuyPropsWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScoreUpdate, self.UpdateTextColor)
end

function MysterMerchantBuyPropsWinView:OnRegisterBinder()

end

function MysterMerchantBuyPropsWinView:UpdateGoodsInfo()
	local Cfg = ItemCfg:FindCfgByKey(self.ItemID)
	if Cfg == nil then
		FLOG_ERROR("UpdateGoodsInfo Cfg == nil")
		return
	end
	local IconID = Cfg.IconID
	local ItemName = self.ItemName
	local ItemColor = Cfg.ItemColor
	local ItemType = Cfg.ItemType
	local IsHQ = Cfg.IsHQ

	local GCfg = GoodsCfg:FindCfgByKey(self.GoodsId)
	local OnceLimitation = GCfg.OnceLimitation
	local DiscountInfo = {}

	DiscountInfo.Discount = GCfg.Discount
	-- DiscountInfo.DiscountDurationStart = ShopMgr:GetTimeInfo(GCfg.DiscountDurationStart)
	-- DiscountInfo.DiscountDurationEnd = ShopMgr:GetTimeInfo(GCfg.DiscountDurationEnd )
	local QuotaInfo = {}
	QuotaInfo.RestrictionType = self.RestrictionType
	QuotaInfo.RestrictionCount = GCfg.RestrictionCount
	QuotaInfo.BoughtCount = self.BoughtCount
	-- QuotaInfo.CounterFirstID = GCfg.GoodsCounterFirst
	-- QuotaInfo.CounterSecondID = GCfg.GoodsCounterSecond
	local ScoreIDCfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_MERCHANT_GOODS_COST_COINID)
	local ScoreID = ScoreIDCfg and ScoreIDCfg.Value[1] or 19000002
	local PriceInfo = {
		{
			Type = ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE,
			ID = ScoreID,
			Count = GCfg.PriceCount,
		},
	} --GCfg.Price
	self.Discount = GCfg.Discount
	self.Exchange = GCfg.Exchange
	self.Obtain = GCfg.Obtain
	self.IsPop = GCfg.PopOut
	if IsHQ == 1 then
		UIUtil.SetIsVisible(self.PanelHQ,true)
	else
		UIUtil.SetIsVisible(self.PanelHQ,false)
	end

	local QualityPath = MerchantDefine.ItemColor[ItemColor]
	self.TextItemName:SetText(ItemName)
	self.TextItemType:SetText(ProtoEnumAlias.GetAlias(ProtoCommon.ITEM_TYPE_DETAIL, ItemType or ""))
	self.TextItemDescription:SetText(ItemCfg:GetItemDesc(self.ItemID))
	local IconPath = ItemCfg.GetIconPath(IconID)
	-- UIUtil.ImageSetBrushFromAssetPath(self.ImgGoods,IconPath)
	-- UIUtil.ImageSetBrushFromAssetPath(self.ImgQuality,QualityPath)

	local PanelList = self.NumberPanelList
	local ShowNumsSelect = GCfg.ShowNumsSelect
	self.ShowNumsSelect = ShowNumsSelect
	for i = 1, #PanelList do 
		if ShowNumsSelect == 1 then
			--UIUtil.SetIsVisible(PanelList[i],true)
			UIUtil.SetIsVisible(self.BtnNumber1, true, true)
			UIUtil.SetIsVisible(self.BtnTips1, true, true)
			UIUtil.SetIsVisible(self.TextNumber1, true)
			UIUtil.SetIsVisible(self.BtnNumber2, true, true)
			UIUtil.SetIsVisible(self.BtnTips2, true, true)
			UIUtil.SetIsVisible(self.TextNumber2, true)
		else
			--UIUtil.SetIsVisible(PanelList[i],false)
			UIUtil.SetIsVisible(self.BtnNumber1, false, true)
			UIUtil.SetIsVisible(self.BtnTips1, false, true)
			UIUtil.SetIsVisible(self.TextNumber1, false)
			UIUtil.SetIsVisible(self.BtnNumber2, false, true)
			UIUtil.SetIsVisible(self.BtnTips2, false, true)
			UIUtil.SetIsVisible(self.TextNumber2, false)
		end
	end
	
	if OnceLimitation == 1 then
		-- for i = 1,#PanelList do 
		-- 	UIUtil.SetIsVisible(PanelList[i],false)
		-- end
		self.AmountSlider:SetBtnIsShow(false)
	else
		-- for i = 1,#PanelList do 
		-- 	UIUtil.SetIsVisible(PanelList[i],true)
		-- end
		self.AmountSlider:SetBtnIsShow(true)
	end
	--self.SetNumberPanel(PanelList)
	--self.SetNumberPanelByOnceLimitation(PanelList,OnceLimitation)
	self:SetTitle()
	self:SetDiscount(DiscountInfo)
	self:SetQuota(QuotaInfo, OnceLimitation)
	self:SetPriceInfo(PriceInfo)
	self:SetOverlayNum()

	--根据是否可购买来判断按钮状态
	local isCanUse,UseDes,NotBuyType = MysterMerchantUtils.IsCanUse(self.GoodsId)
	self.NotBuyType = NotBuyType
	self.IsCanUse = isCanUse
	if NotBuyType == 0 then
		self.IsCanUse = true
	end

	if self.IsCanBuy then
		UIUtil.SetIsVisible(self.TextAmount, true)
		UIUtil.SetIsVisible(self.AmountSlider, true, true)
		UIUtil.SetIsVisible(self.HorizontalPrice, true, true)
		--UIUtil.SetIsVisible(self.NumberPanel1,true,true)
		--UIUtil.SetIsVisible(self.NumberPanel2,true,true)
		self:IsCurNumMax(1,self.MaxNum)
		self:SetSlider()

		if not isCanUse then
			UIUtil.SetIsVisible(self.TextSoldout, true)
			self.TextSoldout:SetText(UseDes)
			self.BuyDes = UseDes
		else
			UIUtil.SetIsVisible(self.TextSoldout, false)
		end
	else
		UIUtil.SetIsVisible(self.TextAmount, false)
		UIUtil.SetIsVisible(self.TextSoldout, true)
		UIUtil.SetIsVisible(self.AmountSlider, false, true)
		-- UIUtil.SetIsVisible(self.NumberPanel1, false, true)
		-- UIUtil.SetIsVisible(self.NumberPanel2, false, true)
		UIUtil.SetIsVisible(self.BtnNumber1, false, true)
		UIUtil.SetIsVisible(self.BtnTips1, false, true)
		UIUtil.SetIsVisible(self.BtnTips1_1, false, true)
		UIUtil.SetIsVisible(self.TextNumber1, false)
		UIUtil.SetIsVisible(self.BtnNumber2, false, true)
		UIUtil.SetIsVisible(self.BtnTips2, false, true)
		UIUtil.SetIsVisible(self.BtnTips2_1, false, true)
		UIUtil.SetIsVisible(self.TextNumber2, false)
		UIUtil.SetIsVisible(self.BtnTips1,false, true)
		UIUtil.SetIsVisible(self.BtnTips2,false, true)

		if self.IsSoldout then
			if self.AllSurplus <= 0 then
				UIUtil.SetIsVisible(self.HorizontalPrice, false, true) 
				self.TextSoldout:SetText(LSTR(1110016))--商品已售罄
			else
				self.TextSoldout:SetText("")
				UIUtil.SetIsVisible(self.HorizontalPrice, true, true) 
			end
		else
			self.TextSoldout:SetText(self.BuyDes)
			UIUtil.SetIsVisible(self.HorizontalPrice, false, true) 
		end
	end

	local GoodsInfo = self.Params
	GoodsInfo.IsBuyView = true
	self.Goods:SetParams({Data = GoodsInfo})
	self.Goods:SetBuyViewItemState(false)
end

function MysterMerchantBuyPropsWinView:SetTitle()
	TitleText = LSTR(1110019)--商品购买
	BtnText = LSTR(1110040)--确认购买
	ExchangeName = LSTR(1110030)--是否继续进行购买
	NotBuyTips = LSTR(1110029)--无法购买

	self.BG:SetTitleText(TitleText)
	self.BtnBuyConfirm:SetButtonText(BtnText)
end

function MysterMerchantBuyPropsWinView:SetDiscount(Info)
	-- if Info.DiscountDurationEnd > 0 and Info.DiscountDurationStart > 0 then
    --     local ServerTime = TimeUtil.GetServerTime() --秒
	-- 	local IsStart = ServerTime - Info.DiscountDurationStart
    --     local RemainSeconds = Info.DiscountDurationEnd - ServerTime
    --     local DayCostSec = 24 * 60 * 60
    --     local RemainDay = math.ceil(RemainSeconds / DayCostSec)
    --     if RemainDay > 0 and IsStart > 0 and Info.Discount and Info.Discount ~= 100 then
	-- 		UIUtil.SetIsVisible(self.PanelDiscount, true)
	-- 		local DiscountValue = string.format(LSTR(1110002), math.floor(Info.Discount / 10))
	-- 		self.IsDiscount = true
	-- 		self.TextDiscount:SetText(DiscountValue)
	-- 	else
	-- 		self.IsDiscount = false
	-- 		UIUtil.SetIsVisible(self.PanelDiscount, false)
    --     end
	-- else
	if Info.Discount > 0 and Info.Discount < 100 then
		self.IsDiscount = true
		UIUtil.SetIsVisible(self.PanelDiscount, true)
		local DiscountValue = string.format(LSTR(1110002), math.floor(Info.Discount / 10))--%d折
		--self.TextDiscount:SetText(DiscountValue)
	else
		self.IsDiscount = false
		UIUtil.SetIsVisible(self.PanelDiscount, false)
    end
end

function MysterMerchantBuyPropsWinView:SetOverlayNum(OnceLimitation)
	UIUtil.SetIsVisible(self.TextNumWin, false) -- 先隐藏
	-- local CurOpneShopID = ShopMgr.CurOpenMallId or ShopMgr.CurQueryShopID
	-- local GoodsInfo = ShopMgr:GetGoodsInfo(CurOpneShopID, self.GoodsId)
	-- if GoodsInfo then
	-- 	self.OverlayNum = GoodsInfo.Items[1].Num
	-- 	ShopMgr.OverlayNum = self.OverlayNum or 0
	-- 	ShopMgr.OnceLimitation = OnceLimitation or 0
	-- 	if self.OverlayNum > 1 then
	-- 		UIUtil.SetIsVisible(self.TextNumWin, true)
	-- 		self.TextNumWin:SetText(self.OverlayNum)
	-- 	else
	-- 		UIUtil.SetIsVisible(self.TextNumWin, false)
	-- 	end
	-- end
end

function MysterMerchantBuyPropsWinView:SetQuota(QuotaInfo, OnceLimitation)
	if QuotaInfo.RestrictionType and QuotaInfo.RestrictionType ~= 0 then
		UIUtil.SetIsVisible(self.FHorizontalSurplus, true)
		local QuotaTtitle = MerchantDefine.LimitBuyNumTipsTitle[QuotaInfo.RestrictionType]
		local CanBuyCount = QuotaInfo.RestrictionCount - QuotaInfo.BoughtCount  --可购买-已购买
		local CurrentRestore = QuotaInfo.RestrictionCount -- CounterMgr:GetCounterRestore(QuotaInfo.CounterFirstID)
		--local AllSurplus = 0
		if CanBuyCount <= 0 then
			self.IsSoldout = true
			--双限购剩余显示处理
			-- if QuotaInfo.CounterSecondID and QuotaInfo.CounterSecondID ~= 0 then		
			-- 	local SecondLimit = CounterMgr:GetCounterLimit(QuotaInfo.CounterSecondID)
			-- 	local CounterSecondNum = self.LimitNum -- self.CounterInfo.CounterSecond.CounterNum
			-- 	AllSurplus = math.max(0, SecondLimit - CounterSecondNum) 
			-- 	self.AllSurplus = AllSurplus

			-- 	if AllSurplus > 0 then
			-- 		UIUtil.SetIsVisible(self.TextWear, true)
			-- 		self.TextWear:SetText(string.format("%s:%d", LSTR(1110015), AllSurplus))--商品剩余量
			-- 	end
			-- end
		else
			self.IsSoldout = false
			-- if QuotaInfo.CounterSecondID and QuotaInfo.CounterSecondID ~= 0 then
			-- 	UIUtil.SetIsVisible(self.TextWear, true)
			-- 	local SecondLimit = CounterMgr:GetCounterLimit(QuotaInfo.CounterSecondID)
			-- 	local CounterSecondNum = self.LimitNum --self.CounterInfo.CounterSecond.CounterNum
			-- 	AllSurplus = math.max(0, SecondLimit - CounterSecondNum)
			-- 	self.AllSurplus = AllSurplus
			-- 	self.TextWear:SetText(string.format("%s:%d", LSTR(1110015), AllSurplus)) --商品剩余量
			-- end
		end

		self.MaxNum = CanBuyCount
		if self.IsSoldout then
			UIUtil.SetIsVisible(self.TextSurplus, false)
		else
			UIUtil.SetIsVisible(self.TextSurplus, true)
			if CanBuyCount == 0 then
				local Text = string.format("<span color=\"#f3f3f399\">%s</><span color=\"#dc5868\">%d</><span color=\"#f3f3f399\">/%d</>", QuotaTtitle, CanBuyCount, CurrentRestore)
				self.TextSurplus:SetText(Text)
			else
				local Text = string.format("<span color=\"#f3f3f399\">%s%d/%d</>", QuotaTtitle, CanBuyCount, CurrentRestore)
				self.TextSurplus:SetText(Text)
			end
		end
	else
		self.IsSoldout = false
		self.MaxNum = OnceLimitation
		UIUtil.SetIsVisible(self.TextWear, false)
		UIUtil.SetIsVisible(self.FHorizontalSurplus, false)
	end
	
end

function MysterMerchantBuyPropsWinView:SetBindState()
	local Item = ItemUtil.CreateItem(self.ItemID, 0)
	--ItemTipsUtil.ShowTipsByItem(Item, self.ImgGoods)
end

function MysterMerchantBuyPropsWinView:SetPriceInfo(PriceInfo)
	local PriceValue = 0
	for i = 1,#PriceInfo do
		if PriceInfo[i].ID ~= 0 then
			UIUtil.SetIsVisible(self.CurrentPanelList[i], true)
			if self.Shoptype == 1 then
				PriceValue = self.GoldCoinPrice
			else
				PriceValue = PriceInfo[i].Count
			end

			PriceValueInfo[i] = {}
			PriceValueInfo[i].ID = PriceInfo[i].ID
			PriceValueInfo[i].Type = PriceInfo[i].Type
			if self.IsDiscount then
				UIUtil.SetIsVisible(self.PanelOriginal, true)
				local NewPrice = math.ceil(PriceValue * (self.Discount / 100))
				PriceValueInfo[i].Count = NewPrice
				PriceValueInfo[i].OriginalPrice = PriceValue
				local IsEnough = self:ScoreIsEnough(PriceValueInfo[i])
				if IsEnough == false then
					UIUtil.TextBlockSetColorAndOpacityHex(self.MoneyTextList[i], TextColor[2])
					self:SetBuyBtnState(false, self.IsCanBuy)
				else
					UIUtil.TextBlockSetColorAndOpacityHex(self.MoneyTextList[i], TextColor[1])
					self:SetBuyBtnState(true, self.IsCanBuy)
				end
				self.MoneyTextList[i]:SetText(ScoreMgr.FormatScore(string.format("%d",NewPrice)))
				self.TextOriginalPrice:SetText(ScoreMgr.FormatScore(PriceValue))
			else
				PriceValueInfo[i].Count = PriceValue
				local IsEnough = self:ScoreIsEnough(PriceValueInfo[i])
				if IsEnough == false then
					UIUtil.TextBlockSetColorAndOpacityHex(self.MoneyTextList[i],TextColor[2])
					self:SetBuyBtnState(false, self.IsCanBuy)
				else
					UIUtil.TextBlockSetColorAndOpacityHex(self.MoneyTextList[i],TextColor[1])
					self:SetBuyBtnState(true, self.IsCanBuy)
				end
				self.MoneyTextList[i]:SetText(ScoreMgr.FormatScore(PriceValue))
				UIUtil.SetIsVisible(self.PanelOriginal, false)
			end

			local IconPath = ""
			if PriceInfo[i].Type == ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE then
				IconPath = ScoreMgr:GetScoreIconName(PriceInfo[i].ID)
			else
				local Cfg = ItemCfg:FindCfgByKey(PriceInfo[i].ID)
				IconPath = UIUtil.GetIconPath(Cfg.IconID)
			end
			UIUtil.ImageSetBrushFromAssetPath(self.MoneyImgList[i], IconPath)
			local Params = {}
			Params.Index = i
			Params.ScoreID = PriceInfo[i].ID
			--UIUtil.AddOnClickedEvent(self, self.MoneyBtnList[i], self.ShowPirceTips, Params)
		else
			UIUtil.SetIsVisible(self.CurrentPanelList[i], false)
		end
	end
end

function MysterMerchantBuyPropsWinView:SetSlider()
	self.AmountSlider:SetSliderValueMaxMin(self.MaxNum, 1)
	--self.AmountSlider:SetSliderValueMaxTips(LSTR(1110028))--数量超出范围
	--self.AmountSlider:SetSliderValueMinTips(LSTR(1110028))--数量超出范围
	self.AmountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v, self.MaxNum)
	end)
end

function MysterMerchantBuyPropsWinView:SetNumberPanel(PanelList)
	--走配置 显示便携数量选择
	local IsShow = true
	for i = 1,#PanelList do 
		UIUtil.SetIsVisible(PanelList[i], IsShow)
	end
end

function MysterMerchantBuyPropsWinView:SetNumberPanelByOnceLimitation(PanelList,OnceLimitation)
	--走配置
	if OnceLimitation == 1 then
		local IsShow = false
		for i = 1,#PanelList do 
			UIUtil.SetIsVisible(PanelList[i], IsShow)
		end
		self.AmountSlider:SetBtnIsShow(IsShow)
	end
end


function MysterMerchantBuyPropsWinView:OnValueChangedSlider(Value,MaxNum)
	self.CurNum = Value 
	self.TextAmount:SetText(Value)
	self:IsCurNumMax(Value,MaxNum)
	self:UpdatePriceInfo(Value)

	for i = 1,#PriceValueInfo do
		local IsEnough = self:ScoreIsEnough(PriceValueInfo[i])
		if IsEnough == false then
			UIUtil.TextBlockSetColorAndOpacityHex(self.MoneyTextList[i],TextColor[2])
			self:SetBuyBtnState(false, self.IsCanBuy)
		else
			UIUtil.TextBlockSetColorAndOpacityHex(self.MoneyTextList[i],TextColor[1])
			self:SetBuyBtnState(true, self.IsCanBuy)
		end
	end
end

function MysterMerchantBuyPropsWinView:IsCurNumMax(CurNum,MaxNum)
	if CurNum >= MaxNum and MaxNum ~= 1 then
		self.BtnNumber2:SetIsEnabled(false)
		if self.ShowNumsSelect == 1 then
			UIUtil.SetIsVisible(self.BtnTips2,true, true)
		end
		UIUtil.SetIsVisible(self.BtnTips2_1,true, true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNumber2,TextColor[3])
	else
		self.BtnNumber2:SetIsEnabled(true)
		UIUtil.SetIsVisible(self.BtnTips2,false, true)
		UIUtil.SetIsVisible(self.BtnTips2_1,false, true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNumber2,TextColor[1])
	end

	if CurNum <= 1 and MaxNum ~= 1 then
		self.BtnNumber1:SetIsEnabled(false)
		if self.ShowNumsSelect == 1 then
			UIUtil.SetIsVisible(self.BtnTips1, true, true)
		end
		UIUtil.SetIsVisible(self.BtnTips1_1,true, true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNumber1,TextColor[3])
	else
		self.BtnNumber1:SetIsEnabled(true)
		UIUtil.SetIsVisible(self.BtnTips1, false, true)
		UIUtil.SetIsVisible(self.BtnTips1_1,false, true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNumber1,TextColor[1])
	end
end

function MysterMerchantBuyPropsWinView:OnClickedConfirmBtn()
	--满足购买和使用条件
	if self.IsCanBuy and self.IsCanUse then
		local IsEnough,ScoreID,SupCount,Name,Index = self:ScoreIsEnough()
		local BagIsEnough,Tips = self:BagCapacityIsEnough()
		if IsEnough then 
			if BagIsEnough then
				self:GoonBuy()
			else
				MsgTipsUtil.ShowTips(Tips)
				self:Hide()
			end
		else
			if self.Exchange == 1 then
				if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_SILVER_CODE or ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
					local NeedValue = ScoreMgr.FormatScore(SupCount)
					local ScoreName = RichTextUtil.GetText(string.format("%s%s",NeedValue,Name),TextColor[1])
					local Content = string.format("%s%s,%s", LSTR(1110025), ScoreName, LSTR(1110031))--您还需要 --是否进行兑换
					local function  Callback()
						local Data = {}
						Data.ScoreID = ScoreID
						Data.NeedCount = SupCount
						Data.Index = Index
						UpdateTextData = Data
						UIViewMgr:ShowView(UIViewID.ShopExchangeWinNew, Data)
						--self:Hide()
					end
					MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1110044), Content, Callback, nil, LSTR(1110012),  LSTR(1110039))--货币不足--取消--确定
				else
					local ScoreName = Name
					local Tips = string.format("%s%s,%s",ScoreName,LSTR(1110006),NotBuyTips)--不足
					MsgTipsUtil.ShowTips(Tips)
					self:Hide()
				end
			elseif self.Obtain == 1 then
				local NeedValue = ScoreMgr.FormatScore(SupCount)
				local ScoreName = RichTextUtil.GetText(string.format("%s%s",NeedValue,Name),TextColor[1])
				local Content = string.format("%s%s,%s", LSTR(1110025), ScoreName, LSTR(1110032))--您还需要--是否进行获取
				MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1110044), Content, nil, nil, LSTR(1110012),  LSTR(1110039))--货币不足--取消--确定
				self:Hide()
			else
				local ScoreName = Name
				local Tips = string.format("%s%s,%s",ScoreName,LSTR(1110006),NotBuyTips)--不足
				MsgTipsUtil.ShowTips(Tips)
				self:Hide()
			end		
		end
	--满足购买但不满足使用条件
	elseif self.IsCanBuy and not self.IsCanUse then
		--弹窗提示
		local IsEnough,ScoreID,SupCount,Name,Index = self:ScoreIsEnough()
		local BagIsEnough,Tips = self:BagCapacityIsEnough()
		if IsEnough then 
			if BagIsEnough then
				local Content = ""
				local Tips = self:GetTipsContent()
				Content = string.format("%s,%s", Tips, ExchangeName)
				local function Callback()
					self:GoonBuy()
				end
				MsgBoxUtil.ShowMsgBoxTwoOp(self, TitleText, Content, Callback, nil, LSTR(1110012), BtnText)--取消
			else 
				MsgTipsUtil.ShowTips(Tips)
				self:Hide()
			end
		else
			if self.Exchange == 1 then
				if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_SILVER_CODE or ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
					local NeedValue = ScoreMgr.FormatScore(SupCount)
					local ScoreName = RichTextUtil.GetText(string.format("%s%s",NeedValue,Name),TextColor[1])
					local Content = string.format("%s%s,%s", LSTR(1110025), ScoreName, LSTR(1110031))--您还需要 --是否进行兑换
					local function  Callback()
						local Data = {}
						Data.ScoreID = ScoreID
						Data.NeedCount = SupCount
						Data.Index = Index
						UpdateTextData = Data
						UIViewMgr:ShowView(UIViewID.ShopExchangeWinNew, Data)
					end
					MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1110044), Content, Callback, nil, LSTR(1110012),  LSTR(1110039))--货币不足--取消--确定
				else
					local ScoreName = Name
					local Tips = string.format("%s%s,%s",ScoreName,LSTR(1110006),NotBuyTips)--不足
					MsgTipsUtil.ShowTips(Tips)
					self:Hide()
				end
			elseif self.Obtain == 1 then
				local NeedValue = ScoreMgr.FormatScore(SupCount)
				local ScoreName = RichTextUtil.GetText(string.format("%s%s",NeedValue,Name),TextColor[1])
				local Content = string.format("%s%s,%s", LSTR(1110025), ScoreName, LSTR(1110032))--您还需要--是否进行获取
				MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1110044), Content, nil, nil, LSTR(1110012),  LSTR(1110039))--货币不足--取消--确定
				self:Hide()
			else
				local ScoreName = Name
				local Tips = string.format("%s%s,%s",ScoreName,LSTR(1110006),NotBuyTips)--不足
				MsgTipsUtil.ShowTips(Tips)
				self:Hide()
			end
		end
	--售罄
	elseif self.IsSoldout then
		local Tips = ""
		if self.TypeState == 1 then
			Tips = LSTR(1110017)--商品已售罄，无法交换
		else
			Tips = LSTR(1110018)--商品已售罄，无法购买
		end
		MsgTipsUtil.ShowTips(Tips)
		self:Hide()
	--不可购买
	elseif not self.IsCanBuy then
		local Tips = ""
		if self.TypeState == 1 then
			Tips = LSTR(1110004)--不满足购买条件，无法交换
		else
			Tips = LSTR(1110005)--不满足购买条件，无法购买
		end
		MsgTipsUtil.ShowTips(Tips)
		-- self:Hide()
	end
end

function MysterMerchantBuyPropsWinView:GetTipsContent()
	local Tips = ""
	if self.NotBuyType == 1 then
		Tips = self.BuyDes
	elseif self.NotBuyType == 2 then
		-- local Title1 = LSTR(1110043)--该商品为
		-- local Name = LSTR(1110024)--幻想药
		-- local Changed = LSTR(1110027)--改变种族
		-- local Test = LSTR(1110013)--可通过
		-- local Title2 = RichTextUtil.GetText(string.format("%s", self.BuyDes), TextColor[1])
		-- local Name2 = RichTextUtil.GetText(string.format("[%s]", Name), TextColor[1])
		-- local Text = string.format("%s%s,%s%s,%s",Title1,Title2,Test,Name2,Changed)
		Tips = self.BuyDes
	elseif self.NotBuyType == 3 then
		-- local Title1 = LSTR(1110043)--该商品为
		-- local Title2 = RichTextUtil.GetText(string.format("%s", self.BuyDes), TextColor[1])
		-- local Name = RichTextUtil.GetText(string.format("[%s]", LSTR(1110003)), TextColor[1])--[幻想药]
		-- local Text = string.format("%s%s,%s%s%,%s", Title1, Title2, LSTR(1110013), Name, LSTR(1110020))--可通过--实现性别更替
		Tips = self.BuyDes
	elseif self.NotBuyType == 4 then
		Tips = self.BuyDes
	end
	return Tips
end

function MysterMerchantBuyPropsWinView:ScoreIsEnough(PriceInfo)
	local IsEnough = false
	local NoEnoughID = 0
	local SupCount = 0
	local Name = ""
	if PriceInfo ~= nil and PriceInfo.ID ~= 0 then
		local HasCount = 0
		if PriceInfo.Type == ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE then
			HasCount = ScoreMgr:GetScoreValueByID(PriceInfo.ID)
			Name = ScoreMgr:GetScoreNameText(PriceInfo.ID)
		else
			HasCount = BagMgr:GetItemNum(PriceInfo.ID)
			Name = ItemUtil.GetItemName(PriceInfo.ID)
		end

		local NeedCount = PriceInfo.Count * self.CurNum
		if HasCount < NeedCount then
			--货币不足
			IsEnough = false
			NoEnoughID = PriceInfo.ID
			SupCount = NeedCount - HasCount
			return IsEnough, NoEnoughID, SupCount, Name,0
		else
			IsEnough = true
		end
	else
		for i = 1,#PriceValueInfo do
			local HasCount = 0
			local Index = 0
			if PriceValueInfo[i].Type == ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE then
				HasCount = ScoreMgr:GetScoreValueByID(PriceValueInfo[i].ID)
				Name = ScoreMgr:GetScoreNameText(PriceValueInfo[i].ID)
			else
				HasCount = BagMgr:GetItemNum(PriceValueInfo[i].ID)
				Name = ItemUtil.GetItemName(PriceValueInfo[i].ID)
			end
			local NeedCount = PriceValueInfo[i].Count * self.CurNum
			if HasCount < NeedCount then
				--货币不足
				IsEnough = false
				NoEnoughID = PriceValueInfo[i].ID
				SupCount = NeedCount - HasCount
				Index = i
				return IsEnough, NoEnoughID, SupCount,Name,Index
			else
				IsEnough = true
			end
		end
	end

	--需要配置推荐兑换和获取进行下一步判断
	return IsEnough, NoEnoughID, SupCount, Name, 0
end

function MysterMerchantBuyPropsWinView:UpdatePriceInfo(Value)
	for i = 1,#PriceValueInfo do
		local NewPrice = tonumber(PriceValueInfo[i].Count) * Value
		self.MoneyTextList[i]:SetText(ScoreMgr.FormatScore(string.format("%d",NewPrice)))
		if self.IsDiscount then
			local OriginalPrice = PriceValueInfo[i].OriginalPrice * Value
			self.TextOriginalPrice:SetText(ScoreMgr.FormatScore(OriginalPrice))
		end
	end
end

--二次弹窗确认后继续购买
function MysterMerchantBuyPropsWinView:GoonBuy()
	if self.BuyCallback then
		self.BuyCallback(self.GoodsId, self.CurNum)
	end
	
	if self.IsPop == 1 then
		_G.LootMgr:SetDealyState(true)
	end
	self:Hide()
end

function MysterMerchantBuyPropsWinView:UpdateTextColor()
	local Data = UpdateTextData
	local HasCount = ScoreMgr:GetScoreValueByID(Data.ScoreID) or 0
	local NeedCount = Data.NeedCount or 0
	if HasCount >= NeedCount then
		UIUtil.TextBlockSetColorAndOpacityHex(self.MoneyTextList[Data.Index],TextColor[1])
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.MoneyTextList[Data.Index],TextColor[2])
	end
	--self.MoneyTextList[Data.Index]:SetText(string.format("%d",NeedCount))
end

function MysterMerchantBuyPropsWinView:BagCapacityIsEnough()
	local BagCapacity = BagMgr:GetBagLeftNum()
	local IsEnough = true
	local Tips = ""
	if BagCapacity < 1 then 
		IsEnough = false
		if self.TypeState then
			Tips = LSTR(1110041)--背包已满，无法交换
		else
			Tips = LSTR(1110042)--背包已满，无法购买
		end
		
	else
		IsEnough = true
	end

	return IsEnough,Tips
end

function MysterMerchantBuyPropsWinView:OnClickedBtnGoods()
	--ItemTipsUtil.CurrencyTips(self.ItemID, false, self.PanelHQ)
	self:SetBindState()
end

function MysterMerchantBuyPropsWinView:OnClickedBtnNumber1()
	local AddVlue = 10
	if self.CurNum - AddVlue < 1 then
		AddVlue = self.CurNum - 1
	end

	self.AmountSlider:SetSubVlue(AddVlue)
end

function MysterMerchantBuyPropsWinView:OnClickedBtnNumber2()
	local AddVlue = 10

	if self.CurNum + AddVlue > self.MaxNum then
		AddVlue = self.MaxNum - self.CurNum
	end

	self.AmountSlider:SetAddVlue(AddVlue)
end

function MysterMerchantBuyPropsWinView:OnClickedBtnTips1()
	local Tips = LSTR(1110023)--已达到最小数量，不能再减少
	MsgTipsUtil.ShowTips(Tips)
end

function MysterMerchantBuyPropsWinView:OnClickedBtnTips2()
	local Tips = LSTR(1110022)--已达到最大数量，不能再增加
	MsgTipsUtil.ShowTips(Tips)
end

function MysterMerchantBuyPropsWinView:OnClickedBtnPreview()
	_G.PreviewMgr:OpenPreviewView(self.ItemID)
end

function MysterMerchantBuyPropsWinView:OnClickedBtnCancel()
	self:Hide()
end

function MysterMerchantBuyPropsWinView:ShowPirceTips(Index)
	if PriceValueInfo[Index].Type == ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE then
		ItemTipsUtil.CurrencyTips(PriceValueInfo[Index].ID, false, self.MoneyImgList[Index])
	else
		ItemTipsUtil.ShowTipsByResID(PriceValueInfo[Index].ID, self.MoneyImgList[Index])
	end
end

function MysterMerchantBuyPropsWinView:SetBuyBtnState(Value, IsCanBuy)
	if IsCanBuy then
		if Value then
			self.BtnBuyConfirm:SetIsRecommendState(true)
			self.BtnBuyConfirm:SetTextColorAndOpacityHex(TextColor[4])
		else
			self.BtnBuyConfirm:SetIsDisabledState(true, true)
			self.BtnBuyConfirm:SetTextColorAndOpacityHex(TextColor[3])
		end
	else
		self.BtnBuyConfirm:SetIsDisabledState(true, true)
		self.BtnBuyConfirm:SetTextColorAndOpacityHex(TextColor[3])
	end
end

return MysterMerchantBuyPropsWinView