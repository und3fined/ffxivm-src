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
local GoodsCfg = require("TableCfg/GoodsCfg")
local ShopDefine = require("Game/Shop/ShopDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MallShopTypeCfg = require("TableCfg/MallsShopTypeCfg")
local MallCfg = require("TableCfg/MallCfg")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemUtil = require("Utils/ItemUtil")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local CounterMgr = require("Game/Counter/CounterMgr")
local ShopGoodsListItemVM = require("Game/Shop/ItemVM/ShopGoodsListItemVM")
local CounterCfg = require("TableCfg/CounterCfg")


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
	"#828282",--灰
	"d5d5d5", -- 白
}

local UpdateTextData = {}

---@class ShopBuyPropsWinView : UIView
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
---@field ShopGoods ShopGoodsListItemView
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
local ShopBuyPropsWinView = LuaClass(UIView, true)

function ShopBuyPropsWinView:Ctor()
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
	--self.ShopGoods = nil
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

function ShopBuyPropsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBuyConfirm)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnGift)
	self:AddSubView(self.ShopGoods)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopBuyPropsWinView:OnInit()
	self.GoodsItemVM = ShopGoodsListItemVM.New()
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

function ShopBuyPropsWinView:OnDestroy()

end

function ShopBuyPropsWinView:OnShow()
	self.AllSurplus = 0
	self.CurNum = 1
	self.MaxNum = 1
	self.GoodsId = self.Params.GoodsId
	self.BoughtCount = self.Params.BoughtCount
	-- self.RestrictionType = self.Params.RestrictionType
	self.CounterInfo = self.Params.CounterInfo
	self.IsCanBuy = self.Params.IsCanBuy
	self.BuyDes = self.Params.bBuyDesc
	self.CurGoldCoinPrice = self.Params.GoldCoinPrice
	self.ItemID = self.Params.ItemID
	self.ItemName = self.Params.Name
	UIUtil.SetIsVisible(self.TextWear, false)
	UIUtil.SetIsVisible(self.BtnGift, false, true)
	UIUtil.SetIsVisible(self.BtnCancel, true, true)
	self.TextAmount:SetText(1)
	self.TextNumber1:SetText(LSTR(1200088))-- -10
	self.TextNumber2:SetText(LSTR(1200089))-- +10
	local Cfg = ItemCfg:FindCfgByKey(self.ItemID)
	if Cfg ~= nil then
		self:UpdateGoodsInfo(Cfg)
	end
	
	local GoodsInfo = self.Params.VMValue
	if GoodsInfo == nil then
		GoodsInfo = self.Params
	end

	self.GoodsItemVM:UpdateVM(GoodsInfo)
	self.GoodsItemVM:SetBuyViewState(true)
	self.ShopGoods:SetParams({Data = self.GoodsItemVM})
	self.ShopGoods:SetBuyViewItemState(false)
	if ShopMgr.JumpToGoodsState then
		local JumpToBuyNum = ShopMgr.JumpToBuyNum or 1
		local BuyValue = math.min(JumpToBuyNum, self.MaxNum)
		self.AmountSlider:SetSliderValue(BuyValue)
	end
	UIUtil.SetIsVisible(self.BtnPreview, self.Params.IsCanPreView, true)
end

function ShopBuyPropsWinView:OnHide()
	self.TextAmount:SetText(1)
	if UIViewMgr:IsViewVisible(UIViewID.ItemTipsStatus) then
		UIViewMgr:HideView(UIViewID.ItemTipsStatus)
	end
	--ShopMgr.CurQueryShopID = nil
	PriceValueInfo = {}
end

function ShopBuyPropsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuyConfirm, self.OnClickedConfirmBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnGoods, self.OnClickedBtnSlot)
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

function ShopBuyPropsWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScoreUpdate, self.UpdateTextColor)
end

function ShopBuyPropsWinView:OnRegisterBinder()

end

