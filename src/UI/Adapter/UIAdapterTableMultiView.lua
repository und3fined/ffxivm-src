--
-- Author: anypkvcai
-- Date: 2021-03-24 14:18
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIAdapterBindableList = require("UI/Adapter/UIAdapterBindableList")
local HashUtil = require("Utils/HashUtil")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING

---@class UIAdapterTableMultiView : UIAdapterBindableList
---@field OnSelectChanged function    @点击、双击、调用SetSelectedIndex都会执行
---@field OnDoubleClicked function @双击会执行
---@field OnClicked function    @单击会执行
---@field SelectedIndex number    @选中的索引 有效范围：1~列表长度
---@field ArrayItems UE.TArray @传递给UE控件的列表 目前是计算Table元素的哈希值 所有Table元素不要有重复值
---@field MapItemInfos table<number, table>
local UIAdapterTableMultiView = LuaClass(UIAdapterBindableList, true)

---CreateAdapter
---@param View UIView
---@param Widget UTableView
---@param OnSelectChanged function
---@param AlwaysNotifySelectChanged boolean @AlwaysNotifySelectChanged为true时 点击同一个Item也会发送OnSelectChanged通知
---@return UIView
function UIAdapterTableMultiView.CreateAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse)
	local Adapter = UIAdapterTableMultiView.New()
	Adapter:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse)
	return Adapter
end

---Ctor
function UIAdapterTableMultiView:Ctor()
	--print("UIAdapterTableMultiView:Ctor")
	self.OnSelectChanged = nil
	self.OnClicked = nil
	self.OnDoubleClicked = nil
	self.SelectedItems = {}
	self.SelectedItemsIndex = {}
	self.ArrayItems = _G.UE.TArray(0)
	self.MapItemInfos = {}

	self.CategoryVMClass = nil
	self.CategoryVMItemMap = {}

	self.bReverse = false
end

---OnDestroy
---@private
function UIAdapterTableMultiView:OnDestroy()
	--print("UIAdapterTableMultiView:OnDestroy")
	self.OnSelectChanged = nil
	self.OnClicked = nil
	self.OnDoubleClicked = nil
	self.SelectedItems = {}
	self.SelectedItemsIndex = {}
	self.MapItemInfos = {}

	self.Super:OnDestroy()
end

---HideSubView
function UIAdapterTableMultiView:HideSubView(Params)
	local Widget = self.Widget
	if nil ~= Widget then
		Widget:ClearTableItems()

		--if Params and Params.IsRegenerateTableViewEntries then
		Widget:RegenerateAllEntries()
		--end
	end

	self.Super:HideSubView(Params)
end

---DestroySubView
function UIAdapterTableMultiView:DestroySubView(Params)
	local Widget = self.Widget
	if nil ~= Widget then
		Widget.BP_OnItemShow:Clear()
		Widget.BP_OnItemHide:Clear()
		Widget.BP_OnItemClicked:Clear()
		Widget.BP_OnGetEntryWidgetIndex:Unbind()
	end

	self.Super:DestroySubView(Params)
end

---InitAdapter
---@param View UIView
---@param Widget UTableView
---@param OnSelectChanged function
---@param AlwaysNotifySelectChanged boolean
function UIAdapterTableMultiView:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse)
	self.Super:InitAdapter(View, Widget)

	self.OnSelectChanged = OnSelectChanged
	self.AlwaysNotifySelectChanged = AlwaysNotifySelectChanged
	self.bReverse = bReverse or false

	local function OnItemShow(_, Item, ItemView)
		self:OnTableItemShow(ItemView, Item)
	end

	local function OnItemUpdate(_, Item, ItemView)
		self:OnTableItemUpdate(ItemView, Item)
	end

	local function OnItemHide(_, ItemView)
		self:OnTableItemHide(ItemView)
	end

	local function OnItemClicked(_, Item, ItemView)
		local Index = self:GetItemIndex(Item)
		local ItemData = self:GetItemData(Item)
		self:OnTableItemClicked(ItemView, Index, ItemData)
	end

	local function OnGetEntryWidgetIndex(_, Item)
		return self:OnTableItemGetWidgetIndex(Item)
	end

	Widget.BP_OnItemShow:Add(View, OnItemShow)
	Widget.BP_OnItemUpdate:Add(View, OnItemUpdate)
	Widget.BP_OnItemHide:Add(View, OnItemHide)
	Widget.BP_OnItemClicked:Add(View, OnItemClicked)
	Widget.BP_OnGetEntryWidgetIndex:Bind(self.Object, OnGetEntryWidgetIndex)
