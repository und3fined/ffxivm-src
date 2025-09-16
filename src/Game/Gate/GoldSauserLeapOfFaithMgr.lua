--
-- Author: michaelyang_lightpaw
-- Date: 2024-11-01
-- Description: 虚景跳跳乐管理
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
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local EObjCfg = require("TableCfg/EobjCfg")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local LeapOfFaithMapconfigCfg = require("TableCfg/LeapOfFaithMapconfigCfg")
local LeapOfFaithCactusCfg = require("TableCfg/LeapOfFaithCactusCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local LeapOfFaithEndActionCfg = require("TableCfg/LeapOfFaithEndActionCfg")
local CommonUtil = require("Utils/CommonUtil")
local EffectUtil = require("Utils/EffectUtil")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local MsgTipsID = require("Define/MsgTipsID")
local MainControlPanelVM = require("Game/Main/VM/MainControlPanelVM")
local SettingsTabRole = require("Game/Settings/SettingsTabRole")
local MsgBoxUtil = require("Utils/MsgBoxUtil")

local UActorManager = nil
local HUDMgr = nil
local GoldSauserEntertainState = ProtoCS.GoldSauserEntertainState
local ActorUtil = nil

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_GOLD_SAUSER_CMD
local GLOBAL_CFG_ID = ProtoRes.Game.game_global_cfg_id
local LSTR = _G.LSTR
local UE = _G.UE
local GamePlayTime = 600000 -- 游戏时长，单位秒，这里直接 * 1000 变成服务器通用的MS

local CactusFadeState = 8
local CactusShowState = 2
local EndPointShowState = 1
local EndPointHideState = 2
local EndPointFlashState = 4

local ShortCutDefaultState = 1
local ShortCutFlashState = 16

local FLOG_INFO = _G.FLOG_INFO
local EndingCameraConfigID = 11001

-- 仙人刺的Eobj，动态创建
local CactusEobjIDTable = {
    2009588, -- 金
    2009589, -- 银
    2009590 -- 铜
}

---@class GoldSauserLeapOfFaithMgr : MgrBase
local GoldSauserLeapOfFaithMgr = LuaClass(MgrBase)

function GoldSauserLeapOfFaithMgr:OnInit()
    UActorManager = _G.UE.UActorManager.Get()
    HUDMgr = _G.HUDMgr
    self:ResetData()
    ActorUtil = require("Utils/ActorUtil")
end

function GoldSauserLeapOfFaithMgr:ResetData()
    self:OnResetAllEObj()

    self.PlayerState = nil
    self.bInGame = false -- 是否在游戏中
    self.bReachEndPoint = false -- 是否已经到达终点
    self.bAlreadySendEnd = false -- 是否已经发送结束
    self.bLeaveWorld = false

    self.CurMapCactusAreaIDList = {} -- 当前地图所有的仙人刺AREAID
    self.PlayerHitCactusAreaIDList = {} -- 玩家已经触碰的仙人刺区域
    self.CurMapNotHitCactusDataList = {} -- 当前地图还在场上的仙人刺

    self.PlayerHitCheckPointList = {} -- 已经触碰的检查点 ListID
    self.ActiveShortCutListID = {} -- 已经激活的捷径，可以是 AreaID， value是{} , EObjListID EntityID

    self.SceneID = 0 -- 服务器随机的SceneID
    self.GoldCount = 0 -- 获得的金牌数量
    self.SilverCount = 0 -- 获得的银牌数量
    self.BronzeCount = 0 -- 获得的铜牌数量
    self.GoldMaxNum = 1 -- 可以获得的金牌总数
    self.SilverMaxNum = 2 -- 可以获得的银牌总数
    self.BronzeMaxNum = 3 -- 可以获得的铜牌总数

    self.GoldCoin = 300 -- 金牌奖励分数
    self.SilverCoin = 200 -- 银牌奖励分数
    self.BronzeCoin = 100 -- 铜牌奖励分数
    self.ReachEndRewardCoin = 1000 -- 到达终点的奖励
    self.NoReachEndRewardCoin = 200 -- 没有到达终点的奖励

    self.EndPoiontEActorEntityID = 0 -- 终点的EobjEntityID

    self.TargetMapResIDTable = {} -- 地图ID，通过遍历表格获取

    self.RoundData = nil -- 服务器下发的游戏轮次相关数据

    self.MainEntertainState = nil --  金碟游乐场主状态
    self.MainRound = nil -- 金碟游乐场主 Round
    self.NeedLeaveScene = false -- 是否需要离开场景，在WorldReady之后

    local AllDataList = LeapOfFaithMapconfigCfg:FindAllCfg()
    for Key, Value in pairs(AllDataList) do
        self.TargetMapResIDTable[Value.SceneID] = 1
    end

    -- 获取游戏时间
    do
        local TempKey = GLOBAL_CFG_ID.GAME_CFG_GATE_LEAP_OF_FAITH_MAX_PLAY_TIME_SECOND
        local TableData = GameGlobalCfg:FindCfgByKey(TempKey)
        if (TableData ~= nil) then
            GamePlayTime = TableData.Value[1] * 1000
        else
            _G.FLOG_ERROR("GameGlobalCfg:FindCfgByKey 出错，无法找到 ID : " .. tostring(TempKey))
        end
    end

    -- 虚景跳跳乐奖励相关
    do
        local Key = GLOBAL_CFG_ID.GAME_CFG_LEAP_OF_FAITH_AWARD
        local _tableData = GameGlobalCfg:FindCfgByKey(Key)
        if (_tableData == nil) then
            _G.FLOG_ERROR("GameGlobalCfg:FindCfgByKey 出错，无法找到 ID ：%s", tostring(Key))
        else
            self.GoldCoin = _tableData.Value[1] -- 金牌奖励分数
            self.SilverCoin = _tableData.Value[2] -- 银牌奖励分数
            self.BronzeCoin = _tableData.Value[3] -- 铜牌奖励分数
            self.ReachEndRewardCoin = _tableData.Value[4] -- 到达终点的奖励
            self.NoReachEndRewardCoin = _tableData.Value[5] -- 没有到达终点的奖励
        end
    end

    -- 获取结算摄像机 ConfigID
    do
        local TableData =
            ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_LEAPOFFAITH_ENDCAMERACONFIGID)

        if (TableData ~= nil) then
            EndingCameraConfigID = tonumber(TableData.Value[1])
        end
    end
