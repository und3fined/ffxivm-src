--
-- Author: zerodeng
-- Date: 2024-5-29
-- Description:自动寻路实施
--
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local ActorUtil = require("Utils/ActorUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local NavigationPathMgr = require("Game/PWorld/Navigation/NavigationPathMgr")
local NavigationConfigCfg = require("TableCfg/NavigationConfigCfg")
local MajorUtil = require("Utils/MajorUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local EffectUtil = require("Utils/EffectUtil")
local MathUtil = require("Utils/MathUtil")

local NavigationConfigType = ProtoRes.navigation_config_type

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING

local CS_CMD = ProtoCS.CS_CMD
local CS_AUTO_FINDPATH_CMD = ProtoCS.CS_AUTO_FINDPATH_CMD

--移动过程中，播放的特效
local MOVE_EFFECT_PATH = "VfxBlueprint'/Game/Assets/Effect/Particles/Sence/LeaderLine/VBP_LeaderLine2.VBP_LeaderLine2_C'"

--传送地图后，位置离寻路表中的距离阈值
local ENTERMAP_MIN_DIFF_DISTANCE = 5000

--被自动寻路管理器调用
local AutoPathMoveImpl = {}

-----------------------对外接口begin------------------
function AutoPathMoveImpl:IsAutoPathMovingByMap(DstMapID, DstPos)
    if (self.IsAutoPathMoving == nil or not self.IsAutoPathMoving) then
        return false
    end

    return self.DstMapID == DstMapID and self.Equal(self.DstPos, DstPos)
end

function AutoPathMoveImpl:IsAutoPathMovingState()
    if (self.IsAutoPathMoving == nil or not self.IsAutoPathMoving) then
        return false
    end

    return true
end

--从水晶位置到目标的服务器路点数据
function AutoPathMoveImpl:GetCrystalPointList(CrystalID, DstPos)
    local Key = string.format("%d-(%d,%d,%d)", CrystalID, 
    math.ceil(DstPos.X), 
    math.ceil(DstPos.Y),
    math.ceil(DstPos.Z))

    return self.CacheCrystalPointList[Key]    
end

-----------------------对外接口end------------------

function AutoPathMoveImpl.Equal(Pos1, Pos2)
    return Pos1.X == Pos2.X and Pos1.Y == Pos2.Y and Pos1.Z == Pos2.Z
end

function AutoPathMoveImpl:OnInit(AutoPathMoveMgr)
    self.AutoPathMoveMgr = AutoPathMoveMgr
    self.IsAutoPathMoving = false
    self.ExecMoveData = nil
    self.DstMapID = nil
    self.DstPos = nil    
    self.TargetType = nil

    self.FromMapID = 0
    self.ToMapID = 0
    self.TransPos = nil
    self.MoveType = nil
    self.IsSimulateMoving = false
    self.IsDstPosRejust = false
    self.NPCPos = nil
    self.InteractionRange = nil

    self.FindPathSeqID = 0

    self.EndPositionOffset = 10

    self.CacheCrystalPointList = {}

    self.TLogData = nil
    self.StopForReconnect = false

    self.AutoPathUseMountMinDist = 5000         
    self.ResumeAutoPathMoveTimer = nil 
    self.CheckMoveStaticTimer = nil

    self.MoveStaticTime = 3
    self.LastMajorPos = {X=0, Y=0, Z=0}

    self.StartListenSkillEnd = false
    self.CurrentSkillID = 0   
end

function AutoPathMoveImpl:OnBegin()
    --寻路终点偏移距离cm
    local cfg = NavigationConfigCfg:FindCfgByKey(NavigationConfigType.AUTOPATH_REJUST_DIST)
    if (cfg ~= nil) then
        self.EndPositionOffset = cfg.Value        
    end

    cfg = NavigationConfigCfg:FindCfgByKey(NavigationConfigType.AUTOPATH_USE_MOUNT_MIN_DIST)
    if (cfg ~= nil) then
        self.AutoPathUseMountMinDist = cfg.Value        
    end

    cfg = NavigationConfigCfg:FindCfgByKey(NavigationConfigType.MOVE_STATIC_TIME)
    if (cfg ~= nil) then
        --转换为秒
        self.MoveStaticTime = cfg.Value / 1000.0        
    end
    
    FLOG_INFO("AutoPathMoveImpl: EndPositionOffset=%d, AutoPathUseMountMinDist=%d", self.EndPositionOffset, self.AutoPathUseMountMinDist)
end

function AutoPathMoveImpl:OnShutdown()
    self.AutoPathMoveMgr = nil
    self.IsAutoPathMoving = false
    self.ExecMoveData = nil
    self.DstMapID = nil
    self.DstPos = nil    
    self.CacheCrystalPointList = nil
    self.NPCPos = nil
    self.InteractionRange = nil
    self.TargetType = nil
    self.TLogData = nil
    self.StopForReconnect = false
end

function AutoPathMoveImpl:RegisterGameNetMsg(AutoPathMoveMgr)
    FLOG_INFO("AutoPathMoveImpl: RegisterGameNetMsg")

    AutoPathMoveMgr:RegisterGameNetMsg(
        CS_CMD.CS_CMD_NAVMESH,
        0,
        function(_, MsgBody)
            self:OnFindPathNotify(MsgBody)
        end
    )

    AutoPathMoveMgr:RegisterGameNetMsg(
        CS_CMD.CS_CMD_AUTOFINDPATH,
        CS_AUTO_FINDPATH_CMD.CS_AUTO_FINDPATH_CMD_START,
        function(_, MsgBody)
            self:OnAutoPathMoveStartRsp(MsgBody)
        end
    )
end

function AutoPathMoveImpl:RegisterGameEvent(AutoPathMoveMgr)
    AutoPathMoveMgr:RegisterGameEvent(
        EventID.PWorldMapEnter,
        function(_, Params)
            self:OnPWorldMapEnter(Params)
        end
    )
    AutoPathMoveMgr:RegisterGameEvent(
        EventID.PWorldMapExit,
        function(_)
            self:OnPWorldMapExit()
        end
    )
    
    AutoPathMoveMgr:RegisterGameEvent(
        EventID.PWorldTransBegin,
        function(_, IsOnlyChangeLocation)
            self:OnPWorldTransBegin(IsOnlyChangeLocation)
        end
    )
    AutoPathMoveMgr:RegisterGameEvent(
        EventID.PreCrystalTransferReq,
        function(_)
            self:OnPreCrystalTransferReq()
        end
    )
    AutoPathMoveMgr:RegisterGameEvent(
        EventID.EnterInteractive,
        function(_)
            self:OnEnterInteractive()
        end
    )
    --[[
    AutoPathMoveMgr:RegisterGameEvent(
        EventID.StateChange,
        function(_, Params, _)
            self:OnStateChange(Params)
        end
    )
    ]]

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.MajorSingBarOver,
        function(_, EntityID, IsBreak)
            self:OnMajorSingBarOver(EntityID, IsBreak)
        end
    )

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.MajorSingBarBegin,
        function(_, EntityID, SingStateID)
            self:OnMajorSingBarBegin(EntityID, SingStateID)
        end
    )


    AutoPathMoveMgr:RegisterGameEvent(
        EventID.MajorDead,
        function(_)
            self:OnGameEventMajorDead()
        end
    )

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.ComBatStateUpdate, 
        function(_, Params)
            self:OnEventControlStateChange(Params)
        end
    )

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.RoleLoginRes, 
        function(_, Params)
            self:OnEventRoleLoginRes(Params)
        end
    )

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.NetworkReconnectStart, 
        function(_, Params)
            self:OnEventNetworkReconnectStart(Params)
        end
    )

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.MajorProfSwitch, 
        function(_, Params)
            self:OnEventMajorProfSwitch(Params)
        end
    )    

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.AutoPathServerPull, 
        function(_, Params)
            self:OnEventServerPull(Params)
        end
    )    

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.SkillEnd, 
        function(_, Params)
            self:OnEventSkillEnd(Params)
        end
    )   

    AutoPathMoveMgr:RegisterGameEvent(
        EventID.BeginPlaySequence, 
        function(_, Params)
            self:OnEventBeginPlaySequence(Params)
        end
    )  
