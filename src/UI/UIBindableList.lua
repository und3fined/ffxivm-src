---
--- Author: anypkvcai
--- DateTime: 2021-04-02 11:30
--- Description: 主要封装了一个LuaTable数据列表，数据缓存处理，以及数据更新后的回调，可以通过UIAdapterBindableList来更新UMG列表类型的控件
--- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=1024712591
---

--local LuaClass = require("Core/LuaClass")
local CommonUtil = require("Utils/CommonUtil")
local SlatePreTick = require("Game/Skill/SlatePreTick")

local FLOG_ERROR = _G.FLOG_ERROR
local XPCall = CommonUtil.XPCall

---@class UIBindableList
---如果需要通过AddByValue或UpdateByValues函数来添加ViewModel，需要在构造函数传递ViewModel类
---AddByValue和UpdateByValues的作用是简化ViewModel的创建
---@field Items UIViewModel[] | table
local UIBindableList = {}

function UIBindableList.New(...)
	local Object = {}
	local function GC()
		Object:FreeAllItems()
	end
	setmetatable(Object, { __index = UIBindableList, __gc = GC })
	Object:Ctor(...)
	return Object
end

---Ctor
---@param ViewModelClass nil | UIViewModel 传递ViewModelClass参数后，UIBindableList 如果是手动创建列表的对象 不要传递这个参数
---@param UpdateVMParams any @UpdateVM的参数
function UIBindableList:Ctor(ViewModelClass, UpdateVMParams)
	self.ViewModelClass = ViewModelClass
	self.UpdateVMParams = UpdateVMParams

	self.Items = {}

	self.bUpdateListDelay = false
	self.UpdateListCallback = {}

	self.bAddItemDelay = false
	self.AddItemsCallback = {}
	self.ItemsToBeAdded = {}

	self.bRemoveItemDelay = false
	self.RemoveItemsCallback = {}
	self.ItemsToBeRemoved = {}
end


---FreeAllItems 私有函数不要直接调用 一般情况是调用Clear
---@private
function UIBindableList:FreeAllItems(CurViewModels)
	local Items = self.Items
	if nil == Items or #Items <= 0 then
		return false
	end

	local ViewModelClass = self.ViewModelClass
	if nil ~= ViewModelClass then
		for i = 1, #Items do
			_G.ObjectPoolMgr:FreeObject(ViewModelClass, Items[i])
		end
	end

	self.Items = {}

	return true
end

---EmptyItems 一般情况是调用Clear, 如果确定ViewModelClass不为空且不放会缓存池 才调用这个函数
function UIBindableList:EmptyItems()
	self.Items = {}
end

---FreeItem
---@param ViewModel table
---@private
function UIBindableList:FreeItem(ViewModel)
	local ViewModelClass = self.ViewModelClass
	if nil == ViewModelClass then
		return
	end
	_G.ObjectPoolMgr:FreeObject(ViewModelClass, ViewModel)
end

---Add    @添加UIViewModel对象或任意值到Items
---@param Item UIViewModel | any
function UIBindableList:Add(Item)
	if nil == Item then
		return
	end

	--外部创建的Item ViewModel
	table.insert(self.Items, Item)

	self:OnAddItem(Item)
end

---Insert    @插入UIViewModel对象到指定位置
---@param Item UIViewModel | any
function UIBindableList:Insert(Item, Index)
	if nil == Item then
		return
	end

	--外部创建的Item ViewModel
	table.insert(self.Items, Index, Item)

	self:OnAddItem(Item)
end

function UIBindableList:InsertByValue(Value, Index)
	if nil == Value then
		return
	end

	local ViewModel = self:CreateViewModel(Value)
	if nil ~= ViewModel then
		ViewModel:UpdateByValue(Value, self.UpdateVMParams, false)
		self:Insert(ViewModel, Index)
	end

	return ViewModel
end

---AddRange  @添加UIViewModel对象或任意值到Items
function UIBindableList:AddRange(Items)
	if nil == Items or #Items == 0 then
		return
	end

	--外部创建的Item ViewModel
	for _, Item in ipairs(Items) do
		table.insert(self.Items, Item)
	end

	self:OnUpdateList()
end

---Remove
---@param Item UIViewModel | any
function UIBindableList:Remove(Item)
	local Items = self.Items
	for i = #Items, 1, -1 do
		if self.Items[i] == Item then
			self:FreeItem(Items[i])
			table.remove(Items, i)
			self:OnRemoveItem(Item)
			return
		end
	end
