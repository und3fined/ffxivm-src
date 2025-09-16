local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MathUtil = require("Utils/MathUtil")
local StoreDefine = require("Game/Store/StoreDefine")

---@class StorePriceVM : UIViewModel
local StorePriceVM = LuaClass(UIViewModel)

local ColorEnough = "D5D5D5FF"
local ColorNotEnough = "AF4C58FF"

function StorePriceVM:Ctor()
	self.BuyPrice = 0
	self.RawPrice = 0
	self.CouponedNum = 0 -- 优惠券优惠的价格
	self.ScoreID = 0
	self.BuyPriceTextColor = ColorEnough
	self.bShowRawPrice = false
	self.bShowCoupons = false -- 是否显示优惠券图标（优惠后才会显示）
	self.bHasCoupon = false -- 是否有可用优惠券
end

---@param GoodCfgData table
---@param bUseCoupon boolean @是否使用优惠券
---@param bRecommendCoupon boolean @是否使用推荐的优惠券
---@param GoodsCount number @商品数量
function StorePriceVM:UpdatePriceData(GoodCfgData, bUseCoupon, bRecommendCoupon, GoodsCount)
	if nil == GoodCfgData then
		return
	end

	if nil == bUseCoupon then
		bUseCoupon = true
	end

	if nil == bRecommendCoupon then
		bRecommendCoupon = false
	end

	if nil == GoodsCount then
		GoodsCount = 1
	end

	-- 价格计算
	local RawPrice, PriceWithDiscount, PriceWithCoupon
	if bUseCoupon and bRecommendCoupon then
		RawPrice, PriceWithDiscount, PriceWithCoupon =
			_G.StoreMgr:GetGoodPriceInfo(GoodCfgData, true, true)
	else
		local CouponID = _G.StoreMgr:GetCurrentCouponID()
		if CouponID > 0 and bUseCoupon then
			RawPrice, PriceWithDiscount, PriceWithCoupon =
				_G.StoreMgr:GetGoodPriceInfo(GoodCfgData, true, true, CouponID)
		else
			RawPrice, PriceWithDiscount, PriceWithCoupon =
				_G.StoreMgr:GetGoodPriceInfo(GoodCfgData, true, false)
		end
	end
	local bHasCoupon = _G.StoreMgr:CheckCoupon(RawPrice, GoodCfgData.ID)
	-- 优惠券显示
	self.bHasCoupon = bHasCoupon
	self.bShowCoupons = PriceWithCoupon < PriceWithDiscount
	local bIsDiscounted = RawPrice ~= PriceWithCoupon
	-- 原价显示
	self.RawPrice = MathUtil.RoundOff(RawPrice)
	self.bShowRawPrice = bIsDiscounted
	-- 货币类型
	if nil ~= GoodCfgData.Price and nil ~= GoodCfgData.Price[StoreDefine.PriceDefaultIndex] then
		self.ScoreID = GoodCfgData.Price[StoreDefine.PriceDefaultIndex].ID
	else
		self.ScoreID = 0
	end
	-- 最终价格
	self.BuyPrice = MathUtil.RoundOff(PriceWithCoupon) * GoodsCount
	self.CouponedNum = MathUtil.RoundOff(PriceWithDiscount - PriceWithCoupon) -- 暂无多商品购买时使用优惠券需求

	self:UpdatePriceColor()
end

function StorePriceVM:UpdatePriceColor()
	-- 字体颜色
	local ScoreValue = _G.ScoreMgr:GetScoreValueByID(self.ScoreID)
	if self.BuyPrice > ScoreValue then
		self.BuyPriceTextColor = ColorNotEnough
	else
		self.BuyPriceTextColor = ColorEnough
	end
end

return StorePriceVM