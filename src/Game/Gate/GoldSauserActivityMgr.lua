--[[
Author: lightpaw_Leo
Date: 2024-02-02 9:02:12
Description: 仙人仙彩，幻卡大赛，时尚品鉴，仙人微彩Npc行为，MapIcon，Hud，系统播报~
该脚本的Activity指 仙人仙彩，幻卡大赛，时尚品鉴，仙人微彩
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
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local TimeUtil = require("Utils/TimeUtil")
local NpcDialogMgr = require("Game/NPC/NpcDialogMgr")
local EventMgr = require("Event/EventMgr")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local GoldsauseNpcBahaviorCfg = require("TableCfg/GoldsauseNpcBahaviorCfg")
local GoldSauseGateCfg = require("TableCfg/GoldSauserGateCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MapDefine = require("Game/Map/MapDefine")
local NpcQuestCfg = require("TableCfg/NpcQuestCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local GoldsauseTipCfg = require("TableCfg/GoldsauseTipCfg")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local JumboCactpotLottoryCeremonyMgr = require("Game/JumboCactpot/JumboCactpotLottoryCeremonyMgr")
local AnimationUtil = require("Utils/AnimationUtil")
local ObjectGCType = require("Define/ObjectGCType")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")

local WorldMsgMgr = nil
local MiniCactpotMgr = _G.MiniCactpotMgr
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr

local EntertainGameID = ProtoRes.Game.GameID
local ActivityState = ProtoRes.GoldActivityState
local EnumActivityType = ProtoRes.GoldActivityType
local QUEST_STATUS =    ProtoCS.CS_QUEST_STATUS
local IsInGoldSauserSysMap = GoldSauserMainPanelDefine.IsInGoldSauserSysMap

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_GOLD_SAUSER_CMD
local LSTR = _G.LSTR
local PWorldMgr = _G.PWorldMgr
local MapEditDataMgr = _G.MapEditDataMgr
local GameNetworkMgr
local JumboCactpotMgr

local GoldSauserActivityMgr = LuaClass(MgrBase)

function GoldSauserActivityMgr:OnInit()
    self.CurrMapResID = nil     -- 当前进入的场景ID
    self.bNeedShowSysTip = true
    self.JDMapID = 12060
    self.RecursionNum = 0
    self.RelateNpcData = {}
    self.CurTimeFormat = TimeUtil.GetServerTimeFormat("%H:%M:%S")
    self.CanBehviorAngle = 60
    -- self.BehaviorTimers = {}
end

function GoldSauserActivityMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    MsgTipsUtil = _G.MsgTipsUtil
    JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
    WorldMsgMgr = _G.WorldMsgMgr
    --
end

function GoldSauserActivityMgr:OnEnd()
end

function GoldSauserActivityMgr:OnShutdown()
end

function GoldSauserActivityMgr:OnRegisterNetMsg()
    -- 检测幻卡大赛消耗了次数
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_FINISH, self.OnHandleNetMsgFantasyCard)
end

function GoldSauserActivityMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)

    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)

    self:RegisterGameEvent(EventID.EnterBubbleRange, self.OnEventEnterTriggerRange)
    self:RegisterGameEvent(EventID.LeaveBubbleRange, self.OnEventLeaveTriggerRange)

    -- self:RegisterGameEvent(EventID.EnterInteractionRange, self.PlayNpcBehavior)
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnGameEventQuestUpdate)
end

--- @type 幻卡大赛消耗次数后
function GoldSauserActivityMgr:OnHandleNetMsgFantasyCard(MsgBody)
    if MsgBody == nil then
        return
    end
    local BehaviorNpcIDList = GoldSauserDefine.BehaviorNpcIDList
    local NpcResID = BehaviorNpcIDList.MagicCardReceptNpc
    self:CheckAndUpdateIconDissAppear(NpcResID)
end


--- @type 检测小地图图标是否需要消失(仙彩，幻卡大赛，微彩，时尚品鉴相关Npc)
function GoldSauserActivityMgr:CheckAndUpdateIconDissAppear(NpcResID)
    local BehaviorNpcIDList = GoldSauserDefine.BehaviorNpcIDList
    local bIsRemove = false
    if NpcResID == BehaviorNpcIDList.JumboCactpotIssueNpc and not JumboCactpotMgr:IsExistJumbCount() then
        bIsRemove = true
    elseif NpcResID == BehaviorNpcIDList.MiniCactpotIssuerNpc and MiniCactpotMgr:GetLeftChance() == 0 then
        bIsRemove = true
    elseif NpcResID == BehaviorNpcIDList.MagicCardReceptNpc and MagicCardTourneyMgr:IsFinishedTourney() then
        bIsRemove = true
    elseif NpcResID == BehaviorNpcIDList.FashionCheckRecptNpc then
        -- bIsRemove = false
    end
    local MapMarkerType = MapDefine.MapMarkerType
    local MarkerProviders = _G.MapMarkerMgr:GetMarkerProviders(MapMarkerType.GoldActivity)
    local DefaultMarkerProvide = MarkerProviders[1]
    if DefaultMarkerProvide ~= nil then
        local Params = DefaultMarkerProvide:FindMarkerParamByNpcResID(NpcResID, bIsRemove)
        -- EventMgr:SendEvent(EventID.GoldActivityMapEnd, Params)
        -- EventMgr:SendEvent(EventID.GoldActivityIconUpdate, { EntityID = ActorUtil.GetActorEntityIDByResID(NpcResID)})
    end
end

