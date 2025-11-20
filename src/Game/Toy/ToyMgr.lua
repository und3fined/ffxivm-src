---
--- Author: MichaelYang_LightPaw
--- DateTime: 2025-07-28 20:45
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local ToyCfg = require("TableCfg/ToyCfg")
local CompanionCfg = require("TableCfg/CompanionCfg")
local ToySlotItemVM = require("Game/Toy/VM/ToySlotItemVM")
local MajorUtil = require("Utils/MajorUtil")

local ToyMonsterGlass = require("Game/Toy/ToyMonsterGlass")
local ToyCompanionMagnifier = require("Game/Toy/ToyCompanionMagnifier")
local ToyMonsterCosplay = require("Game/Toy/ToyMonsterCosplay")
local ToyItemCosplay = require("Game/Toy/ToyItemCosplay")
local ToySummonEObj = require("Game/Toy/ToySummonEObj")

local MSG_ID = ProtoCS.CS_CMD.CS_CMD_TOY
local SUB_MSG_ID = ProtoCS.Role.Toy.ToyCmd
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local CS_CMD = ProtoCS.CS_CMD

---@class ToyMgr : MgrBase
local ToyMgr = LuaClass(MgrBase)

---OnInit
function ToyMgr:OnInit()
    self:ResetData()
end

function ToyMgr:OnBegin()
end

function ToyMgr:OnEnd()
    self:ResetData()
end

function ToyMgr:ResetData()
    self.CurPlayingToy = nil
    self.bQueryToy = false
    self.AllToyVMList = {} -- ToySlotItemVM
end

function ToyMgr:OnShutdown()
end

function ToyMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(MSG_ID, SUB_MSG_ID.ToyCmdQuery, self.OnQueryAllToyRsp) -- 获取所有玩具
    self:RegisterGameNetMsg(MSG_ID, SUB_MSG_ID.ToyCmdNotifyActive, self.OnNotifyActive) -- 激活了新的玩具
    self:RegisterGameNetMsg(MSG_ID, SUB_MSG_ID.ToyCmdPlay, self.OnPlayToyRsp) -- 使用玩具返回
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_VISION,
        ProtoCS.CS_VISION_CMD.CS_VISION_CMD_AVATAR_CHG,
        self.OnNetMsgVisionAvatarChange
    )
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_ENTER, self.OnNetMsgVisionEnter)
end

function ToyMgr:OnNetMsgVisionEnter(MsgBody)
    if (MsgBody == nil or MsgBody.Enter == nil or MsgBody.Enter.Entities == nil) then
        return
    end
    for _, VEntity in ipairs(MsgBody.Enter.Entities or {}) do
        if VEntity.Role then
            if VEntity.Role.Avatar ~= nil and VEntity.Role.Avatar.Face ~= nil then
                local EntityID = VEntity.ID
                if VEntity.Type == _G.UE.EActorType.Companion then
                    local ScaleValue = VEntity.Role.Avatar.Face[ProtoCommon.avatar_personal.AvatarCompanionScale] or 0
                    self:InternalApplyCompanionMagnifier(EntityID, ScaleValue)
                end
            end
        end
    end
end

-- 收到网络消息 --
function ToyMgr:OnNetMsgVisionAvatarChange(MsgBody)
    if (MsgBody == nil or MsgBody.AvatarChg == nil) then
        return
    end
    if (MsgBody.AvatarChg.Type == ProtoCommon.avatar_personal.AvatarCompanionScale) then
        local TargetEntityID = MsgBody.AvatarChg.EntityID
        local TargetValue = MsgBody.AvatarChg.Avatar.Face[MsgBody.AvatarChg.Type]
        self:InternalApplyCompanionMagnifier(TargetEntityID, TargetValue)
    end
end

function ToyMgr:OnNotifyActive(InMsg)
    if (InMsg == nil or InMsg.Active == nil) then
        _G.FLOG_ERROR("ToyMgr:OnNotifyActive 错误，网络数据无效，请检查")
        return
    end

    self:InternalAddNewToy(InMsg.Active.Active)
end
-- END --

function ToyMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)
    self:RegisterGameEvent(EventID.Attr_Change_ChangeRoleId, self.OnGameEventChangeRole) -- 变身
    self:RegisterGameEvent(EventID.NetStateUpdate, self.OnGameEventCombatStateChanged) -- 战斗状态发生改变
end

function ToyMgr:OnGameEventCombatStateChanged(Params)
    if (Params == nil) then
        return
    end

    -- 没有使用玩具的时候，不做改变
    if (not self:IsPlayingToy()) then
        return
    end

    if (MajorUtil.IsMajor(Params.ULongParam1) and Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT) then
        self:CancelPlayToy()
    end
end

