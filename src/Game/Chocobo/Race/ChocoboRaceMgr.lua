--
-- Author: lightpaw_yuhang
-- Date: 2023-10-16 16:57:14
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ProtoRes = require("Protocol/ProtoRes")
local BuddyEquipCfg = require("TableCfg/BuddyEquipCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local CommonUtil = require("Utils/CommonUtil")
local ChocoboRaceRacer = require("Game/Chocobo/Race/ChocoboRaceRacer")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ChocoboActiontimelineCfg = require("TableCfg/ChocoboActiontimelineCfg")
local RaceCfg = require("TableCfg/RaceCfg")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local PWorldCfg = require("TableCfg/PworldCfg")
local BusinessUIMgr = require("UI/BusinessUIMgr")
local ChocoboRaceUtil = require("Game/Chocobo/Race/ChocoboRaceUtil")
local ChocoboRaceVfxCfg = require("TableCfg/ChocoboRaceVfxCfg")
local EffectUtil = require("Utils/EffectUtil")
local ChocoboRaceSkillCfg = require("TableCfg/ChocoboRaceSkillCfg")
local ChocoboRaceStatusCfg = require("TableCfg/ChocoboRaceStatusCfg")
local AudioUtil = require("Utils/AudioUtil")

local GameNetworkMgr = nil
local TeamMgr = nil
local MsgTipsUtil = nil
local LSTR = nil
local ChocoboRaceMainVM = nil
local UIViewMgr = nil
local UIViewID = nil
local EventMgr = nil
local HUDMgr = nil
local PWorldMgr = nil
local RoleInfoMgr = nil
local SUB_MSG_ID = ProtoCS.ChocoboRaceCmd
local CS_CMD_CHOCOBO_RACE = ProtoCS.CS_CMD.CS_CMD_CHOCOBO_RACE

local FrameInterval = 0.2 --200ms一帧

---@class ChocoboRaceMgr : MgrBase
local ChocoboRaceMgr = LuaClass(MgrBase)

function ChocoboRaceMgr:OnInit()
    self.GameRaceID = 0 -- 防止出现异常的时候玩家同时在2场比赛中，通过raceID来丢掉一部分包
    self.GoTime = 0
    self.IsClientReady  = false
    self.IsServerReady   = false
    self.IsCreatePipeline = false
    self.IsCreateInput = false
    self.MajorIndex = 0
    self.CurFrameID = 0
    self.LevelSequenceAniLength = 3
    self.ChocoboRacerData = {}
    self.ChocoboRacer = {}
    self.RaceUpdateParams = {}
    self.VisionCacheAvatar = {}
    self.AfterCutsceneRacer = {}

    self.PendingEntities = {}          -- 需要组装的实体ID集合
    self.IsJoinRequestSent = false     -- 是否已发送加入请求
    self.IsPWorldReady = false
    self.AssembleTimeoutTimer = nil    -- 超时计时器句柄

    self.MaxRacerNum = ProtoCS.ChocoboRaceConst.ChocoboRaceConstRacerNum
    self.GameState = ChocoboDefine.GAME_STATE_ENUM.NONE
    self.RaceStatus = ProtoCS.ChocoboRaceStatus.ChocoboRaceStatusNone
end

function ChocoboRaceMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    TeamMgr = _G.TeamMgr
    MsgTipsUtil = _G.MsgTipsUtil
    LSTR = _G.LSTR
    ChocoboRaceMainVM = _G.ChocoboRaceMainVM
    UIViewMgr = _G.UIViewMgr
    UIViewID = _G.UIViewID
    EventMgr = _G.EventMgr
    HUDMgr = _G.HUDMgr
    PWorldMgr = _G.PWorldMgr
    RoleInfoMgr = _G.RoleInfoMgr

    _G.UE.FTickHelper.GetInst():SetTickIntervalByFrame(self.TickTimerID, 10)
    _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
end

function ChocoboRaceMgr:OnEnd()
end

function ChocoboRaceMgr:OnShutdown()
    self.GameRaceID = 0
    self.GoTime = 0
    self.IsClientReady  = false
    self.IsServerReady   = false
    self.IsCreatePipeline = false
    self.IsCreateInput = false
    self.MajorIndex = 0
    self.CurFrameID = 0
    self.LevelSequenceAniLength = 3
    self.ChocoboRacerData = {}
    self.ChocoboRacer = {}
    self.RaceUpdateParams = {}
    self.VisionCacheAvatar = {}
    self.AfterCutsceneRacer = {}

    self.PendingEntities = {}
    self.IsJoinRequestSent = false
    self.IsPWorldReady = false
    self.AssembleTimeoutTimer = nil

    if self.ChocoboCamera ~= nil then
        CommonUtil.DestroyActor(self.ChocoboCamera)
        self.ChocoboCamera = nil
    end
    
    self.MaxRacerNum = ProtoCS.ChocoboRaceConst.ChocoboRaceConstRacerNum
    self.GameState = ChocoboDefine.GAME_STATE_ENUM.NONE
    self.RaceStatus = ProtoCS.ChocoboRaceStatus.ChocoboRaceStatusNone
end

---OnTick
---暂定每10帧Tick一次，只会在指定副本中才会开启Tick
---用于管理比赛中角色状态和特效
---@param DeltaTime
function ChocoboRaceMgr.OnTick(DeltaTime)
    local _ <close> = CommonUtil.MakeProfileTag("ChocoboRaceMgr.Lua.OnTick")
    _G.ChocoboRaceMgr:Update(DeltaTime)
end

function ChocoboRaceMgr:Update(DeltaTime)
    if not self:IsChocoboRacePWorld() then
        return
    end
    
    self:UpdateCountDown()
    self:UpdateProgress(DeltaTime)
    self:TickResultSequence()
end

function ChocoboRaceMgr:UpdateCountDown()
    if self.GoTime <= 0 then
        return
    end

    if self:GetGameState() >= ChocoboDefine.GAME_STATE_ENUM.BEGIN then
        return
    end

    local CurrentTime = TimeUtil.GetServerTime()
    ChocoboRaceUtil.Log("UpdateCountDown LeftTime :" .. (CurrentTime - self.GoTime))
    if self.GoTime <= CurrentTime then
        self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.BEGIN) -- 这里是唯一正常流程进入Begin的地方
    end
end

function ChocoboRaceMgr:UpdateProgress()
    if self.ChocoboRacer == nil or self.RaceUpdateParams == nil then
        return
    end

    for __, Data in pairs(self.RaceUpdateParams) do
        local Index = Data.Index

        --更新Racer
        local Racer = self:GetRacerByIndex(Index)
        if Racer then
            Racer:UpdateData(Data)
            Racer:Update()
            Data.Progress = Racer:GetRacerProgress()
        end
    end
end

function ChocoboRaceMgr:ResetRace()
    ChocoboRaceMainVM:Clear()

    for __, Racer in pairs(self.ChocoboRacer) do
        Racer:Reset()
    end

    self.IsClientReady  = false
    self.IsServerReady   = false
    self.GameRaceID = 0
    self.GoTime = 0
    self.CurFrameID = 0
    self.MajorIndex = 0
    self.ChocoboRacer = {}
    self.ChocoboRacerData = {}
    self.RaceUpdateParams = {}
    self.VisionCacheAvatar = {}

    self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.NONE)
    _G.UE.UChocoboRaceMgr.Get():SetEnableTick(false)
    _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
end

function ChocoboRaceMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceAllUserIn, self.OnNetMsgRaceAllUserIn)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdQuery, self.OnNetMsgRaceQuery)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdJoin, self.OnNetMsgRaceJoin)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdReady, self.OnNetMsgRaceReady)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdCtrl, self.OnNetMsgRaceCtrl)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdPickup, self.OnNetMsgRacePickup)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdUpdate, self.OnNetMsgRaceUpdate)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdResult, self.OnNetMsgRaceResult)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdQueryProgress, self.OnNetMsgRaceProgress)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceReward, self.OnNetMsgRaceReward)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceQueryResult, self.OnNetMsgRaceResult)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceQueryReward, self.OnNetMsgRaceReward)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceOnceStatus, self.OnNetMsgRaceEffectTrigger)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceNpcchallengeData, self.OnNetMsgRaceNpcchallengeData)
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceSkillCDChange, self.OnNetMsgRaceSkillCDChange)
end

function ChocoboRaceMgr:OnRegisterGameEvent()
    --***********************************************
    -- 注：目前竞赛的外观数据依赖Query下发的数据，不依赖视野包，视野包只负责创建，所以监听以下三个协议，在角色组装好后再进行外观组装，包括主角，玩家，AI
    -- 原因是因为后台的创建接口不支持一开始就带avatar数据，比如NPC上坐骑也是通过视野包创建，再走单独的协议下发avatar数据
    --***********************************************
    self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.PlayerCreate, self.OnGameEventPlayerCreate)
    self:RegisterGameEvent(EventID.NPCCreate, self.OnGameEventNPCCreate)

    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventExitWorld)
    self:RegisterGameEvent(EventID.PWorldReady, self.OnGameEventPWorldReady)
    self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnEnterAreaTrigger)
    
    self:RegisterGameEvent(EventID.MountAssembleAllEnd, self.OnAssembleAllEnd)
    
    self:RegisterGameEvent(EventID.ChocoboRaceArrival, self.OnChocoboRaceArrival)
    self:RegisterGameEvent(EventID.AppEnterForeground, self.OnAppEnterForeground)
end

--region 协议请求
function ChocoboRaceMgr:ReqRaceQuery()
    ChocoboRaceUtil.Log("ReqRaceQuery  ReqRaceQuery  ReqRaceQuery")
    local Params = {}
    Params.Cmd = SUB_MSG_ID.ChocoboRaceCmdQuery
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdQuery, Params)
end

function ChocoboRaceMgr:ReqRaceJoin()
    local Params = {}
    Params.Cmd = SUB_MSG_ID.ChocoboRaceCmdJoin
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdJoin, Params)
end

