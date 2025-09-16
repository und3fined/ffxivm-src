local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local UIBindableList = require("UI/UIBindableList")

local ItemCfg = require("TableCfg/ItemCfg")

local MarketStallItemVM = require("Game/Market/VM/MarketStallItemVM")
local TradeMarketGoodsCfg = require("TableCfg/TradeMarketGoodsCfg")
local MarketMgr = require("Game/Market/MarketMgr")
local BagMainVM = require("Game/NewBag/VM/BagMainVM")
local MonthCardMgr = require("Game/MonthCard/MonthCardMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local TimeUtil = require("Utils/TimeUtil")
local BagDefine = require("Game/Bag/BagDefine")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE
local MarketMainVM = require("Game/Market/VM/MarketMainVM")
local LSTR = _G.LSTR
local BagMgr = _G.BagMgr

---@class MarketSellVM : UIViewModel
local MarketSellVM = LuaClass(UIViewModel)

---Ctor
function MarketSellVM:Ctor()
	--背包,仓库
	self.CurrentItemVMList = UIBindableBagSlotList.New(ItemVM, {IsShowNum = true, IsShowNumProgress = false, IsCanBeSelected = false})

	--摊位
	self.CurrentStallVMList = UIBindableList.New(MarketStallItemVM)

	self.StallsNum = nil
	self.MoneyValue = nil
	self.BtnReceiveEnabled = nil
	self.BtnAddVisible = nil

	self.TabIndex = 1
	self.ItemTab = true
end

function MarketSellVM:IsItemTab()
	return self.ItemTab == true
end
	
function MarketSellVM:IsEquipTab()
	return self.ItemTab == false
end

function MarketSellVM:SetEquipTab()
	self.ItemTab = false
	self.TabIndex = 1
end

function MarketSellVM:SetItemTab()
	self.ItemTab = true
	self.TabIndex = 1
end

function MarketSellVM:SetTabIndex(MenuIndex)
	self.TabIndex = MenuIndex
	self:UpdateItemListInfo()
end

function MarketSellVM:UpdateItemListInfo()
	MarketMainVM.SubTitleText = self:IsItemTab() and BagMainVM:GetItemTabName(self.TabIndex) or BagMainVM:GetEquipTabName(self.TabIndex)
	local ItemList = {}
	ItemList = BagMgr:FilterItemByCondition(function (Item)
		local ResID = Item.ResID
		local GoodCfg = TradeMarketGoodsCfg:FindCfgByKey(ResID)
		if nil ~= GoodCfg and Item.IsBind == false then
			local ItemType = self:IsItemTab() and BagMainVM:GetItemTabType(self.TabIndex) or BagMainVM:GetEquipTabType(self.TabIndex)
			local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
			if Cfg then
				if ItemType == BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL then
					if not ItemUtil.CheckIsEquipment(Cfg.Classify) then
						if Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY or Cfg.Classify ~= ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_NONE then
							return true
						end
					end
				elseif ItemType == BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL then
					if ItemUtil.CheckIsEquipment(Cfg.Classify) then
						return true
					end
				elseif ItemType == ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK then
					if Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
						return true
					end
				elseif ItemType == Cfg.Classify then
					return true
				end
			end
		end
		return false
	end)

	local Capacity = math.ceil(#ItemList/5) * 5 > 35 and math.ceil(#ItemList/5) * 5 or 35
	
	ItemList = BagMainVM:FillCapacityByEmptyItem(ItemList, Capacity - #ItemList)

	self.CurrentItemVMList:UpdateByValues(ItemList)
end

function MarketSellVM:UpdateStallListInfo(PlayLockAni)
	local StallList = {}
	local FreeStallNum = MarketMgr.FreeStallNum or 0
	local MonthCardStallNum = MarketMgr.MonthCardStallNum or 0
	
	local IsOpenMonthCard = MonthCardMgr:GetMonthCardStatus() == true
	local AllStallNum = FreeStallNum + MonthCardStallNum
	local StallItemList = MarketMgr.StallItemList or {}
	local OccupancyStallNum = #StallItemList

	for i = 1, AllStallNum do
		local StallInfo = {}
		if i > OccupancyStallNum then
			if IsOpenMonthCard == false then
				if i > FreeStallNum then
					StallInfo.Status = MarketStallItemVM.StallStatus.Lock
					
				else
					StallInfo.Status = MarketStallItemVM.StallStatus.Idle
				end
			else
				StallInfo.Status = MarketStallItemVM.StallStatus.Idle
			end
		else
			StallInfo.Status = MarketStallItemVM.StallStatus.Occupancy
			StallInfo.StallItem = StallItemList[i]
		end
		
		table.insert(StallList, StallInfo)
	end

	table.sort(StallList, self.SortListPredicate)

	for i = 1, #StallList do
		StallList[i].Index = i
		if i > FreeStallNum then
			StallList[i].PlayUnlockAni = PlayLockAni
		end
	end

	self.CurrentStallVMList:UpdateByValues(StallList)
	local OpenStall = string.format("%d", FreeStallNum)
	if IsOpenMonthCard == true then
		OpenStall = RichTextUtil.GetText(string.format("%d", AllStallNum), "d1ba81", 0, nil)
	end
	self.StallsNum  = string.format(LSTR(1010013), OccupancyStallNum, OpenStall)

	local Income = MarketMgr:GetAllStallIncome()
	self.MoneyValue = Income
	self.BtnReceiveEnabled = Income > 0
	self.BtnAddVisible = not IsOpenMonthCard
end

---排序 
function MarketSellVM.SortListPredicate(Left, Right)
	if Left.Status ~= Right.Status then
		return Left.Status > Right.Status
	end


	if Left.StallItem ~= nil  and Right.StallItem ~= nil then
		local LeftIncome = MarketMgr:GetStallIncome(Left.StallItem)
		local RightIncome = MarketMgr:GetStallIncome(Right.StallItem)
		if LeftIncome > 0 or RightIncome > 0 then
			if LeftIncome ~= RightIncome then
				return LeftIncome > RightIncome
			else
				return Left.StallItem.ExpireTick > Right.StallItem.ExpireTick
			end
		end

		local LeftExpire = Left.StallItem.ExpireTick < TimeUtil.GetServerTime()
		local RightExpire = Right.StallItem.ExpireTick < TimeUtil.GetServerTime()
		if LeftExpire ~= RightExpire then
			return LeftExpire
		end


		return Left.StallItem.ExpireTick > Right.StallItem.ExpireTick
	end

	return false
end


--要返回当前类
return MarketSellVM