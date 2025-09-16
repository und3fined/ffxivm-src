--
-- Author: anypkvcai
-- Date: 2024-07-19 21:09
-- Description:
--

-- 链表节点
---@class Node
local Node = {}

---New 创建节点
---@param Data table
function Node.New(Data)
	local Obj = { Data = Data, Next = nil }
	setmetatable(Obj, { __index = Node })
	return Obj
end

-- 链表类
---@class LinkedList
local LinkedList = {}

---New 创建链表
function LinkedList.New()
	local Obj = { Head = nil, Tail = nil, Num = 0 }
	setmetatable(Obj, { __index = LinkedList })
	return Obj
end

---GetHead
function LinkedList:GetHead()
	return self.Head
end

---GetNum
function LinkedList:GetNum()
	return self.Num
end

---AddHead 在链表头部添加元素
---@param Data table
function LinkedList:AddHead(Data)
	local NewNode = Node.New(Data)

	if self.Num == 0 then
		self.Head = NewNode
		self.Tail = NewNode
	else
		NewNode.Next = self.Head
		self.Head = NewNode
	end

	self.Num = self.Num + 1
end

---AddTail 在链表尾部添加元素
---@param Data table
function LinkedList:AddTail(Data)
	local NewNode = Node.New(Data)

	if not self.Head then
		self.Head = NewNode
		self.Tail = NewNode
	else
		self.Tail.Next = NewNode
		self.Tail = NewNode
	end

	self.Num = self.Num + 1
end

---Empty
function LinkedList:Empty()
	if nil == self.Head then
		return
	end

	local Current = self.Head
	while Current do
		local Next = Current.Next
		Current.Next = nil
		Current = Next
	end

	self.Head = nil
	self.Tail = nil
	self.Num = 0
end

---IsEmpty
function LinkedList:IsEmpty()
	return 0 == self.Num
end

---RemoveHead 从链表头部删除元素
function LinkedList:RemoveHead()
	if 0 == self.Num or nil == self.Head then
		return
	end

	local RemovedData = self.Head.Data
	if self.Head == self.Tail then
		self.Head = nil
		self.Tail = nil
	else
		self.Head = self.Head.Next
	end

	self.Num = self.Num - 1

	return RemovedData
end

---RemoveTail 从链表尾部删除元素
function LinkedList:RemoveTail()
	if 0 == self.Num or nil == self.Head then
		return
	end

	local RemovedData = self.Tail.Data
	if self.Head == self.Tail then
		self.Head = nil
		self.Tail = nil
	else
		local Current = self.Head
		while Current.Next ~= self.Tail do
			Current = Current.Next
		end
		self.Tail = Current
		self.Tail.Next = nil
	end

	self.Num = self.Num - 1

	return RemovedData
end

---Remove @从链表中删除指定元素
---@param Data any
function LinkedList:Remove(Data)
	if 0 == self.Num or nil == self.Head then
		return
	end

	if self.Head.Data == Data then
		return self:RemoveHead()
	end

	local Current = self.Head
	while Current.Next ~= nil do
		if Current.Next.Data == Data then
			Current.Next = Current.Next.Next
			if Current.Next == nil then
				self.Tail = Current
			end
			self.Num = self.Num - 1
			return Data
		end
		Current = Current.Next
	end
end

---RemoveByName @通过节点里的名字和值从链表删除指定元素
---@param Name string
---@param Value any
function LinkedList:RemoveByName(Name, Value)
	if 0 == self.Num or nil == self.Head then
		return
	end

	if self.Head.Data[Name] == Value then
		return self:RemoveHead()
	end

	local Current = self.Head
	while Current.Next ~= nil do
		local Data = Current.Next.Data
		if Data[Name] == Value then
			Current.Next = Current.Next.Next
			if Current.Next == nil then
				self.Tail = Current
			end

			self.Num = self.Num - 1

			return Data
		end
		Current = Current.Next
	end
end

---RemoveAll
---@param Callback function
function LinkedList:RemoveAll(Callback, ...)
	local Num = self.Num
	local CurrentNode = self.Head
	local PrevNode

	local RemovedData

	while CurrentNode do
		if Callback(CurrentNode.Data, ...) then
			if not RemovedData then
				RemovedData = {}
			end
			table.insert(RemovedData, CurrentNode.Data)

			if PrevNode then
				PrevNode.Next = CurrentNode.Next
			else
				self.Head = CurrentNode.Next
			end

			if CurrentNode == self.Tail then
				self.Tail = PrevNode
			end

			CurrentNode = CurrentNode.Next

			Num = Num - 1

		else
			PrevNode = CurrentNode
			CurrentNode = CurrentNode.Next
		end
	end

	self.Num = Num

	return RemovedData
end

---Update @更新链表中的节点数据
---@param OldData table
---@param NewData table
function LinkedList:Update(OldData, NewData)
	if nil == self.Head then
		return
	end

	local Current = self.Head
	while Current do
		if Current.Data == OldData then
			Current.Data = NewData
			return
		end
		Current = Current.Next
	end
end

---Find @从链表中查找指定元素
---@param Data any
function LinkedList:Find(Data)
	if nil == self.Head then
		return
	end

	local Current = self.Head
	while Current do
		if Current.Data == Data then
			return Data
		end

		Current = Current.Next
	end
end

---FindByName @从链表中查找指定元素
---@param Name string
---@param Value any
function LinkedList:FindByName(Name, Value)
	if nil == self.Head then
		return
	end

	local Current = self.Head
	while Current do
		if Current.Data[Name] == Value then
			return Current.Data
		end

		Current = Current.Next
	end
end

---Merge
---@param List LinkedList
---@param bEmpty boolean
function LinkedList:Merge(List, bEmpty)
	if nil == self.Head then
		self.Head = List.Head
		self.Tail = List.Tail
	elseif List.Head ~= nil then
		self.Tail.Next = List.Head
		self.Tail = List.Tail
	end

	self.Num = self:GetNum() + List:GetNum()

	if bEmpty then
		List.Head = nil
		List.Tail = nil
		List.Num = 0
	end
end

---Traverse
---@param Callback function
function LinkedList:Traverse(Callback, ...)
	if nil == self.Head then
		return
	end

	local Current = self.Head
	while Current do
		Callback(Current.Data, ...)
		Current = Current.Next
	end
end

---PrintAll 遍历链表并打印节点数据
function LinkedList:PrintAll()
	print("LinkedList Num=%d", self.Num)

	if nil == self.Head then
		return
	end

	local Current = self.Head
	while Current do
		if type(Current.Data) == "table" then
			print(table.tostring_block(Current.Data, 1))
		else
			print(Current.Data)
		end
		Current = Current.Next
	end
end

return LinkedList