function ChocoboRaceMgr:ReqRaceCtrl(Ctrl, Do, Close)
    if Ctrl == ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility1 or
            Ctrl == ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility2 or
            Ctrl == ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility3 then
        if self.DelayTutorialChocoboRaceSkillTimerID ~= nil then
            self:UnRegisterTimer(self.DelayTutorialChocoboRaceSkillTimerID)
            self.DelayTutorialChocoboRaceSkillTimerID = nil
        end
    end

    local Params = {}
    Params.Ctrl = {}
    Params.Ctrl.Ctrl = Ctrl
    Params.Ctrl.Do = Do
    Params.Ctrl.Close = Close
    Params.Cmd = SUB_MSG_ID.ChocoboRaceCmdCtrl
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdCtrl, Params)
end

-- 请求当前服务器路径最新数据，用于断线重连
function ChocoboRaceMgr:ReqRaceQueryProgress()
    local Params = {}
    Params.Cmd = SUB_MSG_ID.ChocoboRaceCmdQueryProgress
    Params.Progress = {}
    Params.Progress.Index = -1
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceCmdQueryProgress, Params)
end

function ChocoboRaceMgr:ReqRaceReward()
    local Cmd = SUB_MSG_ID.ChocoboRaceQueryReward
    local Params = {}
    Params.Cmd = Cmd
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceQueryReward, Params)
end

function ChocoboRaceMgr:ReqRaceResult()
    local Cmd = SUB_MSG_ID.ChocoboRaceQueryResult
    local Params = {}
    Params.Cmd = Cmd
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceQueryResult, Params)
end

function ChocoboRaceMgr:ReqRaceNpcChallenge(NpcID, Level)
    local Params = {}
    Params.challenge = {}
    Params.challenge.NpcID = NpcID
    Params.challenge.Guan = Level
    Params.Cmd = SUB_MSG_ID.ChocoboRaceStartNpcchallenge
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceStartNpcchallenge, Params)
end

function ChocoboRaceMgr:ReqRaceNpcChallengeData(NpcID)
    local Params = {}
    Params.challengedata = {}
    Params.challengedata.NpcID = NpcID
    Params.challengedata.Guan = 0
    Params.Cmd = SUB_MSG_ID.ChocoboRaceNpcchallengeData
    Params.RaceID = _G.PWorldMgr:GetCurrPWorldInstID()
    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO_RACE, SUB_MSG_ID.ChocoboRaceNpcchallengeData, Params)
end
--endregion

