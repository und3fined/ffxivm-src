--
-- Author: frankjfwang
-- Date: 2021-12-05
-- Description:共鸣水晶
--

local LuaClass = require("Core/LuaClass")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local EffectUtil = require("Utils/EffectUtil")
local AudioUtil = require("Utils/AudioUtil")
local ActorUtil = require("Utils/ActorUtil")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local SingstateCfg = require("TableCfg/SingstateCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local CommonVfxCfg = require("TableCfg/CommonVfxCfg")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local TELEPORT_CRYSTAL_TYPE = ProtoRes.TELEPORT_CRYSTAL_TYPE

--local LuaEntranceType = _G.LuaEntranceType

local CS_TELEPORT_CRYSTAL_CMD = ProtoCS.CS_CMD.CS_CMD_TELEPORT_CRYSTAL
local CS_TELEPORT_CRYSTAL_SUBMSG = ProtoCS.CS_SUBMSGID_TELEPORT_CRYSTAL
local CS_CMD_TRAVEL = ProtoCS.CS_CMD.CS_CMD_TRAVEL
local CS_CMD_INTERAVIVE = ProtoCS.CS_CMD.CS_CMD_INTERAVIVE
local CsInteractionCMDSpellChg = ProtoCS.CsInteractionCMD.CsInteractionCMDSpellChg
local MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local CommBehaviorID = ProtoCommon.CommBehaviorID

local STATUS_ACTIVED = 0
local STATUS_UNACTIVED = 1
local STATUS_ACTIVING_SUCCESS = 2

-- 传送交互id，分同地图、跨地图，见交互表配置
local TransferInterativeIDSameMap = 10003
local TransferInterativeIDAcrossMap = 100002

-- 系统提示"当前城内以太之晶已自动激活，主城的各个大门和飞艇坪的传送已开放"
local TEXT_CRYSTAL_AUTO_UNLOCK_ID = 40293
-- 系统提示"当前城内以太之晶已全部激活，主城的各个大门和飞艇坪的传送已开放"
local TEXT_CRYSTAL_ALL_UNLOCK_ID = 40294

-- 未激活任务错误ID
local UnActiviteQuestErrorID = 107014

---@class CrystalPortalInfo
local CrystalPortalInfo = LuaClass()

function CrystalPortalInfo:Ctor()
    self.ResID = 0
    self.EntityID = 0
    self.Pos = nil
    self.DBConfig = nil
    self.IsActivated = false
end

---@class CrystalPortalMgr
---@field CrystalList CrystalPortalInfo[] 对应当前MapID的水晶列表
---@field ActivatedList integer[] 已激活水晶EntityID列表
local CrystalPortalMgr = {}

function CrystalPortalMgr:OnInit()
    FLOG_INFO("CrystalPortalMgr:OnInit")
    self.ActivatedList = {}
    self.ActivedGroupList = {} --激活的水晶组（激活不代表大水晶也激活）
    self.IsTransferring = false
    self.AllCrystalsInGroup = {}
    self.EnterCrystalList = {}
    self.AllCfgByGroup = {} --水晶配置,禁止修改
    self:InitCfg()
end

function CrystalPortalMgr:OnShutdown()
    self.ActivatedList = nil
    self.ActivedGroupList = nil
    if self.SingTimerID then
        _G.TimerMgr:CancelTimer(self.SingTimerID)
        self.SingTimerID = nil
    end
    if self.FadeTimerID then
        _G.TimerMgr:CancelTimer(self.FadeTimerID)
        self.FadeTimerID = nil
    end
    self.IsCurrentTransfer = false
    self.IsTransferring = false
    self.AllCfgByGroup = nil
end

function CrystalPortalMgr:RegisterGameNetMsg(PWorldMgr)
    FLOG_INFO("CrystalPortalMgr:RegisterGameNetMsg")
    PWorldMgr:RegisterGameNetMsg(CS_TELEPORT_CRYSTAL_CMD, CS_TELEPORT_CRYSTAL_SUBMSG.CRYSTAL_INFO,
        function(_, MsgBody) self:OnNetMsgQueryInfoRsp(MsgBody) end)
    PWorldMgr:RegisterGameNetMsg(CS_TELEPORT_CRYSTAL_CMD, CS_TELEPORT_CRYSTAL_SUBMSG.ACTIVATE_CRYSTAL,
        function(_, MsgBody) self:OnNetMsgActivateRsp(MsgBody) end)
    PWorldMgr:RegisterGameNetMsg(CS_TELEPORT_CRYSTAL_CMD, CS_TELEPORT_CRYSTAL_SUBMSG.ACTIVATE_NTF,
        function(_, MsgBody) self:OnNetMsgActivateNtf(MsgBody) end)
    PWorldMgr:RegisterGameNetMsg(CS_TELEPORT_CRYSTAL_CMD, CS_TELEPORT_CRYSTAL_SUBMSG.TRANSFER,
        function(_, MsgBody) self:OnNetMsgTransferRsp(MsgBody) end)
    PWorldMgr:RegisterGameNetMsg(CS_TELEPORT_CRYSTAL_CMD, CS_TELEPORT_CRYSTAL_SUBMSG.TRANSFER_NTF,
        function(_, MsgBody) self:OnNetMsgTransferNtf(MsgBody) end)
    PWorldMgr:RegisterGameNetMsg(CS_CMD_INTERAVIVE, CsInteractionCMDSpellChg,
        function(_, MsgBody) self:OnNetMsgInteractive(MsgBody) end)
        PWorldMgr:RegisterGameNetMsg(CS_TELEPORT_CRYSTAL_CMD, CS_TELEPORT_CRYSTAL_SUBMSG.CROSS_WORLD_TRANSFER,
        function(_, MsgBody) self:OnNetMsgCrossWorld(MsgBody) end)
end

function CrystalPortalMgr:OnRegisterGameEvent(PWorldMgr)
    PWorldMgr:RegisterGameEvent(EventID.MajorSingBarOver, function(_, EntityID, IsBreak, SingStateID) self:OnMajorSingBarOver(EntityID, IsBreak, SingStateID) end)
    PWorldMgr:RegisterGameEvent(EventID.MajorSingBarBegin, function(_, EntityID, SingStateID) self:OnMajorSingBarBegin(EntityID, SingStateID) end)
    PWorldMgr:RegisterGameEvent(EventID.OthersSingBarOver, function(_, EntityID, IsBreak, SingStateID) self:OnOthersSingBarOver(EntityID, IsBreak, SingStateID) end)
    PWorldMgr:RegisterGameEvent(EventID.OthersSingBarBegin, function(_, EntityID, SingStateID) self:OnOthersSingBarBegin(EntityID, SingStateID) end)
    PWorldMgr:RegisterGameEvent(EventID.PWorldMapEnter, function(_) self:OnPWorldMapEnter() end)
    PWorldMgr:RegisterGameEvent(EventID.PWorldMapExit, function(_) self:OnPWorldMapExit() end)
    PWorldMgr:RegisterGameEvent(EventID.PWorldTransBegin, function(_, IsOnlyChangeLocation) self:OnPWorldTransBegin(IsOnlyChangeLocation) end)
    --PWorldMgr:RegisterGameEvent(EventID.VisionEnter, function(_, Params) self:OnVisionEnter(Params) end)
    PWorldMgr:RegisterGameEvent(EventID.ActorVelocityUpdate, function(_, Params) self:OnActorVelocityUpdate(Params) end)
    PWorldMgr:RegisterGameEvent(EventID.InteractiveReqEndError, function(_) self:OnInteractiveReqEndError() end)
    PWorldMgr:RegisterGameEvent(EventID.NetworkReconnected, function(_) self:OnRelayConnected() end)
end

function CrystalPortalMgr:OnLoginRsp()
    -- 登录结束后拉取角色激活的水晶列表
    self:SendCrystalInfoReq()
end

function CrystalPortalMgr:OnMapLoaded(MapResID)
    -- Load config for this MapID
    local CrystalCfgsByMap =  CrystalPortalCfg:FindAllCfg(string.format("MapID = %d", MapResID))
    if not CrystalCfgsByMap or #CrystalCfgsByMap == 0 then
        FLOG_INFO("CrystalPortalMgr:Init no crystals configured in map "..tostring(MapResID))
        return
    end

    self.AllCrystalsInGroup = {}
    for _, CfgByMap in pairs(CrystalCfgsByMap) do
        if CfgByMap.GroupID then
            local CrystalCfgsByGroup = CrystalPortalCfg:FindAllCfg(string.format("GroupID = %d", CfgByMap.GroupID))
            if CrystalCfgsByGroup then
                for _, CfgByGroup in pairs(CrystalCfgsByGroup) do
                    if not self:FindSameID(self.AllCrystalsInGroup, CfgByGroup.ID) then
                        table.insert(self.AllCrystalsInGroup, CfgByGroup)
                    end
                end
            end
        else
            if not self:FindSameID(self.AllCrystalsInGroup, CfgByMap.ID) then
                table.insert(self.AllCrystalsInGroup, CfgByMap)
            end
        end
    end

    self.CurrentTransferInteractiveID = 0
    self.CurrentActivateCrystal = nil
    self.CrystalList = {}

    for _, c in ipairs(self.AllCrystalsInGroup) do
        local Crystal = CrystalPortalInfo:New()
        Crystal.DBConfig = c
        Crystal.EntityID = c.ID
        Crystal.ResID = c.CrystalID
        Crystal.Pos = _G.UE.FVector(c.X, c.Y, c.Z)

        --[sammrli] 相同地图，才创建触发器
        if c.MapID == MapResID and (c.Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP or c.Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP) then
            -- add trigger
            Crystal.TriggerActor = _G.CommonUtil.SpawnActor(_G.UE.ATriggerSphere.StaticClass(), Crystal.Pos)
            if Crystal.TriggerActor then
                local CollisionComponent = Crystal.TriggerActor:GetComponentByClass(_G.UE.USphereComponent)
                if CollisionComponent then
                    local SphereComp = CollisionComponent:Cast(_G.UE.USphereComponent)
                    if SphereComp then
                        SphereComp:SetSphereRadius(c.Distance)
                    end
                    CollisionComponent:SetCollisionProfileName("OnlyTriggerPawn")
                end

                local function OnActorBeginOverlap(_, _, Target)
                    local Major = Target:Cast(_G.UE.AMajorCharacter)
                    if Major then
                        self:OnInteractiveBegin(Major, Crystal)
                    end
                end
                Crystal.TriggerActor.OnActorBeginOverlap:Add(Crystal.TriggerActor, OnActorBeginOverlap)

                local function OnActorEndOverlap(_, _, Target)
                    local Major = Target:Cast(_G.UE.AMajorCharacter)
                    if Major then
                        self:OnInteractiveEnd(Major, Crystal)
                    end
                end
                Crystal.TriggerActor.OnActorEndOverlap:Add(Crystal.TriggerActor, OnActorEndOverlap)
            end
        end

        table.insert(self.CrystalList, Crystal)
    end


    -- Sync crystal activated info
    if self.ActivatedList then
        for _, c in ipairs(self.CrystalList) do
            c.IsActivated = self.ActivatedList[c.EntityID] or false
        end
    end

    -- 处理水晶比角色后创建的情况
    local Major = MajorUtil.GetMajor()
    if Major then
        for _, Crystal in pairs(self.CrystalList) do
            if Crystal and Crystal.TriggerActor and Crystal.TriggerActor:IsOverlappingActor(Major) then
                local Params = _G.EventMgr:GetEventParams()
                Params.IntParam1 = _G.LuaEntranceType.CRYSTAL
                Params.ULongParam1 = Crystal.EntityID
                _G.EventMgr:SendEvent(_G.EventID.EnterInteractionRange, Params)
                break
            end
        end
    end
end

function CrystalPortalMgr:ResetMap()
    if self.CrystalList then
        for _, c in ipairs(self.CrystalList) do
            if c.TriggerActor then
                _G.CommonUtil.DestroyActor(c.TriggerActor)
            end
        end
        self.CrystalList = nil
    end
end

function CrystalPortalMgr:InitCfg()
    table.clear(self.AllCfgByGroup)
    local AllCfg = CrystalPortalCfg:FindAllCfg()
    for _, Cfg in ipairs(AllCfg) do
        local GroupID = Cfg.GroupID
        if not self.AllCfgByGroup[GroupID] then
            self.AllCfgByGroup[GroupID] = {}
        end
        table.insert(self.AllCfgByGroup[GroupID], Cfg)
    end
end

function CrystalPortalMgr:TransferFadeIn(EntityID, IsPlayEffectAndSound)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        Actor:StartFadeIn(0.5, true)
        if IsPlayEffectAndSound then
            local MeshComp = Actor:GetMeshComponent()
            if MeshComp then
                local VfxCfgItem = CommonVfxCfg:FindCfgByKey(110)
                if VfxCfgItem then
                    local VfxParameter = _G.UE.FVfxParameter()
                    VfxParameter.VfxRequireData.EffectPath = CommonUtil.ParseBPPath(VfxCfgItem.Path)
                    VfxParameter.VfxRequireData.VfxTransform = Actor:FGetActorTransform()
                    VfxParameter.PlaySourceType= _G.UE.EVFXPlaySourceType.PlaySourceType_AetherCurrents
                    local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
                    VfxParameter:SetCaster(Actor, 0, AttachPointType_Body, 0)

                    EffectUtil.PlayVfx(VfxParameter)
                end
            end
            local AudioMgr = _G.UE.UAudioMgr:Get()
            if AudioMgr then
                AudioMgr:LoadAndPostEvent(
                    "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/SE_VFX_LBK_ExtremeTech/Play_SE_VFX_sys_telepo_appear.Play_SE_VFX_sys_telepo_appear'",
                    Actor, false)
            end
        end
        local Companion = Actor:GetCompanionComponent():GetCompanion()
        if Companion then
            Companion:SetVisibility(true, _G.UE.EHideReason.Transfer, true)
            local VfxCfgItem = CommonVfxCfg:FindCfgByKey(167)
            if VfxCfgItem then
                local VfxParameter = _G.UE.FVfxParameter()
                VfxParameter.VfxRequireData.EffectPath = CommonUtil.ParseBPPath(VfxCfgItem.Path)
                VfxParameter.VfxRequireData.VfxTransform = Companion:FGetActorTransform()
                local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
                VfxParameter:SetCaster(Companion, 0, AttachPointType_Body, 0)
                EffectUtil.PlayVfx(VfxParameter)
            end
        end
    end
    local ActorVM = _G.HUDMgr:GetActorVM(EntityID)
    if ActorVM then
        ActorVM:UpdateIsDraw(true)
    end
end

function CrystalPortalMgr:TransferFadeOut(EntityID)
    self.FadeTimerID = _G.TimerMgr:AddTimer(self, function()
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor then
            local Companion = Actor:GetCompanionComponent():GetCompanion()
            if Companion then
                Companion:SetVisibility(false, _G.UE.EHideReason.Transfer, true)
            end
        end
        local ActorVM = _G.HUDMgr:GetActorVM(EntityID)
        if ActorVM then
            ActorVM:UpdateIsDraw(false)
        end
    end, 0.5)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        Actor:StartFadeOut(0.5, 0)
        if not _G.MountMgr:IsInRide() then
            local Companion = Actor:GetCompanionComponent():GetCompanion()
            if Companion then
                local VfxCfgItem = CommonVfxCfg:FindCfgByKey(168)
                if VfxCfgItem then
                    local VfxParameter = _G.UE.FVfxParameter()
                    VfxParameter.VfxRequireData.EffectPath = CommonUtil.ParseBPPath(VfxCfgItem.Path)
                    VfxParameter.VfxRequireData.VfxTransform = Companion:FGetActorTransform()
                    local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
                    VfxParameter:SetCaster(Companion, 0, AttachPointType_Body, 0)
                    EffectUtil.PlayVfx(VfxParameter)
                end
            end
        end
    end
end

function CrystalPortalMgr:GetCrystalByEntityId(EntityID)
    if self.CrystalList == nil then return nil end
    for _, c in ipairs(self.CrystalList) do
        if c.EntityID == EntityID then
            return c
        end
    end
    return nil
end

-- 查找给定位置给定距离内的最近水晶
---@param FindDistance number 查找距离
---@param IsActivated boolean 是否查找激活的水晶
---@param FindPos FVector 查找的位置，如果参数空则用主角位置
---@return CrystalPortalInfo
function CrystalPortalMgr:FindCrystalByDistance(FindDistance, IsActivated, FindPos)
    if FindPos == nil then
        local MajorActor = MajorUtil.GetMajor()
        if MajorActor ~= nil  then
            FindPos = MajorActor:FGetActorLocation()
        end
    end
    if FindPos == nil then
        return
    end

    if self.CrystalList == nil then
        return
    end

    local ClosestDistance = math.huge
    local ClosestCrystal

    local CurrMapID = _G.PWorldMgr:GetCurrMapResID()

    for _, Crystal in pairs(self.CrystalList) do
        if Crystal and Crystal.DBConfig.DisplayOrder > 0 and Crystal.IsActivated == IsActivated and Crystal.DBConfig.MapID == CurrMapID then
            local Distance = _G.UE.FVector.Dist(FindPos, Crystal.Pos)
            if Distance < FindDistance and Distance < ClosestDistance then
                ClosestDistance = Distance
                ClosestCrystal = Crystal
            end
        end
    end

    return ClosestCrystal
end

---是否存在激活的水晶
---@param EntityID 实体ID
---@return boolean
function CrystalPortalMgr:IsExistActiveCrystal(EntityID)
    if self.ActivatedList then
         return self.ActivatedList[EntityID] ~= nil
    end
    return false
end

---是否存在激活的组别
---@param GroupID number
---@return boolean
function CrystalPortalMgr:IsExistActiveGroup(GroupID)
    return self.ActivedGroupList[GroupID]
end

---是否全部小水晶激活(地图没有小水晶返回false)
---@param MapID number
---@return boolean
function CrystalPortalMgr:IsAllSamllCrystalActivated(MapID)
    local CrystalCfgsByMap =  CrystalPortalCfg:FindAllCfg(string.format("MapID = %d", MapID))
    if CrystalCfgsByMap then
        local Cfg = CrystalCfgsByMap[1] --主城不会有多组水晶,直接取第一个做判断
        if Cfg then
            return self:IsExistActiveGroup(Cfg.GroupID)
        end
    end
    return false
end

---获取激活并且同组的水晶（可以不同地图）
---@param GroupID number
---@return CrystalPortalInfo[]
function CrystalPortalMgr:GetAllActivatedCrystalsByGroup(GroupID)
    local ActivatedList = {}
    if not self.CrystalList then --未初始化
        return ActivatedList
    end
    for _, c in ipairs(self.CrystalList) do
        if c.IsActivated and c.DBConfig.GroupID == GroupID and c.DBConfig.TransferInterativeID ~= 0 then
            table.insert(ActivatedList, c)
        end
    end

    local function SortAllActivatedCrystalsInMap(Left, Right)
        if Left.DBConfig.DisplayOrder ~= Right.DBConfig.DisplayOrder then
            return Left.DBConfig.DisplayOrder < Right.DBConfig.DisplayOrder
        end
        return false
    end

    table.sort(ActivatedList,SortAllActivatedCrystalsInMap)
    return ActivatedList
end

---获取当前地图激活的水晶ID列表
---@return table<number>
function CrystalPortalMgr:GetActivatedCrystalsIDListForCurrMap()
    local IDList = {}
    if self.CrystalList then
        for _, c in pairs(self.CrystalList) do
            if c.IsActivated then
                table.insert(IDList, c.EntityID)
            end
        end
    end
    return IDList
end

--获取所有激活的水晶ID列表
---@return table<number>
function CrystalPortalMgr:GetActivatedList()
    return self.ActivatedList
end


---获取是否正在传送
---@return boolean
function CrystalPortalMgr:GetIsTransferring()
    return self.IsTransferring
end

function CrystalPortalMgr:OnPWorldMapEnter()
    if self.IsCurrentTransfer then
        self.IsCurrentTransfer = false
        self.IsMajorFadeOut = false
        self:PlayTransferInEffect(MajorUtil.GetMajorEntityID())
    end
    self.IsTransferring = false
    self:UpdateCrystalDynData()
end

function CrystalPortalMgr:OnPWorldMapExit()
    table.clear(self.EnterCrystalList)
end

function CrystalPortalMgr:OnPWorldTransBegin(IsOnlyChangeLocation)
    if IsOnlyChangeLocation then --只是位置改变,不会走MapEnter逻辑,这里处理淡入特效
        if self.IsCurrentTransfer then
            self.IsCurrentTransfer = false
            self.IsMajorFadeOut = false
            self:PlayTransferInEffect(MajorUtil.GetMajorEntityID())
        end
        self.IsTransferring = false
    end
end

function CrystalPortalMgr:OnActorVelocityUpdate(Params)
    -- 兜底方案,如果断线,这里移动恢复可见
    if self.IsCurrentTransfer and self.IsMajorFadeOut then
        local EntityID = Params.ULongParam1
        local bVelocityIsZero = Params.BoolParam1
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        if EntityID == MajorEntityID and not bVelocityIsZero then
            self.IsMajorFadeOut = false
            self:TransferFadeIn(EntityID, false)
        end
    end
end

function CrystalPortalMgr:PlayTransferInEffect(EntityID)
    self:TransferFadeIn(EntityID, true)
end

--- 由交互界面触发的同地图传送
---@param FromCrystal CrystalPortalInfo
---@param ToCrystal CrystalPortalInfo
function CrystalPortalMgr:TransferByInteractive(FromCrystal, ToCrystal)
    self.CurrentTransferInteractiveID = TransferInterativeIDSameMap
    self:SendTransferReq(FromCrystal.EntityID, ToCrystal.EntityID)

    _G.EventMgr:SendEvent(EventID.CrystalTransferReq)
end

--- 由大地图界面触发的跨地图传送
function CrystalPortalMgr:TransferByMap(ToEntityID)
    -- 临时代码，后续在表格中增加禁止传送 2025-4-18
    if (_G.GoldSauserLeapOfFaithMgr ~= nil and _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
        local MsgID = 146078
        MsgTipsUtil.ShowTipsByID(MsgID)
        return false
    end
    local FromCrystalID = self:__GetCurrentMapBigCrystalID()
    local CrystalPortalCfgItem = CrystalPortalCfg:FindCfgByKey(ToEntityID)
    if CrystalPortalCfgItem then
        local Type = CrystalPortalCfgItem.Type
        if Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP or
            Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP then
            if self:IsExistActiveCrystal(ToEntityID) then
                self.CurrentTransferInteractiveID = TransferInterativeIDAcrossMap
                if self:SendTransferReq(FromCrystalID, ToEntityID) then
                    _G.EventMgr:SendEvent(EventID.CrystalTransferReq)
                    return true
                end  
                return false
            else
                MsgTipsUtil.ShowErrorTips(LSTR(540001)) --540001=无法发动传送，没有开启过指定的以太之光。
            end
        elseif Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_MINI_MAP then
            if self:IsExistActiveGroup(CrystalPortalCfgItem.GroupID) then
                self.CurrentTransferInteractiveID = TransferInterativeIDAcrossMap
                if self:SendTransferReq(FromCrystalID, ToEntityID) then
                    _G.EventMgr:SendEvent(EventID.CrystalTransferReq)
                end
                return true
            end
        elseif Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_DEFAULT_OPEN then
            self.CurrentTransferInteractiveID = TransferInterativeIDAcrossMap
            if self:SendTransferReq(FromCrystalID, ToEntityID) then
                _G.EventMgr:SendEvent(EventID.CrystalTransferReq)
            end
        end
    end
    return false
end

---私有：获取当前地图大水晶ID
function CrystalPortalMgr:__GetCurrentMapBigCrystalID()
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    local CfgList =  CrystalPortalCfg:FindAllCfg()
    if CfgList then
        for _, Cfg in ipairs(CfgList) do
            if Cfg.MapID == MapID then
                return Cfg.CrystalID
            end
        end
    end
    return 0
end

function CrystalPortalMgr:OnInteractiveBegin(MajorActor, Crystal)
    local Params = _G.EventMgr:GetEventParams()
	Params.IntParam1 = _G.LuaEntranceType.CRYSTAL
	Params.ULongParam1 = Crystal.EntityID
    _G.EventMgr:SendEvent(_G.EventID.EnterInteractionRange, Params)
    self.EnterCrystalList[Crystal.EntityID] = true
end

function CrystalPortalMgr:OnInteractiveEnd(MajorActor, Crystal)
    local Params = _G.EventMgr:GetEventParams()
	Params.IntParam1 = _G.LuaEntranceType.CRYSTAL
	Params.ULongParam1 = Crystal.EntityID
    _G.EventMgr:SendEvent(_G.EventID.LeaveInteractionRange, Params)
    self.EnterCrystalList[Crystal.EntityID] = nil
end

function CrystalPortalMgr:OnMajorSingBarOver(EntityID, IsBreak, SingStateID)
    if MajorUtil.IsMajor(EntityID) then
        self.IsTransferring = false
        if self.SingTimerID then
            _G.TimerMgr:CancelTimer(self.SingTimerID)
            self.SingTimerID = nil
        end
        if self.FadeTimerID then
            _G.TimerMgr:CancelTimer(self.FadeTimerID)
            self.FadeTimerID = nil
        end
        if IsBreak and SingStateID == 40 then
            self.IsMajorFadeOut = false
            self:TransferFadeIn(EntityID, false)

            if _G.UIViewMgr:IsViewVisible(UIViewID.CommonFadePanel) then
                local Params = {}
                Params.FadeColorType = 1
                Params.Duration = 1
                Params.bAutoHide = true
                _G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)
            end
        end
    end
end

function CrystalPortalMgr:OnMajorSingBarBegin(EntityID, SingStateID)
    --特殊处理
    if SingStateID == 40 then
        if MajorUtil.IsMajor(EntityID) then
            self.IsMajorFadeOut = true
            self:TransferFadeOut(EntityID)

            -- 显示黑屏渐隐
            local Params = {}
            Params.FadeColorType = 3
            Params.Duration = 1
            Params.bAutoHide = false
            _G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)
            -- FLOG_INFO("loiafeng debug: CrystalPortalMgr Show CommonFadePanel")
        end
    end
