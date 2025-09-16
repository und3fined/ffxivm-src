local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ShopMgr = require("Game/Shop/ShopMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local GoodsCfg = require("TableCfg/GoodsCfg")
local ShopDefine = require("Game/Shop/ShopDefine")
local MysteryMerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local ShopGoodsMoneyItemNewVM =  require("Game/MysterMerchant/VM/Item/MerchantShopGoodsMoneyItemVM")
local TimeUtil = require("Utils/TimeUtil")
local CounterMgr = require("Game/Counter/CounterMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemType = ProtoCommon.ITEM_TYPE_DETAIL

---@class MerchantGoodsListItemVM : UIViewModel
local MerchantGoodsListItemVM = LuaClass(UIViewModel)

---Ctor
function MerchantGoodsListItemVM:Ctor()
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
	self.ShopGoodsMoneyItemNewVM = ShopGoodsMoneyItemNewVM.New()
	self.RestrictionType = nil
	self.CounterInfo = nil
	self.GoodsItemInfo = nil
	self.IsCanBuy = nil
	self.bBuyDesc = nil
	self.GoldCoinPrice = nil
	self.ItemID = nil
	self.SpeciaIcon = false
	self.ArrowIconVisible = false
	self.PanelTaskVisible = false
	self.FirstType = nil
	self.IsBuyView = false
	self.InitialState = false
	self.HQColor = nil
	self.TextconditionText = ""
	self.IsCanPreView = false
end

function MerchantGoodsListItemVM:OnInit()

end
 
---UpdateVM
---@param List table
function MerchantGoodsListItemVM:UpdateVM(List)
	--FLOG_ERROR("TEst GOODSLISTITEM LIST = %s",table_to_string(List))
	local Cfg = List.ItemInfo
	if Cfg == nil then
		Cfg = ItemCfg:FindCfgByKey(List.ItemID)
		List.ItemInfo = Cfg
	end
	if Cfg == nil then
		FLOG_ERROR("神秘商店物品不存在: ItemID = "..List.ItemID)
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
	QuotaInfo.BoughtCount = List.BoughtCount  --已购数
	QuotaInfo.LimitNum = List.LimitNum    --限购数
	self.RestrictionType = List.RestrictionType
	self.ItemID = Cfg.ItemID
	self.Icon = IconID
	self.Name = ItemName
	self.GoodsId = GoodsId
	self.BoughtCount = List.BoughtCount
	self.CounterInfo = List.CounterInfo
	self.LimitNum = List.LimitNum
	self.GoldCoinPrice = List.Price --Cfg.GoldCoinPrice
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
	self.IsCanPreView = Cfg.EquipmentID == 0 and (Cfg.ItemType == ItemType.COLLAGE_MOUNT or Cfg.ItemType == ItemType.COLLAGE_MINION or Cfg.ItemType == ItemType.COLLAGE_FASHION)
end

function MerchantGoodsListItemVM:UpdateGoodsState(List)

end

---@type 设置已售罄状态
---@param PurchasedType number @已售罄类型
function MerchantGoodsListItemVM:SetSoldOutState(PurchasedType)
	if _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Gift then
		FLOG_INFO("Purchase status does not show purchase sold out information")
		return
	end
    local PurchasedText = LSTR(StoreDefine.SoldOutText[PurchasedType])
    if PurchasedText == nil then
        FLOG_WARNING(string.format("StoreGoodVM:SetSoldOutState, PurchasedText is nil, ItemIndex: %d", self.ItemIndex))
        return
    end
	
    -- self.LimitationVisible = false
    self.HorizontalPriceVisible = false
    self.StateTextVisible = true
    self.GoodStateText = PurchasedText
end

function MerchantGoodsListItemVM:SetDiscount(Info)
	-- if Info.DiscountDurationEnd > 0 and Info.DiscountDurationStart > 0 then
	-- 	local ServerTime = TimeUtil.GetServerTime() --秒
	-- 	local IsStart = ServerTime - Info.DiscountDurationStart
    --     local RemainSeconds = Info.DiscountDurationEnd - ServerTime
    --     local DayCostSec = 24 * 60 * 60
    --     local RemainDay = math.ceil(RemainSeconds / DayCostSec)
    --     if RemainDay > 0 and IsStart > 0 then
	-- 	end
	-- end
	if Info.Discount == 0 or Info.Discount == 100 then
		self.TagVisible = false
		self.IsDiscount = false
	else
		self.TagVisible = true
		self.IsDiscount = true
		self.DiscountText = string.format(LSTR(1110002), math.floor(Info.Discount / 10))--%d折
	end
end

function MerchantGoodsListItemVM:SetDiscountTime(Info)
	--折扣时间暂无需求
	-- if Info.DiscountDurationEnd > 0 and Info.DiscountDurationStart > 0 then
    --     local ServerTime = TimeUtil.GetServerTime() --秒
	-- 	local IsStart = ServerTime - Info.DiscountDurationStart
    --     local RemainSeconds = Info.DiscountDurationEnd - ServerTime
    --     local DayCostSec = 24 * 60 * 60
    --     local RemainDay = math.ceil(RemainSeconds / DayCostSec)
    --     if RemainDay > 0 and IsStart > 0 then
	-- 		self.TimeVisible = true
    --         self.TimeText = string.format(LSTR(1110001), RemainDay)--%d天
	-- 	else
	-- 		self.TagVisible = false
    --     end
	-- else
	-- 	self.TimeVisible = false
    -- end
	self.TimeVisible = false
end

function MerchantGoodsListItemVM:SetQuota(Info)
	if Info.RestrictionType and Info.RestrictionType ~= 0 then
		self.QuotaVisible = true
		self.QuotaTtitle = MysteryMerchantDefine.LimitBuyType[Info.RestrictionType]
		local CanBuyCount = Info.LimitNum - Info.BoughtCount
		local CurrentRestore = Info.LimitNum --CounterMgr:GetCounterRestore(Info.CounterInfo.CounterFirst.CounterID)
		self.QuotaNum = string.format("%s%d/%d", self.QuotaTtitle, CanBuyCount, CurrentRestore)
	else
		self.QuotaVisible = false
	end
end

function MerchantGoodsListItemVM:SetHQandColorImg(IsHQ,ItemColor)
	if IsHQ == 1 then
		self.HQVisible = true
	else
		self.HQVisible = false
	end
	self.HQImage = ShopDefine.ItemColor[ItemColor]
end

function MerchantGoodsListItemVM:SetBuyState(IsCanbuy, bBuyDesc)
	self.MaskVisible = not IsCanbuy
	self.TipsText = bBuyDesc
	self.IsCanBuy = IsCanbuy
	self.bBuyDesc = bBuyDesc
end

function MerchantGoodsListItemVM:SetTaskState(ItemID)
	self.TaskVisible = _G.QuestMgr:IsQuestGoods(ItemID)
end

function MerchantGoodsListItemVM:IsEqualVM(Value)
    --return nil ~= Value and Value.ID == self.ShopItemData.ID
end


return MerchantGoodsListItemVM