end

---InitCategoryInfo
---@param CategoryVMClass ViewModelClass
function UIAdapterTableMultiView:InitCategoryInfo(CategoryVMClass)
	self.CategoryVMClass = CategoryVMClass
end

---OnTableItemShow
---@param ItemView UIView
---@private
function UIAdapterTableMultiView:OnTableItemShow(ItemView, Item)
	--print("UIAdapterTableMultiView:OnTableItemShow", ItemView, Item)

	local Index = self:GetItemIndex(Item)
	local ItemData = self:GetItemData(Item)

	self:AddSubView(ItemView)

	if nil == ItemView.InitView then
		return
	end

	ItemView:InitView()
	ItemView:LoadView()
	ItemView:ShowView({ Index = Index, Data = ItemData, Adapter = self })

	if nil ~= ItemView.OnSelectChanged then
		ItemView:OnSelectChanged(self.SelectedItemsIndex[Index] == true)
	end
end

---OnTableItemUpdate
---@param ItemView UIView
---@private
function UIAdapterTableMultiView:OnTableItemUpdate(ItemView, Item)
	--print("UIAdapterTableMultiView:OnTableItemUpdate", ItemView, Item)

	local Params = ItemView.Params
	if nil == Params then
		return
	end

	local Index = self:GetItemIndex(Item)
	if nil == Index then
		return
	end

	ItemView:CheckPlayAnimIn()

	Params.Index = Index
end

---OnTableItemHide
---@param ItemView UIView
---@private
function UIAdapterTableMultiView:OnTableItemHide(ItemView)
	--print("UIAdapterTableMultiView:OnTableItemHide", ItemView)

	--local Params = { IsRegenerateTableViewEntries = true }
	if nil ~= ItemView.HideView then
		ItemView:HideView()
	end

	if nil ~= ItemView.UnloadView then
		ItemView:UnloadView()
	end

	if nil ~= ItemView.DestroyView then
		ItemView:DestroyView()
	end

	self:RemoveSubView(ItemView)
end

---OnTableItemClicked
---@param ItemView UIView
---@private
function UIAdapterTableMultiView:OnTableItemClicked(ItemView, Index, ItemData)
	--print("UIAdapterTableMultiView:OnTableItemClicked", ItemView, Index, ItemData)

	self:HandleItemClicked(Index, ItemData, ItemView)

	local OnClicked = self.OnClicked
	if nil ~= OnClicked then
		OnClicked(self.View, Index, ItemData, ItemView)
	end

	if nil ~= ItemView.OnItemClicked then
		ItemView:OnItemClicked(Index, ItemData)
	end
end

---OnTableItemDoubleClicked
---@param ItemView UIView
---@private
function UIAdapterTableMultiView:OnTableItemDoubleClicked(ItemView, Index, ItemData)
	--print("UIAdapterTableMultiView:OnTableItemDoubleClicked", ItemView, Index, ItemData)

	self:HandleItemDoubleClicked(Index, ItemData, ItemView)

	local OnDoubleClicked = self.OnDoubleClicked
	if nil ~= OnDoubleClicked then
		OnDoubleClicked(self.View, Index, ItemData, ItemView)
	end

	if nil ~= ItemView.OnItemDoubleClicked then
		ItemView:OnItemDoubleClicked(Index, ItemData)
	end
end

