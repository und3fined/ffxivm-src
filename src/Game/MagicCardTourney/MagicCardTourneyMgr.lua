--
-- Author: Carl
-- Date: 2023-10-07 16:57:14
-- Description:幻卡大赛Mgr

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")
local MsgTipsID = require("Define/MsgTipsID")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardRoleManager = require("Game/MagicCardTourney/MagicCardRoleManager")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local PWorldMgr = _G.PWorldMgr
local LSTR = _G.LSTR
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local CS_CMD = ProtoCS.CS_CMD
local FANTASY_CARD_OP = ProtoCS.FANTASY_CARD_OP
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local MagicCardTourneyMgr = LuaClass(MgrBase)
local EMatchState = MagicCardTourneyDefine.EMatchState

function MagicCardTourneyMgr:OnInit()
    self.CanMatch = true
    self.IsInTourney = false
    self.IsEnterMagicCardRange = false
    self.IsEnterMatchRoom = false
    self.IsGameQuit = false
    self.IsRobot = false
    self.CurRefreshEffectIndex = -1
    self.RoleManager = MagicCardRoleManager.New()
    self.MatchConfirmStartTime = 0
    self.BattleID = 0
    self.IsCancelEnterMatch = false
    self.IsMatchSuccess = false
    self.LootParams = {}
end

function MagicCardTourneyMgr:OnBegin()
end

function MagicCardTourneyMgr:OnEnd()
end

function MagicCardTourneyMgr:OnShutdown()
end

function MagicCardTourneyMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_ROOM_UPDATE, self.OnNetMsgRoomUpdate)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_INFO, self.OnNetMsgTourneyInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_RANK, self.OnNetMsgRankInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH, self.OnNetMsgMatchTourney)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH_DONE, self.OnNetMsgMatchSuccess)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH_CONFIRM, self.OnNetMsgMatchConfirm)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_OPPONENT_LEAVE, self.OnNetMsgMatchOpponentLeave)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_FINISH, self.OnNetMsgFantasyCardFinishRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_VIEW_GROUP, self.OnNetMsgViewGroupRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_SIGNUP, self.OnNetMsgSignUpForTourney)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_AWARD, self.OnNetMsgClaimReward)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_EFFECT_REROLL, self.OnNetMsgRefreshEffect)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_CHOOSE, self.OnNetMsgChooseEffectSuccess)
end

function MagicCardTourneyMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(EventID.EnterInteractive, self.OnSingleInteractive)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnLeavePWorld)
    self:RegisterGameEvent(EventID.PWorldTransBegin, self.OnPWorldTransBegin)
    self:RegisterGameEvent(EventID.MagicCardBattleQuit, self.OnMagicCardBattleQuit)
    self:RegisterGameEvent(EventID.MagicCardBeforeEnterQuit, self.OnMagicCardBeforeEnterQuit)
    self:RegisterGameEvent(EventID.HideUI, self.OnHideView)
    self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnGameEventEnterMagicCardRange)
    self:RegisterGameEvent(EventID.AreaTriggerEndOverlap, self.OnGameEventLeaveMagicCardRange)
    self:RegisterGameEvent(EventID.MagicCardTourneyLateShowLoot, self.OnMagicCardTourneyLateShowLoot)
end

function MagicCardTourneyMgr:OnHideView(ViewID)
    if ViewID == nil then
        return
    end 

    if self.IsEnterMagicCardRange == false and self.IsEnterMatchRoom == false then
        return
    end 

    -- GM测试用,使用GM命令后拉取最新数据
    if ViewID == UIViewID.GMMain then
        self:UpdateTourneyInfo()
    end

    if ViewID == UIViewID.CommonRewardPanel then
        self:LateShowLoot()
    end

    if ViewID == UIViewID.InfoAreaTips then
        local CurrPWorldResID = PWorldMgr.BaseInfo.CurrPWorldResID
        local PWorldID = TourneyVMUtils.GetTourneyRoomID() --对局室ID
        if CurrPWorldResID == PWorldID then
            self:SwitchStageInfoView()
        end
    end
end

--- @type 请求进入对局室 拉取大赛数据，供其它模块调用
function MagicCardTourneyMgr:ReqEnterMatchRoom()
    if _G.PWorldMatchMgr:IsMatching() then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.MatchRoomRefuseEnter, nil)
        return
    end
    self:EndInteraction()
    --local IsEnter = PWorldEntUtil.EnterTest()
	local PWorldID = PWorldEntUtil.GetMagicCardTourneyPWorldID()
	local SMode = PWorldQuestDefine.ClientSceneMode.SceneModeChocoboRoom
	local EntTy = ProtoCommon.ScenePoolType.ScenePoolFantasyCard
	if _G.TeamMgr:IsInTeam() and _G.TeamMgr:IsCaptain() then
		_G.PWorldVoteMgr:ReqStartVoteEnterMagicCardTourneyRoom(PWorldID, EntTy, SMode)
	else
        local function SendInteractive()
            -- 单人进入
             local Cfg = require("TableCfg/SceneEnterCfg"):FindCfgByKey(PWorldID)
             if Cfg and Cfg.SPID > 0 then
                _G.PWorldMgr:EnterSinglePWorld(Cfg and Cfg.SPID)
             end
        end

        local function CancelCallBack()
            self:EndInteraction()
        end

        MsgBoxUtil.ShowMsgBoxTwoOp(self, MagicCardTourneyDefine.EnterRoomConfirmBoxTitle, MagicCardTourneyDefine.EnterRoomConfirmBoxText,
        SendInteractive, CancelCallBack, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"
	end
end

function MagicCardTourneyMgr:IsMatching()
    local StageInfoVM = TourneyVM.StageInfoVM
    if (StageInfoVM  == nil) then
        return false
    end

    return StageInfoVM:IsMatching()
end

--- @type 请求退出对局室 
function MagicCardTourneyMgr:ReqExitMatchRoom()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM and StageInfoVM:IsMatching() then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.MatchRoomRefuseExit, nil)
        return
    end
    local PWorldID = PWorldEntUtil.GetMagicCardTourneyPWorldID()
    _G.PWorldMgr:SendLeavePWorld(PWorldID)
