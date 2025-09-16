--
-- Author: sammrli
-- Date: 2024-02-26 10:57:14
-- Description:运输陆行鸟管理
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local EventID = require("Define/EventID")
local HUDType = require("Define/HUDType")
-- local ObjectGCType = require("Define/ObjectGCType")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require ("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")

local MathUtil = require("Utils/MathUtil")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local AudioUtil = require("Utils/AudioUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SkillUtil = require("Utils/SkillUtil")
local CommonUtil = require("Utils/CommonUtil")
local EffectUtil = require("Utils/EffectUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

local MapVM = require("Game/Map/VM/MapVM")
local MountVM = require("Game/Mount/VM/MountVM")
local MainPanelVM = require("Game/Main/MainPanelVM")

local RideCfg = require("TableCfg/RideCfg")
local MapUICfg = require("TableCfg/MapUICfg")
local ChocoboTransGraphCfg = require("TableCfg/ChocoboTransGraphCfg")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local ChocoboTransMountCfg = require("TableCfg/ChocoboTransMountCfg")

local ChocoboTransportDefine = require("Game/Chocobo/Transport/ChocoboTransportDefine")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ProtoRes = require("Protocol/ProtoRes")

local UE = _G.UE
local LSTR = _G.LSTR
local NpcMgr = _G.NpcMgr
local EventMgr = _G.EventMgr
local UIViewMgr = _G.UIViewMgr

local CS_CMD = ProtoCS.CS_CMD
local NavmeshPointType = ProtoCS.NavmeshPointType
local ChocoboTransferCmd = ProtoCS.ChocoboTransferCmd
local TransitionType = ProtoRes.transition_type
local CHOCOBO_FEE_QTE_RESULT = ChocoboDefine.CHOCOBO_FEE_QTE_RESULT
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

local CommStatID = ProtoCommon.CommStatID

local TimerMgr
local GameNetworkMgr

local TransportStatus =
{
    None = 1, --无运输
    ReadyPose = 2, --准备动作
    TurningCamera = 3, --旋转镜头
    Running = 4, --运输中
    RecoverCamera = 5, --恢复镜头
    EndingPose = 6, --播放结束动作
}

---@class ChocoboTransportMgr : MgrBase
---@field MapBookDict table<number, boolean>@<地图id, 是否已经登记>
---@field QueryDict table<number, boolean>@<地图id, 是否已经查询>
---@field FindPathListInMap table<number, table<number, table<UE.FVector>>>@寻路列表缓存<地图id,<npcid,<终点key, 路点list>>>
local ChocoboTransportMgr = LuaClass(MgrBase)

function ChocoboTransportMgr:OnInit()
    self.IsQuestNpcQueryEnable = false
    self.MapGapDict = {}  --地图隘口(数据不可修改)
end

function ChocoboTransportMgr:OnBegin()
    TimerMgr = _G.TimerMgr
    GameNetworkMgr = _G.GameNetworkMgr
    self.MapBookDict = {} --登记地图（不再登记npc）
    self.QueryDict = {} --记录已经查询过的地图
    self.QueryingDict = {} --正在查询
    self.FindPathListInMap = {}
    self.IsTransporting = false --正在运输
    self.IsCanUseSkill = false --可以使用技能
    self.CurrentNpcID = 0
    self.CurrentFindPath = nil
    self.SafeDistance = nil
    self.ProlongDistance = 3000 -- 延长目标点
    self.OnFindPathParams = {} -- {Caller = Caller , CallBack = CallBack }
    self.QuestTransData = {} -- 任务编辑器给到的数据(跨地图需要缓存)

    self.NpcTriggerList = {} --记录陆行鸟Npc Trigger
    self.FindPathSeqID = nil

    self.TransportStatus = TransportStatus.None
    self.CheckBlockTime = 0
    self.MajorLocationRecord = {}

    ChocoboTransportDefine:LoadCfg()
    self:InitMapGap()

    self.bTransOnLeaveWorld = false -- 记录离开地图时是否在运输
    self.bForceFly = false          -- Gm设置是否飞行
end

function ChocoboTransportMgr:OnEnd()
    self.MapBookDict = nil
    self.QueryDict = nil
    self.QueryingDict = nil
    self.FindPathListInMap = nil
    self.AnimTimerID = nil
    self.PlayEndTimerID = nil
    self.CurrentNpcID = 0
    self.SafeDistance = nil
    self.OnFindPathParams = {}
    self.QuestTransData = {}
    if self.IsTransporting then
        self:__ResetTransportStatus() --重置状态
        self.IsTransporting = false
    end
    self.bForceFly = false
    FLOG_INFO("ChocoboTransportMgr:OnEnd()")
end

function ChocoboTransportMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHOCOBO_TRANSFER, ChocoboTransferCmd.ChocoboTransferCmdQuery, self.OnNetMsgGetBookList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHOCOBO_TRANSFER, ChocoboTransferCmd.ChocoboTransferCmdBook, self.OnNetMsgGetBookResult)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHOCOBO_TRANSFER, ChocoboTransferCmd.ChocoboTransferCmdTransfer, self.OnNetMsgGetTransferResult)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NAVMESH, 0, self.OnNetMsgFindPath)
end

function ChocoboTransportMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventEnterExit)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.UpdateChocoboTransportPosition, self.OnGameEventUpdatePosition)
    self:RegisterGameEvent(EventID.ChocoboFeedingQteFinishNotify, self.OnChocoboFeedingQteFinishNotifyCallBack)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.UpdateBuff, self.OnCastBuff)
    self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnGameEventNetworkReconnected)
    self:RegisterGameEvent(EventID.AutoPathServerPull, self.OnGameEventAutoPathServerPull)
    self:RegisterGameEvent(EventID.MountFlyStateChange, self.OnMountFlyStateChange)
    self:RegisterGameEvent(EventID.MountFallStateChange, self.OnMountFallStateChange)
end

function ChocoboTransportMgr:OnMountFallStateChange(Params)
    local EntityID = Params.ULongParam1
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
  
    local IsFallEnd = not Params.BoolParam1
    if IsFallEnd and self.bCancelFlyFalling then
        self:OnInGround()
        self.bCancelFlyFalling = false
    end
end

function ChocoboTransportMgr:OnMountFlyStateChange(Params)
    local EntityID = Params.ULongParam1
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
   
	if not self.IsTransporting then
		return
	end

    local bFly = Params.BoolParam1
    if not bFly then
        self.bCancelFlyFalling = true
    end
end

function ChocoboTransportMgr:InitMapGap()
    local AllCfg = ChocoboTransGraphCfg:FindAllCfg()
    if AllCfg then
        for _, CfgItem in ipairs(AllCfg) do
            local MapID = CfgItem.MapID
            local DstMapList = self.MapGapDict[MapID]
            if not DstMapList then
                DstMapList = {}
                self.MapGapDict[MapID] = DstMapList
            end
            table.insert(DstMapList, CfgItem)--直接引用,注意不要修改数据
        end
    end
end

--- @type 陆行鸟Qte是否成功
function ChocoboTransportMgr:OnChocoboFeedingQteFinishNotifyCallBack(Params)
    if Params then
        self.QuestTransData.QTEGameResult = Params.GameResult
        FLOG_INFO("ChocoboTransportMgr ChoboFeedQte Finish Result = %s", Params.GameResult)
    end
end

--- @type 返回是否为飞行运输_false为跑路运输
function ChocoboTransportMgr:IsFlyMode()
    if not self:IsQuestTransport() then -- 只有任务陆行鸟有飞行
        return false
    end

    if self.bForceFly then  -- 这个变量GM设置
        return true
    end

    local QTEGameResult = self.QuestTransData.QTEGameResult
    if not QTEGameResult then -- 根据QTE结果判断
        return false
    end

    return QTEGameResult == CHOCOBO_FEE_QTE_RESULT.SUCCESS
end

---获取隘口配置数据
---@param MapID number 地图ID
---@param ResID number 资源ID
---@return ChocoboTransGraphCfg
function ChocoboTransportMgr:GetMapGapItem(MapID, ResID)
    local DstMapList = self.MapGapDict[MapID]
    if DstMapList then
        for _, Item in ipairs(DstMapList) do
            if Item.ActorResID == ResID then
                return Item
            end
        end
    end
    return nil
end

--[[
function ChocoboTransportMgr:GetNearbyPoint(X, Y, Z)
    --取寻路点的倒数第二个点
    if self.CurrentFindPath and #self.CurrentFindPath > 2 then
        local Index = #self.CurrentFindPath - 1
        local Point = self.CurrentFindPath[Index].point_data
        local DirX , DirY, DirZ = 0
        DirX, DirY, DirZ = MathUtil.Normalize(X - Point.X, Y - Point.Y, Z - Point.Z)
        return math.floor(X - DirX * NEAR_RANGE),
                math.floor(Y - DirY * NEAR_RANGE),
                math.floor(Z - DirZ * NEAR_RANGE)
    else
        --取玩家和终点的朝向
        local Major = MajorUtil.GetMajor()
        if Major then
            local Location = Major:FGetLocation(UE.EXLocationType.ServerLoc)
            local DirX , DirY, DirZ = 0
            DirX, DirY, DirZ = MathUtil.Normalize(X - Location.x, Y - Location.y, Z - Location.z)
            return math.floor(X - DirX * NEAR_RANGE),
                   math.floor(Y - DirY * NEAR_RANGE),
                   math.floor(Z - DirZ * NEAR_RANGE)
        end
    end
    return X, Y, Z
end
]]

function ChocoboTransportMgr:UpdateChocoboNpcHUD(MapID)
    local NpcIDList = {}
    local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapID(MapID)
    if MapEditCfg then
        for _, V in ipairs(MapEditCfg.NpcList) do
            local NpcID = V.NpcID
            if NpcMgr:IsChocoboNpcByNpcID(NpcID) then
                table.insert(NpcIDList, NpcID)
            end
        end
    end
    for i=1, #NpcIDList do
        local Actor = ActorUtil.GetActorByResID(NpcIDList[i])
        if Actor then
            local AttrComp = Actor:GetAttributeComponent()
            if AttrComp then
                local EntityID = AttrComp.EntityID
                local ActorVM = _G.HUDMgr:GetActorVM(EntityID)
                if ActorVM then
                    ActorVM:UpdateVM(EntityID, HUDType.NPCInfo)
                end
            end
        end
    end
end

-- ==================================================
-- 私有
-- ==================================================

function ChocoboTransportMgr:__OnMoveFinishCallback(IsSuccess, SeqID)
    FLOG_INFO("ChocoboTransportMgr:__OnMoveFinishCallback, IsSuccess = %s", IsSuccess)
    local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
    UMoveSyncMgr.OnSimulateMoveFinish:Clear()

    self.IsCanUseSkill = false

    if IsSuccess then --运输成功,陆行鸟离开前欢跃表现
        local TimelineID = self:GetRideStopAction()
        local LeaveAmimationDurtionTIme = 0
        if TimelineID > 0 then
            LeaveAmimationDurtionTIme = ChocoboTransportDefine.LEAVE_ANIMATION_DURTION_TIME
        end
        self.PlayEndTimerID = TimerMgr:AddTimer(self, self.OnPlayAnimationEnd, LeaveAmimationDurtionTIme)
        local function LatePlayAnimation()
            self.AnimTimerID = nil
            local Major = MajorUtil.GetMajor()
            if Major then
                local AnimComp = Major:GetAnimationComponent()
                if AnimComp then
                    local TimelineID = self:GetRideStopAction()
                    --坐骑
                    local PathCfg = ActiontimelinePathCfg:FindCfgByKey(TimelineID)
                    if PathCfg == nil then
                        FLOG_ERROR("ActiontimelinePathCfg = nil TimelineID = %s", TimelineID)
                        return
                    end
                    local ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
                    local ActionTimelines = {
                        [1] = {AnimPath = ActionTimelinePath, TargetAvatarPartType = UE.EAvatarPartType.RIDE_MASTER}
                    }
                    self.ATLID = _G.AnimMgr:PlayAnimationMulti(MajorUtil.GetMajorEntityID(), ActionTimelines)
                end
            end
        end

        --如果不是室内点阻断,修正朝向
        if not self.InRoom and self.CurrEndPos then
            local Point = self.CurrEndPos
            local Vector = UE.FVector(Point.x, Point.y, Point.z)
            local Major = MajorUtil.GetMajor()
            local Location = Major:FGetActorLocation()
            local LookAtRot = UE.UKismetMathLibrary.FindLookAtRotation(Location, Vector)
            Major:FSetRotationForServer(UE.FRotator(0, LookAtRot.Yaw, 0))
        end

        if TimelineID > 0 then
            self.AnimTimerID = TimerMgr:AddTimer(self, LatePlayAnimation, ChocoboTransportDefine.LATER_PLAY_ANIMATION)
        end

        EventMgr:SendEvent(EventID.ChocoboTransportArriving)

        -- 防止和地名提示重叠,如果地名提示则关闭
        if UIViewMgr:IsViewVisible(UIViewID.InfoAreaTips) then
            UIViewMgr:HideView(UIViewID.InfoAreaTips)
        end

        self.TransportStatus = TransportStatus.EndingPose
    else
        _G.InteractiveMgr:OnEntranceVisible(true)
        if self:IsFlyMode() then           -- 如果是飞行模式
            self:OnBreakFlyTransport()
        else
            self:OnBreakTransport()
        end
    end