--- @type 刷出小地图Icon以及HUD(仙彩，幻卡大赛，微彩，时尚品鉴相关Npc)
function GoldSauserActivityMgr:UpdateMiniMapIcon(NpcResID)
    local MapMarkerType = MapDefine.MapMarkerType
    local MarkerProviders = _G.MapMarkerMgr:GetMarkerProviders(MapMarkerType.GoldActivity)
    local DefaultMarkerProvide = MarkerProviders[1]
    if DefaultMarkerProvide ~= nil then
        local Params = DefaultMarkerProvide:FindMarkerParamByNpcResID(NpcResID)
        -- EventMgr:SendEvent(EventID.GoldActivityMapUpdate, Params)
        -- EventMgr:SendEvent(EventID.GoldActivityIconUpdate, { EntityID = ActorUtil.GetActorEntityIDByResID(NpcResID)})
    end
end

--- 开启金碟系统地图Tick处理相关逻辑（系统播报，npc行为）
function GoldSauserActivityMgr:StartActivityRuleTimer()
    local ActivityRuleTimer = self.ActivityRuleTimer
    if ActivityRuleTimer then
        self:UnRegisterTimer(ActivityRuleTimer)
    end

    self.ActivityRuleTimer = self:RegisterTimer(self.JDMapTick, 0, 0.6 , 0, self)
end

--- 关闭金碟系统地图Tick处理相关逻辑（系统播报，npc行为）
function GoldSauserActivityMgr:EndActivityRuleTimer()
    local ActivityRuleTimer = self.ActivityRuleTimer
    if not ActivityRuleTimer then
        return
    end

    self:UnRegisterTimer(ActivityRuleTimer)
    self.ActivityRuleTimer = nil
end

--- @type 当加载完世界
function GoldSauserActivityMgr:OnPWorldEnter(Params)
    --local JDResID = 1008204
    local EnterMapResID = Params.CurrMapResID
    if not EnterMapResID then
        return
    end
    self.CurrMapResID = EnterMapResID
    if IsInGoldSauserSysMap(EnterMapResID) then
        self:InitData()
        self:StartActivityRuleTimer()
    end
end

function GoldSauserActivityMgr:OnPWorldExit(_, LeaveMapResID)
    if IsInGoldSauserSysMap(LeaveMapResID) then
        self:EndActivityRuleTimer()
        self:UnRegistNpcBehaviorTimer()
    end
end

--- @type Actor进入视野
function GoldSauserActivityMgr:OnGameEventVisionEnter(Params)
    if not self:CheckContinueVisionFunc(Params) then
        return
    end
    local ResID = Params.IntParam2
    -- if ResID ~= 1010446 then
    --     return
    -- end
    self:UpdateCachNpcData(Params.ULongParam1, Params.IntParam1, ResID)
    self:SetTriggerRange(Params.ULongParam1, ResID)
end

function GoldSauserActivityMgr:OnGameEventVisionLeave(Params)
    if not self:CheckContinueVisionFunc(Params) then
        return
    end
    local ResID = Params.IntParam2
    self:ResetCachNpcData(ResID)
end

function GoldSauserActivityMgr:OnEventEnterTriggerRange(Params)
    local EntityID = Params.ULongParam1
    local ResID = ActorUtil.GetActorResID(EntityID)
    local NpcData = self.RelateNpcData[ResID]
    if NpcData == nil then
        return
    end
    self:TryPlayNpcBehaviorByData(NpcData)
end

function GoldSauserActivityMgr:OnEventLeaveTriggerRange(Params)
    local EntityID = Params.ULongParam1
    local ResID = ActorUtil.GetActorResID(EntityID)
    if ResID == nil then
        return
    end
    -- local NpcData = self.RelateNpcData[ResID]
    self:ChangeNpcbActiveState(ResID, false)
    self:UnRegistNpcBehaviorTimer()
end

--- @type 进入视野缓存EntityID且bEnterVisionRange为true
function GoldSauserActivityMgr:UpdateCachNpcData(EntityID, ActorType, ResID)
    self.RelateNpcData[ResID].EntityID = EntityID
    self.RelateNpcData[ResID].ActorType = ActorType
    self.RelateNpcData[ResID].bEnterVisionRange = true
    if self.RelateNpcData[ResID].Rotation == nil then
        local Npc = ActorUtil.GetActorByEntityID(EntityID)
        if Npc ~= nil then
            self.RelateNpcData[ResID].Rotation = Npc:FGetActorRotation()
        end
    end
end