end

--- @type 进入副本时 拉取大赛数据，供其它模块调用
function MagicCardTourneyMgr:OnPWorldReady()
    if MainPanelVM:GetMagicCardTourneyInfoVisible() then
        self:ShowTourneyInfoBar(false)
    end

    if PWorldMgr == nil or PWorldMgr.BaseInfo == nil then
        return
    end

    -- 进入金蝶场景时
    local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    if BaseInfo.CurrMapResID == MagicCardTourneyDefine.JDMapID then
        self:UpdateTourneyInfo()
    end

    -- 进入对局室
    local CurrPWorldResID = PWorldMgr.BaseInfo.CurrPWorldResID
    local PWorldID = TourneyVMUtils.GetTourneyRoomID() --对局室ID
    if CurrPWorldResID == PWorldID then
        self.IsEnterMatchRoom = true
        self:UpdateTourneyInfo()
        if TourneyVM then
            TourneyVM:UpdateEffectStatus()
            TourneyVM:OnEnterMatchRoom()
        end
        self.RoleManager:OnEnterMatchRoom()
        self:SendMsgMatchRoomInfo()
        _G.EventMgr:SendEvent(EventID.MagicCardNeedReqRecover)
    end
end

-- 当进入幻卡区域
function MagicCardTourneyMgr:OnGameEventEnterMagicCardRange(EventParam)
    local AreaID = MagicCardTourneyDefine.FantasyCardAreaID
    if EventParam.AreaID ~= AreaID then
        return
    end

    self.IsEnterMagicCardRange = true
    if not self:GetIsInTourneyRomm() and self:CanShowTourneyInfoBar() then
        self:ShowTourneyInfoBar(true)
        if TourneyVM then
            TourneyVM:OnExitMatchRoom()
        end
    end
end

-- 当离开幻卡区域
function MagicCardTourneyMgr:OnGameEventLeaveMagicCardRange(EventParam)
    local AreaID = MagicCardTourneyDefine.FantasyCardAreaID
    if EventParam.AreaID ~= AreaID then
        return
    end

    if not self.IsEnterMagicCardRange then
        return
    end
    self.IsEnterMagicCardRange = false
    -- 隐藏右上方的大赛提醒UI
    if not self:GetIsInTourneyRomm() then
        self:ShowTourneyInfoBar(false)
    end
end

function MagicCardTourneyMgr:OnMagicCardTourneyLateShowLoot(LootParams)
    if LootParams == nil then
        return
    end
    self.LootParams = TourneyVMUtils.MergeLootList(LootParams)
    local AwardList = TourneyVMUtils.GetAwardListFromLootList(self.LootParams)
    local ItemVM = require("Game/Item/ItemVM")
    local UIBindableList = require("UI/UIBindableList")
    local ItemDefine = require("Game/Item/ItemDefine")
    local ItemVMList =
        UIBindableList.New(
        ItemVM,
        {
            Source = ItemDefine.ItemSource.MatchReward,
            IsCanBeSelected = true,
            IsShowNum = true,
            IsDaily = false,
            IsShowSelectStatus = false,
        }
    )
    for _, V in ipairs(AwardList) do
        ItemVMList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num, PlayAddEffect = V.PlayAddEffect,
        OriginalNum = V.OriginalNum, IncrementedNum = V.IncrementedNum}, nil, true)
    end

    UIViewMgr:ShowView(UIViewID.CommonRewardPanel, {ItemVMList = ItemVMList, Title = LSTR(230008), ShowPanelGoldSauser = true})
end

function MagicCardTourneyMgr:LateShowLoot()
    if self.LootParams == nil or next(self.LootParams) == nil then
        return
    end
    _G.LootMgr:HandleMultipleDrop(self.LootParams)
    _G.LootMgr:ShowSysChatDropList(self.LootParams)
    self.LootParams = nil
end

-- 检测是否显示右上方的大赛提醒UI
function MagicCardTourneyMgr:CheckShowTourneyInfoBar()
    if self:CanShowTourneyInfoBar() and self.IsEnterMagicCardRange == true or self.IsEnterMatchRoom == true then
        if not MainPanelVM:GetMagicCardTourneyInfoVisible() then
            self:ShowTourneyInfoBar(true)
        end
    else
        self:ShowTourneyInfoBar(false)
    end
end

-- 隐藏功能UI的同时显示大赛信息栏
function MagicCardTourneyMgr:ShowTourneyInfoBar(IsShow)
    -- 隐藏右上方的大赛提醒UI
    if MainPanelVM then
        MainPanelVM:SetMagicCardTourneyInfoVisible(IsShow)
    end

    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM then
        StageInfoVM:OnCheckStageChanged(IsShow)
    end
end

-- 准备好匹配比赛，用于显示匹配栏
function MagicCardTourneyMgr:OnReadyTourney()
    self:UpdateTourneyInfo()
    self:ShowTourneyInfoBar(true)
end

--------------- 功能接口 ---------------
function MagicCardTourneyMgr:OnStartMagicCardTourneyWithNPC(NpcId, NpcEntityId, FuncID, Values)
    -- 进入对局室
    if FuncID and FuncID == 80 then
        self:EndInteraction()
        if self.IsEnterMatchRoom then
            self:ReqExitMatchRoom()
        else
            self:ReqEnterMatchRoom()
        end
    else
        -- 没有选择阶段效果
        if not TourneyVM:IsSelectedStageEffect() then
            self:EndInteraction()
            self:ShowStageEffectSelectView() 
        else
            self.NPCID = NpcId
            self.NpcEntityId = NpcEntityId
        
            -- 大赛对局（与NPC）
            local ReqInfo = {
                NPCID = self.NPCID,
                NPCEntityID = self.NpcEntityId,
                IsTournament = true,
            }
            _G.EventMgr:SendEvent(EventID.MagicCardGameStartReq, ReqInfo)
        end
    end
end


--- @type 结束交互
function MagicCardTourneyMgr:EndInteraction()
	_G.NpcDialogMgr:EndInteraction()
end

