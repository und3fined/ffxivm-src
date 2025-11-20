
--- 盲盒mainVM
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local UIBindableList = require("UI/UIBindableList")
local StoreMysteryBoxGoodsItemVM = require("Game/Store/VM/ItemVM/StoreMysteryBoxGoodsItemVM")
local StoreMysteryBoxListItemVM = require("Game/Store/VM/ItemVM/StoreMysteryBoxListItemVM")
local StoreNewBlindBoxDescItemVM = require("Game/Store/VM/ItemVM/StoreNewBlindBoxDescItemVM")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
local CommercializationRandConsumeCfg = require("TableCfg/CommercializationRandConsumeCfg")

local MysteryBoxTypes = ProtoRes.SpecialMysteryBoxTypes

---@class StoreMysteryBoxVM : UIViewModel
local StoreMysteryBoxVM = LuaClass(UIViewModel)

---Ctor
function StoreMysteryBoxVM:Ctor()
	self.GoodsList = UIBindableList.New(StoreMysteryBoxGoodsItemVM)
	self.ContainedItems = UIBindableList.New(StoreMysteryBoxListItemVM)
	self.MysteryBosItemVMList = UIBindableList.New(StoreNewBlindBoxDescItemVM)

	self.CurBoxCfgData = nil
	self.CurBlindBoxID = 0
	self.CurrentPrice = 0
	self.OriginalPrice = 0
	self.OriginalPriceVisible = false
	self.IsOnCountTime = false
	self.TextName = ""
	self.ItemTextName = ""
	self.CurBoxType = MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE
	self.CurMountID = 0
	self.BuyPriceTextColor = "D5D5D5FF"
	self.CurrentPriceText = ""
	self.OriginalPriceText = ""
	self.JumpToIndex = 0
end

function StoreMysteryBoxVM:GetIsHumanType()
	return self.CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE or self.CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_CLOTHING
end

function StoreMysteryBoxVM:GetIsMountType()
	return self.CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_MOUNT_SKIN
end

function StoreMysteryBoxVM:InitMysterBoxData(Value)
	for index, GoodItem in ipairs(Value) do
		local IsOwned = _G.StoreMysteryBoxMgr:CheckGoodsIsOwned(GoodItem.Cfg)
		GoodItem.IsOwned = IsOwned
	end

	table.sort(Value, function(a, b) if a.IsOwned ~= b.IsOwned then return not a.IsOwned end return a.Cfg.Sort > b.Cfg.Sort end)
    self.GoodsList:UpdateByValues(Value, nil)
end

--- 切换选中的盲盒
function StoreMysteryBoxVM:ChangeSelect(Index)
	local Item = self:GetItem(Index)
	if Item == nil then return end
	local GoodCfgData = Item.GoodCfgData
	if GoodCfgData == nil then
		return
	end
	self.CurMountID = GoodCfgData.MountID
	self.CurBoxType = Item.BoxType
	self.CurBlindBoxID = GoodCfgData.ID
	self:UpdatePrice(GoodCfgData)
	self.TextName = GoodCfgData.Name
	self:UpdateContainedItemsByIndex(Index)
end

--- 更新价格显示
function StoreMysteryBoxVM:UpdatePrice(GoodCfgData)
	
	self.OriginalPrice = GoodCfgData.Price[1].Count
	self.CurrentPrice = GoodCfgData.DisCountedPrice
    local CurrentTime = TimeUtil.GetServerLogicTime()
	local DiscountStart = _G.StoreMysteryBoxMgr:GetTimeInfo(GoodCfgData.DiscountDurationStart)
	local DiscountEnd = _G.StoreMysteryBoxMgr:GetTimeInfo(GoodCfgData.DiscountDurationEnd)
	local IsOnTime = (DiscountStart ~= 0 and DiscountEnd ~= 0) and (CurrentTime >= DiscountStart and CurrentTime <= DiscountEnd)

	self.IsOnCountTime = IsOnTime
	if not IsOnTime then
		self.CurrentPrice = self.OriginalPrice
	end
	self.OriginalPriceVisible = IsOnTime
	self.CurrentPriceText = _G.ScoreMgr.FormatScore(self.CurrentPrice)
	self.OriginalPriceText = _G.ScoreMgr.FormatScore(self.OriginalPrice)
	
	local ScoreValue = _G.ScoreMgr:GetScoreValueByID(GoodCfgData.Price[1].ID)
	if ScoreValue < self.CurrentPrice then
		self.BuyPriceTextColor = "AF4C58FF"
	else
		self.BuyPriceTextColor = "D5D5D5FF"
	end