--- @type 设置处罚范围
function GoldSauserActivityMgr:SetTriggerRange(EntityID, ResID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        local NeedCfg = self:GetNeedBehaviorCfgByResID(ResID)
        if NeedCfg then
            Actor:SetBubbleRange(NeedCfg.TriggerRange)
        end
    end
end

--- @type 离开视野秦楚EntityId且bEnterVisionRange为false
function GoldSauserActivityMgr:ResetCachNpcData(ResID)
    self.RelateNpcData[ResID].EntityID = nil
    self.RelateNpcData[ResID].ActorType = nil
    self.RelateNpcData[ResID].bEnterVisionRange = false
end

function GoldSauserActivityMgr:CheckContinueVisionFunc(Params)
    local ActorType = Params.IntParam1
    -- local EntityID = Params.ULongParam1
    local ResID = Params.IntParam2
    if ActorType ~= _G.UE.EActorType.Npc then
        return false
    end
    local RelateNpcData = self.RelateNpcData
    if RelateNpcData[ResID] == nil then
        return false
    end
    return true
end

-- --- @type 获取HudIcon
-- function GoldSauserActivityMgr:GetGoldActivityNPCHudIcon(EntityID)
--     local NpcResID = ActorUtil.GetActorResID(EntityID)
--     local bFinsihQuest = self:CheckShouldHaveHudByNpcID(NpcResID)
--     local IconPath = GoldSauserDefine.TaskIcon.GoldActivityIcon
--     if bFinsihQuest then
--         return IconPath
--     end
--     return
-- end

-- --- 根据是否完成任务以及是否完成活动判断Npc是否需要出现Hud
-- function GoldSauserActivityMgr:CheckShouldHaveHudByNpcID(NpcID)
--     local NpcIDList = GoldSauserDefine.BehaviorNpcIDList
--     local bFinishActivity = false
--     if NpcID == NpcIDList.FashionCheckRecptNpc then
--         bFinishActivity = false --TODO 待完善
--     elseif NpcID == NpcIDList.JumboCactpotIssueNpc then
--         bFinishActivity = not JumboCactpotMgr:IsExistJumbCount()
--     elseif NpcID == NpcIDList.MagicCardReceptNpc then
--         bFinishActivity = MagicCardTourneyMgr:IsFinishedTourney()
--     elseif NpcID == NpcIDList.MiniCactpotIssuerNpc then
--         bFinishActivity = MiniCactpotMgr:GetLeftChance() == 0
--     else
--         return false
--     end
--     local QusetIDList = self:GetQusetIDByNpcID(NpcID)

--     if QusetIDList == nil or #QusetIDList < 1 then    -- 本来就没有任务
--         return false
--     end
--     local bFinsihQuest = true
--     for _, v in pairs(QusetIDList) do
--         local QuestID = v
--         local QuestStatus = _G.QuestMgr:GetQuestStatus(QuestID)
--         if QuestStatus ~= TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED then -- 不是已完成
--             bFinsihQuest = false
--         end
--     end
--     return bFinsihQuest and not bFinishActivity -- 完成任务且没完成活动
-- end

--- @type 检查该Npc是否完成了任务
function GoldSauserActivityMgr:CheckIsFinishNpcQuest(NpcID)
    local QusetIDList = self:GetQusetIDByNpcID(NpcID)
    if QusetIDList == nil or #QusetIDList < 1 then    -- 本来就没有任务
        return true
    end
    local bFinsihQuest = true
    local QuestID = 0
    for _, v in pairs(QusetIDList) do
        QuestID = v
        local QuestStatus = _G.QuestMgr:GetQuestStatus(QuestID)
        if QuestStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then -- 不是已完成
            bFinsihQuest = false
            break
        end

        local TipText = "Finish"
        if QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_FAILED then
            TipText = "Failed"
        elseif QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
            TipText = "InProgress"
        elseif QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
            TipText = "NoBegin"
        end
        _G.FLOG_INFO("QuestStatus is %s", TipText)
    end
    return bFinsihQuest, QuestID
end

--- @type 根据NpcID获取相关任务ID
function GoldSauserActivityMgr:GetQusetIDByNpcID(NpcID)
    local Cfg = NpcQuestCfg:FindCfgByKey(NpcID)
    if Cfg == nil then
        return
    end
    return Cfg.StartQuest
end

--- @type 当进入交互范围
function GoldSauserActivityMgr:PlayNpcBehavior(NpcData)
    local ActorType = NpcData.ActorType
    local EntityID = NpcData.EntityID
    local ResID = NpcData.ID
    if ActorType ~= _G.UE.EActorType.Npc then
        return
    end
    local NeedCfg = self:GetNeedBehaviorCfgByResID(ResID)
    if NeedCfg == nil then
        return
    end

    if NeedCfg.AnimPath ~= nil then
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        -- ActorUtil.LookAtActor(Actor, MajorUtil.GetMajor())
        _G.AnimMgr:PlayActionTimeLineByActor(Actor, --[["AnimMontage'/Game/Assets/Character/Action/ability/2rp_redmage/abl018.abl018'"]]NeedCfg.AnimPath, nil)
        _G.FLOG_INFO("_G.AnimMgr:PlayActionTimeLineByActor(Actor, NeedCfg.AnimPath, nil")
    end
    if NeedCfg.BubbleID ~= nil and NeedCfg.BubbleID ~= 0 then
        _G.SpeechBubbleMgr:ShowBubbleByID(EntityID, NeedCfg.BubbleID)
    end
end

--- @type 幻卡大赛未参与
function GoldSauserActivityMgr:MagicCardNoInvolved()
    local bNoInvolve = not MagicCardTourneyMgr:IsSignUpTourney()
    local bCannotGetReward = not MagicCardTourneyMgr:IsCanGetReward()
    local IsBegin = MagicCardTourneyMgr:IsTourneyActive()
    return bNoInvolve and bCannotGetReward and IsBegin
end

--- @type 幻卡大赛未完成
function GoldSauserActivityMgr:MagicCardNoFinish()
    local bNoFinish = not MagicCardTourneyMgr:IsFinishedTourney()
    local bCannotGetReward = not MagicCardTourneyMgr:IsCanGetReward()
    return bNoFinish and bCannotGetReward
end

--- @type 幻卡大赛完成且未领奖
function GoldSauserActivityMgr:MagicCardFinish()
    local bFinish = MagicCardTourneyMgr:IsFinishedTourney()
    local bCannotGetReward = not MagicCardTourneyMgr:IsCanGetReward()
    return bFinish and bCannotGetReward
end

--- @type 幻卡大赛即将结束且未完成
function GoldSauserActivityMgr:MagicCardNearDDL()
    local TimeData = MagicCardTourneyMgr:GetTourneyDate()
    local OneDaySec = 86400
    local bNearOneDayDDL = (TimeData ~= nil and (TimeData.EndTime - TimeUtil.GetServerTime() > OneDaySec))
    local bNoFinish = not MagicCardTourneyMgr:IsFinishedTourney()
    local bCannotGetReward = not MagicCardTourneyMgr:IsCanGetReward()
    return bNoFinish and bCannotGetReward and bNearOneDayDDL
end

--- @type 获取当前活动的枚举状态
function GoldSauserActivityMgr:GetActivityStateByType(ActivityType, ResID)
    local BehaviorNpcIDList = GoldSauserDefine.BehaviorNpcIDList
    if ActivityType == EnumActivityType.ACTIVITY_JUMBCACTPOT then
        -- 仙彩有两个相关Npc需要分别来判断状态
        if ResID == BehaviorNpcIDList.JumboCactpotIssueNpc then
            if JumboCactpotMgr:GetPurNumLocal() == 0 and not JumboCactpotMgr:IsLottory() then
                return ActivityState.ACTIVITY_STATE_NOINVOLVED
            elseif JumboCactpotMgr:IsExistJumbCount() and not JumboCactpotMgr:IsLottory() then
                return ActivityState.ACTIVITY_STATE_REMAINCOUNT
            elseif JumboCactpotMgr:IsNearlyDeadLine() then
                return ActivityState.ACTIVITY_STATE_NEARDEADLINE
            elseif not JumboCactpotMgr:IsExistJumbCount() and not JumboCactpotMgr:IsLottory() then
                return ActivityState.ACTIVITY_STATE_DEADLINE
            elseif JumboCactpotMgr:IsLottory() then
                return ActivityState.ACTIVITY_STATE_NOEXCHANGE
            end
        end
    elseif ActivityType == EnumActivityType.ACTIVITY_MINICACTPOT then
        if MiniCactpotMgr:GetLeftChance() == 3 then            -- 未参与
            return ActivityState.ACTIVITY_STATE_NOINVOLVED       
        elseif MiniCactpotMgr:GetLeftChance() > 0 then         -- 有剩余次数
            return ActivityState.ACTIVITY_STATE_REMAINCOUNT
        elseif MiniCactpotMgr:GetLeftChance() == 0 then        -- 已完成
            return ActivityState.ACTIVITY_STATE_DEADLINE
        end
    elseif ActivityType == EnumActivityType.ACTIVITY_MAGICCARD then
        if self:MagicCardNoInvolved() then
            return ActivityState.ACTIVITY_STATE_NOINVOLVED
        elseif self:MagicCardNoFinish() then
            return ActivityState.ACTIVITY_STATE_REMAINCOUNT
        elseif self:MagicCardNearDDL() then
            return ActivityState.ACTIVITY_STATE_NEARDEADLINE
        elseif self:MagicCardFinish() then
            return ActivityState.ACTIVITY_STATE_DEADLINE
        elseif MagicCardTourneyMgr:IsCanGetReward() then
             return ActivityState.ACTIVITY_STATE_NOEXCHANGE
         end
    elseif ActivityType == EnumActivityType.ACTIVITY_FASHIONCHECK then
        if not FashionEvaluationMgr:IsEvaluated() and not FashionEvaluationMgr:IsFinishedEvaluation() then          -- 未参与
            return ActivityState.ACTIVITY_STATE_NOINVOLVED
        elseif FashionEvaluationMgr:IsEvaluated() and not FashionEvaluationMgr:IsFinishedEvaluation() then  -- 参与过
            return ActivityState.ACTIVITY_STATE_REMAINCOUNT
        elseif FashionEvaluationMgr:IsNearlyOverEvaluation() and not FashionEvaluationMgr:IsFinishedEvaluation() then       -- 即将结束
            return ActivityState.ACTIVITY_STATE_NEARDEADLINE
        elseif FashionEvaluationMgr:IsFinishedEvaluation() then -- 已完成
            return ActivityState.ACTIVITY_STATE_DEADLINE
        end
    end
    return
end

--- @type 当任务更新时
function GoldSauserActivityMgr:OnGameEventQuestUpdate(Params)
    if Params.RemovedQuestList == nil then
        return
    end
    local RemovedQuestList = Params.RemovedQuestList
    for _, v in pairs(RemovedQuestList) do
        local Elem = v
        local NpcID = Elem.NaviObjID
        if not self:CheckIsNeedNpcID(NpcID) then
            table.remove_item(RemovedQuestList, Elem)
        end
    end
    if #RemovedQuestList == 0 then
        return
    end

    local MapMarkerType = MapDefine.MapMarkerType
    local MarkerProviders = _G.MapMarkerMgr:GetMarkerProviders(MapMarkerType.GoldActivity)
    local DefaultMarkerProvide = MarkerProviders[1]
    if DefaultMarkerProvide ~= nil then
        for _, v in pairs(RemovedQuestList) do
            local QuestData = v
            local NpcID = QuestData.NaviObjID
            self:UpdateMiniMapIcon(NpcID)
        end
    end
end

--- @type 通过NpcID检查是否是需要的任务时间
function GoldSauserActivityMgr:CheckIsNeedNpcID(NpcID)
    local MapMarkerType = MapDefine.MapMarkerType
    local MarkerProviders = _G.MapMarkerMgr:GetMarkerProviders(MapMarkerType.GoldActivity)
    if #MarkerProviders >= 1 then
        for _, v in pairs(MarkerProviders) do
            local Provider = v
            local RelatedNpcIDList = Provider.RelatedNpcIDList
            for _, v in pairs(RelatedNpcIDList) do 
                local ElemNpcID = v
                if NpcID == ElemNpcID then
                    return true
                end
            end
        end
    end
    return false
end

function GoldSauserActivityMgr:GetNeedBehaviorCfgByResID(ResID)
    local Cfg = GoldsauseNpcBahaviorCfg:FindCfgByNpcResID(ResID)
    if Cfg == nil then
        return
    end
    local ActivityType = Cfg.ActivityType
    local State = self:GetActivityStateByType(ActivityType, ResID)
    if State == nil then
        return
    end
    local NeedCfg = GoldsauseNpcBahaviorCfg:FindCfgByNpcResIDAndState(ResID, State)

    return NeedCfg
end

------------------------------------------------------广播提示-------------------------------------------------------
--- @type 需要加载DB数据
function GoldSauserActivityMgr:InitData()
    local GlobalID = ProtoRes.Game.game_global_cfg_id.GAME_CFG_GOLD_SAUSER_ACTIVITY_TIME_RULE
    local MinToSec = 60 -- 从分钟转换为秒
    local TimerRuleData = GameGlobalCfg:FindCfgByKey(GlobalID)
    if TimerRuleData ~= nil then
        self.TimeRoleValue = TimerRuleData.Value
        local BeginAndEndTimeData = GoldSauserDefine.BeginAndEndTimeData
        local SysTipShowTimeRuleData = {}
        SysTipShowTimeRuleData.JumbBeginMin = TimerRuleData.Value[BeginAndEndTimeData.JumbBeginIndex] * MinToSec
        SysTipShowTimeRuleData.JumbEndMin = TimerRuleData.Value[BeginAndEndTimeData.JumbEndIndex] * MinToSec
        SysTipShowTimeRuleData.MagicCardBeginMin = TimerRuleData.Value[BeginAndEndTimeData.MagicCardBeginIndex] * MinToSec
        SysTipShowTimeRuleData.MagicCardEndMin = TimerRuleData.Value[BeginAndEndTimeData.MagicCardEndIndex] * MinToSec
        SysTipShowTimeRuleData.FashionCheckBeginMin = TimerRuleData.Value[BeginAndEndTimeData.FashionCheckBeginIndex] * MinToSec
        SysTipShowTimeRuleData.FashionCheckEndMin = TimerRuleData.Value[BeginAndEndTimeData.FashingCheckEndIndex] * MinToSec
        self.SysTipShowTimeRuleData = SysTipShowTimeRuleData
    end
    self:ConstructNpcData()
end

--- @type 缓存npc位置信息
function GoldSauserActivityMgr:ConstructNpcData()
    local AllCfg = GoldsauseNpcBahaviorCfg:FindAllCfg()
    for i = 1, #AllCfg do
        local NpcResID = AllCfg[i].RelateNpcResID
        local LastResID
        if  i > 1 then
            LastResID = AllCfg[i - 1].RelateNpcResID
        end
        if LastResID == nil or NpcResID ~= LastResID then
            local NpcData = MapEditDataMgr:GetNpc(NpcResID)
            if NpcData == nil then
                _G.FLOG_ERROR("NpcData is nil. ResID = %s", NpcResID)
                return
            end
            local Cfg = GoldsauseNpcBahaviorCfg:FindCfgByNpcResID(NpcResID)
            local Tmp = {}
            Tmp.ID = NpcResID
            Tmp.Location = NpcData.BirthPoint
            Tmp.bInCoolDown = false
            Tmp.AlreadyActive = false
            Tmp.bEnterVisionRange = false
            if Cfg ~= nil then
                Tmp.IntervalTime = Cfg.IntervalTime
                Tmp.TriggerRange = Cfg.TriggerRange
            end 
            self.RelateNpcData[NpcResID] = Tmp
        end 
    end
end

function GoldSauserActivityMgr:JDMapTick()
    local LastTime = self.CurTimeFormat
    local LastTimeArr = string.split(LastTime, ":")
    local LastHour = LastTimeArr[1]
    -- local LastMin = LastTimeArr[2]
    -- local LastSec = LastTimeArr[3]

    self.CurTimeFormat = TimeUtil.GetServerTimeFormat("%H:%M:%S")
    local TimeArr = string.split(self.CurTimeFormat, ":")
    local Hour = TimeArr[1]
    -- local Min = TimeArr[2]
    -- local Sec = TimeArr[3]

    MiniCactpotMgr:CheckNeedRefreshData(LastHour, Hour)
    self:ShowSysTipOnTimeRun()
    JumboCactpotLottoryCeremonyMgr:CheckIsNearLotteryCeremoneyTime()
end

--- @type 改变相关Npc行为
function GoldSauserActivityMgr:TryPlayNpcBehaviorByData(NpcData)
    local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end
    if not NpcData.bInCoolDown and not NpcData.AlreadyActive then
        if self:CheckIsFinishNpcQuest(NpcData.ID) then
            local bSuccessPlay = self:PlayNpcBehaviorAndEnd(NpcData)
            if not bSuccessPlay then
                self.NpcBehaviorTimerHandle = self:RegisterTimer(self.PlayNpcBehaviorAndEnd, 0, 0.3, 0, NpcData)            
            end
        end
    end
end

function GoldSauserActivityMgr:PlayNpcBehaviorAndEnd(NpcData)
    if self:CheckIsInAngle(NpcData) then
        self:PlayNpcBehavior(NpcData)
        self:OnPlayNpcBehaviorEnd(NpcData)
        self:UnRegistNpcBehaviorTimer()
        return true
    end
    return false  
end

function GoldSauserActivityMgr:UnRegistNpcBehaviorTimer()
    if self.NpcBehaviorTimerHandle ~= nil then
        self:UnRegisterTimer(self.NpcBehaviorTimerHandle)
        self.NpcBehaviorTimerHandle = nil
        FLOG_INFO("UnRegistNpcBehaviorTimer")
    end
end

--- @type OnEnd
function GoldSauserActivityMgr:OnPlayNpcBehaviorEnd(NpcData)
    if NpcData == nil then
        return
    end
    self:ChangeNpcCoolDownState(NpcData.ID, true)
    self:ChangeNpcbActiveState(NpcData.ID, true)
    local CoolDownTime = NpcData.IntervalTime
    self:RegisterTimer(function() self:ChangeNpcCoolDownState(NpcData.ID, false) end, CoolDownTime)

    local NeedCfg = self:GetNeedBehaviorCfgByResID(NpcData.ID)
    if NeedCfg == nil then
        return
    end
    local AnimMontage = _G.ObjectMgr:LoadObjectSync(NeedCfg.AnimPath, ObjectGCType.LRU)
    local Npc = ActorUtil.GetActorByEntityID(NpcData.EntityID)
    if Npc ~= nil then
        local NeedMontage = Npc:CheckActionTimelineMontage(AnimMontage, "WholeBody", 0.25, 0.25, 99999)
        if NeedMontage == nil then
            return
        end
        local AnimTime = AnimationUtil.GetAnimMontageLength(NeedMontage)
        if AnimTime > 0 then
            -- self:RegisterTimer(self.ResetNpcRotation, AnimTime, 0, 1, NpcData)
        else
            _G.FLOG_ERROR("Get MontageLength Fail")
        end
    end
    
end

--- @type 改变冷却状态
function GoldSauserActivityMgr:ChangeNpcCoolDownState(ID, bCoolDown)
    if ID == nil or self.RelateNpcData[ID] == nil then
        return
    end
    self.RelateNpcData[ID].bInCoolDown = bCoolDown
end
--- @type 改变是否可被激活行为
function GoldSauserActivityMgr:ChangeNpcbActiveState(ID, bActive)
    if ID == nil or self.RelateNpcData[ID] == nil then
        return
    end
    self.RelateNpcData[ID].AlreadyActive = bActive
end

function GoldSauserActivityMgr:ResetNpcRotation(NpcData)
    if NpcData.EntityID ~= nil then
        local Npc = ActorUtil.GetActorByEntityID(NpcData.EntityID)
        if Npc ~= nil and NpcData.Rotation ~= nil then
            Npc:K2_SetActorRotation(NpcData.Rotation, false)
        end
    end
end

--- @type 检测是否在角度内
function GoldSauserActivityMgr:CheckIsInAngle(NpcData)
    if NpcData.EntityID ~= nil then
        local Npc = ActorUtil.GetActorByEntityID(NpcData.EntityID)
        if Npc ~= nil and NpcData.Rotation ~= nil then
            local NpcForwardVec = Npc:FGetActorRotation():GetForwardVector()
            local Major = MajorUtil.GetMajor()
            if Major ~= nil then
                local NpcToMajorVec = Major:FGetActorLocation() - Npc:FGetActorLocation()
                local CosVal = self.GetCosValue2D(NpcForwardVec, NpcToMajorVec)
                local Radius = math.acos(CosVal)
            
                local Angle = (180 / math.pi) * Radius
                if Angle <= self.CanBehviorAngle / 2 then
                    return true
                end
            end
        end
    end
    return false
end

function GoldSauserActivityMgr:SetCanBehviorAngle(Angle)
    self.CanBehviorAngle = Angle
end

--- @type 获得余眩的值
function GoldSauserActivityMgr.GetCosValue2D(Vec1, Vec2)
    return (Vec1.X * Vec2.X + Vec1.Y * Vec2.Y) / (math.sqrt(Vec1.X ^ 2 + Vec1.Y ^ 2) * math.sqrt(Vec2.X ^ 2 + Vec2.Y ^ 2))
end

--- @type 根据时间判断是否显示系统提示(仙彩，幻卡，时尚品鉴的提示)
function GoldSauserActivityMgr:ShowSysTipOnTimeRun()
    if self:FinishAllActivity() then -- 如果做完了全部活动就返回好了
        return
    end

    self:SetbNeedShowSysTip()
    if not self.bNeedShowSysTip then
        return
    end

    local NextSysTipTime = self.NextSysTipTime
    local CurActivityType = self.CurActivityType
    if NextSysTipTime == nil or CurActivityType == nil then
        self.NextSysTipTime, self.CurActivityType = self:GetNextTypeAndShowTipTime()
    end
    if NextSysTipTime == nil then   -- 如果不在需要出现的时间内，那也不要提示了
        return
    end

    --- 出现提示
    local CurTime = self:GetCurSecondThisHour()
    if CurTime >= NextSysTipTime then
        local Cfg = self:FindCfgByActivityType(CurActivityType)
        if Cfg ~= nil then
            self:ShowBroadcastTips(Cfg.SysNoticeID)
            self.bNeedShowSysTip = false
            self.ShowTime = self:GetCurSecondThisHour()
            self.RecursionNum = 0
        end
        self.NextSysTipTime = nil
        self.CurActivityType = nil
    end
end

--- @type 获得下一次系统播报的时间s
function GoldSauserActivityMgr:GetNextTypeAndShowTipTime()
    local SysTipShowTimeRuleData = self.SysTipShowTimeRuleData
    if SysTipShowTimeRuleData == nil then
        return
    end
    local CurTime = self:GetCurSecondThisHour()
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))

    local NextSysTipTime
    local NeedActivityType
    if CurTime >= SysTipShowTimeRuleData.JumbBeginMin and CurTime <= SysTipShowTimeRuleData.JumbEndMin then
        NextSysTipTime = math.random(CurTime, SysTipShowTimeRuleData.JumbEndMin) --math.clamp(CurTime + 5, CurTime, SysTipShowTimeRuleData.JumbEndMin) -- 
        NeedActivityType = EnumActivityType.ACTIVITY_JUMBCACTPOT
    elseif CurTime >= SysTipShowTimeRuleData.MagicCardBeginMin and CurTime <= SysTipShowTimeRuleData.MagicCardEndMin then
        NextSysTipTime = math.random(CurTime, SysTipShowTimeRuleData.MagicCardEndMin) -- math.clamp(CurTime + 5, CurTime, SysTipShowTimeRuleData.MagicCardEndMin) --
        NeedActivityType = EnumActivityType.ACTIVITY_MAGICCARD
    elseif CurTime >= SysTipShowTimeRuleData.FashionCheckBeginMin and CurTime <= SysTipShowTimeRuleData.FashionCheckEndMin then
        NextSysTipTime = math.random(CurTime, SysTipShowTimeRuleData.FashionCheckEndMin) -- math.clamp(CurTime + 5, CurTime, SysTipShowTimeRuleData.FashionCheckEndMin)  -- 
        NeedActivityType = EnumActivityType.ACTIVITY_FASHIONCHECK
    end
    return NextSysTipTime, NeedActivityType
