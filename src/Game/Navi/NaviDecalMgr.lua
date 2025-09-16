local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local ActorMgr = require("Game/Actor/ActorMgr")
local MajorUtil = require("Utils/MajorUtil")
local EffectUtil = require("Utils/EffectUtil")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local ProtoRes = require("Protocol/ProtoRes")
local CommonDefine = require("Define/CommonDefine")
local SaveKey = require("Define/SaveKey")

local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local FLOG_WARNING = _G.FLOG_WARNING

local bNewVersion = CommonDefine.NaviDecal.bNewVersion
local EffLife = CommonDefine.NaviDecal.EffLife
local Speed = CommonDefine.NaviDecal.EffSpeed
local PointsArray = _G.UE.TArray(_G.UE.FVector)

local VfxEffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Sence/LeaderLine/VBP_LeaderLine.VBP_LeaderLine_C'"

-- 仅地面指引
-- 目前npc、area只能现定于是本地图的，跨图的是查不到的
---@class NaviDecalMgr : MgrBase
local NaviDecalMgr = LuaClass(MgrBase)

--以后有需求再处理，比如多种类型的优先级
NaviDecalMgr.EGuideType =
{
	Task = 1,			--任务
	BigMap = 2,			--地图
	MapWay = 3,			--副本内指引
}

NaviDecalMgr.EForceType =
{
	None = 0,
	TickForce = 100,	--Tick过程中强制寻路的情况
	OnceForce = 200,    --最高级别强制更新,忽略玩家是否移动,每次切换任务目标都强制执行一次
}

function NaviDecalMgr:OnInit()
	--记录最新的目标相关的数据；    如果连续请求多个，丢弃中间的回包
	self.FindPathSeqID = 0
	self.LastNoPathSeqID = 0
	self.LastFailedTime = 0

	self.TargetPos = _G.UE.FVector(0, 0, 0)
	--向后台寻路后，会更新为经过世界坐标原点处理过的坐标
	self.TargetPosByWorldOrigin = _G.UE.FVector(0, 0, 0)
	--寻路到TargetPosByWorldOrigin，服务器返回的经过世界坐标原点处理的路径点
	self.FindPathDisMin = CommonDefine.NaviDecal.FindPathDisMin
	self.ShowEffHeightLimit = CommonDefine.NaviDecal.ShowEffHeightLimit

	self.PointListRsp = {}
	self.CurPointIndex = 1

	self.GuideType = NaviDecalMgr.EGuideType.Task

	-- self.LastRecvFintPathNotifyTime = 0
	self.IsShowNaviPathing = false
	self.MajorMoving = false

	self.bDisableTick = false
	self.LastVfxDist = 0
	self.LastShowVfsTime = 0
	self.LastVfsTime = 0

	self.CurNaviType = NaviDecalMgr.EGuideType.Task
	self.TargetPosMap = {}
end

function NaviDecalMgr:OnBegin()
	--默认显示
	self.ConfigIsShowNaviPath = _G.UE.USaveMgr.GetInt(SaveKey.ShowNaviPath, 1, true)
	-- FLOG_INFO("NaviDecal OnBegin ShowNaviPath:%d", self.ConfigIsShowNaviPath)

	self:StartTickTimer()
end

function NaviDecalMgr:OnEnd()
	-- FLOG_INFO("NaviDecal OnEnd")
	self:ClearTickTimer()
	self:ClearNaviBigMapAgainTimer()

	self:HideNaviPath()
	self:DestoryNaviPath()
end

function NaviDecalMgr:StartTickTimer()
	local TimerInterval = CommonDefine.NaviDecal.FindPathReqInterval
	if bNewVersion then
		TimerInterval = 1
	end

	self:ClearTickTimer()
	-- FLOG_INFO("NaviDecal StartTickTimer")
    self.TickTimerID = _G.TimerMgr:AddTimer(self, self.TickNaviPath, 0, TimerInterval, 0)
end

function NaviDecalMgr:ClearTickTimer()
	-- FLOG_INFO("NaviDecal ClearTickTimer")
	if self.TickTimerID then
		_G.TimerMgr:CancelTimer(self.TickTimerID)
		self.TickTimerID = nil
	end
end

function NaviDecalMgr:ClearNaviBigMapAgainTimer()
	-- FLOG_INFO("NaviDecal NaviBigMapAgainTimerID")
	if self.NaviBigMapAgainTimerID then
		_G.TimerMgr:CancelTimer(self.NaviBigMapAgainTimerID)
		self.NaviBigMapAgainTimerID = nil
	end
end

function NaviDecalMgr:DestoryNaviPath()
	-- FLOG_INFO("NaviDecal DestoryNaviPath")
	if bNewVersion then
		if self.PathVfxEffectID then
			EffectUtil.UnloadVfx(self.PathVfxEffectID)
			self.PathVfxEffectID = nil
		end
	else
		if (self.PortalLineActor ~= nil) then
			_G.CommonUtil.DestroyActor(self.PortalLineActor)
			self.PortalLineActor = nil
		end
	end
end