end

function CrystalPortalMgr:OnOthersSingBarOver(EntityID, IsBreak, SingStateID)
    if not MajorUtil.IsMajor(EntityID) then
        if IsBreak and SingStateID == 40 then
            self:TransferFadeIn(EntityID, false)
        end
    end
end

function CrystalPortalMgr:OnOthersSingBarBegin(EntityID, SingStateID)
    --特殊处理
    if SingStateID == 40 then
        if not MajorUtil.IsMajor(EntityID) then
            self:TransferFadeOut(EntityID)
        end
    end
end

function CrystalPortalMgr:OnInteractiveReqEndError()
    if self.IsMajorFadeOut then
        self.IsMajorFadeOut = false
        local EntityID = MajorUtil.GetMajorEntityID()
        self:TransferFadeIn(EntityID, false)

        if _G.UIViewMgr:IsViewVisible(UIViewID.CommonFadePanel) then
            local Params = {}
            Params.FadeColorType = 1
            Params.Duration = 1
            Params.bAutoHide = true
            _G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)
        end
    end
end

function CrystalPortalMgr:OnRelayConnected()
    if self.IsMajorFadeOut then
        self.IsCurrentTransfer = false
        self.IsMajorFadeOut = false
        local Params = {}
        Params.FadeColorType = 1
        Params.Duration = 1
        Params.bAutoHide = true
        _G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)
    end