--region 协议回包
function ChocoboRaceMgr:OnNetMsgRaceAllUserIn(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceAllUserIn: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceAllUserIn: " .. _G.table_to_string_block(MsgBody))

    --self.IsServerReady = true
    --if self.IsClientReady and self.IsServerReady then
    --    self:ReqRaceQuery()
    --end
end

local function LoadVfx(VfxID)
    if not VfxID or type(VfxID) ~= "number" then
        return
    end

    local Cfg = ChocoboRaceVfxCfg:FindCfgByKey(VfxID)
    if Cfg == nil then
        return
    end

    local VfxPath = Cfg.Path
    if string.isnilorempty(VfxPath) then
        return
    end
    
    local AudioPath = Cfg.AudioPath
    if not string.isnilorempty(AudioPath) then
        ChocoboRaceUtil.Log( "PreLoadAudio AudioPath = " .. AudioPath)
        _G.ObjectMgr:PreLoadObject(AudioPath, _G.UE.EObjectGC.Cache_Map)
    end

    local Actor = ActorUtil.GetActorByEntityID(MajorUtil.GetMajorEntityID())
    if Actor == nil then return end

    local FrontPart = string.sub(VfxPath, 1, #VfxPath - 1)
    local BehindPart = string.sub(VfxPath, #VfxPath)
    local BeUsedPath = string.format("%s_C%s", FrontPart, BehindPart)

    local VfxParameter = _G.UE.FVfxParameter()
    VfxParameter.VfxRequireData.VfxTransform = Actor:GetTransform()
    VfxParameter.VfxRequireData.EffectPath = BeUsedPath
    VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_ChocoboRace
    if Cfg.BindType == ProtoRes.CHOCOBO_RACE_VFX_BIND_TYPE.CHOCOBO_RACE_VFX_BIND_NULL then
        VfxParameter.VfxTransform = Actor:FGetActorTransform()
    elseif Cfg.BindType == ProtoRes.CHOCOBO_RACE_VFX_BIND_TYPE.CHOCOBO_RACE_VFX_BIND_CASTER then
        VfxParameter:SetCaster(Actor, 0, _G.UE.EVFXAttachPointType.AttachPointType_Body, 0)
    elseif Cfg.BindType == ProtoRes.CHOCOBO_RACE_VFX_BIND_TYPE.CHOCOBO_RACE_VFX_BIND_TARGET then
        VfxParameter:AddTarget(Actor, 0, _G.UE.EVFXAttachPointType.AttachPointType_Body, 0)
    end

    ChocoboRaceUtil.Log( "PreLoadVfx VfxID = " .. VfxID)
    return EffectUtil.LoadVfx(VfxParameter)
end

function ChocoboRaceMgr:PreloadSkillVFX()
    local _ <close> = CommonUtil.MakeProfileTag("ChocoboRaceMgr.Lua.PreloadSkillVFX")

    -- 使用哈希表记录已加载资源避免重复加载
    local LoadedEffects = {}

    local function LoadEffectSafe(EffectID)
        if EffectID > 0 and not LoadedEffects[EffectID] then
            LoadVfx(EffectID)
            LoadedEffects[EffectID] = true
        end
    end

    local function ProcessStatusData(StatusData)
        if not StatusData then return end
        LoadEffectSafe(StatusData.InvocationEffect)
        LoadEffectSafe(StatusData.LoopEffect)
        LoadEffectSafe(StatusData.FieldHitEffect)
    end
    
    -- 技能特效
    for _, Racer in pairs(self.ChocoboRacerData) do
        for _, SkillID in ipairs(Racer.Abilities or {}) do
            local SkillCfg = ChocoboRaceSkillCfg:FindCfgByKey(SkillID)
            if SkillCfg then
                local StatusKeys = {
                    SkillCfg.InvocationStatus,
                    SkillCfg.HitStatus
                }

                for _, StatusKey in ipairs(StatusKeys) do
                    if StatusKey and StatusKey ~= 0 then
                        local StatusData = ChocoboRaceStatusCfg:FindCfgByKey(StatusKey)
                        ProcessStatusData(StatusData)
                        if StatusData.NextStatus > 0 then
                            local NextStatusData = ChocoboRaceStatusCfg:FindCfgByKey(StatusData.NextStatus)
                            ProcessStatusData(NextStatusData)
                        end
                    end
                end
            end
        end
    end

    -- 地面特效
    LoadEffectSafe(18)
    LoadEffectSafe(19)
    LoadEffectSafe(20)
    LoadEffectSafe(21)
    -- 命中失败
    LoadEffectSafe(3)
    LoadEffectSafe(4)
    
    -- 道具暂时全部预加载
    local AllSkillCfg = ChocoboRaceSkillCfg:FindAllCfg()
    for _, Item in ipairs(AllSkillCfg) do
        if Item.Rarity == ProtoRes.CHOCOBO_SKILL_QUALITY.CHOCOBO_SKILL_QUALITY_ITEM then
            local StatusKeys = {
                Item.InvocationStatus,
                Item.HitStatus
            }

            for _, StatusKey in ipairs(StatusKeys) do
                if StatusKey and StatusKey ~= 0 then
                    local StatusData = ChocoboRaceStatusCfg:FindCfgByKey(StatusKey)
                    ProcessStatusData(StatusData)
                    if StatusData.NextStatus > 0 then
                        local NextStatusData = ChocoboRaceStatusCfg:FindCfgByKey(StatusData.NextStatus)
                        ProcessStatusData(NextStatusData)
                    end
                end
            end
        end
    end
end

function ChocoboRaceMgr:OnNetMsgRaceQuery(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceQuery: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceQuery: " .. _G.table_to_string_block(MsgBody))

    local Query = MsgBody.Query
    if nil == Query then
        return
    end

    if not self:IsChocoboRacePWorld() then
        return
    end

    self.ChocoboRacerData = {}
    self.RaceUpdateParams = {}
    self.AfterCutsceneRacer = {}

    self.RaceSetup = Query.Setup
    self.RaceStatus = Query.Status
    self.GameRaceID = Query.RaceID

    local RacerData = Query.Racers
    local MajorData = nil
    for i = 1, #RacerData do
        local Index = RacerData[i].Index + 1
        local Data = RacerData[i]
        Data.Index = Index
        Data.IsRide = false

        --初始化数据
        self.ChocoboRacerData[Index] = Data

        --初始化Racer
        local Racer = self:GetRacerByIndex(Index)
        Racer:Init(Data)

        --初始化VM
        local RacerVM = ChocoboRaceMainVM:FindChocoboRaceVM(Index)
        RacerVM:Init(Data)

        -- npc挑战
        RacerVM:SetIsNpcChallenge(false)
        if (self.RaceSetup or {}).Mode == ProtoCS.ChocoboRaceMode.ChocoboRaceModeChallenge then
            if Index == ChocoboDefine.NPC_CHALLENGE_INDEX then
                RacerVM:SetIsNpcChallenge(true)
            end
        end

        --初始化技能
        if MajorUtil.IsMajor(Data.EntityID) then
            MajorData = Data
            ChocoboRaceMainVM:SetMajorIndex(Index)
            RacerVM:SetIsMajor(true)

            local Abilities = Data.Abilities
            for k = 1, #Abilities do
                local SkillID = Abilities[k]
                if SkillID > 0 then
                    local SkillVM = ChocoboRaceMainVM:FindSkillVM(k)
                    SkillVM:UpdateSkillID(SkillID, Data.Passive, Data.PassiveLevel)
                end
            end
        else
            RacerVM:SetIsMajor(false)
        end

        if self.VisionCacheAvatar[Data.EntityID] == nil then
            self.VisionCacheAvatar[Data.EntityID] = {}
        end

        self.VisionCacheAvatar[Data.EntityID].VChocobo = Data
        if self.VisionCacheAvatar[Data.EntityID].bLoadAvatar == true then
            --初始化坐骑
            self:HandleChocoboByResID(Data.EntityID, Data)
        end

        EventMgr:SendEvent(EventID.ChocoboRaceHUDUpdate, { ULongParam1 = Data.EntityID })
    end

    -- 请求坐标数据
    self:ReqRaceQueryProgress()
    --初始化游戏状态
    if self.RaceStatus == ProtoCS.ChocoboRaceStatus.ChocoboRaceStatusRunning then
        self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.BEGIN)
    elseif self.RaceStatus >= ProtoCS.ChocoboRaceStatus.ChocoboRaceStatusResult then
        self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.RESULT)
        self:ReqRaceReward()
        self:ReqRaceResult()
    end
    
    ChocoboRaceMainVM:UpdateRaceSetup(self.RaceSetup)
    ChocoboRaceMainVM:UpdatePlayerInfoList()
    if self.RaceSetup.GoTime > 0 then
        self.GoTime = self.RaceSetup.GoTime
        if self.GoTime <= TimeUtil.GetServerTime() then
            if MajorData ~= nil then
                self.AfterCutsceneRacer[MajorData.Index] = MajorData.EntityID
            end
        end
    end

    local EntityList = {}
    for _, Racer in pairs(self.ChocoboRacerData) do
        table.insert(EntityList, Racer.EntityID)
    end
    self:InitAssemblyTracking(EntityList)

    EventMgr:SendEvent(EventID.ChocoboRacerMapUpdate)
    EventMgr:SendEvent(EventID.ChocoboRaceItemMapUpdate)
    EventMgr:SendEvent(EventID.ChocoboRaceGameQuerySuc)
    
    -- 预加载特效
    self:PreloadSkillVFX()
end

function ChocoboRaceMgr:OnNetMsgRaceJoin(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceJoin: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceJoin: " .. _G.table_to_string_block(MsgBody))

    local Join = MsgBody.Join
    if nil == Join then
        return
    end

    if not self:IsChocoboRacePWorld() then
        return
    end

    if self.AfterCutsceneRacer == nil then
        self.AfterCutsceneRacer = {}
    end

    local Index = Join.Index + 1
    local EntityID = self:GetEntityIDByIndex(Index)
    if EntityID > 0 then
        self.AfterCutsceneRacer[Index] = EntityID
        EventMgr:SendEvent(EventID.ChocoboRaceHUDUpdate, { ULongParam1 = EntityID })
    end
end

function ChocoboRaceMgr:OnNetMsgRaceCtrl(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceCtrl: MsgBody is nil")
        return
    end

    local Ctrl = MsgBody.Ctrl
    if nil == Ctrl then
        return
    end

    if not self:IsChocoboRacePWorld() then
        return
    end

    if self.ChocoboRacerData == nil or next(self.ChocoboRacerData) == nil then
        return
    end
    
    if self:GetGameState() < ChocoboDefine.GAME_STATE_ENUM.BEGIN or self:GetGameState() >= ChocoboDefine.GAME_STATE_ENUM.RESULT then
        return
    end
    
    local Index = Ctrl.Index + 1
    local Racer = self:GetRacerByIndex(Index)
    Racer:UpdateCtrl(Ctrl)
    
    if self:IsMajorByIndex(Index) then
        ChocoboRaceUtil.Log( "OnNetMsgRaceCtrl: " .. _G.table_to_string_block(MsgBody))
        if Ctrl.Ctrl == ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbilityItem then
            ChocoboRaceMainVM:UpdatePickup()
            for i = 1, ChocoboDefine.SKILL_NUM do
                -- 触发全局CD
                local SkillVM = ChocoboRaceMainVM:FindSkillVM(i)
                SkillVM:UpdateSkillCD(TimeUtil.GetServerTimeMS() + self:GetGCDDuration())
            end
        elseif Ctrl.Ctrl == ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility1 or
                Ctrl.Ctrl == ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility2 or
                Ctrl.Ctrl == ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility3 then
            local NowTimeMS = TimeUtil.GetServerTimeMS()
            if Ctrl.CDTime > NowTimeMS then
                for i = 1, ChocoboDefine.SKILL_NUM do
                    local SkillVM = ChocoboRaceMainVM:FindSkillVM(i)
                    if SkillVM.SkillID == Ctrl.AbilityID then
                        SkillVM:UpdateSkillCD(Ctrl.CDTime)
                    else
                        -- 触发全局CD
                        SkillVM:UpdateSkillCD(TimeUtil.GetServerTimeMS() + self:GetGCDDuration())
                    end
                end
            end
        end
    end
end

function ChocoboRaceMgr:OnNetMsgRacePickup(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRacePickup: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRacePickup: " .. _G.table_to_string_block(MsgBody))

    local Pickup = MsgBody.Pickup
    if nil == Pickup then
        return
    end

    if not self:IsChocoboRacePWorld() then
        return
    end

    if self.ChocoboRacerData == nil or next(self.ChocoboRacerData) == nil then
        return
    end
    
    if self:GetGameState() < ChocoboDefine.GAME_STATE_ENUM.BEGIN or self:GetGameState() >= ChocoboDefine.GAME_STATE_ENUM.RESULT then
        return
    end
    
    local Index = Pickup.Index + 1
    if self:IsMajorByIndex(Index) then
        ChocoboRaceMainVM:UpdatePickup(Pickup)
    end
end

function ChocoboRaceMgr:OnNetMsgRaceProgress(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceProgress: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceProgress: " .. _G.table_to_string_block(MsgBody))

    local Progress = MsgBody.Progress
    if nil == Progress then
        return
    end
    
    self:OnNetMsgRaceUpdateHandle(Progress)
end

function ChocoboRaceMgr:OnNetMsgRaceUpdate(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceUpdate: MsgBody is nil")
        return
    end
    --ChocoboRaceUtil.Log( "OnNetMsgRaceUpdate: " .. _G.table_to_string_block(MsgBody))

    local Update = MsgBody.Update
    if nil == Update then
        return
    end
    
    self:OnNetMsgRaceUpdateHandle(Update)
end

function ChocoboRaceMgr:OnNetMsgRaceUpdateHandle(Update)
    if not self:IsChocoboRacePWorld() then
        return
    end

    if self.ChocoboRacerData == nil or next(self.ChocoboRacerData) == nil then
        return
    end
    
    if self:GetGameState() < ChocoboDefine.GAME_STATE_ENUM.BEGIN or self:GetGameState() >= ChocoboDefine.GAME_STATE_ENUM.RESULT then
        return
    end

    --if self.GameRaceID ~= 0 and self.GameRaceID ~= Update.RaceID then
    --    return
    --end

    --if Update.FrameID > 0 and Update.FrameID - self.CurFrameID < FrameInterval then
    --    return
    --end

    self.CurFrameID = Update.FrameID
    self.RaceUpdateParams = self.RaceUpdateParams or {}
    self.LastRankDict = self.LastRankDict or {}
    
    local CheckRank = false
    for __, Value in pairs(Update.Racers) do
        local Params = Value
        Params.Index = Value.Index + 1
        Params.Ranking = Value.Ranking + 1
        self.RaceUpdateParams[Params.Index] = Params

        local LastRank = self.LastRankDict[Params.Index]
        if LastRank and LastRank ~= Params.Ranking then
            CheckRank = true
        end
        self.LastRankDict[Params.Index] = Params.Ranking
        
        if self:IsMajorByIndex(Params.Index) then
            ChocoboRaceMainVM.MajorSpeed = "Speed : " .. Params.Speed
            ChocoboRaceUtil.Log( "OnNetMsgRaceUpdate: " .. table.tostring(Value))
        end

        --更新VM
        local RacerVM = ChocoboRaceMainVM:FindChocoboRaceVM(Params.Index)
        if RacerVM then
            RacerVM:UpdateData(Params)
        end

        --更新结算界面
        if Params.Status == ProtoCS.ChocoboRacerStatus.ChocoboRacerStatusGoal then
            local Racer = self:GetRacerByIndex(Params.Index)
            if Racer ~= nil and RacerVM ~= nil and RacerVM.IsOver == false then
                Racer:SetRank(Params.Ranking)
                -- 如果是断线重连的情况下，此处计算不准，以result的为准
                RacerVM:SetArrivedTimeS(self.CurFrameID * FrameInterval)
            end

            if self:IsMajorByIndex(Params.Index) then
                CheckRank = true
                
                if self:GetGameState() < ChocoboDefine.GAME_STATE_ENUM.GOAL then
                    self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.GOAL)
                    self:ReqRaceReward()
                end
            end
        end
    end

    if CheckRank then
        ChocoboRaceMainVM:SortChocoboRaceVMList()
    end
end

function ChocoboRaceMgr:OnNetMsgRaceReady(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceReady: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceReady: " .. _G.table_to_string_block(MsgBody))

    local Ready = MsgBody.Ready
    if nil == Ready then
        return
    end

    if not self:IsChocoboRacePWorld() then
        return
    end
    
    self.GoTime = Ready.GoTime
    if not self.GoTime then
        return
    end
    
    ChocoboRaceUtil.Log(string.format(
            "OnNetMsgRaceReady | GoTime:%d | ServerTime:%d | LeftTime:%d",
            self.GoTime,
            TimeUtil.GetServerTime(),
            (self.GoTime - TimeUtil.GetServerTime())
    ))

    -- 1.请求的时候会回包
    -- 2.游戏已经开始了，没有请求也会主动推送
    if self.GoTime > 0 then
        if self.GoTime <= TimeUtil.GetServerTime() then  -- 表示已经开始游戏了
            self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.BEGIN)
        else
            if self:GetGameState() == ChocoboDefine.GAME_STATE_ENUM.READY then
                if self.GoTime - TimeUtil.GetServerTime() > 0.5 then  -- 还没开始游戏，并且剩余时间大于0.5
                    ChocoboRaceUtil.Log("OnNetMsgRaceReady PlayCountDown PlayCountDown PlayCountDown")
                    UIViewMgr:ShowView(UIViewID.ChocoboRaceCountDownView, {
                        Mode = "COUNTDOWN",
                        EndTime = self.GoTime,
                    })
                end
            end
        end
    end
end

function ChocoboRaceMgr:OnNetMsgRaceResult(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceResult: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceResult: " .. _G.table_to_string_block(MsgBody))

    local Result = MsgBody.Result
    if nil == Result or nil == Result.Results then
        return
    end

    if not self:IsChocoboRacePWorld() then
        return
    end

    --if self.GameRaceID ~= 0 and self.GameRaceID ~= Result.RaceID then
    --    return
    --end

    if #Result.Results <= 0 then
        return
    end

    -- 重新登陆的时候，地图还没有加载好的时候，客户端还不会请求数据，也会收到服务器的消息，这个时候要return一下
    if self.ChocoboRacerData == nil or next(self.ChocoboRacerData) == nil then
        return
    end
    
    for __, Item in pairs(Result.Results) do
        local Index = Item.Index + 1
        local Rank = Item.Rank + 1
        if Item.ArrivedTimeS ~= nil and Item.ArrivedTimeS > 0 then
            local RacerVM = ChocoboRaceMainVM:FindChocoboRaceVM(Index)
            RacerVM:UpdateResult({Index = Index, Rank = Rank, RunTimesS = Item.RunTimesS})

            local Racer = self:GetRacerByIndex(Index)
            Racer:UpdateResult({Index = Index, Rank = Rank, RunTimesS = Item.RunTimesS})
        end
    end

    if Result.Mode == ProtoCS.ChocoboRaceMode.ChocoboRaceModeChallenge then
        _G.UE.UBGMMgr.Get():Pause()
        if Result.Win == 1 then
            AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), ChocoboDefine.CHOCOBO_RACE_WIN_1ST_SOUND_PATH, true)
        else
            AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), ChocoboDefine.CHOCOBO_RACE_LOST_SOUND_PATH, true)
        end
    end

    self:ReqRaceQueryProgress()
    ChocoboRaceMainVM:UpdateResult(Result)
    ChocoboRaceMainVM:SortChocoboRaceVMList()
    
    if #Result.Results >= self.MaxRacerNum and self:GetGameState() ~= ChocoboDefine.GAME_STATE_ENUM.RESULT then
        self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.RESULT)
    end
end

function ChocoboRaceMgr:OnNetMsgRaceReward(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceReward: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceReward: " .. _G.table_to_string_block(MsgBody))

    if not self:IsChocoboRacePWorld() then
        return
    end

    if self.ChocoboRacerData == nil or next(self.ChocoboRacerData) == nil then
        return
    end
    
    local Award = MsgBody.Award
    if nil == Award or nil == Award.Rewards then
        return
    end

    ChocoboRaceMainVM:UpdateRewards(Award.Rewards)

    if self:GetGameState() < ChocoboDefine.GAME_STATE_ENUM.GOAL then
        self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.GOAL)
    end
end

function ChocoboRaceMgr:OnNetMsgRaceEffectTrigger(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceEffectTrigger: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceEffectTrigger: " .. _G.table_to_string_block(MsgBody))

    if not self:IsChocoboRacePWorld() then
        return
    end

    if self.ChocoboRacerData == nil or next(self.ChocoboRacerData) == nil then
        return
    end
    
    local Onece = MsgBody.Onece
    if Onece == nil then
        return
    end

    if self:GetGameState() < ChocoboDefine.GAME_STATE_ENUM.BEGIN or self:GetGameState() >= ChocoboDefine.GAME_STATE_ENUM.RESULT then
        return
    end
    
    local Index = Onece.Index + 1
    local EffectID = Onece.StatusType

    local Racer = self:GetRacerByIndex(Index)
    if Racer then
        Racer:PlayEffect(EffectID)
    end
end

function ChocoboRaceMgr:OnNetMsgRaceNpcchallengeData(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceNpcchallengeData: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceNpcchallengeData: " .. _G.table_to_string_block(MsgBody))

    local Data = MsgBody.challengedata
    if nil == Data then
        return
    end
    
    UIViewMgr:ShowView(UIViewID.ChocoboRaceNpcChallengeView, { NpcID = Data.NpcID, Level = Data.Guan })
end

function ChocoboRaceMgr:OnNetMsgRaceSkillCDChange(MsgBody)
    if nil == MsgBody then
        ChocoboRaceUtil.Err( "OnNetMsgRaceSkillCDChange: MsgBody is nil")
        return
    end
    ChocoboRaceUtil.Log( "OnNetMsgRaceSkillCDChange: " .. _G.table_to_string_block(MsgBody))

    if not self:IsChocoboRacePWorld() then
        return
    end
    
    if self.ChocoboRacerData == nil or next(self.ChocoboRacerData) == nil then
        return
    end
    
    local CdNotify = MsgBody.cdnotify
    if nil == CdNotify then
        return
    end
    
    local Index = CdNotify.index + 1
    local TargetID = CdNotify.skillid
    local CdTime = CdNotify.cdtime
    local RaceData = ChocoboRaceMgr:GetRacerDataByIndex(Index)
    if RaceData and MajorUtil.IsMajor(RaceData.EntityID) then
        for k = 1, ChocoboDefine.SKILL_NUM do
            local SkillVM = ChocoboRaceMainVM:FindSkillVM(k)
            if SkillVM.SkillID == TargetID then
                SkillVM:UpdateSkillCD(CdTime)
            end
        end
    end
end
--endregion

function ChocoboRaceMgr:InitAssemblyTracking(EntityList)
    self.PendingEntities = {}
    self.IsJoinRequestSent = false

    for _, EntityId in ipairs(EntityList or {}) do
        if EntityId > 0 then
            self.PendingEntities[EntityId] = false
        end
    end

    if not next(self.PendingEntities) then
        self:TrySendRaceJoin()
    end
end

function ChocoboRaceMgr:OnAssembleAllEnd(Params)
    if not self:IsChocoboRacePWorld() then
        return
    end
    
    if self.IsJoinRequestSent then
        return
    end

    local EntityID = Params.ULongParam1
    EventMgr:SendEvent(EventID.ChocoboRaceHUDUpdate, { ULongParam1 = EntityID })
    if self.PendingEntities[EntityID] ~= nil then
        self.PendingEntities[EntityID] = true
        ChocoboRaceUtil.Log("Entity Assembled: "..tostring(EntityID))
    end

    local AllAssembled = true
    for _, Status in pairs(self.PendingEntities) do
        if not Status then
            AllAssembled = false
            break
        end
    end

    if AllAssembled then
        ChocoboRaceUtil.Log("All Entities Assembled")
        self:TrySendRaceJoin()
    end
end

function ChocoboRaceMgr:OnChocoboRaceArrival(Params)
    if not self:IsChocoboRacePWorld() then
        return
    end

    local Index = Params.IntParam1
    ChocoboRaceUtil.Log("OnChocoboRaceArrival Index = " .. Index)
    local Racer = self:GetRacerByIndex(Index + 1)
    Racer:SetIsArrival(true)

    if Racer.IsMajor then
        -- 没有正在播放，也没有创建
        if not self.IsTickResultSequence and not self.ChocoboCamera then
            self:JumpToFinalFrame()
        end
    end
end

function ChocoboRaceMgr:OnAppEnterForeground()
    if not self:IsChocoboRacePWorld() then
        return
    end

    if self:GetGameState() >= ChocoboDefine.GAME_STATE_ENUM.BEGIN then
        ChocoboRaceUtil.Log("OnAppEnterForeground OnAppEnterForeground OnAppEnterForeground")
        self:ReqRaceQueryProgress()
    end
end

function ChocoboRaceMgr:TrySendRaceJoin()
    if not self.IsPWorldReady then return end
    if self.IsJoinRequestSent then return end

    if self.AssembleTimeoutTimer then
        self:UnRegisterTimer(self.AssembleTimeoutTimer)
        self.AssembleTimeoutTimer = nil
    end

    self.IsJoinRequestSent = true
    ChocoboRaceUtil.Log("Sending Race Join Request")

    self:ReqRaceJoin()
end

function ChocoboRaceMgr:StartAssemblyTimeout()
    if self.AssembleTimeoutTimer then return end

    ChocoboRaceUtil.Log("Starting Assembly Timeout Timer")
    self.AssembleTimeoutTimer = self:RegisterTimer(function()
        self:TrySendRaceJoin()
    end, 10)
end

---IsMajorByIndex
---@param Index number 竞赛编号
---@return boolean
function ChocoboRaceMgr:IsMajorByIndex(Index)
    if self.ChocoboRacerData == nil then
        return false
    end

    for __, RacerData in pairs(self.ChocoboRacerData) do
        if RacerData.Index ~= nil and RacerData.Index == Index then
            local EntityID = RacerData.EntityID or 0
            return MajorUtil.IsMajor(EntityID)
        end
    end

    return false
end

---GetRacerData 不提供通过RoleID获取的接口，因为 RoleID = 0 表示机器人
---@param EntityID number
---@return table
function ChocoboRaceMgr:GetRacerData(EntityID)
    if self.ChocoboRacerData == nil or EntityID <= 0 then
        return nil
    end

    for __, RacerData in pairs(self.ChocoboRacerData) do
        if RacerData.EntityID ~= nil and RacerData.EntityID == EntityID then
            return RacerData
        end
    end
    
    return nil
end

function ChocoboRaceMgr:GetRacerDataByIndex(Index)
    if self.ChocoboRacerData == nil or Index <= 0 then
        return nil
    end

    for __, RacerData in pairs(self.ChocoboRacerData) do
        if RacerData.Index ~= nil and RacerData.Index == Index then
            return RacerData
        end
    end

    return nil
end

---GetRacerIndexByID
---@param EntityID number
---@return number
function ChocoboRaceMgr:GetRacerIndexByID(EntityID)
    local Index = (self:GetRacerData(EntityID) or {}).Index
    if Index ~= nil then
        return Index
    end

    return 0
end

---GetEntityIDByIndex
---@param Index number
---@return number
function ChocoboRaceMgr:GetEntityIDByIndex(Index)
    if self.ChocoboRacerData == nil then
        return 0
    end

    for __, RacerData in pairs(self.ChocoboRacerData) do
        if RacerData.Index ~= nil and RacerData.Index == Index then
            return RacerData.EntityID
        end
    end

    return 0
end

---GetRacerNameByID
---@param EntityID number
---@return string
function ChocoboRaceMgr:GetRacerNameByID(EntityID)
    local Name = (self:GetRacerData(EntityID) or {}).Name
    if Name ~= nil then
        return Name
    end

    return ""
end

---GetRacerIndexAsset
---@param EntityID number
---@return string
function ChocoboRaceMgr:GetRacerIndexAsset(EntityID)
    local Index = self:GetRacerIndexByID(EntityID)
    local Path = nil
    if MajorUtil.IsMajor(EntityID) then
        Path = ChocoboRaceUtil.MajorIndexAsset[Index]
    else
        Path = ChocoboRaceUtil.OtherIndexAsset[Index]
    end

    if Path == nil then
        return ""
    end
    return Path
end

---GetRacerCurStamina
---@param EntityID number
---@return number
function ChocoboRaceMgr:GetRacerCurStamina(EntityID)
    local Index = self:GetRacerIndexByID(EntityID)
    local VM = ChocoboRaceMainVM:FindChocoboRaceVM(Index)
    return VM.Stamina
end

---GetRacerMaxStamina
---@return number
function ChocoboRaceMgr:GetRacerMaxStamina()
    if not self.ChocoboStaminaMax then
        local GlobalCfgValue = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_CHOCOBO_STAMINA_MAX, "Value") -- 1068
        self.ChocoboStaminaMax = GlobalCfgValue and GlobalCfgValue[1] or 10000
    end
    return self.ChocoboStaminaMax
end

function ChocoboRaceMgr:OnGameEventMajorCreate(Params)
    if not self:IsChocoboRacePWorld() then
        return
    end

    self.IsCreatePipeline = false
    self:CreateChocoboPipeline()
    self:CreateChocoboInput()

    local EntityID = Params.ULongParam1
    if self.VisionCacheAvatar[EntityID] == nil then
        self.VisionCacheAvatar[EntityID] = {}
    end

    local VChocobo = self.VisionCacheAvatar[EntityID].VChocobo
    if VChocobo == nil then
        self.VisionCacheAvatar[EntityID].bLoadAvatar = true
        return
    end

    if VChocobo.IsRide then
        return
    end

    ChocoboRaceUtil.Log( "OnGameEventMajorCreate EntityID = " .. EntityID)
    self:HandleChocoboByResID(EntityID, VChocobo)
end

function ChocoboRaceMgr:OnGameEventPlayerCreate(Params)
    if not self:IsChocoboRacePWorld() then
        return
    end

    local EntityID = Params.ULongParam1
    if self.VisionCacheAvatar[EntityID] == nil then
        self.VisionCacheAvatar[EntityID] = {}
    end

    local VChocobo = self.VisionCacheAvatar[EntityID].VChocobo
    if VChocobo == nil then
        self.VisionCacheAvatar[EntityID].bLoadAvatar = true
        return
    end

    if VChocobo.IsRide then
        return
    end

    ChocoboRaceUtil.Log( "OnGameEventPlayerCreate EntityID = " .. EntityID)
    self:HandleChocoboByResID(EntityID, VChocobo)
end

function ChocoboRaceMgr:OnGameEventNPCCreate(Params)
    if not self:IsChocoboRacePWorld() then
        return
    end

    local EntityID = Params.ULongParam1
    if self.VisionCacheAvatar[EntityID] == nil then
        self.VisionCacheAvatar[EntityID] = {}
    end

    local VChocobo = self.VisionCacheAvatar[EntityID].VChocobo
    if VChocobo == nil then
        self.VisionCacheAvatar[EntityID].bLoadAvatar = true
        return
    end

    if VChocobo.IsRide then
        return
    end

    if VChocobo.RoleID ~= 0 then
        return
    end

    ChocoboRaceUtil.Log("OnGameEventNPCCreate EntityID = " .. EntityID)
    self:HandleChocoboByResID(EntityID, VChocobo)
end

--离开视野
function ChocoboRaceMgr:OnGameEventVisionLeave(Params)
    if not self:IsChocoboRacePWorld() then
        return
    end
    
    local EntityID = Params.ULongParam1
    if self.VisionCacheAvatar[EntityID] == nil then
        return
    end

    ChocoboRaceUtil.Log( "OnGameEventVisionLeave EntityID = " .. EntityID)
    local VChocobo = self.VisionCacheAvatar[EntityID].VChocobo
    --重连的时候主角会离开下视野
    if VChocobo ~= nil and not MajorUtil.IsMajor(EntityID) then
        VChocobo.IsRide = false
    end
end

function ChocoboRaceMgr:HandleChocoboByResID(EntityID, VChocobo)
    if not self:IsChocoboRacePWorld() then
        return
    end

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor == nil then
        return
    end
    
    local RideComp = Actor:GetRideComponent()
    if RideComp == nil then
        return
    end

    if VChocobo == nil then
        RideComp:UnUseRide(true)
    else
        VChocobo.IsRide = true
        if VChocobo.RoleID == 0 then
            _G.UE.UChocoboRaceMgr.Get():SetAIFlag(VChocobo.EntityID)
        end

        local Head = 0
        local Body = 0
        local Feet = 0
        local StainID = VChocobo.Color
        if StainID == nil then
            StainID = 0
        end
        
        local Armor = VChocobo.Armor
        if Armor ~= nil then
            Head = Armor.Head
            Body = Armor.Body
            Feet = Armor.Feet
        end

        ChocoboRaceUtil.Log(string.format("HandleChocoboByResID entity %d (RoleID:%d)", EntityID, VChocobo.RoleID))
        local HeadChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Head)
        local HeadString = HeadChocoboEquipCfg and HeadChocoboEquipCfg.ModelString or ""
        local FeetChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Feet)
        local FeetString = FeetChocoboEquipCfg and FeetChocoboEquipCfg.ModelString or ""
        local BodyChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Body)
        local BodyString = BodyChocoboEquipCfg and BodyChocoboEquipCfg.ModelString or ""
        RideComp:UseRide(ChocoboDefine.CHOCOBO_RIDE_ID, 0, StainID, HeadString, BodyString, "", FeetString)
        RideComp:EnableAnimationRotating(false)
    end
    EventMgr:SendEvent(EventID.ChocoboRaceHUDUpdate, { ULongParam1 = EntityID })