end

---准备开始运输
function ChocoboTransportMgr:__PreStartPathMove()
    -- body
    if not self.CurrentFindPath or #self.CurrentFindPath < 2 then
        FLOG_ERROR("[ChocoboTransport] CurrentFindPath is invaild")
        return
    end
    local DelayStartTime = 0

    if self:IsFirstTransMap() then  -- 只有第一张地图需要播动作
        if self:GetRideStartAction() > 0 then
            DelayStartTime = ChocoboTransportDefine.START_ANIMATION_DURTION_TIME
            self:__PlayStartAnimation() -- 播放陆行鸟开始动作
        end
    end

    self.TryStartPathMoveNum = 0
    self.StartMoveTimerID = TimerMgr:AddTimer(self, self.__StartPathMove, DelayStartTime)

    self.TransportStatus = TransportStatus.ReadyPose

    table.clear(self.MajorLocationRecord)

    -- switch status display
    self:__SwitchTransportStatus(true)
end

---播放开始运输动画
function ChocoboTransportMgr:__PlayStartAnimation()
    self.PlayStartTimerID = nil
    local Major = MajorUtil.GetMajor()
    if Major then
        -- update ride status
        local RideComp = Major:GetRideComponent()
        if RideComp then
            if not RideComp:IsInRide() or RideComp:IsAssembling() then
                FLOG_WARNING("[ChocoboTransportMgr] ride not init or is assembling !")
                self.PlayStartTimerID = _G.TimerMgr:AddTimer(self, self.__PlayStartAnimation, 0.1)
                return
            else
                local AnimComp = Major:GetAnimationComponent()
                if AnimComp then
                    local TimelineID = self:GetRideStartAction()
                    local PathCfg = ActiontimelinePathCfg:FindCfgByKey(TimelineID)
                    if PathCfg == nil then
                        FLOG_ERROR("ChocoboTransportMgr ActiontimelinePathCfg = nil TimelineID = %s", TimelineID)
                        return
                    end
                    local ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
                    local ActionTimelines = {
                        [1] = {AnimPath = ActionTimelinePath, TargetAvatarPartType = UE.EAvatarPartType.RIDE_MASTER}
                    }
                    self.ATLID = _G.AnimMgr:PlayAnimationMulti(MajorUtil.GetMajorEntityID(), ActionTimelines)
                    FLOG_INFO("[ChocoboTransportMgr] ride PlayAnimationMulti! EntityID = %s ActionTimelinePath = %s ", MajorUtil.GetMajorEntityID(), ActionTimelines[1].AnimPath)
                end
            end
        end
    end
end

function ChocoboTransportMgr:__StopStartAnimation()
    if self.ATLID then
        --_G.AnimMgr:StopAnimationMulti(MajorUtil.GetMajorEntityID(), self.ATLID) --无效,先注释
        local Major = MajorUtil.GetMajor()
        if Major then
            local AnimComp = Major:GetAnimationComponent()
            if AnimComp then
                AnimComp:StopAnimation("", UE.EAvatarPartType.RIDE_MASTER)
            end
        end
        self.ATLID = nil
    end
end

---开始运输
function ChocoboTransportMgr:__StartPathMove()
    if self.PlayStartTimerID then
        _G.TimerMgr:CancelTimer(self.PlayStartTimerID)
        self.PlayStartTimerID = nil
    end

    -- check vaild status 如果没收到上坐骑包,视为失败
    local Major = MajorUtil.GetMajor()
    if Major then
        local RideComp = Major:GetRideComponent()
        if RideComp then
            if (not RideComp:IsInRide() or RideComp:IsAssembling()) and self.TryStartPathMoveNum <= 30 then
                FLOG_WARNING("[ChocoboTransportMgr] ride not init or is assembling !")
                self.TryStartPathMoveNum = self.TryStartPathMoveNum + 1
                self.TryMoveTimerID = _G.TimerMgr:AddTimer(self, self.__StartPathMove, 0.1)
                return
            elseif self.TryStartPathMoveNum > 30 and not RideComp:IsInRide() then
                MsgTipsUtil.ShowTipsByID(ChocoboTransportDefine.WEAK_NETWORK_TIP_ID)
                self:CancelTrasport()
                FLOG_ERROR("ChocoboTransport Rider Rsp is nil")
                return
            end
        end
    end

    -- stop start atl
    if self:IsFirstTransMap() then  -- 如果是跨地图继续运输不需要执行
        self:__StopStartAnimation()
        MsgTipsUtil.ShowTipsByID(ChocoboTransportDefine.START_TRANSPORT_TIP_ID)
    end

    self.StartMoveTimerID = nil
    self.TryMoveTimerID = nil

    self.IsCanUseSkill = true

    -- play start effect
    UIViewMgr:ShowView(UIViewID.ChocoboTransportTip, {bQuestTrans = self:IsQuestTransport()})

    local PointNum = #self.CurrentFindPath

    -- deal path point
    if not self.PosTable then
        self.PosTable = UE.TArray(UE.FVector)
    end
    self.PosTable:Clear()
    local WorldOriginLoc = _G.PWorldMgr:GetWorldOriginLocation()

    local LastIndex = self:GetCanMoveIndex()
    self.InRoom = LastIndex < PointNum

     -- 计算安全距离,从最后一个点开始找
    local SafeEndVectorPos = nil
    if self.SafeDistance and self.SafeDistance > 0 then
        local TotalDist = 0
        local EndPointData = self.CurrentFindPath[PointNum].point_data
        local EndVectorPos = UE.FVector(EndPointData.X, EndPointData.Y, EndPointData.Z)
        local LastPointData = self.CurrentFindPath[LastIndex].point_data
        local LastVectorPos = UE.FVector(LastPointData.X, LastPointData.Y, LastPointData.Z)
        local Dist = LastVectorPos:Dist2D(EndVectorPos)
        if LastVectorPos:Dist2D(EndVectorPos) < self.SafeDistance then
            TotalDist = TotalDist + Dist
            for i = LastIndex, 2, -1 do
                local PointData = self.CurrentFindPath[i].point_data
                local VectorPos = UE.FVector(PointData.X, PointData.Y, PointData.Z)
                LastPointData = self.CurrentFindPath[i - 1].point_data
                LastVectorPos = UE.FVector(LastPointData.X, LastPointData.Y, LastPointData.Z)
                Dist = LastVectorPos:Dist2D(VectorPos)
                if TotalDist + Dist > self.SafeDistance then --截断
                    local NeedDist = self.SafeDistance - TotalDist
                    local Dir = LastVectorPos - VectorPos
                    UE.FVector.Normalize(Dir)
                    SafeEndVectorPos = VectorPos + Dir * NeedDist
                    LastIndex = i - 1
                    break
                end
                TotalDist = TotalDist + Dist
            end
        end
    end

	for index = 1, LastIndex do
        local NavPoint = self.CurrentFindPath[index]
		local PointData = NavPoint.point_data
        local FVectorPos = UE.FVector(PointData.X, PointData.Y, PointData.Z) - WorldOriginLoc
        if index == LastIndex then                          -- 最后一张地图，飞行状态下，最后一个点，加150不要贴地
            if self:IsFlyMode() and self:IsLastTransMap() then
                FVectorPos =  UE.FVector(FVectorPos.X, FVectorPos.Y, FVectorPos.Z + 150)
            end
        end
        self.PosTable:Add(FVectorPos)
	end

    if SafeEndVectorPos then
        self.PosTable:Add(SafeEndVectorPos)
    end

    --- 任务运输且需要跨地图
    if self:IsQuestTransport() --[[and not self:IsFlyMode()]] and not self:IsLastTransMap() then
        --- 往外延长一个点
        local ProlongEndVec = nil
        if self.ProlongDistance and self.ProlongDistance > 0 then
            local EndPointData = self.CurrentFindPath[PointNum].point_data
            local EndVectorPos = UE.FVector(EndPointData.X, EndPointData.Y, EndPointData.Z)
            local PreEndPointData = self.CurrentFindPath[PointNum - 1].point_data
            PreEndPointData = UE.FVector(PreEndPointData.X, PreEndPointData.Y, PreEndPointData.Z)
    
            local Dir = EndVectorPos - PreEndPointData
            UE.FVector.Normalize(Dir)
            local EndVec = Dir * self.ProlongDistance
            ProlongEndVec = EndVectorPos + _G.UE.FVector(EndVec.X, EndVec.Y, EndVec.Z)  
            ProlongEndVec = UE.FVector(ProlongEndVec.X, ProlongEndVec.Y, EndVectorPos.Z - 500) -- Z值用上一個點的-100
        end

        if ProlongEndVec then
            self.PosTable:Add(ProlongEndVec)
        end
    end
        
    if self.PosTable:Length() < 2 then
        FLOG_ERROR("[ChocoboTransport] Path Point Number < 2")
        self:CancelTrasport()
        return
    end
    FLOG_INFO("[ChocoboTransport] self.PosTable:Length() = %s", self.PosTable:Length())

    -- move start
    local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
    local Speed = self:GetTransportSpeed()
    if self:IsFlyMode() then
        FLOG_INFO("[ChocoboTransport] StartPathFlyMove")
        UMoveSyncMgr:StartPathFlyMove(self.PosTable, Speed)
    else
        FLOG_INFO("[ChocoboTransport] StartPathMove")
        UMoveSyncMgr:StartPathMove(self.PosTable, Speed)
    end

    UMoveSyncMgr.OnSimulateMoveFinish:Clear()
    UMoveSyncMgr.OnSimulateMoveFinish:Add(UMoveSyncMgr, function(_, SeqID, StopType)
        local IsSuccess = StopType == UE.ESimulateMoveStop.Finished
        self:__OnMoveFinishCallback(IsSuccess, SeqID)
    end)

    EventMgr:SendEvent(EventID.ChocoboTransportStartMove)

    self.TransportStatus = TransportStatus.TurningCamera --进入旋转镜头阶段

     -- todo:超时保护
end

