--
-- Author: anypkvcai
-- Date: 2021-03-24 14:18
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIAdapterBindableList = require("UI/Adapter/UIAdapterBindableList")
local HashUtil = require("Utils/HashUtil")
local UIUtil = require("Utils/UIUtil")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING

---@class UIAdapterTableView : UIAdapterBindableList
---@field OnSelectChanged function    @点击、双击、调用SetSelectedIndex都会执行
---@field OnDoubleClicked function @双击会执行
---@field OnClicked function    @单击会执行
---@field SelectedIndex number    @选中的索引 有效范围：1~列表长度
---@field ArrayItems UE.TArray @传递给UE控件的列表 目前是计算Table元素的哈希值 所有Table元素不要有重复值
---@field MapItemInfos table<number, table>
local UIAdapterTableView = LuaClass(UIAdapterBindableList, true)

---CreateAdapter
---@param View UIView
---@param Widget UTableView
---@param OnSelectChanged function
---@param AlwaysNotifySelectChanged boolean @AlwaysNotifySelectChanged为true时 点击同一个Item也会发送OnSelectChanged通知
---@param bReverse boolean @点击已选中Item后是否取消选中
---@param bClearCache boolean @全量刷新的时候先将ActiveWidgets的缓存放到InactiveWidgets里面
---@param bClearCacheOnHide boolean @调用UIUtil.SetIsVisible隐藏时是否清除缓存 可以减少内存占用 但再次使用时要重新创建。也可以通过SetClearCacheOnHide函数设置
---@param bClearCacheOnUnload boolean @调用UIViewMgr:HideView时是否清理缓存 可以减少内存占用 但再次使用时要重新创建。也可以通过SetClearCacheOnUnload函数设置
---@return UIView
function UIAdapterTableView.CreateAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse, bClearCache, bClearCacheOnHide, bClearCacheOnUnload)
	if nil == View or nil == Widget then
		return
	end
	local Adapter = UIAdapterTableView.New()
	Adapter:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse, bClearCache, bClearCacheOnHide, bClearCacheOnUnload)
	return Adapter
end

---Ctor
function UIAdapterTableView:Ctor()
	--print("UIAdapterTableView:Ctor")
	self.WidgetName = ""
	self.OnSelectChanged = nil
	self.OnClicked = nil
	self.OnDoubleClicked = nil
	self.SelectedItem = nil
	self.ArrayItems = _G.UE.TArray(0)
	self.MapItemInfos = {}

	self.CategoryVMClass = nil
	self.CategoryVMItemMap = {}

	self.TableDelayDisplayTime = 0
	self.ItemDelayDisplayInterval = 0
	self.ItemRealDelayDisplayTime = 0
	self.bIsEnableTableDelayShow = false
	self.bIsEnableItemDelayShow = true
	self.Timers = {}
	self.ItemClickMap = {}
	self.ItemViewList = {}

	self.bEnabledRetainerBoxPool = false
	self.ItemIndexList = {}
	self.ItemShowStatusList = {}
	self.CurShowItemNum = 0
	self.CurShowItemIndex = 0
	self.IsFrontToTail = true
	self.bLessRenderModeChange = false      -- 减少RT数量

	self.bAutoPlayAnimation = false
	self.bClearCache = false
	self.bClearCacheOnHide = false
	self.bClearCacheOnUnload = false
end

---OnDestroy
---@private
function UIAdapterTableView:OnDestroy()
	--print("UIAdapterTableView:OnDestroy")
	self.OnSelectChanged = nil
	self.OnClicked = nil
	self.OnDoubleClicked = nil
	self.SelectedItem = nil
	self.MapItemInfos = {}

	self.TableDelayDisplayTime = 0
	self.ItemDelayDisplayInterval = 0
	self.ItemRealDelayDisplayTime = 0
	self.bIsEnableTableDelayShow = false
	self.bIsEnableItemDelayShow = true
	self.ItemClickMap = {}
	self.ItemViewList = {}

	self.ItemIndexList = {}
	self.ItemShowStatusList = {}
	self.bEnabledRetainerBoxPool = false

	local Widget = self.Widget
	if nil ~= Widget and Widget:IsValid() then
		Widget.BP_OnItemShow:Clear()
		Widget.BP_OnItemHide:Clear()
		Widget.BP_OnReleaseAll:Clear()
		Widget.BP_OnItemClicked:Clear()
		Widget.BP_OnGetEntryWidgetIndex:Unbind()
	end

	self:CancelAllItemDelayDisplayTimers()
	self.Super:OnDestroy()
end

---OnHide
function UIAdapterTableView:OnHide()
	self:ReleaseAllItem(self.bClearCacheOnHide)

	-- 父类函数没有功能 可以不调用
	--self.Super:OnHide()
end

