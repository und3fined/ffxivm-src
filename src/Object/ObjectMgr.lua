--
-- Author: anypkvcai
-- Date: 2020-08-18 20:52:23
-- Description: 对应C++ UObjectMgr
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local SlatePreTick = require("Game/Skill/SlatePreTick")

local EObjectGC = _G.UE.EObjectGC
local UObjectMgr = _G.UE.UObjectMgr

---@class ObjectMgr : MgrBase
local ObjectMgr = LuaClass(MgrBase)

function ObjectMgr:OnInit()
	self.bForcePurge = false
	self.bPendingUEGC = false
	self.bPendingLuaGC = false
end

function ObjectMgr:OnBegin()

end

function ObjectMgr:OnEnd()

end

function ObjectMgr:OnShutdown()

end

---PreLoadObject
---@param FullPath string           @PaperSprite'/Game/UI/Atlas/..' 资源本身类型为前缀，无后缀
---@param GCType number             @GCType
function ObjectMgr:PreLoadObject(FullPath, GCType)
	GCType = GCType or EObjectGC.Cache_LRU
	return UObjectMgr.PreLoadObject(FullPath, GCType)
end

---LoadObjectSync
---@param FullPath string           @PaperSprite'/Game/UI/Atlas/..' 资源本身类型为前缀，无后缀
---@param GCType number             @GCType
function ObjectMgr:LoadObjectSync(FullPath, GCType)
	GCType = GCType or EObjectGC.Cache_LRU
	return UObjectMgr.LoadObjectSync(FullPath, GCType)
end

---LoadClassSync
---@param FullPath string            @蓝图类Class'/Game/BluePrint/..XXBlueprint.XXBlueprint_C'，Class为前缀，_C为后缀
---@param GCType number              @GCType
function ObjectMgr:LoadClassSync(FullPath, GCType)
	GCType = GCType or EObjectGC.Cache_LRU
	return UObjectMgr.LoadClassSync(FullPath, GCType)
end

local ULuaDelegateProxy = _G.UE.ULuaDelegateProxy
local NewObject = _G.NewObject
local UnLuaRef = _G.UnLua.Ref

---GetCallbackDelegatePairs
function ObjectMgr:GetCallbackDelegatePairs(SuccessCallBack, FailedCallBack)
	local Proxy = NewObject(ULuaDelegateProxy)
	local Ref =  UnLuaRef(Proxy)

	local SuccessDelegatePair = {
		Proxy,
		function(...)
			if type(SuccessCallBack) == "function" then
				SuccessCallBack(...)
			end
			Ref = nil
		end
	}

	local FailedDelegatePair = {
		Proxy,
		function(...)
			if type(FailedCallBack) == "function" then
				FailedCallBack(...)
			end
			Ref = nil
		end
	}

	return SuccessDelegatePair, FailedDelegatePair
end

---LoadObjectAsync
---@param FullPath string            @PaperSprite'/Game/UI/Atlas/..' 资源本身类型为前缀，无后缀
---@param SuccessCallBack function
---@param FailedCallBack function
---@param GCType number              @GCType
function ObjectMgr:LoadObjectAsync(FullPath, SuccessCallBack, GCType, FailedCallBack)
	GCType = GCType or EObjectGC.Cache_LRU
	local SuccessDelegatePair, FailedDelegatePair = self:GetCallbackDelegatePairs(SuccessCallBack, FailedCallBack)
	return UObjectMgr.LoadObjectAsync(FullPath, SuccessDelegatePair, FailedDelegatePair, GCType)
end

---LoadClassAsync
---@param FullPath string           @蓝图类Class'/Game/BluePrint/..XXBlueprint.XXBlueprint_C'，Class为前缀，_C为后缀
---@param SuccessCallBack function
---@param FailedCallBack function
---@param GCType number             @GCType
function ObjectMgr:LoadClassAsync(FullPath, SuccessCallBack, GCType, FailedCallBack)
	GCType = GCType or EObjectGC.Cache_LRU
	local SuccessDelegatePair, FailedDelegatePair = self:GetCallbackDelegatePairs(SuccessCallBack, FailedCallBack)
	return UObjectMgr.LoadClassAsync(FullPath, SuccessDelegatePair, FailedDelegatePair, GCType)
end

--异步加载数组path
function ObjectMgr:LoadObjectsAsync(TArrayFullPath, SuccessCallBack, GCType, FailedCallBack)
	GCType = GCType or EObjectGC.Cache_LRU
	local SuccessDelegatePair, FailedDelegatePair = self:GetCallbackDelegatePairs(SuccessCallBack, FailedCallBack)
	return UObjectMgr.LoadObjectsAsync(TArrayFullPath, SuccessDelegatePair, FailedDelegatePair, GCType)