end

local function PreLoadRacerActionTimeline()
    --预加载动作资源
    -- TODO: AI的动作还没加载
    -- TODO: 武器动作的da有问题，暂时不加载
    local _ <close> = CommonUtil.MakeProfileTag( "ChocoboRaceMgr.Lua.PreLoadRacerActionTimeline")
    local Members = _G.ChocoboMgr:GetQueryMatchChocoboList() or {}
    for __, RoleID in pairs(Members) do
        local RoleVM, IsValid = RoleInfoMgr:FindRoleVM(RoleID, true)
        if IsValid then
            local RaceData = RaceCfg:FindCfgByRaceIDTribeGender(RoleVM.Race, RoleVM.Tribe, RoleVM.Gender)
            if nil ~= RaceData then
                local AttachType = RaceData.AttachType
                local AtlAllData = ChocoboActiontimelineCfg:FindAllCfg()
                ChocoboRaceUtil.Log(string.format( "Lua.PreLoadAllActionTimeline RoleID = %d AttachType = %s", RoleID, AttachType))

                for i = 1, #AtlAllData do
                    if AtlAllData[i].ID ~= ProtoRes.CHOCOBO_ACTION_TIMELINE_TYPE.EXD_ACTION_TIMELINE_CHOCOBORACE_BRAKE then
                        -- 刹车不加载
                        if AtlAllData[i].PlayerAtlID ~= nil and AtlAllData[i].PlayerAtlID > 0 then
                            -- 主角和玩家都可以用a0001，AI检查npcbasecfg的配置，目前来说应该都可以用a0001
                            -- "d0001" 是写死了陆行鸟的
                            _G.UE.UChocoboRaceMgr.Get():PreLoadActionTimeLine(AtlAllData[i].PlayerAtlID, AttachType, "a0001", _G.UE.EAvatarPartType.MASTER)
                            _G.UE.UChocoboRaceMgr.Get():PreLoadActionTimeLine(AtlAllData[i].PlayerAtlID, "d0001", "a0001", _G.UE.EAvatarPartType.RIDE_MASTER)
                        end
                    end
                end
            end
        end
    end