end

function CrystalPortalMgr:SendCrystalInfoReq()
	FLOG_INFO("CrystalPortalMgr:SendCrystalInfoReq")

	local MsgID = CS_TELEPORT_CRYSTAL_CMD
	local SubMsgID = CS_TELEPORT_CRYSTAL_SUBMSG.CRYSTAL_INFO

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.CrystalInfo = {}

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CrystalPortalMgr:SendActivateReq(Crystal)
    FLOG_INFO("CrystalPortalMgr:SendActivateReq")

    if not self:CanActivateCrystal() then
        _G.InteractiveMgr:ExitInteractive()
        self.TimerID = _G.TimerMgr:AddTimer(self, function ()
            _G.InteractiveMgr:StartTickTimer()
            if nil ~= self.TimerID then
                _G.TimerMgr:CancelTimer(self.TimerID)
                self.TimerID = nil
            end
        end, 0.2)
        return false
    end

	local MsgID = CS_TELEPORT_CRYSTAL_CMD
	local SubMsgID = CS_TELEPORT_CRYSTAL_SUBMSG.ACTIVATE_CRYSTAL

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.ActCrystal = { Crystal = Crystal.EntityID }

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

    self.CurrentActivateCrystal = Crystal

    return true
end

function CrystalPortalMgr:SendTransferReq(From, To)
    FLOG_INFO("CrystalPortalMgr:SendTransferReq")

    if not CommonStateUtil.CheckBehavior(CommBehaviorID.COMM_BEHAVIOR_CRYSTAL_TRANS, true) then
        return
    end

    if _G.QuestMgr:IsSubmitingStatus() then
        MsgTipsUtil.ShowTips(LSTR(540004)) --540004=现在无法发动传送。
        return
    end

    local ActorManager = _G.UE.UActorManager:Get()
    if ActorManager then
        if ActorManager:GetVirtualJoystickIsSprintLocked() then
            ActorManager:SetVirtualJoystickIsSprintLocked(false)    --关闭自动锁定移动
        end
    end

    local function TransferMap()
        --先触发事件
        _G.EventMgr:SendEvent(EventID.PreCrystalTransferReq)

        local MsgID = CS_TELEPORT_CRYSTAL_CMD
        local SubMsgID = CS_TELEPORT_CRYSTAL_SUBMSG.TRANSFER

        local MsgBody = {}
        MsgBody.SubCmd = SubMsgID
        MsgBody.Transfer = {FromCrystal = From, ToCrystal = To}

        self.IsTransferring = true

        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end

    if _G.RollMgr.IsTreasureHuntRoll and _G.TeamRollItemVM.IsAllOperated ~= true then
        MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(540010), TransferMap, nil, LSTR(10003), LSTR(10002), nil)
        --540010=还有战利品没分配，离开地图将无法获得该奖励
    else
        TransferMap()
    end

    return true
