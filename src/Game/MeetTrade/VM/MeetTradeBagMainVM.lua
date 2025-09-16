local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local ItemUtil = require("Utils/ItemUtil")
local MeetTradeBagItemVM = require("Game/MeetTrade/VM/MeetTradeBagItemVM")
local BagDefine = require("Game/Bag/BagDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local TradeMarketGoodsCfg = require("TableCfg/TradeMarketGoodsCfg")
local BagMgr = require("Game/Bag/BagMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE
local LSTR = _G.LSTR

---@class MeetTradeBagMainVM : UIViewModel
local MeetTradeBagMainVM = LuaClass(UIViewModel)
---Ctor
function MeetTradeBagMainVM:Ctor()
	self.TabIndex = 1

	self.IsEquipPage = nil
	self.IsBagPage = nil
    self.EmptyItemCache = {}
	self.CurrentItemVMList = UIBindableBagSlotList.New(MeetTradeBagItemVM)
	self.CurrentSlectItemVMList = UIBindableBagSlotList.New(MeetTradeBagItemVM)
	self.ItemIndex = nil  --当前选中的物品在背包中的索引
	self.CurGID = nil
    --- 可能需要改名
	self.PanelDetailVisible = nil
	self.TitleNameText = nil
	self.SubTitleText = nil
	self.IsBag = nil
	---Tips位置相关参数
	self.TipsPanelInfoVisible = false
	self.TipsPanelEmptyVisible = true
	self.TipsPanelItemNumVisible = false
	self.TipsPanelItemIcon = nil
	self.TipsPanelItemResID = nil
	self.TipsPanelItemName = ""
	self.TipsPanelItemQuantity = ""
	self.TipsPanelItemNumber = 0
	self.TipsPanelItemNumberText = ""
	self.TipsPanelItemIconChooseVisible = false
	self.HasSelectItemNumTips = LSTR(1490008) .. " (0/15)"
	---交易设置
	self.ExchangeSettingNumber = nil
	self.EditQuantityVisible = nil
	---
	self.ClassifyCache = {}
	self.SelectedItemList = {} ---记录交易背包面板中选中的物品列表,记录物品的GID
	self.SelectedItemListParams	= {} ---用于构建和全量更新选中物品列表的参数
end

function MeetTradeBagMainVM:ClearSelectedItemList()
	table.clear(self.SelectedItemList)
	table.clear(self.SelectedItemListParams)
	self.CurrentSlectItemVMList:Clear()
end

function MeetTradeBagMainVM:Reset()
	self.TipsPanelInfoVisible = false
	self.TipsPanelEmptyVisible = true
	self.TipsPanelItemNumVisible = false
	self.TipsPanelItemIcon = nil
	self.TipsPanelItemResID = nil
	self.TipsPanelItemName = ""
	self.TipsPanelItemQuantity = ""
	self.TipsPanelItemNumber = 0
	self.TipsPanelItemNumberText = ""
	self.ExchangeSettingNumber = 0

end

--- 全量跟新选中物品列表
function MeetTradeBagMainVM:UpdateTableViewSelectItemList()
	local Items = self.SelectedItemListParams
	local SelectListCapacity = self:GetSelectListCapacity()
	if Items == nil then
		_G.FLOG_ERROR("Items Is Null")
		return
	elseif #Items > SelectListCapacity then
		_G.FLOG_ERROR("MeetTradeBagMainVM SelectListCapacity is %d, but Items count is %d", SelectListCapacity, #Items)
		return
	end
	local ItemList = {}
    for i, Item in ipairs(Items) do
		ItemList[i] = Item
	end
	--- 更新已选择数量的Tips信息
	self.HasSelectItemNumTips = LSTR(1490008) .. string.format(" (%d/15)", #ItemList)
	--- 全量更新VM
    ItemList = self:FillCapacityByEmptyItem(ItemList, SelectListCapacity - #ItemList)
    self.CurrentSlectItemVMList:UpdateByValues(ItemList)
end


function MeetTradeBagMainVM:SetCurTabIndex(Index)
	self.TabIndex = Index
	self:UpdateTabInfo()
	if self.IsBag then
		self.SubTitleText = self:IsItemTab() and self:GetItemTabName(self.TabIndex) or self:GetEquipTabName(self.TabIndex)
	end
end

function MeetTradeBagMainVM:SetCurItem(Index)
	self.CurGID = nil
	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item then
		CurItemVM:SetIsCurSelectItem(false)
	end

	local ClickedItemVM = self.CurrentItemVMList:Get(Index)
	self:SetEmptyItem(ClickedItemVM == nil or ClickedItemVM.IsValid == false)
	if ClickedItemVM and ClickedItemVM.IsValid == true and ClickedItemVM.Item then
		ClickedItemVM:SetIsCurSelectItem(true)
		self.CurGID = ClickedItemVM.Item.GID
	end

	self.ItemIndex = Index
end

function MeetTradeBagMainVM:SetCurItemByGID(GID, EditQuantityView)
	local Index = self:GetItemIndexByGID(GID)
	self:SetCurItem(Index)
	if nil ~= Index then
		self:UpdateTipsInfo()
		self:UpdateCurrentEditQuantitySetting(EditQuantityView)
	end
end

function MeetTradeBagMainVM:GetCurItem()
	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item and CurItemVM.Item.GID == self.CurGID then
		return CurItemVM.Item
	end

	self.ItemIndex = self:GetItemIndexByGID(self.CurGID)

	CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item then
		return CurItemVM.Item
	end

	return nil
end

function MeetTradeBagMainVM:GetCurItemVM()
	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item and CurItemVM.Item.GID == self.CurGID then
		return CurItemVM
	end

	self.ItemIndex = self:GetItemIndexByGID(self.CurGID)

	CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item then
		return CurItemVM
	end

	return nil
end

function MeetTradeBagMainVM:GetItemIndexByGID(GID)
	if GID == nil then
		return
	end

	for i = 1, self.CurrentItemVMList:Length() do
		local ItemVM = self.CurrentItemVMList:Get(i)
		if ItemVM and ItemVM.IsValid == true and ItemVM.Item and ItemVM.Item.GID == GID then
			return i
		end
	end
end

function MeetTradeBagMainVM:UpdateTabInfo()
	--_G.UE.FProfileTag.StaticBegin("BagMainVM:GetItemList")
	local CurTabItem = self:GetCurTabItemList()
	---根据维护的选中列表，更新CurTabItem的选中状态
	for i = 1, #CurTabItem do
		local ItemVM = CurTabItem[i]
		--- 设置选中状态
		if nil ~= self.SelectedItemList[ItemVM.GID] then
			ItemVM.IsSelectedForTrade = true
		else
			ItemVM.IsSelectedForTrade = false
		end
		--- 设置当前选中状态
		if self.CurGID and ItemVM.GID == self.CurGID then
			ItemVM.IsSelect = true
		else
			ItemVM.IsSelect = false
		end
	end
	local BagCapacity = BagMgr:GetBagLeftNum()
	--_G.UE.FProfileTag.StaticEnd()
	CurTabItem = self:FillCapacityByEmptyItem(CurTabItem, BagCapacity)
	self.CurrentItemVMList:UpdateByValues(CurTabItem)
	--_G.UE.FProfileTag.StaticEnd()
end

---根据选中列表更新传入的VM/参数列表的选中状态
function MeetTradeBagMainVM:UpdateSelectSituationBySelectItemList(ItemList)
end


function MeetTradeBagMainVM:FillCapacityByEmptyItem(ItemList, FillCapacity)
	local ResultList = ItemList or {}
	local ItemLen = #ResultList
	for i = 1, FillCapacity do
		ResultList[ItemLen + i] = self.EmptyItemCache
	end
	return ResultList
end


function MeetTradeBagMainVM:SetEmptyItem(IsEmpty)
	if self.IsBag then
        ---TODO 名称可能需要替换
		self.PanelDetailVisible = not IsEmpty
	end
end


function MeetTradeBagMainVM.SortBagItemVMPredicate(Left, Right)
    --- 交易背包，不根据New排序
	if Left.ResID ~= Right.ResID then
		--无论升序降序 ResID小的排前面
		return Left.ResID < Right.ResID
	end

	if Left.Num ~= Right.Num then
		--无论升序降序 数量多的排前面
		return Left.Num > Right.Num
	end

	if Left.GID ~= Right.GID then
		--无论升序降序 GID小的排前面
		return Left.GID < Right.GID

	end

	return false
end


function MeetTradeBagMainVM:GetCurTabItemList()
	local AllItemList = BagMgr.ItemList
	local Length = #AllItemList
	local ItemList = {}
	local ItemType = self:IsItemTab() and self:GetItemTabType(self.TabIndex) or self:GetEquipTabType(self.TabIndex)
	for i = 1, Length do
		local Item = AllItemList[i]
        ---如果物品不能交易，就不添加
        local ResID = Item.ResID
        local GoodCfg = TradeMarketGoodsCfg:FindCfgByKey(ResID)
        if nil ~= GoodCfg and Item.IsBind == false then
            ---获取物品类型
		    local ItemClassify = self:GetItemClassify(Item.ResID)
            ---类型为所有物品
            if ItemType == BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL then
                if not ItemUtil.CheckIsEquipment(ItemClassify) and ItemClassify ~= ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_NONE then
                    table.insert(ItemList, Item)
                end
            ---类型为所有装备
            elseif ItemType == BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL then
                if ItemUtil.CheckIsEquipment(ItemClassify) then
                    table.insert(ItemList, Item)
                end
            ---类型为任务道具
            elseif ItemType == ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK then
                local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
                if Cfg and Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
                    table.insert(ItemList, Item)
                end
            ---类型为当前Tab选中的Type
            elseif ItemType == ItemClassify then
                table.insert(ItemList, Item)
            end
        end
	end
	return ItemList
end

function MeetTradeBagMainVM:GetItemClassify(ResID)
	if self.ClassifyCache[ResID] == nil then
		local Cfg = ItemCfg:FindCfgByKey(ResID)
		if Cfg ~= nil then
			self.ClassifyCache[ResID] = Cfg.Classify
			return Cfg.Classify
		end
	else
		return self.ClassifyCache[ResID]
	end

	return ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_NONE
end

function MeetTradeBagMainVM:GetSelectListCapacity()
	return _G.MeetTradeMgr.SelectListCapacity
end

--- 添加是从背包到选择面板，ItemVM是背包的ItemVM
function MeetTradeBagMainVM:AddItemVMToSelectedList(ItemVM)
	if #self.SelectedItemListParams >= self:GetSelectListCapacity() then
		MsgTipsUtil.ShowTips(LSTR(1490058)) --"可添加物品达到上限"
		return
	end
	if nil~= ItemVM and nil ~= ItemVM.GID then
			--- 更新交易背包中物品的选中状态
			if nil == self.SelectedItemList[ItemVM.GID] then
				self.SelectedItemList[ItemVM.GID] = ItemVM.GID
				ItemVM.IsSelectedForTrade = true
				--- 更新选择面板
				local Param = self:GetCreatSelectListItemVMParam(ItemVM)
				table.insert(self.SelectedItemListParams, Param)
				self:UpdateTableViewSelectItemList(self.SelectedItemListParams)
			else
				self.SelectedItemList[ItemVM.GID] = ItemVM.GID
				ItemVM.IsSelectedForTrade = true
			end
	end
end

--- 移除是从选择面板到背包，ItemVM是选择面板的ItemVM
function MeetTradeBagMainVM:RemoveItemVMFromSelectedList(ItemVM)
	if nil ~= ItemVM and nil ~= ItemVM.GID then
		--- 更新交易背包中物品的选中状态
		local BagItemVMGID = self.SelectedItemList[ItemVM.GID]
		if nil ~= BagItemVMGID then
			local BagItemVM = self:GetItemVMFromTradeBagByGID(BagItemVMGID)
			if nil ~= BagItemVM then
				BagItemVM.IsSelectedForTrade = false
			end
			self.SelectedItemList[ItemVM.GID] = nil
		end
		--- 更新选择面板，移除特定的构建参数，全量更新选择列表
		local ParamIndex = self:GetSelectListItemVMParamIndexByGID(ItemVM.GID)
		if ParamIndex > 0 then
			table.remove(self.SelectedItemListParams, ParamIndex)
		end
		self:UpdateTableViewSelectItemList(self.SelectedItemListParams)
	end
end

function MeetTradeBagMainVM:GetSelectListItemVMParamIndexByGID(GID)
	for i, Param in ipairs(self.SelectedItemListParams) do
		if Param.GID == GID then
			return i
		end
	end
	return -1
end

function MeetTradeBagMainVM:GetItemVMFromTradeBagByGID(GID)
	if nil ~= GID then
		return self.CurrentItemVMList:Find(function(ItemVM)
			return ItemVM.GID == GID
		end)
	end
	return nil
end

function MeetTradeBagMainVM:UpdateTipsInfo()
	if nil ~= self.ItemIndex then
		local CurItemVM = self:GetCurItemVM()
		if nil ~= CurItemVM then
			self.TipsPanelInfoVisible = true
			self.TipsPanelEmptyVisible = false
			self.PanelEmpty = false
			self.TipsPanelItemIcon = CurItemVM.Icon
			self.TipsPanelItemName = CurItemVM.Name
			self.TipsPanelItemResID = CurItemVM.ResID
			self.TipsPanelItemQuantity = string.format(LSTR(1490011), CurItemVM.ItemLevel)
			self.TipsPanelItemNumberText = string.format(LSTR(1490012), CurItemVM.Num)
			self.TipsPanelItemNumber = CurItemVM.Num
			self.ExchangeSettingNumber = self:GetSelectItemNumForTradeByGID(CurItemVM.GID)
		end
	end
end

function MeetTradeBagMainVM:SetSelectItemNumForTrade(NewNum)
	if NewNum > 0 and NewNum <= self.TipsPanelItemNumber then
		self.ExchangeSettingNumber = NewNum
		local CurGID = self.CurGID
		---设置选择列表中的数量
		local ItemVM = self.CurrentSlectItemVMList:Find(function(ItemVM)
			if nil ~= ItemVM and nil ~= CurGID then
				return ItemVM.GID == CurGID
			end
			return false
		end)
		if nil ~= ItemVM then
			ItemVM.Num = self.ExchangeSettingNumber
			ItemVM.AnimOpticalFeedbackStartAt = 1
			---设置构建参数的数量
			local ParamIndex = self:GetSelectListItemVMParamIndexByGID(ItemVM.GID)
			if ParamIndex > 0 then
				self.SelectedItemListParams[ParamIndex].Num = self.ExchangeSettingNumber
			end
		end
	end
end

function MeetTradeBagMainVM:GetCurrentSelectItemNumForTrade()
	return self.ExchangeSettingNumber
end

--- 若在选择列表中不存在则返回1，否则返回参数列表中数量
--- 返回1是因为交易物品的数量至少为1，请不要据此判断物品是在选中列表中
function MeetTradeBagMainVM:GetSelectItemNumForTradeByGID(GID)
	local ParamIndex = self:GetSelectListItemVMParamIndexByGID(GID)
	if ParamIndex > 0 then
		return self.SelectedItemListParams[ParamIndex].Num
	end
	return 1
end

function MeetTradeBagMainVM:GetCurrentSelectItemNum()
	return self.TipsPanelItemNumber
end	

function MeetTradeBagMainVM:UpdateCurrentEditQuantitySetting(EditQuantityView)
	---点击了新的物品，需要重置数量编辑器的参数
	---要在其他参数更新完成后进行更新
	EditQuantityView:SetInputLowerLimit(1)
	EditQuantityView:SetInputUpperLimit(MeetTradeBagMainVM:GetCurrentSelectItemNum())
	EditQuantityView:SetCurValue(MeetTradeBagMainVM:GetCurrentSelectItemNumForTrade())
	---必须在这里更新，EditQuantityVisible可见时会按照设置的CurValue再进行一次数值设置
	local CurItemVM = self:GetCurItemVM()
	if nil ~= CurItemVM then
		self.EditQuantityVisible = CurItemVM:GetIsCanPile()
	end
end

function MeetTradeBagMainVM:GetCreatSelectListItemVMParam(ItemVM)
	local Params = {
		IsShowNum = true,
		IsShowLeftCornerFlag = ItemVM.IsShowLeftCornerFlag,
		Item = ItemVM.Item,
		IsValid = ItemVM.IsValid,
		GID = ItemVM.GID,
		ResID = ItemVM.ResID,
		Num = 1,
		NumVisible = ItemVM.NumVisible,
		Name = ItemVM.Name,
		Icon = ItemVM.Icon,
		ItemType = ItemVM.ItemType,
		ItemColor = ItemVM.ItemColor,
		ItemLevel = ItemVM.ItemLevel,
		IsBind = ItemVM.IsBind,
		IsUnique = ItemVM.IsUnique,
		IsHQ = ItemVM.IsHQ,
		ItemQualityIcon = ItemVM.ItemQualityIcon,
		IsMask = ItemVM.IsMask,
		ItemVisible = ItemVM.ItemVisible,
		IsSelectedForTrade = false,
		Selecte = false,
		IsShowOtherInfo = false,
		IsShowDeletButton = true,
	}
	return Params
end

function MeetTradeBagMainVM:SubmitSelectItemInfo()
	--- 向服务器上报ItemList
	local SendParams = {}
	local Params = self.SelectedItemListParams
	for i = 1, #Params do
		local ItemParam = {
			GID = Params[i].GID,
			ResID = Params[i].ResID,
			Num = Params[i].Num,
		}
		table.insert(SendParams, ItemParam)

	end
	_G.MeetTradeMgr:SendMeetTradePlaceItem(SendParams,_G.MeetTradeMgr.GoldForTrade)
end

function MeetTradeBagMainVM:GetTipsPanelItemResID()
	return self.TipsPanelItemResID
end

---Tab页相关
function MeetTradeBagMainVM:SetIsBag(IsBag)
	self.IsBag = IsBag
	if self.IsBag then
		self.TitleNameText = LSTR(1490007)
		self.SubTitleText = self:IsItemTab() and self:GetItemTabName(self.TabIndex) or self:GetEquipTabName(self.TabIndex)
        --- TODO 逻辑需要修改
		local ClickedItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
		self:SetEmptyItem(ClickedItemVM == nil or ClickedItemVM.IsValid == false)
	else
		self.SubTitleText = LSTR(1490007)
		self.PanelDetailVisible = false
	end
end

function MeetTradeBagMainVM:GetItemTabName(TabIndex)
	if TabIndex == nil then
		return ""
	end

	if BagDefine.ItemTabs == nil then
		return ""
	end

	if TabIndex < 0 or TabIndex > #BagDefine.ItemTabs then
		return ""
	end

	return BagDefine.ItemTabs[TabIndex].Name
end

function MeetTradeBagMainVM:GetEquipTabName(TabIndex)
	if TabIndex == nil then
		return ""
	end
	
	if BagDefine.EquipTabs == nil then
		return ""
	end
	
	if TabIndex < 0 or TabIndex > #BagDefine.EquipTabs then
		return ""
	end

	return BagDefine.EquipTabs[TabIndex].Name
end

function MeetTradeBagMainVM:GetItemTabType(TabIndex)
	if TabIndex == nil then
		return BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL
	end

	if BagDefine.ItemTabs == nil then
		return BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL
	end

	if TabIndex < 0 or TabIndex > #BagDefine.ItemTabs then
		return BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL
	end

	return BagDefine.ItemTabs[TabIndex].Type
end

function MeetTradeBagMainVM:GetEquipTabType(TabIndex)
	if TabIndex == nil then
		return BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL
	end
	if BagDefine.EquipTabs == nil then
		return BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL
	end
	
	if TabIndex < 0 or TabIndex > #BagDefine.EquipTabs then
		return BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL
	end

	return BagDefine.EquipTabs[TabIndex].Type
end

function MeetTradeBagMainVM:IsItemTab()
	return self.IsBagPage
end

function MeetTradeBagMainVM:IsEquipTab()
	return self.IsEquipPage 
end

function MeetTradeBagMainVM:InitShowTabIndex()
	self.IsEquipPage = false
	self.IsBagPage = true
end

function MeetTradeBagMainVM:SetTabToItem()
	self.IsEquipPage = false
	self.IsBagPage = true
	self:SetCurTabIndex(1)
end

function MeetTradeBagMainVM:SetTabToEquip()
	self.IsEquipPage = true
	self.IsBagPage = false
	self:SetCurTabIndex(1)
end
--要返回当前类
return MeetTradeBagMainVM