end

function ChocoboRaceMgr:OnGameEventPWorldMapEnter(Params)
    if not self:IsChocoboRacePWorld() then
        return
    end
    ChocoboRaceUtil.Log( "OnGameEventPWorldMapEnter")
    
    PreLoadRacerActionTimeline()
    
    local bReconnect = false
    if Params ~= nil then
        bReconnect = Params.bReconnect
        if not bReconnect then
            self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.SEQUENCE)
        end
    end

    BusinessUIMgr:ShowMainPanel(UIViewID.ChocoboRaceMainView)
    self.IsClientReady = true
    --local ShouldSendRaceQuery = self.IsClientReady and self.IsServerReady
    --if ShouldSendRaceQuery or bReconnect then
        self:ReqRaceQuery()
    --end
    if bReconnect then
        self.IsJoinRequestSent = true
        self:ReqRaceJoin()
    end

    --开启Tick
    _G.UE.UChocoboRaceMgr.Get():SetEnableTick(true)
    _G.UE.FTickHelper.GetInst():SetTickEnable(self.TickTimerID)
end

function ChocoboRaceMgr:OnGameEventPWorldReady()
    if not self:IsChocoboRacePWorld() then
        return
    end
    ChocoboRaceUtil.Log( "OnGameEventPWorldReady")

    -- sequince 播放完需要 HideJoyStick
    CommonUtil.DisableShowJoyStick(true)
    CommonUtil.HideJoyStick()
    EventMgr:SendEvent(EventID.ChocoboRaceHUDUpdate, { ULongParam1 = MajorUtil.GetMajorEntityID() })
    _G.MapMgr:SetUpdateMap(true, 3)
    if self:GetGameState() <= ChocoboDefine.GAME_STATE_ENUM.SEQUENCE then
        self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.READY)
    end

    self.IsPWorldReady = true
    self:StartAssemblyTimeout()
    
    if not next(self.PendingEntities) then
        self:TrySendRaceJoin()
    end