---OnTableItemGetWidgetIndex
---@param Item number
---@private
function UIAdapterTableMultiView:OnTableItemGetWidgetIndex(Item)
	--FLOG_INFO("UIAdapterTableMultiView:OnTableItemGetWidgetIndex Item=%d", Item)
	local ItemData = self:GetItemData(Item)
	if nil == ItemData then
		return 0
	end

	local AdapterOnGetWidgetIndex = ItemData.AdapterOnGetWidgetIndex
	if nil == AdapterOnGetWidgetIndex then
		FLOG_WARNING("UIAdapterTableMultiView:OnTableItemGetWidgetIndex AdapterOnGetWidgetIndex is nil")
		return 0
	end

	return ItemData:AdapterOnGetWidgetIndex()
end

function UIAdapterTableMultiView:GetItemIndex(Item)
	local ItemData = self:GetItemData(Item)
	if nil == ItemData then
		--FLOG_WARNING("UIAdapterTableMultiView:GetItemIndex ItemData is nil")
		return
	end

	return self.BindableList:GetItemIndex(ItemData)
end

function UIAdapterTableMultiView:GetItemInfo(Item)
	return self.MapItemInfos[Item]
end

function UIAdapterTableMultiView:GetItemData(Item)
	local ItemInfo = self.MapItemInfos[Item]
	if nil == ItemInfo then
		return
	end

	return ItemInfo.ItemData
end

---ClearChildren
---@private
function UIAdapterTableMultiView:ClearChildren()
	--self:CancelSelected()
	self.Widget:ClearTableItems()
	self.ArrayItems:Clear()
	self.MapItemInfos = {}
end

---UpdateChildren
---@private
function UIAdapterTableMultiView:UpdateChildren()
	local Widget = self.Widget
	if nil == Widget then
		return
	end

	local ArrayItems = self.ArrayItems
	ArrayItems:Clear()

	self.MapItemInfos = {}
	local MapItemInfos = self.MapItemInfos
	local BindableList = self.BindableList

	local Num = self.Num or BindableList:Length()
	local CategoryAdded = {}
	for i = 1, Num do
		local ItemData = BindableList:Get(i)
		self:UpdateCategory(ItemData, CategoryAdded, ArrayItems)
		local Hash = self:GetHash(ItemData)
		ArrayItems:Add(Hash)
		MapItemInfos[Hash] = { ItemData = ItemData }
	end

	self:RefreshCategoryMap(CategoryAdded)

	self.Widget:BP_SetTableItems(ArrayItems)
end

---UpdateCategory
---@private
function UIAdapterTableMultiView:UpdateCategory(ItemData, CategoryAdded, ArrayItems)
	if (self.CategoryVMClass == nil) or (ItemData == nil) then return end

	if ItemData.AdapterGetCategory == nil then
		FLOG_WARNING("UIAdapterTableMultiView:UpdateCategory() ItemData lacking realization of AdapterGetCategory()")
		return
	end

	local ItemCategory = ItemData:AdapterGetCategory()
	if (ItemCategory == nil) or CategoryAdded[ItemCategory] then return end

	local CategoryVMItem = self.CategoryVMItemMap[ItemCategory]
	if CategoryVMItem == nil then
		CategoryVMItem = self.CategoryVMClass.New()
		if CategoryVMItem.AdapterSetCategory == nil then
			FLOG_WARNING("UIAdapterTableMultiView:UpdateCategory() CategoryVMItem lacking realization of AdapterSetCategory()")
			return
		end
		CategoryVMItem:AdapterSetCategory(ItemCategory)
		self.CategoryVMItemMap[ItemCategory] = CategoryVMItem
	end

	local Hash = self:GetHash(CategoryVMItem)
	ArrayItems:Add(Hash)
	self.MapItemInfos[Hash] = { ItemData = CategoryVMItem }

	CategoryAdded[ItemCategory] = true
end

---RefreshCategoryMap
---@private
function UIAdapterTableMultiView:RefreshCategoryMap(CategoryAdded)
	for ItemCategory, _ in pairs(self.CategoryVMItemMap) do
		if not CategoryAdded[ItemCategory] then
			self.CategoryVMItemMap[ItemCategory] = nil
		end
	end
end

---GetSelectedIndex
---@return number
function UIAdapterTableMultiView:GetSelectedIndex()
	return self.SelectedItemsIndex
end

---ScrollToTop
function UIAdapterTableMultiView:ScrollToTop()
	self.Widget:ScrollToTop()
end