end

-- 清理所有的EObj数据
function GoldSauserLeapOfFaithMgr:OnResetAllEObj()
    if (self.CurMapNotHitCactusDataList ~= nil and #self.CurMapNotHitCactusDataList > 0) then
        -- 这里清理掉所有的仙人掌
        for Key, Value in pairs(self.CurMapNotHitCactusDataList) do
            _G.ClientVisionMgr:ClientActorLeaveVision(Key, _G.UE.EActorType.EObj)
        end
    end
end

function GoldSauserLeapOfFaithMgr:OnBegin()
end

function GoldSauserLeapOfFaithMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_GOLD_SAUSER,
        SUB_MSG_ID.CS_GOLD_SAUSER_CMD_LEAP_OF_FAITH_INFO,
        self.OnUpdateGameInfoRsp
    )

    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_GOLD_SAUSER,
        SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATE_NOTIFY,
        self.OnGameInfoNotify
    )

    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_GOLD_SAUSER,
        SUB_MSG_ID.CS_GOLD_SAUSER_CMD_UPDATE,
        self.OnUpdateGoldSauserGameInfo
    )

    self:RegisterGameNetMsg(
        ProtoCS.CS_CMD.CS_CMD_INTERAVIVE,
        ProtoCS.CsInteractionCMD.CsInteractionCMDEnd,
        self.OnInteractionEndRsp
    )
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER, SUB_MSG_ID.CS_GOLD_SAUSER_CMD_END, self.OnNetEndGame)
end

function GoldSauserLeapOfFaithMgr:OnInteractionEndRsp()
    if (not self:IsCurMapLeapOfFaith()) then
        return
    end

    if (not self.bInGame) then
        return
    end

    if (self.SceneTableData == nil) then
        return
    end

    local InteractiveEntityID = _G.InteractiveMgr.CurInteractEntityID

    for Key, Value in pairs(self.SceneTableData.CheckPointAndShortCuts) do
        local Actor = ActorUtil.GetActorByTypeAndListID(_G.UE.EActorType.EObj, Value.CheckPointEobjID)
        if (Actor ~= nil) then
            local AttriComp = Actor:GetAttributeComponent()
            if (AttriComp ~= nil) then
                if (AttriComp.EntityID == InteractiveEntityID) then
                    self:OnTriggerCheckPoint(AttriComp.ListID)
                end
            end
        else
            _G.FLOG_ERROR("无法获取Actor , ListID 是 : %s", tostring(Value.CheckPointEobjID))
        end
    end
end

-- 处理所有非对局玩家的显示
function GoldSauserLeapOfFaithMgr:SetOthersVisibility(bVisible)
    -- 隐藏其它玩家技能特效
    EffectUtil.SetIsInMiniGame(not bVisible)
    self:HideAllCompanions(not bVisible)
    -- 寻路指引线
    _G.NaviDecalMgr:SetNavPathHiddenInGame(not bVisible)
    _G.NaviDecalMgr:DisableTick(not bVisible)

    if bVisible then
        UActorManager:HideAllActors(false, _G.UE.TArray(_G.UE.uint64), _G.UE.TArray(_G.UE.uint8))
        HUDMgr:ShowAllActors()
        HUDMgr:ShowAllNpc()
        self:SetMajorCanMove(true)
    else
        local ExcludeArray = _G.UE.TArray(_G.UE.uint64)
        ExcludeArray:Add(MajorUtil.GetMajorEntityID())
        UActorManager:HideAllActors(true, ExcludeArray, _G.UE.TArray(_G.UE.uint8))
        HUDMgr:HideAllActors()
    end
end

function GoldSauserLeapOfFaithMgr:SetMajorCanMove(bCanMove)
    local StateComponent = MajorUtil.GetMajorStateComponent()
    if StateComponent ~= nil then
        --有tag，先判断状态是否一样
        local State = StateComponent:GetActorControlState(_G.UE.EActorControllStat.CanMove)
        if State == bCanMove then
            return
        end

        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, bCanMove, "GoldSauserLeapOfFaithMgr")
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanAllowMove, bCanMove, "GoldSauserLeapOfFaithMgr")
    end
end

---@type 隐藏所有宠物
function GoldSauserLeapOfFaithMgr:HideAllCompanions(IsHide)
    local Companions = _G.UE.UActorManager.Get():GetAllCompanions()
    for _, Companion in pairs(Companions) do
        Companion:SetActorHiddenInGame(IsHide)
    end
end

