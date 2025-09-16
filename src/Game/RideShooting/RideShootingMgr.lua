--
-- Author: sammrli
-- Date: 2023-8-18 15:14
-- Description: 空军装甲游戏管理
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewMgr = require("UI/UIViewMgr")

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local MathUtil = require("Utils/MathUtil")
local CommonUtil = require("Utils/CommonUtil")

local EObjCfg = require("TableCfg/EobjCfg")
--local GlobalCfg = require("TableCfg/GlobalCfg")
local RideShootingCfg = require("TableCfg/RideShootingCfg")
local RideShootingTargetTypeCfg = require("TableCfg/RideShootingTargetTypeCfg")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")

local GateMainVM = require("Game/Gate/View/VM/GateMainVM")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_GOLD_SAUSER_CMD
local UE = _G.UE

local VisionRange = 2000 --可见范围,20米

---@class RideShootingMgr : MgrBase
local RideShootingMgr = LuaClass(MgrBase)

function RideShootingMgr:OnInit()
end

function RideShootingMgr:OnBegin()
    self.InitCfg = false
    self.IsRunning = false
    self.IsGameOver = false -- 已经结算
    self.IsArrived = false -- 抵达终点
    self.Time = 0
    self.IsCheckUnfinishGame = true    --检查上一次未完成的游戏
    --UE.URideShootingMgr:Get().PlaySpeed = 4  --测试代码
end

function RideShootingMgr:OnRegisterNetMsg()
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_ADVENTURE, CS_ADVENTURE_CMD.CS_ADVENTURE_CMD_CHALLENGE_LOG, self.OnNetMsgChallengeLog)
end

function RideShootingMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
    self:RegisterGameEvent(EventID.RideShootingGameEnd, self.OnGameEventGameEnd)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.GoldSauserAirForceGameOver, self.OnGameEventGameOver)
end

function RideShootingMgr:OnRegisterTimer()
end

function RideShootingMgr:OnEnd()
end

function RideShootingMgr:OnShutdown()
end

function RideShootingMgr:RegisterTempNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER, SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATE, self.OnNetMsgGoldSauserUpdate)
    self:RegisterGameEvent(EventID.VisionShowMesh, self.OnGameEventVisionShowMesh)
    self:RegisterGameEvent(EventID.EnterMapFinish, self.OnGameEventEnterMapFinish)
end

function RideShootingMgr:UnRegisterTempNetMsg()
    self:UnRegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER, SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATE, self.OnNetMsgGoldSauserUpdate)
    self:UnRegisterGameEvent(EventID.VisionShowMesh, self.OnGameEventVisionShowMesh)
    self:UnRegisterGameEvent(EventID.EnterMapFinish, self.OnGameEventEnterMapFinish)
    self.NpcHadShowList = {}
    self.InRangeNpcList = {}
end

function RideShootingMgr:UpdateRidePath(TableStr)
    local DotList = load("return "..TableStr)()
    if DotList then
        local PortalLineResPath = "Blueprint'/Game/Assets/Effect/BluePrint/ClientPath/BP_ClientPath_1.BP_ClientPath_1_C'"
        local function LoadModelCallback()
            local ModelClass = _G.ObjectMgr:GetClass(PortalLineResPath)
            if (ModelClass == nil) then
                FLOG_ERROR("[RideShooting] ModelClass is nil")
                return
            end

            local Location = DotList[1]
            local PortalLineActor = CommonUtil.SpawnActor(ModelClass, UE.FVector(Location.X, Location.Y, Location.Z))
            if not PortalLineActor then
                FLOG_ERROR("[RideShooting] PortalLineActor is nil")
                return
            end

            for i=1, #DotList do
                local Point = DotList[i]
                if i==1 then
                    FLOG_INFO("[RideShooting] AddMultiLinePoint "..tostring(Point.X)..","..tostring(Point.Y))
                end
                PortalLineActor:AddMultiLinePoint(UE.FVector(Point.X, Point.Y, Point.Z))
            end

            local PortalLineMaterialResPath = "MaterialInstanceConstant'/Game/Assets/bgcommon/world/common/vfx_for_bg/material/MI_Cube_JinDie.MI_Cube_JinDie'"
            local function LoadMaterialCallback()
                local MaterialObject = _G.ObjectMgr:GetObject(PortalLineMaterialResPath)
                if not MaterialObject then
                    FLOG_ERROR("[RideShooting] MaterialObject is nil")
                    return
                end

                if not PortalLineActor or not CommonUtil.IsObjectValid(PortalLineActor) then
                    FLOG_WARNING("[RideShooting] PortalLineActor is nil or not valid")
                    return
                end

                local MaterialInstance = MaterialObject:Cast(UE.UMaterialInstance)
                if MaterialInstance then
                    PortalLineActor.MI_PortalLine = MaterialInstance
                else
                    FLOG_ERROR("[RideShooting] MaterialInstance is nil")
                end

                FLOG_INFO("[RideShooting] Load Material Success ")
                PortalLineActor:ReCalculateLine()
            end

            _G.ObjectMgr:LoadObjectAsync(PortalLineMaterialResPath, LoadMaterialCallback)
        end

        _G.ObjectMgr:LoadClassAsync(PortalLineResPath, LoadModelCallback)
    else
        FLOG_ERROR("[RideShooting] load table error")
    end