end

---RemoveAt
---@param Index number
function UIBindableList:RemoveAt(Index)
	local Items = self.Items
	if Index <= 0 or Index > #Items then
		return
	end

	self:FreeItem(Items[Index])
	local Item = table.remove(Items, Index)

	self:OnRemoveItem(Item)
end

---RemoveItems
---@param From number @待删除的起始索引
---@param To number @待删除的结束索引
---@param NotFreeItem boolean @不释放item
---@param RemoveItemCBFunc funciton
function UIBindableList:RemoveItems(From, To, NotFreeItem, RemoveItemCBFunc)
	if From > To then
		return
	end

	local Items = self.Items
	if From <= 0 or From > #Items then
		return
	end

	for i = #Items, 1, -1 do
		if i >= From and i <= To then
			local Item = table.remove(Items, i)
			if nil ~= Item then
				if RemoveItemCBFunc then
					RemoveItemCBFunc(Item)
				end

				if NotFreeItem ~= true then
					self:FreeItem(Item)
				end
			end
		end
	end

	self:OnUpdateList()
end

---RemoveByPredicate
---@param Predicate table
function UIBindableList:RemoveByPredicate(Predicate, NotFreeItem)
	local Items = self.Items
	for i = 1, #Items do
		local v = Items[i]
		if Predicate(v) then
			local Item = table.remove(Items, i)
			if NotFreeItem ~= true then
				self:FreeItem(Item)
			end
			self:OnRemoveItem(Item)
			return
		end
	end
end

---@param RemoveItemCBFunc funciton
function UIBindableList:RemoveItemsByPredicate(Predicate, NotFreeItem, RemoveItemCBFunc, bNotUpdate)
	local Items = self.Items

	for i = #Items, 1, -1 do
		if Predicate(Items[i]) then
			local Item = table.remove(Items, i)
			if nil ~= Item then
				if RemoveItemCBFunc then
					RemoveItemCBFunc(Item)
				end

				if NotFreeItem ~= true then
					self:FreeItem(Item)
				end
			end
		end
	end

	if bNotUpdate ~= true then
		self:OnUpdateList()
	end
end

---Sort
---@param Predicate function
function UIBindableList:Sort(Predicate)
	table.sort(self.Items, Predicate)

	self:OnUpdateList()
end

---Find
---@param Predicate function
---@return UIViewModel
function UIBindableList:Find(Predicate)
	local Items = self.Items
	for i = 1, #Items do
		local v = Items[i]
		if Predicate(v) then
			return v, i
		end
	end
end

---FindByKey
---@param key any
---@return UIViewModel
function UIBindableList:FindByKey(key)
	local Items = self.Items
	for i = 1, #Items do
		local v = Items[i]
		if v:GetKey() == key then
			return v, i
		end
	end
end