---切换运输状态（只在传输开始结束调用）
function ChocoboTransportMgr:__SwitchTransportStatus(IsTransport)
    self.IsTransporting = IsTransport
    if IsTransport then
		CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatTrans, true)
        -- Ride Data Init
        --MountVM:SetRideState()
        -- UI
        --UIViewMgr:ShowView(UIViewID.ChocoboTransportSkill, {bFly = self:IsFlyMode()})
        MapVM:SetIsMajorVisible(false)
        --MountVM:SetPanelVisible(false)
        --MainPanelVM:SetControlPanelVisible(false)
        --JoyStick
        _G.CommonUtil.HideJoyStick()
        _G.CommonUtil.DisableShowJoyStick(true) --关闭摇杆显示
        -- 通知cpp镜头固定
        --EventMgr:SendCppEvent(EventID.StartAutoPathMove)
        -- 设置步高
        local Major = MajorUtil.GetMajor()
        if Major then
            local MoveComp = Major:GetMovementComponent()
            if MoveComp then
                self.DefaultMaxStepHeight = MoveComp.MaxStepHeight
                MoveComp:SetMaxStepHeight(ChocoboTransportDefine.MAX_STEP_HEIGHT)
            end
        end
        EventMgr:SendEvent(EventID.ChocoboTransportBegin, {bFlyTrans = self:IsFlyMode()})
    else
		CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatTrans, false)
        -- UI
        --UIViewMgr:HideView(UIViewID.ChocoboTransportSkill) --留着,双重保护
        MapVM:SetIsMajorVisible(true)
        --MountVM:SetPanelVisible(true)
        --MainPanelVM:SetControlPanelVisible(true)
        -- JoyStick
        _G.CommonUtil.DisableShowJoyStick(false) --恢复摇杆显示
        _G.CommonUtil.ShowJoyStick()
        -- 通知cpp镜头解除固定
        EventMgr:SendCppEvent(EventID.StopAutoPathMove)

        local Major = MajorUtil.GetMajor()
        if Major then
            local MoveComp = Major:GetMovementComponent()
            if MoveComp then
                -- 恢复步高
                if self.DefaultMaxStepHeight then
                    MoveComp:SetMaxStepHeight(self.DefaultMaxStepHeight)
                end
                -- move模式保护
                if MoveComp.MovementMode == UE.EMovementMode.MOVE_Flying then
                    MoveComp:SetMovementMode(UE.EMovementMode.MOVE_Walking)
                end
            end
        end
        EventMgr:SendEvent(EventID.ChocoboTransportFinish)

        self.TransportStatus = TransportStatus.None
    end
end

function ChocoboTransportMgr:__ResetTransportStatus()
    MapVM:SetIsMajorVisible(true)
    MountVM:SetPanelVisible(true)
    MainPanelVM:SetControlPanelVisible(true)
    _G.CommonUtil.DisableShowJoyStick(false)
end

-- ==================================================
-- 发送协议包
-- ==================================================

---发送NPC登记列表查询
---@param MapID number 地图ID
function ChocoboTransportMgr:SendChocoboTransferQuery(MapID)
    if self.QueryDict[MapID] then
        --已经查询过,不用再请求服务器
        EventMgr:SendEvent(EventID.UpdateChocoboTransportNpcBookStatus)
        return
    end

    if self.QueryingDict[MapID] then
        -- 正在查询
        return
    end

    local MsgID = CS_CMD.CS_CMD_CHOCOBO_TRANSFER
    local SubMsgID = ChocoboTransferCmd.ChocoboTransferCmdQuery

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Query = { MapID = MapID }

    self.QueryingDict[MapID] = true
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---发送NPC登记
---@param MapID number 地图ID
function ChocoboTransportMgr:SendChocoboTransferBook(MapID)
    local MsgID = CS_CMD.CS_CMD_CHOCOBO_TRANSFER
    local SubMsgID = ChocoboTransferCmd.ChocoboTransferCmdBook

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Book = { MapID = MapID }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---发送开始运输请求
---@param MapID number 地图ID
---@param StartNpcID number 开始NpcID
---@param EndNpcID number 结束NpcID
---@param PosX number 传输点X
---@param PosY number 传输点Y
---@param PosZ number 传输点Z
function ChocoboTransportMgr:SendChocoboTransferGo(MapID, StartNpcID, EndNpcID, PosX, PosY, PosZ)
    if not self.CurrentFindPath then
        MsgTipsUtil.ShowTipsByID(ChocoboTransportDefine.WEAK_NETWORK_TIP_ID)
        return
    end

    if #self.CurrentFindPath < 2 then
        MsgTipsUtil.ShowTipsByID(ChocoboTransportDefine.CANNOT_ARRIVE_TIP_ID)
        return
    end

    if self.IsRequesting then
        return
    end

    local LastIndex = self:GetCanMoveIndex()
    local Distance = 0
    for i=2, LastIndex do
        local LastPoint = self.CurrentFindPath[i-1].point_data
        local Point = self.CurrentFindPath[i].point_data
        local LastVec = UE.FVector(LastPoint.X, LastPoint.Y, LastPoint.Z)
        local Vec = UE.FVector(Point.X, Point.Y, Point.Z)
        Distance = Distance + UE.FVector.Dist(LastVec, Vec)
    end

    if Distance <= ChocoboTransportDefine.CAN_TRANSPORT_MIN_DISTANCE then
        MsgTipsUtil.ShowTips(LSTR(580001), nil, 3) --580001=该目的地就在附近了，请仔细找找吧！
        return
    end

    local MsgID = CS_CMD.CS_CMD_CHOCOBO_TRANSFER
    local SubMsgID = ChocoboTransferCmd.ChocoboTransferCmdTransfer

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    local EndPos = { x = PosX, y = PosY, z = PosZ}
    MsgBody.Transfer = { MapID = MapID , StartNpcID = StartNpcID, EndNpcID = EndNpcID, EndPos = EndPos}

    self.IsRequesting = true
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    FLOG_INFO("ChocoboTransportMgr:SendChocoboTransferGo Sucess")
end

---发送结束运输请求
function ChocoboTransportMgr:SendChocoboTransferEnd(Arrived)
    local MsgID = CS_CMD.CS_CMD_CHOCOBO_TRANSFER
    local SubMsgID = ChocoboTransferCmd.ChocoboTransferCmdEnd

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.End = { 
        Arrived = Arrived,
        Quest = self:IsQuestTransport()
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---位置转key
function ChocoboTransportMgr:PosToKey(Pos)
    return math.floor(Pos.x * 0.1 + 10000) * 10000 + math.floor(Pos.y * 0.1 + 10000)
end

---发送寻路请求
---@param EndPos UE.FVector
function ChocoboTransportMgr:SendFindPath(EndPos)
    if ChocoboTransportDefine.FIND_PATH_CACHE then -- 如果开启缓存，先从缓存里拿
        self.FindPathKey = self:PosToKey(EndPos)
        local MapID = _G.PWorldMgr:GetCurrMapResID()
        local FindPathListInNpc = self.FindPathListInMap[MapID]
        if FindPathListInNpc then
            local FindPathList = FindPathListInNpc[self.CurrentNpcID]
            if FindPathList then
                local FindPath = FindPathList[self.FindPathKey]
                if FindPath then
                    self.CurrentFindPath = FindPath
                    EventMgr:SendEvent(EventID.UpdateChocoboTransportFindPath, FindPath)
                    return
                end
            end
        end
    end

    self.CurrentFindPath = nil
    local Point = nil
    if ChocoboTransportDefine.FIND_PATH_CACHE then -- 开启缓存,起始点用鸟房坐标
        local NpcData = _G.MapEditDataMgr:GetNpc(self.CurrentNpcID)
        if not NpcData then
            local MapID = _G.PWorldMgr:GetCurrMapResID()
            FLOG_ERROR("[ChocoboTransport] "..tostring(MapID).." Cant found npc id = "..tostring(self.CurrentNpcID))
            return
        end
        Point = NpcData.BirthPoint
    else
        local Major = MajorUtil.GetMajor()
        if Major then
            Point = Major:FGetActorLocation()
        end
    end
    if not Point then
        return
    end
    local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
    self.FindPathSeqID = UMoveSyncMgr:FindPath(UE.FVector(Point.X, Point.Y, Point.Z), EndPos)
end

-- ==================================================
-- 接收协议包
-- ==================================================

---返回地图已登记NPC列表
function ChocoboTransportMgr:OnNetMsgGetBookList(MsgBody)
    if nil == MsgBody or nil == MsgBody.Query then
        return
    end

    local MapID = MsgBody.Query.MapID
    local Booked = MsgBody.Query.Booked

    self.QueryDict[MapID] = true
    self.QueryingDict[MapID] = nil
    self.MapBookDict[MapID] = Booked

    self:UpdateChocoboNpcHUD(MapID)

    EventMgr:SendEvent(EventID.UpdateChocoboTransportNpcBookStatus)
end

---返回登记结果
function ChocoboTransportMgr:OnNetMsgGetBookResult(MsgBody)
    if nil == MsgBody or nil == MsgBody.Book then
        return
    end

    local MapID = MsgBody.Book.MapID

    self.MapBookDict[MapID] = true

    self:UpdateChocoboNpcHUD(MapID)

    -- 解锁提示放入队列
    local function ShowTipsCallback(Params)
        --play book success effect
        MsgTipsUtil.ShowTipsByID(ChocoboTransportDefine.BOOK_SUCCESS_TIP_ID)
        --play sound
        AudioUtil.SyncLoadAndPlayUISound(ChocoboTransportDefine.BOOK_SUCCESS_SOUND)

        EventMgr:SendEvent(EventID.UpdateChocoboTransportNpcBookStatus)
    end

    --新手引导系统陆行鸟登记成功处理
    --local function OnTutorial(Params)
    --    local EventParams = _G.EventMgr:GetEventParams()
    --    EventParams.Type = TutorialDefine.TutorialConditionType.ChocoboRegisterSuccess --新手引导触发类型
    --    _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    --end

    local Config = {Type = ProtoRes.tip_class_type.TIP_SYS_NOTICE, Callback = ShowTipsCallback, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(Config)

    --local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {}}
    --_G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

---返回请求运送结果
function ChocoboTransportMgr:OnNetMsgGetTransferResult(MsgBody)
    if nil == MsgBody or nil == MsgBody.Transfer then
        return
    end

    self.CurrEndPos = MsgBody.Transfer.EndPos

    -- npc say goodbye
    if self:IsFirstTransMap() then
        local Actor = ActorUtil.GetActorByResID(self.CurrentNpcID)
        if Actor then
            local AnimComp = Actor:GetAnimationComponent()
            if AnimComp then
                AnimComp:PlayActionTimeline(ChocoboTransportDefine.TIME_LINE_LEAVE_WITH_CHOCOBO)
            end
        end
    end

    -- ride call sound
    local SoundPath = self:GetRideCallSound()
    if SoundPath then
        AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), SoundPath, true)
    end

    -- start move
    self:__PreStartPathMove()
end

function ChocoboTransportMgr:OnNetMsgGetStatStatus(MsgBody)
    if nil == MsgBody or nil == MsgBody.Status then
        return
    end
    local StatusRsp = MsgBody.Status
    local IsTransporting = StatusRsp.StatBits & (1 << CommStatID.CommStatTrans) > 0
    FLOG_INFO("[ChocoboTransport] GetStatStatus IsTransporting="..tostring(IsTransporting))
    if IsTransporting then
        --local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
        --if UMoveSyncMgr then
        --    local FindPathSeqId = UMoveSyncMgr:GetSelfFindPathSeqId()
        --    FLOG_WARNING(string.format("[ChocoboTransport] FindPathSeqId = %s", tostring(FindPathSeqId)))
        --    if FindPathSeqId <= 0 then
                self:CancelTrasport()
        --    end
        --end
    else
        local Major = MajorUtil.GetMajor()
        if Major then
            local RideComp = Major:GetRideComponent()
            if RideComp then
                local RideResID = RideComp:GetRideResID()
                if RideResID > 0 then
                    FLOG_INFO("[ChocoboTransport] Transport is false but in ride= "..tostring(RideResID))
                    -- 不在运输中,但是坐在运输鸟上或任务鸟上
                    local PurposeType = _G.MountMgr:GetPurposeType(RideResID)
                    if PurposeType == ProtoRes.EnumRidePurposeType.Transport or
                        PurposeType == ProtoRes.EnumRidePurposeType.Quest then
                        -- 主动发下坐骑请求
                        _G.MountMgr:ForceSendMountCancelCall()
                    end
                end
            end
        end
    end

    self:UnRegisterGameNetMsg(CS_CMD.CS_CMD_COMM_STAT, ProtoCS.CS_COMM_STAT_CMD.CS_COMM_STAT_CMD_STATUS, self.OnNetMsgGetStatStatus)
end

