--
-- Author: anypkvcai
-- Date: 2022-07-06 11:21
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local FLOG_INFO = _G.FLOG_INFO

---@class UIAdapterTreeView : UIAdapterTableView
local UIAdapterTreeView = LuaClass(UIAdapterTableView, true)

---CreateAdapter
---@param View UIView
---@param Widget UTableView
---@param OnSelectChanged function
---@param AlwaysNotifySelectChanged boolean @AlwaysNotifySelectChanged为true时 点击同一个Item也会发送OnSelectChanged通知
---@param bAutoExpandAll boolean @更新数据是否自动展开, 也可以调试 ExpandAll 函数来展开
---@param bReverse boolean @点击已选中Item后是否取消选中
---@param bClearCache boolean @全量刷新的时候先将ActiveWidgets的缓存放到InactiveWidgets里面
---@return UIView
function UIAdapterTreeView.CreateAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bAutoExpandAll, bReverse, bClearCache)
	local Adapter = UIAdapterTreeView.New()
	Adapter:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse, bClearCache)
	Adapter:SetAutoExpandAll(bAutoExpandAll)
	return Adapter
end

---Ctor
function UIAdapterTreeView:Ctor()
	--print("UIAdapterTreeView:Ctor")
	self.OnExpansionChanged = nil
	self.KeyToBeSelected = nil --树形控件子节点是异步加载的，所有先临时记录下，在创建时在处理回调
	self.bAutoExpandAll = true
end

---OnDestroy
---@private
function UIAdapterTreeView:OnDestroy()
	--print("UIAdapterTreeView:OnDestroy")
	self.OnExpansionChanged = nil

	local Widget = self.Widget
	if nil ~= Widget then
		Widget.BP_OnGetIsCanExpand:Unbind()
		Widget.BP_OnGetItemChildren:Unbind()
		Widget.BP_OnItemExpansionChanged:Clear()
	end

	self.Super:OnDestroy()
end

---InitAdapter
---@param View UIView
---@param Widget UTableView
---@param OnSelectChanged function
function UIAdapterTreeView:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse, bClearCache)
	self.Super:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged, bReverse, bClearCache)

	local function OnGetIsCanExpand(_, Item)
		return self:OnTreeItemGetIsCanExpand(Item)
	end

	Widget.BP_OnGetIsCanExpand:Bind(self.Object, OnGetIsCanExpand)

	local function OnGetItemChildren(_, Item)
		return self:OnTreeItemGetChildren(Item)
	end

	Widget.BP_OnGetItemChildren:Bind(self.Object, OnGetItemChildren)

	local function OnItemExpansionChanged(_, Item, IsExpanded)
		return self:OnTreeItemExpansionChanged(Item, IsExpanded)
	end

	Widget.BP_OnItemExpansionChanged:Add(View, OnItemExpansionChanged)
end

---@param AlwaysNotifySelectChanged boolean
function UIAdapterTreeView:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
	self.Super:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
end

function UIAdapterTreeView:UpdateChildren()
	self.Super:UpdateChildren()

	if self.bAutoExpandAll then
		self.Widget:ExpandAll()
	end
end

---OnTableItemShow
---@param ItemView UIView
---@private
function UIAdapterTreeView:OnTableItemShow(ItemView, Item)
	self.Super:OnTableItemShow(ItemView, Item)

	if Item == self.KeyToBeSelected then
		self.KeyToBeSelected = nil
		local ItemData = self:GetItemData(Item)
		self:HandleSelected(nil, Item, ItemData, ItemView)
	end
end

--- 是否可以展开树形控件子节点
---@param Item number
---@private
function UIAdapterTreeView:OnTreeItemGetIsCanExpand(Item)
	--FLOG_INFO("UIAdapterTreeView:OnTreeItemGetIsCanExpand Item=%d", Item)

	local ItemData = self:GetItemData(Item)
	if nil == ItemData then
		return true
	end

	local AdapterOnGetIsCanExpand = ItemData.AdapterOnGetIsCanExpand
	if nil == AdapterOnGetIsCanExpand then
		return true
	end

	return ItemData:AdapterOnGetIsCanExpand()
end