end

function ChocoboRaceMgr:OnGameEventExitWorld(LeavePWorldResID, LeaveMapResID)
    local PWorldTableCfg = PWorldCfg:FindCfgByKey(LeavePWorldResID)
    local PWorldSubType = (PWorldTableCfg ~= nil and PWorldTableCfg.SubType or 0)
    if PWorldSubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_CHOCOBO_RACE then
        ChocoboRaceMainVM:ResetRace()
        _G.UE.UBGMMgr.Get():Resume()
        _G.MapMgr:SetUpdateMap(false, 3)
        _G.EventMgr:SendEvent(_G.EventID.ChocoboRacerMapClear)
        _G.EventMgr:SendEvent(_G.EventID.ChocoboRaceItemMapClear)
        if self.ChocoboCamera ~= nil then
            _G.LuaCameraMgr:ResumeCamera(true)
            CommonUtil.DestroyActor(self.ChocoboCamera)
            self.ChocoboCamera = nil
        end
        self:ClearChocoboPipeline()
        self:ClearChocoboInput()
        self:ResetRace()
        self:SetGameState(ChocoboDefine.GAME_STATE_ENUM.NONE)
        ChocoboRaceMainVM:ClearChocoboRaceVMList()
    end
end

---IsInputVisible
---@return boolean
function ChocoboRaceMgr:IsInputVisible()
    return self.IsCreateInput
end

function ChocoboRaceMgr:CreateChocoboPipeline()
    if self.IsCreatePipeline then
        ChocoboRaceUtil.Wrn("Pipeline already created, skipping")
        return
    end

    ChocoboRaceUtil.Log("Creating chocobo pipeline...")
    self.IsCreatePipeline = true
    _G.UE.UChocoboRaceMgr.Get():CreateMajorPipeline()
end

function ChocoboRaceMgr:ClearChocoboPipeline()
    if not self.IsCreatePipeline then
        return
    end
    
    local MajorActor = MajorUtil.GetMajor()
    if MajorActor then
        local RideComp = MajorActor:GetRideComponent()
        if RideComp then
            RideComp:EnableAnimationRotating(true)
        end
    end
    
    self.IsCreatePipeline = false
    _G.UE.UChocoboRaceMgr.Get():ClearMajorPipeline()
end

function ChocoboRaceMgr:CreateChocoboInput()
    if self.IsCreateInput then
        return
    end

    self.IsCreateInput = true
    _G.UE.UChocoboRaceMgr.Get():CreateMajorInput()
    local IE_Pressed = _G.UE.EInputEvent.IE_Pressed
    local IE_Released = _G.UE.EInputEvent.IE_Released
    _G.UE.UInputMgr.Get():RegisterPlayerInputKeyForLua("W", IE_Pressed)
    _G.UE.UInputMgr.Get():RegisterPlayerInputKeyForLua("W", IE_Released)
    _G.UE.UInputMgr.Get():RegisterPlayerInputKeyForLua("A", IE_Pressed)
    _G.UE.UInputMgr.Get():RegisterPlayerInputKeyForLua("A", IE_Released)
    _G.UE.UInputMgr.Get():RegisterPlayerInputKeyForLua("D", IE_Pressed)
    _G.UE.UInputMgr.Get():RegisterPlayerInputKeyForLua("D", IE_Released)
    _G.UE.UInputMgr.Get():RegisterPlayerInputKeyForLua("SpaceBar", IE_Pressed)
    _G.UE.UInputMgr.Get():RegisterPlayerInputKeyForLua("SpaceBar", IE_Released)
end

function ChocoboRaceMgr:ClearChocoboInput()
    if not self.IsCreateInput then
        return
    end

    self.IsCreateInput = false
    _G.UE.UChocoboRaceMgr.Get():ClearMajorInput()
    local IE_Pressed = _G.UE.EInputEvent.IE_Pressed
    local IE_Released = _G.UE.EInputEvent.IE_Released
    _G.UE.UInputMgr.Get():UnRegisterPlayerInputKeyForLua("W", IE_Pressed)
    _G.UE.UInputMgr.Get():UnRegisterPlayerInputKeyForLua("W", IE_Released)
    _G.UE.UInputMgr.Get():UnRegisterPlayerInputKeyForLua("A", IE_Pressed)
    _G.UE.UInputMgr.Get():UnRegisterPlayerInputKeyForLua("A", IE_Released)
    _G.UE.UInputMgr.Get():UnRegisterPlayerInputKeyForLua("D", IE_Pressed)
    _G.UE.UInputMgr.Get():UnRegisterPlayerInputKeyForLua("D", IE_Released)
    _G.UE.UInputMgr.Get():UnRegisterPlayerInputKeyForLua("SpaceBar", IE_Pressed)
    _G.UE.UInputMgr.Get():UnRegisterPlayerInputKeyForLua("SpaceBar", IE_Released)
end

--function ChocoboRaceMgr:OnGameEventEnterInteractionRange(Params)
--    if not self:IsChocoboRacePWorld() then
--        return
--    end
--    if Params.IntParam1 ~= _G.UE.EActorType.EObj then
--        return
--    end
--
--    ChocoboRaceUtil.Err("OnGameEventEnterInteractionRange EntityID = %d", Params.ULongParam1)
--end

function ChocoboRaceMgr:OnEnterAreaTrigger(EventParam)
    if not self:IsChocoboRacePWorld() then
        return
    end
    
    local Treasure = { }
    if self.RaceSetup ~= nil and self.RaceSetup.Treasure ~= nil then
        Treasure = self.RaceSetup.Treasure
    end

    for __, Value in pairs(Treasure) do
        if EventParam.AreaID == Value then
            --ChocoboRaceUtil.Err( "OnEnterAreaTrigger AreaID = %d", EventParam.AreaID)
            --_G.MsgTipsUtil.ShowTips(LSTR("宝箱出现"))
            ChocoboRaceMainVM:SetIsShowTreasureTips(true)
        end
    end
end

---IsChocoboRacePWorld
---@return boolean
function ChocoboRaceMgr:IsChocoboRacePWorld()
    if PWorldMgr:GetCurrPWorldSubType() == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_CHOCOBO_RACE then
        return true
    end

    return false
end

---IsShowChocoboRacerHUD
---@param EntityID number
---@return boolean
function ChocoboRaceMgr:IsShowChocoboRacerHUD(EntityID)
    if not self:IsChocoboRacePWorld() then
        return false
    end

    local Data = ChocoboRaceMgr:GetRacerData(EntityID)
    --if Data ~= nil and Data.RoleID == 0 then
    --    return true
    --end
    --
    --local Index = self:GetRacerIndexByID(EntityID)
    --return self.AfterCutsceneRacer[Index] == EntityID
    if Data ~= nil then
        return true
    end
    return false
end

---GetServerPathR
---@return table TArray
function ChocoboRaceMgr:GetServerPathR()
    local PathPoints = _G.UE.TArray(_G.UE.FVector)

    if self:IsChocoboRacePWorld() then
        local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
        local PointsData = CurMapEditCfg.PatrolPathList[1].Points
        for i = 1, #PointsData do
            local Point = PointsData[i].Point
            PathPoints:Add(_G.UE.FVector(Point.X, Point.Y, Point.Z))
        end
    end

    return PathPoints
end

---GetServerPathL
---@return table TArray
function ChocoboRaceMgr:GetServerPathL()
    local PathPoints = _G.UE.TArray(_G.UE.FVector)

    if self:IsChocoboRacePWorld() then
        local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
        local PointsData = CurMapEditCfg.PatrolPathList[2].Points
        for i = 1, #PointsData do
            local Point = PointsData[i].Point
            PathPoints:Add(_G.UE.FVector(Point.X, Point.Y, Point.Z))
        end
    end

    return PathPoints
end

---GetRacerByIndex
---@param InIndex number
---@return table
function ChocoboRaceMgr:GetRacerByIndex(InIndex)
    if InIndex == nil then
        InIndex = 1
        for __, Value in pairs(self.ChocoboRacerData) do
            if MajorUtil.IsMajor(Value.EntityID) then
                InIndex = Value.Index
                break
            end
        end
    end

    local Racer = self.ChocoboRacer[InIndex]
    if Racer == nil then
        Racer = ChocoboRaceRacer:New()
        self.ChocoboRacer[InIndex] = Racer
    end

    return Racer
end

function ChocoboRaceMgr:GetGCDDuration()
    if self.GCDDuration then
        return self.GCDDuration
    end

    local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
    local TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_CHOCOBO_RACE_SKILL_GCD)
    if TableData then
        self.GCDDuration = TableData.Value and TableData.Value[1]
    end
    
    return self.GCDDuration or 1500
end

function ChocoboRaceMgr:IterChocoboRacer()
    local IterFunc = function(t, i)
        i = i + 1
        local v = t[i]
        if v then
            return i, v.RoleID or 0, v.EntityID or 0
        end
    end

    return IterFunc, self.ChocoboRacerData or {}, 0
end

function ChocoboRaceMgr:IterChocoboRaceItem()
    local IterFunc = function(t, i)
        i = i + 1
        local v = t[i]
        if v then
            return i, v
        end
    end

    return IterFunc, (self.RaceSetup and self.RaceSetup.Treasure) or {}, 0
end