function MagicCardTourneyMgr:ClearInteractFuncList()
    _G.InteractiveMgr.CurInteractEntrance:OnInit()
end

--- @type 点击一级交互开启对话
function MagicCardTourneyMgr:OnSingleInteractive(EntranceItem)
	if EntranceItem == nil then
		return
	end

    if not self:HasFinishPreQuest() then
       return
    end

	self.EntranceItem = EntranceItem
    local NpcID = MagicCardTourneyDefine.NPCID
    if self.EntranceItem.ResID ~= NpcID then
        return
    end

    local DialogID = 0
    if self:IsShowInteractionSignUp() then  -- 可报名
        DialogID = MagicCardTourneyDefine.TourneyCanSignUpDiaglogID
    elseif self:IsCanGetReward() then  -- 可领奖
        DialogID = MagicCardTourneyDefine.TourneyAwardCanGetDialogID
    elseif not self:IsTourneyActive() and not self:IsCanGetReward() then  --大赛未开启且无奖可领
        DialogID = MagicCardTourneyDefine.TourneyNotActiveDialogID
    end

    if DialogID > 0 then
        local EntityID = EntranceItem.EntityID
        _G.NpcDialogMgr:OverrideStatePending()
        _G.NpcDialogMgr:PlayDialogLib(DialogID, EntityID, true, nil)
    end
    --self:UpdateTourneyInfo()
    self:ClearInteractFuncList()
end

function MagicCardTourneyMgr:HasFinishPreQuest()
    local ModleID = ProtoCommon.ModuleID.ModuleIDFantasyCardTournament
    local IsOpen = _G.ModuleOpenMgr:CheckOpenState(ModleID)
    local OpenCfg = _G.ModuleOpenMgr:GetCfgByModuleID(ModleID)
    local PreTaskList = OpenCfg.PreTask
    local IsFinishPreQuest = true
    if PreTaskList then
        for _, QuestID in ipairs(PreTaskList) do
            if _G.QuestMgr:GetQuestStatus(QuestID) ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                IsFinishPreQuest = false
                break
            end
        end
    end
    return IsOpen and IsFinishPreQuest
end

-- 离开副本通知
function MagicCardTourneyMgr:OnLeavePWorld(LeavePWorldResID, LeaveMapResID)
    local MatchRoomID = TourneyVMUtils.GetTourneyRoomID() --对局室ID
    -- 离开对局室
    if LeavePWorldResID == MatchRoomID then
        self.IsInTourney = false
        if TourneyVM then
            TourneyVM:OnExitMatchRoom()
        end
        
        local StageInfoVM = TourneyVM.StageInfoVM
        if StageInfoVM and StageInfoVM:IsMatching() then
            self:OnCancelMatch()
        end

        if self.IsMatchSuccess then
            self:ManualCancelEnterConfirm()
        end
        self.RoleManager:OnExitMatchRoom()
        --self:ShowPlayerRankTagAll(false)
        self:ShowTourneyInfoBar(false)
    end
    
    -- 离开金蝶游乐场
    if LeaveMapResID == MagicCardTourneyDefine.JDMapID then
        if self.IsEnterMagicCardRange then
            self:ShowTourneyInfoBar(false)
        end
    end

    self.IsEnterMagicCardRange = false
    self.IsEnterMatchRoom = false
end

-- 副本内传送（由于离开幻卡区域在金蝶副本内传送没有触发，所以采用这个事件）
function MagicCardTourneyMgr:OnPWorldTransBegin(IsOnlyChangeLocation)
    if IsOnlyChangeLocation then
        return
    end

    --副本内传送离开幻卡区域
    if self.IsEnterMagicCardRange then
        self:ShowTourneyInfoBar(false)
        self.IsEnterMagicCardRange = false
    end
end 

-- 对局前退出
function MagicCardTourneyMgr:OnMagicCardBeforeEnterQuit()
    self.IsInTourney = false
    self.IsGameQuit = true
    self.RoleManager:OnMagicCardBattleQuit()
end

-- 对局中主动退出/正常结算退出
function MagicCardTourneyMgr:OnMagicCardBattleQuit()
    self.RoleManager:OnMagicCardBattleQuit()
    if not self:GetIsInTourney() then
        return
    end

    self.IsGameQuit = true
    self.IsInTourney = false
    
    --正常结算退出
    if self:CanShowStageSettlement() then
        self:ShowStageSettelementView()
        return
    end
end

-- 开始匹配
function MagicCardTourneyMgr:OnStartMatch()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM == nil then
        return
    end
    local MatchState = StageInfoVM:GetMatchState()
    if MatchState == EMatchState.Default then
        if TourneyVM:IsSelectedStageEffect() then
            self:SendNetMsgMatchTourney()
        else
            self:ShowStageEffectSelectView()
        end
    elseif MatchState == EMatchState.Matching then
        self:OnCancelMatch()
    elseif MatchState == EMatchState.Confirm then
        --self:OnCancelEnter()
    elseif MatchState == EMatchState.EnterCD then
        local TipText = string.format(MagicCardTourneyDefine.ReMatchTipText, self.MaxReMatchDelay)
        _G.MsgTipsUtil.ShowTips(TipText)
    elseif MatchState == EMatchState.Finished then
    end
end

---@type 取消匹配
function MagicCardTourneyMgr:OnCancelMatch()
    self:ClearMatchTimer()

    self:SendNetMsgCancelMatch()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM == nil then
        return
    end

    StageInfoVM:OnCancelMatch()
    self.MaxReMatchDelay = MagicCardTourneyDefine.MaxReMatchDelay
    StageInfoVM:UpdateMatchTextByState(EMatchState.Default)
end

---@type 取消进入对局
function MagicCardTourneyMgr:OnCancelEnter()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM == nil then
        return
    end

    local function LeftCallBack()
        MsgBoxUtil.CloseMsgBox()
        --UIViewMgr:ShowView(UIViewID.MagicCardTourneyMatchConfirmView)
    end
    self.IsCancelEnterMatch = true
    local TipContent = string.format(MagicCardTourneyDefine.CancelMatchTipText, MagicCardTourneyDefine.MaxReMatchDelay)
    MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), TipContent, self.ManualCancelEnterConfirm, LeftCallBack, LSTR(10003), LSTR(10002)) --"提示" "取 消"、"确 认"
