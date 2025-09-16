---
--- Author: anypkvcai
--- DateTime: 2022-06-15 11:23
--- Description:
---


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ObjectPool = require("Game/ObjectPool/ObjectPool")
local CommonUtil = require("Utils/CommonUtil")
local EmptyTableMaker = require("Game/ObjectPool/EmptyTableMaker")

local FLOG_INFO
local FLOG_ERROR

---@class ObjectPoolMgr : MgrBase
local ObjectPoolMgr = LuaClass(MgrBase)

function ObjectPoolMgr:OnInit()
	self.ObjectPools = {}
end

function ObjectPoolMgr:OnBegin()
	FLOG_INFO = _G.FLOG_INFO
	FLOG_ERROR = _G.FLOG_ERROR

	self:PreLoadObjects()
end

function ObjectPoolMgr:OnEnd()

end

function ObjectPoolMgr:OnShutdown()
	self:ReleaseAll()
end

function ObjectPoolMgr:OnRegisterNetMsg()

end

function ObjectPoolMgr:OnRegisterGameEvent()

end

---AllocObject
---@param ObjectClass table @LuaClass对象
---@return table
function ObjectPoolMgr:AllocObject(ObjectClass)
	local Pool = self:GetObjectPool(ObjectClass)
	if nil == Pool then
		FLOG_ERROR("ObjectPoolMgr:AllocObject Error: Pool is nil")
		return
	end

	local Object = Pool:AllocObject()
	if nil == Object then
		return
	end

	--FLOG_INFO("ObjectPoolMgr:AllocObject FreeCount=%d UsedCount=%d", Pool:GetFreeCount(), Pool:GetUsedCount())

	return Object
end

---FreeObject
---@param ObjectClass table @LuaClass对象
---@param Object table
function ObjectPoolMgr:FreeObject(ObjectClass, Object)
	local ObjectPools = self.ObjectPools
	local Pool = ObjectPools[ObjectClass]
	if nil == Pool then
		--FLOG_ERROR("ObjectPoolMgr:FreeObject Error: Pool is nil")
		return
	end

	Pool:FreeObject(Object)

	--FLOG_INFO("ObjectPoolMgr:FreeObject FreeCount=%d UsedCount=%d", Pool:GetFreeCount(), Pool:GetUsedCount())
end

function ObjectPoolMgr:PreLoadObjects()
	FLOG_INFO("ObjectPoolMgr:PreLoadObjects")
	local ObjectPoolConfig = require("Define/ObjectPoolConfig")

	local _ <close> = CommonUtil.MakeProfileTag("ObjectPoolMgr:PreLoadObjects")

	for i = 1, #ObjectPoolConfig do
		local Config = ObjectPoolConfig[i]
		local Pool = self:GetObjectPool(Config.ObjectClass)
		if nil == Pool then
			FLOG_ERROR("ObjectPoolMgr:PreLoadObjects Error: Pool is nil")
		else
			Pool:PreLoadObject(Config.PreLoadNum)
		end
	end
end

function ObjectPoolMgr:AllocCommonTable()
	return self:AllocObject(EmptyTableMaker)
end

function ObjectPoolMgr:FreeCommonTable(Object)
	if Object then
		table.clear(Object)
		self:FreeObject(EmptyTableMaker, Object)
	end
end

---GetObjectPool
---@param ObjectClass table
---@private
function ObjectPoolMgr:GetObjectPool(ObjectClass)
	local ObjectPools = self.ObjectPools
	local Pool = ObjectPools[ObjectClass]
	if nil == Pool then
		local function Constructor()
			return ObjectClass.New()
		end

		Pool = ObjectPool.New(Constructor)

		ObjectPools[ObjectClass] = Pool
	end

	return Pool
end

function ObjectPoolMgr:ReleaseAll()
	local ObjectPools = self.ObjectPools
	for i = 1, #ObjectPools do
		local Pool = ObjectPools[i]
		Pool:ReleaseAll()
	end
end

function ObjectPoolMgr:ReleasePool(ObjectClass)
	local ObjectPools = self.ObjectPools
	local Pool = ObjectPools[ObjectClass]
	if nil == Pool then
		return
	end
	Pool:ReleaseAll()
end

function ObjectPoolMgr:DumpObjects(ObjectClass)
	local ObjectPools = self.ObjectPools
	local Pool = ObjectPools[ObjectClass]
	if nil == Pool then
		return
	end

	local FreeCount = Pool:GetFreeCount()
	local UsedCount = Pool:GetUsedCount()

	_G.FLOG_INFO(string.format("ObjectPoolMgr:DumpObject ObjectClass=%s FreeCount=%d UsedCount=%d", ObjectClass, FreeCount, UsedCount))
end

function ObjectPoolMgr:DumpAllObjects()
	_G.FLOG_INFO("ObjectPoolMgr:DumpAllObjects Begin----------------------------------------------------------------")

	local FreeCount = 0
	local UsedCount = 0
	for k, v in pairs(self.ObjectPools) do
		FreeCount = FreeCount + v:GetFreeCount()
		UsedCount = UsedCount + v:GetUsedCount()
		_G.FLOG_INFO(string.format("ObjectClass=%s FreeCount=%d UsedCount=%d", k, FreeCount, UsedCount))
	end

	_G.FLOG_INFO("ObjectPoolMgr:DumpAllObjects End ------------------------------------ActiveObjectNum=%d InactiveObject=%d", FreeCount, UsedCount)
end

return ObjectPoolMgr