---SetGameState
---@param Value number ChocoboDefine.GAME_STATE_ENUM
function ChocoboRaceMgr:SetGameState(Value)
    ChocoboRaceUtil.Log(string.format("Game state changed: %s -> %s", self.GameState, Value))
    
    if self.GameState == Value then
        return
    end

    self.GameState = Value
    if self.GameState == ChocoboDefine.GAME_STATE_ENUM.READY then
        CommonUtil.DisableShowJoyStick(true)
        CommonUtil.HideJoyStick()
        ChocoboRaceMainVM.IsShowSkillPanel = false
        ChocoboRaceMainVM.IsShowPanelPlayer = true
        ChocoboRaceMainVM.IsShowMiniMap = true
        ChocoboRaceMainVM.IsShowPanelPhysical = true
        ChocoboRaceMainVM.IsShowPanelNumber = true
        EventMgr:SendEvent(EventID.ChocoboRaceGameReady)
    elseif self.GameState == ChocoboDefine.GAME_STATE_ENUM.BEGIN then
        CommonUtil.DisableShowJoyStick(true)
        CommonUtil.HideJoyStick()
        ChocoboRaceMainVM.IsShowSkillPanel = true
        ChocoboRaceMainVM.IsShowPanelPlayer = true
        ChocoboRaceMainVM.IsShowMiniMap = true
        ChocoboRaceMainVM.IsShowPanelPhysical = true
        ChocoboRaceMainVM.IsShowPanelNumber = true
        EventMgr:SendEvent(EventID.ChocoboRaceGameBegin)
        
        do
            ---陆行鸟竞赛新手引导提示: 使用加速
            local function ShowChocoboRaceSpeedTutorial(Params)
                local EventParams = _G.EventMgr:GetEventParams()
                EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
                EventParams.Param1 = TutorialDefine.GameplayType.Chocobo
                EventParams.Param2 = TutorialDefine.GamePlayStage.ChocoboSpeed
                _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
            end

            local TutorialConfig = { Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowChocoboRaceSpeedTutorial, Params = {} }
            _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
        end

        do
            ---陆行鸟竞赛新手引导提示: 30秒内沒有使用技能引导
            local function DelayTutorialChocoboRaceSkillCallback()
                local function ShowChocoboRaceUseSkillTutorial(Params)
                    local EventParams = _G.EventMgr:GetEventParams()
                    EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
                    EventParams.Param1 = TutorialDefine.GameplayType.Chocobo
                    EventParams.Param2 = TutorialDefine.GamePlayStage.ChocoboUseSkill
                    _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
                end

                local TutorialConfig = { Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowChocoboRaceUseSkillTutorial, Params = {} }
                _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
                if self.DelayTutorialChocoboRaceSkillTimerID ~= nil then
                    self:UnRegisterTimer(self.DelayTutorialChocoboRaceSkillTimerID)
                end
                self.DelayTutorialChocoboRaceSkillTimerID = nil
            end
            self.DelayTutorialChocoboRaceSkillTimerID = self:RegisterTimer(DelayTutorialChocoboRaceSkillCallback, 30)
        end

    elseif self.GameState == ChocoboDefine.GAME_STATE_ENUM.GOAL then
        CommonUtil.DisableShowJoyStick(true)
        CommonUtil.HideJoyStick()
        ChocoboRaceMainVM:UpdateSelfResult()
        EventMgr:SendEvent(EventID.ChocoboRaceGameGoal)
        UIViewMgr:ShowView(UIViewID.ChocoboRaceCountDownView, { Mode = "ARRIVED" })
        if (self.RaceSetup or {}).Mode ~= ProtoCS.ChocoboRaceMode.ChocoboRaceModeChallenge then
            _G.UE.UBGMMgr.Get():Pause()
            local MajorRacer = ChocoboRaceMgr:GetRacerByIndex()
            local Rank = MajorRacer.Ranking or 1
            if Rank == 1 then
                AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), ChocoboDefine.CHOCOBO_RACE_WIN_1ST_SOUND_PATH, true)
            elseif Rank == 2 then
                AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), ChocoboDefine.CHOCOBO_RACE_WIN_2ND_SOUND_PATH, true)
            elseif Rank == 3 then
                AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), ChocoboDefine.CHOCOBO_RACE_WIN_2ND_SOUND_PATH, true)
            else
                AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), ChocoboDefine.CHOCOBO_RACE_LOST_SOUND_PATH, true)
            end
        end
        self:PlayResultSequence()
    elseif self.GameState == ChocoboDefine.GAME_STATE_ENUM.RESULT then
        CommonUtil.DisableShowJoyStick(true)
        CommonUtil.HideJoyStick()
        ChocoboRaceMainVM.IsShowSkillPanel = false
        if UIViewMgr:IsViewVisible(UIViewID.ChocoboRaceMainView) then
            _G.BusinessUIMgr:HideMainPanel(UIViewID.ChocoboRaceMainView)
        end
        if UIViewMgr:IsViewVisible(UIViewID.ChocoboRaceCountDownView) then
            _G.UIViewMgr:HideView(UIViewID.ChocoboRaceCountDownView)
        end
        
        if not UIViewMgr:IsViewVisible(UIViewID.ChocoboRaceResultPanelView) then
            UIViewMgr:ShowView(UIViewID.ChocoboRaceResultPanelView)
        end
        
        -- 没有正在播放，也没有创建
        if not self.IsTickResultSequence and not self.ChocoboCamera then
            self:JumpToFinalFrame()
        end
    end
end

---GetGameState
---@return number ChocoboDefine.GAME_STATE_ENUM
function ChocoboRaceMgr:GetGameState()
    return self.GameState
end

---OpenChocoboRaceNpcChallenge
function ChocoboRaceMgr:OpenChocoboRaceNpcChallenge(ResID, EntityID)
    self:ReqRaceNpcChallengeData(ResID)
end

---IsNpcChallengeByIndex
---@param EntityID number
function ChocoboRaceMgr:IsNpcChallengeByEntityID(EntityID)
    local RacerData = self:GetRacerData(EntityID)
    local Ret = false
    if RacerData ~= nil then
        Ret = ChocoboRaceMainVM:IsNpcChallengeByIndex(RacerData.Index)
    end
    
    return Ret
end

function ChocoboRaceMgr:IsAfterCutsceneByEntityID(EntityID)
    if MajorUtil.IsMajor(EntityID) then
        return true
    end

    if self:GetGameState() >= ChocoboDefine.GAME_STATE_ENUM.BEGIN then
        return true
    end
    
    local RacerData = self:GetRacerData(EntityID)
    if RacerData then
        if RacerData.RoleID == 0 then
            return true
        end

        local Index = RacerData.Index
        return self.AfterCutsceneRacer[Index] == EntityID
    end

    return false
end

function ChocoboRaceMgr:GetInterpolatedValue(Timeline, CurrentFrame)
    if #Timeline == 0 then return 0 end

    if CurrentFrame <= Timeline[1].Time then
        return Timeline[1].Value
    end

    if CurrentFrame >= Timeline[#Timeline].Time then
        return Timeline[#Timeline].Value
    end

    -- 线性插值
    for i = 2, #Timeline do
        if CurrentFrame <= Timeline[i].Time then
            local Prev = Timeline[i-1]
            local Curr = Timeline[i]
            local t = (CurrentFrame - Prev.Time) / (Curr.Time - Prev.Time)
            return Prev.Value + (Curr.Value - Prev.Value) * t
        end
    end

    return Timeline[#Timeline].Value
end

function ChocoboRaceMgr:PlayResultSequence()
    ChocoboRaceUtil.Log("PlayResultSequence PlayResultSequence PlayResultSequence ")
    if self.IsTickResultSequence or self.ChocoboCamera then
        return
    end

    -- 初始化摄像机
    self.ElapsedFrames = 0
    self.ChocoboCamera = CommonUtil.SpawnActor(_G.UE.AChocoboRaceCamera, _G.UE.FVector(0, 0, 0), _G.UE.FRotator(0, 0, 0))
    if not self.ChocoboCamera then return end

    local MajorActor = MajorUtil.GetMajor()
    local MajorPos = MajorActor and MajorActor:FGetActorLocation() or _G.UE.FVector(0, 0, 0)

    -- 摄像机初始设置
    self.ChocoboCamera:SetRootLocation(MajorPos, false)
    self.ChocoboCamera:SetSocketOffset(_G.UE.FVector(0, 0, 0), false)
    self.ChocoboCamera:Rotate(_G.UE.FRotator(0, -180, 0), false)
    self.ChocoboCamera:SwitchCollision(false)

    -- 切换摄像机
    _G.UE.UCameraMgr.Get():SwitchCamera(self.ChocoboCamera, 0)
    self.ChocoboCamera:SetFOVY(20)

    -- 启动Tick
    _G.UE.FTickHelper.GetInst():SetTickIntervalByFrame(self.TickTimerID, 1)
    _G.UE.FTickHelper.GetInst():SetTickEnable(self.TickTimerID)
    self.IsTickResultSequence = true
end

function ChocoboRaceMgr:TickResultSequence()
    if not (self.IsTickResultSequence and self.ChocoboCamera) then return end

    self.ElapsedFrames = (self.ElapsedFrames or 0) + 1
    if self.ElapsedFrames > ChocoboRaceUtil.MaxAnimationFrames then
        self:StopResultSequence()
        return
    end

    local MajorActor = MajorUtil.GetMajor()
    if not MajorActor then return end

    -- 批量插值计算
    local Interpolations = {
        ArmLength = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.CraneArmLength, self.ElapsedFrames),
        Pitch = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.CranePitch, self.ElapsedFrames),
        Yaw = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.CraneYaw, self.ElapsedFrames),
        OffsetX = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.LocationX, self.ElapsedFrames),
        OffsetY = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.LocationY, self.ElapsedFrames),
        OffsetZ = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.LocationZ, self.ElapsedFrames)
    }

    -- 计算摄像机位置
    local MajorPos = MajorActor:FGetActorLocation()
    local MajorRot = MajorActor:FGetActorRotation()
    local WorldOffset = MajorRot:RotateVector(_G.UE.FVector(
            Interpolations.OffsetX,
            Interpolations.OffsetY,
            Interpolations.OffsetZ
    ))

    -- 更新摄像机
    self.ChocoboCamera:SetRootLocation(MajorPos + WorldOffset)
    self.ChocoboCamera:UpdateCraneComponents(
            Interpolations.Pitch,
            Interpolations.Yaw + MajorRot.Yaw,
            Interpolations.ArmLength
    )
end

function ChocoboRaceMgr:StopResultSequence()
    self.IsTickResultSequence = false
    _G.UE.FTickHelper.GetInst():SetTickIntervalByFrame(self.TickTimerID, 10)
