---
--- Author: anypkvcai
--- DateTime: 2021-09-14 11:15
--- Description: 对象缓存池
--- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=1861039916

---@class ObjectPool
--local ObjectPool = LuaClass()
local ObjectPool = {}

function ObjectPool.New(...)
	local Object = {}
	setmetatable(Object, { __index = ObjectPool })
	Object:Ctor(...)
	return Object
end

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING

---Ctor
---@param Constructor function
---@param Destructor function | nil
function ObjectPool:Ctor(Constructor, Destructor)
	self.Constructor = Constructor
	self.Destructor = Destructor
	self.FreeObjectList = {}
	self.FreeObjectHash = {}		--查询使用
	self.UsedObjectMap = {}
end


---AllocObject
function ObjectPool:AllocObject(Params)
	local _ <close> = CommonUtil.MakeProfileTag("ObjectPool:AllocObject()")

	local Object = self:AllocObjectInternal(Params)

	if nil ~= Object then
		self.UsedObjectMap[tostring(Object)] = Object
	else
		FLOG_ERROR("ObjectPool:AllocObject Error: Object is nil")
	end

	return Object
end

---PreLoad
function ObjectPool:PreLoadObject(Count)
	local FreeObjectList = self.FreeObjectList
	local Constructor = self.Constructor
	if nil == Constructor then
		FLOG_ERROR("ObjectPool:PreLoadObject Error：Constructor is nil")
		return
	end

	for _ = 1, Count do
		local Object = Constructor()
		if nil ~= Object then
			table.insert(FreeObjectList, Object)
			self.FreeObjectHash[tostring(Object)] = true
		else
			FLOG_ERROR("ObjectPool:PreLoadObject Error: Object is nil")
		end
	end
end

---FreeObject
---@param Object any
function ObjectPool:FreeObject(Object)
	if nil == Object then
		FLOG_ERROR("ObjectPool:FreeObject Error: Object is nil")
		return
	end

	local KeyStr = tostring(Object)

	local _ <close> = CommonUtil.MakeProfileTag(string.format("ObjectPool:FreeObject_Find"))
	if self.FreeObjectHash[KeyStr] ~= nil then
		FLOG_ERROR("ObjectPool:FreeObject Error")
		if not CommonUtil.IsShipping() then
			FLOG_WARNING("Free object = %s", rawget(Object, "ObjectName") or KeyStr)
			FLOG_WARNING(debug.traceback())
		end
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("ObjectPool:FreeObject_Remove"))
	if self.UsedObjectMap[KeyStr] ~= nil then
		self.UsedObjectMap[KeyStr] = nil

		local _ <close> = CommonUtil.MakeProfileTag(string.format("ObjectPool:FreeObject_Insert"))
		table.insert(self.FreeObjectList, Object)
		self.FreeObjectHash[KeyStr] = true

		self:FreeObjectInternal(Object)
	end
end

---ReleaseAll
function ObjectPool:ReleaseAll()
	for _, Value in pairs(self.UsedObjectMap) do
		self:FreeObjectInternal(Value)
	end

	self.FreeObjectList = {}
	self.UsedObjectMap = {}
	self.FreeObjectHash = {}
end

---FindObject
function ObjectPool:FindObject(Predicate)
	local FreeObjectList = self.FreeObjectList
	local Count = #FreeObjectList

	for i = 1, Count do
		local Object = FreeObjectList[i]
		if Predicate(Object) then
			return Object
		end
	end
end

---GetUsedCount
function ObjectPool:GetFreeCount()
	return #self.FreeObjectList
end

---@GetUsedCount 调试用
function ObjectPool:GetUsedCount()
	local Count = 0
	for _, Value in pairs(self.UsedObjectMap) do
		Count = Count + 1
	end

	return Count
end

---AllocObjectInternal
---@private
function ObjectPool:AllocObjectInternal(Params)
	local _ <close> = CommonUtil.MakeProfileTag("ObjectPool:AllocObjectInternal()")

	local FreeObjectList = self.FreeObjectList
	local Count = #FreeObjectList

	if Count > 0 then
		local _ <close> = CommonUtil.MakeProfileTag("ObjectPool:AllocObjectInternal_1")

		local Object = table.remove(FreeObjectList, Count)
		self.FreeObjectHash[tostring(Object)] = nil

		return Object
	else
		local _ <close> = CommonUtil.MakeProfileTag("ObjectPool:AllocObjectInternal_2")

		local Constructor = self.Constructor
		if nil ~= Constructor then
			return Constructor(Params)
		else
			FLOG_ERROR("ObjectPool:AllocObjectInternal Error：Constructor is nil")
		end
	end
end

---FreeObjectInternal
---@private
function ObjectPool:FreeObjectInternal(Object)
	local Destructor = self.Destructor
	if nil ~= Destructor then
		Destructor(Object)
	end
end

return ObjectPool