--- Find All
---@param Predicate function
---@return table
function UIBindableList:FindAll(Predicate)
	local Result = {}
	local Items = self.Items
	for i = 1, #Items do
		local v = Items[i]
		if Predicate(v) then
			Result[#Result + 1] = v
		end
	end
	return Result
end

---Clear
function UIBindableList:Clear()
	if self:FreeAllItems() then
		self:OnUpdateList()
	end
end

---Update
---@param Items table<UIViewModel | any>
---@param SortPredicate function
function UIBindableList:Update(Items, SortPredicate)
	self:FreeAllItems()

	if Items then
		self.Items = Items
	end

	if nil ~= SortPredicate then
		self:Sort(SortPredicate)
	end

	self:OnUpdateList()
end

---AddByValue
---创建一个self.ViewModelClass类的对象,并把Value作为参数调用UpdateVM(Value)
---构造函数要初始化UIViewModel类
---和手动调用ViewModel.New()创建对象，然后调用UIBindableList:Add实现的功能是一样的
---@param Value table
---@param bDelayUpdate boolean
function UIBindableList:AddByValue(Value, bDelayUpdate)
	local ViewModel = self:CreateViewModel(Value)
	if nil ~= ViewModel then
		ViewModel:UpdateByValue(Value, self.UpdateVMParams, bDelayUpdate)
		self:Add(ViewModel)
	end

	return ViewModel
end

---UpdateByValues 一般是初始化列表的时候调用，如果列表增、删、修改数据， 可以调用对应的接口，不要调用这个接口全量更新
---构造函数要初始化UIViewModel类
---@param Values table
---@param SortPredicate function @ VM里数据获取要访问元表，所以建议排序好了之后再调用UpdateByValues，如果排序时要用到UpdateVM创建的值时才用SortPredicate
---@param bDelayUpdate boolean @ 如果列表数据比较多或UpdateVM逻辑复杂性能不好时，可以选迟更新。因为有些情况在UpdateVM前就会访问VM的值，所以默认不延迟更新，如果这种情况要延迟更新，可以把提前要访问的数据更新放到OnValueChanged里，其他耗时的更新放到UpdateVM里
function UIBindableList:UpdateByValues(Values, SortPredicate, bDelayUpdate)
	local ViewModels = {}
	local Count = 1
	local CurViewModelsMap = {}

	do
		local _ <close> = CommonUtil.MakeProfileTag("UIBindableList:UpdateByValues_CreateViewModel")
		if nil ~= Values then
			for i = 1, #Values do
				local Value = Values[i]								
				local ViewModel = self:FindEqualVM(Value, ViewModels)			
				if nil == ViewModel then
					local _ <close> = CommonUtil.MakeProfileTag("UIBindableList:UpdateByValues_CreateModel_Sigle")
					ViewModel = self:CreateViewModel(Value)
				end

				if nil ~= ViewModel then
					local _ <close> = CommonUtil.MakeProfileTag("UIBindableList:UpdateByValues_UpdateValue")

					ViewModel:UpdateByValue(Value, self.UpdateVMParams, bDelayUpdate)
					ViewModels[Count] = ViewModel
					Count = Count + 1

					local KeyStr = tostring(ViewModel)
					if (CurViewModelsMap[KeyStr] == nil) then
						CurViewModelsMap[KeyStr] = true
					end
				end
			end
		end
	end

	local _ <close> = CommonUtil.MakeProfileTag("UIBindableList:UpdateByValues_UpdateList")

	self:FreeAllItems(CurViewModelsMap)

	self.Items = ViewModels

	if nil ~= SortPredicate then
		self:Sort(SortPredicate)
	end

	self:OnUpdateList()
end

---FindEqualVM：   这个函数找到后会删除掉
---@param Value any
---@private
function UIBindableList:FindEqualVM(Value, CurViewModels)
	if nil == Value then
		FLOG_ERROR("UIBindableList:FindEqualVM Value is nil")
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("UIBindableList:FindEqualVM()")

	local Items = self.Items
	for i = 1, #Items do
		local v = Items[i]

		local _ <close> = CommonUtil.MakeProfileTag("UIBindableList:FindEqualVM_IsEqualVM")

		if v:IsEqualVM(Value) then
			table.remove(Items, i)
			return v
		end
	end
end

---ContainEqualVM：   这个函数找到后不删除，只返回
---@param Value any
---@private
function UIBindableList:ContainEqualVM(Value)
	if nil == Value then
		FLOG_ERROR("UIBindableList:ContainEqualVM Value is nil")
		return
	end

	local Items = self.Items
	for i = 1, #Items do
		local v = Items[i]
		if v:IsEqualVM(Value) then
			return v
		end
	end
end

---CreateViewModel
---@param Value any
---@private
function UIBindableList:CreateViewModel(Value)
	if nil == Value then
		FLOG_ERROR("UIBindableList:CreateViewModel Value is nil")
		return
	end

	local ViewModelClass = self.ViewModelClass
	if nil == ViewModelClass then
		FLOG_ERROR("UIBindableList:CreateViewModel ViewModel is nil")
		return
	end

	return _G.ObjectPoolMgr:AllocObject(ViewModelClass)
end

---Get
---@param Index number
---@return UIViewModel | any
function UIBindableList:Get(Index)
	if nil == Index or Index <= 0 or Index > #self.Items then
		--FLOG_ERROR("UIBindableList:Get Index is invalid", Index)
		return
	end

	return self.Items[Index]
end

---Length
function UIBindableList:Length()
	return #self.Items
end

---GetItems
function UIBindableList:GetItems()
	return self.Items
end

---GetItemIndex
function UIBindableList:GetItemIndex(Item)
	local Items = self.Items
	for i = 1, #Items do
		if Items[i] == Item then
			return i
		end
	end
end

---GetItemIndexByPredicate
---@param Predicate table
function UIBindableList:GetItemIndexByPredicate(Predicate)
	local Items = self.Items
	for i = 1, #Items do
		if Predicate(Items[i]) then
			return i
		end
	end
end

---GetItemByPredicate
---@param Predicate table
function UIBindableList:GetItemByPredicate(Predicate)
	local Index = self:GetItemIndexByPredicate(Predicate)
	if nil ~= Index then
		return self.Items[Index]
	end
end

---RegisterCallback
---@param CallbackList table
---@param Listener table
---@param Callback function
function UIBindableList:RegisterCallback(CallbackList, Listener, Callback)
	table.insert(CallbackList, { Listener = Listener, Callback = Callback })
end

---UnRegisterCallback
---@param CallbackList table
---@param Listener table
---@param Callback function
function UIBindableList:UnRegisterCallback(CallbackList, Listener, Callback)
	for i = 1, #CallbackList do
		local v = CallbackList[i]
		if nil ~= v and v.Listener == Listener and v.Callback == Callback then
			table.remove(CallbackList, i)
			return
		end
	end
end

function UIBindableList:RegisterUpdateListCallback(Listener, Callback)
	self:RegisterCallback(self.UpdateListCallback, Listener, Callback)
end

function UIBindableList:UnRegisterUpdateListCallback(Listener, Callback)
	self:UnRegisterCallback(self.UpdateListCallback, Listener, Callback)
end

function UIBindableList:RegisterAddItemsCallback(Listener, Callback)
	self:RegisterCallback(self.AddItemsCallback, Listener, Callback)
end

function UIBindableList:UnRegisterAddItemsCallback(Listener, Callback)
	self:UnRegisterCallback(self.AddItemsCallback, Listener, Callback)
end

function UIBindableList:RegisterRemoveItemsCallback(Listener, Callback)
	self:RegisterCallback(self.RemoveItemsCallback, Listener, Callback)
end

function UIBindableList:UnRegisterRemoveItemsCallback(Listener, Callback)
	self:UnRegisterCallback(self.RemoveItemsCallback, Listener, Callback)
end

function UIBindableList:OnUpdateListDelay()
	--print("UIBindableList:OnUpdateListDelay")
	local _ <close> = CommonUtil.MakeProfileTag("UIBindableList:OnUpdateListDelay")
	self.bUpdateListDelay = false
	self:OnExecuteCallback(self.UpdateListCallback)
end

---OnUpdateList
---@private
function UIBindableList:OnUpdateList()
	if #self.UpdateListCallback <= 0 then
		return
	end

	if not self.bUpdateListDelay then
		self.bUpdateListDelay = true
		SlatePreTick.RegisterSlatePreTickSingle(self, self.OnUpdateListDelay)
	end
end

function UIBindableList:OnAddItemDelay()
	--print("UIBindableList:OnAddItemDelay")
	self.bAddItemDelay = false
	self:OnExecuteCallback(self.AddItemsCallback, self.ItemsToBeAdded)
	table.clear(self.ItemsToBeAdded)
end

function UIBindableList:OnAddItem(Item)
	if #self.AddItemsCallback <= 0 then
		return
	end

	table.insert(self.ItemsToBeAdded, Item)

	if not self.bAddItemDelay then
		self.bAddItemDelay = true
		SlatePreTick.RegisterSlatePreTickSingle(self, self.OnAddItemDelay)
	end
end

function UIBindableList:OnRemoveItemDelay()
	--print("UIBindableList:OnRemoveItemDelay")
	self.bRemoveItemDelay = false
	self:OnExecuteCallback(self.RemoveItemsCallback, self.ItemsToBeRemoved)
	table.clear(self.ItemsToBeRemoved)
end

function UIBindableList:OnRemoveItem(Item)
	if #self.RemoveItemsCallback <= 0 then
		return
	end

	table.insert(self.ItemsToBeRemoved, Item)

	if not self.bRemoveItemDelay then
		self.bRemoveItemDelay = true
		SlatePreTick.RegisterSlatePreTickSingle(self, self.OnRemoveItemDelay)
	end
end

function UIBindableList:OnExecuteCallback(CallbackList, Item)
	for i = 1, #CallbackList do
		local v = CallbackList[i]
		if nil ~= v and nil ~= v.Callback then
			XPCall(v.Listener, v.Callback, Item)
		end
	end
end

return UIBindableList