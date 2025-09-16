--
-- Author: anypkvcai
-- Date: 2020-11-10 21:41:45
-- Description:
--



local LuaClass = require("Core/LuaClass")
local UIAdapterBindableList = require("UI/Adapter/UIAdapterBindableList")

---@class UIAdapterDynamicEntryBox : UIAdapterBindableList
local UIAdapterDynamicEntryBox = LuaClass(UIAdapterBindableList, true)

---CreateAdapter
---@param View UIView
---@param Widget UDynamicEntryBox
---@return UIView
function UIAdapterDynamicEntryBox.CreateAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged)
	local Adapter = UIAdapterDynamicEntryBox.New()
	Adapter:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged)
	return Adapter
end

---Ctor
---@field OnSelectChanged function    @点击、双击、调用SetSelectedIndex都会执行
---@field OnDoubleClicked function @双击会执行
---@field OnClicked function    @单击会执行
---@field SelectedIndex number    @选中的索引 有效范围：1~列表长度
function UIAdapterDynamicEntryBox:Ctor()
	self.OnSelectChanged = nil
	self.OnDoubleClicked = nil
	self.OnClicked = nil
	self.SelectedIndex = nil
end

function UIAdapterDynamicEntryBox:OnUnload()
	self:ClearChildren()
end

---DestroySubView
function UIAdapterDynamicEntryBox:DestroySubView(Params)
	local Widget = self.Widget
	if nil ~= Widget then
		Widget:Reset(false)
	end

	self.Super:DestroySubView(Params)
end

---InitAdapter
---@param View UIView
---@param Widget UDynamicEntryBox
function UIAdapterDynamicEntryBox:InitAdapter(View, Widget, OnSelectChanged, AlwaysNotifySelectChanged)
	self.Super:InitAdapter(View, Widget)

	self.OnSelectChanged = OnSelectChanged
	self.AlwaysNotifySelectChanged = AlwaysNotifySelectChanged
end

---ClearChildren
---@private
function UIAdapterDynamicEntryBox:ClearChildren()
	self.SelectedIndex = nil

	local Widget = self.Widget
	if nil ~= Widget then
		Widget:Reset(false)
	end

	local SubViews = self.SubViews
	if nil ~= SubViews then
		for i = 1, #SubViews do
			local v = SubViews[i]
			v:HideView()
			v:DestroyView()
		end
		self.SubViews = {}
	end
end

---UpdateChildren
---@private
function UIAdapterDynamicEntryBox:UpdateChildren()
	local Widget = self.Widget
	if nil == Widget then
		return
	end

	local Num = self.Num or self.BindableList:Length()
	for i = 1, Num do
		local ItemView = Widget:BP_CreateEntry()
		local ItemData = self:GetItemDataByIndex(i)

		self:AddSubView(ItemView)

		ItemView:InitView()
		ItemView:LoadView()
		ItemView:ShowView({ Index = i, Data = ItemData, Adapter = self })

		if nil ~= ItemView.OnSelectChanged then
			ItemView:OnSelectChanged(i == self.SelectedIndex)
		end
	end
end

---OnItemClicked
---@private
function UIAdapterDynamicEntryBox:OnItemClicked(ItemView, Index)
	local ItemData = self:GetItemDataByIndex(Index)

	self:HandleSelected(Index, ItemData, ItemView)

	if nil ~= self.OnClicked then
		self.OnClicked(self.View, Index, ItemData, ItemView)
	end

	if nil ~= ItemView.OnItemClicked then
		ItemView:OnItemClicked(Index, ItemData)
	end
end

---OnItemDoubleClicked
---@private
function UIAdapterDynamicEntryBox:OnItemDoubleClicked(ItemView, Index)
	local ItemData = self:GetItemDataByIndex(Index)

	self:HandleSelected(Index, ItemData, ItemView)

	if nil ~= self.OnDoubleClicked then
		self.OnDoubleClicked(self.View, Index, ItemData, ItemView)
	end

	if nil ~= ItemView.OnItemDoubleClicked then
		ItemView:OnItemDoubleClicked(Index, ItemData)
	end
end

---ClearSelectedIndex @只是设置选中索引为空
function UIAdapterDynamicEntryBox:ClearSelectedIndex()
	self.SelectedIndex = nil
end

---SetSelectedIndex
---@param Index number @从1开始
function UIAdapterDynamicEntryBox:SetSelectedIndex(Index)
	if nil == Index then
		return false
	end

	local ItemData = self:GetItemDataByIndex(Index)
	local ItemView = self.Widget:GetEntry(Index - 1)
	return self:HandleSelected(Index, ItemData, ItemView)
end

---CancelSelected
function UIAdapterDynamicEntryBox:CancelSelected()
	local Index = self.SelectedIndex
	if nil == Index then
		return
	end

	local ItemView = self.Widget:GetEntry(Index - 1)
	if nil ~= ItemView and nil ~= ItemView.OnSelectChanged then
		ItemView:OnSelectChanged(false)
	end
end

--- 根据条件选择选中的列表下标
---@param Predicate function @命中条件
---@return boolean @是否设置成功
function UIAdapterDynamicEntryBox:SetSelectedByPredicate(Predicate)
	local Index = self:GetItemIndexByPredicate(Predicate)
	if Index ~= nil then
		self:SetSelectedIndex(Index)
		return true
	end
	return false
end

--- 获取Item的对应Item的下标
---@param Predicate function @命中条件
function UIAdapterDynamicEntryBox:GetItemIndexByPredicate(Predicate)
	local Item = self.BindableList:Find(Predicate)
	if Item ~= nil then
		local Index = self.BindableList:GetItemIndex(Item)
		return Index
	end
end

---HandleSelected
---@param Index number
---@param ItemData table
---@param ItemView UIView
---@private
function UIAdapterDynamicEntryBox:HandleSelected(Index, ItemData, ItemView)
	if nil == ItemData then
		return false
	end

	local bCallback = false

	if Index ~= self.SelectedIndex then
		if self:GetItemDataCanBeSelected(ItemData) then
			self:CancelSelected()

			bCallback = true
		end
		self.SelectedIndex = Index
	else
		if self.AlwaysNotifySelectChanged then
			bCallback = true
		end
	end

	if bCallback then
		if nil ~= ItemView and nil ~= ItemView.OnSelectChanged then
			ItemView:OnSelectChanged(true)
		end

		if nil ~= self.OnSelectChanged then
			self.OnSelectChanged(self.View, Index, ItemData, ItemView)
		end
	end

	return true
end

---SetAlwaysNotifySelectChanged
---@param AlwaysNotifySelectChanged boolean
function UIAdapterDynamicEntryBox:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
	self.AlwaysNotifySelectChanged = AlwaysNotifySelectChanged
end

---SetOnSelectChangedCallback
---@param Callback function
function UIAdapterDynamicEntryBox:SetOnSelectChangedCallback(Callback)
	self.OnSelectChanged = Callback
end

---SetOnDoubleClickedCallback
---@param Callback function
function UIAdapterDynamicEntryBox:SetOnDoubleClickedCallback(Callback)
	self.OnDoubleClicked = Callback
end

---SetOnClickedCallback
---@param Callback function
function UIAdapterDynamicEntryBox:SetOnClickedCallback(Callback)
	self.OnClicked = Callback
end

return UIAdapterDynamicEntryBox