function ToyMgr:OnGameEventChangeRole(Params)
    if (Params == nil) then
        return
    end

    if (not self:IsPlayingToy()) then
        return
    end

    -- 这里看下类型，是否为变身怪物或者变身物品
    local ToyType = self.CurPlayingToy.Ins:GetToyType()
    if (ToyType ~= ProtoRes.ToyType.ToyTypeCosplay and ToyType ~= ToyType ~= ProtoRes.ToyType.ToyTypeCosObj) then
        return
    end

    local EntityID = Params.ULongParam1
    local ChangeRoleID = Params.IntParam1

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if (MajorEntityID == EntityID) then
        if (ChangeRoleID == 0) then
            -- 变身为0，那么发送取消玩具
            self:SendCancelToyReq()
        end
    end
end

function ToyMgr:OnPWorldEnter(Params)
    -- 进入场景的时候，获取一下玩具数据，只获取一次就可以了，后续使用的时候，是另外一个协议
    if (self.bQueryToy) then
        return
    end

    self:SendQueryAllToy()
end

function ToyMgr:OnPWorldExit(Params)
    -- 退出的时候，取消玩具
end

function ToyMgr:OnGameEventVisionEnter(Params)
    if (Params == nil) then
        return
    end

    local EntityType = Params.IntParam1
    local EntityID = Params.ULongParam1

    -- 宠物放大器的话，需要检测一下类型，然后去获取一下放大系数
    if (EntityType == _G.UE.EActorType.Companion) then
        local ScaleValue = 0
        local AttriComp = ActorUtil.GetActorAttributeComponent(EntityID)
        if (AttriComp and AttriComp.Owner > 0) then
            local OwnerActor = ActorUtil.GetActorByEntityID(AttriComp.Owner)
            if (OwnerActor) then
                local OwnerAvatarComp = OwnerActor:GetAvatarComponent()
                if (OwnerAvatarComp) then
                    local TempKey = ProtoCommon.avatar_personal.AvatarCompanionScale
                    ScaleValue = OwnerAvatarComp:GetAvatarFaceValueByKey(TempKey)
                end
                self:InternalApplyCompanionMagnifier(EntityID, ScaleValue)
            end
        end
    end

    if (self:IsPlayingToy()) then
        self.CurPlayingToy.Ins:VisionEnter(EntityType, EntityID, Params)
    end
end

function ToyMgr:OnGameEventVisionLeave(Params)
    if (Params == nil) then
        return
    end

    if (self.CurPlayingToy == nil) then
        return
    end
end

-- 获取所有玩具 --
function ToyMgr:SendQueryAllToy()
    -- 发送请求
    local SubMsgID = SUB_MSG_ID.ToyCmdQuery
    local MsgBody = {
        Cmd = SubMsgID
    }
    _G.GameNetworkMgr:SendMsg(MSG_ID, SubMsgID, MsgBody)
end

function ToyMgr:OnQueryAllToyRsp(InMsg)
    -- 收到回复
    if (InMsg == nil or InMsg.Query == nil) then
        _G.FLOG_ERROR("ToyMgr:OnQueryAllToyRsp 错误，传入的 InMsg 为空")
        return
    end

    local QueryData = InMsg.Query
    self.bQueryToy = true

    if (QueryData.Joy ~= nil) then
        local bCreateNew = true
        if (self.CurPlayingToy ~= nil) then
            if (self.CurPlayingToy.ID == QueryData.Joy.ResID) then
                -- 如果当前的玩具ID相同，那么更新一下
                self.CurPlayingToy.Last = QueryData.Joy.Last
                self.CurPlayingToy.SceneObjID = QueryData.Joy.ObjID
                bCreateNew = false
            else
                self.CurPlayingToy.Ins:ToyExit()
                self.CurPlayingToy.Ins = nil
            end
        end

        if (bCreateNew) then
            self:InternalCreateCurPlayToy(QueryData.Joy)
        end
    end

    for _, Value in pairs(QueryData.Toys) do
        self:InternalAddNewToy(Value)
    end
end