function NaviDecalMgr:OnShutdown()
end

function NaviDecalMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NAVMESH, 0, self.OnFindPathNotify)
end

function NaviDecalMgr:LoadVfx()
	if not self.PathVfxEffectID then
		local VfxParameter = _G.UE.FVfxParameter()
		local Major = MajorUtil.GetMajor()
		if not Major then
			FLOG_ERROR("NaviDecalMgr LoadVfx Major is nil")
			return true
		end

		VfxParameter.VfxRequireData.EffectPath = VfxEffectPath
		VfxParameter.VfxRequireData.bAlwaysSpawn = true
		VfxParameter.VfxRequireData.bPersistent = true
		VfxParameter.VfxRequireData.bDistanceCulling = true
		local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body--AttachPointType_Body
		local MajorTransform = Major:FGetActorTransform()
		local NeedTransform = _G.UE.FTransform()

		VfxParameter.OffsetTransform = NeedTransform
		VfxParameter.VfxRequireData.VfxTransform = MajorTransform
		VfxParameter:SetCaster(Major, 0, AttachPointType_Body, 0)

		VfxParameter.LODMethod = _G.UE.ParticleSystemLODMethod.PARTICLESYSTEMLODMETHOD_DirectSet
		VfxParameter.LODLevel = EffectUtil.GetMajorEffectLOD(_G.UE.ELODRuleType.QualityLevelLOD)
		VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_WorldMap

		self.PathVfxEffectID = EffectUtil.LoadVfx(VfxParameter)
		FLOG_INFO("Navi LoadVfx VfxEffectID:%d", self.PathVfxEffectID or 0)

		if not self.TickTimerID then
			self:StartTickTimer()
		end
	end
end

--切图过程中hide  pcw todo
function NaviDecalMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
    self:RegisterGameEvent(EventID.PWorldTransBegin, self.OnPWorldTransBegin)
	self:RegisterGameEvent(EventID.MountFlyStateChange, self.OnGameEventMountFlyStateChange)
end

-- function NaviDecalMgr:UnRegisterGameEvents()
--     self:UnRegisterGameEvent(EventID.ActorVelocityUpdate, self.ActorVelocityUpdate)
-- end

function NaviDecalMgr:OnGameEventExitWorld(Params)
	-- FLOG_INFO("NaviDecal OnGameEventExitWorld")
	self:ClearNaviBigMapAgainTimer()
	self:HideNaviPath()
	self:DestoryNaviPath()
end

function NaviDecalMgr:ActorVelocityUpdate(Params)
    local EntityID = Params.ULongParam1
    if EntityID == MajorUtil.GetMajorEntityID() then
		self.MajorMoving = true
    end
end

function NaviDecalMgr:OnPWorldTransBegin(IsOnlyChangeLocation)
	if not IsOnlyChangeLocation then
		-- FLOG_INFO("NaviDecal OnPWorldTransBegin TargetPos = nil")
		self.TargetPos = nil
	end
end

function NaviDecalMgr:ResetTargetPos()
	-- FLOG_INFO("NaviDecal ResetTargetPos TargetPos = nil")
	self.TargetPos = nil
end

-- function NaviDecalMgr:ShowNaviPath()
-- end
--------------------------- 对外的接口 begin  -------------------------------

function NaviDecalMgr:SetNaviType(NaviType)
	-- FLOG_INFO("NaviDecal SetNaviType:%s", tostring(NaviType))

	if NaviType ~= self.CurNaviType then
		self.bForceRefresh = true
	else
		self.bForceRefresh = false
	end

	self.CurNaviType = NaviType or NaviDecalMgr.EGuideType.Task
end

--留副本指引等使用，现在都是回到任务指引
function NaviDecalMgr:CancelNaviType(NaviType)
	if NaviType == nil then
		FLOG_ERROR("NaviDecalMgr:CancelNaviType NaviType is nil")
		return
	end

	FLOG_INFO("NaviDecal CancelNaviType:%s  Cur:%s", tostring(NaviType), tostring(self.CurNaviType))

	self.TargetPosMap[NaviType] = nil
	if NaviType ~= self.CurNaviType then
		return
	end
	
	local function DelaySwitchNaviType(TaskType)
		-- local TaskType = NaviDecalMgr.EGuideType.Task
		self.CurNaviType = TaskType
		self.bForceRefresh = true

		if NaviType ~= TaskType then
			local TargetPos = self.TargetPosMap[TaskType]
			if TargetPos and self.IsShowNaviPathing then
				self:NaviPathToPos(TargetPos, TaskType, NaviDecalMgr.EForceType.OnceForce)
			end
		end
	end

	self:HideNaviPath(NaviType, true)

	local TaskType = NaviDecalMgr.EGuideType.MapWay
	if self.TargetPosMap[TaskType] then
		DelaySwitchNaviType(TaskType)
		return 
	end

	TaskType = NaviDecalMgr.EGuideType.Task
	if self.TargetPosMap[TaskType] then
		DelaySwitchNaviType(TaskType)
		return 
	end

	TaskType = NaviDecalMgr.EGuideType.BigMap
	if self.TargetPosMap[TaskType] then
		DelaySwitchNaviType(TaskType)
		return 
	end
	--延迟一点时间再切换到任务，给之前的特效 消亡时间
	-- _G.TimerMgr:AddTimer(nil, DelaySwitchNaviType, 1, 1, 1)