end

--发送开始自动寻路协议
function AutoPathMoveImpl:SendAutoPathMoveStart()
    local AutoFindPathReq = {}
    local MsgBody = {}
    local SubMsgID = CS_AUTO_FINDPATH_CMD.CS_AUTO_FINDPATH_CMD_START
    MsgBody.Cmd = SubMsgID
    MsgBody.Start  = AutoFindPathReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_AUTOFINDPATH, SubMsgID, MsgBody)    
end

function AutoPathMoveImpl:SendAutoPathMoveStop()
    local StopAutoFindPathReq = {}
    local MsgBody = {}
    local SubMsgID = CS_AUTO_FINDPATH_CMD.CS_AUTO_FINDPATH_CMD_STOP
    MsgBody.Cmd = SubMsgID
    MsgBody.Stop  = StopAutoFindPathReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_AUTOFINDPATH, SubMsgID, MsgBody)    
end

function AutoPathMoveImpl:OnAutoPathMoveStartRsp(MsgBody)
    local StartAutoFindPathRsp = MsgBody.Start
    if (StartAutoFindPathRsp == nil) then
        FLOG_ERROR("AutoPathMoveImpl: start rsp network data error")
        return
    end

    if (StartAutoFindPathRsp.ret == 0) then
        FLOG_INFO("AutoPathMoveImpl: start rsp success, buff add!")
    else
        -- body
        FLOG_ERROR("AutoPathMoveImpl: start rsp success, buff not add!")
    end
end

--启动
function AutoPathMoveImpl:Start(ExecMoveData, DstMapID, DstPos, InTargetType, TLogData)
    if (self.IsAutoPathMoving) then
        --寻路中，中断当前的
        self:Stop()
    end

    FLOG_INFO("AutoPathMoveImpl:AutoPathMove is Start!--------------")

    self.IsAutoPathMoving = true
    self.ExecMoveData = ExecMoveData
    self.DstMapID = DstMapID
    self.DstPos = DstPos    
    self.TargetType = InTargetType
    self.TLogData = TLogData
    self.StopForReconnect = false

    self.StartListenSkillEnd = false
    self.CurrentSkillID = 0    

    --UI显示：寻路中...
    local Params = {IsAutoPathMove = true, TargetType = InTargetType}

    UIViewMgr:HideView(UIViewID.AutoPathMoveTips)
    UIViewMgr:ShowView(UIViewID.AutoPathMoveTips, Params)

    --add by sammrli:lua侧传参
    local EventParam = {MapID = DstMapID, Pos = DstPos, TargetType = InTargetType}

    --发送开始事件
    _G.EventMgr:SendCppEvent(EventID.StartAutoPathMove)
    _G.EventMgr:SendEvent(EventID.StartAutoPathMove, EventParam)

    --通知服务器开始
    self:SendAutoPathMoveStart()

    --播放角色开始特效
    self:PlayMajorMoveEffect()

    --中断锁定跑步
    _G.UE.UActorManager.Get():SetVirtualJoystickIsSprintLocked(false)

    --获取第一个数据，运行
    self:NotifyOneAutoMoveOver()
