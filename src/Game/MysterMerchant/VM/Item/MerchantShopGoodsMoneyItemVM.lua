---
--- Author: Carl
--- DateTime: 2025-03-26 18:48:34
--- Description: 冒险游商团商店系统
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ScoreMgr = require("Game/Score/ScoreMgr")
local TimeUtil = require("Utils/TimeUtil")
--local LSTR = _G.LSTR
---@class MerchantShopGoodsMoneyItemVM : UIViewModel

local MerchantShopGoodsMoneyItemVM = LuaClass(UIViewModel)

---Ctor
function MerchantShopGoodsMoneyItemVM:Ctor()
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

function MerchantShopGoodsMoneyItemVM:IsEqualVM(Value)
    return true
end


function MerchantShopGoodsMoneyItemVM:UpdateVM(List)
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
    local TimeInfo = {}
    TimeInfo.DiscountDurationStart = List.DiscountDurationStart
    TimeInfo.DiscountDurationEnd = List.DiscountDurationEnd
    self.GoldCoinPrice = List.GoldCoinPrice

    -- 金币商店只有金币一种货币
    self:SetScorePrice(CoinInfo,1,TimeInfo)
end

function MerchantShopGoodsMoneyItemVM:SetScorePrice(Info,Index,TimeInfo)
    --FLOG_ERROR("test price info = %s",table_to_string(Info))
    self["MoneyVisible"..Index] = true
    self["Img"..Index] = Info.ID
    local Coin = Info.Count

    if TimeInfo.DiscountDurationEnd and TimeInfo.DiscountDurationEnd > 0 and 
        TimeInfo.DiscountDurationStart and TimeInfo.DiscountDurationStart > 0 then
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

return MerchantShopGoodsMoneyItemVM