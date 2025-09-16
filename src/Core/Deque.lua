--
-- Author: anypkvcai
-- Date: 2023-09-19 10:19
-- Description:
--

local Deque = {}

function Deque:New(...)
	local Object = { First = 0, Last = -1, Values = {} }
	setmetatable(Object, { __index = Deque })
	return Object
end

---GetFirst
---@return number
function Deque:GetFirst()
	return self.First
end

---GetLast
---@return number
function Deque:GetLast()
	return self.Last
end

---GetValue
---@return any
function Deque:GetValue(Index)
	return self.Values[Index]
end

---GetHead
---@return number
function Deque:GetHead()
	return self.Values[self.First]
end

---GetTail
---@return number
function Deque:GetTail()
	return self.Values[self.Last]
end

---AddHead @在队首插入新的元素
---@param Value any
function Deque:AddHead(Value)
	local First = self.First - 1
	self.First = First
	self.Values[First] = Value
end

---AddTail @在队尾插入新的元素
---@param Value any
function Deque:AddTail(Value)
	local Last = self.Last + 1
	self.Last = Last
	self.Values[Last] = Value
end

---RemoveHead @从队首删除元素
function Deque:RemoveHead()
	local First = self.First
	if First > self.Last then
		return
	end
	local Value = self.Values[First]
	self.Values[First] = nil
	self.First = First + 1
	if self:IsEmpty() then
		self.First = 0
		self.Last = -1
	end
	return Value
end

---RemoveTail @从队尾删除元素
function Deque:RemoveTail()
	local Last = self.Last
	if self.First > Last then
		return
	end
	local Value = self.Values[Last]
	self.Values[Last] = nil
	self.Last = Last - 1
	if self:IsEmpty() then
		self.First = 0
		self.Last = -1
	end
	return Value
end

---Num
function Deque:Num()
	return self.Last - self.First + 1
end

---IsEmpty
function Deque:IsEmpty()
	return self.Last - self.First + 1 <= 0
end

---Empty @清除所有元素
function Deque:Empty()
	self.First = 0
	self.Last = -1
	self.Values = {}
end

return Deque