end

--隐藏指引
-- GuideType:如果是nil，则强制隐藏指引线
--				不是nil，则看是不是当前类型的，不是当前类型的也不会隐藏
function NaviDecalMgr:HideNaviPath(GuideType, bIgnoreIsShowNaviPathing)
	FLOG_INFO("NaviDecal HideNaviPath %s, CurType:%s", tostring(GuideType), tostring(self.CurNaviType))
	if GuideType ~= nil and GuideType ~= self.CurNaviType then
		return
	end

	if not bIgnoreIsShowNaviPathing then
		self.IsShowNaviPathing = false
	end

	self.TargetPosByWorldOrigin = _G.UE.FVector(0, 0, 0)
	self.TargetPos = nil

	if bNewVersion then
		if self.PathVfxEffectID then
			EffectUtil.StopVfx(self.PathVfxEffectID)
		end
	else
		if self.PortalLineActor and _G.UE.UCommonUtil.IsObjectValid(self.PortalLineActor) then
			self.PortalLineActor:SetActorHiddenInGame(true)
		end
	end

	self.IsEventRegisted = false
	self:UnRegisterGameEvent(EventID.ActorVelocityUpdate, self.ActorVelocityUpdate)

	self.CurPointIndex = 1
	self.PointListRsp = {}
end

function NaviDecalMgr:OnGameEventMountFlyStateChange(Params)
    local EntityID = Params.ULongParam1
    local bFly = Params.BoolParam1
	if MajorUtil.IsMajor(EntityID) then
		if bFly then
			self:SetNavPathHiddenInGame(true)
		else
			self:SetNavPathHiddenInGame(false)
		end
		-- FLOG_INFO("NaviDecal bFly:%s", tostring(bFly))
	end
end

function NaviDecalMgr:SetNavPathHiddenInGame(IsHidden)
	-- FLOG_INFO("NaviDecal SetNavPathHiddenInGame:%s IsShowNaviPathing:%s"
	-- 	, tostring(IsHidden), tostring(self.IsShowNaviPathing))
	if not self.IsShowNaviPathing then
		return
	end

	if bNewVersion then
		if self.PathVfxEffectID then
			_G.UE.UFGameFXManager.Get():SetVisibility(self.PathVfxEffectID, not IsHidden)
		end
	else
		if self.PortalLineActor and _G.UE.UCommonUtil.IsObjectValid(self.PortalLineActor) then
			self.PortalLineActor:SetActorHiddenInGame(IsHidden)
		end
	end
end

--下面几个接口，如果满足条件是立即请求的，会及时刷新

--GuideType默认值nil， 当做是Task指引
--以后有需要再扩展处理
--TargetPos是没经过WorldOrigin处理的世界坐标
function NaviDecalMgr:NaviPathToPos(TargetPos, GuideType, ForceType)
	GuideType = GuideType or NaviDecalMgr.EGuideType.Task
	local Major = MajorUtil:GetMajor()
	if not Major then
		return -1
	end

	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)

	self.TargetPosMap[GuideType] = TargetPos
	if self:CanShowNaviPath(GuideType) == false then
		if GuideType == NaviDecalMgr.EGuideType.BigMap then
			self:ClearNaviBigMapAgainTimer()
			self.NaviBigMapAgainTimerID = _G.TimerMgr:AddTimer(self, self.DelayNaviBigMapAgain, 3, 1, 1)
		end

		return -1
	end

	self.TargetPos = TargetPos

	local FindPathSeqID = self:DoFindPath(MajorPos, TargetPos, GuideType, ForceType)

	self:SetFindPathDisMin(CommonDefine.NaviDecal.FindPathDisMin)
	-- FLOG_INFO("NaviDecal NaviPathToPos Seq:%d", self.FindPathSeqID)

	return FindPathSeqID
end

function NaviDecalMgr:DelayNaviBigMapAgain()
	self.NaviBigMapAgainTimerID = nil

	local TargetPos = self.TargetPosMap[NaviDecalMgr.EGuideType.BigMap]
	if TargetPos then
		if not self.TargetPosMap[NaviDecalMgr.EGuideType.Task] then
			FLOG_INFO("NaviDecal DelayNaviBigMapAgain")
			self:SetNaviType(NaviDecalMgr.EGuideType.BigMap)
			self:NaviPathToPos(TargetPos, NaviDecalMgr.EGuideType.BigMap)
		else
			FLOG_INFO("NaviDecal DelayNaviBigMapAgain None")
		end
	end
end

