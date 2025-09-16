---
--- Author: Administrator
--- DateTime: 2024-10-25 15:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local StoreMgr = require("Game/Store/StoreMgr")
local FLinearColor = _G.UE.FLinearColor

---@class OpsCommBtnLView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtnL CommBtnLView
---@field IconMoney UFImage
---@field PanelMoney UFHorizontalBox
---@field PanelOriginalPrice UFCanvasPanel
---@field TextNotUnlock UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextPrice UFTextBlock
---@field Money bool
---@field Price bool
---@field BtnText text
---@field NotUnlock bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCommBtnLView = LuaClass(UIView, true)

function OpsCommBtnLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBtnL = nil
	--self.IconMoney = nil
	--self.PanelMoney = nil
	--self.PanelOriginalPrice = nil
	--self.TextNotUnlock = nil
	--self.TextOriginalPrice = nil
	--self.TextPrice = nil
	--self.Money = nil
	--self.Price = nil
	--self.BtnText = nil
	--self.NotUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCommBtnLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtnL)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCommBtnLView:OnInit()

end

function OpsCommBtnLView:OnDestroy()

end

function OpsCommBtnLView:OnShow()

end

function OpsCommBtnLView:OnHide()

end

function OpsCommBtnLView:OnRegisterUIEvent()

end

function OpsCommBtnLView:OnRegisterGameEvent()

end

function OpsCommBtnLView:OnRegisterBinder()

end

function OpsCommBtnLView:SetBtnPriceByGoodsID(GoodsID)
	if not GoodsID then return end
		
	local GoodsData = _G.StoreMgr:GetProductDataByID(GoodsID)
	if table.is_nil_empty(GoodsData) then return end
		
	local GoodCfgData = GoodsData.Cfg
	local IsOnTime = StoreMgr:IsDuringSaleTime(GoodCfgData)
	if GoodCfgData.Discount == StoreDefine.DiscountMinValue or GoodCfgData.Discount >= StoreDefine.DiscountMaxValue or not IsOnTime then
		UIUtil.SetIsVisible(self.PanelOriginalPrice, false)
	else
		UIUtil.SetIsVisible(self.PanelOriginalPrice, true)
	end

	local PriceData = GoodCfgData.Price[StoreDefine.PriceDefaultIndex]
    local Discount = GoodCfgData.Discount
    local ScoreValue = _G.ScoreMgr:GetScoreValueByID(PriceData.ID)
	local ScoreIcon = _G.ScoreMgr:GetScoreIconName(PriceData.ID)
	if ScoreIcon then
        UIUtil.ImageSetBrushFromAssetPath(self.IconMoney, ScoreIcon)
    end

    if not Discount then
        Discount = StoreDefine.DiscountMaxValue
    end

    if Discount <= 0 then
        Discount = StoreDefine.DiscountMaxValue - Discount
    end

	local BuyGoodPrice = math.floor(PriceData.Count * (Discount / StoreDefine.DiscountMaxValue))
	self.TextPrice:SetText(_G.ScoreMgr.FormatScore(BuyGoodPrice))
	self.TextOriginalPrice:SetText(_G.ScoreMgr.FormatScore(PriceData.Count))

	if tonumber(BuyGoodPrice) > ScoreValue then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextPrice, "#DC5868FF")
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextPrice, "#ffffff")
	end
end

function OpsCommBtnLView:SetBtnName(Name)
	self.CommBtnL:SetBtnName(Name)
end

function OpsCommBtnLView:SetDisplayContent(BuyText, BuyPriceText, BuyPriceVisible)
	UIUtil.SetIsVisible(self.PanelOriginalPrice, false)
	self.TextNotUnlock:SetText("")
	self.BtnText = BuyText
	self.CommBtnL:SetBtnName(BuyText)
	self.TextPrice:SetText(BuyPriceText)
	UIUtil.SetIsVisible(self.IconMoney, BuyPriceVisible)
end


return OpsCommBtnLView