function ChocoboTransportMgr:OnNetMsgFindPath(MsgBody)
    if nil == MsgBody then
        return
    end

    local FindPathRsp = MsgBody
    if self.FindPathSeqID ~= FindPathRsp.id then
        return
    end

    FLOG_INFO("[ChocoboTrans] recieve find path, FindPathSeqID="..tostring(self.FindPathSeqID))

    local PointNum = #FindPathRsp.NavPoints

    local CurrentPoints = nil
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    if not self.FindPathListInMap[MapID] then
        self.FindPathListInMap[MapID] = {}
    end
    local FindPathListInNpc = self.FindPathListInMap[MapID]

    if not FindPathListInNpc[self.CurrentNpcID] then
        FindPathListInNpc[self.CurrentNpcID] = {}
    end
    local FindPathList = FindPathListInNpc[self.CurrentNpcID]

    local WorldOriginLoc = _G.PWorldMgr:GetWorldOriginLocation()
    if WorldOriginLoc.X == 0 and WorldOriginLoc.Y == 0 then
        EventMgr:SendEvent(EventID.UpdateChocoboTransportFindPath, FindPathRsp.NavPoints)
        --缓存
        if ChocoboTransportDefine.FIND_PATH_CACHE then
            FindPathList[self.FindPathKey] = FindPathRsp.NavPoints
        end
        CurrentPoints = FindPathRsp.NavPoints
    else
        local NavPointList = {}
        for index = 1, PointNum do

            local NavPoint = FindPathRsp.NavPoints[index]
            NavPoint.point_data.X = NavPoint.point_data.X - WorldOriginLoc.X
            NavPoint.point_data.Y = NavPoint.point_data.Y - WorldOriginLoc.Y

            table.insert(NavPointList, NavPoint)
        end
        EventMgr:SendEvent(EventID.UpdateChocoboTransportFindPath, NavPointList)
        --缓存
        if ChocoboTransportDefine.FIND_PATH_CACHE then
            FindPathList[self.FindPathKey] = NavPointList
        end
        CurrentPoints = NavPointList
    end

    self.CurrentFindPath = CurrentPoints

    if next(self.OnFindPathParams) ~= nil then
        self.OnFindPathParams.CallBack(self.OnFindPathParams.Caller)
        self.OnFindPathParams = {}
    end
end

-- ==================================================
-- 接收事件
-- ==================================================

function ChocoboTransportMgr:OnPlayAnimationEnd()
    self.PlayEndTimerID = nil
    self.ATLID = nil
    --[[
    if ChocoboTransportDefine.USE_CLIENT_MOUNT then
        -- mount
        local Major = MajorUtil.GetMajor()
        if Major then
            -- update ride status
            local RideComp = Major:GetRideComponent()
            if RideComp then
                if RideComp:IsAssembling() then
                    FLOG_WARNING("[ChocoboTransportMgr] ride is assembling !")
                    -- 一些异常情况ride还在组装,这里加定时保护
                    self.PlayEndTimerID = _G.TimerMgr:AddTimer(self, self.OnPlayAnimationEnd, 0.2)
                    return
                else
                    RideComp:UnUseRide(true)
                end
            end
            -- exit sound
            local RideCfgItem = RideCfg:FindCfgByKey(ChocoboTransportDefine.MOUNT_RES_ID)
            if RideCfgItem then
                UE.UAudioMgr:Get():LoadAndPostEvent(RideCfgItem.MountExitse, Major, true)
            end
        end
    end
    ]]

    -- switch status display
    _G.InteractiveMgr:OnEntranceVisible(true)
    self:OnSuccessTransport()
end

function ChocoboTransportMgr:OnGameEventLoginRes(Params)
    if not CommonUtil.IsShipping() then
        FLOG_INFO("[ChocoboTransport] LoginRes bReconnect="..tostring(Params.bReconnect) .."  , IsTransporting="..tostring(self.IsTransporting) )
    end
    if Params.bReconnect then
        if self.IsTransporting then
            self:CancelTrasport()
        end
    end
end

function ChocoboTransportMgr:OnGameEventNetworkReconnected(Params)
    local bRelay = Params and Params.bRelay
    if not CommonUtil.IsShipping() then
        FLOG_INFO("[ChocoboTransport] OnGameEventNetworkReconnected bRelay="..tostring(bRelay))
    end
end

function ChocoboTransportMgr:OnGameEventAutoPathServerPull()
    local IsPrint = not CommonUtil.IsShipping()
    if IsPrint then
        FLOG_INFO("[ChocoboTransport] on recieve server pull location")
    end
    if not self:GetIsTransporting() then
        if IsPrint then
            FLOG_INFO("[ChocoboTransport] curr is not transporting")
        end
        return
    end
    -- 弱网拉扯情况处理
    if not self.PosTable then
        if IsPrint then
            FLOG_ERROR("[ChocoboTransport] PosTable is nil")
        end
        return
    end
    if self.PosTable:Length() <= 1 then
        if IsPrint then
            FLOG_ERROR("[ChocoboTransport] PosTable length <= 1")
        end
        return
    end
    local BrokenPosTable = self:GetResumeBrokenPosTable()
    if not BrokenPosTable then
        if IsPrint then
            FLOG_ERROR("[ChocoboTransport] cannot found broken pos!!")
        end
        return
    end
    local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
    UMoveSyncMgr.OnSimulateMoveFinish:Clear()
    local Speed = self:GetTransportSpeed()
    if self:IsFlyMode() then
        if IsPrint then
            FLOG_INFO("[ChocoboTransport] server pull then restart PathFlyMove")
        end
        UMoveSyncMgr:StopPathFlyMove(UE.ESimulateMoveStop.Break)
        UMoveSyncMgr:StartPathFlyMove(BrokenPosTable, Speed)
    else
        if IsPrint then
            FLOG_INFO("[ChocoboTransport] server pull then restart PathMove")
        end
        UMoveSyncMgr:StopPathMove(UE.ESimulateMoveStop.Break)
        UMoveSyncMgr:StartPathMove(BrokenPosTable, Speed)
    end
    UMoveSyncMgr.OnSimulateMoveFinish:Add(UMoveSyncMgr, function(_, SeqID, StopType)
        local IsSuccess = StopType == UE.ESimulateMoveStop.Finished
        self:__OnMoveFinishCallback(IsSuccess, SeqID)
    end)
end

---断(路)点续传
function ChocoboTransportMgr:GetResumeBrokenPosTable()
    local IsPrint = not CommonUtil.IsShipping()
    local Major = MajorUtil.GetMajor()
    if not Major then
        return nil
    end
    local Point = Major:FGetActorLocation()
    local Width = 100 --1米
    local StartIndex = nil
    local Length = self.PosTable:Length()
    for i=2, Length do
        local LastPos = self.PosTable:GetRef(i-1)
        local Pos = self.PosTable:GetRef(i)
        if MathUtil.IsPointOnLine(Point.X, Point.Y, LastPos.X, LastPos.Y, Pos.X, Pos.Y,  Width) then
            StartIndex = i
            if IsPrint then
                FLOG_INFO("[ChocoboTransport] GetResumeBroken Major pos:"..tostring(Point.X)..","..tostring(Point.Y))
                FLOG_INFO("[ChocoboTransport] GetResumeBroken Found StartIndex = "..tostring(StartIndex))
            end
            break
        end
    end
    if not StartIndex then
        FLOG_ERROR("[ChocoboTransport] GetResumeBroken cannot Found StartIndex, Major pos:"..tostring(Point.X)..","..tostring(Point.Y))
        return nil
    end
    local ResumeBrokenPosTable = UE.TArray(UE.FVector)
    for i=StartIndex, Length do
        local Pos = self.PosTable:GetRef(i)
        ResumeBrokenPosTable:Add(Pos)
    end
    return ResumeBrokenPosTable
end

function ChocoboTransportMgr:OnGameEventEnterWorld()
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    self:SendChocoboTransferQuery(MapID)

    -- 保护,如果进入副本是传输状态,请求传输结束
    local MajorStatComp = MajorUtil.GetMajorStateComponent()
    if MajorStatComp then
        if MajorStatComp:IsInNetState(ProtoCommon.CommStatID.CommStatTrans) then
            FLOG_WARNING(string.format("[ChocoboTransport] status in trans when enter world"))
            self:CancelTrasport()
            return --return 不用监听状态了
        end
    end

    
    --[[
    local EntityID = MajorUtil.GetMajorEntityID()

    local HasStatCache = false
    local CacheStat = 0
    local Mgr = UE.UCommonStateMsgHandler:Get()
    if Mgr then
        HasStatCache = Mgr:GetCommStat(EntityID, CacheStat)
    end
    FLOG_ERROR("[ChocoboTransport] HasStatCache="..tostring(HasStatCache))
    if HasStatCache then
        FLOG_ERROR("[ChocoboTransport] CacheStat="..tostring(CacheStat))
        local Val = 1 << ProtoCommon.CommStatID.CommStatTrans
        if (CacheStat & Val) == Val then
            FLOG_WARNING(string.format("[ChocoboTransport] cache status in trans when enter world"))
            self:CancelTrasport()
            return
        end
    else
        local MajorStatComp = MajorUtil.GetMajorStateComponent()
        if MajorStatComp then
            if MajorStatComp:IsInNetState(ProtoCommon.CommStatID.CommStatTrans) then
                FLOG_WARNING(string.format("[ChocoboTransport] status in trans when enter world"))
                self:CancelTrasport()
                return
            end
        end
    end
    ]]

    -- 二次保护,可能状态同步包未到达，监听状态协议
    self:UnRegisterGameNetMsg(CS_CMD.CS_CMD_COMM_STAT, ProtoCS.CS_COMM_STAT_CMD.CS_COMM_STAT_CMD_STATUS, self.OnNetMsgGetStatStatus)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMM_STAT, ProtoCS.CS_COMM_STAT_CMD.CS_COMM_STAT_CMD_STATUS, self.OnNetMsgGetStatStatus)


    self:TryContinueBeginTrans()

end

function ChocoboTransportMgr:OnGameEventMajorCreate()
    FLOG_INFO("ChocoboTransportMgr:OnGameEventMajorCreate()")

end

function ChocoboTransportMgr:OnGameEventEnterExit(LeavePWorldResID, LeaveMapResID)
    --for _, TriggerActor in ipairs(self.NpcTriggerList) do
    --    _G.CommonUtil.DestroyActor(TriggerActor)
    --end
    --self.NpcTriggerList = {}
    --FLOG_ERROR("[ChocoboTransport] IsTransporting="..tostring(self.IsTransporting) )
    self.bTransOnLeaveWorld = self.IsTransporting
    if self.IsTransporting then
        --local Major = MajorUtil.GetMajor()
        --if Major then
        --    local MoveComp = Major:GetMovementComponent()
        --    if MoveComp then
        --        MoveComp.bCanWalkOffLedges = true --恢复检测fall
        --    end
        --end
        -- self:CancelTrasport() -- 如果fly会注册DiableTimer，下面刚好有反注册逻辑
    end

    if self.AnimTimerID then
        _G.TimerMgr:CancelTimer(self.AnimTimerID)
        self.AnimTimerID = nil
    end

    if self.PlayEndTimerID then
        _G.TimerMgr:CancelTimer(self.PlayEndTimerID)
        self.PlayEndTimerID = nil
    end

    if self.PlayStartTimerID then
        _G.TimerMgr:CancelTimer(self.PlayStartTimerID)
        self.PlayStartTimerID = nil
    end

    if self.StartMoveTimerID then
        _G.TimerMgr:CancelTimer(self.StartMoveTimerID)
        self.StartMoveTimerID = nil
    end
    
    if self.TryMoveTimerID then
        _G.TimerMgr:CancelTimer(self.TryMoveTimerID)
        self.TryMoveTimerID = nil
    end

    if self.DiableTimer then
        self:UnRegisterTimer(self.DiableTimer)
        self:OnInGround()
        self.DiableTimer = nil
    end
end

