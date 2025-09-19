--[[
Author: ZhengJianChuan, lightpaw_Leo
Date: 2023-03-20 10:24:12
Description: 机遇临门活动管理器
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local LogMgr = require("Log/LogMgr")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsID = require("Define/MsgTipsID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local TimeUtil = require("Utils/TimeUtil")
local NpcDialogMgr = require("Game/NPC/NpcDialogMgr")
local EventMgr = require("Event/EventMgr")
local GoldSharpKnife = require("Game/Gate/GoldGame/GoldSharpKnife")
local GoldAirForce = require("Game/Gate/GoldGame/GoldAirForce")
local GoldSprayAir = require("Game/Gate/GoldGame/GoldSprayAir")
local GoldRescueChick = require("Game/Gate/GoldGame/GoldRescueChick")
local GoldGameLeapOfFaith = require("Game/Gate/GoldGame/GoldGameLeapOfFaith")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local GoldSauserGateCfg = require("TableCfg/GoldSauserGateCfg")
local AnyWayWindBlowsCfg = require("TableCfg/AnyWayWindBlowsCfg")
local MainPanelVM = require("Game/Main/MainPanelVM")
local ClientVisionMgr = require("Game/Actor/ClientVisionMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local GoldSauserVM = require("Game/Gate/GoldSauserVM")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local CliffHangerCfg = require("TableCfg/CliffHangerCfg")
local CommonDefine = require("Define/CommonDefine")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local BuffUtil = require("Utils/BuffUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local SettingsTabRole = require("Game/Settings/SettingsTabRole")
local MainPanelConfig = require("Game/Main/MainPanelConfig")

local UAudioMgr = nil
local MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE

local JDCoinResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
local LocalizationUtil = nil
local WorldMsgMgr = nil
local EActorType = _G.UE.EActorType
local EntertainGameID = ProtoRes.Game.GameID
local GoldSauserEntertainState = ProtoCS.GoldSauserEntertainState
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_GOLD_SAUSER_CMD
local LSTR = _G.LSTR
local MapEditorActorConfig = _G.MapEditorActorConfig
local PWorldMgr = _G.PWorldMgr
local MapEditDataMgr = _G.MapEditDataMgr
local GameNetworkMgr = nil
local JumboCactpotMgr = nil
local FLOG_ERROR = _G.FLOG_ERROR
local GoldSauserMgr = LuaClass(MgrBase)
local AirForceMapResIDList = {1008204, 1008205, 1008206} -- 金蝶空军装甲驾驶员场景

local RescueChickenTriggerIDOne = 2100000 -- 小雏鸟的触发区域ID
local RescueChickenTriggerIDTwo = 2200000 -- 小雏鸟的触发区域ID
local MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local CactusStandingPlatesID = 1 -- 仙人掌立牌的地图物件ID
local CactusStandingPlatesHideState = 6 -- 仙人掌立牌隐藏状态
local CactusStandingPlatesAirForceState = 5 -- 仙人掌立牌-空军装甲的播放状态
local CactusStandingPlatesLeapOfFaithState = 1 -- 仙人掌立牌-虚景跳跳乐的播放状态

function GoldSauserMgr:OnInit()
    LocalizationUtil = require("Utils/LocalizationUtil")
    self.RewardShowTimeLimit = 300000 -- 显示时间间隔为5分钟，300秒, 这里直接转化为ms
    self.JDMapID = 12060
    self.ChocoboMapID = 12061
    self.MarkerForSignupNpc = {
        ID = 1, -- 是一个活动NPC
        IconPath = GoldSauserDefine.TaskIcon.Ended,
        MapID = self.JDMapID,
        EntertainID = 1,
        bShow = false,
        BirthPoint = nil -- 后面写入，是对象的location
    }

    self.MarkerForChecken = {
        ID = 2, -- 是需要拯救的小雏鸟
        IconPath = GoldSauserDefine.TaskIcon.ChicksSignUp,
        MapID = self.JDMapID,
        EntertainID = EntertainGameID.GameIDCliffhanger,
        bShow = false,
        BirthPoint = nil -- 后面写入，是对象的location
    }

    LogMgr.Info("GoldSauserMgr:OnInit")
    self.BeginCountDownMusicPath =
        "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_CFTimeCount.Play_SE_UI_SE_UI_CFTimeCount'"

    self:ResetData()
end

function GoldSauserMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    UAudioMgr = _G.UE.UAudioMgr.Get()
    MsgTipsUtil = _G.MsgTipsUtil
    JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
    WorldMsgMgr = _G.WorldMsgMgr
end

---GoldSauserMgr.IsCurMapGoldSauserMap 当前地图是否为金蝶主场景地图
---@param InbIgnoreChocobo bool 是否忽略陆行鸟广场
---@return  bool Description
function GoldSauserMgr:IsCurMapGoldSauserMap(InbIgnoreChocobo)
    if (InbIgnoreChocobo) then
        return PWorldMgr.BaseInfo.CurrMapResID == self.JDMapID
    else
        return PWorldMgr.BaseInfo.CurrMapResID == self.JDMapID or PWorldMgr.BaseInfo.CurrMapResID == self.ChocoboMapID
    end
end

function GoldSauserMgr:IsPlayerSignup()
    if (not self:IsCurMapGoldSauserMap(true)) then
        return false
    end

    if (self.Entertain == nil) then
        return false
    end

    if (self.Player ~= ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp) then
        return false
    end

    return true
end

function GoldSauserMgr:IsCurMapAirForce()
    local CurMapResID = PWorldMgr.BaseInfo.CurrMapResID
    for K, V in pairs(AirForceMapResIDList) do
        if (V == CurMapResID) then
            return true
        end
    end

    return false
end

--- @type 更新活动报名NPC的地图标记，头顶标记
function GoldSauserMgr:RefreshGameNpcIconState(bForceRemove)
    self:InternalRefreshGameNpcIconState(bForceRemove)

    local NpcEntityID = self.SignupNpcEntityID
    if (NpcEntityID ~= nil and NpcEntityID > 0) then
        _G.EventMgr:SendEvent(_G.EventID.GateOppoNpcTaskIconUpdate, {EntityID = NpcEntityID})
    end
end

--- 最终处理报名NPC图标状态
function GoldSauserMgr:InternalRefreshGameNpcIconState(bForceRemove)
    if (self.Entertain == nil or bForceRemove) then
        self.MarkerForSignupNpc.bShow = false
        EventMgr:SendEvent(EventID.GoldSauserCommMapEnd, self.MarkerForSignupNpc.ID)
        EventMgr:SendEvent(
            EventID.WorldMapMarkerTipsListRemove,
            {
                SearchKeyName = "EntertainID",
                SearchKeyValue = self.MarkerForSignupNpc.EntertainID
            }
        )
        return
    end

    -- 虚景跳跳乐，报名过后，或者超出了报名时间，不显示
    if (self:IsGameLeapOfFaith()) then
        local bPlayerNotSignUp = self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_NotSignUp
        local bInProgress = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_InProgress
        if (not bPlayerNotSignUp or bInProgress) then
            self.MarkerForSignupNpc.bShow = false
            EventMgr:SendEvent(EventID.GoldSauserCommMapEnd, self.MarkerForSignupNpc.ID)
            EventMgr:SendEvent(
                EventID.WorldMapMarkerTipsListRemove,
                {
                    SearchKeyName = "EntertainID",
                    SearchKeyValue = self.MarkerForSignupNpc.EntertainID
                }
            )
            return
        end
    -- 空军装甲，只要报过名不显示
    elseif (self.Entertain.ID == EntertainGameID.GameIDAirForceOne) then
        local bPlayerNotSignUp = self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_NotSignUp
        if (not bPlayerNotSignUp) then
            self.MarkerForSignupNpc.bShow = false
            EventMgr:SendEvent(EventID.GoldSauserCommMapEnd, self.MarkerForSignupNpc.ID)
            EventMgr:SendEvent(
                EventID.WorldMapMarkerTipsListRemove,
                {
                    SearchKeyName = "EntertainID",
                    SearchKeyValue = self.MarkerForSignupNpc.EntertainID
                }
            )
            return
        end
    else
        -- 快刀和喷风在倒计时结束后，不显示ICON
        local bSliceRight = self.Entertain.ID == EntertainGameID.GameIDSliceIsRight
        local bSprayAir = self.Entertain.ID == EntertainGameID.GameIDAnyWayWindBlows
        if (bSliceRight or bSprayAir) then
            local bInProgress = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_InProgress
            if (bInProgress) then
                self.MarkerForSignupNpc.bShow = false
                self.MarkerForSignupNpc.IconPath = GoldSauserDefine.TaskIcon.Ended
                EventMgr:SendEvent(EventID.GoldSauserCommMapEnd, self.MarkerForSignupNpc.ID)
                EventMgr:SendEvent(
                    EventID.WorldMapMarkerTipsListRemove,
                    {
                        SearchKeyName = "EntertainID",
                        SearchKeyValue = self.MarkerForSignupNpc.EntertainID
                    }
                )
                return
            end
        end
    end

    do
        local bEarlyEnd = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_EarlyEnd
        local bEnd = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_End
        local bPlayerEnd = self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_End

        if (bEarlyEnd or bEnd or bPlayerEnd) then
            self.MarkerForSignupNpc.bShow = false
            self.MarkerForSignupNpc.IconPath = GoldSauserDefine.TaskIcon.Ended
            EventMgr:SendEvent(EventID.GoldSauserCommMapEnd, self.MarkerForSignupNpc.ID)
            EventMgr:SendEvent(
                EventID.WorldMapMarkerTipsListRemove,
                {
                    SearchKeyName = "EntertainID",
                    SearchKeyValue = self.MarkerForSignupNpc.EntertainID
                }
            )
            return
        end

        local WorldPos = self:GetSignupNpcLocation()
        self.MarkerForSignupNpc.BirthPoint = WorldPos
        self.MarkerForSignupNpc.bShow = true
        if (self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_NotSignUp) then
            self.MarkerForSignupNpc.IconPath = GoldSauserDefine.TaskIcon.NoSignUp
        elseif (self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp) then
            self.MarkerForSignupNpc.IconPath = GoldSauserDefine.TaskIcon.AlreadySignUp
        end

        EventMgr:SendEvent(EventID.GoldSauserCommMapUpdate, self.MarkerForSignupNpc)
    end
end

--- 更新小雏鸟的地图标记
function GoldSauserMgr:UpdateChickenIcon(bForceRemove)
    local ChickenActor = ActorUtil.GetActorByEntityID(self.ChickenEntityID)
    if (ChickenActor ~= nil and not bForceRemove) then
        local Location = ChickenActor:FGetActorLocation()

        self.MarkerForChecken.BirthPoint = Location

        if (self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp) then
            self.MarkerForChecken.bShow = true
            EventMgr:SendEvent(EventID.GoldSauserCommMapUpdate, self.MarkerForChecken)
        else
            self.MarkerForChecken.bShow = false
            EventMgr:SendEvent(EventID.GoldSauserCommMapEnd, self.MarkerForChecken.ID)
        end
    else
        self.MarkerForChecken.bShow = false
        EventMgr:SendEvent(EventID.GoldSauserCommMapEnd, self.MarkerForChecken.ID)
    end

    local NpcEntityID = self.ChickenEntityID
    if (NpcEntityID ~= nil and NpcEntityID > 0) then
        _G.EventMgr:SendEvent(_G.EventID.GateOppoNpcTaskIconUpdate, {EntityID = NpcEntityID})
    end
end

function GoldSauserMgr:GetSignupNpcLocation()
    local MapEditListID = self:GetCurGameSignupNpcMapListID()
    local NpcData = MapEditDataMgr:GetNpcByListID(MapEditListID)

    if (NpcData ~= nil) then
        local BirthPoint = NpcData[MapEditorActorConfig.Npc.PointKey]
        return BirthPoint
    end

    return nil
end

function GoldSauserMgr:OnEnd()
    self:ResetData()
end

function GoldSauserMgr:OnShutdown()
    self:ResetData()
end

function GoldSauserMgr:ResetData(InNotResetSpecialJump)
    _G.FLOG_INFO("GoldSauserMgr:ResetData")

    -- 首先清理各个玩法需要清理的东西
    if (self.CurGameClass ~= nil) then
        self.CurGameClass:GameStateToEnd(self, self.GoldSauserVM)
    end

    if (not InNotResetSpecialJump) then
        self.EnableSpecialJumpRecordGameID = 0
    end

    self.MarkerForChecken.bShow = false
    self:SetToggleInfoPanel(false) -- VM那边不是跟着角色的，会一直存在，换号了也是，所以这里需要关闭一下

    self:DestroyCurGameSignUpNpc()
    self.bRequireReward = false
    self.HasPlaySignUp = false
    self.bHasPlayerSignUp = false -- 因为网络协议顺序的问题，报名之后需要先在本地做一个缓存
    self.CurGameClass = nil -- 当前进行的那种游戏
    self.TeleportToStage = false -- 是否传送到了舞台

    self.CacheTableData = {} -- 表格数据缓存
    self.CliffHangerCfgCache = {} -- 表格数据缓存
    self.SignupRecordMapID = 0
    self.Index = 0
    self.Entertain = nil -- 游戏状态
    self.Player = ProtoCS.GoldSauserPlayer.GoldSauserPlayer_NotSignUp -- 默认是没报名状态
    self.Round = 0 -- 当前轮数
    self.SignUpEndTime = nil
    self.CurrMapResID = nil -- 当前进入的场景ID
    self.CacheTableData = {}
    if (self.PlayedBGMUniqueID ~= nil) then
        if (UAudioMgr ~= nil) then
            UAudioMgr:StopBGM(self.PlayedBGMUniqueID)
        end
    end
    self.PlayedBGMUniqueID = 0 -- 当前机遇临门游戏播放的BGM唯一ID，用于机遇临门游戏结束后关闭掉
    self.GetCachedResetCameraParams = nil
    self.SignupNpcEntityID = 0 -- 创建的npc全局id
    self:InternalSetChickenEntityID(0) -- 拯救小雏鸟的 entityID
    if (self.GoldSauserVM == nil) then
        self.GoldSauserVM = GoldSauserVM.New()
    else
        self.GoldSauserVM:ResetData()
    end
    -- 确保关闭倒计时界面
    if UIViewMgr:IsViewVisible(UIViewID.PlayStyleCountDownTips) then
        UIViewMgr:HideView(UIViewID.PlayStyleCountDownTips)
    end
end

function GoldSauserMgr:InternalSetChickenEntityID(InValue)
    self.ChickenEntityID = InValue
    self:UpdateChickenIcon()
end

function GoldSauserMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER, SUB_MSG_ID.CS_GOLD_SAUSER_CMD_SIGNUP, self.OnNetSignUp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER, SUB_MSG_ID.CS_GOLD_SAUSER_CMD_RESIGNUP, self.OnNetReSignup)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER, SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATE, self.OnUpdateGameInfoRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER, SUB_MSG_ID.CS_GOLD_SAUSER_CMD_END, self.OnNetEndGame)
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_GOLD_SAUSER,
        SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATE_NOTIFY,
        self.OnGameInfoNotify
    )
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_GOLD_SAUSER,
        SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATE_GAME_STATE,
        self.OnNetUpdateGameData
    )
end

function GoldSauserMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
    self:RegisterGameEvent(EventID.WorldPostLoad, self.OnWorldPostLoad)
    self:RegisterGameEvent(EventID.WorldPreLoad, self.OnWorldPreLoad)
    self:RegisterGameEvent(EventID.PWorldTransBegin, self.OnPWorldTransBegin)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnPWorldMapExit)
    self:RegisterGameEvent(EventID.NPCCreate, self.OnNPCCreate)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
    self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnEnterAreaTrigger)
    self:RegisterGameEvent(EventID.AreaTriggerEndOverlap, self.OnLeaveAreaTrigger)
    self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOver)
    self:RegisterGameEvent(EventID.TutorialMainPanelReActive, self.OnTutorialMainPanelReActive)
    self:RegisterGameEvent(EventID.TutorialMainPanelInActive, self.OnTutorialMainPanelInActive)