-- 金碟游戏总的数据更新了
function GoldSauserLeapOfFaithMgr:OnUpdateGoldSauserGameInfo(MsgBody)
    if (not self:IsCurMapLeapOfFaith()) then
        return
    end

    if (nil == MsgBody or MsgBody.Update == nil) then
        _G.FLOG_ERROR("GoldSauserMgr:OnUpdateGoldSauserGameInfo 错误，msg 为空，请检查")
        return
    end

    local Data = MsgBody.Update
    if (Data == nil) then
        _G.FLOG_ERROR("错误，金碟游戏的主数据为空，将重新请求数据")
        self:OnReconnect()
        return
    end

    self.MainGameData = Data
    self.MainEntertainState = Data.Entertain
    self.MainRound = Data.Round
    self.PlayerState = Data.Player

    if (Data.RewardRecord ~= nil and Data.RewardRecord.FinishTime > 0) then
        -- 这里显示奖励
        local ServerTimeNow = TimeUtil.GetServerLogicTimeMS()
        local TimeSpan = ServerTimeNow - Data.RewardRecord.FinishTime * 1000
        if (TimeSpan < _G.GoldSauserMgr.RewardShowTimeLimit) then
            -- 这里去显示奖励，就不管了，也不需要发送请求，奖励数据是会
            return
        end
    end

    local bGameA = self.MainEntertainState.ID == ProtoRes.Game.GameID.GameIDLeapOfFaithA
    local bGameB = self.MainEntertainState.ID == ProtoRes.Game.GameID.GameIDLeapOfFaithB

    if (not bGameA and not bGameB) then
        _G.FLOG_ERROR("1 游戏已经不是跳跳乐了，返回")
        self:LeaveWorld()
        return
    end

    local bPlayerNotSignup = Data.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_NotSignUp
    if (bPlayerNotSignup) then
        _G.FLOG_ERROR("GoldSauserLeapOfFaithMgr:OnUpdateGoldSauserGameInfo 玩家没有报名，将返回")
        self:LeaveWorld()
        return
    end

    local bPlayerEnd = Data.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_End
    if (bPlayerEnd) then
        _G.FLOG_INFO("GoldSauserLeapOfFaithMgr:OnUpdateGoldSauserGameInfo 玩家状态已结束，将返回")
        self:LeaveWorld()
        return
    end

    self:SendGetGameInfo()
end

function GoldSauserLeapOfFaithMgr:LeaveWorld()
    if (self.bLeaveWorld) then
        return
    end

    self:SetOthersVisibility(true)
    self.bInGame = false
    self.bAlreadySendEnd = false
    self.bLeaveWorld = true
    _G.PWorldMgr:SendLeavePWorld()
    _G.EventMgr:SendEvent(EventID.LeapOfFaithGameEndAndLeave)

    -- 离开跳跳乐游戏，恢复技能按钮
    MainControlPanelVM:SetBtnSwitchTips(0)
    MainControlPanelVM.SkillSprintVisible = true
end

function GoldSauserLeapOfFaithMgr:OnGameInfoNotify(MsgBody)
end

-- return bool 是否停止后续检测
function GoldSauserLeapOfFaithMgr:CheckIsGameEnd(bNotify)
    if (self.MainGameData == nil) then
        self:OnReconnect() -- 没有金碟主场景的数据，重新请求
        return true
    end

    if (self.MainEntertainState == nil) then
        return false
    end

    if (self.RoundData == nil) then
        return false
    end

    if (self.MainGameData.RewardRecord ~= nil and self.MainGameData.RewardRecord.FinishTime > 0) then
        -- 这里显示奖励
        local ServerTimeNow = TimeUtil.GetServerLogicTimeMS()
        local TimeSpan = ServerTimeNow - self.MainGameData.RewardRecord.FinishTime * 1000
        if (TimeSpan < _G.GoldSauserMgr.RewardShowTimeLimit) then
            -- 这里去显示奖励，就不管了
            return
        end
    end

    if (self.RoundData.RoundID ~= self.MainRound) then
        -- 如果轮次不同，那么提示结束
        _G.FLOG_ERROR("服务器轮次：%s, 本地轮次 :%s", self.MainRound, self.RoundData.RoundID)
        self:LeaveWorld()
        return true
    end

    local bEnd = self.MainEntertainState.State == GoldSauserEntertainState.GoldSauserEntertainState_End
    local bEarlyEnd = self.MainEntertainState.State == GoldSauserEntertainState.GoldSauserEntertainState_EarlyEnd

    if (bEnd or bEarlyEnd) then
        local bPlayerSignup = _G.GoldSauserMgr.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp
        if (bPlayerSignup) then
            -- 如果玩家还是报名状态，那么结束一下
            self:SendEndGameReq()
        else
            _G.FLOG_ERROR("玩家状态不是报名状态，将直接结束")
            if (bNotify) then
                local DelayTime = 2
                -- 如果是下发的，那么弹出一个提示，延迟后再离开副本
                _G.FLOG_ERROR("测试，收到服务器通知，虚景跳跳乐挑战已经结束，将在2秒后回到金蝶游乐场")
                self:RegisterTimer(
                    function()
                        -- 提示一下，结束了
                        _G.FLOG_WARNING("服务器下发更新通知，游戏结束了，只能返回")
                        self:LeaveWorld()
                    end,
                    DelayTime,
                    0,
                    1
                )
            else
                -- 提示一下，结束了
                _G.FLOG_WARNING("服务器状态是游戏结束，将返回")
                self:LeaveWorld()
            end
        end

        return true
    end

    --  如果是通知下来的，玩家状态改变了，那么不检测
    if (bNotify == false) then
        local bPlayerSignup = _G.GoldSauserMgr.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp
        if (not bPlayerSignup) then
            _G.FLOG_WARNING("玩家已经游玩结束，将返回金碟游乐场")
            self:LeaveWorld()
            return true
        end
    end

    return false