-- 应用宠物放大镜
function ToyMgr:InternalApplyCompanionMagnifier(InEntityID, InScaleValue)
    local TargetActor = ActorUtil.GetActorByEntityID(InEntityID)
    if (TargetActor == nil) then
        _G.FLOG_ERROR("无法获取角色， EntityID : %s", InEntityID)
        return
    end

    -- 这里去设置为表格里面的缩放数值
    local AttriComp = TargetActor:GetAttributeComponent()
    if (AttriComp == nil) then
        _G.FLOG_ERROR("无法获取角色AttriComp， EntityID : %s", InEntityID)
        return
    end
    local ActorType = AttriComp:GetActorType()
    local ResID = AttriComp.ResID
    if (ActorType == _G.UE.EActorType.Player or ActorType == _G.UE.EActorType.Major) then
        -- 如果是玩家或者是自己，那么去找一下宠物
        local ActorManager = _G.UE.UActorManager.Get()
        local AllCompanion = ActorManager:GetAllCompanions()
        for _, Value in pairs(AllCompanion) do
            -- body
            local TempAttriComp = Value:GetAttributeComponent()
            if (TempAttriComp and TempAttriComp.Owner == InEntityID) then
                ResID = TempAttriComp.ResID
                TargetActor = Value
                break
            end
        end
    end

    if (ResID == nil or ResID <= 0) then
        return
    end

    local TargetCfg = CompanionCfg:FindCfgByKey(ResID)
    if (TargetCfg == nil) then
        _G.FLOG_ERROR("无法获取角色 CompanionCfg ResID : %s", ResID)
        return
    end

    local OriginScale = TargetCfg.Scale * 0.01

    if (InScaleValue == nil or InScaleValue == 0) then
        -- 这里进行缩放
        local Process = 0
        local Interval = 0.05
        local Times = 10
        local TimeSpan = 1 / Times
        local TargetScale = OriginScale
        local CurScale = TargetActor:GetScaleFactor() -- 当前的缩放
        local ScaleSpan = TargetScale - CurScale
        self:RegisterTimer(
            function()
                if (TargetActor == nil or not TargetActor:IsValid()) then
                    return
                end
                Process = Process + TimeSpan
                local FinalScale = CurScale + Process * ScaleSpan
                TargetActor:SetScaleFactor(FinalScale, true)
            end,
            0,
            Interval,
            Times
        )
    else
        -- 这里进行缩放
        local Process = 0
        local Interval = 0.05
        local Times = 10
        local TimeSpan = 1 / Times
        local TargetScale = InScaleValue * 0.01 * OriginScale
        local CurScale = TargetActor:GetScaleFactor() -- 当前的缩放
        local ScaleSpan = TargetScale - CurScale
        self:RegisterTimer(
            function()
                if (TargetActor == nil or not TargetActor:IsValid()) then
                    return
                end
                Process = Process + TimeSpan
                local FinalScale = CurScale + Process * ScaleSpan
                TargetActor:SetScaleFactor(FinalScale, true)
            end,
            0,
            Interval,
            Times
        )
    end
end

function ToyMgr:InternalCreateCurPlayToy(InData)
    if (InData == nil) then
        _G.FLOG_ERROR("ToyMgr:InternalCreateCurPlayToy 错误， 传入的 InData 为空")
        return
    end
    local TargetCfg = ToyCfg:FindCfgByKey(InData.ResID)
    if (TargetCfg == nil) then
        _G.FLOG_ERROR("ToyCfg:FindCfgByKey 错误，无法找到数据，ID是 : %s", InData.ResID)
        return
    end

    local ToyIns = nil
    if (TargetCfg.Type == ProtoRes.ToyType.ToyTypeMonsterEye) then
        -- 怪物眼镜
        ToyIns = ToyMonsterGlass.New()
    elseif (TargetCfg.Type == ProtoRes.ToyType.ToyTypePetZoomIn) then
        -- 宠物放大镜
        ToyIns = ToyCompanionMagnifier.New()
    elseif (TargetCfg.Type == ProtoRes.ToyType.ToyTypeCosplay) then
        -- 变身怪物
        ToyIns = ToyMonsterCosplay.New()
    elseif (TargetCfg.Type == ProtoRes.ToyType.ToyTypeCosObj) then
        -- 变身怪物
        ToyIns = ToyItemCosplay.New()
    elseif (TargetCfg.Type == ProtoRes.ToyType.ToyTypeSceneObj) then
        -- 变身怪物
        ToyIns = ToySummonEObj.New()
    else
        _G.FLOG_ERROR("未处理的玩具类型，请检查，玩具ID : %s , 类型是：%s", InData.ResID, TargetCfg.Type)
        return
    end

    if (not ToyIns:Init(InData.ResID)) then
        _G.FLOG_ERROR("Toy:Init 出错，请检查")
        return
    end

    ToyIns:ToyBegin(InData.ObjID)
    self.CurPlayingToy = {}
    self.CurPlayingToy.Ins = ToyIns
    self.CurPlayingToy.Last = InData.Last
    self.CurPlayingToy.SceneObjID = InData.ObjID
end

function ToyMgr:InternalGetToyVMByResID(InToyID)
    for _, Value in pairs(self.AllToyVMList) do
        if (Value.ResID == InToyID) then
            return Value
        end
    end

    return nil
end