function ChocoboTransportMgr:OnGameEventUpdatePosition()
    if self.TransportStatus == TransportStatus.TurningCamera then
        if self.PosTable and self.PosTable:Length() > 1 then
            local Vec = self.PosTable:GetRef(1)
            local Major = MajorUtil.GetMajor()
            local Location = Major:FGetActorLocation()
            local Dist = MathUtil.Dist(Vec, Location)
            if Dist > 1000 then
                EventMgr:SendCppEvent(EventID.StartAutoPathMove)
                self.TransportStatus = TransportStatus.Running
            end
        end
    elseif self.TransportStatus == TransportStatus.Running then
        if self.PosTable and self.PosTable:Length() > 1 then
            local Last = self.PosTable:Length()
            local Vec = self.PosTable:GetRef(Last)
            local Major = MajorUtil.GetMajor()
            local Location = Major:FGetActorLocation()
            local Dist = MathUtil.Dist(Vec, Location)
            if Dist < 1000 then
                EventMgr:SendCppEvent(EventID.StopAutoPathMove)
                self.TransportStatus = TransportStatus.RecoverCamera
            end
        end
    end
    if self.TransportStatus >= TransportStatus.TurningCamera and self.TransportStatus <= TransportStatus.RecoverCamera then
        self.CheckBlockTime = self.CheckBlockTime + 1
        if math.fmod(self.CheckBlockTime, 10) == 0 then -- 每一秒通过一次
            self:CheckBlocked()
        end
    end
end

function ChocoboTransportMgr:OnCastBuff(Params)
    local EntityID = Params.ULongParam1
    if MajorUtil.GetMajorEntityID() ~= EntityID then
        return
    end
    local BuffID = Params.IntParam1
    if BuffID == ChocoboTransportDefine.BUFFER_ID_SPEED_UP then
        local Major = MajorUtil.GetMajor()
        if Major then
            local AnimComp = Major:GetAnimationComponent()
            if AnimComp then
                local ActionTimelines = {}
                for _, TimelineParam in ipairs(ChocoboTransportDefine.TIME_LINE_CHOCOBO_SPEED_UP_LIST) do
                    local PathCfg = ActiontimelinePathCfg:FindCfgByKey(TimelineParam.ID)
                    if PathCfg == nil then
                        FLOG_ERROR("ActiontimelinePathCfg = nil TimelineID = %s", TimelineParam.ID)
                        return
                    end
                    local ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
                    table.insert(ActionTimelines, { AnimPath = ActionTimelinePath, PlayRate = TimelineParam.Rate, TargetAvatarPartType = UE.EAvatarPartType.RIDE_MASTER})
                end
                self.SpeedATLID = _G.AnimMgr:PlayAnimationMulti(EntityID, ActionTimelines)
            end
            self:__PlaySpeedVfx(Major, ChocoboTransportDefine.SPEED_VFX_PATH)
            --play sound
            AudioUtil.SyncLoadAndPlaySoundEvent(EntityID, ChocoboTransportDefine.ACCELERATION_SKILL_SOUND, true)
        end
    end
end

function ChocoboTransportMgr:OnRemoveBuff(Params)
    local EntityID = Params.ULongParam1
    if MajorUtil.GetMajorEntityID() ~= EntityID then
        return
    end
    local BuffID = Params.IntParam1
    if BuffID == ChocoboTransportDefine.BUFFER_ID_SPEED_UP then
        if self.SpeedATLID then -- 这里只停加速ATL
            --_G.AnimMgr:StopAnimationMulti(MajorUtil.GetMajorEntityID(), self.ATLID) --无效,先注释
            local Major = MajorUtil.GetMajor()
            if Major then
                local AnimComp = Major:GetAnimationComponent()
                AnimComp:StopAnimation("", UE.EAvatarPartType.RIDE_MASTER)
            end
            self.SpeedATLID = nil
        end
        self:__StopSpeedVfx()
    end
end

function ChocoboTransportMgr:__PlaySpeedVfx(Major, EffectPath)
    self:__StopSpeedVfx()
    local VfxParameter = UE.FVfxParameter()
    VfxParameter.VfxRequireData.VfxTransform = Major:GetTransform()
    VfxParameter.VfxRequireData.EffectPath = CommonUtil.ParseBPPath(EffectPath)
    VfxParameter.PlaySourceType= UE.EVFXPlaySourceType.PlaySourceType_URideComponent
    local AttachPointType_AvatarPartType = UE.EVFXAttachPointType.AttachPointType_AvatarPartType
    VfxParameter:AddTarget(Major, 0, AttachPointType_AvatarPartType, UE.EAvatarPartType.RIDE_MASTER)
    self.SpeedVfxID = EffectUtil.PlayVfx(VfxParameter)
end

function ChocoboTransportMgr:__StopSpeedVfx()
    local SpeedVfxID = self.SpeedVfxID
    if SpeedVfxID then
        EffectUtil.StopVfx(SpeedVfxID)
        self.SpeedVfxID = nil
    end
end

function ChocoboTransportMgr:CheckBlocked()
    local Major = MajorUtil.GetMajor()
    local Location = Major:FGetActorLocation()
    local MajorLocationRecord = self.MajorLocationRecord
    table.insert(MajorLocationRecord, Location)
    local Num = #MajorLocationRecord
    if Num >= 3 then
        local Dist = MathUtil.Dist(MajorLocationRecord[1], MajorLocationRecord[2])
        if Dist < 50 then --3秒移动半米内,认为被阻挡,结束运输
            Dist = MathUtil.Dist(MajorLocationRecord[2], MajorLocationRecord[3])
            if Dist < 50 then
                self:CancelTrasport()
            end
        end
        table.remove(MajorLocationRecord, 1)
    end
end

---计算能移动的路点index（室内点不可达）
function ChocoboTransportMgr:GetCanMoveIndex()
    if not self.CurrentFindPath then
        return 0
    end
    if self:IsQuestTransport() then -- 任务范式会跨世界，需要所有点
        return #self.CurrentFindPath
    end

    local PointNum = #self.CurrentFindPath
    local LastIndex = PointNum
    local InRoom = false
    for i = 1, PointNum do
        local Point = self.CurrentFindPath[i]
        if Point.point_type == NavmeshPointType.NAVPOINT_TYPE_NOT_WAYPOINT then
            if not InRoom then
                LastIndex = i
            end
        elseif Point.point_type == NavmeshPointType.NAVPOINT_TYPE_IN_WAYPOINT then
            InRoom = true
        else
            InRoom = false
            LastIndex = i --室外点肯定能走到
        end
    end
    return LastIndex
end

-- ==================================================
-- 外部系统接口
-- ==================================================

--- @type 重置跨地图条件状态_BehaviorRide:DoStartBehavior()中用于重置
function ChocoboTransportMgr:ResetAcrossMapData()
    self.bTransOnLeaveWorld = false
end

---清理上次请求信息
function ChocoboTransportMgr:ClearLastRequestInfo()
    self.IsRequesting = false
end

---获取是否运输中
---@return boolean
function ChocoboTransportMgr:GetIsTransporting()
    return self.IsTransporting
end

-- 运输中跨地图不要下坐骑
function ChocoboTransportMgr:CheckNeedRide()
    return self.IsTransporting and self:IsQuestTransport() and not self:IsLastTransMap()
end


---获取可以使用技能
---@return boolean
function ChocoboTransportMgr:GetIsCanUseSkill()
    return self.IsCanUseSkill
end

---@return boolean 在离开的时候是否是骑乘坐骑
function ChocoboTransportMgr:GetbTransOnLeaveWorld()
    return self.bTransOnLeaveWorld
end

---获取玩家是否运输中
---@param EntityID number
---@return boolean
function ChocoboTransportMgr:GetActorIsTransporting(EntityID)
    local StateComponent = ActorUtil.GetActorStateComponent(EntityID)
    return StateComponent:IsInNetState(ProtoCommon.CommStatID.CommStatTrans)
end

---获取当前地图是否有追踪任务
---@return boolean
function ChocoboTransportMgr:GetIsHasTrackingQuestCurrentMap()
    local TrackingQuestParam = _G.QuestTrackMgr:GetTrackingQuestParam()
    if #TrackingQuestParam > 0 then
        local CurrMapResID = _G.PWorldMgr:GetCurrMapResID()
        for _,Param in ipairs(TrackingQuestParam) do
            if Param.MapID == CurrMapResID then
                return true
            end
        end
    end
    return false
end

---运输中锁镜头,提供接口让镜头旋转值
function ChocoboTransportMgr:GetAutoMoveLagValue()
    return 2 --临时写死,后面配入global表
end