--区域的位置会是没经过WorldOrigin处理的世界坐标
function NaviDecalMgr:NaviPathToArea(AreaID, GuideType, ForceType)
	GuideType = GuideType or NaviDecalMgr.EGuideType.Task
	local Major = MajorUtil:GetMajor()
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)

	local MapArea = _G.MapEditDataMgr:GetArea(AreaID)
	if not MapArea then
		FLOG_ERROR("NaviDecal Area %d is not config", AreaID)
		return -1
	end

	local AreaLoc = _G.MapEditDataMgr:GetAreaPos(MapArea)
	if not AreaLoc then
		FLOG_ERROR("NaviDecal GetAreaPos error")
		return -1
	end

	self.TargetPosMap[GuideType] = AreaLoc
	if self:CanShowNaviPath(GuideType) == false then
		return -1
	end

	self.TargetPos = AreaLoc
	local FindPathSeqID = self:DoFindPath(MajorPos, AreaLoc, GuideType, ForceType)

	local SizeX, SizeY = _G.MapEditDataMgr:GetAreaSize(MapArea)
	local MinSize = SizeX < SizeY and SizeX or SizeY
	self:SetFindPathDisMin(MinSize)

	-- FLOG_INFO("NaviDecal NaviPathToArea Seq:%d", self.FindPathSeqID)
	return FindPathSeqID
end

--Npc的位置会是没经过WorldOrigin处理的世界坐标
function NaviDecalMgr:NaviPathToNpc(NpcID, GuideType, ForceType)
	GuideType = GuideType or NaviDecalMgr.EGuideType.Task
	local Major = MajorUtil:GetMajor()
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)

    local MapNpc = _G.MapEditDataMgr:GetNpc(NpcID)
    if MapNpc == nil then
		FLOG_ERROR("NaviDecal Npc %d is not config", NpcID)
		return -1
	end

    local BP = MapNpc.BirthPoint
    local NpcLoc = _G.UE.FVector(BP.X, BP.Y, BP.Z)
	self.TargetPosMap[GuideType] = NpcLoc
	if self:CanShowNaviPath(GuideType) == false then
		return -1
	end

	self.TargetPos = NpcLoc
	local FindPathSeqID = self:DoFindPath(MajorPos, NpcLoc, GuideType, ForceType)

	self:SetFindPathDisMin(CommonDefine.NaviDecal.FindPathDisMin)
	-- FLOG_INFO("NaviDecal NaviPathToNpc Seq:%d", self.FindPathSeqID)
	return FindPathSeqID
end

function NaviDecalMgr:NaviPathToNpcByEntityID(EntityID, GuideType, ForceType)
	GuideType = GuideType or NaviDecalMgr.EGuideType.Task
	local Major = MajorUtil:GetMajor()
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)

	local Npc = ActorUtil.GetActorByEntityID(EntityID)
    if Npc == nil then
		FLOG_ERROR("NaviDecal Npc Entity(%d) is not Exist", EntityID)
		return -1
	end

    local NpcLoc = Npc:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	self.TargetPosMap[GuideType] = NpcLoc
	if self:CanShowNaviPath(GuideType) == false then
		return -1
	end
	self.TargetPos = NpcLoc

	local FindPathSeqID = self:DoFindPath(MajorPos, NpcLoc, GuideType, ForceType)

	self:SetFindPathDisMin(CommonDefine.NaviDecal.FindPathDisMin)
	-- FLOG_INFO("NaviDecal NaviPathToNpcByEntityID Seq:%d", self.FindPathSeqID)
	return FindPathSeqID
end

--外部控制显示与否的开关，按roleid保存到本地
function NaviDecalMgr:ShowNaviPath(IsShow)
	if IsShow then
		IsShow = 1
	else
		IsShow = 0
	end

	self.ConfigIsShowNaviPath = IsShow
	_G.UE.USaveMgr.SetInt(SaveKey.ShowNaviPath, IsShow, true)
end
--------------------------- 对外的接口 end  -------------------------------

