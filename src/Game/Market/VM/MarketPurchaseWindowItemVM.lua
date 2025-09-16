local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local ShopDefine = require("Game/Shop/ShopDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local TradeMarketGoodsCfg = require("TableCfg/TradeMarketGoodsCfg")

---@class MarketPurchaseWindowItemVM : UIViewModel
local MarketPurchaseWindowItemVM = LuaClass(UIViewModel)

---Ctor
function MarketPurchaseWindowItemVM:Ctor()
	self.CommodityQuality = nil
	self.HQVisible = nil
	self.HQColor = nil
	self.Icon = nil
	self.QuantityText = nil
	self.CollectVisible = nil
	self.CollectBtnVisible = nil
	self.CollectSelectedVisible = nil
	self.PreviewBtnVisible = nil
end

function MarketPurchaseWindowItemVM:UpdateVM(ResID, InfoStr)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
        return
    end
    self.Icon = Cfg.IconID
    self:SetHQandColorImg(Cfg.IsHQ, Cfg.ItemColor)
	self.ResID = ResID
	self.QuantityText = InfoStr

	self.PreviewBtnVisible = self:CanPreview(Cfg)
end

function MarketPurchaseWindowItemVM:CanPreview(Cfg)
	if nil == Cfg then
        return false
    end

	--[[if ItemUtil.CheckIsEquipment(Cfg.Classify) then
		local TradeCfg = TradeMarketGoodsCfg:FindCfgByKey(Cfg.ItemID)
		if TradeCfg then
			if TradeCfg.SubType == 2 then
				return Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.ARMOR_SHIELD
			else
				return true
			end
		else
			return false
		end
	end]]--

	if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_FASHION then
		if Cfg.EquipmentID > 0 then
			local EquipmentCfg = require("TableCfg/EquipmentCfg")
			local ECfg = EquipmentCfg:FindCfgByKey(Cfg.EquipmentID)
			if ECfg and ECfg.ItemMainType == ProtoCommon.ItemMainType.ItemArm then
				return false
			end
		end

		return true
	end

	if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MOUNT or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MINION then
		return true
	end
	return false
end

function MarketPurchaseWindowItemVM:SetHQandColorImg(IsHQ,ItemColor)
	if IsHQ == 1 then
		self.HQVisible = true
	else
		self.HQVisible = false
	end
	self.CommodityQuality = ShopDefine.ItemColor[ItemColor]
	self.HQColor = ShopDefine.ItemHQColor[ItemColor]
end

function MarketPurchaseWindowItemVM:SetCollectStatus()
	if self.ResID == nil then
		return
	end
    self.CollectSelectedVisible = _G.MarketMgr:IsGoodsConcern(self.ResID)
	self.CollectVisible = not self.CollectSelectedVisible
	self.CollectBtnVisible = true
end

function MarketPurchaseWindowItemVM:OnClickedCollect()
    if self.CollectSelectedVisible == true then
        _G.MarketMgr:SendConcernGoodsMessage(self.ResID, true)
    else
        if _G.MarketMgr:IsGoodsConcernMax() then
			_G.MsgTipsUtil.ShowTips(_G.LSTR(1010015))
			return
		end
		_G.MarketMgr:SendConcernGoodsMessage(self.ResID, false)
    end
end

--要返回当前类
return MarketPurchaseWindowItemVM