end

function RideShootingMgr:PlayEndingAnimation()
    local Delay = 3.5
    self:RegisterTimer(self.OnCameraStartMove, Delay)
    self:RegisterTimer(self.OnAirStartMove, Delay + 0.2)
    self:RegisterTimer(self.OnAirPlayAnimation, Delay + 2.6)
end

---@是否空军装甲副本
---@return boolean
function RideShootingMgr:IsRideShootingDungeon()
    local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local RideShootingIDTable = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_AIR_FORCE_ONE_SCENE_ID, "Value")
    if not RideShootingIDTable then
        FLOG_ERROR("Global Cfg Is Nil, ID: GAME_CFG_AIR_FORCE_ONE_SCENE_ID")
        return false
    end
    if table.contain(RideShootingIDTable, PWorldResID) then
        return true
    end
    return false
end

function RideShootingMgr:OnAlreadyEnd()
    if self.IsRunning then
        --主动退出副本
        _G.PWorldMgr:SendLeavePWorld()
    end
end

function RideShootingMgr:OnGameStart()
    local UMajor = MajorUtil.GetMajor()
    UMajor:SwitchFly(true)

    local CharacterMovement = UMajor.CharacterMovement
    CharacterMovement:SetMovementMode(0)

    --关闭位置同步
    local UMoveSyncMgr = UE.UMoveSyncMgr:Get()
    UMoveSyncMgr:EndModule()

    local AvatarComponent = UMajor:GetAvatarComponent()
    if AvatarComponent then
        AvatarComponent:SetAvatarHiddenInGame(0, true, false, false)
    end

    local EventParams = _G.EventMgr:GetEventParams()
	EventParams.IntParam1 = 0
	_G.EventMgr:SendCppEvent(EventID.RideShootingGameStart, EventParams)
end

