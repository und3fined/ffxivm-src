---
--- Author: Alex
--- DateTime: 2023-02-03 18:48:34
--- Description: 商店系统
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ShopMgr = require("Game/Shop/ShopMgr")
local MallCfg = require("TableCfg/MallCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
--local LSTR = _G.LSTR
---@class ShopGoodsMoneyItemNewVM : UIViewModel
---@field TabName string @商店页签名称

local ShopGoodsMoneyItemNewVM = LuaClass(UIViewModel)

---Ctor
function ShopGoodsMoneyItemNewVM:Ctor()
    -- Main Part
    self.Img1 = nil
    self.Img2 = nil
    self.Img3 = nil
    self.MoneyVisible1 = nil
    self.MoneyVisible2 = nil
    self.MoneyVisible3 = nil
    self.MoneyNum1 = nil
    self.MoneyNum2 = nil
    self.MoneyNum3 = nil
    self.CostPricePanelVisible = nil
    self.CostPriceNum = nil
    self.GoodsId = nil
    self.Discount = nil
    self.IsDiscount = nil
    --是否是银币商店
    self.Isyinbi = nil  --目前银币已全部改成金币 金币价格需要去物品表读取

end

function ShopGoodsMoneyItemNewVM:IsEqualVM(Value)
    return true
end


function ShopGoodsMoneyItemNewVM:UpdateVM(List)
    --FLOG_ERROR("?ASDASDASD = %s",table_to_string(List))
    self.MoneyVisible1 = false
    self.MoneyVisible2 = false
    self.MoneyVisible3 = false
    self.Isyinbi = false
    self.CostPricePanelVisible = false
    self.GoodsId = List.GoodsId
    self.Discount = List.Discount
    self.IsDiscount = List.IsDiscount
    local CoinInfo = List.CoinInfo
    local MallId = List.MallID or ShopMgr.CurOpenMallId or ShopMgr.CurQueryShopID
    local ShopType
	if ShopMgr.AllShopInfo ~= nil and MallId ~= nil then
		ShopType = ShopMgr.CurOpenShopType or ShopMgr.AllShopInfo[MallId].ShopType
	end
    local TimeInfo = {}
    TimeInfo.DiscountDurationStart = List.DiscountDurationStart
    TimeInfo.DiscountDurationEnd = List.DiscountDurationEnd
    self.GoldCoinPrice = List.GoldCoinPrice

    if ShopType == 1 then
        --银币商店只有银币一种货币
        self.Isyinbi = true
        self:SetScorePrice(CoinInfo[1],1,TimeInfo)
    else
        for i = 1,#CoinInfo do
            if CoinInfo[i].ID ~= nil and CoinInfo[i].ID > 0 then
                if CoinInfo[i].Type == ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE then
                    self:SetScorePrice(CoinInfo[i],i,TimeInfo)
                elseif CoinInfo[i].Type == ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_ITEM then
                    self:SetItemPrice(CoinInfo[i],i,TimeInfo)
                end
            end
        end
    end
end

function ShopGoodsMoneyItemNewVM:SetScorePrice(Info,Index,TimeInfo)
    --FLOG_ERROR("test price info = %s",table_to_string(Info))
    self["MoneyVisible"..Index] = true
    self["Img"..Index] = Info.ID
    local Coin = 0
    if self.Isyinbi then
        Coin = self.GoldCoinPrice
    else
        Coin = Info.Count
    end

    if TimeInfo.DiscountDurationEnd > 0 and TimeInfo.DiscountDurationStart > 0 then
        local ServerTime = TimeUtil.GetServerTime() --秒
		local IsStart = ServerTime - TimeInfo.DiscountDurationStart
        local RemainSeconds = TimeInfo.DiscountDurationEnd - ServerTime
        local DayCostSec = 24 * 60 * 60
        local RemainDay = math.ceil(RemainSeconds / DayCostSec)
        if RemainDay > 0 and IsStart > 0 and self.Discount and self.Discount ~= 100 then
            self.CostPricePanelVisible = true
            self["MoneyNum"..Index] = ScoreMgr.FormatScore(string.format("%d",Coin * (self.Discount / 100)))
            self.CostPriceNum = ScoreMgr.FormatScore(Coin)
		else
            self["MoneyNum"..Index] = ScoreMgr.FormatScore(Coin)
            self.CostPricePanelVisible = false
        end
	elseif self.Discount > 0 and self.Discount < 100 then
        self.CostPricePanelVisible = true
        self["MoneyNum"..Index] = ScoreMgr.FormatScore(string.format("%d",Coin * (self.Discount / 100)))
        self.CostPriceNum = ScoreMgr.FormatScore(Coin)
	else
        self["MoneyNum"..Index] = ScoreMgr.FormatScore(Coin)
        self.CostPricePanelVisible = false
    end
end

function ShopGoodsMoneyItemNewVM:SetItemPrice(Info,Index,TimeInfo)
    self["MoneyVisible"..Index] = true
    self["Img"..Index] = Info.ID

    if TimeInfo.DiscountDurationEnd > 0 and TimeInfo.DiscountDurationStart > 0 then
        local ServerTime = TimeUtil.GetServerTime() --秒
		local IsStart = ServerTime - TimeInfo.DiscountDurationStart
        local RemainSeconds = TimeInfo.DiscountDurationEnd - ServerTime
        local DayCostSec = 24 * 60 * 60
        local RemainDay = math.ceil(RemainSeconds / DayCostSec)
        if RemainDay > 0 and IsStart > 0 and self.Discount then
            self.CostPricePanelVisible = true
            self["MoneyNum"..Index] = ScoreMgr.FormatScore(string.format("%d",Info.Count * (self.Discount / 100)))
            self.CostPriceNum = Info.Count
		else
            self["MoneyNum"..Index] = Info.Count
            self.CostPricePanelVisible = false
        end
	elseif self.Discount > 0 and self.Discount < 100 then
        self.CostPricePanelVisible = true
        self["MoneyNum"..Index] = ScoreMgr.FormatScore(string.format("%d",Info.Count * (self.Discount / 100)))
        self.CostPriceNum = Info.Count
	else
        self["MoneyNum"..Index] = Info.Count
        self.CostPricePanelVisible = false
    end
end

return ShopGoodsMoneyItemNewVM