function NaviDecalMgr:DoFindPath(MajorPos, TargetPos, GuildType, ForceType)
	if self.bForceRefresh then
		self.bForceRefresh = false
		ForceType = NaviDecalMgr.EForceType.OnceForce
	end

	ForceType = ForceType or NaviDecalMgr.EForceType.None

	if not self.IsEventRegisted then
		self:RegisterGameEvent(EventID.ActorVelocityUpdate, self.ActorVelocityUpdate)
		self.IsEventRegisted = true
	end

	local WorldOriginLoc = _G.PWorldMgr:GetWorldOriginLocation()
	TargetPos = TargetPos - WorldOriginLoc
	local Dist = _G.UE.FVector.DistSquared2D(TargetPos, self.TargetPosByWorldOrigin)
	if not self.MajorMoving and Dist < 10 and ForceType ~= NaviDecalMgr.EForceType.OnceForce then
		return -1
	end

	--NaviDecalMgr的Tick时 才会强制寻路
	if ForceType ~= NaviDecalMgr.EForceType.TickForce and ForceType ~= NaviDecalMgr.EForceType.OnceForce and Dist < 10 then
		return -1
	end

	local HeightToTarget = math.abs(MajorPos.Z - TargetPos.Z)
	local Dist = MajorPos:Dist2D(TargetPos)
	if Dist < self.FindPathDisMin and HeightToTarget < self.ShowEffHeightLimit and ForceType ~= NaviDecalMgr.EForceType.OnceForce then
		self.TargetPosByWorldOrigin = TargetPos
		-- FLOG_INFO("NaviDecal DoFindPath dist:%f is too near", Dist)
		return -1
	end

	if self.LastNoPathSeqID and self.LastNoPathSeqID == self.FindPathSeqID then
		-- FLOG_INFO("NaviDecal Last DoFindPath Failed, svr no points")
		local CurTime = _G.TimeUtil.GetServerTimeMS()
		if CurTime - self.LastFailedTime < 5000 then
			return -1
		end
	end

	if ForceType == NaviDecalMgr.EForceType.OnceForce then
		self.LastShowVfsTime = 0
	end

	self.TargetPosByWorldOrigin = TargetPos

	-- self.LastRecvFintPathNotifyTime = _G.TimeUtil.GetLocalTimeMS()
	local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
	self.FindPathSeqID = UMoveSyncMgr:FindPath(MajorPos, TargetPos)

	-- FLOG_INFO("NaviDecal DoFindPath Seq:%d Type:%s  begin:%s => end:%s"
	-- 	, self.FindPathSeqID, tostring(GuildType), tostring(MajorPos), tostring(TargetPos))

	return self.FindPathSeqID
end

function NaviDecalMgr:SetFindPathDisMin(Dis)
	self.FindPathDisMin = Dis or CommonDefine.NaviDecal.FindPathDisMin
end

function NaviDecalMgr:CanShowNaviPath(GuideType)
	if self.CurNaviType ~= GuideType then
		FLOG_WARNING("NaviDecal %s is not CurNaviType(%s)", tostring(GuideType), tostring(self.CurNaviType))
		return false
	end

	local IsDisable = CommonDefine.NaviDecal.Disable
	if not IsDisable then
		if self.ConfigIsShowNaviPath == 1 then
			return true
		end
	end

	return false
end

function NaviDecalMgr:DisableTick(bDisable)
	self.bDisableTick = bDisable
end

--每隔一定时间去刷新path指引，站立的时候忽略
function NaviDecalMgr:TickNaviPath()
	if not self.IsShowNaviPathing or self.bDisableTick or not self.TargetPos then
		return
	end

	local Major = MajorUtil:GetMajor()
	if not Major then
		return
	end

	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local Dist = MajorPos:Dist2D(self.TargetPosByWorldOrigin)
	local HeightToTarget = math.abs(MajorPos.Z - self.TargetPosByWorldOrigin.Z)

	local bPlayEff = true
	if Dist < self.FindPathDisMin and HeightToTarget < self.ShowEffHeightLimit then
		bPlayEff = false
	end

	if self.MajorMoving == false then
		if bNewVersion and bPlayEff then
			self:ShowFindPath(PointsArray, true)
			return
		end

		return
	end

	if not bPlayEff then
		self:SafeSetActorHiddenInGame(true)
		return
	end

	self:SafeSetActorHiddenInGame(false)

	self.LastReqSvrPathTime = self.LastReqSvrPathTime or 0
	local CurTime = _G.TimeUtil.GetServerTimeMS()
	--判定是否要重新寻路
		--如果不需要，则客户端自己根据上次寻路的结果，重新生成路径点，刷新地面指引
		--如果需要，才去重新请求路径
	if self:CheckNeedFindPath() and CurTime - self.LastReqSvrPathTime > CommonDefine.NaviDecal.FindPathReqInterval then
		--每一种接口，最终都会是寻路到某个没经过世界远点偏移处理的世界坐标
		_G.NaviDecalMgr:NaviPathToPos(self.TargetPos, self.CurNaviType, NaviDecalMgr.EForceType.TickForce)
	elseif bNewVersion then
		self:ShowFindPath(PointsArray, true)
	end

	local InputVector = Major:GetInputVector()
	if InputVector:SizeSquared() < 100 then
		self.MajorMoving = false
	end
end