end

---- 用水晶跨界请求
function CrystalPortalMgr:SendCrossWorldTransReq(WorldID, CrystalID)
    local MsgID = CS_TELEPORT_CRYSTAL_CMD
	local SubMsgID = CS_TELEPORT_CRYSTAL_SUBMSG.CROSS_WORLD_TRANSFER
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.CrossWorld = {WorldID = WorldID, CrystalID = CrystalID}

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---- 无水晶跨界请求
function CrystalPortalMgr:SendTravelCrossWorldTransReq(WorldID, Pos, Dir)
    local MsgID = CS_CMD_TRAVEL
    local SubCMD = ProtoCS.Travel.TravelCmd.TravelCmdChange
    local MsgBody = {
        Cmd = SubCMD,
        Change = {
            WorldID = WorldID,
            Pos = Pos,
            Dir = Dir
        }
	}
	_G.GameNetworkMgr:SendMsg(MsgID, SubCMD, MsgBody)
end

function CrystalPortalMgr:OnNetMsgQueryInfoRsp(MsgBody)
    FLOG_INFO("CrystalPortalMgr:OnNetMsgQueryInfoRsp")
    local CrystalInfo = MsgBody.CrystalInfo
    if not CrystalInfo then
        return
    end
    self:ResetMap()
    self.ActivatedList = {}
    if CrystalInfo.Crystal then
        for _, id in ipairs(CrystalInfo.Crystal) do
            self.ActivatedList[id] = true
        end
    end

    self.ActivedGroupList = {}
    if CrystalInfo.ActivedGroup then
        for _, GroupID in ipairs(CrystalInfo.ActivedGroup) do
            self.ActivedGroupList[GroupID] = true
        end
    end

    local MapResID = _G.PWorldMgr:GetCurrMapResID()
    self:OnMapLoaded(MapResID)