---OnUnload
function UIAdapterTableView:OnUnload()
	if self.bClearCacheOnUnload then
		local Widget = self.Widget
		if nil ~= Widget and Widget:IsValid() then
			Widget:ResetWidgetPoolPool()
		end
	end

	-- 父类函数没有功能 可以不调用
	--self.Super:OnUnload()
end

-----ShowSubView
--function UIAdapterTableView:ShowSubView(Params)
--
--end

---HideSubView
function UIAdapterTableView:HideSubView(Params)
	self.ItemRealDelayDisplayTime = self.TableDelayDisplayTime
	if self.TableDelayDisplayTime > 0.0 then
		self.bIsEnableTableDelayShow = true
	end

	self.Super:HideSubView()
end

---ShowSubView
function UIAdapterTableView:ActiveSubView()
	--SubView一般用不到Active功能， 为了性能暂不调用
end

---ShowSubView
function UIAdapterTableView:InactiveSubView()

end

---UpdateSubView
function UIAdapterTableView:UpdateSubView()

end

---ReleaseAllWidgets 释放所有的Item 一般建议用 ClearCacheOnUnload 或 ClearCacheOnHide 来控制
---@param bClearCache @是否清除缓存
function UIAdapterTableView:ReleaseAllItem(bClearCache)
	local SubViews = self.SubViews
	if nil == SubViews or #SubViews <= 0 then
		return
	end

	self:HideSubView()
	self:UnloadSubView()
	self:DestroySubView()

	self.ArrayItems:Clear()
	self.MapItemInfos = {}
	self.SubViews = {}
	self:CancelAllItemDelayDisplayTimers()

	local Widget = self.Widget
	if nil ~= Widget and Widget:IsValid() then
		Widget:ClearTableItems()
		Widget:ReleaseAllWidgets(bClearCache or false)
	end

	self.ItemClickMap = {}
	self.ItemViewList = {}

	self.ItemIndexList = {}
	self.ItemShowStatusList = {}
end

---InitAdapter
---@param View UIView
---@param Widget UTableView
---@param OnSelectChanged function
---@param AlwaysNotifySelectChanged boolean
---@param bReverse boolean
function UIAdapterTableView:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse, bClearCache, bClearCacheOnHide, bClearCacheOnUnload)
	self.Super:InitAdapter(View, Widget)
	self.WidgetName = Widget:GetName()
	self.OnSelectChanged = OnSelectChanged
	self.AlwaysNotifySelectChanged = AlwaysNotifySelectChanged
	self.bReverse = bReverse or false
	self.bClearCache = bClearCache or false
	self.bClearCacheOnHide = bClearCacheOnHide or false
	self.bClearCacheOnUnload = bClearCacheOnUnload or false
	self.TableDelayDisplayTime = Widget:GetTableDelayDisplayTime()
	self.ItemDelayDisplayInterval = Widget:GetTableItemDelayDisplayInterval()
	self.bEnabledRetainerBoxPool = Widget:GetEnableRetainerBoxPool() and Widget:GetUseRetainerBoxPool()
	self.bAutoPlayAnimation = Widget:GetAutoPlayAnimation()

	-- FLOG_INFO("UIAdapterTableView:InitAdapter, TableDelayDisplayTime=%f, ItemDelayDisplayInterval=%f, EnabledRetainerBoxPool=%s",
	-- 	self.TableDelayDisplayTime, self.ItemDelayDisplayInterval, tostring(self.bEnabledRetainerBoxPool))

	if self.TableDelayDisplayTime > 0.0 then
		self.bIsEnableTableDelayShow = true
	end

	self.ItemRealDelayDisplayTime = self.TableDelayDisplayTime

	local function OnItemShow(_, Item, ItemView)
		--self:OnTableItemShow(ItemView, Item)
		self:OnItemShow(Item, ItemView)
	end

	local function OnItemUpdate(_, Item, ItemView)
		self:OnTableItemUpdate(ItemView, Item)
	end

	local function OnItemHide(_, ItemView, bReleaseSlate)
		self:OnTableItemHide(ItemView, bReleaseSlate)
	end

	local function OnReleaseAll()
		self:OnTableReleaseAll()
	end

	local function OnItemClicked(_, Item, ItemView)
		local Index = self:GetItemIndex(Item)
		local ItemData = self:GetItemData(Item)
		if nil == ItemData then
			return
		end
		self:OnTableItemClicked(ItemView, Index, ItemData)
	end

	local function OnGetEntryWidgetIndex(_, Item)
		return self:OnTableItemGetWidgetIndex(Item)
	end

	Widget.BP_OnItemShow:Add(View, OnItemShow)
	Widget.BP_OnItemUpdate:Add(View, OnItemUpdate)
	Widget.BP_OnItemHide:Add(View, OnItemHide)
	Widget.BP_OnReleaseAll:Add(View, OnReleaseAll)
	Widget.BP_OnItemClicked:Add(View, OnItemClicked)
	Widget.BP_OnGetEntryWidgetIndex:Bind(self.Object, OnGetEntryWidgetIndex)