function NaviDecalMgr:CheckNeedFindPath()
	local Major = MajorUtil:GetMajor()
	local PointNum = #self.PointListRsp
	if not Major or not self.PointListRsp or PointNum < 2 then
		return true
	end

	if self.CurPointIndex > PointNum then
		return true
	end

	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc) or _G.UE.FVector(0, 0, 0)

	--从CurPointIndex往前一点开始，确定一个最近的点，重新确定CurPointIndex
	local BeginIdx = self.CurPointIndex - 2
	if BeginIdx <= 0 then
		BeginIdx = 1
	end

	local MinDist = 1999999999
	local NearestIndex = self.CurPointIndex
	for Idx = BeginIdx, PointNum do
		local Dist = _G.UE.FVector.Dist(MajorPos, self.PointListRsp[Idx])
		if Dist < MinDist then
			NearestIndex = Idx
			MinDist = Dist
		end
	end

	if NearestIndex < PointNum then
		local Vector1 = self.PointListRsp[NearestIndex] - MajorPos
		local Vector2 = self.PointListRsp[NearestIndex] - self.PointListRsp[NearestIndex + 1]
		local CosValue2D = Vector1:CosineAngle2D(Vector2)
		if CosValue2D > 0 then
			NearestIndex = NearestIndex + 1
			if NearestIndex > PointNum then
				NearestIndex = PointNum
			end
		end
	end

	local TraceZOffset = 30
	MajorPos.Z = MajorPos.Z + TraceZOffset

	local TraceBeginIdx = NearestIndex + 1
	if TraceBeginIdx > PointNum then
		TraceBeginIdx = PointNum
	end

	local TraceEndIdx = NearestIndex - 1
	if TraceEndIdx <= 0 then
		TraceEndIdx = 1
	end

	local Point = nil
	local OffsetVector = _G.UE.FVector(0, 0, TraceZOffset)
	local UPWorldMgr = _G.UE.UPWorldMgr:Get()
	local bHaveBlock = false
	for Idx = TraceBeginIdx, TraceEndIdx, -1 do
		Point = self.PointListRsp[Idx]
		if UPWorldMgr:IsCanArrivedBySphereSweepTrace(MajorPos, Point + OffsetVector, 10) then
			if bHaveBlock then
				local LastPoint = self.PointListRsp[Idx + 1]
				local Dir = Point - LastPoint
				local Distance = _G.UE.FVector.Dist(Point, LastPoint)
				_G.UE.FVector.Normalize(Dir)

				local ValidPoint = LastPoint
				for index = 1, 3 do
					ValidPoint = ValidPoint + Dir * Distance / 3
					if UPWorldMgr:IsCanArrivedBySphereSweepTrace(MajorPos, ValidPoint + OffsetVector, 10) then
						self:OnRefreshPath(MajorPos, Idx + 1, ValidPoint)
						return false
					end
				end
			end

			--最近的点是可以走过去的（前一个或者下一个）
			self:OnRefreshPath(MajorPos, Idx)
			return false
		end

		bHaveBlock = true
	end

	return true
end

function NaviDecalMgr:OnRefreshPath(MajorPos, PointIdx, InterpPos)
	self.CurPointIndex = PointIdx

	self:PreShowFindPath()

	-- FLOG_INFO("NaviDecal Client RefreshPath")

	if bNewVersion then
		if self.bIsLoading and not self.PathVfxEffectID then
			FLOG_WARNING("NaviDecal PathVfxEffect is loading, so return")
			return
		end
	else
		if self.bIsLoading and not self.PortalLineActor then
			FLOG_WARNING("NaviDecal BP_PortalMultiLine is loading, so return")
			return
		end
	end

	local PointList = {}
	MajorPos.Z = MajorPos.Z + CommonDefine.NaviDecal.HeightOffset
	table.insert(PointList, MajorPos)

	if InterpPos then
		table.insert(PointList, InterpPos)
	end

	for index = PointIdx, #self.PointListRsp do
		table.insert(PointList, self.PointListRsp[index])
	end

	self:ShowFindPath(PointList)
end

function NaviDecalMgr:ConvertFindPathRsp(FindPathRsp)
	self.PointListRsp = {}
	self.CurPointIndex = 1

	local WorldOriginLoc = _G.PWorldMgr:GetWorldOriginLocation()
	local PointNum = #FindPathRsp.NavPoints
	for index = 1, PointNum do
		local Pos = FindPathRsp.NavPoints[index].point_data
		local FVectorPos = _G.UE.FVector(Pos.X, Pos.Y, Pos.Z + CommonDefine.NaviDecal.HeightOffset) - WorldOriginLoc
		table.insert(self.PointListRsp, FVectorPos)

		-- local Dist = MajorPos:Dist2D(FVectorPos)
		-- if Dist > CommonDefine.NaviDecal.ShowEffMaxDis then
		-- 	FLOG_WARNING("NaviDecal points will not show  from index:%d", index)
		-- 	break
		-- end

		-- FLOG_INFO("NaviDecal index:%d  point:%s", index, tostring(FVectorPos))
	end
end

function NaviDecalMgr:PreShowFindPath()
	if bNewVersion then
		if self.PathVfxEffectID then
			-- EffectUtil.StopVfx(self.PathVfxEffectID)
			self.bIsLoading = false
		end

		if not self.IsShowNaviPathing and self.PathVfxEffectID then
			_G.UE.UFGameFXManager.Get():SetVisibility(self.PathVfxEffectID, true)
		end
	else
		if self.PortalLineActor and _G.UE.UCommonUtil.IsObjectValid(self.PortalLineActor) == false then
			FLOG_WARNING("self.PortalLineActor is released")
			self:DestoryNaviPath()
			self.bIsLoading = false
		end

		if not self.IsShowNaviPathing and self.PortalLineActor then
			self.PortalLineActor:SetActorHiddenInGame(false)
		end
	end

	self.IsShowNaviPathing = true
end

function NaviDecalMgr:ReNavi()
	if PointsArray then
		_G.UE.UFGameFXManager.Get():PlayGuideLine(self.PathVfxEffectID, Speed, PointsArray)
	end