end

--- @type 构造获得TipID的函数列表
function GoldSauserActivityMgr:FindCfgByActivityType(CurActivityType)
    local TimeRoleValue = self.TimeRoleValue
    local ActivityNum = #TimeRoleValue / 2
    local FunctionTable = {
        {Function = self.GetJumbTipID, Type = EnumActivityType.ACTIVITY_JUMBCACTPOT},
        {Function = self.GetMagicCardTipID, Type = EnumActivityType.ACTIVITY_MAGICCARD},
        {Function = self.GetFashionCheckTipID, Type = EnumActivityType.ACTIVITY_FASHIONCHECK}
    }
    self.ActivityCfg = nil
    for _, v in pairs(FunctionTable) do
        local Elem = v
        if Elem.Type == CurActivityType then
            self.ActivityCfg = Elem.Function()
        end   
    end
    if self.ActivityCfg == nil then
        return
    end
    if self.RecursionNum > ActivityNum then
        _G.FLOG_INFO("All Activity Is Finished!")
        return
    end

    if self.ActivityCfg.ActivityState == ActivityState.ACTIVITY_STATE_DEADLINE then
        self.RecursionNum = self.RecursionNum + 1
        local NextActivityType = self:FindNextActivity(CurActivityType)
        self.ActivityCfg = self:FindCfgByActivityType(NextActivityType)
    end
    return self.ActivityCfg
