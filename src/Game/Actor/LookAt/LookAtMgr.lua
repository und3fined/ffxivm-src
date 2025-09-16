--
-- Author: jamiyang
-- Date: 2025-01-14 16:10:17
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
--local CommonUtil = require("Utils/CommonUtil")
local EventID = require("Define/EventID")

local EActorType = _G.UE.EActorType
local ELookAtType = _G.UE.ELookAtType
local ELookAtTargetType = _G.UE.ELookAtTargetType
local LookAtParams = _G.UE.FLookAtParams()

---@class LookAtMgr : MgrBase
local LookAtMgr = LuaClass(MgrBase)

function LookAtMgr:OnInit()
	self.CachedLookAtParamsList = {}
	self.bInPhoto = false
end

function LookAtMgr:OnBegin()
end

function LookAtMgr:OnEnd()
end

function LookAtMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PhotoStart,            self.OnPhotoStart)
    self:RegisterGameEvent(EventID.PhotoEnd,              self.OnPhotoEnd)
    self:RegisterGameEvent(EventID.TargetChangeActor,     self.OnTargetChangeActor)
	self:RegisterGameEvent(EventID.SelectTarget,          self.OnManualSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget,        self.OnUnSelectTarget)
	self:RegisterGameEvent(EventID.MountCall,             self.OnMountCall)
	self:RegisterGameEvent(EventID.MountBack,             self.OnMountBack)
end

function LookAtMgr:OnPhotoStart()
	self.bInPhoto = true
	self:RecordLookAtParam()
end

function LookAtMgr:OnPhotoEnd()
	self.bInPhoto = false
	self:RecoverLookAtParam()
end

--function LookAtMgr:IsOnPhoto()
	--return self.bInPhoto
--end

-- 缓存玩家Lookat目标
function LookAtMgr:RecordLookAtParam()
	local VisionActorList = _G.UE.UActorManager:Get():GetAllActors()
	local ActorCnt = VisionActorList:Length()
    for i = 1, ActorCnt, 1 do
		local BaseCharacter = VisionActorList:Get(i)
		if BaseCharacter and BaseCharacter:GetActorType() == EActorType.Player then
            local AnimComp = BaseCharacter:GetAnimationComponent()
			local LookAtParam = AnimComp and AnimComp:GetLookAtParam() or nil
			local AttrCom = BaseCharacter:GetAttributeComponent()
			local CatserEntityID = AttrCom and AttrCom.EntityID or 0
			self.CachedLookAtParamsList[CatserEntityID] = LookAtParam
        end
	end
end

-- 恢复玩家Lookat目标
function LookAtMgr:RecoverLookAtParam()
	-- 主角单独重置
	local Major = MajorUtil.GetMajor()
	if Major and Major:GetAnimationComponent() then
		Major:GetAnimationComponent():SetLookAtType(ELookAtType.None)
	end
	if self.CachedLookAtParamsList ==nil or table.size(self.CachedLookAtParamsList) == 0 then return end
	for EntityID, LookAtParam in pairs(self.CachedLookAtParamsList) do
        local Character = ActorUtil.GetActorByEntityID(EntityID)
		if Character and Character:GetActorType() == EActorType.Player then
			local AnimComp = Character:GetAnimationComponent()
			if AnimComp then
				AnimComp:SetLookAtParam(LookAtParam)
			end
		end
    end
	self.CachedLookAtParamsList = {}
end

--玩家目标切换
function LookAtMgr:OnTargetChangeActor(Params)
	--local Params ={EntityID = EntityID, TargetID = TargetID}
	local OwnerCharacter = ActorUtil.GetActorByEntityID(Params.EntityID)
	if OwnerCharacter == nil or OwnerCharacter:GetActorType() ~= EActorType.Player or OwnerCharacter:GetIsSequenceing() then
		return
	end
	-- 切换目标后LookAt参数
	local TargetCharacter = ActorUtil.GetActorByEntityID(Params.TargetID)
	local LookAtParam = LookAtParams
	if Params.EntityID ~= Params.TargetID and TargetCharacter and
	   (TargetCharacter:GetActorType() == EActorType.Player or TargetCharacter:GetActorType() == EActorType.Major) then
		local bInRide = ActorUtil.IsInRide(Params.EntityID)
		LookAtParam.LookAtType = bInRide and ELookAtType.HeadAndEye or ELookAtType.ALL
		LookAtParam.Target.Type = ELookAtTargetType.Actor
		LookAtParam.Target.Target = TargetCharacter
	else
		LookAtParam.LookAtType = ELookAtType.None
	end

	if self.bInPhoto then
		--缓存其他玩家在拍照期间切换的目标，退出拍照时再执行
		self.CachedLookAtParamsList[Params.EntityID] = LookAtParam
	else
		local AnimComp = OwnerCharacter:GetAnimationComponent()
		if AnimComp then
			AnimComp:SetLookAtParam(LookAtParam)
		end
	end