end

function NaviDecalMgr:ShowFindPath(PointList, bArray)
	-- local WorldOriginLoc = _G.PWorldMgr:GetWorldOriginLocation()
	local Dist = self.LastVfxDist or 0
	if bArray then
		if not bNewVersion then
			return
		end
	else
		self.CurPathPointList = PointList
		Dist = 0

		PointsArray:Clear()
		local Cnt = #PointList
		for index = 1, Cnt do
			local Point = PointList[index]
			local CurDist = 10000
			if index < Cnt then
				CurDist = _G.UE.FVector.Dist(Point, PointList[index + 1])
				Dist = Dist + CurDist
				if Dist > CommonDefine.NaviDecal.ShowEffMaxDis then
					break
				end
			else -- last point
				local GroudPos, GroundValid = _G.PWorldMgr:GetGroudPosByLineTrace(Point, 1000)
				if GroundValid then
					GroudPos.Z = GroudPos.Z + CommonDefine.NaviDecal.HeightOffset
					Point = GroudPos
				end
			end

			if CurDist > 80 then
				PointsArray:Add(_G.UE.FVector(Point.X, Point.Y, Point.Z))
			end
		end

		self.LastVfxDist = Dist
	end

	if bNewVersion then
		if _G.TimeUtil.GetServerTimeMS() - self.LastShowVfsTime < self.LastVfsTime then
			return
		end

		self.LastShowVfsTime = _G.TimeUtil.GetServerTimeMS()
		self.LastVfsTime = (Dist * 1000) / CommonDefine.NaviDecal.EffSpeed + CommonDefine.NaviDecal.EffLife
		-- if self.LastVfsTime < CommonDefine.NaviDecal.EffLife then
		-- 	self.LastVfsTime = CommonDefine.NaviDecal.EffLife
		-- end

		-- FLOG_INFO("Navi Dist:%.2f VfsTime:%.2f bArray:%s", Dist, self.LastVfsTime, tostring(bArray))
	end

	self.bIsLoading = true
	local bPlayEff = true
	local Major = MajorUtil:GetMajor()
	if Major then
		local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
		local HeightToTarget = math.abs(MajorPos.Z - self.TargetPosByWorldOrigin.Z)
		if Dist < self.FindPathDisMin and HeightToTarget < self.ShowEffHeightLimit then
			bPlayEff = false
		end
	end

	local bHide = _G.UE.UFGameFXManager.Get():GetNeedSheildEff()
	if bHide then
		bPlayEff = false
	end

	if bNewVersion then
		local PathVfxEffectID = self.PathVfxEffectID
		if PathVfxEffectID then
			self.bIsLoading = false

			if _G.UE.UFGameFXManager.Get():GetVfxInstance(PathVfxEffectID) == nil then
				self:DestoryNaviPath()
				FLOG_INFO("[NaviDecalMgr] can't find vfx=%s, destroy and reload", tostring(PathVfxEffectID))
				return
			end

			if bPlayEff and not MajorUtil.IsMajorDead() then
				_G.UE.UFGameFXManager.Get():PlayGuideLine(PathVfxEffectID, Speed, PointsArray)
			end

			return
		end
	else
		if self.PortalLineActor then
			self.bIsLoading = false
			self.PortalLineActor:ClearMultiLinePoints()

			if (_G.CommonUtil.IsWithEditor()) then
				local ActorLabelName = string.format("NaviPath-%d", self.FindPathSeqID)
				self.PortalLineActor:SetActorLabel(ActorLabelName)
			end

			local GroudPos, GroundValid = _G.PWorldMgr:GetGroudPosByLineTrace(PointList[1], 1000)
			if not GroundValid then
				return
			end
			self.PortalLineActor:K2_SetActorLocation(GroudPos, false, nil, false)

			for index = 1, #PointList do
				self.PortalLineActor:AddMultiLinePoint(PointList[index])
			end

			self.PortalLineActor.DotDistance = CommonDefine.NaviDecal.MeshDist
			self.PortalLineActor.PlayerHeightOffsetForPortalLine = CommonDefine.NaviDecal.HeightOffset
			self.PortalLineActor.MaxDistance = CommonDefine.NaviDecal.ShowEffMaxDis
			self.PortalLineActor.DefaultWidth = CommonDefine.NaviDecal.DefaultWidth
			if self.PortalLineActor:ReCalculateLine() == 0 then
				-- self:NaviPathToPos(self.TargetPos, NaviDecalMgr.EGuideType.TickForce)
			end
			return
		end
	end

	if bNewVersion then
		local function LoadVfxEffCallback()
			self.bIsLoading = false
			local EffObj = _G.ObjectMgr:GetObject(VfxEffectPath)
			if (EffObj == nil) then
				return
			end

			self:LoadVfx()
			if bPlayEff and not MajorUtil.IsMajorDead() then
				_G.UE.UFGameFXManager.Get():PlayGuideLine(self.PathVfxEffectID, Speed, PointsArray)
			end
		end

		_G.ObjectMgr:LoadClassAsync(VfxEffectPath, LoadVfxEffCallback, _G.UE.EObjectGC.Cache_Map)
	else
		local PortalLineResPath = "Blueprint'/Game/Assets/Effect/BluePrint/PortalLine/BP_PortalMultiLine.BP_PortalMultiLine_C'"
		local function LoadModelCallback()
			self.bIsLoading = false
			local ModelClass = _G.ObjectMgr:GetClass(PortalLineResPath)
			if (ModelClass == nil) then
				return
			end

			local FirstPos = PointList[1]
			self.PortalLineActor = _G.CommonUtil.SpawnActor(ModelClass, FirstPos)
			if (self.PortalLineActor == nil) then
				return
			end

			for index = 1, #PointList do
				self.PortalLineActor:AddMultiLinePoint(self.PointListRsp[index])
			end

			if (_G.CommonUtil.IsWithEditor()) then
				local ActorLabelName = string.format("NaviPath-%d", self.FindPathSeqID)
				self.PortalLineActor:SetActorLabel(ActorLabelName)
				self.PortalLineActor:SetFolderPath("NaviPath")
			end

			local PortalLineMaterialResPath
				-- = "MaterialInstanceConstant'/Game/Assets/Effect/SenceModelInstance/MI_zhiyin_1.MI_zhiyin_1'"
				= "MaterialInstanceConstant'/Game/Assets/Effect/BluePrint/PortalLine/MI_PortalMultiLine.MI_PortalMultiLine'"
			--local PortalLineMaterialResPath = self.PortalLineActor:GetMIPath()
			local function LoadMaterialCallback()
				self.bIsLoading = false
				local MaterialObject = _G.ObjectMgr:GetObject(PortalLineMaterialResPath)
				if (MaterialObject == nil) then
					return
				end

				if not self.PortalLineActor or _G.UE.UCommonUtil.IsObjectValid(self.PortalLineActor) == false then
					FLOG_WARNING("self.PortalLineActor is nil or not valid")
					return
				end

				local MaterialInstance = MaterialObject:Cast(_G.UE.UMaterialInstance)
				if (MaterialInstance ~= nil) then
					self.PortalLineActor.MI_PortalLine = MaterialInstance
				end

				self.PortalLineActor.DotDistance = CommonDefine.NaviDecal.MeshDist
				self.PortalLineActor.MaxDistance = CommonDefine.NaviDecal.ShowEffMaxDis
				self.PortalLineActor.DefaultWidth = CommonDefine.NaviDecal.DefaultWidth
				if self.PortalLineActor:ReCalculateLine() == -2 then
					-- self:NaviPathToPos(self.TargetPos, NaviDecalMgr.EGuideType.TickForce)
				end
			end

			_G.ObjectMgr:LoadObjectAsync(PortalLineMaterialResPath, LoadMaterialCallback)
		end

		_G.ObjectMgr:LoadClassAsync(PortalLineResPath, LoadModelCallback)
	end