---ScrollToBottom
function UIAdapterTableMultiView:ScrollToBottom()
	self.Widget:ScrollToBottom()
end

---ScrollToIndex  下标从1开始
---@param Index number
function UIAdapterTableMultiView:ScrollToIndex(Index)
	self.Widget:SetScrollOffset(Index - 1)
end

---ScrollIndexIntoView @只是滚动到可见位置 并不一定是在顶部  下标从1开始
---@param Index number
function UIAdapterTableMultiView:ScrollIndexIntoView(Index)
	self.Widget:ScrollIndexIntoView(Index - 1)
end

---IsUserScrolling
---@return boolean
function UIAdapterTableMultiView:IsUserScrolling()
	return self.Widget:IsUserScrolling()
end

---IsAtEndOfList
---@return boolean
function UIAdapterTableMultiView:IsAtEndOfList()
	return self.Widget:IsAtEndOfList()
end

---SetScrollbarIsVisible
---@param IsVisible boolean
function UIAdapterTableMultiView:SetScrollbarIsVisible(IsVisible)
	self.Widget:SetScrollbarIsVisible(IsVisible)
end

---GetHash
---@param ItemData UIViewModel | table
---@private
function UIAdapterTableMultiView:GetHash(ItemData)
	local Str = tostring(ItemData)

	--BKDRHash
	return HashUtil.BKDRHash(Str)
end

--[chaooren]临时统一UIAdapterDynamicEntryBox和UIAdapterTableMultiView的接口
function UIAdapterTableMultiView:OnItemClicked(ItemView, Index)
	local ItemData = self:GetItemDataByIndex(Index)
	self:OnTableItemClicked(ItemView, Index, ItemData)
end

function UIAdapterTableMultiView:OnItemDoubleClicked(ItemView, Index)
	local ItemData = self:GetItemDataByIndex(Index)
	self:OnTableItemDoubleClicked(ItemView, Index, ItemData)
end

---ClearSelectedItem @只是设置选中为空
function UIAdapterTableMultiView:ClearSelectedItem()
	self.SelectedItems = {}
	self.SelectedItemsIndex = {}
end

---SetIndexSelectedStatus
---@param Index number
---@param Status bool
---@return boolean  @是否设置成功
function UIAdapterTableMultiView:SetIndexSelectedStatus(Index, Status)
	if nil == Index or nil == Status then
		return false
	end

	local ItemData = self:GetItemDataByIndex(Index)
	if nil == ItemData then
		return false
	end

	local Item = self:GetHash(ItemData)
	local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Item)
	return self:HandleSelectChanged(Index, Item, ItemData, ItemView, Status)
end

---SetItemSelectedStatus
---@param ItemData table
---@return boolean  @是否设置成功
function UIAdapterTableMultiView:SetItemSelectedStatus(ItemData, Status)
	if nil == ItemData or nil == Status then
		return false
	end

	local Item = self:GetHash(ItemData)
	local Index = self.BindableList:GetItemIndex(ItemData)
	local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Item)
	return self:HandleSelectChanged(Index, Item, ItemData, ItemView, Status)
end

function UIAdapterTableMultiView:SelectedAll()
	self.SelectedItems = {}
	self.SelectedItemsIndex = {}
	local ItemsIndex = {}
	local Length = self.BindableList:Length()
	for Index = 1, Length do
		local ItemData = self:GetItemDataByIndex(Index)
		if ItemData ~= nil then
			local Item = self:GetHash(ItemData)
			table.insert(self.SelectedItems, Item)
			ItemsIndex[Index] = true
			if self.SelectedItemsIndex[Index] ~= true then
				local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Item)
				if nil ~= ItemView and nil ~= ItemView.OnSelectChanged then
					ItemView:OnSelectChanged(true)
				end
			end
		end
	end
	self.SelectedItemsIndex = ItemsIndex
end

---CancelSelected
function UIAdapterTableMultiView:CancelSelectedAll()
	if self.SelectedItems == {} then
		return
	end

	local Items = self.SelectedItems
	self.SelectedItems = {}
	self.SelectedItemsIndex = {}

	for _, Item in ipairs(Items) do
		local ItemData = self:GetItemData(Item)
		if nil ~= ItemData then
			local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Item)
			if nil ~= ItemView and nil ~= ItemView.OnSelectChanged then
				ItemView:OnSelectChanged(false)
			end
		end
	end