end

function GoldSauserMgr:OnTutorialMainPanelReActive()
    if (self:IsCurMapGoldSauserMap()) then
        local TargetView = UIViewMgr:FindVisibleView(UIViewID.GateMainCountDownPanel)
        if (TargetView ~= nil) then
            TargetView:SetVisible(true)
        else
            _G.UIViewMgr:ShowView(UIViewID.GateMainCountDownPanel)
        end
    end
end

function GoldSauserMgr:OnTutorialMainPanelInActive()
    if (self:IsCurMapGoldSauserMap()) then
        local TargetView = UIViewMgr:FindVisibleView(UIViewID.GateMainCountDownPanel)
        if (TargetView ~= nil) then
            TargetView:SetVisible(false)
        end
    end
end

function GoldSauserMgr:OnMajorSingBarOver(EntityID, IsBreak, SingStateID)
    if not MajorUtil.IsMajor(EntityID) then
        return
    end

    if SingStateID == 40 then
        -- 这里是水晶传送，取消掉小雏鸟的检测
        if (self.CurGameClass ~= nil and self.CurGameClass.StopTickForHeightCheck ~= nil) then
            self.CurGameClass:StopTickForHeightCheck()
        end
    end
end

function GoldSauserMgr:OnPWorldReady(Params)
    if (self.EnableSpecialJumpRecordGameID ~= nil and self.EnableSpecialJumpRecordGameID > 0) then
        if (self.EnableSpecialJumpRecordGameID == EntertainGameID.GameIDCliffhanger) then
            -- 只要当前地图不是金碟游乐场，那么弹出提示
            if (not self:IsCurMapGoldSauserMap(true)) then
                self:RecoverSpecialJumpTips()
            end
        elseif (self.EnableSpecialJumpRecordGameID == EntertainGameID.GameIDLeapOfFaithA) then
            -- 只要当前地图不是跳跳乐，弹出提示
            if (not _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
                self:RecoverSpecialJumpTips()
            end
        else
            _G.FLOG_WARNING(
                "GoldSauserMgr:OnPWorldReady 出错，未处理的类型:%s", self.EnableSpecialJumpRecordGameID
            )
        end
    end
end

function GoldSauserMgr:OnAssembleAllEnd(Params)
end

function GoldSauserMgr:OnWorldPostLoad(Params)
end

function GoldSauserMgr:OnNPCCreate(Params)
    if (Params == nil) then
        return
    end

    if (not self:IsCurMapGoldSauserMap(true)) then
        return
    end

    local EntityID = Params.ULongParam1
    local NpcID = Params.IntParam1

    self:InternalCheckGameNpcs(EntityID, NpcID)
end

function GoldSauserMgr:InternalCheckGameNpcs(EntityID, NpcID)
    if (NpcID == nil or EntityID == nil) then
        _G.FLOG_ERROR("GoldSauserMgr:InternalCheckGameNpcs 错误，传入的参数为nil，请检查")
        return
    end

    local Result = GoldSauserDefine.RescueChickenResID[NpcID]
    if (Result ~= nil) then
        self:InternalSetChickenEntityID(EntityID)
        return
    end

    -- 避免加载失败的情况，后续看LISTID是否匹配
    local TargetActor = ActorUtil.GetActorByEntityID(EntityID)
    if (TargetActor ~= nil) then
        local ActorType = TargetActor:GetActorType()
        if (ActorType ~= nil and ActorType == EActorType.Npc) then
            local AttrCmp = TargetActor:GetAttributeComponent()
            if AttrCmp then
                local TargetListID = AttrCmp.ListID
                if (TargetListID ~= nil and TargetListID > 0) then
                    local CurGameListID = self:GetCurGameSignupNpcMapListID()
                    if (TargetListID == CurGameListID) then
                        self:SetSignUpNpcEntityID(EntityID)
                    end
                end
            end
        end
    end
end

function GoldSauserMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params.bReconnect
    if bReconnect and self:IsCurMapGoldSauserMap() then
        self:ResetData()
        self:SendUpdateGame()
    end
end

function GoldSauserMgr:OnWorldPreLoad(Params)
end

function GoldSauserMgr:OnPWorldMapExit()
end

function GoldSauserMgr:OnPWorldTransBegin()
    self.HasTransBegin = true

    if (WorldMsgMgr.IsShowLoadingView) then
        -- 这里是要进黑幕加载了，等加载完成后再显示
        self.SignupNpcEntityID = 0
        self:InternalSetChickenEntityID(0)
    else
        -- 这里是直接传送的，这里就不用缓存了，直接显示就好了
        if (self.SignupRecordMapID ~= nil and PWorldMgr.BaseInfo.CurrMapResID == self.SignupRecordMapID) then
            if (self.bNeedPlaySignupAnim) then
                self.bNeedPlaySignupAnim = false
                if (self.CurGameClass ~= nil) then
                    self.CurGameClass:ShowInfoAfterSignup(self)
                end

                if (self.TeleportToStage == true) then
                    self.TeleportToStage = false
                    self:ResetCameraAfterTeleport()
                end
            end
        end
        self.SignupRecordMapID = nil

        if (self.Entertain ~= nil and self.Entertain.ID == EntertainGameID.GameIDCliffhanger) then
            if (self.CurGameClass ~= nil) then
                self.CurGameClass:JudgeForNeedCheckHeight()
            end
        end
    end
end

-----------------------------------------------协议相关-------------------------------------------------
---SendSignUpGame      @报名游戏
---@param Round number @当前轮数
function GoldSauserMgr:SendSignUpGame(InRound)
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_SIGNUP

    local TargetRound = InRound
    if (TargetRound == nil or TargetRound == 0) then
        TargetRound = self.Round
    end
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.SignUp = {Round = TargetRound}
    self.bHasPlayerSignUp = true
    self.SignupRecordMapID = PWorldMgr:GetCurrMapResID()
    self.TeleportToStage = true
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    self.bNeedPlaySignupAnim = true
end

-- 重新报名
function GoldSauserMgr:SendReSignUpGame()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_RESIGNUP
    self.bHasPlayerSignUp = true
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 传送到相关npc附近
function GoldSauserMgr:SendTeleReq()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_TELE

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    --MsgBody.Tele = {Round = self.Round}

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GoldSauserMgr:ResetCameraAfterTeleport()
    if (self.Entertain == nil or self.Entertain.ID ~= EntertainGameID.GameIDCliffhanger) then
        return
    end

    local TableData = self:GetCachedCliffHangerCfg()
    -- 目前只有小雏鸟需要特定的摄像机镜头
    if (self.GetCachedResetCameraParams == nil) then
        self.GetCachedResetCameraParams = {}
    end
    -- CacheData.Length = 800
    -- CacheData.AnglePich = -10
    -- CacheData.AngleYaw = -90
    local Key = self:GoldRescueChickGetStage()
    local CacheData = self.GetCachedResetCameraParams[Key]
    if (CacheData == nil) then
        if (TableData ~= nil and TableData.ResetCameraParams ~= nil and TableData.ResetCameraParams ~= "") then
            local ParamsStr = TableData.ResetCameraParams
            local SplitTable = string.split(ParamsStr, ",")
            if (#SplitTable >= 3) then
                CacheData = {}
                CacheData.Length = SplitTable[1]
                CacheData.AnglePich = SplitTable[2]
                CacheData.AngleYaw = SplitTable[3]
            end
            self.GetCachedResetCameraParams[Key] = CacheData
        end
    end
    if (CacheData ~= nil) then
        local Major = MajorUtil.GetMajor()
        local Camera = Major:GetCameraControllComponent()
        local CameraParams = _G.UE.FCameraResetParam()
        local CurDist = Camera:GetTargetArmLength()
        _G.FLOG_INFO("摄像机距离：%s", CurDist)
        if (CurDist == nil or CurDist < 10) then
            _G.FLOG_WARNING("摄像机距离过近，将设置为默认800距离")
            CurDist = 800
        end

        CameraParams.Distance = CurDist
        CameraParams.Rotator = _G.UE.FRotator(CacheData.AnglePich, CacheData.AngleYaw, 0)
        CameraParams.bRelativeRotator = true
        CameraParams.Offset = _G.UE.FVector(0, 0, 0)
        CameraParams.ResetType = _G.UE.ECameraResetType.Jump
        CameraParams.LagValue = 10
        Camera:ResetSpringArmByParam(_G.UE.ECameraResetLocation.RecordLocation, CameraParams)
    end
end

--- @type 传送到舞台
function GoldSauserMgr:SendTeleToStageReq()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_TELE_TO_STAGE

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID

    local ID = self.Entertain.ID

    local bSprayAir = ID == EntertainGameID.GameIDAnyWayWindBlows
    local bSharpeKnife = ID == EntertainGameID.GameIDSliceIsRight

    self.SignupRecordMapID = PWorldMgr:GetCurrMapResID()

    self.TeleportToStage = true
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GoldSauserMgr:SendUpdateGame()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATE

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.UpdateReq = {
        SceneInstID = _G.PWorldMgr.BaseInfo.CurrPWorldInstID
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 请求结算
function GoldSauserMgr:SendEndGameReq(Score, Success)
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_END

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.End = {
        Round = self.Round,
        Score = Score,
        Success = Success
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 重新请求结算（用于断线重连后）
function GoldSauserMgr:ResendEndGameReq(Round, Score)
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_END

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.End = {
        Round = Round,
        Score = Score,
        Success = true
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 更新得分
---@param Score number  @当前分数
function GoldSauserMgr:SendUpdateScoreReq(Score)
    --SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATESCORE
    --协议后台删除了，需要调用通用存储接口来存
    local Content = string.format("%d|%d", self.Round or 0, Score or 0)
    _G.ClientSetupMgr:SendSetReq(ClientSetupID.RideShootingLastRecord, Content)
end

--- @type 金币兑换金碟币请求
function GoldSauserMgr:SendExchangeJDCoin()
    local Cfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_GOLD_SAUCER_QUICK_EXANGE)
    if Cfg == nil then
        return
    end
    local GoldCodeNum = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    if GoldCodeNum < Cfg.Value[2] then
        MsgTipsUtil.ShowTips(LSTR(1270031)) -- 金币不足
        return
    end

    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_QUICK_EXANGE

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 报名的Rsq
function GoldSauserMgr:OnNetSignUp(MsgBody)
    self.bNeedPlaySignupAnim = true
    if (self.CurGameClass ~= nil) then
        self.bHasPlayerSignUp = true
        self.Player = ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp
        self.CurGameClass:NetPlayerSignUp(self, self.GoldSauserVM)
    else
        self:ResetData()
        self:SendUpdateGame()
    end
end

function GoldSauserMgr:OnNetReSignup(MsgBody)
    if (self.CurGameClass ~= nil) then
        self.bHasPlayerSignUp = true
        self.Player = ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp
        self.CurGameClass:NetPlayerSignUp(self, self.GoldSauserVM)
        self.CurGameClass:ShowInfoAfterSignup(self)
    else
        self:ResetData()
        self:SendUpdateGame()
    end
end

-- 服务器下发的通知，这里通知的是游戏的阶段发生了变化
function GoldSauserMgr:OnGameInfoNotify(MsgBody)
    -- 本地数据无效，直接请求更新数据
    if (self.CurGameClass == nil or self.Entertain == nil) then
        self:ResetData()
        self:SendUpdateGame()
        return
    end

    local Data = MsgBody.UpdateNotify
    if (Data == nil) then
        _G.FLOG_ERROR("GoldSauserMgr:OnGameInfoNotify 出错，下发的数据为空，请检查")
        return
    end

    if (Data.Entertain == nil) then
        _G.FLOG_ERROR("错误， GoldSauserMgr:OnGameInfoNotify 下发的 Entertain 为空，请检查")
        self:ResetData()
        self:SendUpdateGame()
        return
    end

    -- 轮次不同，游戏不同，放弃本地的数据，重新请求
    if (self.Round ~= Data.Round or self.Entertain.ID ~= Data.Entertain.ID) then
        _G.FLOG_INFO("轮次不同，游戏不同，清理数据，重新请求，本地轮次:%s, 服务器下发轮次:%s", self.Round, Data.Round)
        -- 游戏结束，清理一下
        self.bHasPlayerSignUp = false
        self.CurGameClass:GameStateToEnd(self, self.GoldSauserVM)
        self.CurGameClass = nil
        self:DestroyCurGameSignUpNpc()
        self:ResetData()
        self:SendUpdateGame()
        return
    end

    self.Entertain = Data.Entertain
    self.Round = Data.Round -- 游戏当前轮数
    self.SignUpEndTime = self.Entertain.SignUpEndTime
    self.NextID = self.Entertain.NextID
    self.MarkerForSignupNpc.EntertainID = self.Entertain.ID

    if (self.CurGameClass == nil) then
        self:InternalCreateGameClass(Data)
    end

    if (self.CurGameClass == nil) then
        _G.FLOG_ERROR("错误，self.CurGameClass 为空，请检查")
        return
    end

    self:UpdateGameByState(true)
    self:UpdateCactusStandPlateState()
end

-- 消息是 GoldSauserUpdateRsp， 是通过发送 GoldSauserUpdateReq 主动获取的
function GoldSauserMgr:OnUpdateGameInfoRsp(MsgBody)
    if nil == MsgBody then
        _G.FLOG_ERROR("GoldSauserMgr:OnUpdateGameInfoRsp 错误，msg 为空，请检查")
        return
    end

    local Data = MsgBody.Update
    if (Data == nil) then
        _G.FLOG_ERROR("GoldSauserMgr:OnUpdateGameInfoRsp 错误，msg.update 为空，请检查")
        return
    end

    if Data.Entertain == nil then
        _G.FLOG_ERROR("GoldSauserMgr:OnUpdateGameInfoRsp 错误，Data.Entertain 为空")
        return
    end

    local bNotSameRound = self.Round ~= 0 and self.Round ~= Data.Round
    local bNotSameGame = self.Entertain ~= nil and self.Entertain.ID ~= Data.Entertain.ID
    if (bNotSameRound or bNotSameGame) then
        self:ResetData()
        self:SendUpdateGame()
        return
    end

    self.Entertain = Data.Entertain
    self.Round = Data.Round -- 游戏当前轮数
    self.Player = Data.Player
    self.SignUpEndTime = self.Entertain.SignUpEndTime
    self.NextID = self.Entertain.NextID

    if (self.CurGameClass == nil) then
        self:InternalCreateGameClass(Data)
    end

    if (self.CurGameClass == nil) then
        _G.FLOG_ERROR("错误，self.CurGameClass 为空，请检查")
        return
    end

    if (Data.RewardRecord ~= nil and Data.RewardRecord.FinishTime > 0) then
        -- 这里显示奖励
        local ServerTimeNow = TimeUtil.GetServerLogicTimeMS()
        local TimeSpan = ServerTimeNow - Data.RewardRecord.FinishTime * 1000
        if (TimeSpan < self.RewardShowTimeLimit) then
            if (Data.RewardRecord.Success == true) then
                local CurGame = self.CurGameClass
                self:ShowGoldSauserOpportunityForResult(
                    GoldSauserDefine.PopType.Win,
                    Data.RewardRecord.AwardCoins,
                    function(Params)
                        CurGame:AfterGateOpportunityRewardAnimEnd(Params)
                    end,
                    Data.RewardRecord.ItemID2Num
                )
            else
                local CurGame = self.CurGameClass
                self:ShowGoldSauserOpportunityForResult(
                    GoldSauserDefine.PopType.Lose,
                    Data.RewardRecord.AwardCoins,
                    function(Params)
                        CurGame:AfterGateOpportunityRewardAnimEnd(Params)
                    end,
                    Data.RewardRecord.ItemID2Num
                )
            end
        else
            _G.FLOG_WARNING("机遇临门的奖励显示时间超时了，将不显示")
        end
    end

    self:UpdateGameByState(false)

    local bNeedReSignup = self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUpLeaveStage
    if (bNeedReSignup) then
        local bSignUpState = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_SignUp
        if (bSignUpState) then
            self:SendReSignUpGame()
        end
    else
        local bPlayerSignUp = self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp
        local bCurGameSignUpState = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_SignUp
        -- 如果当前是小雏鸟，并且玩家的状态报名状态，并且上一个地图不是金碟主地图,那么弹出一下机遇临门
        local bBirdGame = self.Entertain.ID == EntertainGameID.GameIDCliffhanger
        if (bBirdGame and bPlayerSignUp and bCurGameSignUpState) then
            local LastMapResID = PWorldMgr.BaseInfo.LastPWorldResID
            local bLastMapNotJD = LastMapResID == 0 or LastMapResID ~= self.JDMapID
            if (bLastMapNotJD) then
                self:ShowGoldSauserOpportunityForBegin()
            end
        end
    end

    self.bRequireReward = false -- 是否在请求奖励

    -- 处理在游戏中重登的数据
    local bInProgress = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_InProgress
    if (bInProgress) then
        local EntertainID = self.Entertain.ID
        if EntertainID == EntertainGameID.GameIDAnyWayWindBlows then
            -- 喷风小游戏走这个
            self:UpdateInfoData(Data)
        elseif EntertainID == EntertainGameID.GameIDSliceIsRight then
            if (self.CurGameClass ~= nil and Data.PlayerSIR ~= nil) then
                -- 快刀斩魔 ， 需要直接设置，通用的更新里面有一些阶段相关
                self.CurGameClass:DirectRefreshInfoData(self, self.GoldSauserVM, Data)
            end
        end
    end
    -- 处理完成

    self:UpdateCactusStandPlateState()
end

function GoldSauserMgr:OnBtnExitClicked()
    if (self.CurGameClass == nil) then
        _G.FLOG_ERROR("GoldSauserMgr:OnBtnExitClicked 出错，当前没有游戏，请检查")
        return
    end

    self.CurGameClass:OnBtnExitClicked()
end

function GoldSauserMgr:InternalCreateGameClass(InMsg)
    local EntertainID = self.Entertain.ID
    self.MarkerForSignupNpc.EntertainID = EntertainID

    if (self.CurGameClass ~= nil) then
        self.CurGameClass:CancelAllTimer()
        self.CurGameClass = nil
    end

    if (self.CurGameClass == nil) then
        if EntertainID == EntertainGameID.GameIDAnyWayWindBlows then
            self.CurGameClass = GoldSprayAir.New() -- 喷风小游戏
        elseif EntertainID == EntertainGameID.GameIDSliceIsRight then
            self.CurGameClass = GoldSharpKnife.New() -- 快刀小游戏
        elseif EntertainID == EntertainGameID.GameIDAirForceOne then
            self.CurGameClass = GoldAirForce.New() -- 空军小游戏
        elseif EntertainID == EntertainGameID.GameIDLeapOfFaithA or EntertainID == EntertainGameID.GameIDLeapOfFaithB then
            self.CurGameClass = GoldGameLeapOfFaith.New() -- 跳跳乐小游戏
        elseif EntertainID == EntertainGameID.GameIDCliffhanger then
            self.GoldRescueChickStage = InMsg.Param -- 小雏鸟
            if (self.GoldRescueChickStage == nil or self.GoldRescueChickStage == 0) then
                self.GoldRescueChickStage = self.Entertain.NextParam
            end
            self.CurGameClass = GoldRescueChick.New() -- 小雏鸟营救
        else
            _G.FLOG_ERROR("错误，当前的机遇临门游戏为创建，ID是 : " .. tostring(EntertainID))
            return
        end

        self.CurGameClass:Init(self)
    end
end

function GoldSauserMgr:IsGameLeapOfFaith()
    if (self.Entertain == nil) then
        return false
    end
    local EntertainID = self.Entertain.ID
    local bGameA = EntertainID == EntertainGameID.GameIDLeapOfFaithA
    local bGameB = EntertainID == EntertainGameID.GameIDLeapOfFaithB
    return bGameA or bGameB
end

--- @type 更新空军动态物件
function GoldSauserMgr:UpdateCactusStandPlateState()
    if (self.Entertain == nil or self.CurGameClass == nil) then
        PWorldMgr:LocalUpdateDynData(
            MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE,
            CactusStandingPlatesID,
            CactusStandingPlatesHideState
        ) -- 立牌消失
        return
    end

    local bGameEnd = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_End
    local bGameEarlyEnd = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_EarlyEnd
    if (bGameEnd or bGameEarlyEnd) then
        PWorldMgr:LocalUpdateDynData(
            MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE,
            CactusStandingPlatesID,
            CactusStandingPlatesHideState
        ) -- 立牌消失
        return
    end

    local bIsAirForce = self.Entertain.ID == EntertainGameID.GameIDAirForceOne
    if (bIsAirForce) then
        PWorldMgr:LocalUpdateDynData(
            MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE,
            CactusStandingPlatesID,
            CactusStandingPlatesAirForceState
        ) -- 空军小游戏动态物件显示
    elseif (self:IsGameLeapOfFaith()) then
        PWorldMgr:LocalUpdateDynData(
            MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE,
            CactusStandingPlatesID,
            CactusStandingPlatesLeapOfFaithState
        ) -- 虚景跳跳乐动态物件显示
    else
        PWorldMgr:LocalUpdateDynData(
            MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE,
            CactusStandingPlatesID,
            CactusStandingPlatesHideState
        ) -- 立牌消失
    end
end

--- @type 当玩法状态更新，目前只有快刀、喷风用到了，用于更新阶段
function GoldSauserMgr:OnNetUpdateGameData(MsgBody)
    if (MsgBody == nil) then
        _G.FLOG_ERROR("出错了，GoldSauserMgr:OnNetUpdateGameData ， MsgBody 为空，请检查")
        return
    end

    local Data = MsgBody.UpdateGameState
    if (Data == nil) then
        _G.FLOG_ERROR("InternalUpdateGameStateInfo 错误，传入的Data为空，请检查")
        return
    end

    if (self.Entertain == nil or self.CurGameClass == nil) then
        _G.FLOG_ERROR("当前没有 Entertain， 将请求数据下发，请检查")
        self:ResetData()
        self:SendUpdateGame()
        return
    end

    self:UpdateInfoData(Data)
end

function GoldSauserMgr:GetEntertainState()
    if (self.Entertain == nil) then
        return ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_Invalid
    end
    return self.Entertain.State
end

function GoldSauserMgr:GetHasSignUp()
    if (self.Player == nil) then
        return false
    end

    return self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp or self.bHasPlayerSignUp
end

--- 当前是否金蝶副本
function GoldSauserMgr:CurrIsGoldSauserDungeon()
    local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    if not self.RideShootingIDTable then
        self.RideShootingIDTable =
            GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_AIR_FORCE_ONE_SCENE_ID, "Value")
    end
    if table.contain(self.RideShootingIDTable, PWorldResID) then
        return true
    end
    return false
end

--- @type 玩家游玩状态结束
function GoldSauserMgr:OnNetEndGame(MsgBody)
    self.bHasPlayerSignUp = false
    self.Player = ProtoCS.GoldSauserPlayer.GoldSauserPlayer_End

    -- 这里去结束一下游戏
    if (self.CurGameClass ~= nil) then
        self.CurGameClass:PlayerGameEnd(self, self.GoldSauserVM, MsgBody)
    end

    self.bRequireReward = true

    self:SendUpdateGame()
end
-----------------------------------------------------------End---------------------------------------------------------

-------------------------------------------------------对外接口---------------------------------------------------------
--- @type 展示通用提示
---@param Content string @提示内容
function GoldSauserMgr:ShowCommTips(Content)
    MsgTipsUtil.ShowActiveTips(Content, nil, nil, nil)
end

--- @type 展示获得奖励界面
---@param Data table @数据
function GoldSauserMgr:ShowCommRewardPanel(InDataVMList, Title, HideCallback)
    local IsInPanelMiniGame = _G.GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true) -- 小游戏过程中防止触发影响小游戏
    if IsInPanelMiniGame then
        return
    end
    UIViewMgr:ShowView(
        UIViewID.CommonRewardPanel,
        {
            Title = Title,
            ItemVMList = InDataVMList,
            CloseCallback = HideCallback,
            ShowPanelGoldSauser = true,
        }
    )
end

--- @type 动态更新游戏信息
function GoldSauserMgr:UpdateInfoData(NetMsg)
    if self.CurGameClass ~= nil then
        self.CurGameClass:NetUpdateGameData(NetMsg, self, self.GoldSauserVM)
    else
        FLOG_ERROR("GoldSauserMgr:UpdateInfoData(NetMsg) 出错 , 传入的 NetMsg 数据为空，请检查")
    end
end

--- @type 主动结束游戏
function GoldSauserMgr:EndGame(...)
    if (self.CurGameClass ~= nil) then
        self.CurGameClass:EndGame(...)
    end

    self.SignupRecordMapID = nil
end

--- @type 小雏鸟配表的主键
function GoldSauserMgr:GoldRescueChickGetStage()
    return self.GoldRescueChickStage
end

--- @type 判断是否是出于可报名状态
function GoldSauserMgr:CanSignUp()
    if (self.Entertain == nil) then
        return false
    end

    local bSignupState = self.Entertain.State == ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_SignUp
    local bPlayerNotSignup = self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_NotSignUp

    if (bSignupState and bPlayerNotSignup) then
        return true
    end

    return false
end

--- @type 获取当前活动的Npc，地图指引用，会在界面生成一个仙人掌的指引图标
function GoldSauserMgr:GetCurGameNpc()
    local Entertain = self.Entertain
    if Entertain == nil then
        return
    end
    local NpcListID = self:GetCurGameSignupNpcMapListID()
    local Npc = MapEditDataMgr:GetNpcByListID(NpcListID)
    if Npc == nil then
        return
    end
    return Npc
end

--------------------------------------------------------End---------------------------------------------------------

-------------------------------------------------------注册事件---------------------------------------------------------
--- @type 尝试打开去往活动地点提示
function GoldSauserMgr.TryOpenMsg()
    if NpcDialogMgr:IsDialogPlaying() then
        return
    end

    local function ClickYesCallBack()
        GoldSauserMgr:SendTeleReq()
    end
    local Content = LSTR(1270007)
    local Title = LSTR(10032)
    GoldSauserMgr:ShowStyleCommWin(GoldSauserMgr, Title, Content, ClickYesCallBack)
end

--- @type 当加载完世界
function GoldSauserMgr:OnPWorldEnter(Params)
    if (self:IsCurMapGoldSauserMap()) then
        _G.UIViewMgr:ShowView(UIViewID.GateMainCountDownPanel)
        if (self.bNeedPlaySignupAnim) then
            if (self.CurGameClass ~= nil) then
                self.CurGameClass:ShowInfoAfterSignup(self)
            end

            if (self.TeleportToStage == true) then
                self.TeleportToStage = false
                self:ResetCameraAfterTeleport()
            end
            self.bNeedPlaySignupAnim = false
        end

        local BaseInfo = PWorldMgr.BaseInfo
        local LastMapResID = 0
        if (self.HasTransBegin) then
            LastMapResID = BaseInfo.LastTransMapResID
        else
            LastMapResID = BaseInfo.LastMapResID -- 不同地图
        end

        local bIsLastAirForce = false
        for K, V in pairs(AirForceMapResIDList) do
            if (V == LastMapResID) then
                bIsLastAirForce = true
                break
            end
        end

        local bNotSameJDMap = (LastMapResID ~= 0 and LastMapResID ~= self.JDMapID) or bIsLastAirForce
        local bNeedUpdate = true
        if (self.Entertain ~= nil and self.CurGameClass ~= nil) then
            local GameState = self.Entertain.State
            local bEnd = GameState == GoldSauserEntertainState.GoldSauserEntertainState_End
            local bEarlyEnd = GameState == GoldSauserEntertainState.GoldSauserEntertainState_EarlyEnd

            if (bEnd or bEarlyEnd) then
                bNeedUpdate = false
            end
        end
        local bChangeLine = Params.bChangeLine or false
        if (bChangeLine) then
            _G.FLOG_INFO("GoldSauserMgr ，因为 发生了切分线为空，需要重置数据，拉取新数据")
            bNeedUpdate = true
        end

        if (bNeedUpdate or bNotSameJDMap) then
            local NotResetSpecialJump = true
            self:ResetData(NotResetSpecialJump)
            self:SendUpdateGame()
        end

        if (self.SignupRecordMapID == PWorldMgr.BaseInfo.CurrMapResID) then
            if (self.CurGameClass ~= nil) then
                self.CurGameClass:ShowInfoAfterSignup(self)
            end

            if (self.TeleportToStage == true) then
                self.TeleportToStage = false
                self:ResetCameraAfterTeleport()
            end
        end
        self:UpdateCactusStandPlateState()
        self.HasTransBegin = false
        self.SignupRecordMapID = 0
    else
        self:SetToggleInfoPanel(false)
    end
end

function GoldSauserMgr:SendGoldSauserUpdateReq()
end

function GoldSauserMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    if (LeaveMapResID == self.JDMapID or LeaveMapResID == self.ChocoboMapID) then
        _G.UIViewMgr:HideView(UIViewID.GateMainCountDownPanel)
        local NotResetSpecialJump = true
        self:ResetData(NotResetSpecialJump)
    end
end

--- @type Actor进入视野
function GoldSauserMgr:OnGameEventVisionEnter(Params)
    if (Params == nil) then
        return
    end

    if (not self:IsCurMapGoldSauserMap(true)) then
        return
    end

    local ResID = Params.IntParam2
    local EntityID = Params.ULongParam1

    -- 这里也看下chicken
    self:InternalCheckGameNpcs(EntityID, ResID)
end

-------------------------------------------------------End---------------------------------------------------------

--------------------------------------------------------Npc交互-----------------------------------------------------------

-- 开始游戏用的动画
function GoldSauserMgr:ShowGoldSauserOpportunityForBegin(AnimFinishCallbackFunc)
    local Params = {
        Type = GoldSauserDefine.PopType.Gate,
        AnimFinichCallback = AnimFinishCallbackFunc
    }
    UIViewMgr:ShowView(UIViewID.GoldSauserOpportunityPanel, Params)
end

function GoldSauserMgr:ShowEnableSpecialJumpMsgBox(InRecordGameID)
    local bEnableSpecialJump = SettingsTabRole:GetEnableSpecialJump() == 1
    if (not bEnableSpecialJump) then
        MsgBoxUtil.ShowMsgBoxTwoOp(
            self,
            "", -- 不显示标题
            LSTR(1270037), -- 是否开启跳跃辅助功能？
            function()
                local bActive = 1
                SettingsTabRole:SetEnableSpecialJump(bActive) -- 开启辅助跳越
                self.EnableSpecialJumpRecordGameID = InRecordGameID
            end,
            nil,
            LSTR(10028), --否
            LSTR(10027) --是
        )
    end
end

function GoldSauserMgr:RecoverSpecialJumpTips()
    if (self.EnableSpecialJumpRecordGameID == nil or self.EnableSpecialJumpRecordGameID == 0) then
        return
    end
    self.EnableSpecialJumpRecordGameID = 0
    local bDisable = 2
    SettingsTabRole:SetEnableSpecialJump(bDisable) -- 关闭辅助跳越
    local Content = LSTR(1270038)
    MsgTipsUtil.ShowTips(Content)
end

-- 结算用的动画
---@param PopType                GoldSauserDefine.PopType 是赢还是输
---@param AwardCoins             int32 奖励金碟币数量
---@param AnimFinishCallbackFunc func 动画完成后的回调
---@param InRewardDataTable      额外奖励Table [int32,int32] goldsauser.proto 里面的 GateRewardRecord.ItemID2Num
---@return  Type Description
function GoldSauserMgr:ShowGoldSauserOpportunityForResult(PopType, AwardCoins, AnimFinishCallbackFunc, InRewardDataTable)
    local List = {}
    if (AwardCoins ~= nil and AwardCoins > 0) then
        local Elem = {}
        Elem.ID = JDCoinResID
        Elem.Num = AwardCoins
        table.insert(List, Elem)
    end

    if (InRewardDataTable ~= nil) then
        for Key, Value in pairs(InRewardDataTable) do
            local Elem = {}
            Elem.ID = Key
            Elem.Num = Value
            table.insert(List, Elem)
        end
    end

    local RewardItemVMList = self:UpdateRewardListVM(List)

    local Params = {
        Type = PopType,
        AwardCoins = AwardCoins,
        AnimFinichCallback = AnimFinishCallbackFunc,
        RewardData = RewardItemVMList
    }

    UIViewMgr:ShowView(UIViewID.GoldSauserOpportunityPanel, Params)
end

--- @type 出现公用提示
function GoldSauserMgr:ShowStyleCommWin(
    View,
    Title,
    Content,
    ConfirmCallBack,
    CancelCallBack,
    ConfirmParams,
    CancelParams,
    InTextYes,
    InTextNo)
    local Params = {
        View = View,
        Title = Title,
        Content = Content,
        ConfirmCallBack = ConfirmCallBack,
        CancelCallBack = CancelCallBack,
        ConfirmParams = ConfirmParams,
        CancelParams = CancelParams,
        TextYes = InTextYes,
        TextNo = InTextNo
    }
    UIViewMgr:ShowView(UIViewID.PlayStyleCommWin, Params)
end

--- @type 与相关的Npc交互
function GoldSauserMgr:InteractWithReleNpcs(NpcResID, NpcEntityID)
    local RelatedNpcID = GoldSauserDefine.RelatedNpcID
    local Mathc1 = NpcResID == RelatedNpcID.EventNarrator1
    local Match2 = NpcResID == RelatedNpcID.EventNarrator2
    local Match3 = NpcResID == RelatedNpcID.EventNarrator3
    if Mathc1 or Match2 or Match3 then
        self:InteractWithEventNarrator() -- 与三个活动解说员交互
    else
        self:InteractWithCreateNpc(NpcResID, NpcEntityID) -- 与创建出来的Npc交互
    end
end

--- @type 与活动解说员对话
function GoldSauserMgr:InteractWithEventNarrator()
    local NarratorDialogLib = GoldSauserDefine.NarratorDialogLib
    local DialogID = NarratorDialogLib.OutOfActivity

    if (self:GetIsInActivePeriod()) then
        DialogID = NarratorDialogLib.DuringInActivity
    end

    NpcDialogMgr:PlayDialogLib(DialogID, nil, false, self.TryOpenMsg)
end

--- @type 与生成的进入活动的Npc对话
function GoldSauserMgr:InteractWithCreateNpc(NpcResID, NpcEntityID)
    local Entertain = self.Entertain
    local CurGameClass = self.CurGameClass
    if Entertain == nil or CurGameClass == nil then
        return
    end

    local DialogLibID = CurGameClass:GetDialogLib(self)

    local DialogCallBack = CurGameClass:GetDialogCallBack(self, DialogLibID)
    NpcDialogMgr:PlayDialogLib(DialogLibID, NpcEntityID, false, DialogCallBack)
end

--- @type 展示挑战提示
function GoldSauserMgr:ShowChallengeTip(Content, ConfirmCallBack, InTitleText, InTextYes, InTextNo)
    -- 判断一下当前的状态，如果不是报名状态，那么不显示
    if (self.Player ~= nil and self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_End) then
        return
    end

    if (self.Entertain == nil or self.Entertain.State == nil) then
        return
    end

    if self.Entertain.State ~= GoldSauserEntertainState.GoldSauserEntertainState_SignUp then
        return
    end

    local Title = InTitleText or LSTR(10032)
    GoldSauserMgr:ShowStyleCommWin(GoldSauserMgr, Title, Content, ConfirmCallBack, nil, nil, nil, InTextYes, InTextNo)
end

--- @type 出现加载界面
function GoldSauserMgr:ShowLoadingPanel(bAirForceBgVisible)
    local Params = {}
    Params.bAirForceBgVisible = bAirForceBgVisible
    UIViewMgr:ShowView(UIViewID.PlayStyleLoadingPanel, Params)
end

--- @type 通过下一期举行的活动获取系统给予的时间提示(实则走的是Npc对话那一套)nex
function GoldSauserMgr:GetNextActivityTime()
    local NeedMin = 0
    local CurMin = tonumber(TimeUtil.GetServerTimeFormat("%M"))
    local CurHour = tonumber(TimeUtil.GetServerTimeFormat("%H"))
    if CurMin >= 0 and CurMin < 20 then
        NeedMin = "20"
    elseif CurMin >= 20 and CurMin < 40 then
        NeedMin = "40"
    elseif CurMin >= 40 and CurMin < 60 then
        NeedMin = "00"
        CurHour = CurHour + 1
        if (CurHour >= 24) then
            CurHour = "00"
        end
    end
    FLOG_INFO("Server Time Hour is %s, Server Time Min is %s", CurHour, CurMin)
    local ShowStr = string.format("%s:%s", CurHour, NeedMin)
    --local FinalStr = LocalizationUtil.GetTimeForFixedFormat(ShowStr, not CommonDefine.bChsVersion)
    return ShowStr
end

function GoldSauserMgr:ShowOpportunityNewTutorial()
    local function ShowGoldSauserCommTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.UnlockGameplay
        --新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.JiYuLingMen
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {
        Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
        Callback = ShowGoldSauserCommTutorial,
        Params = {}
    }
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--- @type 当进入了小雏鸟的区域
function GoldSauserMgr:OnEnterAreaTrigger(Params)
    -- 小雏鸟的范围
    if Params.AreaID == RescueChickenTriggerIDOne or Params.AreaID == RescueChickenTriggerIDTwo then
        self.EnterRescueChickenArea = true
    end

    if (self.Entertain ~= nil and self.Entertain.ID == EntertainGameID.GameIDCliffhanger) then
        if (self.CurGameClass ~= nil) then
            self.CurGameClass:JudgeForNeedCheckHeight()
        end
    end
end

function GoldSauserMgr:OnLeaveAreaTrigger(Params)
    -- 小雏鸟的范围
    if Params.AreaID == RescueChickenTriggerIDOne or Params.AreaID == RescueChickenTriggerIDTwo then
        self.EnterRescueChickenArea = false
    end
end

-- 当前玩家是否处于活动期间，游戏处于进行时，玩家处于游玩状态则算处于活动期间，其他的都不属于活动期间
function GoldSauserMgr:GetIsInActivePeriod()
    if (self.Entertain == nil) then
        return false
    end

    local StateValue = self.Entertain.State
    local CurPlayerState = self.Player

    local bEnd = StateValue == GoldSauserEntertainState.GoldSauserEntertainState_End
    local bEarlyEnd = StateValue == GoldSauserEntertainState.GoldSauserEntertainState_EarlyEnd
    local bPlayerEnd = CurPlayerState == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_End

    if (bEnd or bEarlyEnd or bPlayerEnd) then
        return false
    end

    local bInProgress = StateValue == GoldSauserEntertainState.GoldSauserEntertainState_InProgress
    local bInSignUp = StateValue == GoldSauserEntertainState.GoldSauserEntertainState_SignUp

    if (bInProgress or bInSignUp) then
        return true
    end

    return false
end

-- 玩家是否正在参加机遇临门游戏
function GoldSauserMgr:IsPlayerJoinGoldSauserOpportunityGame()
    local CurPlayerState = self.Player
    local bInSignUp = CurPlayerState == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp

    return bInSignUp
end

--- @type 获取下一个活动的发生的地点
function GoldSauserMgr:GetNextActivityLoc()
    local NeedID
    if self:GetIsInActivePeriod() then
        NeedID = self.Entertain.ID
    else
        NeedID = self.NextID
    end
    return self:GetGameZoneByID(NeedID)
end

--- @type 获取活动名称
function GoldSauserMgr:GetNextActivityName(InbForceNext)
    if (self.Entertain == nil or self.NextID == nil) then
        return ""
    end

    local NeedID = nil

    if (self:GetIsInActivePeriod()) then
        NeedID = self.Entertain.ID
    else
        NeedID = self.NextID
    end

    local Cfg = self:GetCachedData(NeedID)
    if Cfg == nil then
        FLOG_ERROR("获取 GoldSauserGateCfg:FindCfgByKey 失败，查找的ID是：%s", NeedID)
        return ""
    end
    return Cfg.GameName
end

--- @type 获取报名倒计时MS
function GoldSauserMgr:GetRemainSignUpTime()
    local SignUpEndTime = self.SignUpEndTime
    
    local CurTime = TimeUtil.GetServerLogicTimeMS()
    if (SignUpEndTime == nil or SignUpEndTime == 0) then
        SignUpEndTime = CurTime
    end
    return SignUpEndTime - CurTime
end

------------------------------------------------------End-----------------------------------------------------------

--------------------------------------更新游戏状态，任务图标，地图图标，创建Npc等--------------------------------------
--- @type 根据游戏进行到什么阶段来更新NPC，以及地图Icon等
-- bShowMsg bool 是否发送通知
function GoldSauserMgr:UpdateGameByState(bShowMsg)
    if (self.Entertain == nil) then
        _G.FLOG_ERROR("错误，当前的 self.Entertain 为空，请检查")
        return
    end

    local GameState = self.Entertain.State

    if GameState == GoldSauserEntertainState.GoldSauserEntertainState_SignUp then
        _G.BuoyMgr:SetGoldGameNPCFollowState(true) -- 仙人刺的指引状态重置一下
        self:LoadCurGameSignUpNpc()
        self.CurGameClass:GameStateToSignUp(self, self.GoldSauserVM)
        if (self.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_NotSignUp) then
            self:ShowWindowTips(MsgTipsID.GoldSauser_Windows) -- 开始的时候一定要要通知一下
        end
    elseif GameState == GoldSauserEntertainState.GoldSauserEntertainState_InProgress then
        self:LoadCurGameSignUpNpc()
        self.CurGameClass:GameStateToInProgress(self, self.GoldSauserVM)

        if (bShowMsg) then
            local TipID = 0
            local bIsWindBlow = self.Entertain.ID == EntertainGameID.GameIDAnyWayWindBlows
            local bIsSlice = self.Entertain.ID == EntertainGameID.GameIDSliceIsRight
            if bIsWindBlow or bIsSlice then
                TipID = MsgTipsID.GoldSauser_Stage_SignUpEnd
            else
                TipID = MsgTipsID.GoldSauser_Other_SignUpEnd
            end
            self:ShowWindowTips(TipID)
        end
    else
        -- 游戏结束，清理一下
        self.bHasPlayerSignUp = false
        self.CurGameClass:GameStateToEnd(self, self.GoldSauserVM)
        local bEarlyEnd = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_EarlyEnd
        if (bShowMsg and not bEarlyEnd) then
            self:ShowWindowTips(MsgTipsID.GoldSauser_ActivityEnd)
        end

        self:DestroyCurGameSignUpNpc()
        self.SignupNpcEntityID = 0
        self:InternalSetChickenEntityID(0)
    end

    EventMgr:SendEvent(EventID.GoldSauserStateUpdate)
end

function GoldSauserMgr:SetSignUpNpcEntityID(InEntityID)
    self.SignupNpcEntityID = InEntityID
    if (self.SignupNpcEntityID == nil or self.SignupNpcEntityID == 0) then
        self:RefreshGameNpcIconState(true)
    else
        self:RefreshGameNpcIconState()
    end
end

--- 机遇临门游戏结束的时候，回收NPC
function GoldSauserMgr:DestroyCurGameSignUpNpc()
    if self.SignupNpcEntityID ~= nil and self.SignupNpcEntityID > 0 then
        ClientVisionMgr:DestoryClientActor(self.SignupNpcEntityID, EActorType.Npc)
        self:SetSignUpNpcEntityID(0)
    end

    -- 这里是双重保险，避免没有正确删除目标
    local CurGameNpc = self:GetCurGameNpc()
    if (CurGameNpc ~= nil) then
        local TargetActor = ActorUtil.GetActorByTypeAndListID(EActorType.Npc, CurGameNpc.ListId)
        if (TargetActor ~= nil) then
            local AttrComp = TargetActor:GetAttributeComponent()
            if (AttrComp ~= nil) then
                ClientVisionMgr:DestoryClientActor(AttrComp.EntityID, EActorType.Npc)
            end
        end
    end
end

--- @type 打开飘窗，拼接Content内容。 展示与NPC谈话内容
function GoldSauserMgr:ShowWindowTips(InTipsID)
    -- 这里在空军里面不显示 TIPS
    local BaseInfo = PWorldMgr.BaseInfo
    if table.contain(AirForceMapResIDList, BaseInfo.CurrMapResID) then -- 空军副本不显示广播
        return
    end

    if (_G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then -- 虚景跳跳乐也不显示
        return
    end

    if _G.GoldSauserMainPanelMgr:BlockByMiniGameInPanel() then -- 金碟手册界面存在小游戏不显示此飘窗tips
        return
    end

    local bViewVisible = UIViewMgr:IsViewVisible(UIViewID.GoldSauserOpportunityPanel)
    if (bViewVisible) then
        self:RegisterTimer(
            function()
                MsgTipsUtil.ShowTipsByID(InTipsID)
            end,
            2.5,
            0,
            1
        )
    else
        if (self.bRequireReward) then
            self:RegisterTimer(
                function()
                    self:ShowWindowTips(InTipsID)
                end,
                1,
                0,
                1
            )
        else
            local RemainTime = self:GetRemainSignUpTime()
            if (RemainTime <= 1000 and RemainTime >= -1000) then
                self:RegisterTimer(
                    function()
                        MsgTipsUtil.ShowTipsByID(InTipsID)
                    end,
                    3 + RemainTime,
                    0,
                    1
                )
            else
                MsgTipsUtil.ShowTipsByID(InTipsID)
            end
        end
    end
end

--- @type 设置NpcEntityID和地图图标
function GoldSauserMgr:LoadCurGameSignUpNpc()
    if (self.Entertain == nil) then
        FLOG_ERROR("GoldSauserMgr:LoadCurGameSignUpNpc() 出错 , self.Entertain == nil")
        return
    end

    -- 加载过就不重复加载了，只更新下状态
    if (self.SignupNpcEntityID ~= nil or self.SignupNpcEntityID > 0) then
        local TargetActor = ActorUtil.GetActorByEntityID(self.SignupNpcEntityID)
        if (TargetActor ~= nil) then
            self:SetSignUpNpcEntityID(self.SignupNpcEntityID)
            return
        end

        self.SignupNpcEntityID = 0
        _G.FLOG_INFO("注意，状态发生改变时，记录了NPC的ENTITYID，但是无法获取到，请检查")
    end

    local MapEditListID = self:GetCurGameSignupNpcMapListID()
    local NpcData = MapEditDataMgr:GetNpcByListID(MapEditListID)
    if (NpcData == nil) then
        _G.FLOG_WARNING("错误，无法加载NpcData,MapEditListID 是：%s，尝试加载新的NPCDATA", MapEditListID)
        NpcData = ClientVisionMgr:GetEditorDataByEditorID(MapEditListID, MapEditorActorConfig.Npc)
    end

    local TempEntityID = ClientVisionMgr:DoClientActorEnterVision(MapEditListID, NpcData, MapEditorActorConfig.Npc)
    if (TempEntityID == nil or TempEntityID == 0) then
        TempEntityID = 0
        _G.FLOG_ERROR(
            "GoldSauserMgr:LoadCurGameSignUpNpc() 错误，无法加载目标NPC, MapEditListID: %s", MapEditListID
        )
    end

    self:SetSignUpNpcEntityID(TempEntityID)
end

function GoldSauserMgr:IsCurGameSignUpNpc(InMapListID)
    if (self.Entertain == nil) then
        return false
    end

    local InbIgnoreChocobo = true
    if (not self:IsCurMapGoldSauserMap(InbIgnoreChocobo)) then
        return false
    end

    local TargetNpcMapEditID = self:GetCurGameSignupNpcMapListID()
    if (TargetNpcMapEditID == InMapListID) then
        return true
    end

    return false
end

--- @type 是否需要创建相关活动的Npc
function GoldSauserMgr:CanCreateGoldSauserNpc(MapListID)
    if (self.Entertain == nil) then
        return false
    end

    local bGameEnd = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_End
    local bGameEarlyEnd = self.Entertain.State == GoldSauserEntertainState.GoldSauserEntertainState_EarlyEnd
    if (bGameEnd or bGameEarlyEnd) then
        return false
    end

    local TargetNpcMapEditID = self:GetCurGameSignupNpcMapListID()
    if (TargetNpcMapEditID == MapListID) then
        return true
    end

    return false
end

function GoldSauserMgr:GetCurGameSignupNpcMapListID()
    if (self.Entertain == nil) then
        return 0
    end
    local EntertainType = self.Entertain.ID
    if EntertainType == EntertainGameID.GameIDCliffhanger then
        local TableData = self:GetCachedCliffHangerCfg()
        if (TableData == nil) then
            return 0
        end
        return TableData.NpcID
    end

    local Cfg = self:GetCachedData(EntertainType)
    if nil == Cfg then
        _G.FLOG_ERROR("无法获取数据，游戏ID是：" .. tostring(EntertainType))
        return
    end
    return Cfg.SignUpNpcListID
end

--- 获取缓存下的表格 GoldSauserGateCfg
---@param ID any
function GoldSauserMgr:GetCachedData(ID)
    if (ID == nil or ID <= 0) then
        _G.FLOG_ERROR("GoldSauserMgr:GetCachedData 出错了，传入的 ID 为空，请检查")
        return nil
    end
    if (self.CacheTableData == nil) then
        self.CacheTableData = {}
    end
    local CfgData = self.CacheTableData[ID]
    if (CfgData == nil) then
        CfgData = GoldSauserGateCfg:FindCfgByKey(ID)
        self.CacheTableData[ID] = CfgData
    end
    if (CfgData == nil) then
        FLOG_ERROR("GoldSauserGateCfg:FindCfgByKey 错误，ID是 : " .. ID)
    end
    return CfgData
end

function GoldSauserMgr:GetGameNameByID(ID)
    local Cfg = self:GetCachedData(ID)
    if nil == Cfg then
        return
    end

    return Cfg.GameName
end

--- 获取当前机遇临门的名字
function GoldSauserMgr:GetCurGameName()
    if (self.Entertain == nil) then
        return ""
    end

    return self:GetGameNameByID(self.Entertain.ID)
end

function GoldSauserMgr:GetGameZoneByID(ID)
    -- 小雏鸟特殊处理
    if ID == nil then
        return ""
    end

    if ID == EntertainGameID.GameIDCliffhanger then
        local TableData = self:GetCachedCliffHangerCfg()
        if (TableData == nil) then
            return ""
        end
        return TableData.RescueChickenZone
    end

    local Cfg = self:GetCachedData(ID)
    if nil == Cfg then
        return ""
    end

    return Cfg.Zone
end

--- 获取缓存的小雏鸟表格数据
function GoldSauserMgr:GetCachedCliffHangerCfg()
    local Key = self:GoldRescueChickGetStage() or 1
    if (self.CliffHangerCfgCache == nil) then
        self.CliffHangerCfgCache = {}
    end
    local TableData = self.CliffHangerCfgCache[Key]
    if nil == TableData then
        TableData = CliffHangerCfg:FindCfgByKey(Key)
        self.CliffHangerCfgCache[Key] = TableData
    end
    if nil == TableData then
        FLOG_ERROR("CliffHangerCfg:FindCfgByKey 获取失败，ID 是：" .. Key)
        return nil
    end
    return TableData
end

--- @type 返回Npc头顶的Icon
function GoldSauserMgr:GetNPCHudIcon(InEntityID)
    if (self.SignupNpcEntityID > 0 and InEntityID == self.SignupNpcEntityID) then
        if (self.MarkerForSignupNpc.bShow == false) then
            return nil
        end
        return self.MarkerForSignupNpc.IconPath
    elseif (self.ChickenEntityID > 0 and InEntityID == self.ChickenEntityID) then
        if (self.MarkerForChecken.bShow == false) then
            return nil
        end
        return self.MarkerForChecken.IconPath
    end

    return nil
end

--- @type 设置收起或者展开游戏信息面板
function GoldSauserMgr:SetToggleInfoPanel(InbVisible)
    if (InbVisible) then
        local bAirForce = self.Entertain.ID == EntertainGameID.GameIDAirForceOne
        if (bAirForce) then
            -- 空军不显示
            MainPanelVM:SetPlayStyleInfoVisible(false)
        else
            if (self:IsCurMapGoldSauserMap() or _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
                MainPanelVM:SetFunctionVisible(true, MainPanelConfig.TopRightInfoType.PlayStyleInfo)
                MainPanelVM:SetPlayStyleInfoVisible(true)
            else
                MainPanelVM:SetPlayStyleInfoVisible(false)
            end
        end

    else
        MainPanelVM:SetPlayStyleInfoVisible(false)
    end
end

---------------------------------------------------End-----------------------------------------------

function GoldSauserMgr:UpdateRewardListVM(InList)
    if (InList == nil) then
        _G.FLOG_ERROR("GoldSauserMgr:UpdateRewardListVM 出错，传入的List为空，请检查")
        return
    end

    for Key,Value in pairs(InList) do
        -- 这里检测一下， 看是不是有金碟币
        if (Value.ID == JDCoinResID or Value.ResID == JDCoinResID) then
            -- 这里去看下是否有BUFF显示
            local Table = BuffUtil.GetBuffBonusStateValueByScoreID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
            if (Table ~= nil) then
                local PercentValue = Table[ProtoRes.BonusStateEffectSubType.STATE_EFFECT_SUB_TYPE_WAN_RATE]
                if (PercentValue ~= nil and PercentValue > 0) then
                    PercentValue = 1 + PercentValue * 0.0001
                    Value.OriginalNum = math.ceil(Value.Num / PercentValue)
                    Value.IncrementedNum = Value.Num
                    if (Value.IncrementedNum < 0) then
                        Value.IncrementedNum = 0
                    end
                    Value.PlayAddEffect = true
                end
            end
        end
    end

    if (self.GoldSauserVM == nil) then
        self.GoldSauserVM = GoldSauserVM.New()
    end
    -- 因为对于货币需要特殊修改
    self.GoldSauserVM.RewardListVMList:UpdateByValues(InList)

    return self.GoldSauserVM.RewardListVMList
end

function GoldSauserMgr:ShowJDExchangeTip(View)
    local Cfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_GOLD_SAUCER_QUICK_EXANGE)
    if Cfg == nil then
        return
    end
    local Content = string.format(LSTR(1270029), Cfg.Value[2], Cfg.Value[3]) -- 是否消耗%s金币替换%s金碟币

    self:ShowStyleCommWin(self, LSTR(1270030), Content, self.SendExchangeJDCoin, nil, nil, nil) -- 购买提示
end

--- 与Npc兑换员交互
function GoldSauserMgr:OnExchangeJDCoinInteractive(ResID, InteractivedescCfg, FuncID)
    local InteractiveDialogID = GoldSauserDefine.InteractiveDialogID

    local function ExchangeJDCoin()
        --- 金碟币是否符合 <= n
        local JDCoinResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
        local ScoreValue = _G.ScoreMgr:GetScoreValueByID(JDCoinResID)
        local JDCoinCfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_GOLD_SAUCER_QUICK_EXANGE)
        if JDCoinCfg ~= nil then
            if tonumber(ScoreValue) < tonumber(JDCoinCfg.Value[3]) then
                GoldSauserMgr:ShowJDExchangeTip()
            else
                NpcDialogMgr:PlayDialogLib(InteractiveDialogID.ExchangeJDCoinFail, nil, false)
            end
        end
    end

    NpcDialogMgr:PlayDialogLib(InteractiveDialogID.ExchangeJDCoin, nil, false, ExchangeJDCoin)
end

return GoldSauserMgr