end

---InitCategoryInfo
---@param CategoryVMClass ViewModelClass
function UIAdapterTableView:InitCategoryInfo(CategoryVMClass)
	self.CategoryVMClass = CategoryVMClass
end

---OnItemShow
---@param Item number
---@param ItemView UIView
---@private
function UIAdapterTableView:OnItemShow(Item, ItemView)
	if nil == ItemView then
		return
	end

	if (self.TableDelayDisplayTime > 0.0 or self.ItemDelayDisplayInterval > 0.0) and self.bIsEnableItemDelayShow == true then
		local Index = self:GetItemIndex(Item)
		if Index == 1 then
			self:ResetDelayDisplayEffect()
		end
		UIUtil.SetRenderOpacity(ItemView, 0.0)
		--self.ItemRealDelayDisplayTime = self.TableDelayDisplayTime + self.ItemDelayDisplayInterval * Index

		-- if nil == self.Timers[Index] then
		self.ItemRealDelayDisplayTime = self.ItemRealDelayDisplayTime + self.ItemDelayDisplayInterval
		-- end

		--FLOG_INFO("UIAdapterTableView:OnItemShow, Index=%d, DelayDisplayTime=%f", Index, self.ItemRealDelayDisplayTime)

		local Params = { Item = Item, ItemView = ItemView, ItemDelayDisplayInterval = self.ItemDelayDisplayInterval }
		local function ShowTableItem(Info)
			if nil ~= ItemView and nil ~= ItemView.Object and ItemView.Object:IsValid() then
				UIUtil.SetRenderOpacity(ItemView, 1.0)
				ItemView:PlayAnimIn()
			end
			if self.bIsEnableTableDelayShow then
				self.ItemRealDelayDisplayTime = self.ItemRealDelayDisplayTime - self.TableDelayDisplayTime
				self.bIsEnableTableDelayShow = false
			end
			self.ItemRealDelayDisplayTime = self.ItemRealDelayDisplayTime - Info.ItemDelayDisplayInterval
			-- if nil ~= self.Timers[Index] then
			-- 	_G.TimerMgr:CancelTimer(self.Timers[Index])
			-- 	self.Timers[Index] = nil
			-- end
			if nil ~= Index then
				self.ItemClickMap[Index] = true
				self.ItemViewList[Index] = ItemView
			end
			--FLOG_INFO("UIAdapterTableView:OnItemShow really, Index=%d, DelayDisplayTime=%f", Index, self.ItemRealDelayDisplayTime)
		end

		if nil ~= Index then
			self.ItemClickMap[Index] = false
			--if nil == self.Timers[Index] then
			--self.Timers[Index] = _G.TimerMgr:AddTimer(nil, ShowTableItem, self.ItemRealDelayDisplayTime, nil, nil, Params)
			self.Timers[Index] = self:RegisterTimer(ShowTableItem, self.ItemRealDelayDisplayTime, 1, 1, Params)
			--end
		end
	end

	self:OnTableItemShow(ItemView, Item)
end

---OnTableItemShow
---@param ItemView UIView
---@private
function UIAdapterTableView:OnTableItemShow(ItemView, Item)
	local Index = self:GetItemIndex(Item)
	--print("UIAdapterTableView:OnTableItemShow, ", Index, ItemView, Item)
	local ItemData = self:GetItemData(Item)

	self:AddSubView(ItemView)

	if nil == ItemView.InitView then
		return
	end

	ItemView:InitView()
	ItemView:LoadView()
	ItemView:ShowView({ Index = Index, Data = ItemData, Adapter = self })

	if nil ~= ItemView.OnSelectChanged then
		ItemView:OnSelectChanged(Item == self.SelectedItem)
	end

	if nil ~= Index then
		self.ItemViewList[Index] = ItemView
		if nil ~= self.Widget then
			if Index == 1 then
				self.Widget:SetScrollToFirstItem(Item)
			elseif Index == self:GetNum() then
				self.Widget:SetScrollToLastItem(Item)
			end
		end
		if self.bEnabledRetainerBoxPool then
			self.ItemIndexList[Index] = Item
			self.ItemShowStatusList[Index] = true
			self.CurShowItemNum = self.CurShowItemNum + 1
			self.IsFrontToTail = Index >= self.CurShowItemIndex
			self.CurShowItemIndex = Index
			--FLOG_INFO("UIAdapterTableView:OnTableItemShow, CurShowItemNum: %d, IsFrontToTail: %s, CurShowItemIndex: %d",
			--	self.CurShowItemNum, tostring(self.IsFrontToTail), self.CurShowItemIndex)
			self:ChangeItemsRenderMode()
		end
	end