function ShopBuyPropsWinView:UpdateGoodsInfo(Cfg)
	if Cfg == nil then
		FLOG_ERROR("UpdateGoodsInfo Cfg == nil")
		return
	end
	local GCfg = GoodsCfg:FindCfgByKey(self.GoodsId)
	local ItemColor = Cfg.ItemColor
	local ItemType = Cfg.ItemType
	local OnceLimitation = GCfg.OnceLimitation
	local DiscountInfo = {}

	DiscountInfo.Discount = GCfg.Discount
	DiscountInfo.DiscountDurationStart = ShopMgr:GetTimeInfo(GCfg.DiscountDurationStart)
	DiscountInfo.DiscountDurationEnd = ShopMgr:GetTimeInfo(GCfg.DiscountDurationEnd )
	local QuotaInfo = {}
	QuotaInfo.RestrictionCount = GCfg.RestrictionCount
	QuotaInfo.BoughtCount = self.BoughtCount
	QuotaInfo.CounterFirstID = GCfg.GoodsCounterFirst
	QuotaInfo.CounterSecondID = GCfg.GoodsCounterSecond
	if QuotaInfo.CounterFirstID and QuotaInfo.CounterFirstID ~= 0 then
		QuotaInfo.RestrictionType = CounterCfg:FindCfgByKey(GCfg.GoodsCounterFirst).CounterType or 0
	end
	local PriceInfo = GCfg.Price
	self.Discount = GCfg.Discount
	self.Exchange = GCfg.Exchange
	self.Obtain = GCfg.Obtain
	self.IsPop = GCfg.PopOut
	self.GoldCoinPrice = Cfg.GoldCoinPrice
	-- if IsHQ == 1 then
	-- 	UIUtil.SetIsVisible(self.PanelHQ,true)
	-- else
	-- 	UIUtil.SetIsVisible(self.PanelHQ,false)
	-- end

	local TempItemLevelStr = ShopMgr:GetItemlevelStr(Cfg)
	self.TextItemType:SetText(string.format("%s%s", ProtoEnumAlias.GetAlias(ProtoCommon.ITEM_TYPE_DETAIL, ItemType or ""), TempItemLevelStr))
	self.TextItemName:SetText(Cfg.ItemName)
	if Cfg.ItemMainType > ProtoCommon.ItemMainType.ItemMainTypeNone and Cfg.ItemMainType < ProtoCommon.ItemMainType.ItemConsumables then
		local ProfDes = ShopMgr:GetEquipProfInfoToBuyWinView(Cfg)
		self.TextItemDescription:SetText(ProfDes)
	else
		self.TextItemDescription:SetText(Cfg.ItemDesc)
	end

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
	--self:SetDiscount(DiscountInfo)
	self:SetQuota(QuotaInfo, OnceLimitation)
	self:SetPriceInfo(PriceInfo)
	self:SetOverlayNum()

	--根据是否可购买来判断按钮状态
	local isCanUse,UseDes,NotBuyType = ShopMgr:IsCanUse(nil, self.GoodsId)
	self.NotBuyType = NotBuyType
	self.IsCanUse = isCanUse
	if NotBuyType == 0 then
		self.IsCanUse = true
	end

	if self.IsCanBuy then
		UIUtil.SetIsVisible(self.TextAmount, true)
		UIUtil.SetIsVisible(self.AmountSlider, true, true)
		UIUtil.SetIsVisible(self.HorizontalPrice, true, true)
		UIUtil.SetIsVisible(self.TextSoldout, false)
		--UIUtil.SetIsVisible(self.NumberPanel1,true,true)
		--UIUtil.SetIsVisible(self.NumberPanel2,true,true)
		self:IsCurNumMax(1, self.MaxNum)
		self:SetSlider()

		if not isCanUse then
			-- UIUtil.SetIsVisible(self.TextWear, true)
			-- self.TextWear:SetText(UseDes)
			self.BuyDes = UseDes
		else
			-- UIUtil.SetIsVisible(self.TextWear, false)
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
				self.TextSoldout:SetText(LSTR(1200025))
				UIUtil.SetIsVisible(self.HorizontalPrice, false, true) 
			else
				self.TextSoldout:SetText("")
				UIUtil.SetIsVisible(self.HorizontalPrice, true, true) 
			end
		else
			self.TextSoldout:SetText(self.BuyDes)
			UIUtil.SetIsVisible(self.HorizontalPrice, false, true)
		end
	end
end