end

---UnLoadObject		目前没用到
---@param FullPath string           @PaperSprite'/Game/UI/Atlas/..' 资源本身类型为前缀，无后缀
---@param MarkDestroy boolean       @如果业务侧明确知道Object是在此处进行销毁，无它处引用则为true（下一次GC清掉），否则由UE4自动GC掉
function ObjectMgr:UnLoadObject(FullPath, MarkDestroy)
	MarkDestroy = MarkDestroy or false
	return UObjectMgr.UnLoadObject(FullPath, MarkDestroy)
end

---UnLoadClass
---@param FullPath string           @蓝图类Class'/Game/BluePrint/..XXBlueprint.XXBlueprint_C'，Class为前缀，_C为后缀
---@param MarkDestroy boolean       @如果业务侧明确知道Object是在此处进行销毁，无它处引用则为true（下一次GC清掉），否则由UE4自动GC掉
function ObjectMgr:UnLoadClass(FullPath, MarkDestroy)
	MarkDestroy = MarkDestroy or false
	return UObjectMgr.UnLoadClass(FullPath, MarkDestroy)
end

---UnloadAll
function ObjectMgr:UnloadAll(bForceUnloadAll, MarkDestroy)
	bForceUnloadAll = bForceUnloadAll or false
	MarkDestroy = MarkDestroy or false
	return UObjectMgr.UnloadAll(bForceUnloadAll, MarkDestroy)
end

function ObjectMgr:CancelLoad(HandleID)
	return UObjectMgr.CancelLoad(HandleID)
end

---GetObject
---@param FullPath string           @PaperSprite'/Game/UI/Atlas/..' 资源本身类型为前缀，无后缀
function ObjectMgr:GetObject(FullPath)
	return UObjectMgr.GetObject(FullPath)
end

---GetClass
---@param FullPath string           @蓝图类Class'/Game/BluePrint/..XXBlueprint.XXBlueprint_C'，Class为前缀，_C为后缀
function ObjectMgr:GetClass(FullPath)
	return UObjectMgr.GetClass(FullPath)
end

function ObjectMgr:ForceGarbageCollection(bForcePurge)
	return UObjectMgr.ForceGarbageCollection(bForcePurge)
end

function ObjectMgr:SetLruPoolMaxSize(MaxSize)
	UObjectMgr.SetLruPoolMaxSize(MaxSize)
end

function ObjectMgr:GetLruPoolMaxSize()
	return UObjectMgr.GetLruPoolMaxSize()
end

function ObjectMgr:IsResExist(ResPath)
	local ResSoftPath = _G.UE.FSoftObjectPath()
	ResSoftPath:SetPath(ResPath)
	return _G.UE.UCommonUtil.IsObjectExist(ResSoftPath)
end

---UECollectGarbage
---@private
function ObjectMgr.UECollectGarbage()
	--print("ObjectMgr.UECollectGarbage", ObjectMgr.bForcePurge)
	ObjectMgr.bPendingUEGC = false
	local _ <close> = CommonUtil.MakeProfileTag("ObjectMgr.UECollectGarbage")
	UObjectMgr.ForceGarbageCollection(ObjectMgr.bForcePurge)
	ObjectMgr.bForcePurge = false
end

---LuaCollectGarbage
---该函数会影响测试数据，修改前知会少波
---@private
function ObjectMgr.LuaCollectGarbage()
	--print("ObjectMgr.LuaCollectGarbage")
	ObjectMgr.bPendingLuaGC = false
	local _ <close> = CommonUtil.MakeProfileTag("ObjectMgr.LuaCollectGarbage")
	if CommonUtil.IsIOSPlatform() then
		collectgarbage("collect")
	else
		collectgarbage("incremental", 120)
	end
end

---CollectGarbage
---@param bForcePurge boolean
---@param bIOSOnly boolean
---@param bNoLuaGC boolean
function ObjectMgr:CollectGarbage(bForcePurge, bIOSOnly, bNoLuaGC)
	--print("ObjectMgr:CollectGarbage")
	if bIOSOnly and not CommonUtil.IsIOSPlatform() then
		return
	end

	do
		self.bForcePurge = bForcePurge or self.bForcePurge

		if not self.bPendingUEGC then
			self.bPendingUEGC = true
			SlatePreTick.RegisterSlatePreTickSingle(nil, ObjectMgr.UECollectGarbage)
		end
	end

	if not bNoLuaGC then
		if not self.bPendingLuaGC then
			self.bPendingLuaGC = true
			SlatePreTick.RegisterSlatePreTickSingle(nil, ObjectMgr.LuaCollectGarbage)
		end
	end
end

return ObjectMgr