end

---OnTableItemUpdate
---@param ItemView UIView
---@private
function UIAdapterTableView:OnTableItemUpdate(ItemView, Item)
	if nil == ItemView then
		return
	end
	--print("UIAdapterTableView:OnTableItemUpdate", ItemView, Item)

	if nil == ItemView then
		return
	end

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

	-- Fixed：数据A切换到空数据，然后再切回来的时候，没有地方可以通知ItemView的问题
	if nil ~= ItemView.OnItemUpdate then
		ItemView:OnItemUpdate()
	end
end

---OnTableItemHide
---@param ItemView UIView
---@private
function UIAdapterTableView:OnTableItemHide(ItemView, bReleaseSlate)
	if nil == ItemView then
		return
	end

	local Index = self:GetItemIndexByItemView(ItemView)
	--print("UIAdapterTableView:OnTableItemHide, ", Index, ItemView)
	if nil ~= Index then
		--FLOG_INFO("UIAdapterTableView:OnItemHide, Index=%d", Index)

		--计时器逻辑(暂不需要了)
		-- if nil ~= self.Timers[Index] then
		-- 	self.ItemRealDelayDisplayTime = self.ItemRealDelayDisplayTime - self.ItemDelayDisplayInterval
		-- 	_G.TimerMgr:CancelTimer(self.Timers[Index])
		-- 	self.Timers[Index] = nil
		-- 	--FLOG_INFO("UIAdapterTableView:OnItemHide, Index=%d, ItemRealDelayDisplayTime=%f", Index, self.ItemRealDelayDisplayTime)
		-- end
	end

	if nil ~= ItemView.HideView then
		ItemView:HideView()
	end

	if bReleaseSlate then
		ItemView:UnloadView()
		ItemView:DestroyView()
		table.remove_item(self.SubViews, ItemView)
	end

	if self.bEnabledRetainerBoxPool and nil ~= Index then
		self.ItemShowStatusList[Index] = false
		self.CurShowItemNum = self.CurShowItemNum - 1
		--print("UIAdapterTableView:OnTableItemHide, CurShowItemNum: ", self.CurShowItemNum)
		self:ChangeItemsRenderMode()
	end
end

