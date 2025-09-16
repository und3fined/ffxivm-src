--
-- Author: sammrli
-- Date: 2023-10-16 14:55
-- Description:地图迷雾管理
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCS = require ("Protocol/ProtoCS")
local MsgTipsID = require("Define/MsgTipsID")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local MapVM = require("Game/Map/VM/MapVM")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local ModuleMapContentVM = require("Game/Map/VM/ModuleMapContentVM")

local BitUtil = require("Utils/BitUtil")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")

local MapCfg = require("TableCfg/MapCfg")
local MapUICfg = require("TableCfg/MapUICfg")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

local GameNetworkMgr

local FOG_UNLOCK_SOUND_PATH = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Discovery.Play_FM_Discovery'"

local FogMgr = LuaClass(MgrBase)

---@class FogMgr : MgrBase
---@field DictDiscoveryFlag table<number, number>
---@field DictAllActivate table<number, boolean>
function FogMgr:OnInit()
    self.DictDiscoveryFlag = {}
    self.DictAllActivate = {}
end

function FogMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    self.DictDiscoveryFlag = {}
    self.DictAllActivate = {}
    self.AllHadFogMapIDList = {}
    self.LateCheckDiscovery = false

    local Record = {}
    local CfgList = MapUICfg:FindAllCfg()
    for _, Cfg in ipairs(CfgList) do
        if not string.isnilorempty(Cfg.MaskPath) then
            if not Record[Cfg.MapID] then
                table.insert(self.AllHadFogMapIDList, Cfg.MapID)
                Record[Cfg.MapID] = true
            end
        end
    end
end

function FogMgr:OnEnd()
    self.DictDiscoveryFlag = {}
    self.DictAllActivate = {}
    self.LateCheckDiscovery = false
end

function FogMgr:OnShutdown()
end

function FogMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_FOG, ProtoCS.CSExploreFogCmd.ExploreFogAreaIDListCmd, self.OnNetMsgGetMapFogInfo)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_FOG, ProtoCS.CSExploreFogCmd.ExploreFogActivateAreaIDCmd, self.OnNetMsgFogActivate)
end

function FogMgr:OnRegisterGameEvent()
    --self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
    self:RegisterGameEvent(EventID.PWorldBegin, self.OnGameEventCheckDiscovery)
    self:RegisterGameEvent(EventID.PWorldMapMovieSequenceEnd, self.OnGameEventCheckDiscovery)
end

---获取地图遮罩掩码
---@param MapID number
---@return number
function FogMgr:GetFlogFlag(MapID)
    return self.DictDiscoveryFlag[MapID] or 0
end

---迷雾数据是否已经初始化
---@param MapID number
---@return number
function FogMgr:IsFlagInit(MapID)
    return self.DictDiscoveryFlag[MapID] ~= nil
end

---区域是否解锁
---@param MapID number
---@param ID number
---@return BoolValue
function FogMgr:IsInFlag(MapID, ID)
    local Flag = self.DictDiscoveryFlag[MapID]
    if Flag == nil then
        return false
    end
    local Val = 1 << ID
    return (Flag & Val) == Val
end

---地图是否存在已解锁区域（如果地图没有迷雾返回true）
---@param MapID number @地图ID
---@return BoolValue
function FogMgr:IsAnyActivate(MapID)
    local MapCfgItem = MapCfg:FindCfgByKey(MapID)
    if MapCfgItem then
        if MapCfgItem.UIMapID > 0 then
            local MapUICfgItem = MapUICfg:FindCfgByKey(MapCfgItem.UIMapID)
            if MapUICfgItem then
                -- 策划以有没配置遮罩图来确定是否有迷雾数据
                if MapUICfgItem.MaskPath == "" then
                    return true
                end
            end
        end
    end
    if self.DictAllActivate[MapID] then
        return true
    end
    local Flag = self.DictDiscoveryFlag[MapID]
    return Flag and Flag > 0
end

---是否全部区域解锁
---@param MapID number @地图ID
---@return BoolValue
function FogMgr:IsAllActivate(MapID)
    local MapCfgItem = MapCfg:FindCfgByKey(MapID)
    if MapCfgItem then
        if MapCfgItem.UIMapID > 0 then
            local MapUICfgItem = MapUICfg:FindCfgByKey(MapCfgItem.UIMapID)
            if MapUICfgItem then
                -- 策划以有没配置遮罩图来确定是否有迷雾数据
                if MapUICfgItem.MaskPath == "" then
                    return true
                end
            end
        end
    end
    -- 特殊副本
    if MapUtil.IsSpecialPWorldMap(MapID) then
        return true
    end
    return self.DictAllActivate[MapID]