function ToyMgr:InternalAddNewToy(InToy)
    if (InToy == nil) then
        _G.FLOG_ERROR("ToyMgr:InternalAddNewToy 错误， 传入的 InToy 为空，请检查")
        return
    end
    local NewToyData = ToySlotItemVM.New()
    NewToyData:UpdateVM(InToy)
    table.insert(self.AllToyVMList, NewToyData)
    if (#self.AllToyVMList >= 2) then
        table.sort(
            self.AllToyVMList,
            function(Left, Right)
                return Left.ResID < Right.ResID
            end
        )
    end
end

-- END --

-- 使用玩具 --
function ToyMgr:SendPlayToyReq(InToyID)
    if (InToyID == nil) then
        return
    end

    if (self.CurPlayingToy ~= nil) then
        _G.FLOG_ERROR("当前有正在使用的玩具，需要先取消再使用其他玩具")
        return
    end

    local TargetToy = self:InternalGetToyVMByResID(InToyID)
    if (TargetToy == nil) then
        _G.FLOG_ERROR("ToyMgr:SendPlayToyReq 错误，无法获取玩具，传入的ID是:%s", InToyID)
        return
    end

    -- 发送请求
    local SubMsgID = SUB_MSG_ID.ToyCmdPlay
    local MsgBody = {
        Cmd = SubMsgID,
        Play = {
            ResID = InToyID
        }
    }
    _G.GameNetworkMgr:SendMsg(MSG_ID, SubMsgID, MsgBody)
end

function ToyMgr:OnPlayToyRsp(InMsg)
    -- 收到回复
    if (InMsg == nil) then
        _G.FLOG_ERROR("ToyMgr:OnPlayToyRsp 错误，传入的 InMsg 无效")
        return
    end

    if (InMsg.Play == nil or InMsg.Play.Joy == nil or InMsg.Play.Joy.ResID == 0) then
        if (self.CurPlayingToy.Ins ~= nil) then
            local CurToyID = self.CurPlayingToy.Ins:GetToyID()
            local TargetToy = self:InternalGetToyVMByResID(CurToyID)
            if (TargetToy ~= nil) then
                TargetToy.LastTimeStamp = 0
            end
            self.CurPlayingToy.Ins:ToyExit()
        end
        self.CurPlayingToy = nil
        _G.EventMgr:SendEvent(EventID.PlayToy, nil)
    else
        local NetData = InMsg.Play.Joy
        local TargetToy = self:InternalGetToyVMByResID(NetData.ResID)
        if (TargetToy == nil) then
            _G.FLOG_ERROR("ToyMgr:OnPlayToyRsp 错误，无法获取玩具，ID是:%s", NetData.ResID)
            return
        end
        local DataCfg = ToyCfg:FindCfgByKey(NetData.ResID)
        if (DataCfg == nil) then
            _G.FLOG_ERROR("无法获取 ToyCfg , ID 是 :%s", NetData.ResID)
            return
        end

        TargetToy:UpdateTimeStamp(NetData.CD, NetData.Last)
        self:InternalCreateCurPlayToy(NetData)
        _G.EventMgr:SendEvent(EventID.PlayToy, NetData)
    end
end
-- END --

-- 取消玩具 --
function ToyMgr:SendCancelToyReq()
    if (self.CurPlayingToy == nil) then
        return
    end

    -- 发送请求
    local SubMsgID = SUB_MSG_ID.ToyCmdPlay
    local MsgBody = {
        Cmd = SubMsgID,
        Play = {
            ResID = 0
        }
    }
    _G.GameNetworkMgr:SendMsg(MSG_ID, SubMsgID, MsgBody)
end

function ToyMgr:CancelPlayToy()
    if (not self:IsPlayingToy()) then
        return
    end

    self.CurPlayingToy.Ins:ToyExit()
    self.CurPlayingToy.Ins = nil
    self.CurPlayingToy = nil
end
-- END --

-- 外部使用 --

---@return self.AllToyVMList VALUE 是 ToySlotItemVM
function ToyMgr:GetAllToy()
    return self.AllToyVMList
end

function ToyMgr:IsPlayingToy()
    if (self.CurPlayingToy == nil or self.CurPlayingToy.Ins == nil) then
        return false
    end

    return true
end

function ToyMgr:GetCurPlayToyResID()
    if (not self:IsPlayingToy()) then
        return 0
    end

    return self.CurPlayingToy.Ins.ToyID
end

-- 当前玩具的持续时间是否到了
function ToyMgr:IsCurToyPlayTimeOver(InbSendCancelToy)
    if (self.CurPlayingToy == nil or self.CurPlayingToy.Ins == nil) then
        return true
    end

    local TargetToyVM = self:InternalGetToyVMByResID(self.CurPlayingToy.Ins:GetToyID())
    if (TargetToyVM == nil) then
        return true
    end

    if (TargetToyVM:GetLastTimeStamp() <= 0) then
        return true
    end

    local CurTimeMS = TimeUtil.GetServerLogicTimeMS()
    if (CurTimeMS >= TargetToyVM:GetLastTimeStamp()) then
        return true
    end

    return false
end
-- END

--要返回当前类
return ToyMgr