---OnTableReleaseAll
function UIAdapterTableView:OnTableReleaseAll()
	--print("UIAdapterTableView:OnTableReleaseAll", #self.SubViews)
	self:ReleaseAllItem()
end

---OnTableItemClicked
---@param ItemView UIView
---@private
function UIAdapterTableView:OnTableItemClicked(ItemView, Index, ItemData)
	--print("UIAdapterTableView:OnTableItemClicked", Index, self.ItemClickMap[Index])
	if self.ItemClickMap[Index] == false then
		return
	end

	self:HandleItemClicked(Index, ItemData, ItemView)

	local OnClicked = self.OnClicked
	if nil ~= OnClicked then
		OnClicked(self.View, Index, ItemData, ItemView)
	end

	if nil ~= ItemView and nil ~= ItemView.Object and ItemView.Object:IsValid() and nil ~= ItemView.OnItemClicked then
		ItemView:OnItemClicked(Index, ItemData)
	end
end

---OnTableItemDoubleClicked
---@param ItemView UIView
---@private
function UIAdapterTableView:OnTableItemDoubleClicked(ItemView, Index, ItemData)
	--print("UIAdapterTableView:OnTableItemDoubleClicked", ItemView, Index, ItemData)

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
function UIAdapterTableView:OnTableItemGetWidgetIndex(Item)
	--FLOG_INFO("UIAdapterTableView:OnTableItemGetWidgetIndex Item=%d", Item)
	local ItemData = self:GetItemData(Item)
	if nil == ItemData then
		return 0
	end

	local AdapterOnGetWidgetIndex = ItemData.AdapterOnGetWidgetIndex
	if nil == AdapterOnGetWidgetIndex then
		FLOG_WARNING("UIAdapterTableView:OnTableItemGetWidgetIndex AdapterOnGetWidgetIndex is nil")
		return 0
	end

	return ItemData:AdapterOnGetWidgetIndex()
end

function UIAdapterTableView:GetItemIndexByItemView(ItemView)
	if nil ~= ItemView then
		for Index, Value in ipairs(self.ItemViewList) do
			if Value == ItemView then
				return Index
			end
		end
	end

	return nil
end

function UIAdapterTableView:GetItemIndex(Item)
	local ItemData = self:GetItemData(Item)
	if nil == ItemData then
		--FLOG_WARNING("UIAdapterTableView:GetItemIndex ItemData is nil")
		return
	end

	return self.BindableList:GetItemIndex(ItemData)
end

function UIAdapterTableView:GetItemDataIndex(ItemData)
	return self.BindableList:GetItemIndex(ItemData)
end

function UIAdapterTableView:GetItemInfo(Item)
	return self.MapItemInfos[Item]
end

function UIAdapterTableView:GetItemData(Item)
	local ItemInfo = self.MapItemInfos[Item]
	if nil == ItemInfo then
		return
	end

	return ItemInfo.ItemData
end

---ClearChildren
---@private
function UIAdapterTableView:ClearChildren()
	--self:CancelSelected()
	if self.bClearCache then
		--self.Widget:RegenerateAllEntries()
		self:ReleaseAllItem(true)
	else
		local Widget = self.Widget
		if nil ~= Widget and Widget:IsValid() then
			Widget:ClearTableItems()
		end
	end

	self.ArrayItems:Clear()
	self.MapItemInfos = {}
end

---UpdateChildren
---@private
function UIAdapterTableView:UpdateChildren()
	local Widget = self.Widget
	if nil == Widget or not Widget:IsValid()then
		return
	end

	local ArrayItems = self.ArrayItems
	local MapItemInfos = self.MapItemInfos
	local BindableList = self.BindableList

	local OriginNum = self.BindableList:Length()
	local MaxDisplayNum = self:GetMaxItemDataDisplayNum()
	local DisplayNum = 0

	local CategoryAdded = {}
	for i = 1, OriginNum do
		if DisplayNum >= MaxDisplayNum then
			break
		end

		local ItemData = BindableList:Get(i)
		if nil ~= ItemData then
			if self:IsItemVisible(ItemData) then
				self:UpdateCategory(ItemData, CategoryAdded, ArrayItems)
				local Hash = self:GetHash(ItemData)
				ArrayItems:Add(Hash)
				MapItemInfos[Hash] = { ItemData = ItemData }
				DisplayNum = DisplayNum + 1
			end
		end
	end

	self:RefreshCategoryMap(CategoryAdded)
	self.Widget:BP_SetTableItems(ArrayItems)
end

---GetMaxItemDataDisplayNum 允许子类重写，控制Item显示数量
---@protected
function UIAdapterTableView:GetMaxItemDataDisplayNum()
	return self:GetNum()
end

---IsItemVisible 允许子类重写，控制特定Item是否显示
---@protected
function UIAdapterTableView:IsItemVisible(ItemData)
	local AdapterOnGetIsVisible = ItemData.AdapterOnGetIsVisible
	return nil == AdapterOnGetIsVisible or ItemData:AdapterOnGetIsVisible()
end

function UIAdapterTableView:GetItemDataDisplayIndex(ItemData)
	if nil == ItemData then return end

	local ArrayItems = self.ArrayItems
	local ItemHash = self:GetHash(ItemData)
	for i = 1, ArrayItems:Length() do
		if ItemHash == ArrayItems:Get(i) then return i end
	end
end

---GetChildWidget
---@param Index number  @从1开始
function UIAdapterTableView:GetChildWidget(Index)
	local Widget = self.Widget
	if nil == Widget then
		return
	end

	local ItemData = self:GetItemDataByIndex(Index)
	if nil == ItemData then
		return
	end

	local Item = self:GetHash(ItemData)
	return Widget:BP_GetEntryWidgetFromItem(Item)
end

---UpdateCategory
---@private
function UIAdapterTableView:UpdateCategory(ItemData, CategoryAdded, ArrayItems)
	if (self.CategoryVMClass == nil) or (ItemData == nil) then
		return
	end

	if ItemData.AdapterGetCategory == nil then
		FLOG_WARNING("UIAdapterTableView:UpdateCategory() ItemData lacking realization of AdapterGetCategory()")
		return
	end

	local ItemCategory = ItemData:AdapterGetCategory()
	if (ItemCategory == nil) or CategoryAdded[ItemCategory] then
		return
	end

	local CategoryVMItem = self.CategoryVMItemMap[ItemCategory]
	if CategoryVMItem == nil then
		CategoryVMItem = self.CategoryVMClass.New()
		if CategoryVMItem.AdapterSetCategory == nil then
			FLOG_WARNING("UIAdapterTableView:UpdateCategory() CategoryVMItem lacking realization of AdapterSetCategory()")
			return
		end
		self.CategoryVMItemMap[ItemCategory] = CategoryVMItem
	end
	CategoryVMItem:AdapterSetCategory(ItemCategory)

	local Hash = self:GetHash(CategoryVMItem)
	ArrayItems:Add(Hash)
	self.MapItemInfos[Hash] = { ItemData = CategoryVMItem }

	CategoryAdded[ItemCategory] = true
end

---RefreshCategoryMap
---@private
function UIAdapterTableView:RefreshCategoryMap(CategoryAdded)
	for ItemCategory, _ in pairs(self.CategoryVMItemMap) do
		if not CategoryAdded[ItemCategory] then
			self.CategoryVMItemMap[ItemCategory] = nil
		end
	end
end

---GetSelectedIndex
---@return number
function UIAdapterTableView:GetSelectedIndex()
	local SelectedItem = self.SelectedItem
	if nil == SelectedItem then
		return
	end

	return self:GetItemIndex(SelectedItem)
end

---GetSelectedItemData
---@return any
function UIAdapterTableView:GetSelectedItemData()
	return self:GetItemDataByIndex(self:GetSelectedIndex())
end

---ScrollToTop
function UIAdapterTableView:ScrollToTop()
	self.Widget:ScrollToTop()
end

---ScrollToBottom
function UIAdapterTableView:ScrollToBottom()
	self.Widget:ScrollToBottom()
end

---ScrollToIndex  @下标从1开始 滑动到顶部, 因为是异步创建，如果在OnShow里调用需要延迟一会
---@param Index number
function UIAdapterTableView:ScrollToIndex(Index)
	if nil ~= Index and nil ~= self.Widget and self.Widget:IsValid() then
		self.Widget:ScrollToIndex(Index - 1)
	end
end

---ScrollIndexIntoView @下标从1开始 可见时不会滑动 不可见时滚动到中间位置
---@param Index number
function UIAdapterTableView:ScrollIndexIntoView(Index)
	if nil ~= Index and nil ~= self.Widget and self.Widget:IsValid() then
		self.Widget:ScrollIndexIntoView(Index - 1)
	end
end

---IsUserScrolling
---@return boolean
function UIAdapterTableView:IsUserScrolling()
	return self.Widget:IsUserScrolling()
end

---IsAtEndOfList
---@return boolean
function UIAdapterTableView:IsAtEndOfList()
	return self.Widget:IsAtEndOfList()
end

---SetScrollbarIsVisible
---@param IsVisible boolean
function UIAdapterTableView:SetScrollbarIsVisible(IsVisible)
	self.Widget:SetScrollbarIsVisible(IsVisible)
end

---SetTileAlignment
---@param Alignment EListItemAlignment
function UIAdapterTableView:SetTileAlignment(Alignment)
	self.Widget:SetTileAlignment(Alignment)
end

---GetHash
---@param ItemData UIViewModel | table
---@private
function UIAdapterTableView:GetHash(ItemData)
	if nil == ItemData then
		return
	end

	local GetKey = ItemData.GetKey
	if nil ~= GetKey then
		local Key = GetKey(ItemData)
		if nil ~= Key then
			return Key
		end
	end

	local Str = tostring(ItemData)

	--BKDRHash
	return HashUtil.BKDRHash(Str)
end

--[chaooren]临时统一UIAdapterDynamicEntryBox和UIAdapterTableView的接口
function UIAdapterTableView:OnItemClicked(ItemView, Index)
	local ItemData = self:GetItemDataByIndex(Index)
	self:OnTableItemClicked(ItemView, Index, ItemData)
end

function UIAdapterTableView:OnItemDoubleClicked(ItemView, Index)
	local ItemData = self:GetItemDataByIndex(Index)
	self:OnTableItemDoubleClicked(ItemView, Index, ItemData)
end

---ClearSelectedItem @只是设置选中为空
function UIAdapterTableView:ClearSelectedItem()
	self.SelectedItem = nil
end

---SetSelectedIndex
---@param Index number @下标，从1开始
---@return boolean  @是否设置成功
function UIAdapterTableView:SetSelectedIndex(Index)
	if nil == Index then
		self:CancelSelected()
		return false
	end

	local ItemData = self:GetItemDataByIndex(Index)
	if nil == ItemData then
		self:CancelSelected()
		return false
	end

	local Item = self:GetHash(ItemData)
	local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Item)
	return self:HandleSelected(Index, Item, ItemData, ItemView)
