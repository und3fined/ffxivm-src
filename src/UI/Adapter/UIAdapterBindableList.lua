---
--- Author: anypkvcai
--- DateTime: 2021-08-11 15:43
--- Description: 列表类型 Adapter基类
---    主要实现了UMG列表类控件要显示BindableList数据的接口，并处理了BindableList相关回调
---


local LuaClass = require("Core/LuaClass")
local UIAdapterBase = require("UI/Adapter/UIAdapterBase")
local CommonUtil = require("Utils/CommonUtil")
local UIBindableList = require("UI/UIBindableList")

---@class UIAdapterBindableList: UIAdapterBase
local UIAdapterBindableList = LuaClass(UIAdapterBase, true)

function UIAdapterBindableList:Ctor()
	self.Num = 0
	self.BindableList = nil
	self.OnItemChanged = nil
	self.OnGetCanBeSelected = nil
end

---OnDestroy
function UIAdapterBindableList:OnDestroy()
	self:UnRegisterBindableListCallback()
	self.Num = 0
	self.BindableList = nil
	self.OnItemChanged = nil
	self.OnGetCanBeSelected = nil

	self.Super:OnDestroy()
end

---InitSubView
function UIAdapterBindableList:InitSubView()

end

-----ShowSubView
--function UIAdapterBindableList:ShowSubView()
--
--end

---GetItemDataByIndex
---@param Index number
---@return table
function UIAdapterBindableList:GetItemDataByIndex(Index)
	local BindableList = self.BindableList
	if nil == Index or nil == BindableList then
		return
	end

	return self.BindableList:Get(Index)
end

---UpdateAll
---@param DataList table | UIBindableList
---@param Num number
function UIAdapterBindableList:UpdateAll(DataList, Num)
	self:ClearChildren()

	self:UnRegisterBindableListCallback()

	self.Num = Num

	if not CommonUtil.IsA(DataList, UIBindableList) then
		local BindableList = UIBindableList.New()
		BindableList:Update(DataList)
		self.BindableList = BindableList
	else
		self.BindableList = DataList
	end

	self:RegisterBindableListCallback()

	self:UpdateChildren()
end

function UIAdapterBindableList:GetNum()
	return self.Num or (self.BindableList:Length() or 0)
end

---RegisterBindableListCallback
function UIAdapterBindableList:RegisterBindableListCallback()
	local BindableList = self.BindableList
	if nil == BindableList then
		return
	end

	BindableList:RegisterUpdateListCallback(self, self.BindableListUpdateListCallback)
	BindableList:RegisterAddItemsCallback(self, self.BindableListAddItemsCallback)
	BindableList:RegisterRemoveItemsCallback(self, self.BindableListRemoveItemsCallback)
end

---UnRegisterBindableListCallback
function UIAdapterBindableList:UnRegisterBindableListCallback()
	local BindableList = self.BindableList
	if nil == BindableList then
		return
	end

	BindableList:UnRegisterUpdateListCallback(self, self.BindableListUpdateListCallback)
	BindableList:UnRegisterAddItemsCallback(self, self.BindableListAddItemsCallback)
	BindableList:UnRegisterRemoveItemsCallback(self, self.BindableListRemoveItemsCallback)
end

---BindableListUpdateListCallback
function UIAdapterBindableList:BindableListUpdateListCallback()
	local Widget = self.Widget
	if nil ~= Widget and Widget:IsValid() then
		self:OnUpdateList()
	end
end

---BindableListAddItemsCallback
---@param Items any
function UIAdapterBindableList:BindableListAddItemsCallback(Items)
	local Widget = self.Widget
	if nil ~= Widget and Widget:IsValid() then
		self:OnAddItems(Items)
	end
end

---BindableListRemoveItemsCallback
---@param Items table
function UIAdapterBindableList:BindableListRemoveItemsCallback(Items)
	local Widget = self.Widget
	if nil ~= Widget and Widget:IsValid() then
		self:OnRemoveItems(Items)
	end
end

---ClearChildren
function UIAdapterBindableList:ClearChildren()

end

---UpdateChildren
function UIAdapterBindableList:UpdateChildren()

end

---OnUpdateList
function UIAdapterBindableList:OnUpdateList()
	self:ClearChildren()
	self:UpdateChildren()
	self:CallItemChangedCallback()
end

---OnAddItems @子类可重写 做一些优化处理 不用清除所有Children再全部更新
---@param Items any
function UIAdapterBindableList:OnAddItems(Items)
	self:ClearChildren()
	self:UpdateChildren()
	self:CallItemChangedCallback()
end

---OnRemoveItems @子类可重写 做一些优化处理 不用清除所有Children再全部更新
---@param Items any
function UIAdapterBindableList:OnRemoveItems(Items)
	self:ClearChildren()
	self:UpdateChildren()
	self:CallItemChangedCallback()
end

---SetItemChangedCallback
---@param Callback function
function UIAdapterBindableList:SetItemChangedCallback(Callback)
	self.OnItemChanged = Callback
end

function UIAdapterBindableList:CallItemChangedCallback()
	if nil ~= self.OnItemChanged then
		self.OnItemChanged(self.View)
	end
end

---SetGetCanBeSelectedCallback
---@param Callback function
function UIAdapterBindableList:SetCanBeSelectedCallback(Callback)
	self.OnGetCanBeSelected = Callback
end

---GetItemDataCanBeSelected @默认返回true 优先判断是否设置了OnGetCanBeSelected回调
---@private
function UIAdapterBindableList:GetItemDataCanBeSelected(ItemData, bByClick)
	local OnGetCanBeSelected = self.OnGetCanBeSelected

	if nil ~= OnGetCanBeSelected then
		return OnGetCanBeSelected(self.View, ItemData, bByClick)
	end

	if type(ItemData) ~= "table" then
		return true
	end

	local AdapterOnGetCanBeSelected = ItemData.AdapterOnGetCanBeSelected
	if nil ~= AdapterOnGetCanBeSelected then
		return ItemData:AdapterOnGetCanBeSelected(bByClick)
	end

	return true
end

return UIAdapterBindableList