end

function GoldSauserLeapOfFaithMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnWorldMapEnter)
    self:RegisterGameEvent(EventID.WorldPreLoad, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnPWorldMapExit)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnEnterAreaTrigger)
    self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(EventID.ShowUI, self.OnUIShow)
end

function GoldSauserLeapOfFaithMgr:OnUIShow(InViewID)
    if (InViewID == nil) then
        return
    end

    if (InViewID == UIViewID.MainPanel and self.bInGame) then
        -- 进入跳跳乐游戏，屏蔽切换按钮
        MainControlPanelVM:SetBtnSwitchTips(MsgTipsID.CannotFightSkillPanel)
    --MainControlPanelVM.SkillSprintVisible = false
    end
end

-- 注意，返回值 bool 是告诉外面是否停止后面的检测；是否碰到了结束区域
function GoldSauserLeapOfFaithMgr:IsTriggerShortCut(InAreaID)
    local ShortCutData = self.ActiveShortCutListID[InAreaID]
    if (ShortCutData == nil) then
        return false
    end

    local Actor = ActorUtil.GetActorByEntityID(ShortCutData.ShortCutEntityID)
    if (Actor ~= nil) then
        Actor:SetSharedGroupTimelineState(ShortCutFlashState)
    end

    local DelayTime = 0.5
    do
        UIUtil.SetInputMode_UIOnly()
        CommonUtil.HideJoyStick()
        self:SetMajorCanMove(false)
        self:PlayTransEffect()
    end

    self:RegisterTimer(
        function()
            do
                UIUtil.SetInputMode_GameAndUI()
                CommonUtil.ShowJoyStick()
                self:SetMajorCanMove(true)
            end
            -- 上报给服务器
            self:SendTriggerReport(0, InAreaID, 0)
        end,
        DelayTime,
        0,
        1
    )

    return true
end

function GoldSauserLeapOfFaithMgr:OnPWorldReady(Params)
end

function GoldSauserLeapOfFaithMgr:OnPWorldMapExit()
end

--- @type 玩家游玩状态结束
function GoldSauserLeapOfFaithMgr:OnNetEndGame(MsgBody)
end

--- @type 触发了碰撞
function GoldSauserLeapOfFaithMgr:OnEnterAreaTrigger(Params)
    if (not self:IsCurMapLeapOfFaith()) then
        return
    end

    if (not self.bInGame) then
        return
    end

    local AreaID = Params.AreaID

    -- 看是否为仙人刺
    if (self:IsTriggerCactus(AreaID)) then
        return
    end

    -- 看是否为终点
    if (self:IsTriggerEndArea(AreaID)) then
        return
    end

    if (self:IsTriggerShortCut(AreaID)) then
        return
    end
end

-- 当前交互的是不是一个跳跳乐里面的检查点
function GoldSauserLeapOfFaithMgr:IsInteractACheckPoint(Params)
    if (not self:IsCurMapLeapOfFaith()) then
        return false
    end

    if (not self.bInGame) then
        return false
    end

    if self.SceneTableData == nil then
        return
    end

    local ListID = Params.ListID
    for Key, Value in pairs(self.SceneTableData.CheckPointAndShortCuts) do
        if (Value.CheckPointEobjID == ListID) then
            -- 这里隐藏一下
            return true
        end
    end

    return false
end

function GoldSauserLeapOfFaithMgr:OnTriggerCheckPoint(ListID)
    -- 先检查一下看，是否已经触碰了
    if (self.PlayerHitCheckPointList[ListID] ~= nil) then
        return false
    end

    -- 显示捷径
    for Key, Value in pairs(self.SceneTableData.CheckPointAndShortCuts) do
        if (Value.CheckPointEobjID == ListID) then
            self.PlayerHitCheckPointList[ListID] = 1

            _G.ClientVisionMgr:ClientActorLeaveVision(ListID, _G.UE.EActorType.EObj)

            if (not self.IsReConnect) then
                local MentionCallback = function()
                    local Title = LSTR(1270012) -- 检查点解锁
                    local Type = 3
                    local InfoMsg = LSTR(1270013) -- 可通过捷径快速返回检查点
                    MsgTipsUtil.ShowInfoTextTips(Type, Title, InfoMsg, 3)
                end

                local Config = {
                    Type = ProtoRes.tip_class_type.TIP_SYS_NOTICE,
                    Callback = MentionCallback
                }
                _G.TipsQueueMgr:AddPendingShowTips(Config)
            end

            self:InternalShowShorcut(Value.ShortCutAreaID, Value.ShortCutListID)
            return true
        end
    end

    _G.FLOG_ERROR("表格里没有找到对应检查点, ID是 : %s", ListID)

    return false
end

function GoldSauserLeapOfFaithMgr:PlayTransEffect()
    local SingstateCfg = require("TableCfg/SingstateCfg")
    local EntityID = MajorUtil.GetMajorEntityID()
    local SingStateID = 40
    local SingstateDesc = SingstateCfg:FindCfgByKey(SingStateID)
    _G.SingBarMgr:DoSingDisplay(EntityID, true, SingstateDesc)
end