end

function CrystalPortalMgr:OnNetMsgActivateRsp(MsgBody)
    FLOG_INFO("CrystalPortalMgr:OnNetMsgActivateRsp")

    --local Params = _G.EventMgr:GetEventParams()
	--Params.IntParam1 = _G.LuaEntranceType.CRYSTAL
	--Params.ULongParam1 = self.CurrentActivateCrystal.EntityID
    --_G.EventMgr:SendEvent(_G.EventID.LeaveInteractionRange, Params)
    -- _G.SingBarMgr:MajorSingByInteractiveID(self.CurrentActivateCrystal.DBConfig.ActiviteInterativeID)
end

function CrystalPortalMgr:UpdateCrystalDynData()
    local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
    if self.CrystalList and self.ActivatedList then
        for _, c in ipairs(self.CrystalList) do
            local IsActivated = self.ActivatedList[c.EntityID] or false
            -- set status
            if c.DBConfig.Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP and c.DBConfig.MapID == CurrMapID then
                if c.DBConfig.EObjID and c.DBConfig.EObjID > 0 then
                    if IsActivated then
                        _G.PWorldMgr:LocalUpdateDynData(MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE, c.DBConfig.EObjID, STATUS_ACTIVED)
                    else
                        _G.PWorldMgr:LocalUpdateDynData(MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE, c.DBConfig.EObjID, STATUS_UNACTIVED)
                    end
                end
            end
        end
    end