end

---@type 主动确认取消进入对局 有CD
function MagicCardTourneyMgr:ManualCancelEnterConfirm()
    self:CancelEnterConfirm(true)
    self:OnEnterMatchCD()
end

---@type 取消匹配操作
function MagicCardTourneyMgr:CancelEnterConfirm(IsManual)
    self.IsCancelEnterMatch = true
    self.IsMatchSuccess = false
    self:HideEnterConfirmRelativeView()
    self:ClearAutoCancelEnterTimer()
    if IsManual then
        self:SendNetMsgCancelEnterConfirm()
    end
    MsgBoxUtil.CloseMsgBox()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM then
        StageInfoVM:OnCancelEnter(IsManual)
    end
end

---@type 进入匹配CD
function MagicCardTourneyMgr:OnEnterMatchCD()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM == nil then
        return
    end
    -- 主动取消，有时间惩罚
    StageInfoVM:SetMatchState(EMatchState.EnterCD)
    self.MaxReMatchDelay = MagicCardTourneyDefine.MaxReMatchDelay
    local function ReMatchCD()
        StageInfoVM:UpdateMatchTextByState(EMatchState.EnterCD, self.MaxReMatchDelay)
        if self.MaxReMatchDelay <= 0 then
            self:ClearMatchCDTimer()
            
            self.MaxReMatchDelay = MagicCardTourneyDefine.MaxReMatchDelay
            StageInfoVM:UpdateMatchTextByState(EMatchState.Default)
        end
        self.MaxReMatchDelay = self.MaxReMatchDelay - 1
    end
    self:ClearMatchCDTimer()
    self.MatchCDTimer = self:RegisterTimer(ReMatchCD, 0, 1, -1)
end

---@type 隐藏匹配确认相关界面
function MagicCardTourneyMgr:HideEnterConfirmRelativeView()
    self:SetMatchConfirmSidebarVisible(false) --隐藏侧边栏
    _G.UIViewMgr:HideView(_G.UIViewID.PWorldConfirm) --隐藏匹配确认弹窗
end

---@type 确认进入对局
function MagicCardTourneyMgr:OnConfirmEnterTourney()
    self.IsInTourney = true
    self.IsGameQuit = false
    self:ClearAutoCancelEnterTimer()
    self.IsCancelEnterMatch = true  -- 进入对局也认为是取消匹配了
    TourneyVM:SetReady(true)
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM then
        StageInfoVM:UpdateMatchTextByState(EMatchState.Default)
    end
    if not self:IsOpponentRobot() then
        self:SendNetMsgEnterConfirm()
        return
    end

    --对手是机器人，本地玩家准备时间超过了机器人的准备时长，则直接确认
    local RobotReadyTime = TourneyVMUtils.GetRobotReadyTime()
    if self.MatchTimeCount >= RobotReadyTime then
        self:SendNetMsgEnterConfirm()
        return
    end

    local Delay = RobotReadyTime - self.MatchTimeCount
    -- 对手为机器人，并且客户端准备时间很短，则客户端确认时间等于机器人的准备时间，用于模拟对手玩家的准备时间
    self:RegisterTimer(self.SendNetMsgEnterConfirm, Delay)
end

function MagicCardTourneyMgr:ClearMatchCDTimer()
    if self.MatchCDTimer then
        self:UnRegisterTimer(self.MatchCDTimer)
    end
    self.MatchCDTimer = nil
end

function MagicCardTourneyMgr:ClearMatchTimer()
    if self.MatchTimer then
        self:UnRegisterTimer(self.MatchTimer)
    end
    self.MatchTimer = nil
end

function MagicCardTourneyMgr:ClearAutoCancelEnterTimer()
    if self.AutoCancelEnterTimer then
        self:UnRegisterTimer(self.AutoCancelEnterTimer)
    end
    self.AutoCancelEnterTimer = nil
end

---@type 完成所有对局
function MagicCardTourneyMgr:OnFinishedTourney()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM == nil then
        return
    end

    local EndTime = TourneyVM:GetTourneyEndTime()
    local EndTimeText = _G.TimeUtil.GetTimeFormat("%Y/%m/%d %H:%M:%S", EndTime)
    local LocalEndTimeText = LocalizationUtil.GetTimeForFixedFormat(EndTimeText, true) --时间本地化
    local TakeAwardTimeText = string.format(MagicCardTourneyDefine.TourneyFinishRewardTimeText, LocalEndTimeText)
    MsgTipsUtil.ShowTipsByID(MagicCardTourneyDefine.TipsID.TourneyFinished, nil,  TakeAwardTimeText )
    local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
    local Cfg = SysnoticeCfg:FindCfgByKey(MagicCardTourneyDefine.TipsID.TourneyFinished)
	if Cfg then
		local Title = Cfg.Content[1]
        MsgTipsUtil.ShowInfoTextTips(3, Title, TakeAwardTimeText, 3)
	end

    StageInfoVM:OnFinishedTourney()
    StageInfoVM:UpdateMatchTextByState(EMatchState.Finished)
end

---@type 拉取最新数据
function MagicCardTourneyMgr:UpdateTourneyInfo()
    self:SendMsgGetTourneyInfo()
    self:SendMsgRankInfo() 
end

---@type 是否显示报名选项
function MagicCardTourneyMgr:IsShowInteractionSignUp()
    local IsShow = not self:IsSignUpTourney() and self:IsTourneyActive()
    return IsShow
end

---@type 是否显示进入对局室选项
function MagicCardTourneyMgr:IsShowInteractionEnterTourney()
    return not self:GetIsInTourneyRomm()
end

---@type 是否可进行大赛对局
function MagicCardTourneyMgr:CanStartTourneyGame()
    return self:IsTourneyActive() and self:IsSignUpTourney() and not self:IsFinishedTourney()
end

---@type 是否显示领奖选项大 赛未结束时大于最大局数
function MagicCardTourneyMgr:IsShowInteractionGetReward()
    return self:IsCanGetReward()