function ShopBuyPropsWinView:SetOverlayNum(OnceLimitation)
	local CurOpneShopID = ShopMgr.CurOpenMallId or ShopMgr.CurQueryShopID
	local GoodsInfo = ShopMgr:GetGoodsInfo(CurOpneShopID, self.GoodsId)
	if GoodsInfo then
		self.OverlayNum = GoodsInfo.Items[1].Num
		ShopMgr.OverlayNum = self.OverlayNum or 0
		ShopMgr.OnceLimitation = OnceLimitation or 0
		if self.OverlayNum > 1 then
			UIUtil.SetIsVisible(self.TextNumWin, true)
			self.TextNumWin:SetText(self.OverlayNum)
		else
			UIUtil.SetIsVisible(self.TextNumWin, false)
		end
	end
end

function ShopBuyPropsWinView:SetTitle()
	local ShopID = ShopMgr.CurOpenMallId or ShopMgr.CurQueryShopID
	local MallInfo = MallCfg:FindCfgByKey(ShopID)
	local Type = MallShopTypeCfg:FindCfgByKey(MallInfo.ShopType)
	if Type == nil then
		FLOG_ERROR("SetTitle Type = nil")
		return
	end
	self.Shoptype = Type.ID
	self.TypeState = Type.State
	if Type.State == 1 then
		TitleText = LSTR(1200023)
		BtnText = LSTR(1200070)
		ExchangeName = LSTR(1200049)
		NotBuyTips = LSTR(1200046)
	else
		TitleText = LSTR(1200028)
		BtnText = LSTR(1200071)
		ExchangeName = LSTR(1200050)
		NotBuyTips = LSTR(1200047)
	end

	self.BG:SetTitleText(TitleText)
	self.BtnBuyConfirm:SetButtonText(BtnText)
	self.BtnCancel:SetButtonText(LSTR(1200087))
end

function ShopBuyPropsWinView:SetDiscount(Info)
	if Info.DiscountDurationEnd > 0 and Info.DiscountDurationStart > 0 then
        local ServerTime = TimeUtil.GetServerTime() --秒
		local IsStart = ServerTime - Info.DiscountDurationStart
        local RemainSeconds = Info.DiscountDurationEnd - ServerTime
        local DayCostSec = 24 * 60 * 60
        local RemainDay = math.ceil(RemainSeconds / DayCostSec)
        if RemainDay > 0 and IsStart > 0 and Info.Discount and Info.Discount ~= 100 then
			UIUtil.SetIsVisible(self.PanelDiscount, true)
			local DiscountValue = string.format(LSTR(1200002), math.floor(Info.Discount / 10))
			self.IsDiscount = true
			self.TextDiscount:SetText(DiscountValue)
		else
			self.IsDiscount = false
			UIUtil.SetIsVisible(self.PanelDiscount, false)
        end
	elseif Info.Discount > 0 and Info.Discount < 100 then
		self.IsDiscount = true
		UIUtil.SetIsVisible(self.PanelDiscount, true)
		local DiscountValue = string.format(LSTR(1200002), math.floor(Info.Discount / 10))
		self.TextDiscount:SetText(DiscountValue)
	else
		self.IsDiscount = false
		UIUtil.SetIsVisible(self.PanelDiscount, false)
    end
end