end

function CrystalPortalMgr:OnNetMsgActivateNtf(MsgBody)
    FLOG_INFO("CrystalPortalMgr:OnNetMsgActivateNtf")
    local ActivateNtf = MsgBody.ActivateNtf
    if ActivateNtf and ActivateNtf.Result then
        local NewActivated = ActivateNtf.Crystal
        self.ActivatedList[NewActivated] = true

        -- set status
        local CfgItem = CrystalPortalCfg:FindCfgByKey(NewActivated)
        if CfgItem then
            if CfgItem.Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP then
                local function ShowSmallCrystalTutorial(Params)
                    local EventParams = _G.EventMgr:GetEventParams()
                    EventParams.Type = TutorialDefine.TutorialConditionType.SmallCrystal--新手引导触发类型
                    _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
                end

                local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowSmallCrystalTutorial, Params = {}}
                _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
            end
            if CfgItem.EObjID and CfgItem.EObjID > 0 then
                _G.PWorldMgr:LocalUpdateDynData(MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE, CfgItem.EObjID, STATUS_ACTIVING_SUCCESS)
            end
        end

        -- other crystal
        if ActivateNtf.CrystalIDs then
            for _, ID in ipairs(ActivateNtf.CrystalIDs) do
                local CrystalCfgItem = CrystalPortalCfg:FindCfgByKey(ID)
                if CrystalCfgItem then
                    self.ActivatedList[ID] = true
                    if CrystalCfgItem.EObjID and CrystalCfgItem.EObjID > 0 then
                        _G.PWorldMgr:LocalUpdateDynData(MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE, CrystalCfgItem.EObjID, STATUS_ACTIVING_SUCCESS)
                        _G.EventMgr:SendEvent(EventID.CrystalActivated, ID)
                    end
                end
            end
        end

        -- group
        local ActiveGroup = ActivateNtf.ActiveGroup
        if ActiveGroup and ActiveGroup > 0 then
            self.ActivedGroupList[ActiveGroup] = true
        end

        -- Sync crystal activated info
        if self.CrystalList then
            for _, c in ipairs(self.CrystalList) do
                c.IsActivated = self.ActivatedList[c.EntityID] or false
            end
           -- FLOG_INFO("CrystalPortalMgr:OnNetMsgActivateNtf, SortInteractorParamsList")
            _G.InteractiveMgr:UpdateInteractorItems(_G.LuaEntranceType.CRYSTAL)
        end

        if self.CurrentActivateCrystal and self.CurrentActivateCrystal.EntityID == ActivateNtf.Crystal then
            self.CurrentActivateCrystal = nil
            local CrystalCfg = CrystalPortalCfg:FindCfg(string.format("CrystalID = %d", ActivateNtf.Crystal))
            if not CrystalCfg then
                FLOG_INFO("CrystalPortalMgr:OnNetMsgActivateNtf no crystals configured ID: "..tostring(ActivateNtf.Crystal))
            else
                if CrystalCfg.Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP then
                    local MapTableCfg = _G.PWorldMgr:GetCurrMapTableCfg()
                    MsgTipsUtil.ShowCrystalTips(LSTR(540006), MapTableCfg.DisplayName) --540006=到达了以太之光
                elseif  CrystalCfg.Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP then
                    local MapTableCfg = _G.PWorldMgr:GetCurrMapTableCfg()
                    MsgTipsUtil.ShowCrystalTips(LSTR(540007), MapTableCfg.DisplayName) --540007=城内以太之晶开放
                else
                    FLOG_INFO("CrystalPortalMgr:OnNetMsgActivateNtf no crystals config type "..tostring(CrystalCfg.Type))
                end
            end

            local Params = _G.EventMgr:GetEventParams()
            Params.IntParam1 = _G.LuaEntranceType.CRYSTAL
            Params.ULongParam1 = ActivateNtf.Crystal
            _G.EventMgr:SendEvent(EventID.EnterInteractionRange, Params)
        else
            FLOG_ERROR("No CurrentActivateCrystal but receive NetMsgActivateNtf!")
        end

        _G.EventMgr:SendEvent(EventID.CrystalActivated, NewActivated)
    else
        FLOG_ERROR("Activate failed for crystal: "..tostring(ActivateNtf.Crystal))
    end