end

---@type 大赛是否开启
function MagicCardTourneyMgr:IsTourneyActive()
    if self.TourneyInfo == nil then
        return false
    end
    return self.TourneyInfo.IsActive
end

---@type 是否可以显示情报栏
function MagicCardTourneyMgr:CanShowTourneyInfoBar()
    if self.TourneyInfo == nil then
        return false
    end

    -- 如果玩家加入了机遇临门游戏，那么不显示
    if (_G.GoldSauserMgr:IsPlayerJoinGoldSauserOpportunityGame()) then
        return false
    end

    return self.TourneyInfo.IsActive or self:IsCanGetReward() -- 大赛进行中或者奖励未领取
end

---@type 大赛开启与结束时间 
function MagicCardTourneyMgr:GetTourneyDate()
    if TourneyVM == nil then
        return nil
    end

    local DataInfo = {
        StartTime = TourneyVM.StartTime,
        EndTime = TourneyVM.EndTime,
    }

    return DataInfo
end

---@type 是否可领奖 
function MagicCardTourneyMgr:IsCanGetReward()
    local AwardList = self:GetTourneyAward()
    local IsRewardValid = AwardList and #AwardList > 0
    local RewardCondition = self:IsSignUpTourney() and not self:IsTourneyActive() -- 已报名且大赛结束了
    local AwardNotCollected = self.TourneyInfo and not self.TourneyInfo.AwardCollected  --未领奖
    return IsRewardValid and RewardCondition and AwardNotCollected
end

---@type 获取大赛信息 对外接口
---@return table
function MagicCardTourneyMgr:GetTourneySimpleInfo()
    return TourneyVM:GetTourneySimpleInfo()
end

---@type 是否完赛
function MagicCardTourneyMgr:IsFinishedTourney()
    return TourneyVM:GetIsFinishedTourney()
end

---@type 是否报名参赛
function MagicCardTourneyMgr:IsSignUpTourney()
    if self.TourneyInfo == nil then
        return false
    end
    return self.TourneyInfo.IsSignUp
end

---@type 是否处于大赛对局
function MagicCardTourneyMgr:GetIsInTourney()
    return self.IsInTourney
end

---@type 是否处于匹配中 包括确认中
function MagicCardTourneyMgr:GetIsInMatching()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM == nil then
        return
    end
    local MatchState = StageInfoVM:GetMatchState()
    return MatchState == EMatchState.Matching or MatchState == EMatchState.Confirm
end

---@type 是否处于对局室
function MagicCardTourneyMgr:GetIsInTourneyRomm()
    return self.IsEnterMatchRoom
end

---@type 对手是否机器人
function MagicCardTourneyMgr:IsOpponentRobot()
    return self.IsRobot
end

---@type 获取排名图标Path
function MagicCardTourneyMgr:GetRankIndexAsset(RoleID)
    if RoleID == nil or RoleID <= 0 then
        return nil
    end
    local RankList = self.RankInfo and self.RankInfo.TopRank or {}
    local _, Rank = table.find_by_predicate(RankList, 
 function(Info)
        return Info.RoleID == RoleID 
    end )
    local Asset = MagicCardTourneyDefine.RankIndexAsset[Rank]
    if Asset == nil then
        FLOG_ERROR("MagicCardTourneyDefine.RankIndexAsset[%d] is nil", Rank or 0)
        return nil
    end
    return Asset
end

---@type 获取大赛结算奖励
function MagicCardTourneyMgr:GetTourneyAward()
    local PlayerScore = TourneyVM:GetPlayerScore()
    local PlayerRank = TourneyVM:GetPlayerRank()
    local TourneyID = TourneyVM:GetTourneyID()
    local AwardList = TourneyVMUtils.GetTourneySettlementAward(PlayerScore, PlayerRank, TourneyID)
    return AwardList
end

---@type 获取大赛名
function MagicCardTourneyMgr:GetTourneyName()
    return TourneyVM:GetTourneyName()
end

function MagicCardTourneyMgr:GetNextTourneyCD()
    local TimeText = ""
    local Secs = TourneyVM:GetNextTourneyTime() - _G.TimeUtil.GetServerTime()
    local LocalRemainTime = LocalizationUtil.GetCountdownTimeForLongTime(Secs)
    if LocalRemainTime then
        TimeText = LocalRemainTime
    end
    return TimeText
end

---@type 获取限时效果的时间
function MagicCardTourneyMgr:GetPlayerTimeOutForMove()
    local CurEffectID = TourneyVM:GetCurStageEffectID()
    return TourneyVMUtils.GetPlayerTimeOutForMove(CurEffectID, self.IsInTourney)
end

---@type 获取对局室内正在对局中的所有玩家
function MagicCardTourneyMgr:GetInGamePlayerEntityIDMap()
    local PlayerEntityIDMap = MagicCardRoleManager:GetInGamePlayerEntityIDMap()
    return PlayerEntityIDMap
end

function MagicCardTourneyMgr:OnEffectSelected(EffectIndex)
    self:SendMsgSelectEffect(EffectIndex)
end

---@type 显示排名界面
function MagicCardTourneyMgr:ShowRankView()
    UIViewMgr:ShowView(UIViewID.MagicCardTourneyRankView)
end

---@type 显示阶段结算界面
function MagicCardTourneyMgr:ShowStageSettelementView()
    self:SendMsgRankInfo()
    UIViewMgr:ShowView(UIViewID.MagicCardStageSettlmentView)
    self.IsGameQuit = false
end

---@type 是否可以显示阶段结算界面
function MagicCardTourneyMgr:CanShowStageSettlement()
    return self.IsGameQuit and self:IsWillBeNextStage()
end

---@type 是否将要轮到下一个阶段
---@param CurTourneyNum 当前对局数
function MagicCardTourneyMgr:IsWillBeNextStage()
    local BattleCount = self.TourneyInfo and self.TourneyInfo.BattleCount
    if BattleCount == nil or BattleCount <= 0 then
        return false
    end
    return math.fmod(BattleCount, 5) == 0
end