end

---是否播放清除迷雾动画
---@param MapID number
---@return boolean
function FogMgr:CanPlayClearFogAnimation(MapID)
    --条件1 地图有迷雾并且全部解锁
    if not self.DictAllActivate[MapID] then
       return false
    end
    --条件2 从未播放过清除动画
    local RoleID = MajorUtil.GetMajorRoleID()
    local RecordStr = _G.ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.FogPlayClearAnimationRecord)
    if not string.isnilorempty(RecordStr) then --未播放过
        if string.find(RecordStr, MapID) then
            return false
        end
    end
    return true
end

---记录播放清除迷雾动画
---@param MapID number
function FogMgr:RecordPlayClearFogAnimation(MapID)
    local RoleID = MajorUtil.GetMajorRoleID()
    local RecordStr = _G.ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.FogPlayClearAnimationRecord)
    if string.isnilorempty(RecordStr) then
        RecordStr = tostring(MapID)
    else
        if string.find(RecordStr, MapID) then --已经记录了
            return
        end
        RecordStr = string.format("%s|%s", RecordStr, tostring(MapID))
    end
    _G.ClientSetupMgr:SendSetReq(ClientSetupID.FogPlayClearAnimationRecord, RecordStr)
end

---GM查询Npc所属迷雾ID
---@param NpcResID number
function FogMgr:QueryNpcDiscoveryID(NpcResID)
    local NpcData = _G.MapEditDataMgr:GetNpc(NpcResID)
    if NpcData then
        local BirthPoint = NpcData.BirthPoint
        return _G.MapAreaMgr:GetDiscoveryIDByLocation(BirthPoint.X, BirthPoint.Y, BirthPoint.Z)
    end
    return -1
end

---列表转掩码
---@param Bytes table<string.byte>
---@return number
function FogMgr:BytesToFlag(Bytes)
    local Flag = 0
    for i=#Bytes, 1, -1 do
        Flag = Flag * 256 + Bytes[i]
    end
    return Flag
end

---请求拉取地图迷雾数据
---@param MapIDList table<number>
function FogMgr:SendGetMapFogInfo(MapIDList)
    local HasCache = true
    for _,ID in pairs(MapIDList) do
        if self.DictDiscoveryFlag[ID] == nil then
            HasCache = false
            break
        end
    end
    --如果本地已有数据
    if HasCache then
        return
    end

    local MsgID = ProtoCS.CS_CMD.CS_CMD_FOG
    local SubMsgID = ProtoCS.CSExploreFogCmd.ExploreFogAreaIDListCmd

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.FogMapArea = { MapList = MapIDList }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求激活区域
---@param ID number 注意此处发送的是区域id，不是discoveryID
function  FogMgr:SendActivateArea(ID)
    local MsgID = ProtoCS.CS_CMD.CS_CMD_FOG
    local SubMsgID = ProtoCS.CSExploreFogCmd.ExploreFogActivateAreaIDCmd

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ExploreFogActivate = { AreaID = ID }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---返回拉取地图迷雾数据
function FogMgr:OnNetMsgGetMapFogInfo(MsgBody)
    if nil == MsgBody or nil == MsgBody.FogMapArea then
        return
    end

    local CurrentMapResID = _G.PWorldMgr:GetCurrMapResID()

    for ID, FogMapArea in pairs(MsgBody.FogMapArea.FogMapAreaData) do

        local BytesSet = BitUtil.StringToByteArray(FogMapArea.AreaIDList)
        local Flag = self:BytesToFlag(BytesSet)-- + 1 --+1默认显示区域0
        self.DictDiscoveryFlag[ID] = Flag
        self.DictAllActivate[ID] = FogMapArea.AllActivate
        FLOG_INFO("[FogMgr] get fog info MapID="..tostring(ID).."  , Flag=".. tostring(Flag).." , All="..tostring(FogMapArea.AllActivate))

        if ID == CurrentMapResID then --如果是当前地图，做初始化校验
            local DiscoveryID, AreaID = _G.MapAreaMgr:GetDiscoveryID()
            local IsAllActivate = self:IsAllActivate(CurrentMapResID)
            if DiscoveryID > 0 and not self:IsInFlag(CurrentMapResID, DiscoveryID) and not IsAllActivate then --所在区域没有解锁
                self:SendActivateArea(AreaID)
            else
                WorldMapVM:SetDiscoveryFlag(Flag)
                MapVM:SetDiscoveryFlag(Flag)
                MapVM:SetIsAllActivate(IsAllActivate)
                ModuleMapContentVM:SetDiscoveryFlag(Flag)
                ModuleMapContentVM:SetIsAllActivate(IsAllActivate)
            end
        end
    end

    _G.WorldMapMgr:UpdateDiscovery()

    _G.EventMgr:SendEvent(EventID.UpdateFogInfo)

    if self.LateCheckDiscovery then
        self.LateCheckDiscovery = false
        self:OnGameEventCheckDiscovery()
    end