end

--中断
function AutoPathMoveImpl:Stop(IsSuccessStop)
    FLOG_INFO("AutoPathMoveImpl:AutoPathMove is Stop!----------------")
    if (not self.IsAutoPathMoving) then
        FLOG_WARNING("AutoPathMoveImpl:Stop call more!----------------")
        return
    end

    --通知服务器结束
    self:SendAutoPathMoveStop()

    --播放结束特效
    self:StopMajorMoveEffect()

    if (self.MoveType == self.AutoPathMoveMgr.EMoveType.Point) then
        --清理回调
        local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
        UMoveSyncMgr.OnSimulateMoveFinish:Clear()

        if (self.IsSimulateMoving) then
            UMoveSyncMgr:StopPathMove(_G.UE.ESimulateMoveStop.Break)
        end
    end

    local TLogResult = 0
    --抵达终点
    if (IsSuccessStop ~= nil and IsSuccessStop) then
        --_G.MsgTipsUtil.ShowTips(LSTR(1590003))

        TLogResult = 1
    end

    --cancel timer
    self:CancelNetworkRsqTimer()
    self:CancelNotifyMoveOverTimer()
    self:CancelCheckMoveStaticTimer()

    self.IsAutoPathMoving = false
    self.DstMapID = nil
    self.DstPos = nil
    self.StartListenSkillEnd = false
    self.CurrentSkillID = 0
    self.ExecMoveData = nil
    self:ClearAutoMoveData()

    --TLog发送
    if (self.TLogData ~= nil) then
        local SrcPosStr = string.format("(%s,%s,%s)", 
            tostring(self.TLogData.SrcPos.X), 
            tostring(self.TLogData.SrcPos.Y), 
            tostring(self.TLogData.SrcPos.Z))
        local DstPosStr = string.format("(%s,%s,%s)", 
            tostring(self.TLogData.DstPos.X), 
            tostring(self.TLogData.DstPos.Y), 
            tostring(self.TLogData.DstPos.Z))

        DataReportUtil.ReportData("AutomaticFlow", true, false, true,
        "RequestTargetType", tostring(self.TargetType),
        "InitiateArg1", tostring(self.TLogData.SrcMapID),
        "InitiateArg2", SrcPosStr,
        "InitiateArg3", tostring(self.TLogData.DstMapID),
        "InitiateArg4", DstPosStr,
        "Result", tostring(TLogResult))

        FLOG_INFO("AutoPathMoveImpl: Send TLog Success!")
    end

    --隐藏UI
    UIViewMgr:HideView(UIViewID.AutoPathMoveTips)

    --发送结束事件
    _G.EventMgr:SendCppEvent(EventID.StopAutoPathMove)
    _G.EventMgr:SendEvent(EventID.StopAutoPathMove)
end