end

-- 主角目标选择
function LookAtMgr:OnManualSelectTarget(Params)
	if self.bInPhoto then
		-- 拍照系统
		-- 测试拍照LookAt，实际执行在拍照上层逻辑设置参数
		-- local TargetID = Params.ULongParam1
		-- local TargetCharacter = ActorUtil.GetActorByEntityID(TargetID)
		-- if TargetCharacter ~= nil and (TargetCharacter:GetActorType() == EActorType.Player or TargetCharacter:GetActorType() == EActorType.Major) then
		-- 	ActorUtil.SetCharacterLookAtCamera(TargetCharacter, _G.UE.ELookAtType.ALL)
		-- end
		return
	end
	local Major = MajorUtil.GetMajor()
	if Major == nil or Major:GetIsSequenceing() then
		return
	end
	local MajorID = MajorUtil.GetMajorEntityID()
	local TargetID = Params.ULongParam1
	local TargetCharacter = ActorUtil.GetActorByEntityID(TargetID)
	local LookAtParam = LookAtParams
	if MajorID ~= TargetID and TargetCharacter and
		TargetCharacter:GetActorType() ~= EActorType.EObj and TargetCharacter:GetActorType() ~= EActorType.Gather then
		local bInRide = ActorUtil.IsInRide(MajorID)
		LookAtParam.LookAtType = bInRide and ELookAtType.HeadAndEye or ELookAtType.ALL
		LookAtParam.Target.Type = ELookAtTargetType.Actor
		LookAtParam.Target.Target = TargetCharacter
	else
		LookAtParam.LookAtType = ELookAtType.None
		LookAtParam.Target.Type = ELookAtTargetType.None
	end
	local AnimComp = Major:GetAnimationComponent()
	if AnimComp then
		AnimComp:SetLookAtParam(LookAtParam)
	end
end

function LookAtMgr:OnUnSelectTarget()
	if self.bInPhoto then
		return
	end
	local Major = MajorUtil.GetMajor()
	if Major == nil or Major:GetIsSequenceing() then
		return
	end
	local LookAtParam = LookAtParams
	LookAtParam.LookAtType = ELookAtType.None
	LookAtParam.Target.Type = ELookAtTargetType.None
	local AnimComp = Major:GetAnimationComponent()
	if AnimComp then
		AnimComp:SetLookAtParam(LookAtParam)
	end
end

-- 坐骑状态下需要只转动头部
function LookAtMgr:OnMountCall(Params)
	local OwnerCharacter = ActorUtil.GetActorByEntityID(Params.EntityID)
	if OwnerCharacter == nil or OwnerCharacter:GetIsSequenceing() then
		return
	end
	local AnimComp = OwnerCharacter:GetAnimationComponent()
	if AnimComp then
		local CurLookAtParam = AnimComp:GetLookAtParam()
		if CurLookAtParam.LookAtType == ELookAtType.ALL then
			AnimComp:SetLookAtType(ELookAtType.HeadAndEye)
		end
	end
end
function LookAtMgr:OnMountBack(Params)
	local OwnerCharacter = ActorUtil.GetActorByEntityID(Params.EntityID)
	if OwnerCharacter == nil or OwnerCharacter:GetIsSequenceing() then
		return
	end
	local AnimComp = OwnerCharacter:GetAnimationComponent()
	if AnimComp then
		local CurLookAtParam = AnimComp:GetLookAtParam()
		if CurLookAtParam.LookAtType == ELookAtType.HeadAndEye then
			AnimComp:SetLookAtType(ELookAtType.ALL)
		end
	end
end
return LookAtMgr