end

---推送新的区域列表
function FogMgr:OnNetMsgFogActivate(MsgBody)
    if nil == MsgBody or nil == MsgBody.ActivateMapAreaID then
        return
    end

    local Data = MsgBody.ActivateMapAreaID
    local BytesSet = BitUtil.StringToByteArray(Data.AreaIDList)

    local Flag = self:BytesToFlag(BytesSet)-- + 1 --+1默认显示区域0
    self.DictDiscoveryFlag[Data.MapResID] = Flag
    self.DictAllActivate[Data.MapResID] = Data.AllActivate

    if Data.MapResID == _G.PWorldMgr:GetCurrMapResID() then
        WorldMapVM:SetDiscoveryFlag(Flag)
        MapVM:SetDiscoveryFlag(Flag)
        MapVM:SetIsAllActivate(Data.AllActivate)
        ModuleMapContentVM:SetDiscoveryFlag(Flag)
        ModuleMapContentVM:SetIsAllActivate(Data.AllActivate)
        if Data.AllActivate then
            WorldMapVM:SetMapMaskPath(nil)
            MapVM:SetMapMaskPath(nil)
            ModuleMapContentVM:SetMapMaskPath(nil)
        end
    end

    local function ShowFogUnlockTipCallback(Params)
        _G.MsgTipsUtil.ShowFogUnlockTips(Data.AllActivate)
    end

    --新手引导迷雾解锁处理
    local function OnTutorial(Params)
        --发送新手引导触发获得物品触发消息
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.Fog --新手引导触发类型
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    if not _G.PWorldMgr:CurrIsInDungeon() then
        local Config = {Type = ProtoRes.tip_class_type.TIP_SYS_NOTICE, Callback = ShowFogUnlockTipCallback, Params = {}}
        _G.TipsQueueMgr:AddPendingShowTips(Config)

        local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {}}
        _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)

        local NoticeCfgItem = SysnoticeCfg:FindCfgByKey(MsgTipsID.MapFogUnlock)
        if NoticeCfgItem then
            _G.ChatMgr:AddSysChatMsg(NoticeCfgItem.Content[1])
        end

        AudioUtil.LoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), FOG_UNLOCK_SOUND_PATH)
    end

    _G.EventMgr:SendEvent(EventID.UpdateFogInfo)
    FLOG_INFO("[FogMgr] active fog MapID="..tostring(Data.MapResID).."  , Flag=".. tostring(Flag).." , All="..tostring(Data.AllActivate))
end

function FogMgr:OnGameEventEnterWorld(Params)
    local MapResID = _G.PWorldMgr:GetCurrMapResID()
    self:SendGetMapFogInfo({MapResID})
end

function FogMgr:OnGameEventRoleLoginRes(Params)
    if self.AllHadFogMapIDList then
        self:SendGetMapFogInfo(self.AllHadFogMapIDList)
    end
    if Params.bReconnect then
        self.LateCheckDiscovery = true
    end
end

-- 解决副本有入场动画,跳过了迷雾解锁
function FogMgr:OnGameEventCheckDiscovery()
    local MapResID = _G.PWorldMgr:GetCurrMapResID()
    if self:IsAllActivate(MapResID) then
        return
    end
    local DiscoveryID, AreaID = _G.MapAreaMgr:GetDiscoveryID()
    if DiscoveryID and DiscoveryID > 0 then
        if not self:IsInFlag(MapResID, DiscoveryID) then
            self:SendActivateArea(AreaID)
        end
    end
end

return FogMgr