function RideShootingMgr:OnGameEventEnterWorld()
    local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local EventParams = _G.EventMgr:GetEventParams()
    if self:IsRideShootingDungeon() then -- 如果是空军副本
        if self.IsArrived then -- 如果已经抵达了，不再重新开始
            _G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
            CommonUtil.DisableShowJoyStick(true) --关闭摇杆显示
            CommonUtil.HideJoyStick()
            _G.HUDMgr:SetIsDrawHUD(false) --关闭HUD
            return
        end
        _G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
        local GateMainView = UIViewMgr:FindView(UIViewID.GoldSauserMainPanel)
        if GateMainView then
            GateMainView:OnShow()
        else
            UIViewMgr:ShowView(UIViewID.GoldSauserMainPanel)
        end
        local ObjectMgr = _G.ObjectMgr
        -- 预加载临时处理,需要eobj预加载统一处理
        local function OnCreateActor(LoadResPath)
            local ModelClass = _G.ObjectMgr:GetClass(LoadResPath)
            if ModelClass then
                CommonUtil.SpawnActor(ModelClass, UE.FVector(1000000, 0, 1000000))
            end
        end

        local AllTargetTypeCfg = RideShootingTargetTypeCfg:FindAllCfg()
        if AllTargetTypeCfg then
            for i=1,#AllTargetTypeCfg do
                local EObjCfgItem = EObjCfg:FindCfgByKey(AllTargetTypeCfg[i].EOBJ)
                if EObjCfgItem then
                    local ResPath = string.sub(EObjCfgItem.BPPath, 1, -2).."_C'"
                    local function LoadSuccess()
                        OnCreateActor(ResPath)
                    end
                    ObjectMgr:LoadClassAsync(ResPath, LoadSuccess, UE.EObjectGC.Cache_Map)
                end
            end
        end
        --for i=1, 4 do
        --    local ResPath = string.format("Blueprint'/Game/Assets/bg/ffxiv/wil_w1/shared/for_bg/sgbg_w1ei_a0_gmc0%d_sg2.sgbg_w1ei_a0_gmc0%d_sg2_C'", i , i)
        --    _G.ObjectMgr:LoadClassAsync(ResPath, LoadSuccess)
        --end
	    EventParams.BoolParam1 = true
        --路线
        local PlanID = 1
        local AllCfg = RideShootingCfg:FindAllCfg()
        for _,Cfg in pairs(AllCfg) do
            if PWorldResID ==  Cfg.DungeonID then
                PlanID = Cfg.Scheduler
                break
            end
        end
        EventParams.IntParam1 = PlanID

        self.IsRunning = true
        self.IsGameOver = false
        self.IsArrived = false

        CommonUtil.DisableShowJoyStick(true) --关闭摇杆显示
        CommonUtil.HideJoyStick()

        _G.HUDMgr:SetIsDrawHUD(false) --关闭HUD

        self.IsCheckUnfinishGame = false
        _G.GoldSauserMgr:SendUpdateScoreReq(0) --重置历史分数

        self:UnRegisterTempNetMsg()
        self:RegisterTempNetMsg()
        _G.GoldSauserMgr:SendUpdateGame() --断线重连的时候检查下当前的游戏状态

        _G.EventMgr:SendCppEvent(EventID.RideShootingGameInit, EventParams)
        _G.EventMgr:SendEvent(EventID.RideShootingWorldStart)

        self:UnRegisterAllTimer()
        self:RegisterTimer(self.OnTimeGCHandle, 10, 0.2, -1)
    end

    if self.IsCheckUnfinishGame then
        FLOG_INFO("[RideShooting] OnGameEventEnterWorld Start CheckUnfinishGame")
        self.IsCheckUnfinishGame = false
        local RoleID = MajorUtil.GetMajorRoleID()
        local StrContent = _G.ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.RideShootingLastRecord)
        if not string.isnilorempty(StrContent) then
            local SplitList = string.split(StrContent, "|")
            local Round = tonumber(SplitList[1]) or 0
            local Score = tonumber(SplitList[2]) or 0
            if Round > 0 and Score > 0 then
                --上次游戏未完成，重发游戏结束请求
                _G.GoldSauserMgr:ResendEndGameReq(Round, Score)

                --重置历史分数
                _G.GoldSauserMgr:SendUpdateScoreReq(0)
            end
        end
    end
end

function RideShootingMgr:OnGameEventExitWorld()
    if self.IsRunning then
        CommonUtil.DisableShowJoyStick(false) --恢复摇杆显示
        _G.HUDMgr:SetIsDrawHUD(true) --恢复HUD
        local UMajor = MajorUtil.GetMajor()
        if UMajor then
            UMajor:SwitchFly(false)
            local RideComponent = UMajor:GetRideComponent()
            RideComponent:UnUseRide(false)
        end
        self:UnRegisterTempNetMsg()
        self:UnRegisterAllTimer()

        _G.EventMgr:SendEvent(EventID.RideShootingWorldEnd)
    end
    self.IsRunning = false
    self.IsGameOver = false
    self.IsArrived = false
end