-- 注意，返回值 bool 是告诉外面是否停止后面的检测；是否碰到了结束区域
function GoldSauserLeapOfFaithMgr:IsTriggerEndArea(InAreaID)
    if (self.SceneTableData == nil) then
        return false
    end

    if (self.SceneTableData.EndAreaID == InAreaID) then
        -- 到达终点
        if (self.bReachEndPoint == false) then
            -- 如果没有到达过，那记录一下，后续需要修改终点的状态
            self.bReachEndPoint = true

            local MentionCallback = function()
                local Title = LSTR(1270014) -- 到达终点!
                local Type = 3
                local InfoMsg = LSTR(1270015) -- 尝试收集更多仙人刺，获得更多奖励
                MsgTipsUtil.ShowInfoTextTips(Type, Title, InfoMsg, 3)
            end

            local Config = {
                Type = ProtoRes.tip_class_type.TIP_SYS_NOTICE,
                Callback = MentionCallback
            }
            _G.TipsQueueMgr:AddPendingShowTips(Config)

            _G.PWorldMgr:LocalUpdateDynData(
                ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE,
                self.SceneTableData.EndSgbID,
                EndPointFlashState
            )

            self:OnUpdateCoin()

            self:SendTriggerReport(0, 0, InAreaID)
        end
        return true
    end

    return false
end

-- 注意，返回值 bool 是告诉外面是否停止后面的检测；是否碰到了仙人刺
function GoldSauserLeapOfFaithMgr:IsTriggerCactus(InAreaID)
    local ExistCactusData = self.CurMapNotHitCactusDataList[InAreaID]
    if (ExistCactusData == nil or ExistCactusData.Actor == nil) then
        return false
    end
    local TriggerType = ExistCactusData.Type
    if (TriggerType == nil) then
        return false
    end

    -- 是仙人刺
    local PlayerTriggerType = self.PlayerHitCactusAreaIDList[InAreaID]
    if (PlayerTriggerType ~= nil) then
        -- 已经触发过了
        return true
    end

    local CactusType = ProtoRes.Game.LeapOfFaithCactusType
    local CoinValue = 0

    self.PlayerHitCactusAreaIDList[InAreaID] = TriggerType

    if (TriggerType == CactusType.LeapOfFaithCactusTypeGold) then
        self.GoldCount = self.GoldCount + 1
        CoinValue = self.GoldCoin
    elseif (TriggerType == CactusType.LeapOfFaithCactusTypeSilver) then
        self.SilverCount = self.SilverCount + 1
        CoinValue = self.SilverCoin
    else
        self.BronzeCount = self.BronzeCount + 1
        CoinValue = self.BronzeCoin
    end

    local TypeStr = ProtoEnumAlias.GetAlias(CactusType, TriggerType)

    local TipsStr = string.format(LSTR(1270020), TypeStr, CoinValue) -- 收集了%s仙人刺，+%s金碟币
    _G.MsgTipsUtil.ShowTips(TipsStr)

    self:OnUpdateCoin()

    _G.EventMgr:SendEvent(EventID.LeapOfFaithUpdateScore, TriggerType)

    ExistCactusData.Actor:SetSharedGroupTimelineState(CactusFadeState)
    local DelayTime = 1
    self:RegisterTimer(
        function()
            _G.ClientVisionMgr:ClientActorLeaveVision(InAreaID, _G.UE.EActorType.EObj)
        end,
        DelayTime,
        0,
        1
    )

    self.CurMapNotHitCactusDataList[InAreaID] = nil

    -- 上报给服务器
    self:SendTriggerReport(InAreaID, 0, 0)

    return true
end

function GoldSauserLeapOfFaithMgr:OnUpdateCoin()
    local GoldVM = _G.GoldSauserMgr.GoldSauserVM
    local TotalCoin = self:GetTotalCoin()
    GoldVM.GoldText = string.format(LSTR(1270002), TotalCoin)
end

function GoldSauserLeapOfFaithMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params.bReconnect
    if bReconnect and self:IsCurMapLeapOfFaith() then
        self.bAlreadySendEnd = false
        self:OnReconnect()
        self.IsReConnect = true
    end
end

function GoldSauserLeapOfFaithMgr:OnReconnect()
    self:SendGetGameInfo()
    _G.GoldSauserMgr:SendUpdateGame()
    UIViewMgr:HideView(UIViewID.GateLeapOfFaithTopInfo)
    UIViewMgr:ShowView(UIViewID.GateLeapOfFaithTopInfo)
end

function GoldSauserLeapOfFaithMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    if (self.bInGame) then
        self:SendEndGameReq()
    end

    if (self:IsCurMapLeapOfFaith()) then
        self.bNeedPlayEnterAnim = true
        self:ResetData()
    end
end