end

function ChocoboRaceMgr:JumpToFinalFrame()
    self:StopResultSequence()

    if not self.ChocoboCamera then
        self.ChocoboCamera = CommonUtil.SpawnActor(_G.UE.AChocoboRaceCamera, _G.UE.FVector(0, 0, 0), _G.UE.FRotator(0, 0, 0))
        if not self.ChocoboCamera then return end
    end
    
    local MajorActor = MajorUtil.GetMajor()
    if not MajorActor then
        return
    end

    -- 获取最终帧数值
    local FinalFrame = ChocoboRaceUtil.MaxAnimationFrames
    local Interpolations = {
        ArmLength = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.CraneArmLength, FinalFrame),
        Pitch = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.CranePitch, FinalFrame),
        Yaw = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.CraneYaw, FinalFrame),
        OffsetX = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.LocationX, FinalFrame),
        OffsetY = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.LocationY, FinalFrame),
        OffsetZ = self:GetInterpolatedValue(ChocoboRaceUtil.AnimationCurves.LocationZ, FinalFrame)
    }

    local MajorPos = MajorActor:FGetActorLocation()
    local MajorRot = MajorActor:FGetActorRotation()
    local WorldOffset = MajorRot:RotateVector(_G.UE.FVector(
            Interpolations.OffsetX,
            Interpolations.OffsetY,
            Interpolations.OffsetZ
    ))

    self.ChocoboCamera:SetRootLocation(MajorPos + WorldOffset)
    self.ChocoboCamera:UpdateCraneComponents(
            Interpolations.Pitch,
            Interpolations.Yaw + MajorRot.Yaw,
            Interpolations.ArmLength
    )

    -- 同步摄像机切换
    self.ChocoboCamera:SetSocketOffset(_G.UE.FVector(0, 0, 0), false)
    self.ChocoboCamera:Rotate(_G.UE.FRotator(0, -180, 0), false)
    self.ChocoboCamera:SwitchCollision(false)
    _G.UE.UCameraMgr.Get():SwitchCamera(self.ChocoboCamera, 0)
    self.ChocoboCamera:SetFOVY(20)
end

------------------------------------ 下面是给测试用的GM --------------------------------------------------
function ChocoboRaceMgr:PlayEffect(EffectID)
    if self:IsChocoboRacePWorld() then
        local Racer = self:GetRacerByIndex()
        if Racer then
            Racer:PlayEffect(EffectID)
        end
    end

    local Cfg = ChocoboRaceVfxCfg:FindCfgByKey(EffectID)
    if Cfg == nil then
        return
    end

    local VfxPath = Cfg.Path
    if string.isnilorempty(VfxPath) then
        return
    end

    local Actor = ActorUtil.GetActorByEntityID(MajorUtil.GetMajorEntityID())
    if Actor == nil then return end

    local FrontPart = string.sub(VfxPath, 1, #VfxPath - 1)
    local BehindPart = string.sub(VfxPath, #VfxPath)
    local BeUsedPath = string.format("%s_C%s", FrontPart, BehindPart)

    local VfxParameter = _G.UE.FVfxParameter()
    VfxParameter.VfxRequireData.VfxTransform = Actor:GetTransform()
    VfxParameter.VfxRequireData.EffectPath = BeUsedPath
    VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_URideComponent
    if Cfg.BindType == ProtoRes.CHOCOBO_RACE_VFX_BIND_TYPE.CHOCOBO_RACE_VFX_BIND_NULL then
        VfxParameter.VfxTransform = Actor:FGetActorTransform()
    elseif Cfg.BindType == ProtoRes.CHOCOBO_RACE_VFX_BIND_TYPE.CHOCOBO_RACE_VFX_BIND_CASTER then
        VfxParameter:SetCaster(Actor, 0, _G.UE.EVFXAttachPointType.AttachPointType_AvatarPartType, _G.UE.EAvatarPartType.RIDE_MASTER)
    elseif Cfg.BindType == ProtoRes.CHOCOBO_RACE_VFX_BIND_TYPE.CHOCOBO_RACE_VFX_BIND_TARGET then
        VfxParameter:AddTarget(Actor, 0, _G.UE.EVFXAttachPointType.AttachPointType_AvatarPartType, _G.UE.EAvatarPartType.RIDE_MASTER)
    end
    
    local AudioPath = Cfg.AudioPath
    if not string.isnilorempty(AudioPath) then
        AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), AudioPath, true)
    end
    EffectUtil.PlayVfx(VfxParameter)
end

function ChocoboRaceMgr:PlaySkill(SkillID)
    local SkillCfg = ChocoboRaceSkillCfg:FindCfgByKey(SkillID)
    if SkillCfg then
        local StatusKeys = {
            SkillCfg.InvocationStatus,
            SkillCfg.HitStatus
        }

        for _, StatusKey in ipairs(StatusKeys) do
            if StatusKey and StatusKey ~= 0 then
                local StatusData = ChocoboRaceStatusCfg:FindCfgByKey(StatusKey)
                if StatusData then
                    self:PlayEffect(StatusData.InvocationEffect)
                    self:PlayEffect(StatusData.LoopEffect)
                end
            end
        end
    end
end

function ChocoboRaceMgr:SetBuff(BuffID, Flag)
    local Racer = self:GetRacerByIndex()
    if Racer then
        Racer:SetBuff(BuffID, Flag)
    end
end

function ChocoboRaceMgr:ShowArea()
    local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    if PWorldDynDataMgr == nil then
        return
    end

    local MapDynDatas = PWorldDynDataMgr.MapDynDatas
    if MapDynDatas == nil then
        return
    end

    for _, DynData in ipairs(MapDynDatas) do
        if DynData.DataType == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_AREA then
            local Rotator = DynData.Rotator
            local Extent = DynData.Extent
            local Center = _G.UE.FVector(DynData.Location.X, DynData.Location.Y, DynData.Location.Z - Extent.Z)
            _G.UE.UChocoboRaceMgr.Get():DebugDrawBoxSurface(Center, Extent, Rotator, 180)
            _G.UE.UKismetSystemLibrary.DrawDebugBox(_G.FWORLD(), DynData.Location, DynData.Extent, _G.UE.FLinearColor(0, 1, 0, 1), DynData.Rotator, 180, 4)
        end
    end
end

function ChocoboRaceMgr:ShowPath()
    _G.UE.UChocoboRaceMgr.Get():DebugDrawPathPoints()
end

function ChocoboRaceMgr:ShowDecArea()
    local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    if PWorldDynDataMgr == nil then
        return
    end

    local MapDynDatas = PWorldDynDataMgr.MapDynDatas
    if MapDynDatas == nil then
        return
    end

    local AreaID = {
        5653548, 5653549, 5653548, 5653549, 5653839, 5653847, 5653867, 5653869, 5653548, 5653549, 5653839, 5653847,
        5653867, 5653869, 5653548, 5653549, 5653839, 5653847, 5653867, 5653869, 5653548, 5653549, 5653839, 5653847,
        5653867, 5653869, 5653548, 5653549, 5653839, 5653847, 5653867, 5653869, 5653548, 5653549, 5653839, 5653847,
        5653867, 5653869, 5653548, 5653549, 5653839, 5653847, 5653867, 5653869, 5653548, 5653549, 5653839, 5653847,
        5653867, 5653869, 5653548, 5653549, 5653839, 5653847, 5653867, 5653869, 5653548, 5653549, 5653839, 5653847,
        5653867, 5653869, 5653548, 5653549, 5653839, 5653847, 5653867, 5653869, 5653548, 5653549, 5653839, 5653847,
        5653867, 5653869, 5653548, 5653549, 5653839, 5653847, 5653867, 5653869, 5653867, 5653869, 5653839, 5653847,
        5653548, 5653549, 5653867, 5653869, 5653839, 5653847, 5653548, 5653549, 5653839, 5653847, 5653867, 5653869,
        5653548, 5653549, 5653839, 5653847, 5653548, 5653549, 5653867, 5653869, 5653548, 5653549, 5653839, 5653847,
        5653867, 5653869,
    }

    for _, DynData in ipairs(MapDynDatas) do
        for i = 1, #AreaID do
            if DynData.ID == AreaID[i] then
                local Rotator = DynData.Rotator
                local Extent = DynData.Extent
                local Center = _G.UE.FVector(DynData.Location.X, DynData.Location.Y, DynData.Location.Z - Extent.Z)
                _G.UE.UChocoboRaceMgr.Get():DebugDrawBoxSurface(Center, Extent, Rotator, 180)
                _G.UE.UKismetSystemLibrary.DrawDebugBox(_G.FWORLD(), DynData.Location, DynData.Extent, _G.UE.FLinearColor(0, 1, 0, 1), DynData.Rotator, 180, 4)
            end
        end
    end
end

function ChocoboRaceMgr:PlayAtl(ActionTimelineID, IsChocobo)
    local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
    local AnimComp = ActorUtil.GetActorAnimationComponent(MajorUtil.GetMajorEntityID())
    if AnimComp == nil then
        return
    end

    if IsChocobo then
        local PathCfg = ActiontimelinePathCfg:FindCfgByKey(ActionTimelineID)
        local ActionTimelinePath = AnimComp:GetActionTimeline(PathCfg.Filename)
        AnimComp:PlayAnimation(ActionTimelinePath, 1.0, 0.25, 0.25, true, _G.UE.EAvatarPartType.RIDE_MASTER)
    else
        AnimComp:PlayActionTimeline(ActionTimelineID)
    end
end

function ChocoboRaceMgr:EnterRace()
    _G.GMMgr:ReqGM("entertain race matchrace 1216001 1")
end

function ChocoboRaceMgr:OpenChocoboRaceGMPanel()
    if _G.UIViewMgr:IsViewVisible(_G.UIViewID.ChocoboRaceMainView) then
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.ChocoboRaceGMTargetInfoView) then
            _G.UIViewMgr:HideView(_G.UIViewID.ChocoboRaceGMTargetInfoView)
        else
            _G.UIViewMgr:ShowView(_G.UIViewID.ChocoboRaceGMTargetInfoView)
        end
    end
end

return ChocoboRaceMgr