end

function NaviDecalMgr:OnFindPathNotify(MsgBody)
	local FindPathRsp = MsgBody
	if not FindPathRsp or self.FindPathSeqID ~= FindPathRsp.id then
		return
	end

	local PointNum = #FindPathRsp.NavPoints
	if PointNum <= 1 then
		self:HideNaviPath(self.CurNaviType)
		FLOG_WARNING("NaviDecal OnFindPathNotify Error Points Num:%d", PointNum)
		self.LastNoPathSeqID = FindPathRsp.id
		self.LastFailedTime = _G.TimeUtil.GetServerTimeMS()
		_G.EventMgr:SendEvent(EventID.FindPathFailed, self.FindPathSeqID)
		return
	end

	self.LastNoPathSeqID = 0

	self:PreShowFindPath()

	FLOG_INFO("NaviDecal OnFindPathNotify Seq:%d, pointNum:%d", FindPathRsp.id, PointNum)

	if bNewVersion then	--todo
		-- if self.bIsLoading and not self.PortalLineActor then
		-- 	FLOG_WARNING("NaviDecal BP_PortalMultiLine is loading, so return")
		-- 	return
		-- end
	else
		if self.bIsLoading and not self.PortalLineActor then
			FLOG_WARNING("NaviDecal BP_PortalMultiLine is loading, so return")
			return
		end
	end

	self:ConvertFindPathRsp(FindPathRsp)

	self:ShowFindPath(self.PointListRsp)
end

function NaviDecalMgr:SafeSetActorHiddenInGame(IsHidden)
	if bNewVersion then
		if self.PathVfxEffectID then
			_G.UE.UFGameFXManager.Get():SetVisibility(self.PathVfxEffectID, not IsHidden)
			-- if IsHidden then
			-- 	FLOG_WARNING("NaviDecal SafeSetActorHiddenInGame true")
			-- end
		end
	else
		local Actor = self.PortalLineActor
		if Actor and _G.UE.UCommonUtil.IsObjectValid(Actor) then
			Actor:SetActorHiddenInGame(IsHidden)
		end
	end
end

return NaviDecalMgr