end

---HandleItemClicked
---@param Index number
---@param ItemData UIViewModel | table
---@param ItemView UIView
---@private
function UIAdapterTableMultiView:HandleItemClicked(Index, ItemData, ItemView)
	local Item = self:GetHash(ItemData)
	self:HandleSelectChanged(Index, Item, ItemData, ItemView)
end

---HandleItemDoubleClicked
---@param Index number
---@param ItemData UIViewModel | table
---@param ItemView UIView
---@private
function UIAdapterTableMultiView:HandleItemDoubleClicked(Index, ItemData, ItemView)
	local Item = self:GetHash(ItemData)
	self:HandleSelectChanged(Index, Item, ItemData, ItemView)
end

function UIAdapterTableMultiView:HandleSelectChanged(Index, Item, ItemData, ItemView, Status)
	if nil == ItemData then
		return false
	end

	if Status == nil then
		if self.bReverse then
			Status = self.SelectedItemsIndex[Index] ~= true
		else
			Status = true
		end
	end

	local bCallback = false

	local CurStatus = self.SelectedItemsIndex[Index] or false
	if CurStatus ~= Status then
		if Status then
			table.insert(self.SelectedItems, Item)
			self.SelectedItemsIndex[Index] = true
		else
			table.remove_item(self.SelectedItems, Item)
			self.SelectedItemsIndex[Index] = nil
		end
		bCallback = true
	elseif self.AlwaysNotifySelectChanged then
		bCallback = true
	end
	if bCallback then
		if nil ~= ItemView and nil ~= ItemView.OnSelectChanged then
			ItemView:OnSelectChanged(Status)
		end

		if nil ~= self.OnSelectChanged then
			self.OnSelectChanged(self.View, Index, ItemData, ItemView, Status)
		end
	end

	return true
end

-- ---HandleSelected
-- ---@param Index number
-- ---@param Item number
-- ---@param ItemData table
-- ---@param ItemView UIView
-- ---@param IsByClick bool  是否是click过来的   如果以后doubleclick也需要再说吧（应该不用，因为有专门的双击的回调接口）
-- ---@private
-- function UIAdapterTableMultiView:HandleSelected(Index, Item, ItemData, ItemView, IsByClick)
-- 	if nil == ItemData then
-- 		return false
-- 	end

-- 	local bCallback = false

-- 	if Item ~= self.SelectedItem then
-- 		if self:GetItemDataCanBeSelected(ItemData) then
-- 			self:CancelSelected()

-- 			self.SelectedItem = Item

-- 			bCallback = true
-- 		end
-- 	else
-- 		if self.AlwaysNotifySelectChanged then
-- 			bCallback = true
-- 		end
-- 	end

-- 	if bCallback then
-- 		if nil ~= ItemView and nil ~= ItemView.OnSelectChanged then
-- 			ItemView:OnSelectChanged(true, IsByClick)
-- 		end

-- 		if nil ~= self.OnSelectChanged then
-- 			self.OnSelectChanged(self.View, Index, ItemData, ItemView, IsByClick)
-- 		end
-- 	end

-- 	return true
-- end

---SetAlwaysNotifySelectChanged
---@param AlwaysNotifySelectChanged boolean
function UIAdapterTableMultiView:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
	self.AlwaysNotifySelectChanged = AlwaysNotifySelectChanged
end

---SetOnSelectChangedCallback
---@param Callback function
function UIAdapterTableMultiView:SetOnSelectChangedCallback(Callback)
	self.OnSelectChanged = Callback
end

---SetOnClickedCallback
---@param Callback function
function UIAdapterTableMultiView:SetOnClickedCallback(Callback)
	self.OnClicked = Callback
end

---SetOnDoubleClickedCallback
---@param Callback table
function UIAdapterTableMultiView:SetOnDoubleClickedCallback(Callback)
	self.OnDoubleClicked = Callback
end

return UIAdapterTableMultiView