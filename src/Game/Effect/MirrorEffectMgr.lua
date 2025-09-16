local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local ObjectMgr = require("Object/ObjectMgr")

local MaxActorCount = 5
local CacheTime = 30 -- 缓存时间，单位：秒
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local MirrorEffectActorPath = "Class'/Game/BluePrint/Misc/BP_MirrorEffectActor.BP_MirrorEffectActor_C'"

---@class MirrorEffectMgr : MgrBase
local MirrorEffectMgr = LuaClass(MgrBase)

function MirrorEffectMgr:OnInit()
	self.MirrorEffectPool = {}
end

function MirrorEffectMgr:OnBegin()
end

function MirrorEffectMgr:OnEnd()
end

function MirrorEffectMgr:OnShutdown()
end

function MirrorEffectMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PWorldExit, self.OnWorldLeave)
end

function MirrorEffectMgr:OnWorldLeave()
	self:ClearEffects()
end

function MirrorEffectMgr:PlayEffect(EffectParam)
	if nil == EffectParam or nil == EffectParam.TrajCurves then
		return
	end

	for _, TrajCurvePath in pairs(EffectParam.TrajCurvePaths) do
		local Curve = ObjectMgr:LoadObjectSync(TrajCurvePath)
		if nil == Curve then
			FLOG_ERROR(string.format("Cannot find curve: %s", TrajCurvePath))
		else
			EffectParam.TrajCurves:Add(Curve)
		end
	end

	local OutEffectID = 0

	-- 从缓存池中取空闲镜像特效
	for EffectID, MirrorEffectDesc in ipairs(self.MirrorEffectPool) do
		local bIsFree = MirrorEffectDesc.bIsFree
		if bIsFree then
			OutEffectID = EffectID
			break
		end
	end

	-- 未在缓存池中找到空闲特效
	if OutEffectID == 0 then
		if #self.MirrorEffectPool == MaxActorCount then
			FLOG_WARNING("Cannot create mirror effect any more!")
			return 0
		else
			OutEffectID = #self.MirrorEffectPool + 1
		end
		self.MirrorEffectPool[OutEffectID] = {}
	end

	if nil == self.MirrorEffectPool[OutEffectID].Actor then
		self.MirrorEffectPool[OutEffectID].Actor = self:GenerateNewMirrorEffect(EffectParam)
	end

	if nil == self.MirrorEffectPool[OutEffectID].Actor then
		-- 创建MirrorEffectActor失败
		return OutEffectID
	end

	self.MirrorEffectPool[OutEffectID].bIsFree = false
	local EffectActor = self.MirrorEffectPool[OutEffectID].Actor
	EffectActor.Param = EffectParam
	EffectActor:Init()
	EffectActor:CaptureActor(EffectParam.Target, EffectParam.CameraComp)
	return OutEffectID
end

function MirrorEffectMgr:BreakEffect(EffectID)
	if nil == self.MirrorEffectPool[EffectID] or nil == self.MirrorEffectPool[EffectID].Actor then
		return
	end
	local Actor = self.MirrorEffectPool[EffectID].Actor
	if nil ~= Actor then
		Actor:UnInit()
	end
	self.MirrorEffectPool[EffectID].bIsFree = true
	self:RegisterTimer(function() self:DestroyEffect(EffectID) end, CacheTime)
end

function MirrorEffectMgr:GenerateNewMirrorEffect(EffectParam)
	if nil == EffectParam or nil == EffectParam.Target then
		FLOG_ERROR("Failed to create mirror effect actor. Please check params.")
		return
	end

	local ActorClass = ObjectMgr:LoadClassSync(MirrorEffectActorPath)
	local MirrorEffectActor = CommonUtil.SpawnActor(ActorClass, EffectParam.Target:K2_GetActorLocation(), EffectParam.Target:K2_GetActorRotation())
	return MirrorEffectActor
end

function MirrorEffectMgr:DestroyEffect(EffectID)
	if nil == self.MirrorEffectPool[EffectID] or not self.MirrorEffectPool[EffectID].bIsFree then
		return
	end

	if nil ~= self.MirrorEffectPool[EffectID].Actor then
		CommonUtil.DestroyActor(self.MirrorEffectPool[EffectID].Actor)
	end
	self.MirrorEffectPool[EffectID].Actor = nil
	self.MirrorEffectPool[EffectID].bIsFree = true
end

function MirrorEffectMgr:ClearEffects()
	for _, MirrorEffectDesc in ipairs(self.MirrorEffectPool) do
		CommonUtil.DestroyActor(MirrorEffectDesc.Actor)
	end
	self.MirrorEffectPool = {}
end

return MirrorEffectMgr