end

--- @type 寻找下一个活动
function GoldSauserActivityMgr:FindNextActivity(CurActivityType)
    local AllTipCfg = GoldsauseTipCfg:FindAllCfg()
    for i = 1, #AllTipCfg do
        local Cfg = AllTipCfg[i]
        local NextCfg
        if i + 1 <= #AllTipCfg then
            NextCfg = AllTipCfg[i + 1]
        else
            return AllTipCfg[1].ActivityType
        end
        if NextCfg ~= nil and Cfg.ActivityType == CurActivityType and NextCfg.ActivityType ~= CurActivityType then
            return NextCfg.ActivityType 
        end
    end
end

--- @type 所有活动都完成了
function GoldSauserActivityMgr:FinishAllActivity()
    local bFinishAll = GoldSauserActivityMgr:JumbFinished() and MagicCardTourneyMgr:IsFinishedTourney() and FashionEvaluationMgr:IsFinishedEvaluation()
    return bFinishAll
end

--- @type 仙人仙彩已完成购买
function GoldSauserActivityMgr:JumbFinished()
    -- 没有购买次数了，并且没开奖
    return not JumboCactpotMgr:IsExistJumbCount() and not JumboCactpotMgr:IsLottory()
end

--- @type 根据仙彩参与的状态选取tipID
function GoldSauserActivityMgr.GetJumbTipID()
    local ActivityType = EnumActivityType.ACTIVITY_JUMBCACTPOT
    local CurActivityState

    if JumboCactpotMgr:GetPurNumLocal() == 0 and not JumboCactpotMgr:IsLottory() then  -- 未参与
        CurActivityState = ActivityState.ACTIVITY_STATE_NOINVOLVED
    elseif JumboCactpotMgr:IsExistJumbCount() and not JumboCactpotMgr:IsLottory() then  -- 有剩余次数
        CurActivityState = ActivityState.ACTIVITY_STATE_REMAINCOUNT
    elseif JumboCactpotMgr:IsNearlyDeadLine() and not JumboCactpotMgr:IsLottory() then  -- 临近结束
        CurActivityState = ActivityState.ACTIVITY_STATE_NEARDEADLINE
    elseif GoldSauserActivityMgr:JumbFinished() then      -- 完成购买
        CurActivityState = ActivityState.ACTIVITY_STATE_DEADLINE
    elseif JumboCactpotMgr:IsLottory() then         -- 已开将
        CurActivityState = ActivityState.ACTIVITY_STATE_NOEXCHANGE
    end

    local bFinishQuest = GoldSauserActivityMgr:CheckIsFinishNpcQuest(GoldSauserDefine.BehaviorNpcIDList.JumboCactpotIssueNpc)
    if not bFinishQuest then
        CurActivityState = ActivityState.ACTIVITY_STATE_NOINVOLVED -- 没完成任务状态变为未参与
    end

    if CurActivityState == nil then
        return
    end
    local Cfg = GoldsauseTipCfg:FindCfgByActivityTypeAndActivityState(ActivityType, CurActivityState)
    if Cfg == nil then
        return
    end
    return Cfg