end

function CrystalPortalMgr:OnNetMsgTransferRsp(MsgBody)
    FLOG_INFO("CrystalPortalMgr:OnNetMsgTransferRsp")
    if self.CurrentTransferInteractiveID == 0 then
        FLOG_ERROR("No CurrentTransferInteractiveID but receive NetMsgActivateRsp!")
        return
    end
    -- _G.SingBarMgr:MajorSingByInteractiveID(self.CurrentTransferInteractiveID)
    self.CurrentTransferInteractiveID = 0
    self.IsCurrentTransfer = true

    if _G.RollMgr.IsTreasureHuntRoll then
        _G.RollMgr:OnTreasureAssign(false)
    end
end

function CrystalPortalMgr:OnNetMsgTransferNtf(MsgBody)
    FLOG_INFO("CrystalPortalMgr:OnNetMsgTransferNtf")
    if not MsgBody.TransferNtf.Result then
        FLOG_ERROR("Transfer failed!")
    end
    -- 传送成功后续由服务器发送地图传送包来驱动
    if _G.RollMgr.IsTreasureHuntRoll then
        _G.RollMgr:OnTreasureAssign(false)
    end
end

function CrystalPortalMgr:OnNetMsgInteractive(MsgBody)
    if not self.CurrentActivateCrystal then
        return
    end
    -- 处理极限情况下脱离水晶交互范围共鸣的情况
    local SpellChgRsp = MsgBody.SpellChg
    if not SpellChgRsp then
        return
    end
    if SpellChgRsp.Result == ProtoCS.SpellResult.SpellResultFirst and (SpellChgRsp.SpellID == 3 or SpellChgRsp.SpellID == 4) then
        local DBConfig = self.CurrentActivateCrystal.DBConfig
        if DBConfig then
            local PointVec = _G.UE.FVector(DBConfig.X, DBConfig.Y, DBConfig.Z)
            local Major = MajorUtil.GetMajor()
            local MajorPos = Major:FGetActorLocation()
            local Dis = PointVec:Dist2D(MajorPos)
            local LimitDistance = DBConfig.Distance + 50 --因为主角有个1米的包围盒，允许距离超出半米
            if Dis > LimitDistance then
                FLOG_ERROR("[CrystalPortalMgr] out interactive range ! Dis="..tostring(Dis))
                _G.SingBarMgr:OnBreakSingOver()
            end
        end
    end