end

function StoreMysteryBoxVM:UpdateAfterBuy(BlindBoxID)
	local Items = self.GoodsList:GetItems()

	if Items == nil then
		return
	end
	local TempItem
	for _, value in ipairs(Items) do
		if value.BlindBoxID == BlindBoxID then
			TempItem = value
			break
		end
	end
	local BoughtIndex = self.GoodsList:GetItemIndex(TempItem)
	if BoughtIndex == nil or BoughtIndex == 0 then
		return
	end
	--- 购买后更新购买界面还有哪些未拥有的Item
	_G.StoreMysteryBoxVM:ChangeSelect(BoughtIndex)
	--- 更新商城界面右侧包含列表和概率
	_G.StoreMysteryBoxVM:UpdateContainedItemsByIndex(BoughtIndex)

end

function StoreMysteryBoxVM:UpdateContainedItemsByIndex(Index)

	local Item = self:GetItem(Index)
	if Item == nil then return end
	self.CurBoxCfgData = Item.GoodCfgData

	if table.is_nil_empty(Item.Items) then
		return
	end
	
    self.ContainedItems:UpdateByValues(Item.Items, nil)
	self:UpdateMysteryBoxData(Item.Items, self.CurBoxCfgData.PrizePoolID)
end

--- 更新奇遇盲盒Tips列表
---@param Items table 包含物品
---@param PrizePoolID number 奖池ID  用来计算权重 概率
function StoreMysteryBoxVM:UpdateMysteryBoxData(Items, PrizePoolID)
	if PrizePoolID == nil then
		return
	end
	local ItemsData = {}
	--- 权重List
	local DropWeightList = {}
	--- 拥有状态List
	local bIsOwnedList = {}
	--- 未拥有权重总和
	local AllDropWeight = 0
	local TempRandCfgList = CommercializationRandCfg:FindAllCfg(string.format("PrizePoolID=%d", PrizePoolID))
	for _, value in ipairs(TempRandCfgList) do
		if value.ProbMode == ProtoRes.PROBABILITY_TYPE.PROBABILITY_TYPE_WEIGHTED then
			DropWeightList[value.DropID] = value.DropWeight
			local bIsOwned = _G.HaircutMgr.CheckHairUnlock(value.DropID) or _G.StoreMysteryBoxMgr.CheckItemOwned(value.DropID)
			if not bIsOwned then
				AllDropWeight = AllDropWeight + value.DropWeight
			end
			bIsOwnedList[value.DropID] = bIsOwned
		end
	end
	for index, value in ipairs(Items) do
		local ItemID = value.ID
		ItemsData[index] = {
			ID = ItemID,
			DropWeight = DropWeightList[ItemID],
			bIsOwned = bIsOwnedList[ItemID],
			AllDropWeight = AllDropWeight
		}
	end
	table.sort(ItemsData, function(a, b) if a.bIsOwned == b.bIsOwned then return false end return not a.bIsOwned end)

	self.MysteryBosItemVMList:UpdateByValues(ItemsData)
end

function StoreMysteryBoxVM:OnBegin()
	
end


function StoreMysteryBoxVM:UpdateTableViewData(Data)
	self.TableViewData:UpdateByValues(Data, nil, true)
end

--- 商城侧获取是否显示盲盒页签接口
function StoreMysteryBoxVM:GetMysterBoxIsEnable()

end

function StoreMysteryBoxVM:OnSelectChanged(Index)
	for i = 1, self.ContainedItems:Length() do
		self.ContainedItems.Items[i]:OnSelectedChange(false)
	end
	self.ContainedItems.Items[Index]:OnSelectedChange(true)
end

function StoreMysteryBoxVM:GetItem(Index)
	local Item = self.GoodsList:Get(Index)
	if Item == nil then
		return nil
	end
	return Item
end

function StoreMysteryBoxVM:GetCurBlindIsOnCountTime()
	return self.IsOnCountTime
end

function StoreMysteryBoxVM:GetContainedItemsItem(Index)
	local Item = self.ContainedItems:Get(Index)
	if Item == nil then
		return nil
	end
	return Item
end

return StoreMysteryBoxVM