end

--- 根据条件选择选中的列表下标
---@param Predicate function @命中条件
---@return boolean @是否设置成功
function UIAdapterTableView:SetSelectedByPredicate(Predicate)
	local ItemData = self:GetItemDataByPredicate(Predicate)
	if ItemData ~= nil then
		self:SetSelectedItem(ItemData)
		return true
	end
	return false
end

--- 获取Item的对应Item的下标
---@param Predicate function @命中条件
function UIAdapterTableView:GetItemDataByPredicate(Predicate)
	local ItemData, Index = self.BindableList:Find(Predicate)
	if ItemData ~= nil then
		return ItemData, Index
	end
end

---SetSelectedItem
---@param ItemData table
---@return boolean  @是否设置成功
function UIAdapterTableView:SetSelectedItem(ItemData)
	if nil == ItemData then
		self:CancelSelected()
		return false
	end

	local Item = self:GetHash(ItemData)
	local Index = self.BindableList:GetItemIndex(ItemData)
	local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Item)
	return self:HandleSelected(Index, Item, ItemData, ItemView)
end

---SetSelectedKey @列表中的对象 需要实现GetKey函数
---@param Key any
function UIAdapterTableView:SetSelectedKey(Key)
	local ItemData = self:GetItemData(Key)
	local Index = self.BindableList:GetItemIndex(ItemData)
	local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Key)
	return self:HandleSelected(Index, Key, ItemData, ItemView)