function AutoPathMoveImpl:NotifyOneAutoMoveOver()
    if (not self.IsAutoPathMoving) then
        FLOG_WARNING("AutoPathMoveImpl: AutoPathMoving is false")
        return
    end

    self:CancelNotifyMoveOverTimer()
    self:CancelCheckMoveStaticTimer()

    --正常结束
    if (#self.ExecMoveData == 0) then
        self:Stop(true)
        return
    end

    --获取下一个数据，运行
    self:ClearAutoMoveData()

    local MoveData = table.clone(self.ExecMoveData[1])
    table.remove(self.ExecMoveData, 1)

    self:RunAutoMoveData(MoveData)
end

function AutoPathMoveImpl:ClearAutoMoveData()
    self.FromMapID = 0
    self.ToMapID = 0
    self.TransPos = nil
    self.MoveType = nil
    self.IsSimulateMoving = false
    self.NPCPos = nil
    self.InteractionRange = nil

    self.FindPathSeqID = 0
    self.FindPathDstPos = nil
end

function AutoPathMoveImpl:RunAutoMoveData(MoveData)
    self.MoveType = MoveData.Type

    FLOG_INFO("AutoPathMoveImpl: RunAutoMoveData type:%d--------------", MoveData.Type)

    if (MoveData.Type == self.AutoPathMoveMgr.EMoveType.Crystal) then
        self:RunCrystalMoveData(MoveData.Data)
    elseif (MoveData.Type == self.AutoPathMoveMgr.EMoveType.Point) then
        self:RunPointMoveData(MoveData.Data)
    elseif (MoveData.Type == self.AutoPathMoveMgr.EMoveType.TransEdge) then
        self:RunTransEdgeMoveData(MoveData.Data)
    elseif (MoveData.Type == self.AutoPathMoveMgr.EMoveType.Actor) then
        self:RunActorMoveData(MoveData.Data)
    end
end

--水晶传送
function AutoPathMoveImpl:RunCrystalMoveData(CrystalData)    
    --0,传送
    local CrystalID = CrystalData.CrystalID
    self.FromMapID = CrystalData.FromMapID
    self.ToMapID = CrystalData.ToMapID
    self.TransPos = CrystalData.TransPos

    FLOG_INFO("AutoPathMoveImpl: RunCrystalMoveData CrystalID=%d", CrystalID)

    local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
    local Success = CrystalMgr:TransferByMap(CrystalID)
    if (Success == nil) then
        --失败，传送中断
        FLOG_ERROR("AutoPathMoveImpl Crystal transition failed! id:%d", CrystalID)

        self:Stop()        
        return
    end
end

--目标点移动
function AutoPathMoveImpl:RunPointMoveData(PointData)
    local MapID = PointData.MapID

    --出生点以当前主角所在点（传送地图后，生成点会在随机范围）
    local Major = MajorUtil.GetMajor()
    if Major == nil then        
        self:Stop()
        FLOG_ERROR("AutoPathMoveImpl Major is nil!")
        return
    end

    local UEStartPos = Major:FGetActorLocation()
    local UEEndPos = _G.UE.FVector(PointData.DstPos.X, PointData.DstPos.Y, PointData.DstPos.Z)

    local CurrMapID =  _G.PWorldMgr:GetCurrMapResID()
    local RejustMapID = NavigationPathMgr:RejustDynamicMap(CurrMapID)

    --存在动态地图
    if (RejustMapID ~= MapID) then
        FLOG_ERROR("AutoPathMoveImpl Run other map:%d points move,curmapid=%d", MapID, CurrMapID)
        self:Stop()
        return
    end

    self.IsDstPosRejust = PointData.IsDstPosRejust
    self.StartCrystalID = PointData.StartCrystalID
    self.NPCPos = PointData.NPCPos
    self.InteractionRange = PointData.InteractionRange

    --服务器请求路点
    local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
    self.FindPathSeqID = UMoveSyncMgr:FindPath(UEStartPos, UEEndPos)
    self.FindPathDstPos = PointData.DstPos

    --监听回包,3秒未收到回包，终止寻路
    self:CancelNetworkRsqTimer()
    self.ReqNetworkTimer = _G.TimerMgr:AddTimer(self, self.CheckNetworkRsq, 3, 0, 1)
end

--NPC,EOBJ传送
function AutoPathMoveImpl:RunActorMoveData(ActorData)
    --传送NPC处理
    FLOG_INFO("AutoPathMoveImpl NPC/EOBJ transform ResID:%d, InteractiveID=%d", ActorData.ActorResID,ActorData.InteractiveID)

    if (not self:InteravtiveTransition(ActorData.ActorResID, ActorData.InteractiveID)) then
        self:Stop()
        return
    end

    --传送地图，地图，位置需要记录
    self.FromMapID = ActorData.FromMapID
    self.ToMapID = ActorData.ToMapID
    self.TransPos = ActorData.TransPos

    --监听回包,20秒未收到回包，终止寻路
    self:CancelNetworkRsqTimer()
    self.ReqNetworkTimer = _G.TimerMgr:AddTimer(self, self.CheckNetworkRsq, 10, 0, 1)
end

function AutoPathMoveImpl:InteravtiveTransition(ActorID, InteractiveID)
    local EntityID = ActorUtil.GetActorEntityIDByResID(ActorID)

    _G.InteractiveMgr:SendInteractiveStartReq(InteractiveID, EntityID)

    return true
end

--传送带传送
function AutoPathMoveImpl:RunTransEdgeMoveData(TransEdgeData)
    --记录地图信息，由上一步走进去触发传送
    self.FromMapID = TransEdgeData.FromMapID
    self.ToMapID = TransEdgeData.ToMapID
    self.TransPos = TransEdgeData.DstPos
end

--检查网络回包
function AutoPathMoveImpl:CheckNetworkRsq(Params)
    --没有收到回包
    FLOG_ERROR("AutoPathMoveImpl CheckNetworkRsq call: no rsq data!")
    self:CancelNetworkRsqTimer()

    if (Params ~= nil and Params.CrystalTrans ~= nil) then
        --水晶传送没有回包
        _G.MsgTipsUtil.ShowTipsByID(107012)
    end

    self:Stop()
end

function AutoPathMoveImpl:CancelNetworkRsqTimer()
    if (self.ReqNetworkTimer ~= nil) then
        _G.TimerMgr:CancelTimer(self.ReqNetworkTimer)
        self.ReqNetworkTimer = nil
    end
end

function AutoPathMoveImpl:CancelNotifyMoveOverTimer()
    if (self.DelayNotifyMoveOverTimer ~= nil) then
        _G.TimerMgr:CancelTimer(self.DelayNotifyMoveOverTimer)
        self.DelayNotifyMoveOverTimer = nil
    end    
end

--进入地图
function AutoPathMoveImpl:OnPWorldMapEnter(MapData, IsOnlyChangeLocation)
    --非自动寻路，不处理
    if (not self.IsAutoPathMoving) then
        return
    end

    local Major = _G.UE.UActorManager:Get():GetMajor()
    if Major == nil then
        return
    end

    if (MapData ~= nil and MapData.bReconnect) then
        --这里应该闪断情况，传送过程中发生重连。LoginRes事件没有被触发,直接退出寻路，如果重新发起寻路，是传送水晶的话，会出现异常
        FLOG_INFO("AutoPathMoveImpl reconnect!")
        self:Stop()            
        return
    end

    local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
    local LastMapID = _G.PWorldMgr:GetLastMapResID()

    if (self.FromMapID == 0 or self.ToMapID == 0) then
        FLOG_ERROR("AutoPathMoveImpl not autopath call trans map!")
        self:Stop()
        
        --切换到私人副本
        local DynamicCurrMapID = NavigationPathMgr:RejustDynamicMap(CurrMapID)
        local DynamicLastMapID = NavigationPathMgr:RejustDynamicMap(LastMapID)

        if (DynamicCurrMapID == DynamicLastMapID) then
            --同地图传送，继续寻路
            FLOG_INFO("AutoPathMoveImpl: same map transform!")
            self:ResumeAutoPathMove()
        end

        return
    end

    --跨地图寻路，再次发送请求，添加加速buff（buff跨地图会删除）
    self:SendAutoPathMoveStart()

    --取消监听
    self:CancelNetworkRsqTimer()

    if (self.FromMapID == self.ToMapID) then
        --同地图传送
        LastMapID = _G.PWorldMgr:GetLastTransMapResID()
    end
    
    local MajorPos = Major:FGetActorLocation()

    FLOG_INFO("AutoPathMoveImpl OnPWorldMapEnter() call! CurrMapID:%d, LastMapID:%d", CurrMapID, LastMapID)
    local NeedPlayRunningEffect = (CurrMapID ~= LastMapID)

    local RejustCurrMapID = NavigationPathMgr:RejustDynamicMap(CurrMapID)
    local RejustLastMapID = NavigationPathMgr:RejustDynamicMap(LastMapID)

    if (self.FromMapID == RejustLastMapID and self.ToMapID == RejustCurrMapID) then
        --set 0
        self.FromMapID = 0
        self.ToMapID = 0

        local UETransPos = _G.UE.FVector(self.TransPos.X, self.TransPos.Y, self.TransPos.Z)
        
        local Distance = _G.UE.FVector.Dist(UETransPos, MajorPos)
        if (Distance < ENTERMAP_MIN_DIFF_DISTANCE) then
            --水晶传送门会有多个点
            self.DelayNotifyMoveOverTimer = _G.TimerMgr:AddTimer(self, self.NotifyOneAutoMoveOver, 2, 1, 1)
        else
            FLOG_ERROR("AutoPathMoveImpl OnPWorldMapEnter() distance is too long,%s", tostring(Distance))
            self:Stop()

            NeedPlayRunningEffect = false
        end
    else
        FLOG_ERROR("AutoPathMoveImpl OnPWorldMapEnter() frommap or tomap is not equal!")
        self:Stop()

        NeedPlayRunningEffect = false
    end

    --切换地图完成，播放特效
    if (NeedPlayRunningEffect) then
        --非同地图传送
        self:PlayMajorMoveEffect()    
    end    
end

function AutoPathMoveImpl:OnPWorldMapExit()
    --非自动寻路，不处理
    if (not self.IsAutoPathMoving or self.MoveType == nil) then
        return
    end

    local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
    FLOG_INFO("AutoPathMoveImpl OnPWorldMapExit() call! CurrMapID:%d", CurrMapID)

    --取消超时等待（NPC,EOBJ,水晶切换地图）
    if (self.MoveType == self.AutoPathMoveMgr.EMoveType.Actor 
        or self.MoveType == self.AutoPathMoveMgr.EMoveType.Crystal) then
        self:CancelNetworkRsqTimer()
    end    

    --移动过程中,进入传送带
    local NextMoveData = self.ExecMoveData[1]
    if (self.MoveType == self.AutoPathMoveMgr.EMoveType.Point) then
        if (NextMoveData ~= nil and NextMoveData.Type == self.AutoPathMoveMgr.EMoveType.TransEdge) then
            _G.UE.UMoveSyncMgr:Get().OnSimulateMoveFinish:Clear()

            --执行下一个
            self:NotifyOneAutoMoveOver()
        end
    end
end


function AutoPathMoveImpl:OnPWorldTransBegin(IsOnlyChangeLocation)
    --同地图水晶传送，离的很近的时候会触发
    if (IsOnlyChangeLocation) then
        local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
        FLOG_INFO("AutoPathMoveImpl OnPWorldTransBegin() call! CurrMapID:%d", CurrMapID)

        self:OnPWorldMapEnter(nil, IsOnlyChangeLocation)
    end
end

--路径回包
function AutoPathMoveImpl:OnFindPathNotify(MsgBody)
    --非自动寻路，不处理
    if (not self.IsAutoPathMoving) then
        return
    end

    local FindPathRsp = MsgBody
    if not FindPathRsp then
        return
    end

    if (self.FindPathSeqID ~= FindPathRsp.id) then
        return
    end

    --删除检查器
    self:CancelNetworkRsqTimer()

    local PointNum = #FindPathRsp.NavPoints
    if PointNum <= 1 then
        _G.MsgTipsUtil.ShowTipsByID(40192)

        FLOG_ERROR("AutoPathMoveImpl OnFindPathNotify Error Points Num:%d", PointNum)
        self:Stop()
        return
    end

    FLOG_INFO("AutoPathMoveImpl OnFindPathNotify Seq:%d, pointNum:%d", FindPathRsp.id, PointNum)

    --show
    local PointList = NavigationPathMgr:ConvertFindPathRsp(FindPathRsp)
    --NavigationPathMgr:ShowFindPath(PointList)
    
    --缓存路点数据
    if (self.StartCrystalID ~= nil and self.StartCrystalID > 0) then
        local Key = string.format("%d-(%d,%d,%d)", self.StartCrystalID, 
            math.ceil(self.FindPathDstPos.X), 
            math.ceil(self.FindPathDstPos.Y),
            math.ceil(self.FindPathDstPos.Z))

        self.CacheCrystalPointList[Key] = PointList
    end

    --终点是否一致（Z轴除外）    
    FLOG_INFO("AutoPathMoveImpl OnFindPathNotify ClientDstPos:%s, ServerDstPos:%s", 
        table.tostring(self.FindPathDstPos), table.tostring(PointList[PointNum]))
    
    --优化终点（终点偏移）
    self:RejustEndPoint(PointList)

    --路径优化
    self:RejustNPCEndPos(PointList)

    --获取路径长度
    local PathDistance = self:GetDistanceForPointList(PointList)

    local PosTable = _G.UE.TArray(_G.UE.FVector)
    for i = 1, #PointList do        
        PosTable:Add(PointList[i])
    end

    local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
    local Speed = UMoveSyncMgr:GetSelfMaxWalkSpeed()

    UMoveSyncMgr:StartPathMove(PosTable, Speed)
    self.IsSimulateMoving = true

    --注册回调
    UMoveSyncMgr.OnSimulateMoveFinish:Clear()
    UMoveSyncMgr.OnSimulateMoveFinish:Add(
        UMoveSyncMgr,
        function(_, SeqID, StopType)
            self:MoveFinishCallback(StopType, SeqID)
        end
    )

    --启动静止检测
    self:StartCheckMoveStatic()

    --发送自动移动开始事件
    _G.EventMgr:SendCppEvent(EventID.StartAutoMoving)
    _G.EventMgr:SendEvent(EventID.StartAutoMoving)

    --是否使用坐骑    
    local ShouldUseMount = PathDistance > self.AutoPathUseMountMinDist
    FLOG_INFO("AutoPathMoveImpl OnFindPathNotify ShouldUseMount=%s, PathDistance=%s", tostring(ShouldUseMount), tostring(PathDistance))

    --技能使用中
    if (ShouldUseMount) then        
        if MajorUtil.IsUsingSkill() then
            --监听技能释放完
            self.CurrentSkillID = _G.SkillObjectMgr:GetOrCreateEntityData(MajorUtil.GetMajorEntityID()).CurrentSkillObject.CurrentSkillID
            self.StartListenSkillEnd = true            
        else
            --直接使用坐骑
            FLOG_INFO("AutoPathMoveImpl: not using skill, use mount")
            _G.EventMgr:SendEvent(EventID.UseMount)
        end
    end
end

function AutoPathMoveImpl:OnEventSkillEnd(Params)
    if ((not self.IsAutoPathMoving) or (not self.StartListenSkillEnd)) then
        return
    end

    local SkillID = Params.IntParam2
	local EntityID = Params.ULongParam1

    local MajorEntityID = MajorUtil.GetMajorEntityID()

    if (self.CurrentSkillID == SkillID and EntityID == MajorEntityID) then
        FLOG_INFO("AutoPathMoveImpl: receive skillend event")
        self.StartListenSkillEnd = false
        self.CurrentSkillID = 0

        --延后一帧处理，因为接口MajorUtil.IsUsingSkill()下一帧才会返回false
        local function callback()
            if (not self.IsAutoPathMoving) then
                return
            end            
            FLOG_INFO("AutoPathMoveImpl: delay one frame to use mount")

            _G.EventMgr:SendEvent(EventID.UseMount) 
        end

        _G.TimerMgr:AddTimer(nil, callback, 0.01, 0, 1)        
    end    
end


function AutoPathMoveImpl:RejustEndPoint(PointList)
    if (self.IsDstPosRejust == nil or not self.IsDstPosRejust) then
        FLOG_INFO("AutoPathMoveImpl not set rejust target pos!")
        return
    end

    local PointNum = #PointList

    if (PointNum < 2) then
        FLOG_INFO("AutoPathMoveImpl:RejustEndPoint point num < 2")
        return
    end

    local UEEndPoint = PointList[PointNum]
    local UEPreEndPoint = PointList[PointNum - 1]

    local Distance = _G.UE.FVector.Dist(UEEndPoint, UEPreEndPoint)
    if (Distance <= self.EndPositionOffset) then
        FLOG_WARNING("AutoPathMoveImpl PreEndPos=%s and EndPos=%s too near", table.tostring(UEPreEndPoint), table.tostring(UEEndPoint))    

        table.remove(PointList, PointNum)        
        return
    end

    --路径上取点，指定终点偏移量
    local Dir = UEPreEndPoint - UEEndPoint
    _G.UE.FVector.Normalize(Dir)
    local AimPoint = UEEndPoint + Dir * self.EndPositionOffset

    PointList[PointNum] = AimPoint

    FLOG_INFO("AutoPathMoveImpl EndPos=%s, NewEndPos=%s", table.tostring(UEEndPoint), table.tostring(AimPoint))
end

--NPC目标点优化
function AutoPathMoveImpl:RejustNPCEndPos(PointList)
    if (self.NPCPos == nil or self.InteractionRange == nil) then
        return
    end

    local PointNum = #PointList

    if (PointNum < 2) then
        FLOG_WARNING("AutoPathMoveImpl:RejustNPCEndPos point num < 2")
        return
    end

    --从终点回溯，找到最远可交互点
    while true do
        PointNum = #PointList
        if (PointNum <= 2) then
            break
        end

        local Distance = _G.UE.FVector.Dist(PointList[PointNum-1], self.NPCPos)
        if (Distance <= self.InteractionRange) then
            --符合要求，后一个点可删除
            table.remove(PointList, PointNum)
        else
            break
        end
    end
end

--计算原点到终点距离
function AutoPathMoveImpl:GetDistanceForPointList(PointList)
    local PointNum = #PointList

    if (PointNum < 2) then
        FLOG_WARNING("AutoPathMoveImpl:PointList point num < 2") 
        return 0
    end

    local RetDistance = 0
    for i = 1, PointNum - 1 do
        local Pos1 = PointList[i]
        local Pos2 = PointList[i + 1]
        local Distance = _G.UE.FVector.Dist(Pos1, Pos2)

        RetDistance = RetDistance + Distance        
    end

    return RetDistance
end

function AutoPathMoveImpl:MoveFinishCallback(StopType, SeqID)
    local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
    UMoveSyncMgr.OnSimulateMoveFinish:Clear()
    self.IsSimulateMoving = false

    FLOG_INFO("AutoPathMoveImpl MoveStop StopType:%s", tostring(StopType))

    if (StopType == _G.UE.ESimulateMoveStop.Finished) then
        --达到目的地
        --强制同步当前位置
        MajorUtil.SyncSelfMoveReq(true)

        self:NotifyOneAutoMoveOver()
    else
        --中断寻路:可恢复中断
        self:Stop()
    end

    --可恢复中断（摇杆，技能等）
    if (StopType == _G.UE.ESimulateMoveStop.Buffer) then
        --UI显示：倒计时...
        local Params = {ResumeMove = true, ShowTime = 4}
        UIViewMgr:ShowView(UIViewID.AutoPathMoveTips, Params)
    end

    --发送自动移动结束事件
    _G.EventMgr:SendCppEvent(EventID.StopAutoMoving)
    _G.EventMgr:SendEvent(EventID.StopAutoMoving)
end

--传送水晶过程被打断
function AutoPathMoveImpl:OnMajorSingBarOver(EntityID, IsBreak)
    if (not self.IsAutoPathMoving) then
        return
    end

    if (self.MoveType == self.AutoPathMoveMgr.EMoveType.Crystal) then
        if (IsBreak) then
            FLOG_INFO("AutoPathMoveImpl singbar break stop!")

            --主动打断寻路
            self:Stop()
        else
            --读条结束，重新计时，监听回包
            local Params = {CrystalTrans = true}
            self:CancelNetworkRsqTimer()
            self.ReqNetworkTimer = _G.TimerMgr:AddTimer(self, self.CheckNetworkRsq, 5, 0, 1, Params)    
        end
    end
end

function AutoPathMoveImpl:OnMajorSingBarBegin(EntityID, SingStateID)
    if (not self.IsAutoPathMoving) then
        return
    end

    --读条开始，取消读条计时，读条结束后重新监听
    if (self.MoveType == self.AutoPathMoveMgr.EMoveType.Crystal) then                
        self:CancelNetworkRsqTimer()           
    end
end

--死亡
function AutoPathMoveImpl:OnGameEventMajorDead()
    if MajorUtil.IsMajorDead() and self.IsAutoPathMoving then
        FLOG_INFO("AutoPathMoveImpl Major Dead break stop!")

        --主动打断寻路
        self:Stop()        
    end
end

-------中断寻路----------
--传送水晶开启
function AutoPathMoveImpl:OnPreCrystalTransferReq()
    if (not self.IsAutoPathMoving) then
        return
    end

    --自动寻路发起的，忽略
    if (self.MoveType == self.AutoPathMoveMgr.EMoveType.Crystal) then
        --监听回包,5秒未收到回包，终止寻路。这里发送水晶传送包后，如果需要读条，那么会触发EventID.MajorSingBarBegin事件，重新计时
        local Params = {CrystalTrans = true}
        self:CancelNetworkRsqTimer()
        self.ReqNetworkTimer = _G.TimerMgr:AddTimer(self, self.CheckNetworkRsq, 5, 0, 1, Params)   

        return
    end

    FLOG_INFO("AutoPathMoveImpl self UI break stop!")

    --主动打断寻路
    self:Stop()
end

--点击交互
function AutoPathMoveImpl:OnEnterInteractive()
    if (not self.IsAutoPathMoving) then
        return
    end

    FLOG_INFO("AutoPathMoveImpl EnterInteractive break stop!")

    --主动打断寻路
    self:Stop()
end

function AutoPathMoveImpl:OnEventControlStateChange(Params)
    if (not self.IsAutoPathMoving) then
        return
    end

    if not MajorUtil.IsMajor(Params.ULongParam1) then
        return
    end    

    local majorStatComp = MajorUtil.GetMajor():GetStateComponent()
    local CanMove = majorStatComp:GetActorControlState(_G.UE.EActorControllStat.CanMove)    

    --FLOG_INFO("AutoPathMoveImpl major ControlStateChange call! canmove=%s, CanAllowMove=%s", tostring(CanMove), tostring(CanAllowMove))

    --不可移动，中断
    if not CanMove then
        FLOG_INFO("AutoPathMoveImpl major control state change: can't move!")

        self:Stop()
    end    
end

function AutoPathMoveImpl:OnEventRoleLoginRes(Params)
    if (Params.bReconnect) then
        --断线重连
        if self.StopForReconnect then        
            --弹出重连框，客户端已经中断寻路，需要发送删除加速buff协议

            self:SendAutoPathMoveStop()
            self.StopForReconnect = false
        elseif (self.IsAutoPathMoving) then
            --闪断情况，重新发起寻路  
            FLOG_INFO("AutoPathMoveImpl: OnEventRoleLoginRes") 
            self:Stop()

            self:ResumeAutoPathMove()
        end         
    else
        --登录成功，发送删除加速buff协议，处理上次直接杀进程退出游戏情况
        self:SendAutoPathMoveStop()
    end
end

--重新发起寻路
function AutoPathMoveImpl:ResumeAutoPathMove()
    --延迟一帧
    local function callback()
        FLOG_INFO("AutoPathMoveImpl: ResumeAutoPathMove")
        self.ResumeAutoPathMoveTimer = nil

        _G.AutoPathMoveMgr:ResumeAutoPathMove()
    end

    if (self.ResumeAutoPathMoveTimer ~= nil) then
        _G.TimerMgr:CancelTimer(self.ResumeAutoPathMoveTimer)
        self.ResumeAutoPathMoveTimer = nil
    end

    self.ResumeAutoPathMoveTimer = _G.TimerMgr:AddTimer(nil, callback, 1, 0, 1)
end


--自身特效播放
function AutoPathMoveImpl:PlayMajorMoveEffect()
    FLOG_INFO("AutoPathMoveImpl PlayMajorMoveEffect call!")
    
    --如果主角未创建，不播放
    local Major = MajorUtil.GetMajor()
    if (Major == nil) then
        FLOG_INFO("AutoPathMoveImpl PlayMajorMoveEffect: major not create!")
        return
    end

    local VfxParameter = _G.UE.FVfxParameter()    
    VfxParameter.VfxRequireData.EffectPath = MOVE_EFFECT_PATH
    VfxParameter.VfxRequireData.bAlwaysSpawn = true
    --VfxParameter.VfxRequireData.VfxTransform = Major:GetTransform()
    VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_AetherCurrents
    local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
    VfxParameter:SetCaster(Major, 0, AttachPointType_Body, 0)
    self.EffectID = EffectUtil.PlayVfx(VfxParameter)
end

function AutoPathMoveImpl:StopMajorMoveEffect()
    FLOG_INFO("AutoPathMoveImpl StopMajorMoveEffect call!")
    if (self.EffectID ~= nil) then
        EffectUtil.KickTriggerByID(self.EffectID, 1)            
    end    
end

function AutoPathMoveImpl:OnEventNetworkReconnectStart(Params)
    --断线重连开始-弹框出现-中断寻路
    if (self.IsAutoPathMoving) then     
        self.StopForReconnect = true
        FLOG_INFO("AutoPathMoveImpl NetworkReconnect break stop!")
        self:Stop()
    end
end

function AutoPathMoveImpl:OnEventMajorProfSwitch(Params)
    --切换职业的时候，角色身上buff会删除，需要重新发协议给服务器，加上buff
    if (self.IsAutoPathMoving) then
        self:SendAutoPathMoveStart()
    end
end

function AutoPathMoveImpl:OnEventServerPull(Params)    
    --寻路时出现拉扯
    if (self.IsAutoPathMoving) then
        FLOG_INFO("AutoPathMoveImpl: OnEventServerPull") 
        self:Stop()

        self:ResumeAutoPathMove() 
    end    
end

--卡住检测
function AutoPathMoveImpl:StartCheckMoveStatic()    
    local function callback()
        if (not self.IsAutoPathMoving) then
            self:CancelCheckMoveStaticTimer()
            return
        end
        local Major = MajorUtil.GetMajor()
        if (Major == nil) then
            self:CancelCheckMoveStaticTimer()
            FLOG_ERROR("AutoPathMoveImpl_StartCheckMoveStatic major is nil!")
            return
        end        

        local CurMajorPos = Major:FGetActorLocation()
        local Dist = MathUtil.Dist(self.LastMajorPos, CurMajorPos)

        if Dist < 50 then --3秒移动半米内,认为被阻挡
            self:CancelCheckMoveStaticTimer()

            FLOG_INFO("AutoPathMoveImpl: static move above 3 second!") 
            self:Stop()
            _G.MsgTipsUtil.ShowTipsByID(40196)
        else
            self.LastMajorPos = CurMajorPos
        end
    end

    self.LastMajorPos = _G.UE.FVector(0,0,0)    
    
    --间隔3秒不断执行
    self:CancelCheckMoveStaticTimer()
    self.CheckMoveStaticTimer = _G.TimerMgr:AddTimer(nil, callback, 0.5, self.MoveStaticTime, 0)
end

function AutoPathMoveImpl:CancelCheckMoveStaticTimer()
    if (self.CheckMoveStaticTimer ~= nil) then
        _G.TimerMgr:CancelTimer(self.CheckMoveStaticTimer)
        self.CheckMoveStaticTimer = nil
    end
end

function AutoPathMoveImpl:OnEventBeginPlaySequence(Params)
    --进场景开始播放过场
    if (not self.IsAutoPathMoving) then
        return
    end

    FLOG_INFO("AutoPathMoveImpl: play sequence!")

    self:Stop()
end

return AutoPathMoveImpl