---开始运输
---@param MapID number@地图ID
---@param EndNpcID number@终点npc id
---@param X number@终点坐标X
---@param Y number@终点坐标Y
---@param Z number@终点坐标Z
---@param SafeDistance number@安全距离（距离终点多少米提前完成运输）
---@param bFly boolean@是否是飞行运输
function ChocoboTransportMgr:StartTransport(MapID, EndNpcID, X, Y, Z, SafeDistance, bFly)
    --[[
    if not EndNpcID or EndNpcID == 0 then --目标点不是鸟房,根据设计,寻找坐标的附近辅助点
        local Point = self:GetNearbyTransportPoint(X, Y, Z)
        if Point then
            self:SendChocoboTransferGo(MapID, self.CurrentNpcID, 0, Point.X, Point.Y, Point.Z)
        end
    else
        --如果是鸟房,终点不能与鸟房重叠
        --计算鸟房附近的点
        X, Y, Z = self:GetNearbyPoint(X, Y, Z)

        self:SendChocoboTransferGo(MapID, self.CurrentNpcID, EndNpcID, X, Y, Z)
    end
    ]]
    --- 体验优化
    -- 陆行鸟优先朝向下一个路点
    local Major = MajorUtil.GetMajor()
    if Major then
        if self.CurrentFindPath and #self.CurrentFindPath > 1 then
            local Point = self.CurrentFindPath[2].point_data
            local MajorLoc = Major:FGetActorLocation()
            local Vector = UE.FVector(Point.X, Point.Y, MajorLoc.Z)
            local LookAtRot = UE.UKismetMathLibrary.FindLookAtRotation(MajorLoc, Vector)
            Major:FSetRotationForServer(UE.FRotator(0, LookAtRot.Yaw, 0))
            FLOG_INFO("FSetRotationForServer Suc  #self.CurrentFindPath Num = %s", #self.CurrentFindPath)
            --camera
            --local CameraControlComponent = Major:GetCameraControllComponent()
            --if CameraControlComponent then
            --    CameraControlComponent:ResetSpringArm(false)
            --end
        end

        local AvatarCom = Major:GetAvatarComponent()
        if AvatarCom then
            -- 立刻收刀
            AvatarCom:TempSetAvatarBack(1)
        end
    end
    self.SafeDistance = SafeDistance

    -- 保护,如果这时候在坐骑上,先下坐骑
	local bInRide = false
	if bFly then
		-- 飞行运输按照实际是否在坐骑上判断
		local MajorEntityID = MajorUtil.GetMajorEntityID() 
		bInRide = ActorUtil.IsInRide(MajorEntityID)
	else
		-- 普通运输为避免自动寻路影响按照坐骑ViewModel接口判断
		bInRide = _G.MountMgr:IsInRide()
	end
  
    if bInRide then
        local function CancelCallback()
            self:SendChocoboTransferGo(MapID, self.CurrentNpcID, EndNpcID or 0, X, Y, Z)        
        end
        _G.MountMgr:SendMountCancelCall(CancelCallback)
        return
    end

    self:SendChocoboTransferGo(MapID, self.CurrentNpcID, EndNpcID or 0, X, Y, Z)
end

--- 取消运输
function ChocoboTransportMgr:CancelTrasport()
    local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
    UMoveSyncMgr.OnSimulateMoveFinish:Clear()
    self.IsCanUseSkill = false
    if self:IsFlyMode() then
        UMoveSyncMgr:StopPathFlyMove(UE.ESimulateMoveStop.Break)
        self:ReportChocoboQTE(2, 3)
        if self.bTransOnLeaveWorld and not self:IsTransMap() then     -- 因为传送导致break飞行运输单独处理
            self:BreakFlyTransportImmed()
        else
            self:OnBreakFlyTransport()
        end
    else
        UMoveSyncMgr:StopPathMove(UE.ESimulateMoveStop.Break) -- MoveMode变成了Walking
        self:ReportChocoboQTE(2, 4)
        self:OnBreakTransport()
        FLOG_INFO("ChocoboTransportMgr:CancelTrasport() is not fly mode")
    end

    FLOG_INFO("ChocoboTransportMgr:CancelTrasport() Suc")
end

--- @type 当终止运输时相关表现处理
function ChocoboTransportMgr:OnBreakTransport()
    self:__SwitchTransportStatus(false)
    self:SendChocoboTransferEnd(false)
    self:ClearQuestTransData()
end

--- @type 运输到达目的地时相关表现处理
function ChocoboTransportMgr:OnSuccessTransport()
    self:RegisterTimer(self.__SwitchTransportStatus, 0.5, 0, 1, false)
    self:SendChocoboTransferEnd(true)
    self:ClearQuestTransData()
end

---获取附近的传输点
---@param X number@坐标X
---@param Y number@坐标Y
---@param Z number@坐标Z
---@return ChocoboTransportPoint
function ChocoboTransportMgr:GetNearbyTransportPoint(X, Y, Z)
    ---@type table<ChocoboTransportPoint>
    local PointList = {}
    local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()

    --辅助点位置
    if CurMapEditCfg.ChocoboTransportPointList then
        for _, V in ipairs(CurMapEditCfg.ChocoboTransportPointList) do
            ---@class ChocoboTransportPoint
            ---@field X number@坐标X
            ---@field Y number@坐标Y
            ---@field Z number@坐标Z
            ---@field Type number@类型1=鸟房,2=辅助点
            ---@field NpcID number
            local Point = {}
            Point.X = V.Point.X
            Point.Y = V.Point.Y
            Point.Z = V.Point.Z
            Point.Type = 2
            table.insert(PointList, Point)
        end
    end

    --鸟房位置
    if CurMapEditCfg.NpcList then
        for _, V in ipairs(CurMapEditCfg.NpcList) do
            if NpcMgr:IsChocoboNpcByNpcID(V.NpcID) then
                --if self.CurrentNpcID ~= V.NpcID then
                    ---@type ChocoboTransportPoint
                    local Point = {}
                    Point.X = V.BirthPoint.X
                    Point.Y = V.BirthPoint.Y
                    Point.Z = V.BirthPoint.Z
                    Point.Type = 1
                    Point.NpcID = V.NpcID
                    table.insert(PointList, Point)
                --end
            end
        end
    end

    local TargetPoint = UE.FVector(X, Y, Z)
    local MinDistance = nil
    local FindTransportPoint = nil
    for _, Point in ipairs(PointList) do
        local PointVec = UE.FVector(Point.X, Point.Y, Point.Z)
        local Dis = PointVec:Dist2D(TargetPoint)
        if not MinDistance then
            MinDistance = Dis
            FindTransportPoint = Point
        else
            if Dis < MinDistance then
                MinDistance = Dis
                FindTransportPoint = Point
            end
        end
    end
    return FindTransportPoint
end

function ChocoboTransportMgr:SetQuestPoint(QuestPoint, MinDistance, MajorPos, TargetPos)
    local Dis = MathUtil.Dist(MajorPos, TargetPos)
    if not MinDistance then
        MinDistance = Dis
        QuestPoint = {}
        QuestPoint.X = TargetPos.X
        QuestPoint.Y = TargetPos.Y
        QuestPoint.Z = TargetPos.Z
    else
        if Dis < MinDistance then
            MinDistance = Dis
            QuestPoint = {}
            QuestPoint.X = TargetPos.X
            QuestPoint.Y = TargetPos.Y
            QuestPoint.Z = TargetPos.Z
        end
    end
    return QuestPoint, MinDistance
end

---获取能够前往目标点的隘口
function ChocoboTransportMgr:GetGapPointToTransportPoint(MapID, Pos)
    local DstMapList = self.MapGapDict[MapID]
    if DstMapList then
        for _, DstMapData in ipairs(DstMapList) do
            local DstMapID = DstMapData.DstMapID
            if DstMapID == MapID then
                local TargetBlockID = _G.NavigationPathMgr:GetBlockID(MapID, Pos)
                local DstPosition = DstMapData.DstPosition
                local FindBlockID = _G.NavigationPathMgr:GetBlockID(MapID, UE.FVector(DstPosition.X, DstPosition.Y, DstPosition.Z))
                if TargetBlockID == FindBlockID then --同一个地块
                    if DstMapData.TransType == TransitionType.TRANSITION_NPC then
                        local NpcData = _G.MapEditDataMgr:GetNpc(DstMapData.ActorResID)
                        if NpcData then
                            return  NpcData.BirthPoint
                        end
                    else
                        return DstMapData.Position
                    end
                end
            end
        end
    end
    return nil
end

---获取任务目标附近的传输点
---@return ChocoboTransportPoint
function ChocoboTransportMgr:GetQuestTargetNearbyTransportPoint(MapID)
    local QuestList = _G.QuestTrackMgr:GetTrackingQuestParam()

    local MinDistance = nil
    local IsNearGap = false

    ---@type ChocoboTransportPoint
    local QuestPoint = nil

    local Major = MajorUtil.GetMajor()
    local MajorPos = Major:FGetActorLocation()

    for _, Quest in ipairs(QuestList) do
        if Quest.Pos then
            if MapID == Quest.MapID then --目标点在当前地图
                local FindQuestPos = Quest.AssistPos or Quest.Pos
                if self:IsSameMapBlock(MapID, MajorPos, FindQuestPos) then --目标点在同一个地块
                    QuestPoint, MinDistance = self:SetQuestPoint(QuestPoint, MinDistance, MajorPos, FindQuestPos)
                    IsNearGap = false
                else --目标点在不同地块
                    local DstMapList = self.MapGapDict[MapID]
                    if DstMapList then
                        for _, DstMapData in ipairs(DstMapList) do
                            local DstMapID = DstMapData.DstMapID
                            if DstMapID == MapID then
                                local TargetBlockID = _G.NavigationPathMgr:GetBlockID(MapID, FindQuestPos)
                                local DstPosition = DstMapData.DstPosition
                                local FindBlockID = _G.NavigationPathMgr:GetBlockID(MapID, UE.FVector(DstPosition.X, DstPosition.Y, DstPosition.Z))
                                if TargetBlockID == FindBlockID then --同一个地块
                                    if DstMapData.TransType == TransitionType.TRANSITION_NPC then
                                        local NpcData = _G.MapEditDataMgr:GetNpc(DstMapData.ActorResID)
                                        if NpcData then
                                            QuestPoint, MinDistance = self:SetQuestPoint(QuestPoint, MinDistance, MajorPos, NpcData.BirthPoint)
                                            IsNearGap = true
                                        end
                                    else
                                        QuestPoint, MinDistance = self:SetQuestPoint(QuestPoint, MinDistance, MajorPos, DstMapData.Position)
                                        IsNearGap = true
                                    end
                                end
                            end
                        end
                    end
                end
            else --目标点不在当前地图
                --判断是否邻图,是则送到对应的隘口
                local DstMapList = self.MapGapDict[MapID]
                if DstMapList then
                    for _, DstMapData in ipairs(DstMapList) do
                        local DstMapID = DstMapData.DstMapID
                        if DstMapID == Quest.MapID then
                            local FindGapPos = DstMapData.Position
                            if self:IsSameMapBlock(MapID, MajorPos, FindGapPos) then --目标点在同一个地块
                                if DstMapData.TransType == TransitionType.TRANSITION_NPC then
                                    local NpcData = _G.MapEditDataMgr:GetNpc(DstMapData.ActorResID)
                                    if NpcData then
                                        QuestPoint, MinDistance = self:SetQuestPoint(QuestPoint, MinDistance, MajorPos, NpcData.BirthPoint)
                                        IsNearGap = true
                                    end
                                else
                                    QuestPoint, MinDistance = self:SetQuestPoint(QuestPoint, MinDistance, MajorPos, DstMapData.Position)
                                    IsNearGap = true
                                end
                            end
                        end
                    end
                end
            end
            --if QuestPoint then
            --    if Quest.NaviType == QuestDefine.NaviType.NpcResID then
            --        QuestPoint.NpcID = Quest.NaviObjID
            --    end
            --end
        end
    end

    if not QuestPoint then
        -- 如果没找到追踪任务，则找当前地图进行中的任务，按优先级找，找不到再找下一级
        local MapQuestList = _G.QuestTrackMgr:GetMapQuestList(MapID)
        local QuestTypeQuestList = {}
        local MaxQuestType = 3
        for i=1,MaxQuestType do
            QuestTypeQuestList[i] = {}
        end
        for _, QuestParam in ipairs(MapQuestList) do
            local QuestStatus = _G.QuestMgr:GetQuestStatus(QuestParam.QuestID)
            if QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
                local QuestTypeIndex = QuestParam.QuestType + 1
                table.insert(QuestTypeQuestList[QuestTypeIndex], QuestParam)
            end
        end

        for i=1, MaxQuestType do
            local QuestParamList = QuestTypeQuestList[i]
            for _, Quest in ipairs(QuestParamList) do
                if Quest.Pos then
                    if MapID == Quest.MapID then --目标点在当前地图
                        local FindQuestPos = Quest.AssistPos or Quest.Pos
                        if self:IsSameMapBlock(Quest.MapID, MajorPos, FindQuestPos) then --目标点在同一个地块
                            QuestPoint, MinDistance = self:SetQuestPoint(QuestPoint, MinDistance, MajorPos, FindQuestPos)
                            IsNearGap = false
                        else --目标点在不同地块
                            local DstMapList = self.MapGapDict[MapID]
                            if DstMapList then
                                for _, DstMapData in ipairs(DstMapList) do
                                    local DstMapID = DstMapData.DstMapID
                                    if DstMapID == MapID then
                                        local TargetBlockID = _G.NavigationPathMgr:GetBlockID(MapID, FindQuestPos)
                                        local DstPosition = DstMapData.DstPosition
                                        local FindBlockID = _G.NavigationPathMgr:GetBlockID(MapID, UE.FVector(DstPosition.X, DstPosition.Y, DstPosition.Z))
                                        if TargetBlockID == FindBlockID then --同一个地块
                                            if DstMapData.TransType == TransitionType.TRANSITION_NPC then
                                                local NpcData = _G.MapEditDataMgr:GetNpc(DstMapData.ActorResID)
                                                if NpcData then
                                                    QuestPoint, MinDistance = self:SetQuestPoint(QuestPoint, MinDistance, MajorPos, NpcData.BirthPoint)
                                                    IsNearGap = true
                                                end
                                            else
                                                QuestPoint, MinDistance = self:SetQuestPoint(QuestPoint, MinDistance, MajorPos, DstMapData.Position)
                                                IsNearGap = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if QuestPoint then
                break
            end
        end
    end

    return QuestPoint, IsNearGap
end

---是否已经登记
---@param MapID number
---@param NpcID number
---@return boolean
function ChocoboTransportMgr:IsBook(MapID, NpcID)
    return self.MapBookDict[MapID]
end

---是否出发鸟房
---@param NpcID number
---@return boolean
function ChocoboTransportMgr:IsStartNpc(NpcID)
    return NpcID == self.CurrentNpcID
end

---获取任务npc查询开关
---@return boolean
function ChocoboTransportMgr:GetQuestNpcQueryEnable()
    return self.IsQuestNpcQueryEnable
end

---获取显示辅助点开关
---@return boolean
function ChocoboTransportMgr:GetShowTransportPointEnable()
    return self.IsShowTransportPointEnable
end

---获取npc头顶图标
---@param NpcServerId number
---@return string|nil
function ChocoboTransportMgr:GetNPCHudIcon(EntityID)
    local Attr = ActorUtil.GetActorAttributeComponent(EntityID)
    if Attr then
        local NpcID = Attr.ResID
        if _G.NpcMgr:IsChocoboNpcByNpcID(NpcID) then
            local MapID = _G.PWorldMgr:GetCurrMapResID()
            if self:IsBook(MapID, NpcID) then
                return ChocoboTransportDefine.ICON_HUD
            else
                return ChocoboTransportDefine.ICON_UNBOOK_HUD
            end
        end
    end
    return nil
end

---获取状态图标
function ChocoboTransportMgr:GetVisionStatusIcon()
    return ChocoboTransportDefine.ICON_STATUS
end

---获取地图标记图标
---@param MapID number
---@param NpcID number
function ChocoboTransportMgr:GetMapMarkerIcon(MapID, NpcID)
    if not self.QueryDict[MapID] then
        self:SendChocoboTransferQuery(MapID)
    end
    if self:IsBook(MapID, NpcID) then
        return ChocoboTransportDefine.ICON_ACTIVE_MARKER
    end
    return ChocoboTransportDefine.ICON_UNACTIVE_MARKER
end

---获取UI上路点位置列表
---@param UIMapID number
---@param ScaleX number
---@return UE.TArray<UE.FVector2D>
function ChocoboTransportMgr:GetUIMovePointList(UIMapID, ScaleX)
    local Points = UE.TArray(UE.FVector2D)
    if self.CurrentFindPath then
        local MapID = _G.PWorldMgr:GetCurrMapResID()
        if UIMapID == MapUtil.GetUIMapID(MapID) then
            local Cfg = MapUICfg:FindCfgByKey(UIMapID)
            if Cfg then
                local MapScale = Cfg.Scale
                local MapOffsetX = Cfg.OffsetX
                local MapOffsetY = Cfg.OffsetY
                for i=1, #self.CurrentFindPath do
                    local Point = self.CurrentFindPath[i].point_data
                    local UIX, UIY = MapUtil.ConvertMapPos2UI(Point.X, Point.Y, MapOffsetX, MapOffsetY, MapScale, true)
                    local X, Y = MapUtil.AdjustMapMarkerPosition(ScaleX, UIX, UIY)
                    Points:Add(UE.FVector2D(X, Y))
                end
            end
        end
    end
    return Points
end

---获取传输速度(陆地行走)
function ChocoboTransportMgr:GetTransportSpeed()
    local RideResID = ChocoboTransportDefine.MOUNT_RES_ID
    if self.CurrentNpcID then
        local CfgItem = ChocoboTransMountCfg:FindCfgByKey(self.CurrentNpcID)
        if CfgItem then
            RideResID = CfgItem.RideResID
        end
    end
    local RideCfgItem = RideCfg:FindCfgByKey(RideResID)
    if RideCfgItem then
        return RideCfgItem.WalkSpeed
    end
    return 900
end

---获取陆行鸟开始动作ATL
function ChocoboTransportMgr:GetRideStartAction()
    local TimelineID = ChocoboTransportDefine.TIME_LINE_CHOCOBO_START
    if self.CurrentNpcID then
        local CfgItem = ChocoboTransMountCfg:FindCfgByKey(self.CurrentNpcID)
        if CfgItem then
            TimelineID = CfgItem.StartAction
        end
    end
    return TimelineID
end

---获取陆行鸟停止动作ATL
function ChocoboTransportMgr:GetRideStopAction()
    local TimelineID = ChocoboTransportDefine.TIME_LINE_CHOCOBO_LEAVE
    if self.CurrentNpcID then
        local CfgItem = ChocoboTransMountCfg:FindCfgByKey(self.CurrentNpcID)
        if CfgItem then
            TimelineID = CfgItem.StopAction
        end
    end
    return TimelineID
end

---获取坐骑召唤音效
function ChocoboTransportMgr:GetRideCallSound()
    if self.CurrentNpcID then
        local CfgItem = ChocoboTransMountCfg:FindCfgByKey(self.CurrentNpcID)
        if CfgItem then
            local RideResID = CfgItem.RideResID
            if RideResID ~= 0 then
                local RideCfgItem =RideCfg:FindCfgByKey(RideResID)
                if RideCfgItem then
                    return RideCfgItem.MountCallse
                end
            end
        end
    end
    return nil
end

--- @type 获取结束蒙太奇时间 Do not Need？
-- function ChocoboTransportMgr:GetMontageLength(TimelineID)
--     local PathCfg = ActiontimelinePathCfg:FindCfgByKey(TimelineID)
--     if PathCfg == nil then
--         FLOG_ERROR("ActiontimelinePathCfg = nil TimelineID = %s", TimelineID)
--         return ChocoboTransportDefine.LEAVE_ANIMATION_DURTION_TIME
--     end
--     local Major = MajorUtil.GetMajor()
--     if Major then
--         local AnimComp = Major:GetAnimationComponent()
--         local ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
--         local AnimMontage = _G.ObjectMgr:LoadObjectSync(ActionTimelinePath, ObjectGCType.LRU)
--         local NeedMontage = Major:CheckActionTimelineMontage(AnimMontage, "WholeBody", 0.25, 0.25, 99999)
--         if NeedMontage == nil then
--             return
--         end
--         local AnimTime = AnimationUtil.GetAnimMontageLength(NeedMontage)
--         if AnimTime > 0 then
--             FLOG_INFO("ChocoboTransportMgr End AimTime = %s", AnimTime)
--             return AnimTime + 0.2 -- 预留一点容错
--         end
--     end
--     return ChocoboTransportDefine.LEAVE_ANIMATION_DURTION_TIME
-- end

---使用加速技能
function ChocoboTransportMgr:DoAccelerationSkill()
    FLOG_INFO("ChocoboTransportMgr DoAccelerationSkill")
    if not self:GetIsCanUseSkill() then
        FLOG_INFO("ChocoboTransportMgr Can not UseSkill")
        return
    end

    local SkillID = ChocoboTransportDefine.DEFAULT_ACCELERATION_SKILL_ID
    if self.CurrentNpcID then
        local CfgItem = ChocoboTransMountCfg:FindCfgByKey(self.CurrentNpcID)
        if CfgItem then
            if CfgItem.AccelerationDuration > 0 then
                SkillID = CfgItem.AccelerationDuration
            end
        end
    end

	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local SkillCastType = SkillUtil.CastSkill(MajorEntityID, 0, SkillID)
    FLOG_INFO("ChocoboTransportMgr UseSkill Sucess, SkillCastType="..tostring(SkillCastType).." SkillID="..tostring(SkillID))
end

---提供给UI的下坐骑按钮处理
function ChocoboTransportMgr:DoGetDownMount()
    if not self:GetIsCanUseSkill() then
        return
    end
    self:CancelTrasport()
end

---获取自动移动的进度
---@return number@(0~1)
function ChocoboTransportMgr:GetMoveProgress()
    if self.CurrentFindPath then
		local Major = MajorUtil.GetMajor()
		if not Major then
			return 0
		end
		local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
		local CurrNum = UMoveSyncMgr:GetPathMovedPointsNum() + 1
		local MajorPos = Major:FGetActorLocation()
		local TotalLength = 0
		local MoveLength = 0
		for i=2, #self.CurrentFindPath do
			local LastPoint = self.CurrentFindPath[i-1].point_data
			local CurrPoint = self.CurrentFindPath[i].point_data
			local Distance = UE.FVector(LastPoint.X, LastPoint.Y, LastPoint.Z):Dist2D(UE.FVector(CurrPoint.X, CurrPoint.Y, CurrPoint.Z))
			TotalLength = TotalLength + Distance
			if CurrNum == i then
				local AlreayMove = UE.FVector(LastPoint.X, LastPoint.Y, LastPoint.Z):Dist2D(UE.FVector(MajorPos.X, MajorPos.Y, MajorPos.Z))
				MoveLength = MoveLength + AlreayMove
			elseif i < CurrNum then
				MoveLength = MoveLength + Distance
			end
		end
        if TotalLength == 0 then
			return 0
		end
		return MoveLength / TotalLength
	end
	return 0
end

---是否同一个地块
---@class Pos
---@field X number
---@field Y number
---@field Z number
---@param MapID number
---@param StartPos Pos
---@param EndPos Pos
function ChocoboTransportMgr:IsSameMapBlock(MapID, StartPos, EndPos)
	local CurrBlockID = _G.NavigationPathMgr:GetBlockID(MapID, StartPos)
	local TargetBlockID = _G.NavigationPathMgr:GetBlockID(MapID, EndPos)
	return CurrBlockID == TargetBlockID
end

--- @type 是否是任务陆行鸟范式
function ChocoboTransportMgr:IsQuestTransport()
    local CurrentNpcID = self.CurrentNpcID
    if not CurrentNpcID then
        return false
    end
    local Cfg = ChocoboTransMountCfg:FindCfgByKey(CurrentNpcID)
    if not Cfg then
        return false
    end

    return Cfg.IsQuest == 1
end

--- @type 当前地图是否是第一张运输地图
function ChocoboTransportMgr:IsFirstTransMap()
    local CurWorldID = _G.PWorldMgr:GetCurrMapResID()
    local ThroughMapIDList = self.QuestTransData.ThroughMapIDList
    if not ThroughMapIDList then -- 只有一张地图捏
        return true
    end

    return CurWorldID == ThroughMapIDList[1]
end

function ChocoboTransportMgr:IsTransMap()
    local CurWorldID = _G.PWorldMgr:GetCurrMapResID()
    local ThroughMapIDList = self.QuestTransData.ThroughMapIDList
    for i = 1, #ThroughMapIDList do
        local MapID = ThroughMapIDList[i]
        if MapID == CurWorldID then
           return true
        end
    end

    return false
end

--- @type 当前地图是否是最后一张运输地图
function ChocoboTransportMgr:IsLastTransMap()
    local CurWorldID = _G.PWorldMgr:GetCurrMapResID()
    local ThroughMapIDList = self.QuestTransData.ThroughMapIDList
    if not ThroughMapIDList then -- 只有一张地图捏
        return true
    end

    return CurWorldID == ThroughMapIDList[#ThroughMapIDList]
end

-- ==================================================
-- 外部系统接口 任务坐骑相关
-- ==================================================


-- ==================================================
-- 任务范式
-- ==================================================

---设置当前交互的NPC
---@param NpcID number
function ChocoboTransportMgr:SetCurrentInteractiveNpcID(NpcID)
    self.CurrentNpcID = NpcID
end

--- @type 清空任务运输数据
function ChocoboTransportMgr:ClearQuestTransData()
    self.QuestTransData = {}                    -- 重置
end  

---设置任务开始的MapID
---@param NpcID number
function ChocoboTransportMgr:SetQuestStartMapID(MapID)
    self.QuestTransData.StartMapID = MapID
end

--- @type 缓存运输起始点_路径等
function ChocoboTransportMgr:InitTransportBaseData(Params, GameID, QuestID)
    FLOG_INFO(" ChocoboTransportMgr:InitTransportBaseData")
    local QuestTransData = self.QuestTransData
    QuestTransData.TargetMapID = tonumber(Params[1])                                                    -- 陆地上跑用
    QuestTransData.TargetPointID = tonumber(Params[2])                                                  -- 陆地上跑用
    QuestTransData.IsShowLoading = tonumber(Params[3]) == 1                                             -- 是否生成Loading
    QuestTransData.GameID = GameID
    QuestTransData.QuestID = QuestID

    if Params[4] ~= nil then
        QuestTransData.ThroughMapIDList =  string.split(Params[4], "|")                               -- 需要通过的地图
        QuestTransData.RemainMapNum = #QuestTransData.ThroughMapIDList
        self:TableElemStringToNumber(QuestTransData.ThroughMapIDList)
    end
    
    if Params[5] ~= nil then
        QuestTransData.ThroughPathList = string.split(Params[5], "|")                                 -- 飞行路径
        self:TableElemStringToNumber(QuestTransData.ThroughPathList)
    end

    QuestTransData.PointLocList = self:ConstructPointIDList()                                             -- 陆地上跑用
end

--- @type 查询路过的地图路径
function ChocoboTransportMgr:ConstructPointIDList()
    local PointLocList = {}
    local QuestTransData = self.QuestTransData
    local TargetMap = QuestTransData.TargetMapID
    local QuestMapID = QuestTransData.StartMapID  -- 任务开始的MapID
    if QuestMapID == TargetMap then               -- 不跨地图
        local TargetPointID = QuestTransData.TargetPointID
        table.insert(PointLocList, TargetPointID)          -- 需要到达的目的点ID
        return PointLocList
    end

    local ThroughMapIDList = QuestTransData.ThroughMapIDList
    for i = 1, #ThroughMapIDList do
        local MapID = ThroughMapIDList[i]
        local NextMapID
        if i + 1 <= #ThroughMapIDList then
            NextMapID = ThroughMapIDList[i + 1]
        end
        if MapID and NextMapID then
            local TGCfgList = self.MapGapDict[MapID]
            for _, v in pairs(TGCfgList) do
                local TGCfg = v
                if TGCfg.DstMapID == TargetMap then    
                    table.insert(PointLocList, TGCfg.Position)   -- 需要到达的目的点
                    break
                end
            end
        end
    end

    local TargetPointID = QuestTransData.TargetPointID
    table.insert(PointLocList, TargetPointID)          -- 需要到达的目的点ID
    return PointLocList
end

--- @type 表中元素从string变为number
function ChocoboTransportMgr:TableElemStringToNumber(List)
    for i = 1, #List do
        List[i] = tonumber(List[i])
    end
end

--- @type 检测是否符合跨地图运输条件
function ChocoboTransportMgr:CheckCanContinueTrans()
    if not self:IsQuestTransport() then                      -- 只有任务范式有跨地图
        FLOG_INFO("ChocoboTransportMgr TryContinueBeginTrans Is not QuestTransport")
        return false
    end

    if not self.bTransOnLeaveWorld then                       -- 离开World的时候仍然是运输状态
        FLOG_INFO("ChocoboTransportMgr TryContinueBeginTrans self.bTransOnLeaveWorld = false")
        return false
    end

    local CurWorldID = _G.PWorldMgr:GetCurrMapResID()
    local Index = self:GetCurMapDataIndex()
    if Index == -1 then
        return false
    end
    local TransMapID  = self.QuestTransData.ThroughMapIDList[Index]
    if CurWorldID ~= TransMapID then                                    -- 当前World和要运输的World能对上
        FLOG_INFO("ChocoboTransportMgr TryContinueBeginTrans CurWorldID ~= TransMapID CurMapId = %s TransMapID = %s", CurWorldID, TransMapID)
        return false
    end

    return true
end

--- @type 跨地图后尝试继续开始运输
function ChocoboTransportMgr:TryContinueBeginTrans()
    if self:CheckCanContinueTrans() then
        self:QuestStartTrasport()           -- 继续运输
    elseif self.bTransOnLeaveWorld then     -- 如果离开World时候是运输状态     
        self:CancelTrasport()
    end
    self.bTransOnLeaveWorld = false
end

--- @type 开始任务范式运输
function ChocoboTransportMgr:QuestStartTrasport()
    local QuestTransData = self.QuestTransData
    if QuestTransData.QTEGameResult and QuestTransData.QTEGameResult == CHOCOBO_FEE_QTE_RESULT.SKIP then
        return
    end
    FLOG_INFO("ChocoboTransportMgr:QuestStartTrasport()")

    -- 清除上次请求tag，允许再次运输
    _G.ChocoboTransportMgr:ClearLastRequestInfo()

    if self:IsFlyMode() then
        -- 飞行运输
        self:PreStartFlyTransport()
		FLOG_INFO("ChocoboTransportMgr:QuestStartTrasport(), FlyMode")
        self:ReduceRemainMapNum()
    else
        self:PreStartTransport()
    end
end

--- @type 准备运输_拉请求路径等
function ChocoboTransportMgr:PreStartTransport()
    local PointLoc = self:GetCurMapTargetLoc()
    self:SendFindPath(_G.UE.FVector(PointLoc.X, PointLoc.Y, PointLoc.Z))
    self:SetOnFindPathParams(self, self.StartTransportBehavior)
end

--- @type 开始运输
function ChocoboTransportMgr:StartTransportBehavior()
    local PointLoc = self:GetCurMapTargetLoc()
    if PointLoc == nil then
        FLOG_WARNING("Do not find target location.")
        return
    end
    self:StartTransport(self.QuestTransData.StartMapID, 0, PointLoc.X, PointLoc.Y, PointLoc.Z, 0)
    --- 减少剩余需要穿过地图的数量
    self:ReduceRemainMapNum()
end

function ChocoboTransportMgr:SetOnFindPathParams(Caller, StartTransportCallBakc)
    self.OnFindPathParams.Caller = Caller
    self.OnFindPathParams.CallBack = StartTransportCallBakc
end

--- @type 减少剩余需要通过地图的数量
function ChocoboTransportMgr:ReduceRemainMapNum()
    local RemainMapNum = self.QuestTransData.RemainMapNum
    if RemainMapNum and RemainMapNum > 0 then
        self.QuestTransData.RemainMapNum = RemainMapNum - 1
        FLOG_INFO("_FUNCTION_ ChocoboTransportMgr:ReduceRemainMapNum() RemainMapNum = %s", RemainMapNum)
    end
end

--- @type 获取当前地图运输需要的数据
function ChocoboTransportMgr:GetCurMapDataIndex()
    local RemainMapNum = self.QuestTransData.RemainMapNum   -- 会变，在ReduceRemainMapNum中维护
    if not self.QuestTransData.ThroughMapIDList then
        return -1
    end
    local AllMapNum = #self.QuestTransData.ThroughMapIDList -- 只会初始化一次
    return AllMapNum - RemainMapNum + 1
end

--- @type 获取当前地图运输目标点位置
function ChocoboTransportMgr:GetCurMapTargetLoc()
    local CurMapIndex = self:GetCurMapDataIndex()
    if CurMapIndex == -1 then
        return
    end
    local PointLocList = self.QuestTransData.PointLocList
    if PointLocList == nil then
        FLOG_ERROR("ChocoboTransportMgr:PreStartTransport() PointLocList == nil")
        return
    end

    if type(PointLocList[CurMapIndex]) == "number" then
        local MapPoint = _G.MapEditDataMgr:GetMapPoint(PointLocList[CurMapIndex])
        if not MapPoint then
            FLOG_ERROR("MapPoint = NIL PoinID = %s", PointLocList[CurMapIndex])
            return
        end
        return MapPoint.Point
    end

    return PointLocList[CurMapIndex]    
end

--- @type 获取当前地图运输飞行路径
function ChocoboTransportMgr:GetCurMapFlyPath()
    local ThroughPathList = self.QuestTransData.ThroughPathList
    if ThroughPathList == nil then
        return
    end

    local CurMapDataIndex = self:GetCurMapDataIndex()
    if CurMapDataIndex == -1 then
        return
    end
    return ThroughPathList[CurMapDataIndex]  
end

-- ==================================================
-- 陆行鸟飞行运输 任务范式
-- ==================================================

--- @type 准备飞行
function ChocoboTransportMgr:PreStartFlyTransport()
    local NextPathID = self:GetCurMapFlyPath()
    if NextPathID == nil then
        FLOG_ERROR("Do not find Fly path  Check Data")
        return
    end
    self:FindFlyPath(NextPathID)
    
    local MapPoint = _G.MapEditDataMgr:GetPath(NextPathID)
    if MapPoint == nil then
        FLOG_ERROR("PathID is not Config ID = %d", NextPathID)
        return
    end
    local Points = MapPoint.Points
    local LastPoint = Points[#Points].Point
    -- local EndPos = _G.UE.FVector(LastPoint.X, LastPoint.Y, LastPoint.Z)
    self:StartTransport(self.QuestTransData.StartMapID, 0, LastPoint.X, LastPoint.Y, LastPoint.Z, 0, true)
end

--- @type 设置是否阻断Major输入_EnableInput_or_DiableInput
function ChocoboTransportMgr:SetMajorCanInput(bCanInput)
    local MajorController = MajorUtil.GetMajorController()
    if MajorController == nil then
        return
    end
    MajorController:SetMajorCanInput(bCanInput)
end

--- @type 因为传送强行打断飞行
function ChocoboTransportMgr:BreakFlyTransportImmed()
    self.TransportStatus = TransportStatus.None -- 飞行需要提前置为空
    self:OnInGround()
    FLOG_INFO("ChocoboTransportMgr:BreakFlyTransportImmed()")
end

--- @type 当终止飞行运输时相关表现处理
function ChocoboTransportMgr:OnBreakFlyTransport()
    self.TransportStatus = TransportStatus.None -- 飞行需要提前置为空
    if CommonUtil.GetPlatformName() == "Windows" then -- 防止按WASD持续飞行 手机端是无所谓的
        self:SetMajorCanInput(false) 
    end
    
    self.DiableTimer = self:RegisterTimer(self.EnterFalling, 0.1)
end

--- @type 停止输入让玩家Fall
function ChocoboTransportMgr:EnterFalling()
    self.DiableTimer = nil
    local MajorController = MajorUtil.GetMajorController()
    if MajorController == nil then
        return
    end
    local Major = MajorUtil.GetMajor()
    local CharacterMovement = Major.CharacterMovement
    if CharacterMovement then
        CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_Flying)
    end
    MajorController:MountFall()

    self.OnGroundTimer = self:RegisterTimer(self.OnInGround, 4) -- 保底，4s后必结束
end

--- @type 检测落地终止飞行运输以及相关表现处理
function ChocoboTransportMgr:CheckFlyTrasportOnGround()
    local Major = _G.UE.UActorManager:Get():GetMajor()
    if Major == nil then
        return
    end

    local IsOnGround = Major:IsOnGround()
    if IsOnGround then
        self:OnInGround()
    end
end

--- @type 当落地
function ChocoboTransportMgr:OnInGround()
    FLOG_INFO("ChocoboTransportMgr:OnInGround()")
    self:OnBreakTransport()
    _G.MountMgr:CancelForceCanFly()
    if CommonUtil.GetPlatformName() == "Windows" then -- 恢复
        self:SetMajorCanInput(true) 
    end

    if self.OnGroundTimer ~= nil then
        self:UnRegisterTimer(self.OnGroundTimer)
        self.OnGroundTimer = nil
    end
end

--- @type 获取飞行路径
function ChocoboTransportMgr:FindFlyPath(PathID)
    local Path = _G.MapEditDataMgr:GetPath(PathID)
    local Points = Path.Points
    self.CurrentFindPath = {}
    for i = 1, #Points do
        local PointData = {}
        local Elem = Points[i]
        local Point = Elem.Point
        PointData.point_data = Point
        PointData.point_type = NavmeshPointType.NAVPOINT_TYPE_OUT_WAYPOINT
        table.insert(self.CurrentFindPath, PointData)
    end
end

---QTE流水上报
---@param GameType number@1=结果、2=过程
---@param Result number@Type=2:1=投喂、2=跳过、3=飞行中断、4=陆行中断
---@param Arg1 number@任务ID
function ChocoboTransportMgr:ReportChocoboQTE(GameType, Result)
    local QuestTransData = self.QuestTransData
    if QuestTransData and QuestTransData.GameID and QuestTransData.QuestID then
        DataReportUtil.ReportData("ChocoboQTEFlow", true, false, true,
        "GameID", tostring(QuestTransData.GameID),
        "GameType", tostring(GameType),
        "Result", tostring(Result),
        "Arg1", tostring(QuestTransData.QuestID))
    end
end

-- ==================================================

-- ==================================================
-- GM
-- ==================================================
-- lua ChocoboTransportMgr:SetFly(1)
--- @type 把运输模式强行设置为飞行
function ChocoboTransportMgr:SetFly(FlyNum)
    self.bForceFly = FlyNum == 1
end

---设置任务npc查询开关
---@param Val boolean
function ChocoboTransportMgr:SetQuestNpcQueryEnable(Val)
    self.IsQuestNpcQueryEnable = Val
end

---设置显示辅助点开关
---@param Val boolean
function ChocoboTransportMgr:SetShowTransportPointEnable(Val)
    self.IsShowTransportPointEnable = Val
end

---登记鸟房（当前地图）
function ChocoboTransportMgr:BookChocoboStables()
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    self:SendChocoboTransferBook(MapID)
end

---设置步高开关
function ChocoboTransportMgr:SetStepHeightEnable(Val)
    self.IsSetStepHeightEnable = Val
end


return ChocoboTransportMgr