end

---CancelSelected
function UIAdapterTableView:CancelSelected()
	local Item = self.SelectedItem
	if nil == Item then
		return
	end

	self.SelectedItem = nil

	local ItemData = self:GetItemData(Item)
	if nil == ItemData then
		return
	end

	local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Item)
	if nil ~= ItemView and nil ~= ItemView.OnSelectChanged then
		ItemView:OnSelectChanged(false)
	end
end

---HandleItemClicked
---@param Index number
---@param ItemData UIViewModel | table
---@param ItemView UIView
---@private
function UIAdapterTableView:HandleItemClicked(Index, ItemData, ItemView)
	local Item = self:GetHash(ItemData)
	self:HandleSelected(Index, Item, ItemData, ItemView, true)
end

---HandleItemDoubleClicked
---@param Index number
---@param ItemData UIViewModel | table
---@param ItemView UIView
---@private
function UIAdapterTableView:HandleItemDoubleClicked(Index, ItemData, ItemView)
	local Item = self:GetHash(ItemData)
	self:HandleSelected(Index, Item, ItemData, ItemView)
end

---HandleSelected
---@param Index number
---@param Item number
---@param ItemData table
---@param ItemView UIView
---@param bByClick bool  是否是click过来的   如果以后doubleclick也需要再说吧（应该不用，因为有专门的双击的回调接口）
---@private
function UIAdapterTableView:HandleSelected(Index, Item, ItemData, ItemView, bByClick)
	if nil == ItemData then
		return false
	end

	local bCallback = false
	local bSelectChanged = false
	if Item ~= self.SelectedItem then
		if self:GetItemDataCanBeSelected(ItemData, bByClick) then
			local LastItemData = self:GetItemData(self.SelectedItem)
			if nil ~= LastItemData and nil ~= LastItemData.SetNextClickItem then
				LastItemData:SetNextClickItem(ItemData)
			end

			self:CancelSelected()

			self.SelectedItem = Item

			bCallback = true
		end
	else
		if self.bReverse and self:GetItemDataCanBeSelected(ItemData, bByClick) then
			self:CancelSelected()
			if nil ~= self.OnSelectChanged then
				bSelectChanged = true
				self.OnSelectChanged(self.View, Index, ItemData, ItemView, bByClick)
			end
		elseif self.AlwaysNotifySelectChanged then
			bCallback = true
		end
	end

	if bCallback then
		if nil ~= ItemView and nil ~= ItemView.OnSelectChanged then
			bSelectChanged = true
			ItemView:OnSelectChanged(true, bByClick)
		end

		if nil ~= self.OnSelectChanged then
			bSelectChanged = true
			self.OnSelectChanged(self.View, Index, ItemData, ItemView, bByClick)
		end
	end

	if self.bAutoPlayAnimation and bSelectChanged then
		self:PlaySelectItemChangedAnimation(ItemView)
	end

	return true
end

function UIAdapterTableView:PlaySelectItemChangedAnimation(ItemView)
	if nil == ItemView then
		return
	end

	local ParentView = ItemView
	while nil ~= ParentView do
		local Anim = ParentView:GetSelectionChangedAnim(self.WidgetName)
		if nil ~= Anim then
			ParentView:PlayAnimation(Anim)
			break
		else
			ParentView = ParentView.ParentView
		end
	end
end

---SetAlwaysNotifySelectChanged
---@param AlwaysNotifySelectChanged boolean
function UIAdapterTableView:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
	self.AlwaysNotifySelectChanged = AlwaysNotifySelectChanged
end

---SetOnSelectChangedCallback
---@param Callback function
function UIAdapterTableView:SetOnSelectChangedCallback(Callback)
	self.OnSelectChanged = Callback
end

---SetOnClickedCallback
---@param Callback function
function UIAdapterTableView:SetOnClickedCallback(Callback)
	self.OnClicked = Callback
end

---SetOnDoubleClickedCallback
---@param Callback table
function UIAdapterTableView:SetOnDoubleClickedCallback(Callback)
	self.OnDoubleClicked = Callback
end