function RideShootingMgr:OnGameEventGameEnd(Params)
    --local Location = UE.FVector(Params.FloatParam1, Params.FloatParam2, Params.FloatParam3)
    --local Rotator = UE.FRotator(Params.IntParam1, Params.IntParam2, Params.IntParam3)
    --local UMajor = MajorUtil.GetMajor()
    --UMajor:K2_SetActorLocation(Location, false, nil, false)
    --UMajor:K2_SetActorRotation(Rotator, false)
    self.IsArrived = true

    if self.IsGameOver then
        return
    end

    --上报结算，玩家的状态是报名了，才结算，如果自己手动点击结束了，那么状态会更新，不发送
    if (_G.GoldSauserMgr.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp) then
        _G.LootMgr:SetDealyState(true)
        _G.GoldSauserMgr:EndGame(true)
    end

    --清理剩余npc
    for EntityID, Param in pairs(self.NpcHadShowList) do
        --销毁
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor and CommonUtil.IsObjectValid(Actor) then
            --清理动画
            local AnimComp = Actor:GetAnimationComponent()
            if AnimComp then
                AnimComp:ClearResidentAnimAssets()
            end
            --清理mesh
            Actor:SetVisionLoadMeshState(5)
            Actor:VisionReleaseMesh()
            CommonUtil.DestroyActor(Actor)
        end
    end
    _G.ObjectMgr:CollectGarbage(true, false)
end

function RideShootingMgr:OnGameEventGameOver()
    _G.GoldSauserMgr:SendUpdateScoreReq(0) --重置历史分数
    self.IsGameOver = true
end


function RideShootingMgr:OnGameEventVisionShowMesh(EventParams)
    local EntityID = EventParams.ULongParam1
    if not self.NpcHadShowList[EntityID] then
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor then
            local Location = Actor:FGetActorLocation()
            self.NpcHadShowList[EntityID] = {X = Location.X, Y = Location.Y, Z = Location.Z}
            --移交管理权,不再受视野管理
            UE.UVisionMgr.Get():RemoveFromVision(Actor)
        end
    end
end

function RideShootingMgr:OnGameEventEnterMapFinish()
    if self:IsRideShootingDungeon() then
        CommonUtil.DisableShowJoyStick(true)
    end
end

function RideShootingMgr:OnTimeGCHandle()
    local Major = MajorUtil.GetMajor()
    if not Major then
        return
    end

    local MajorPos = Major:FGetActorLocation()

    for EntityID, Param in pairs(self.InRangeNpcList) do
        if MathUtil.Dist(MajorPos, Param) > VisionRange then
            --销毁
            local Actor = ActorUtil.GetActorByEntityID(EntityID)
            if Actor and CommonUtil.IsObjectValid(Actor) then
                --清理动画
                local AnimComp = Actor:GetAnimationComponent()
                if AnimComp then
                    AnimComp:ClearResidentAnimAssets()
                end
                --清理mesh
                Actor:SetVisionLoadMeshState(5)
                Actor:VisionReleaseMesh()
                CommonUtil.DestroyActor(Actor)
            end
            self.InRangeNpcList[EntityID] = nil
        end
    end

    for EntityID, Param in pairs(self.NpcHadShowList) do
        if MathUtil.Dist(MajorPos, Param) <= VisionRange then
            self.InRangeNpcList[EntityID] = Param
            self.NpcHadShowList[EntityID] = nil
        end
    end

    --GC
    self.Time = self.Time + 1
    if math.fmod(self.Time, 50) == 0 then
        _G.ObjectMgr:CollectGarbage(true, false)
    end
end

function RideShootingMgr:OnGameEventLoginRes(Params)
    if not CommonUtil.IsShipping() then
        FLOG_INFO(string.format("[RideShooting] OnGameEventLoginRes bReconnect=%s IsGameOver=%s IsArrived=%s",
        tostring(Params.bReconnect), tostring(self.IsGameOver), tostring(self.IsArrived)))
    end
    if Params.bReconnect then
        if self.IsGameOver then
            -- 已经结算过了,直接退出
            _G.PWorldMgr:SendLeavePWorld()
            return
        end
        if self.IsArrived then
            _G.LootMgr:SetDealyState(true)
            _G.GoldSauserMgr:EndGame(true)
        else
            -- 重新开始游戏
            self:OnGameEventEnterWorld()
        end
    end
end