end

--- @type 根据幻卡大赛参与的状态选取tipID
function GoldSauserActivityMgr.GetMagicCardTipID()
    local OneDaySec = 86400
    local ActivityType = EnumActivityType.ACTIVITY_MAGICCARD
    local CurActivityState
    local TimeData = MagicCardTourneyMgr:GetTourneyDate()
    if not MagicCardTourneyMgr:IsSignUpTourney() and MagicCardTourneyMgr:IsTourneyActive()  then  --- 未参与
        CurActivityState = ActivityState.ACTIVITY_STATE_NOINVOLVED
    elseif not MagicCardTourneyMgr:IsFinishedTourney() and MagicCardTourneyMgr:IsTourneyActive() then     -- 有剩余次数
        CurActivityState = ActivityState.ACTIVITY_STATE_REMAINCOUNT
    elseif (TimeData ~= nil and (TimeData.EndTime - TimeUtil.GetServerTime() > OneDaySec)) and MagicCardTourneyMgr:IsTourneyActive() then  -- 临近结束
        CurActivityState = ActivityState.ACTIVITY_STATE_NEARDEADLINE
    elseif MagicCardTourneyMgr:IsFinishedTourney() then  -- 次数用光
        CurActivityState = ActivityState.ACTIVITY_STATE_DEADLINE
    elseif MagicCardTourneyMgr:IsCanGetReward() then    -- 开奖但未兑换
        CurActivityState = ActivityState.ACTIVITY_STATE_NOEXCHANG
    end

    local bFinishQuest = GoldSauserActivityMgr:CheckIsFinishNpcQuest(GoldSauserDefine.BehaviorNpcIDList.MagicCardReceptNpc)
    if not bFinishQuest then
        CurActivityState = ActivityState.ACTIVITY_STATE_NOINVOLVED -- 没完成任务状态变为未参与
    end

    if CurActivityState == nil then
        return
    end
    local Cfg = GoldsauseTipCfg:FindCfgByActivityTypeAndActivityState(ActivityType, CurActivityState)
    if Cfg == nil then
        return
    end
    return Cfg