function ShopBuyPropsWinView:SetQuota(QuotaInfo, OnceLimitation)
	--有RestrictionType限购类型代表有限购，无则没限购
	if QuotaInfo.RestrictionType and QuotaInfo.RestrictionType ~= 0 then
		UIUtil.SetIsVisible(self.FHorizontalSurplus, true)
		local QuotaTtitle = ShopDefine.LimitBuyNumTipsTitle[QuotaInfo.RestrictionType]
		local CanBuyCount = QuotaInfo.BoughtCount
		local CurrentRestore = CounterMgr:GetCounterRestore(QuotaInfo.CounterFirstID) or 0
		local AllSurplus = 0
		if CanBuyCount <= 0 then
			self.IsSoldout = true
			--双限购剩余显示处理
			if QuotaInfo.CounterSecondID and QuotaInfo.CounterSecondID ~= 0 then		
				local SecondLimit = CounterMgr:GetCounterLimit(QuotaInfo.CounterSecondID)
				local CounterSecondNum = self.CounterInfo.CounterSecond.CounterNum
				AllSurplus = math.max(0, SecondLimit - CounterSecondNum) 
				self.AllSurplus = AllSurplus

				if AllSurplus > 0 then
					UIUtil.SetIsVisible(self.TextSurplus_2, true)
					self.TextSurplus_2:SetText(string.format("%s:%d", LSTR(1200062), AllSurplus))
				else
					UIUtil.SetIsVisible(self.TextSurplus_2, false)
				end
			end
		else
			self.IsSoldout = false
			if QuotaInfo.CounterSecondID and QuotaInfo.CounterSecondID ~= 0 then
				UIUtil.SetIsVisible(self.TextSurplus_2, true)
				local SecondLimit = CounterMgr:GetCounterLimit(QuotaInfo.CounterSecondID)
				local CounterSecondNum = self.CounterInfo.CounterSecond.CounterNum
				AllSurplus = math.max(0, SecondLimit - CounterSecondNum)
				self.AllSurplus = AllSurplus
				self.TextSurplus_2:SetText(string.format("%s:%d", LSTR(1200062), AllSurplus)) 
			end
		end

		self.MaxNum = CanBuyCount or 1
		if self.IsSoldout and AllSurplus <= 0 or not self.IsCanBuy then
			UIUtil.SetIsVisible(self.TextSurplus, false)
		else
			UIUtil.SetIsVisible(self.TextSurplus, true)
			if CanBuyCount == 0 then
				local Text = string.format("<span color=\"#f3f3f399\">%s</><span color=\"#dc5868\">%d</><span color=\"#828282FF\">/%d</>", QuotaTtitle, CanBuyCount, CurrentRestore)
				self.TextSurplus:SetText(Text)
			else
				local Text = string.format("<span color=\"#828282FF\">%s%d/%d</>", QuotaTtitle, CanBuyCount, CurrentRestore)
				self.TextSurplus:SetText(Text)
			end
		end
	else
		self.MaxNum = OnceLimitation or 1
		UIUtil.SetIsVisible(self.TextSurplus_2, false)
		UIUtil.SetIsVisible(self.FHorizontalSurplus, false)
	end
	
end

function ShopBuyPropsWinView:SetBindState()
	local Item = ItemUtil.CreateItem(self.ItemID, 0)
	if not Item then
		return
	end
	ItemTipsUtil.ShowTipsByItem(Item, self.PanelItem)
end

function ShopBuyPropsWinView:SetPriceInfo(PriceInfo)
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
				local NewPrice = PriceValue * (self.Discount / 100)
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

function ShopBuyPropsWinView:SetSlider()
	self.AmountSlider:SetSliderValueMaxMin(self.MaxNum, 1)
	self.AmountSlider:SetSliderValueMaxTips(LSTR(1200033))
	self.AmountSlider:SetSliderValueMinTips(LSTR(1200034))
	self.AmountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v, self.MaxNum)
	end)
end

function ShopBuyPropsWinView:SetNumberPanel(PanelList)
	--走配置 显示便携数量选择
	local IsShow = true
	for i = 1,#PanelList do 
		UIUtil.SetIsVisible(PanelList[i], IsShow)
	end
end

function ShopBuyPropsWinView:SetNumberPanelByOnceLimitation(PanelList,OnceLimitation)
	--走配置
	if OnceLimitation == 1 then
		local IsShow = false
		for i = 1,#PanelList do 
			UIUtil.SetIsVisible(PanelList[i], IsShow)
		end
		self.AmountSlider:SetBtnIsShow(IsShow)
	end
end


function ShopBuyPropsWinView:OnValueChangedSlider(Value,MaxNum)
	self.CurNum = Value
	if self.OverlayNum > 1 then
		self.TextNumWin:SetText(self.OverlayNum * Value)
	end
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

function ShopBuyPropsWinView:IsCurNumMax(CurNum,MaxNum)
	if CurNum >= MaxNum and MaxNum ~= 1 then
		self.BtnNumber2:SetIsEnabled(false)
		if self.ShowNumsSelect == 1 then
			UIUtil.SetIsVisible(self.BtnTips2,true, true)
		end
		UIUtil.SetIsVisible(self.BtnTips2_1,true, true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNumber2, TextColor[3])
	else
		self.BtnNumber2:SetIsEnabled(true)
		UIUtil.SetIsVisible(self.BtnTips2,false, true)
		UIUtil.SetIsVisible(self.BtnTips2_1,false, true)
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNumber2, TextColor[1])
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