---@type 开始报名
function MagicCardTourneyMgr:OnSignUp()
    UIViewMgr:HideView(UIViewID.MagicCardTourneySignUpView)
    self:EndInteraction()
    if self.TourneyInfo and self.TourneyInfo.IsSignUp then
        return
    end
    self:SendMsgSignUpForTourney()
end

---@type 报名成功
function MagicCardTourneyMgr:OnSignUpSuccess()
    if self.TourneyInfo == nil then
        return
    end

    _G.InteractiveMgr:HideFunctionItem(self.NpcEntityId)
     -- 直接跳回一级交互
    self:EndInteraction()

    local TipDuration = TourneyVMUtils.GetTipDurationByID(MagicCardTourneyDefine.TipsID.SignUpSuccessTip)
    FLOG_ERROR("Tips时间："..TipDuration)
    local function OnTipsReoved()
        self:EndInteraction()
        self:SwitchStageInfoView()
    end

    local function PlayDialogCallback()
        self:ClearInteractFuncList()
        _G.HUDMgr:ShowAllActors()
        if TourneyVM then
            local CupName = TourneyVM.TourneyCupName or ""
            MsgTipsUtil.ShowTipsByID(MagicCardTourneyDefine.TipsID.SignUpSuccessTip, nil, CupName)
        end

        if self.IsEnterMatchRoom then
            self:RegisterTimer(OnTipsReoved, TipDuration*1.5)
        else
            self:ReqEnterMatchRoom()
        end
    end

    local DialogID = MagicCardTourneyDefine.SignUpSuccessDialogID
    if DialogID ~= nil then
        _G.NpcDialogMgr:PlayDialogLib(DialogID, nil, false, PlayDialogCallback)
    else
        FLOG_ERROR("MagicCardTourneyMgr:SignUp Success Dialog Value is nil,Please Config!!")
    end
end

---@type 显示阶段选择或者阶段提示
function MagicCardTourneyMgr:SwitchStageInfoView()
    if TourneyVM:IsSelectedStageEffect() then
        if self:IsSignUpTourney() and self:IsTourneyActive() then
            local StageName = TourneyVM.CurStageName
            local Desc = TourneyVM.CurStageDesc
            if not self:IsFinishedTourney() then
                MsgTipsUtil.ShowInfoTextTips(3, StageName, Desc, 3)
            end
        end
    else
        self:ShowStageEffectSelectView() -- 没有选择阶段效果
    end
end

---@type 显示阶段选择界面
function MagicCardTourneyMgr:ShowStageEffectSelectView()
    UIViewMgr:ShowView(UIViewID.MagicCardTourneyEffectSelectView)
end

---@type 显示比赛详情界面
function MagicCardTourneyMgr:ShowTourneyDetailView()
    local IsActive = self:IsTourneyActive()
    if IsActive == false then
        return
    end
    self:SendMsgRankInfo()
    TourneyVM:UpdateEffectStatus()
    UIViewMgr:ShowView(UIViewID.MagicCardTourneyDetailPanel)
end

---@type 当前对局双方形象处理
function MagicCardTourneyMgr:HandleOpponentAndMajor(IsPVP, OpponentRoleSimple, OpponentResID)
    return self.RoleManager:OnHandleOpponentAndMajor(IsPVP, OpponentRoleSimple, OpponentResID)
end

---@type 距离NPC最近桌是否正在对局中
---@param NPCEntityID number 观众NPC EntityID
---@param NearDistance number 靠近桌子判断距离
function MagicCardTourneyMgr:IsNearDeskPlaying(NPCEntityID, NearDistance)
    return self.RoleManager:IsNearDeskPlaying(NPCEntityID, NearDistance)
end

---@type NPC停留桌是否结束对局
---@param NPCEntityID number 观众NPC EntityID
function MagicCardTourneyMgr:IsNearDeskEndPlay(NPCEntityID)
    return self.RoleManager:IsNearDeskEndPlay(NPCEntityID)
end

---@type 更新排行榜动态物件状态
---@param NPCEntityID number 观众NPC EntityID
function MagicCardTourneyMgr:UpdateRankObjState(IsActive)
    local State = IsActive and 2 or 0
    _G.PWorldMgr:PlaySharedGroupTimeline(MagicCardTourneyDefine.RankDynAssetID, State)
end


-------------------------------------------region NetMsg ----------------------------------------

---@type 获取大赛信息请求
function MagicCardTourneyMgr:SendMsgGetTourneyInfo()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_INFO

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_INFO
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 大赛信息回调
function MagicCardTourneyMgr:OnNetMsgTourneyInfo(MsgBody)
    if MsgBody == nil or MsgBody.InfoRsp == nil then
        return
    end
    local InfoRsp = MsgBody.InfoRsp
    self.TourneyInfo =
    {
        TourneyTerm = InfoRsp.Term or 0, -- 期数
        Rule = InfoRsp.Rule, -- 本期规则
        IsActive = InfoRsp.Active, -- 是否开启
        StartTime = InfoRsp.StartTime, -- 开启时间
        --玩家信息
        IsSignUp = InfoRsp.Signup, -- 是否已经报名
        IsMatching = InfoRsp.IsMatching, -- 是否正在匹配
        AwardCollected = InfoRsp.AwardCollected, -- 是否已领取奖励
        BattleCount = InfoRsp.BattleCount, --已对局次数
        Score = InfoRsp.Score, -- 积分
        -- 待选择的阶段效果ID
        --EffectChoiceList = InfoRsp.EffectChoice,--{[1] = 3,[2] = 5, [3] = 8},
        EffectChoiceList = InfoRsp.EffectChoices, 
        Stats = InfoRsp.Stats,
        -- message Effect {
        --     int32 EffectID = 1;  -- 阶段效果ID
        --     bool Success = 2;    -- 是否成功
        --     int32 Progress = 3;  -- 当前进度
        --     EFFECT_STATUS Status = 4; --阶段效果状态
        --     int32 ScoreChange = 5；-- 阶段效果积分变化
        -- }
        -- 所有阶段效果，最后一个为当前阶段
        SelectedEffectList = InfoRsp.Effects,
        TourneyID = InfoRsp.TournamentIndex,
    }

    if TourneyVM then
        TourneyVM:UpdateTourneyInfo(self.TourneyInfo)
    end

    _G.GoldSauserMainPanelMgr:SetTheMsgUpdateState(GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace, true)
    -- 显示右上方的大赛提醒UI
    self:CheckShowTourneyInfoBar()

    self:UpdateRankObjState(self.TourneyInfo.IsActive)