-- 发送触发情况, InCactusAreaID ， InShortCutAreaID 只能选一个
function GoldSauserLeapOfFaithMgr:SendTriggerReport(InCactusAreaID, InShortCutAreaID, InEndPointAreaID)
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_REPORT_LEAP_OF_FAITH_INFO

    local MsgBody = {
        Cmd = SubMsgID,
        ReportLeapOfFaithReq = {
            CactusAreaID = InCactusAreaID,
            ShortCutAreaID = InShortCutAreaID,
            EndPointAreaID = InEndPointAreaID
        }
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GoldSauserLeapOfFaithMgr:SendEndGameReq()
    if (self.bInGame == false or self.bAlreadySendEnd) then
        return
    end

    self.bAlreadySendEnd = true

    -- 如果离开了游戏地图，那么需要结算
    _G.GoldSauserMgr:SendEndGameReq(self:GetTotalCoin(), self.bReachEndPoint)
end

-- InbCalcFailed 是否计算没有到达终点的情况下的奖励
function GoldSauserLeapOfFaithMgr:GetTotalCoin(InbCalcFailed)
    local TotalCoin = self:GetGoldCoin() + self:GetSilverCoin() + self:GetBronzeCoin()
    if (self.bReachEndPoint) then
        TotalCoin = TotalCoin + self.ReachEndRewardCoin
    elseif (InbCalcFailed) then
        TotalCoin = TotalCoin + self.NoReachEndRewardCoin
    end
    return TotalCoin
end

function GoldSauserLeapOfFaithMgr:GetGoldCoin()
    return self.GoldCount * self.GoldCoin
end

function GoldSauserLeapOfFaithMgr:GetGoldCount()
    return self.GoldCount
end

function GoldSauserLeapOfFaithMgr:GetSilverCoin()
    return self.SilverCount * self.SilverCoin
end

function GoldSauserLeapOfFaithMgr:GetSilverCount()
    return self.SilverCount
end

function GoldSauserLeapOfFaithMgr:GetBronzeCoin()
    return self.BronzeCount * self.BronzeCoin
end

function GoldSauserLeapOfFaithMgr:GetBronzeCount()
    return self.BronzeCount
end

function GoldSauserLeapOfFaithMgr:OnWorldMapEnter()
    if (not self:IsCurMapLeapOfFaith()) then
        return
    end

    if (not _G.PWorldMgr:IsReconnectInSameMap()) then
        self:OnReconnect()
        self.bNeedPlayEnterAnim = true
        _G.EventMgr:SendEvent(EventID.LeapOfFaithGameStart)
    end
end

function GoldSauserLeapOfFaithMgr:SendGetGameInfo()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_CMD_LEAP_OF_FAITH_INFO

    local MsgBody = {
        Cmd = SubMsgID
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GoldSauserLeapOfFaithMgr:OnConfirmCallBack()
    _G.GoldSauserLeapOfFaithMgr:SendEndGameReq()
end

function GoldSauserLeapOfFaithMgr:ShowLeaveConfirm()
    local Title = LSTR(1270016) -- 虚景跳跳乐大挑战
    local Content = LSTR(1270017) -- 现在退出将立刻结算已获得的奖励，退出后无法再次挑战，确定退出吗？
    _G.GoldSauserMgr:ShowStyleCommWin(
        _G.GoldSauserMgr,
        Title,
        Content,
        self.OnConfirmCallBack,
        nil,
        nil,
        nil,
        LSTR(10002),
        LSTR(10003)
    )
end

function GoldSauserLeapOfFaithMgr:ShowEndingPose()
    local Major = MajorUtil.GetMajor()
    if (Major ~= nil) then
        local EndFacing = self.SceneTableData.PlayerEndFacing
        Major:FSetRotationForServerNoInterp(_G.UE.FVector(EndFacing.X, EndFacing.Y, EndFacing.Z))
    end

    self:SetOthersVisibility(false)

    -- 这里去隐藏一下结算的特效
    _G.PWorldMgr:LocalUpdateDynData(
        ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE,
        self.SceneTableData.EndSgbID,
        EndPointHideState
    )
    local MajorAnimComponent = MajorUtil.GetMajorAnimationComponent()
    if (MajorAnimComponent ~= nil) then
        local TimelineID = 50020
        local AllCfg = LeapOfFaithEndActionCfg:FindAllCfg()
        local TotalCoin = self:GetTotalCoin()

        for Key, Value in pairs(AllCfg) do
            if (TotalCoin >= Value.RequireCoin) then
                TimelineID = Value.ActionTimelineID
            end
        end

        MajorAnimComponent:PlayActionTimeline(TimelineID, 1.0, 0.25, 0.25, true)
        _G.LuaCameraMgr:TryChangeViewByConfigID(EndingCameraConfigID)
    else
        _G.FLOG_ERROR("无法获取 MajorAnimComponent，请检查")
    end
end

function GoldSauserLeapOfFaithMgr:OnUpdateGameInfoRsp(MsgBody)
    if (MsgBody == nil) then
        _G.FLOG_ERROR("GoldSauserLeapOfFaithMgr:OnUpdateGameInfoRsp 错误，下发的数据为空")
        return
    end

    local InMsgData = MsgBody.LeapOfFaithRsp
    if (InMsgData == nil) then
        _G.FLOG_ERROR("数据出错，MsgBody.LeapOfFaithRsp 为空")
        return
    end

    if (not self:IsCurMapLeapOfFaith()) then
        _G.FLOG_WARNING("当前地图不是跳跳乐地图，将不会更新数据")
        return
    end

    self:ResetData()

    local PlayerData = InMsgData.PlayerLOF
    self.RoundData = InMsgData.RoundLOF

    self.bReachEndPoint = PlayerData.ArriveEndPoint -- 玩家是否已经到达终点了

    local GoldSauserMgr = _G.GoldSauserMgr
    local PlayerSignUpTimeStampMS = PlayerData.SignUpTimeStamp * 1000
    GoldSauserMgr.SignUpEndTime = PlayerSignUpTimeStampMS + GamePlayTime

    local CurGameClass = GoldSauserMgr.CurGameClass
    if (CurGameClass == nil) then
        _G.FLOG_ERROR("错误，无法获取金碟主数据参数，请检查")
        return
    end

    self.bInGame = true

    -- 获取当前地图信息
    local TempSearchStr = string.format("SceneID = %d", self.RoundData.SceneID)
    local TableData = LeapOfFaithMapconfigCfg:FindCfg(TempSearchStr)
    if (TableData == nil) then
        _G.FLOG_ERROR("错误 LeapOfFaithMapconfigCfg:FindCfgByKey 找不到数据，ID是: %s", self.RoundData.SceneID)
    else
        self.SceneTableData = TableData

        -- 终点显示
        _G.PWorldMgr:LocalUpdateDynData(
            ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE,
            self.SceneTableData.EndSgbID,
            EndPointShowState
        )

        self.GoldMaxNum = self.SceneTableData.GoldMaxNum
        self.SilverMaxNum = self.SceneTableData.SilverMaxNum
        self.BronzeMaxNum = self.SceneTableData.BronzeMaxNum
    end
    -- END

    do
        -- 游戏进程检测
        local CurServerTime = TimeUtil.GetServerLogicTimeMS()
        if (GoldSauserMgr.SignUpEndTime < CurServerTime) then
            self:SendEndGameReq()
            return
        end

        CurGameClass:GameStateToSignUp(GoldSauserMgr, GoldSauserMgr.GoldSauserVM)
        CurGameClass:RegisterPlayTimeCountDown(GoldSauserMgr, GoldSauserMgr.GoldSauserVM)

        -- 这里，当前时间距离报名时间没有超过15秒，才播放动画，应该没有哪个手机要加载这么久吧
        if (PlayerSignUpTimeStampMS + 15000 > CurServerTime and self.bNeedPlayEnterAnim) then
            self.bNeedPlayEnterAnim = false
            _G.GoldSauserMgr:ShowGoldSauserOpportunityForBegin(
                function()
                    -- 这里先留着，后续可能做跳跳乐的指引
                    -- local MentionCallback = function()
                    --     local Title = LSTR(1270018) -- 向着终点前进
                    --     local Type = 3
                    --     local InfoMsg = string.format(LSTR(1270019), self.ReachEndRewardCoin) -- 抵达终点可获得%s金碟币
                    --     MsgTipsUtil.ShowInfoTextTips(Type, Title, InfoMsg, 3)
                    -- end

                    -- local Config = {
                    --     Type = ProtoRes.tip_class_type.TIP_SYS_NOTICE,
                    --     Callback = MentionCallback
                    -- }
                    -- _G.TipsQueueMgr:AddPendingShowTips(Config)

                    local Title = LSTR(1270018) -- 向着终点前进
                    local Type = 3
                    local InfoMsg = string.format(LSTR(1270019), self.ReachEndRewardCoin) -- 抵达终点可获得%s金碟币
                    local ShowTime = 3
                    MsgTipsUtil.ShowInfoTextTips(Type, Title, InfoMsg, ShowTime)

                    -- 这里检测一下辅助跳越，没开启就弹窗提示是否要开启
                    local bEnableSpecialJump = SettingsTabRole:GetEnableSpecialJump() == 1
                    if (not bEnableSpecialJump) then
                        self:RegisterTimer(
                            function()
                                -- 这里直接用A表示所有的跳跳乐了
                                local RecordGameID = ProtoRes.Game.GameID.GameIDLeapOfFaithA
                                _G.GoldSauserMgr:ShowEnableSpecialJumpMsgBox(RecordGameID)
                            end,
                            ShowTime, -- 这里是延迟显示
                            0,
                            1
                        )
                    end

                    -- 机遇临门通用的新手引导
                    _G.GoldSauserMgr:ShowOpportunityNewTutorial()
                    -- 通用结束
                end
            )
        end
    end

    -- 创建离开EOBJ
    do
        local EndEobjListID = self.SceneTableData.EndEobjID

        local MapEditorData = _G.ClientVisionMgr:GetEditorDataByEditorID(EndEobjListID, "EObj")
        if (MapEditorData ~= nil) then
            _G.ClientVisionMgr:DoClientActorEnterVision(
                EndEobjListID,
                MapEditorData,
                _G.MapEditorActorConfig.EObj,
                MapEditorData.ResID
            )
        else
            _G.FLOG_ERROR("ClientVisionMgr:GetEditorDataByEditorID() 失败， ID是:%s", tostring(EndEobjListID))
        end
    end

    -- END

    -- 读取当前地图的所有仙人刺AreaID
    local SearchStr = string.format("MapConfigID = %d", self.SceneTableData.ID)
    local TableList = LeapOfFaithCactusCfg:FindAllCfg(SearchStr)
    for Key, Value in pairs(TableList) do
        self.CurMapCactusAreaIDList[Value.AreaID] = Value.Type
    end
    -- End

    do
        -- 这里记录一下玩家已经触碰了的仙人刺
        for _, AreaID in pairs(PlayerData.CactusAreaIDs) do
            -- 因为ID是唯一的，因此直接将VALUE写成KEY
            local Type = self.CurMapCactusAreaIDList[AreaID]
            if (Type == nil) then
                _G.FLOG_ERROR("服务器下发的仙人刺 AreaID : %s ，在当前地图记录中找不到，请检查", AreaID)
            else
                self.PlayerHitCactusAreaIDList[AreaID] = Type
            end
        end

        for InAreaID, TriggerType in pairs(self.PlayerHitCactusAreaIDList) do
            if (TriggerType == ProtoRes.Game.LeapOfFaithCactusType.LeapOfFaithCactusTypeGold) then
                self.GoldCount = self.GoldCount + 1
            elseif (TriggerType == ProtoRes.Game.LeapOfFaithCactusType.LeapOfFaithCactusTypeSilver) then
                self.SilverCount = self.SilverCount + 1
            else
                self.BronzeCount = self.BronzeCount + 1
            end
        end

        local GoldVM = _G.GoldSauserMgr.GoldSauserVM
        local TotalCoin = self:GetTotalCoin()
        GoldVM.GoldText = string.format(LSTR(1270002), TotalCoin) -- 当前获得的金碟币：%s
    end

    do
        -- 这里处理需要显示的仙人刺
        for _, AreaID in pairs(self.RoundData.CactusAreaIDs) do
            local _Type = self.CurMapCactusAreaIDList[AreaID]
            if (_Type == nil) then
                _G.FLOG_ERROR("服务器下发的仙人刺 AreaID : %s ，在当前地图记录中找不到，请检查", AreaID)
            else
                if (self.PlayerHitCactusAreaIDList[AreaID] == nil) then
                    -- 玩家没有触碰的
                    self.CurMapNotHitCactusDataList[AreaID] = {
                        Type = _Type
                    }
                    FLOG_INFO("服务器下发，且没有触碰的仙人掌 ID : %s", AreaID)
                end
            end
        end

        local CurMapEditData = _G.MapEditDataMgr:GetMapEditCfg()
        local AreaList = CurMapEditData.AreaList
        for AreaID, Value in pairs(self.CurMapNotHitCactusDataList) do
            -- 这里生成一下
            local CactusEobjID = CactusEobjIDTable[Value.Type]

            local TargetData = table.find_item(AreaList, AreaID, "ID")
            if (TargetData == nil) then
                _G.FLOG_ERROR("虚景跳跳乐报错，当前地图信息无法获取 AreaID : %s", AreaID)
            else
                if (TargetData.Cylinder ~= nil) then
                    local TargetPos = TargetData.Cylinder.Start

                    local EobjData = {
                        ID = AreaID,
                        ResID = CactusEobjID,
                        IsHide = true,
                        Dir = _G.UE.FVector(),
                        Scale = _G.UE.FVector(1, 1, 1),
                        Point = TargetPos,
                        Type = _G.UE.EActorType.EObj
                    }

                    Value.EntityID =
                        _G.ClientVisionMgr:DoClientActorEnterVision(
                        AreaID,
                        EobjData,
                        _G.MapEditorActorConfig.EObj,
                        CactusEobjID
                    )

                    local Actor = ActorUtil.GetActorByEntityID(Value.EntityID)
                    if (Actor ~= nil) then
                        Actor:SetSharedGroupTimelineState(CactusShowState)
                        Value.Actor = Actor
                    end
                else
                    _G.FLOG_ERROR("ID ：%s 没有 Cylinder 数据，请检查", AreaID)
                end
            end
        end
    end

    do
        -- 遍历表格数据，设置隐藏或者显示捷径，以及检查点
        for Key, Value in pairs(self.SceneTableData.CheckPointAndShortCuts) do
            if (Value.CheckPointEobjID > 0) then
                local ExistItem = table.find_item(PlayerData.CheckPointEobjIDs, Value.CheckPointEobjID)
                if (ExistItem == nil) then
                    -- 没有开启检查点，那么创建出来检查点
                    local MapEditorData = _G.ClientVisionMgr:GetEditorDataByEditorID(Value.CheckPointEobjID, "EObj")
                    if (MapEditorData ~= nil) then
                        _G.ClientVisionMgr:DoClientActorEnterVision(
                            Value.CheckPointEobjID,
                            MapEditorData,
                            _G.MapEditorActorConfig.EObj,
                            MapEditorData.ResID
                        )
                    else
                        _G.FLOG_ERROR(
                            "ClientVisionMgr:GetEditorDataByEditorID() 失败， ID是:%s",
                            tostring(Value.CheckPointEobjID)
                        )
                    end
                else
                    self.PlayerHitCheckPointList[Value.CheckPointEobjID] = 1
                    self:InternalShowShorcut(Value.ShortCutAreaID, Value.ShortCutListID)
                end
            end
        end
    end
    -- End 处理完成

    self.IsReConnect = false

    _G.EventMgr:SendEvent(EventID.LeapOfFaithUpdateScore)
end

function GoldSauserLeapOfFaithMgr:InternalShowShorcut(InShortCutAreaID, InShortCutListID)
    -- 这里要创建捷径
    local MapEditorData = _G.ClientVisionMgr:GetEditorDataByEditorID(InShortCutListID, "EObj")
    if (MapEditorData ~= nil) then
        local EntityID =
            _G.ClientVisionMgr:DoClientActorEnterVision(
            InShortCutListID,
            MapEditorData,
            _G.MapEditorActorConfig.EObj,
            MapEditorData.ResID
        )

        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if (Actor ~= nil) then
            Actor:SetSharedGroupTimelineState(ShortCutDefaultState)
            local Data = {}
            self.ActiveShortCutListID[InShortCutAreaID] = Data
            Data.ShortCutEntityID = EntityID
        else
            _G.FLOG_ERROR("无法获取 Actor , ID 是 : %s", EntityID)
        end
    else
        _G.FLOG_ERROR("ClientVisionMgr:GetEditorDataByEditorID() 失败， ID是:%s", tostring(InShortCutListID))
    end
end

--- 当前地图是否为虚景跳跳乐地图
function GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()
    if (self.TargetMapResIDTable == nil) then
        return false
    end

    if (_G.PWorldMgr.BaseInfo == nil) then
        return false
    end

    local CurrPWorldResID = _G.PWorldMgr.BaseInfo.CurrPWorldResID
    for Key, Value in pairs(self.TargetMapResIDTable) do
        if (Key == CurrPWorldResID) then
            return true
        end
    end

    return false
end

function GoldSauserLeapOfFaithMgr:OnRegisterTimer()
end

function GoldSauserLeapOfFaithMgr:OnEnd()
    local b = 0
end

function GoldSauserLeapOfFaithMgr:OnShutdown()
end

return GoldSauserLeapOfFaithMgr