end

--- @type 根据时尚品鉴参与的状态选取tipID TODO
function GoldSauserActivityMgr.GetFashionCheckTipID()
    -- local OneDaySec = 86400
    -- local TimeData = MagicCardTourneyMgr:GetTourneyDate()
    local CurActivityState = ActivityState.ACTIVITY_STATE_NOINVOLVED
    if not FashionEvaluationMgr:IsEvaluated() and not FashionEvaluationMgr:IsFinishedEvaluation() then              -- 未参与
        CurActivityState = ActivityState.ACTIVITY_STATE_NOINVOLVED
    elseif FashionEvaluationMgr:IsEvaluated() and not FashionEvaluationMgr:IsFinishedEvaluation() then  -- 参与过
        CurActivityState = ActivityState.ACTIVITY_STATE_REMAINCOUNT
    elseif FashionEvaluationMgr:IsNearlyOverEvaluation() and not FashionEvaluationMgr:IsFinishedEvaluation() then       -- 即将结束
        CurActivityState = ActivityState.ACTIVITY_STATE_NEARDEADLINE
    elseif FashionEvaluationMgr:IsFinishedEvaluation() then -- 已完成
        CurActivityState = ActivityState.ACTIVITY_STATE_DEADLINE
    end

    local bFinishQuest = GoldSauserActivityMgr:CheckIsFinishNpcQuest(GoldSauserDefine.BehaviorNpcIDList.FashionQuestNpc)
    if not bFinishQuest then
        CurActivityState = ActivityState.ACTIVITY_STATE_NOINVOLVED -- 没完成任务状态变为未参与
    end

    local ActivityType = EnumActivityType.ACTIVITY_FASHIONCHECK
    if CurActivityState == nil then
        return
    end
    local Cfg = GoldsauseTipCfg:FindCfgByActivityTypeAndActivityState(ActivityType, CurActivityState)

    return Cfg -- 暂时写死
