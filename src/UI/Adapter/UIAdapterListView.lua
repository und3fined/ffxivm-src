--
-- Author: anypkvcai
-- Date: 2020-11-10 21:41:45
-- Description:
--

--[[

local LuaClass = require("Core/LuaClass")
local UIAdapterBase = require("UI/Adapter/UIAdapterBase")
local UIAdapterItemPool = require("UI/Adapter/UIAdapterItemPool")

local ListViewObject = "Class'/Game/UI/BP/Common/ListItemObject.ListItemObject_C'"

---@class UIAdapterListView : UIAdapterBase
local UIAdapterListView = LuaClass(UIAdapterBase)

---CreateAdapter
---@param View UIView
---@param Widget userdata           @UUserWidget
---@param OnSelectChanged function
---@return UIView
function UIAdapterListView.CreateAdapter(View, Widget, OnSelectChanged)
	local Adapter = UIAdapterListView.New()
	Adapter:InitAdapter(View, Widget, OnSelectChanged)
	return Adapter
end

function UIAdapterListView:Ctor()
	--print("UIAdapterListView:Ctor")
	self.ItemData = {}
	self.OnSelectChanged = nil
	self.SelectedIndex = nil
end

function UIAdapterListView:OnDestroy()
	--print("UIAdapterListView:OnDestroy")
	self:ClearAll()
end

---GetItemDataByIndex
---@param Index number
---@return table
function UIAdapterListView:GetItemDataByIndex(Index)
	return self.ItemData[Index]
end

---GetSelectedItem
---@return table
function UIAdapterListView:GetSelectedItem()
	local ItemData = self.ItemData[self.SelectedIndex]
	if nil == ItemData then
		return
	end

	return ItemData.Item
end

---InitAdapter
---@param View UIView
---@param Widget userdata           @UUserWidget
---@param OnSelectChanged function
function UIAdapterListView:InitAdapter(View, Widget, OnSelectChanged)
	self.Super:InitAdapter(View, Widget)

	self.OnSelectChanged = OnSelectChanged

	local function OnEntryGenerated(_, Entry)
		self:OnEntryGenerated(Entry)
	end

	local function OnEntryReleased(_, Entry)
		self:OnEntryReleased(Entry)
	end

	local function OnItemClicked(_, Item)
		self:OnItemClicked(Item)
	end

	local View = self.View
	local Widget = self.Widget

	Widget.BP_OnEntryGenerated:Add(View, OnEntryGenerated)
	Widget.BP_OnEntryReleased:Add(View, OnEntryReleased)
	Widget.BP_OnItemClicked:Add(View, OnItemClicked)
end

---OnEntryGenerated
---@param Entry userdata           @UObject 
function UIAdapterListView:OnEntryGenerated(Entry)
	--print("UIAdapterListView:OnEntryGenerated", Entry, Entry.Object, Entry.ItemIndex)

	local Index = Entry.ItemIndex

	local ItemData = self:GetItemDataByIndex(Index)
	if nil == ItemData then
		return
	end

	Entry:InitView()
	Entry:ShowView({ Index = Index, Data = ItemData.Data })

	if nil ~= Entry.OnSelectChanged then
		Entry:OnSelectChanged(Index == self.SelectedIndex)
	end
end

---OnEntryReleased
---@param Entry userdata            @UObject
function UIAdapterListView:OnEntryReleased(Entry)
	--print("UIAdapterListView:OnEntryReleased", Entry, Entry.Object, Entry.ItemIndex)
	Entry:HideView()
	Entry:DestroyView()
end

---OnItemClicked
---@param Item table
function UIAdapterListView:OnItemClicked(Entry)
	--print("UIAdapterListView:OnItemClicked")

	local Index = Entry.ItemIndex

	local ItemData = self:GetItemDataByIndex(Index)
	if nil == ItemData then
		return
	end

	local Entry = self.Widget:GetEntryWidget(ItemData.Item)
	if nil == Entry then
		return
	end

	if nil ~= Entry.OnItemClicked then
		Entry:OnItemClicked()
	end

	if Index == self.SelectedIndex then
		return
	end

	if nil ~= Entry.CanBeSelected then
		if Entry:CanBeSelected() then
			local SelectedEntry = self.Widget:GetEntryWidget(self:GetSelectedItem())
			if nil ~= SelectedEntry and nil ~= SelectedEntry.OnSelectChanged then
				SelectedEntry:OnSelectChanged(false)
			end

			self.SelectedIndex = Index

			if nil ~= Entry.OnSelectChanged then
				Entry:OnSelectChanged(true)
			end
		end
	end

	if nil ~= self.OnSelectChanged then
		self.OnSelectChanged(self.View, Index, ItemData.Data)
	end
end

---UpdateAll
---@param Data table
---@param Num number
function UIAdapterListView:UpdateAll(Data, Num)
	self:ClearAll()

	self.ItemData = {}

	Num = Num or #Data
	for i = 1, Num do
		-- for i,v in ipairs(Data) do
		local Item = UIAdapterItemPool:GetItem(ListViewObject)
		Item.ItemIndex = i
		self.Widget:AddItem(Item)

		table.insert(self.ItemData, { Item = Item, Data = Data[i] })
	end

	self.Widget:RegenerateAllEntries()

	-- local Entries = self.Widget:GetDisplayedEntryWidgets()
	-- local Length = Entries:Length()
	-- for i=1, Length do
	--     local Entry = Entries:Get(i)
	--     if nil ~= Entry then
	--         local Index = Entry.ItemIndex

	--         local ItemData = self:GetItemDataByIndex(Index)
	--         if nil == ItemData then return end

	--         Entry:UpdateView({Index = Index, Data = ItemData.Data})

	--         if nil ~= Entry.OnSelectChanged then
	--             Entry:OnSelectChanged(Index == self.SelectedIndex)
	--         end
	--     end
	-- end

end

-- function UIAdapterListView:UpdateData(Data)

-- end

---ClearAll
function UIAdapterListView:ClearAll()
	for _, v in ipairs(self.ItemData) do
		UIAdapterItemPool:FreeItem(v.Item)
	end

	self.ItemData = {}
	self.Widget:ClearListItems()
end

-- function UIAdapterListView:OnListItemObjectSet(Entry,ListItemObject)
--     local Index =  ListItemObject.ItemIndex
--     local ItemData = self.ItemData[Index]
--     if nil == ItemData then return end

--     Entry:UpdateData(ItemData.Data)
-- end

---NavigateToIndex
---@param Index number
function UIAdapterListView:NavigateToIndex(Index)
	local Widget = self.Widget

	Widget:SetScrollbarIsVisible(Index)
end

---ScrollToTop
function UIAdapterListView:ScrollToTop()
	local Widget = self.Widget

	Widget:ScrollToTop()
end

---ScrollToBottom
function UIAdapterListView:ScrollToBottom()
	local Widget = self.Widget

	Widget:ScrollToBottom()
end

---ScrollToIndex
---@param InScrollOffset number
function UIAdapterListView:ScrollToIndex(InScrollOffset)
	local Widget = self.Widget

	Widget:SetScrollOffset(InScrollOffset)
end

---SetScrollbarIsVisible
---@param InVisibility number           @ESlateVisibility
function UIAdapterListView:SetScrollbarIsVisible(InVisibility)
	local Widget = self.Widget

	Widget:SetScrollbarIsVisible(InVisibility)
end

return UIAdapterListView

--]]