end

---@type 报名请求
function MagicCardTourneyMgr:SendMsgSignUpForTourney()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_SIGNUP

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_SIGNUP
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 报名回调
function MagicCardTourneyMgr:OnNetMsgSignUpForTourney()
    self:UpdateTourneyInfo()
    self:OnSignUpSuccess()
end

---@type 匹配对局请求
function MagicCardTourneyMgr:SendNetMsgMatchTourney()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 匹配对局请求回包
function MagicCardTourneyMgr:OnNetMsgMatchTourney()
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM == nil then
        return
    end
    StageInfoVM:OnStartMatch()
    self.MatchCountDown = 0
    local function MatchingCD()
        self.MatchCountDown = self.MatchCountDown + 1
        StageInfoVM:UpdateMatchTextByState(EMatchState.Matching, self.MatchCountDown)
    end

    self:ClearMatchTimer()
    self.MatchTimer = self:RegisterTimer(MatchingCD, 0, 1, -1)
end

---@type 取消匹配请求
function MagicCardTourneyMgr:SendNetMsgCancelMatch()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_CANCEL_MATCH

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_CANCEL_MATCH
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 匹配成功回调
function MagicCardTourneyMgr:OnNetMsgMatchSuccess(MsgBody)
    if MsgBody and MsgBody.MatchDoneRsp then
        self.IsRobot = MsgBody.MatchDoneRsp.IsRobot
        self.BattleID = MsgBody.MatchDoneRsp.BattleID
    end
    self.IsMatchSuccess = true
    self.MatchConfirmStartTime = _G.TimeUtil.GetLocalTime()
    UIViewMgr:HideView(UIViewID.MagicCardTourneyDetailPanel)
    local StageInfoVM = TourneyVM.StageInfoVM
    if StageInfoVM then
        StageInfoVM:UpdateMatchTextByState(EMatchState.Confirm)
    end
    self:ClearMatchTimer()
    self:ClearMatchCDTimer()
    self:ClearAutoCancelEnterTimer()
    self.MaxReMatchDelay = MagicCardTourneyDefine.MaxReMatchDelay
    TourneyVM:OnMatchConfirm()
    self.IsCancelEnterMatch = false
    --UIViewMgr:ShowView(UIViewID.MagicCardTourneyMatchConfirmView)
    _G.UIViewMgr:ShowView(_G.UIViewID.PWorldConfirm, self:GetMatchConfirmParams(false))
    if self.IsRobot then
        local RobotReadyTime = TourneyVMUtils.GetRobotReadyTime()
        local function SetReadyForOpponent()
            TourneyVM:SetReadyForOpponent()
        end
        self:RegisterTimer(SetReadyForOpponent, RobotReadyTime)
    end
    self:AutoCancelEnterCD()
end


---@type 匹配对手准备
function MagicCardTourneyMgr:OnNetMsgMatchConfirm(MsgBody)
    if MsgBody == nil or MsgBody.MatchConfirm == nil then
        return
    end
    local OpponentRoleID = MsgBody.MatchConfirm.RoleID
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    if OpponentRoleID and OpponentRoleID ~= MajorRoleID then
        TourneyVM:SetReadyForOpponent()
    end
end

---@type 匹配对手离开
function MagicCardTourneyMgr:OnNetMsgMatchOpponentLeave()
    -- 被动取消
    local IsManual = not self.IsInTourney -- 是否匹配惩罚判断（未主动确认也算主动取消，一样要惩罚CD）
    self:CancelEnterConfirm(IsManual)
    if IsManual then
        self:OnEnterMatchCD()
    end
    local TipText = MagicCardTourneyDefine.OpponentCancelMatchTipText
    _G.MsgTipsUtil.ShowTips(TipText)
end

function MagicCardTourneyMgr:GetMatchConfirmStartTime()
    return self.MatchConfirmStartTime
end

function MagicCardTourneyMgr:GetMatchConfirmParams(IsFromSidebar)
    local Params = {
        bFromSidebar = IsFromSidebar, 
        ModuleID = ProtoCommon.ModuleID.ModuleIDFantasyCard,
        StartTime = self:GetMatchConfirmStartTime(),
        Duration = TourneyVMUtils.GetCardMatchConfirmTime(),
        FoldUpCallBack = function()
            self:SetMatchConfirmSidebarVisible(self:CanShowSidebar())
        end,
        CancelCallBack = function()
            self:OnCancelEnter()
        end,
        ConfirmCallBack = function()
            self:OnConfirmEnterTourney()
        end ,
    }
    return Params
end

function MagicCardTourneyMgr:CanShowSidebar()
    return not self.IsCancelEnterMatch
end

function MagicCardTourneyMgr:SetMatchConfirmSidebarVisible(IsVisible)
    local ConfirmSideBarType = SidebarDefine.SidebarType.MagicCardMatchConfirm
    local SidebarMgr = _G.SidebarMgr
    local IsExist = SidebarMgr:GetSidebarItemVM(ConfirmSideBarType) ~= nil
    if IsVisible then
        if IsExist then
            return
        end

        local Now = _G.TimeUtil.GetLocalTime()
        local CD = TourneyVMUtils.GetCardMatchConfirmTime()
        local StartTime = self:GetMatchConfirmStartTime()
        CD = CD - math.max(0, Now - StartTime)
        SidebarMgr:AddSidebarItem(ConfirmSideBarType, StartTime, CD, nil, false, MagicCardTourneyDefine.PleaseReadyText)
    else
        if not IsExist then
            return
        end

        SidebarMgr:RemoveSidebarItem(ConfirmSideBarType)
    end
end