function ShopBuyPropsWinView:OnClickedConfirmBtn()
	--满足购买和使用条件
	if self.IsCanBuy and self.IsCanUse then
		local IsEnough, ScoreID, SupCount, Name, Index = self:ScoreIsEnough()
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
					local Content = string.format("%s%s,%s", LSTR(1200040), ScoreName, LSTR(1200051))--您还需要     是否进行兑换
					local function  Callback()
						local Data = {}
						Data.ScoreID = ScoreID
						Data.NeedCount = SupCount
						Data.Index = Index
						UpdateTextData = Data
						UIViewMgr:ShowView(UIViewID.ShopExchangeWinNew, Data)
						--self:Hide()
					end
					MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1200079), Content, Callback, nil, LSTR(1200019),  LSTR(1200069))--货币不足    取消     确定
				else
					local ScoreName = Name
					local Tips = string.format("%s%s", ScoreName, LSTR(1200010))--不足
					MsgTipsUtil.ShowTips(Tips)
					self:Hide()
				end
			elseif self.Obtain == 1 then
				local NeedValue = ScoreMgr.FormatScore(SupCount)
				local ScoreName = RichTextUtil.GetText(string.format("%s%s", NeedValue, Name), TextColor[1])
				local Content = string.format("%s%s,%s", LSTR(1200040), ScoreName, LSTR(1200052))--您还需要     是否进行获取
				MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1200079), Content, nil, nil, LSTR(1200019),  LSTR(1200069))--取消     确定
				self:Hide()
			else
				local ScoreName = Name
				local Tips = string.format("%s%s",ScoreName, LSTR(1200010))--不足
				MsgTipsUtil.ShowTips(Tips)
				--self:Hide()
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
				MsgBoxUtil.ShowMsgBoxTwoOp(self, TitleText, Content, Callback, nil, LSTR(1200019), BtnText)
			else 
				MsgTipsUtil.ShowTips(Tips)
				self:Hide()
			end
		else
			if self.Exchange == 1 then
				if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_SILVER_CODE or ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
					local NeedValue = ScoreMgr.FormatScore(SupCount)
					local ScoreName = RichTextUtil.GetText(string.format("%s%s",NeedValue,Name),TextColor[1])
					local Content = string.format("%s%s,%s", LSTR(1200040), ScoreName, LSTR(1200051))
					local function  Callback()
						local Data = {}
						Data.ScoreID = ScoreID
						Data.NeedCount = SupCount
						Data.Index = Index
						UpdateTextData = Data
						UIViewMgr:ShowView(UIViewID.ShopExchangeWinNew, Data)
					end
					MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1200079), Content, Callback, nil, LSTR(1200019),  LSTR(1200069))
				else
					local ScoreName = Name
					local Tips = string.format("%s%s", ScoreName, LSTR(1200010))
					MsgTipsUtil.ShowTips(Tips)
					self:Hide()
				end
			elseif self.Obtain == 1 then
				local NeedValue = ScoreMgr.FormatScore(SupCount)
				local ScoreName = RichTextUtil.GetText(string.format("%s%s",NeedValue,Name),TextColor[1])
				local Content = string.format("%s%s,%s", LSTR(1200040), ScoreName, LSTR(1200052))
				MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1200079), Content, nil, nil, LSTR(1200019),  LSTR(1200069))
				self:Hide()
			else
				local ScoreName = Name
				local Tips = string.format("%s%s", ScoreName, LSTR(1200010))
				MsgTipsUtil.ShowTips(Tips)
				self:Hide()
			end
		end
	--售罄
	elseif self.IsSoldout then
		local Tips = ""
		if self.TypeState == 1 then
			Tips = LSTR(1200026)
		else
			Tips = LSTR(1200027)
		end
		MsgTipsUtil.ShowTips(Tips)
		--self:Hide()
	--不可购买
	elseif not self.IsCanBuy then
		local Tips = ""
		if self.TypeState == 1 then
			Tips = LSTR(1200008)
		else
			Tips = LSTR(1200009)
		end
		MsgTipsUtil.ShowTips(Tips)
		-- self:Hide()
	end
end

