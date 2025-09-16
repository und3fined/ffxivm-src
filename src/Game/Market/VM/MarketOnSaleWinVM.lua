local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local MarketPriceItemVM = require("Game/Market/VM/MarketPriceItemVM")
local MarketPurchaseWindowItemVM = require("Game/Market/VM/MarketPurchaseWindowItemVM")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local TradeMarketGoodsCfg = require("TableCfg/TradeMarketGoodsCfg")

local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local CommonUtil = require("Utils/CommonUtil")

---@class MarketOnSaleWinVM : UIViewModel
local MarketOnSaleWinVM = LuaClass(UIViewModel)

---Ctor
function MarketOnSaleWinVM:Ctor()
    self.ReferencePriceVMList = UIBindableList.New(MarketPriceItemVM)
    self.SellItemMV = MarketPurchaseWindowItemVM.New()

    self.ItemTypeText = nil
    self.ItemNameText = nil
    self.ItemDescriptionText = nil
    self.TariffText = nil
    self.AmountText = nil
    self.RecommendText = nil

	self.EmptyTipsVisible = nil
    self.MarketPriceVisible = nil
	self.ReSellVisible = nil
    self.SellVisible = nil
    self.TextQuantityColor = nil
end

function MarketOnSaleWinVM:UpdateVM(Value)
    self.ReSellVisible = Value.Stall ~= nil
    self.SellVisible = Value.Item ~= nil

    self.EmptyTipsVisible = false
    self.MarketPriceVisible = false

    local ItemResID = nil
    local Num = 0
    if Value.Stall ~= nil then
        ItemResID = Value.Stall.ResID
        Num = Value.Stall.TotalNum - Value.Stall.SoldNum
        self.TextQuantityColor = "828282"
    elseif Value.Item ~= nil then
        ItemResID = Value.Item.ResID
        Num = Value.Item.Num
        if Num > 1 then
            self.TextQuantityColor = "d5d5d5"
        else
            self.TextQuantityColor = "828282"
        end
    end

    if ItemResID == nil then
        return
    end

    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end

    self.ItemTypeText = _G.MarketMgr:GetMarketItemLevelInfo(Cfg)
	self.ItemNameText = CommonUtil.GetTextFromStringWithSpecialCharacter(Cfg.ItemName)
	self.ItemDescriptionText = _G.MarketMgr:GetMarketItemDesc(Cfg)
    if self.SellItemMV then
        self.SellItemMV:UpdateVM(ItemResID, string.format(_G.LSTR(1010016), Num))
    end

    local GoodCfg = TradeMarketGoodsCfg:FindCfgByKey(ItemResID)
    if GoodCfg ~= nil then
        self.RecommendText = GoodCfg.BaseSugPrice
    end

    self.TariffText = string.format(_G.LSTR(1010017), _G.MarketMgr:GetCurTax()*100, '%')

end

function MarketOnSaleWinVM:SetQuantity(Quantity)
    self.Quantity = Quantity
    if self.Quantity == nil or self.Price == nil then
        return
    end
    self.AmountText = math.floor(Quantity * self.Price * (1 - _G.MarketMgr:GetCurTax()))
end

function MarketOnSaleWinVM:SetPrice(Price)
    self.Price = Price
    if self.Quantity == nil or self.Price == nil then
        return
    end
    self.AmountText = math.floor(self.Quantity * Price * (1 - _G.MarketMgr:GetCurTax()))
end


function MarketOnSaleWinVM:UpdateReferencePrice(ReferencePrice)
    local PriceList = ReferencePrice.PriceList or {}

	self.ReferencePriceVMList:UpdateByValues(PriceList)
    self.EmptyTipsVisible = #PriceList == 0
    self.MarketPriceVisible = #PriceList > 0

    local RecommendPrice = self:GetRecommendPrice(PriceList)
    if RecommendPrice > 0 then
        self.RecommendText = RecommendPrice
    end
end

function MarketOnSaleWinVM:GetRecommendPrice(PriceList)
    local RecommendPrice = 0
    local MaxNum = 0
    for i = 1, #PriceList do
        local Value = PriceList[i]
        if Value.SellNum > MaxNum  then
            MaxNum = Value.SellNum
            RecommendPrice = Value.Price
        elseif Value.SellNum == MaxNum and Value.Price < RecommendPrice then
            RecommendPrice = Value.Price
        end
	end

    return RecommendPrice
end

--要返回当前类
return MarketOnSaleWinVM