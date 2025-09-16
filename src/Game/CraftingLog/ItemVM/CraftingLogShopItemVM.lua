--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-02-28 15:22:41
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-02-28 15:23:48
FilePath: \Client\Source\Script\Game\CraftingLog\ItemVM\CraftingLogShopItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagMgr = require("Game/Bag/BagMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local UIUtil = require("Utils/UIUtil")
local SCORE_TYPE = ProtoRes.SCORE_TYPE

---@class CraftingLogShopItemVM : UIViewModel
local CraftingLogShopItemVM = LuaClass(UIViewModel)

---Ctor
function CraftingLogShopItemVM:Ctor()
	self.CostNum = 0
    self.CostId = SCORE_TYPE.SCORE_TYPE_GOLD_CODE
    self.bShowExchange = false
    self.bActiveByView = false
    self.Icon = nil
    self.ItemQualityImg = nil
    self.NumRatio = ""
	self.NeedNum = 0
    self.BuyNum = 0
	self.UnitPrice = 0
	self.GropNum = 1
	self.ItemID = nil
	self.GoodsID = nil
	self.CanGroupBuy = true
end

function CraftingLogShopItemVM:OnInit()
end

function CraftingLogShopItemVM:UpdateVM(Value)
	self.OnceLimitation = Value.OnceLimitation
	self.ItemID = Value.ItemID
	self.GoodsID = Value.GoodsID
	local ItemData = ItemCfg:FindCfgByKey(Value.ItemID)
	self.ItemData = ItemData
	self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Value.ItemID))
    self.ItemQualityImg = ItemUtil.GetSlotColorIcon(Value.ItemID, ItemDefine.ItemSlotType.Item96Slot)

	local NeedNum =  Value.NeedNum
	self.NeedNum = NeedNum
	self:SetNumRatio()

	self.UnitPrice = ItemData.GoldCoinPrice
	self:SetBuyNum(NeedNum)
end

function CraftingLogShopItemVM:IsEqualVM(Value)
	return self.ItemID == Value.ItemID
end

function CraftingLogShopItemVM:SetNumRatio()
	local NeedNum =  self.NeedNum
	local ItemData =  self.ItemData
	local HaveCount = ItemData.IsHQ == 1 and BagMgr:GetItemHQNum(ItemData.ItemID) or BagMgr:GetItemNumWithHQ(ItemData.ItemID)
	if NeedNum > HaveCount then
		self.NumRatio = string.format("<span color=\"#FF0000FF\">%d</>/%d", HaveCount, NeedNum)
	else
		self.NumRatio = string.format("<span color=\"#FFFFFFFF\">%d</>/%d", HaveCount, NeedNum)
	end
end

function CraftingLogShopItemVM:SetBuyNum(Value)
	self.BuyNum = Value
	self.CostNum = self.BuyNum * self.UnitPrice
	_G.CraftingLogShopWinVM:SetCostNum()

	local GropNum = _G.CraftingLogShopWinVM.GroupNum
	local CanGroupBuy = Value/GropNum == self.NeedNum
	if self.CanGroupBuy ~= CanGroupBuy then
		self.CanGroupBuy = CanGroupBuy
		_G.CraftingLogShopWinVM:SetGroupBuyEnable(CanGroupBuy)
	else
		self.CanGroupBuy = CanGroupBuy
	end
end

return CraftingLogShopItemVM