---@type 开始取消进入对局的倒计时
function MagicCardTourneyMgr:AutoCancelEnterCD()
    self.MatchTimeCount = 0
    local CancelDelay = TourneyVMUtils.GetCardMatchConfirmTime()
	local function AutoCancelEnter()
        TourneyVM:UpdateMatchingResultInfo(CancelDelay)
		CancelDelay = CancelDelay - 0.05
        self.MatchTimeCount = self.MatchTimeCount + 0.05
		if CancelDelay <= 0  then
			self:ManualCancelEnterConfirm()
		end
	end
    
    self:ClearAutoCancelEnterTimer()
    self.AutoCancelEnterTimer = self:RegisterTimer(AutoCancelEnter, 0, 0.05, -1)
end

---@type 确认进入对局请求
function MagicCardTourneyMgr:SendNetMsgEnterConfirm()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH_CONFIRM

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH_CONFIRM
    MsgBody.MatchConfirmReq = {}
    MsgBody.MatchConfirmReq.Enter = true
    MsgBody.MatchConfirmReq.BattleID = self.BattleID
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 取消进入对局请求
function MagicCardTourneyMgr:SendNetMsgCancelEnterConfirm()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH_CONFIRM
    if self.BattleID == nil or self.BattleID <= 0 then
        return
    end
    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH_CONFIRM
    MsgBody.MatchConfirmReq = {}
    MsgBody.MatchConfirmReq.Enter = false
    MsgBody.MatchConfirmReq.BattleID = self.BattleID
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    self.BattleID = 0
end

---@type 开始对局准备
function MagicCardTourneyMgr:OnNetMsgViewGroupRsp(MsgBody)
    self.IsMatchSuccess = false
    TourneyVM:UpdateEffectStatus()
    self:HideEnterConfirmRelativeView()
end

function MagicCardTourneyMgr:OnNetMsgFantasyCardFinishRsp(MsgBody)
    if MsgBody == nil or MsgBody.FinishRsp == nil then
        return
    end
    local TourneyResultInfo = MsgBody.FinishRsp.Tournament
    if TourneyResultInfo == nil then
        return
    end

    -- 大赛对局结束时，只返回了玩家相关信息，大赛信息需要复制过来
    if self.TourneyInfo then
        TourneyResultInfo.Term = self.TourneyInfo.TourneyTerm
        TourneyResultInfo.Active = self.TourneyInfo.IsActive
        TourneyResultInfo.Rule = self.TourneyInfo.Rule
        TourneyResultInfo.StartTime = self.TourneyInfo.StartTime
        self:OnNetMsgTourneyInfo({InfoRsp = TourneyResultInfo})
    end
end

---@type 刷新阶段效果请求
function MagicCardTourneyMgr:SendMsgRefreshEffect(EffectIdx)
    if EffectIdx == nil then
        return
    end
    self.CurRefreshEffectIndex = EffectIdx
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_EFFECT_REROLL

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_EFFECT_REROLL
    MsgBody.RerollReq = {
        EffectIdx = EffectIdx
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 刷新阶段效果回包
function MagicCardTourneyMgr:OnNetMsgRefreshEffect(MsgBody)
    if MsgBody == nil or MsgBody.RerollRsp == nil then
        return
    end

    local NewEffectID = MsgBody.RerollRsp.EffectID
    TourneyVM:UpdateRerollEffectID(self.CurRefreshEffectIndex, NewEffectID)
end

---@type 选择阶段效果请求
function MagicCardTourneyMgr:SendMsgSelectEffect(EffectIdx)
    if EffectIdx == nil then
        return
    end

    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_CHOOSE

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_CHOOSE
    MsgBody.ChooseReq = {
        ChooseEffectIdx = EffectIdx
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardTourneyMgr:OnNetMsgChooseEffectSuccess()
    self:OnReadyTourney()
end

---@type 获取排名请求
function MagicCardTourneyMgr:SendMsgRankInfo()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_RANK

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_RANK
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 排名回调
function MagicCardTourneyMgr:OnNetMsgRankInfo(MsgBody)
    if MsgBody == nil or MsgBody.RankRsp == nil then
        return
    end

    -- 排名信息
    self.RankInfo = MsgBody.RankRsp
    if TourneyVM then
        TourneyVM:UpdateRankInfo(self.RankInfo)
    end

    --self:ShowPlayerRankTagAll(self.IsEnterMatchRoom)
end

---@type HUD 更新所有玩家头顶排名标识
function MagicCardTourneyMgr:ShowPlayerRankTagAll(IsShow)
    if self.RankInfo == nil then
        return
    end
    local EntityIDList = {}
    for Index, RankInfo in ipairs(self.RankInfo.TopRank) do
        local EntityID = ActorUtil.GetEntityIDByRoleID(RankInfo.RoleID)
        if EntityID then
            EntityIDList[Index] = EntityID
        end
    end
    local Params = {
        IsVisible = IsShow,
        EntityIDList = EntityIDList,
    }
    _G.EventMgr:SendEvent(EventID.MagicCardTourneyRankUpdate, Params)
end

---@type 领取奖励请求
function MagicCardTourneyMgr:SendMsgClaimReward()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_AWARD

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_AWARD
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    _G.LootMgr:SetDealyState(true)
end

---@type 领取奖励回调
function MagicCardTourneyMgr:OnNetMsgClaimReward()
    -- 成功领取奖励
    if self.TourneyInfo == nil then
        return
    end
    self.TourneyInfo.AwardCollected = true
    if TourneyVM then
        TourneyVM:UpdateTourneyInfo(self.TourneyInfo)
    end

    self:CheckShowTourneyInfoBar()
end

---@type 对局室信息请求
function MagicCardTourneyMgr:SendMsgMatchRoomInfo()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_ROOM_UPDATE

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_ROOM_UPDATE
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 对局室信息回调
function MagicCardTourneyMgr:OnNetMsgRoomUpdate(MsgBody)
   if MsgBody == nil then
        return
   end
   local RoomRsp = MsgBody.RoomUpdateRsp
   self.RoleManager:OnMagicCardRoomUpdate(RoomRsp)
end

--endregion
return MagicCardTourneyMgr