end

--- @type 设置是否需要出现系统提示
function GoldSauserActivityMgr:SetbNeedShowSysTip()
    if self.bNeedShowSysTip then
        return
    end
    local ShowTime = self.ShowTime
    if ShowTime == nil then
        return
    end
    local SysTipShowTimeRuleData = self.SysTipShowTimeRuleData
    if not SysTipShowTimeRuleData or not next(SysTipShowTimeRuleData) then
        return
    end
    local CurSecond = self:GetCurSecondThisHour()
    if ShowTime >= SysTipShowTimeRuleData.JumbBeginMin and ShowTime <= SysTipShowTimeRuleData.JumbEndMin then
        if CurSecond > SysTipShowTimeRuleData.JumbEndMin then
            self.bNeedShowSysTip = true
            return
        end
    end

    if ShowTime >= SysTipShowTimeRuleData.MagicCardBeginMin and ShowTime <= SysTipShowTimeRuleData.MagicCardEndMin then
        if CurSecond > SysTipShowTimeRuleData.MagicCardEndMin then
            self.bNeedShowSysTip = true
            return
        end
    end

    if ShowTime >= SysTipShowTimeRuleData.FashionCheckBeginMin and ShowTime <= SysTipShowTimeRuleData.FashionCheckEndMin then
        if CurSecond > SysTipShowTimeRuleData.FashionCheckEndMin then
            self.bNeedShowSysTip = true
            return
        end
    end
end

--- @type 获取这个小时进行到多少秒
function GoldSauserActivityMgr:GetCurSecondThisHour()
    local MinToSec = 60 -- 从分钟转换为秒
    local CurMinute = TimeUtil.GetServerLogicTimeFormat("%M")
    local CurSecond = TimeUtil.GetServerLogicTimeFormat("%S")
    return CurMinute * MinToSec + CurSecond
end

--- @type 展示系统播报
function GoldSauserActivityMgr:ShowBroadcastTips(MsgTipID)
    local Cfg = SysnoticeCfg:FindCfgByKey(MsgTipID)

    if nil == Cfg or nil == next(Cfg) then
		-- _G.FLOG_ERROR(string.format("MsgTipsUtil.ShowTipsByID can't find tips, ID=%d", MsgTipID))
		return
	end

    local Times = 1

    if Cfg.ShowTimes > 0 then
		Times = Cfg.ShowTimes
	end
    MsgTipsUtil.ShowTipsByID(MsgTipID)
end
------------------------------------------------------广播提示End-------------------------------------------------------

return GoldSauserActivityMgr