function ShopBuyPropsWinView:GetTipsContent()
	local Tips = ""
	if self.NotBuyType == 1 then
		Tips = self.BuyDes
	elseif self.NotBuyType == 2 then
		-- local Title1 = LSTR(1200078)
		-- local Name = LSTR(1200035)
		-- local Changed = LSTR(1200043)
		-- local Test = LSTR(1200021)
		-- local Title2 = RichTextUtil.GetText(string.format("%s", self.BuyDes), TextColor[1])
		-- local Name2 = RichTextUtil.GetText(string.format("[%s]", Name), TextColor[1])
		-- local Text = string.format("%s%s,%s%s,%s",Title1,Title2,Test,Name2,Changed)
		Tips = self.BuyDes
	elseif self.NotBuyType == 3 then
		-- local Title1 = LSTR(1200078)
		-- local Title2 = RichTextUtil.GetText(string.format("%s", self.BuyDes), TextColor[1])
		-- local Name = RichTextUtil.GetText(string.format("[%s]", LSTR(1200007)), TextColor[1])
		-- local Text = string.format("%s%s,%s%s%,%s", Title1, Title2, LSTR(1200021), Name, LSTR(1200030))
		Tips = self.BuyDes
	elseif self.NotBuyType == 4 then
		Tips = self.BuyDes
	end
	return Tips
end

function ShopBuyPropsWinView:ScoreIsEnough(PriceInfo)
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
			return IsEnough, NoEnoughID, SupCount, Name
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
	return IsEnough, NoEnoughID, SupCount, Name
end

function ShopBuyPropsWinView:UpdatePriceInfo(Value)
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
function ShopBuyPropsWinView:GoonBuy()
	ShopMgr:SendMsgMallInfoBuy(self.GoodsId,self.CurNum)
	if self.IsPop == 1 then
		_G.LootMgr:SetDealyState(true)
	end
	self:Hide()
end

function ShopBuyPropsWinView:UpdateTextColor()
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

function ShopBuyPropsWinView:BagCapacityIsEnough()
	local BagCapacity = BagMgr:GetBagLeftNum()
	local IsEnough = true
	local Tips = ""
	if BagCapacity < 1 then 
		IsEnough = false
		if self.TypeState == 1 then
			Tips = LSTR(1200075)
		else
			Tips = LSTR(1200076)
		end
		
	else
		IsEnough = true
	end

	return IsEnough,Tips
end

function ShopBuyPropsWinView:OnClickedBtnSlot()
	--ItemTipsUtil.CurrencyTips(self.ItemID, false, self.PanelHQ)
	self:SetBindState()
end

function ShopBuyPropsWinView:OnClickedBtnNumber1()
	local AddVlue = 10
	if self.CurNum - AddVlue < 1 then
		AddVlue = self.CurNum - 1
	end

	self.AmountSlider:SetSubVlue(AddVlue)
end

function ShopBuyPropsWinView:OnClickedBtnNumber2()
	local AddVlue = 10

	if self.CurNum + AddVlue > self.MaxNum then
		AddVlue = self.MaxNum - self.CurNum
	end

	self.AmountSlider:SetAddVlue(AddVlue)
end

function ShopBuyPropsWinView:OnClickedBtnTips1()
	local Tips = LSTR(1200034)
	MsgTipsUtil.ShowTips(Tips)
end

function ShopBuyPropsWinView:OnClickedBtnTips2()
	local Tips = LSTR(1200033)
	MsgTipsUtil.ShowTips(Tips)
end

function ShopBuyPropsWinView:OnClickedBtnPreview()
	_G.PreviewMgr:OpenPreviewView(self.ItemID)
end

function ShopBuyPropsWinView:OnClickedBtnCancel()
	self:Hide()
end

function ShopBuyPropsWinView:ShowPirceTips(Index)
	if PriceValueInfo[Index].Type == ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE then
		ItemTipsUtil.CurrencyTips(PriceValueInfo[Index].ID, false, self.MoneyImgList[Index])
	else
		ItemTipsUtil.ShowTipsByResID(PriceValueInfo[Index].ID, self.MoneyImgList[Index])
	end
end

function ShopBuyPropsWinView:SetBuyBtnState(Value, IsCanBuy)
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

return ShopBuyPropsWinView