---EnableItemDelayShow
---@param Enable boolean
function UIAdapterTableView:EnableItemDelayShow(Enable)
	self.bIsEnableItemDelayShow = Enable
	self.Widget:SetScrollEnabled(not Enable)
end

function UIAdapterTableView:GetItemShowStatus(Index)
	if Index >= 1 and Index <= self:GetNum() then
		return self.ItemShowStatusList[Index]
	end
	return nil
end

function UIAdapterTableView:ChangeItemsRenderMode()
	-- local FrontItemIndex = 1
	-- local TailItemIndex = 1
	-- local ItemNum = #self.ItemShowStatusList

	-- for Index = 1, ItemNum do
	-- 	if nil ~= self.ItemShowStatusList[Index] and self.ItemShowStatusList[Index] == true then
	-- 		FrontItemIndex = Index
	-- 		break
	-- 	end
	-- end

	-- for Index = ItemNum, 1, -1 do
	-- 	if nil ~= self.ItemShowStatusList[Index] and self.ItemShowStatusList[Index] == true then
	-- 		TailItemIndex = Index
	-- 		break
	-- 	end
	-- end


	local FrontItemIndex = 1
	local TailItemIndex = 1
	local ItemNum = #self.ItemIndexList
	if self.IsFrontToTail then
		TailItemIndex = self.CurShowItemIndex
		FrontItemIndex = TailItemIndex - (self.CurShowItemNum - 1)
	else
		FrontItemIndex = self.CurShowItemIndex
		TailItemIndex = FrontItemIndex + (self.CurShowItemNum - 1)
	end

	if FrontItemIndex > TailItemIndex then
		FrontItemIndex = TailItemIndex
	end

	print("UIAdapterTableView:ChangeItemsRenderMode, ", FrontItemIndex, TailItemIndex)

	local Widget = self.Widget
	for Index = 1, ItemNum do
		Widget:SetEnabledNormalRender(self.ItemIndexList[Index], true)
	end

	Widget:SetEnabledNormalRender(self.ItemIndexList[FrontItemIndex], false)
	local Difference = TailItemIndex - FrontItemIndex
	if Difference > 1 and not self.bLessRenderModeChange then
		Widget:SetEnabledNormalRender(self.ItemIndexList[FrontItemIndex + 1], false)
	end
	if Difference > 2 and not self.bLessRenderModeChange then
		Widget:SetEnabledNormalRender(self.ItemIndexList[TailItemIndex - 1], false)
	end
	Widget:SetEnabledNormalRender(self.ItemIndexList[TailItemIndex], false)
end

function UIAdapterTableView:ResetDelayDisplayEffect()
	--FLOG_INFO("UIAdapterTableView:ResetDelayDisplayEffect")
	self.ItemRealDelayDisplayTime = self.TableDelayDisplayTime

	--计时器逻辑(暂不需要)
	-- for Index = 1, #self.Timers do
	-- 	local ItemView = self.ItemViewList[Index]
	-- 	if nil ~= ItemView and nil ~= ItemView.Object and ItemView.Object:IsValid() then
	-- 		UIUtil.SetRenderOpacity(ItemView, 1.0)
	-- 	end
	-- 	_G.TimerMgr:CancelTimer(self.Timers[Index])
	-- 	self.Timers[Index] = nil
	-- end
end

function UIAdapterTableView:CancelAllItemDelayDisplayTimers()
	for Index = 1, #self.Timers do
		_G.TimerMgr:CancelTimer(self.Timers[Index])
	end
	self.Timers = {}
end

---SetClearCacheOnHide @隐藏时是否清理缓存 一般是有多个页签切换 隐藏页签时希望清理缓存 减少内存占用时设置为true
---@param bClearCacheOnHide boolean
function UIAdapterTableView:SetClearCacheOnHide(bClearCacheOnHide)
	self.bClearCacheOnHide = bClearCacheOnHide
end

---SetClearCacheOnUnload @调用UIViewMgr:HideView时是否清理缓存 一般是关闭界面 希望清理TableView缓存时设置为true
---bClearCacheOnHide为true时不用设置 隐藏时已经清理了
---bForceGC为true的界面不用设置 关闭界面会释所有资源
---@param bClearCacheOnUnload boolean
function UIAdapterTableView:SetClearCacheOnUnload(bClearCacheOnUnload)
	self.bClearCacheOnUnload = bClearCacheOnUnload
end

---SetEntryHeight
---@param NewHeight number @the height of every tile entry
function UIAdapterTableView:SetEntryHeight(NewHeight)
	self.Widget:SetEntryHeight(NewHeight)
end

---SetEntryWidth
---@param NewWidth number @the width of every tile entry
function UIAdapterTableView:SetEntryWidth(NewWidth)
	self.Widget:SetEntryWidth(NewWidth)
end

return UIAdapterTableView