function RideShootingMgr:OnCameraStartMove()
    _G.EventMgr:SendEvent(EventID.RideShootingPlayCameraAnimation)
    UE.URideShootingMgr:Get():PlayResultAnimation("LevelSequence'/Game/Assets/Cut/ffxiv_m/gldwil/gldwil00010/gldwil00010.gldwil00010'")
end

function RideShootingMgr:OnAirStartMove()
    local UMajor = MajorUtil.GetMajor()
    if UMajor then
        local RideComponent = UMajor:GetRideComponent()
        if RideComponent then
            RideComponent:UseRide(156)
        end
        local AvatarComponent = UMajor:GetAvatarComponent()
        if AvatarComponent then
            AvatarComponent:SetAvatarHiddenInGame(0, false, false, false)
            _G.EventMgr:SendEvent(EventID.RideShootingShowAllAvatarPart)
        end

        --[[
        local AnimComp = UMajor:GetAnimationComponent()
        if AnimComp then
            PathCfg = ActiontimelinePathCfg:FindCfgByKey(16)
            ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
            AnimComp:PlayAnimation(ActionTimelinePath, 1.0, 0.25, 0.25, true, UE.EAvatarPartType.RIDE_MASTER)
        end
        ]]
    end
end

function RideShootingMgr:OnAirPlayAnimation()
    local UMajor = MajorUtil.GetMajor()
    if UMajor then
        local AnimComp = UMajor:GetAnimationComponent()
        if AnimComp then
            local ATLID = self:GetATLID()
            local PathCfg = ActiontimelinePathCfg:FindCfgByKey(ATLID)
            local ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
            AnimComp:PlayAnimationCallBack(ActionTimelinePath)

            --PathCfg = ActiontimelinePathCfg:FindCfgByKey(16)
            --ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
            --AnimComp:PlayAnimation(ActionTimelinePath, 1.0, 0.25, 0.25, true, UE.EAvatarPartType.RIDE_MASTER)
        end
    end
end

function RideShootingMgr:OnNetMsgGoldSauserUpdate(MsgBody)
    if nil == MsgBody then
        return
    end

    local Data = MsgBody.Update

    local Entertain = Data.Entertain
    if nil == Entertain  then
        return
    end

    if Entertain.ID ~= ProtoRes.Game.GameID.GameIDAirForceOne then
        FLOG_WARNING("[RideShootingMgr] game error gameID="..tostring(Entertain.ID))
        _G.PWorldMgr:SendLeavePWorld()
        UIViewMgr:HideView(UIViewID.GoldSauserMainPanel)
        return
    end

    if Data.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_NotSignUp then
        FLOG_WARNING("[RideShootingMgr] game status error Player="..tostring(Data.Player))
        _G.PWorldMgr:SendLeavePWorld()
        UIViewMgr:HideView(UIViewID.GoldSauserMainPanel)
        return
    end

    if not self.IsGameOver and Data.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_End then
        if (Data.RewardRecord ~= nil and Data.RewardRecord.FinishTime > 0) then
            -- 如果有奖励那么会去走奖励显示相关的
            local ServerTimeNow = TimeUtil.GetServerTimeMS()
            local TimeSpan = ServerTimeNow - Data.RewardRecord.FinishTime * 1000
            if (TimeSpan < _G.GoldSauserMgr.RewardShowTimeLimit) then
                return
            end
        end
        FLOG_WARNING("[RideShootingMgr] game status error Player="..tostring(Data.Player))
        _G.PWorldMgr:SendLeavePWorld()
        UIViewMgr:HideView(UIViewID.GoldSauserMainPanel)
        return
    end

    if Entertain.State == ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_End then
        FLOG_WARNING("[RideShootingMgr] game status error State="..tostring(Entertain.State))
        _G.PWorldMgr:SendLeavePWorld()
        UIViewMgr:HideView(UIViewID.GoldSauserMainPanel)
    end
end

function RideShootingMgr:GetATLID()
    local Score = GateMainVM:GetScore()
    local Scores = GoldSauserDefine.AirForceConfig.Scores
    local ATLs = GoldSauserDefine.AirForceConfig.ATLs

    local Grade = 1
    for i=1,#Scores do
        if Score >= Scores[i] then
            Grade = i
        else
            break
        end
    end
    return ATLs[Grade]
end

return RideShootingMgr