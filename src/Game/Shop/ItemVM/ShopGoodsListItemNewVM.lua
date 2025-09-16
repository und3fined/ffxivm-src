local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ShopMgr = require("Game/Shop/ShopMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local GoodsCfg = require("TableCfg/GoodsCfg")
local ShopDefine = require("Game/Shop/ShopDefine")
local ShopGoodsMoneyItemNewVM =  require("Game/Shop/ItemVM/ShopGoodsMoneyItemNewVM")
local TimeUtil = require("Utils/TimeUtil")
local CounterMgr = require("Game/Counter/CounterMgr")


---@class ShopGoodsListItemNewVM : UIViewModel
local ShopGoodsListItemNewVM = LuaClass(UIViewModel)

---Ctor
function ShopGoodsListItemNewVM:Ctor()
	self.Name = nil
	self.ItemQuality = nil
	self.Icon = nil
	self.QuotaVisible = nil
	--self.FVerticalBoxVisible = nil
	self.HQVisible = nil
	self.QuotaTtitle = nil
	self.QuotaNum = nil
	self.TagVisible = nil
	self.TimeVisible = nil
	self.DiscountText = nil
	self.TimeText = nil
	self.MaskVisible = nil
	self.TipsText = nil
	self.HQImage = nil
	self.MoneyList = nil
	self.IsDiscount = nil
	self.GoodsId = nil
	self.BoughtCount = nil
	self.TaskVisible = nil
	-- self.Img1 = nil
    -- self.Img2 = nil
    -- self.Img3 = nil
    -- self.Money2Visible = nil
    -- self.Money3Visible = nil
    -- self.Money1Num = nil
    -- self.Money2Num = nil
    -- self.Money3Num = nil
    -- self.CostPricePanelVisible = nil
    -- self.CostPriceNum = nil
    -- self.GoodsId = nil
    -- self.Discount = nil
    -- self.IsDiscount = nil
	self.ShopGoodsMoneyItemNewVM = ShopGoodsMoneyItemNewVM.New()
	self.RestrictionType = nil
	self.CounterInfo = nil
	self.GoodsItemInfo = nil
	self.IsCanBuy = nil
	self.bBuyDesc = nil
	self.GoldCoinPrice = nil
	self.ItemID = nil

end

function ShopGoodsListItemNewVM:OnInit()

end
 
---UpdateVM
---@param List table
function ShopGoodsListItemNewVM:UpdateVM(List)
	--FLOG_ERROR("TEst GOODSLISTITEM LIST = %s",table_to_string(List))
	local Cfg = List.ItemInfo
	if Cfg == nil then
		Cfg = ItemCfg:FindCfgByKey(List.ItemID)
		List.ItemInfo = Cfg
	end
	if Cfg == nil then
		FLOG_ERROR("ShopGoodsListItemNewVM: Cfg = nil ")
		Cfg = ItemCfg:FindCfgByKey(List.ItemID)
		List.ItemInfo = Cfg
	end
	if Cfg == nil then
		FLOG_ERROR("ShopGoodsListItemNewVM: Cfg = nil ID = %d ", List.ItemID)
		return
	end
	
	local IconID = Cfg.IconID
	local ItemName = Cfg.ItemName
	local ItemColor = Cfg.ItemColor
	local IsHQ = Cfg.IsHQ
	local GoodsId = List.GoodsId
	local DiscountInfo = {}
	DiscountInfo.Discount = List.Discount
	DiscountInfo.DiscountDurationStart = List.DiscountDurationStart
	DiscountInfo.DiscountDurationEnd = List.DiscountDurationEnd
	local QuotaInfo = {}
	QuotaInfo.RestrictionType = List.RestrictionType
	QuotaInfo.BoughtCount = List.BoughtCount
	QuotaInfo.CounterInfo = List.CounterInfo
	self.RestrictionType = List.RestrictionType
	self.ItemID = Cfg.ItemID
	self.Icon = IconID
	self.Name = ItemName
	self.GoodsId = GoodsId
	self.BoughtCount = List.BoughtCount
	self.CounterInfo = List.CounterInfo
	self.GoldCoinPrice = Cfg.GoldCoinPrice

	self:SetDiscount(DiscountInfo)
	self:SetDiscountTime(DiscountInfo)
	self:SetQuota(QuotaInfo)
	self:SetHQandColorImg(IsHQ,ItemColor)
	self:SetBuyState(List.bBuy, List.bBuyDesc)
	self:SetTaskState(self.ItemID)
	local Price = { }
	Price.CoinInfo = List.Price
	Price.GoodsId = GoodsId
	Price.Discount = List.Discount
	Price.IsDiscount = self.IsDiscount
	Price.DiscountDurationStart =  List.DiscountDurationStart
	Price.DiscountDurationEnd =  List.DiscountDurationEnd
	Price.GoldCoinPrice = self.GoldCoinPrice
	self.MoneyList = Price
	self.ShopGoodsMoneyItemNewVM:UpdateVM(self.MoneyList)
end

function ShopGoodsListItemNewVM:UpdateGoodsState(List)

end

function ShopGoodsListItemNewVM:SetDiscount(Info)
	if Info.DiscountDurationEnd > 0 and Info.DiscountDurationStart > 0 then
		local ServerTime = TimeUtil.GetServerTime() --秒
		local IsStart = ServerTime - Info.DiscountDurationStart
        local RemainSeconds = Info.DiscountDurationEnd - ServerTime
        local DayCostSec = 24 * 60 * 60
        local RemainDay = math.ceil(RemainSeconds / DayCostSec)
        if RemainDay > 0 and IsStart > 0 then
		end
	end
	if Info.Discount == 0 or Info.Discount == 100 then
		self.TagVisible = false
		self.IsDiscount = false
	else
		self.TagVisible = true
		self.IsDiscount = true
		self.DiscountText = string.format(LSTR(1200002), math.floor(Info.Discount / 10))
	end
end

function ShopGoodsListItemNewVM:SetDiscountTime(Info)
	if Info.DiscountDurationEnd > 0 and Info.DiscountDurationStart > 0 then
        local ServerTime = TimeUtil.GetServerTime() --秒
		local IsStart = ServerTime - Info.DiscountDurationStart
        local RemainSeconds = Info.DiscountDurationEnd - ServerTime
        local DayCostSec = 24 * 60 * 60
        local RemainDay = math.ceil(RemainSeconds / DayCostSec)
        if RemainDay > 0 and IsStart > 0 then
			self.TimeVisible = true
            self.TimeText = string.format(LSTR(1200001), RemainDay)
		else
			self.TagVisible = false
        end
	else
		self.TimeVisible = false
    end
end

function ShopGoodsListItemNewVM:SetQuota(Info)
	if Info.RestrictionType and Info.RestrictionType ~= 0 then
		self.QuotaVisible = true
		self.QuotaTtitle = ShopDefine.LimitBuyType[Info.RestrictionType]
		local CanBuyCount = Info.BoughtCount
		local CurrentRestore = CounterMgr:GetCounterRestore(Info.CounterInfo.CounterFirst.CounterID)
		self.QuotaNum = string.format("%d/%d", CanBuyCount, CurrentRestore)
	else
		self.QuotaVisible = false
	end
end

function ShopGoodsListItemNewVM:SetHQandColorImg(IsHQ,ItemColor)
	if IsHQ == 1 then
		self.HQVisible = true
	else
		self.HQVisible = false
	end
	self.HQImage = ShopDefine.ItemColor[ItemColor]
end

function ShopGoodsListItemNewVM:SetBuyState(IsCanbuy, bBuyDesc)
	self.MaskVisible = not IsCanbuy
	self.TipsText = bBuyDesc
	self.IsCanBuy = IsCanbuy
	self.bBuyDesc = bBuyDesc
end

function ShopGoodsListItemNewVM:SetTaskState(ItemID)
	self.TaskVisible = _G.QuestMgr:IsQuestGoods(ItemID)
end

function ShopGoodsListItemNewVM:IsEqualVM(Value)
    --return nil ~= Value and Value.ID == self.ShopItemData.ID
end

function ShopGoodsListItemNewVM:OnValueChanged(Value)
	if ShopMgr.JumpToGoodsState then
		self.GoodsId = Value.GoodsId
		self.BoughtCount = Value.BoughtCount
		self.CounterInfo = Value.CounterInfo
		self.IsCanBuy = Value.bBuy
		self.bBuyDesc = Value.bBuyDesc
		self.ItemID = Value.ItemID
	end
end


return ShopGoodsListItemNewVM