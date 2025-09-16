local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local MarketMgr = require("Game/Market/MarketMgr")
local ShopDefine = require("Game/Shop/ShopDefine")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR
local ShoWMaxNum = 999

---@class MarketCommodityItemVM : UIViewModel
local MarketCommodityItemVM = LuaClass(UIViewModel)

---Ctor
---

function MarketCommodityItemVM:Ctor()
    self.Name = nil
	self.Icon = nil
	self.QuotaVisible = nil
	self.HQVisible = nil
	self.HQColor = nil
	self.QuotaTtitle = nil
	self.QuotaNum = nil
	
	self.HQImage = nil
	self.CollectSelectVisible = nil
	self.MoneyVisible = nil
	self.MoneyNum1 = nil
	self.PriceInfoText = nil

    self.CollectSelectVisible = nil
	self.CommodityItem = nil

	self.UpArrowVisible = nil
	self.ImgXVisible = nil
	self.ProfRestrictionsImgColor = nil
		
end

function MarketCommodityItemVM:UpdateVM(Value)
	if nil == Value then
		return
	end
    self.CommodityItem = Value
    local ResID = Value.ResID
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
        FLOG_WARNING("MarketCommodityItemVM:UpdateVM can't find item cfg, ResID =%d", ResID)
        return
    end
	self.Icon = Cfg.IconID
	self.Name = ItemCfg:GetItemName(ResID)
	self:SetHQandColorImg(Cfg.IsHQ, Cfg.ItemColor)
	
    self.QuotaVisible = true
    self.QuotaTtitle = LSTR(1010020)
	local AllSellNum = Value.AllSellNum or 0
    if AllSellNum > ShoWMaxNum then
        self.QuotaNum = "999+"
    else
        self.QuotaNum = string.format("%d", AllSellNum)
    end

	local Price = Value.LowPrice or 0
	if Price > 0 then
		self.MoneyVisible = true
		self.MoneyNum1 = _G.ScoreMgr.FormatScore(Price)
		self.PriceInfoText = _G.LSTR(1010021)
	else
		self.MoneyVisible = false
		self.PriceInfoText = _G.LSTR(1010022)
	end

    self.ResID = ResID

    self.CollectVisible = true
    self.CollectSelectVisible = MarketMgr:IsGoodsConcern(Value.ResID)

	self.ImgXVisible = false
	if ItemUtil.CheckIsEquipment(Cfg.Classify) then
		local CanWearable, OtherProfWearable= ItemUtil.UpdateProfRestrictions(self.ResID)
		if CanWearable == false then
			self.ImgXVisible = true
			self.ProfRestrictionsImgColor = OtherProfWearable and "#6fb1e9FF" or "#DC5868FF"	
		end
	end

	self.UpArrowVisible = ItemUtil.CheckIsEquipment(Cfg.Classify) and _G.EquipmentMgr:CanEquiped(ResID) and _G.BagMgr:DiffQualityWithEquipment(ResID) > 0
	
end

function MarketCommodityItemVM:SetHQandColorImg(IsHQ,ItemColor)
	if IsHQ == 1 then
		self.HQVisible = true
	else
		self.HQVisible = false
	end
	self.HQImage = ShopDefine.ItemColor[ItemColor]
	self.HQColor = ShopDefine.ItemHQColor[ItemColor]
end

function MarketCommodityItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ResID == self.ResID
end

function MarketCommodityItemVM:OnClickedCollect()
    if self.CollectSelectVisible == true then
        MarketMgr:SendConcernGoodsMessage(self.ResID, true)
    else
        if MarketMgr:IsGoodsConcernMax() then
			_G.MsgTipsUtil.ShowTips(LSTR(1010015))
			return
		end
		MarketMgr:SendConcernGoodsMessage(self.ResID, false)
    end
end

--要返回当前类
return MarketCommodityItemVM