end

function CrystalPortalMgr:OnNetMsgCrossWorld(MsgBody)
    if MsgBody and MsgBody.CrossWorld then
        local WorldID = MsgBody.CrossWorld.WorldID
        local RoleVM = MajorUtil.GetMajorRoleVM()
        if RoleVM and WorldID then
            RoleVM:SetCrossZoneWorldID(WorldID)
            FLOG_INFO(string.format("RloeVM Update CrossWorldID WorldID : %s" , WorldID))
        end

        _G.EventMgr:SendEvent(EventID.PWorldCrossWorld, WorldID)  -- 跨服ID 跨回原服时为0
    end
end

function CrystalPortalMgr:OnVisionEnter(Params)
    local EntityType = Params.IntParam1
    if EntityType ~= 1 then
       return
    end
    local EntityID = Params.ULongParam1
    self:PlayTransferInEffect(EntityID)
end

function CrystalPortalMgr:CanActivateCrystal()
    if not CommonStateUtil.CheckBehavior(CommBehaviorID.COMM_BEHAVIOR_CRYSTAL_TRANS, true) then
        return false
    end

    local Major = MajorUtil.GetMajor()
    if Major and Major.CharacterMovement then
        local Velocity = Major.CharacterMovement.Velocity
        if Velocity.Z ~= 0 then
            MsgTipsUtil.ShowTips(LSTR(540008)) --540008=在跳跃中无法操作
            return false
        elseif Velocity.X ~= 0 or Velocity.Y ~= 0 then
            MsgTipsUtil.ShowTips(LSTR(540009)) --540009=移动中无法操作
            return false
        end
    end
    return true
end

---查找table是否有相同的ID的元素
---@param Table Table
---@param ID integer
---@return boolean
function CrystalPortalMgr:FindSameID(Table, ID)
    for _, V in ipairs(Table) do
        if V.ID == ID then
            return true
        end
    end
    return false
end

return CrystalPortalMgr