---GetItemDataChildren
---@param Item number
---@private
function UIAdapterTreeView:GetItemDataChildren(Item)
	local ItemData = self:GetItemData(Item)
	if nil == ItemData then
		return
	end

	local AdapterOnGetChildren = ItemData.AdapterOnGetChildren
	if nil == AdapterOnGetChildren then
		return
	end

	return ItemData:AdapterOnGetChildren()
end

---OnTreeItemGetChildren
---@param Item number
---@private
function UIAdapterTreeView:OnTreeItemGetChildren(Item)
	--FLOG_INFO("UIAdapterTreeView:OnTreeItemGetChildren Item=%d", Item)

	--UE.FProfileTag.StaticBegin("UIAdapterTreeView:OnTreeItemGetChildren1")

	local Children = self:GetItemDataChildren(Item)

	--UE.FProfileTag.StaticEnd()

	if nil == Children then
		return
	end

	local MapItemInfos = self.MapItemInfos
	local ItemInfo = MapItemInfos[Item]
	if nil == ItemInfo then
		return
	end

	--UE.FProfileTag.StaticBegin("UIAdapterTreeView:OnTreeItemGetChildren2")

	if nil == ItemInfo.ArrayItems then
		ItemInfo.ArrayItems = _G.UE.TArray(0)
	end

	local ArrayItems = ItemInfo.ArrayItems
	ArrayItems:Clear()

	for i = 1, #Children do
		local ItemData = Children[i]
		local IsVisible = not (nil ~= ItemData.AdapterOnGetIsVisible and not ItemData:AdapterOnGetIsVisible())
		if IsVisible then
			local Hash = self:GetHash(ItemData)
			ArrayItems:Add(Hash)
			MapItemInfos[Hash] = { ItemData = ItemData }
		end
	end

	--UE.FProfileTag.StaticEnd()

	return ArrayItems
end

---OnTreeItemExpansionChanged
---@param Item number
---@private
function UIAdapterTreeView:OnTreeItemExpansionChanged(Item, IsExpanded)
	local ItemData = self:GetItemData(Item)
	if nil == ItemData then
		return
	end

	local AdapterOnExpansionChanged = ItemData.AdapterOnExpansionChanged
	if nil == AdapterOnExpansionChanged then
		return
	end

	ItemData:AdapterOnExpansionChanged(IsExpanded)

	local OnExpansionChanged = self.OnExpansionChanged
	if nil ~= OnExpansionChanged then
		OnExpansionChanged(self.View, ItemData, IsExpanded)
	end
end

---SetOnExpansionChangedCallback
---@param Callback table
function UIAdapterTreeView:SetOnExpansionChangedCallback(Callback)
	self.OnExpansionChanged = Callback
end

---SetSelectedKey @列表中的对象 需要实现GetKey函数
---@param Key any
---@param IsExpandItem boolean @ 否展开
function UIAdapterTreeView:SetSelectedKey(Key, IsExpandItem)
	if nil == IsExpandItem then
		IsExpandItem = true
	end

	self.Widget:SetItemExpansion(Key, IsExpandItem)

	local ItemData = self:GetItemData(Key)
	local ItemView = self.Widget:BP_GetEntryWidgetFromItem(Key)
	if nil ~= ItemData and nil ~= ItemView then
		self.KeyToBeSelected = nil
		self:HandleSelected(nil, Key, ItemData, ItemView)
	else
		self.KeyToBeSelected = Key
	end
end

---SetIsExpansion  @列表中的对象 需要实现GetKey函数
---@param Key any
---@param IsExpandItem boolean @是否展开
function UIAdapterTreeView:SetIsExpansion(Key, IsExpandItem)
	return self.Widget:SetItemExpansion(Key, IsExpandItem)
end

---ExpandAll
function UIAdapterTreeView:ExpandAll()
	self.Widget:ExpandAll()
end

---CollapseAll
function UIAdapterTreeView:CollapseAll()
	self.Widget:CollapseAll()
end

---SetAutoExpandAll @默认自动展开
---@param bAutoExpandAll boolean
function UIAdapterTreeView:SetAutoExpandAll(bAutoExpandAll)
	if nil == bAutoExpandAll then
		bAutoExpandAll = true
	end
	self.bAutoExpandAll = bAutoExpandAll
end

return UIAdapterTreeView
