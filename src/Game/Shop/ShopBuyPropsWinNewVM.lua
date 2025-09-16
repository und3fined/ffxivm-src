--
-- Author: ds_yangyumian
-- Date: 2022-09-19 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ShopMgr = require("Game/Shop/ShopMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local GoodsCfg = require("TableCfg/GoodsCfg")
local ShopDefine = require("Game/Shop/ShopDefine")


---@class ShopBuyPropsWinNewVM : UIViewModel
local ShopBuyPropsWinNewVM = LuaClass(UIViewModel)

---Ctor
function ShopBuyPropsWinNewVM:Ctor()
	self.GoodsName = nil
	self.GoodsType = nil
	self.GoodsDesc = nil
	self.GoodsSoldout = nil
	self.GoodsQuality = nil
	self.GoodsIcon = nil
	self.DiscountVisible = nil
	self.DiscountText = nil
	self.HQVisible = nil
	self.SurpluText = nil
	self.SurpluText2 = nil
	self.SurpluText2Visible = nil
end

---UpdateVM
---@param List table
function ShopBuyPropsWinNewVM:UpdateVM(GoodsId,BoughtCount)
	local ItemID = ShopMgr:GetGoodsItemID(GoodsId)
	local Cfg = ItemCfg:FindCfgByKey(ItemID)
	local GCfg = GoodsCfg:FindCfgByKey(GoodsId)
	local IconID = Cfg.IconID
	local ItemName = ItemCfg:GetItemName(ItemID)
	local ItemColor = Cfg.ItemColor
	local DiscountInfo = {}
	DiscountInfo.Discount = GCfg.Discount
	DiscountInfo.DiscountDurationStart = GCfg.DiscountDurationStart
	DiscountInfo.DiscountDurationEnd = GCfg.DiscountDurationEnd
	self.GoodsName = ItemName
	self.GoodsType = Cfg.ItemType
	self.GoodsIcon = IconID
	self.GoodsDesc = ItemCfg:GetItemDesc(ItemID)
	self.GoodsQuality = ShopDefine.ItemColor[ItemColor]
	self:SetDiscount(DiscountInfo)
end

function ShopBuyPropsWinNewVM:SetDiscount(Info)
	if Info.Discount == 0 or Info.Discount == 100 then
		self.TagVisible = false
		self.IsDiscount = false
	else
		self.TagVisible = true
		self.IsDiscount = true
		self.DiscountText = string.format(LSTR(1200002), math.floor(Info.Discount / 10))
	end
end

return ShopBuyPropsWinNewVM