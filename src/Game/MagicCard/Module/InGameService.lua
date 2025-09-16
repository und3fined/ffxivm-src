---
--- Author: frankjfwang
--- DateTime: 2022-05-20 17:43
--- Description:
---
local LuaClass = require("Core/LuaClass")

local Log = require("Game/MagicCard/Module/Log")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local MagicCardTourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local ActorAnimService = require("Game/MagicCard/Module/ActorAnimService")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local Async = require("Game/MagicCard/Module/AsyncUtils")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local AudioUtil = require("Utils/AudioUtil")
local GlobalCfg = require("TableCfg/GlobalCfg")
local NpcAnimEnum = ProtoRes.fantasy_card_npc_anim_enum
local MajorAnimEnum = ProtoRes.fantasy_card_major_anim_enum

local MagicCardMgr = nil ---@type MagicCardMgr
local GameRuleService = nil ---@type GameRuleService
local EventMgr = nil ---@type EventMgr
local TimerMgr = nil ---@type TimerMgr
local RuleDef = ProtoRes.Game.fantasy_card_rule
local GroupAttack = ProtoCS.BATTLE_GROUP.BATTLE_GROUP_ATTACK
local GroupDefense = ProtoCS.BATTLE_GROUP.BATTLE_GROUP_DEFENSE

local table = table
local ipairs = ipairs

---@class InGameService
---@field Vm MagicCardInGameVM
---@field GameRules RuleConfig[] @本局规则
---@field ImposedCardPlayOrder int[] @“秩序/混乱”规则下指定的玩家出牌顺序
---@field PlayerExchangedCard int @“交换”规则下玩家要交换的牌
---@field EnemyExchangedCard int @“交换”规则下对家要交换的牌
---@field PlayerCardGroup int @玩家所属的Group，决定是否先手（Attackers）
---@field EnemyCardGroup int @对方所属的Group
---@field MoveHandle InGameMoveHandle
---@field TimerForMove int
---@field IsPlayerCurrentMove boolean
---@field IsGameFinishedAfterThisMove boolean
---@field NetMoveRspMoveList RuleEffect[]
---@field NewMoveFlipEffect MoveFlipEffect
local InGameService = LuaClass()

---@param Vm MagicCardInGameVM
function InGameService:Ctor(Vm)
    MagicCardMgr = _G.MagicCardMgr
    EventMgr = _G.EventMgr
    GameRuleService = MagicCardMgr:GetRuleService()
    TimerMgr = _G.TimerMgr
    self.MoveHandle = require("Game/MagicCard/Module/InGameMoveHandle")
    self.MoveHandle.Init(self)
    self.Vm = Vm
    self.OnBoardCardVMList = Vm.OnBoardCardVMList
    self.PlayerCardVMList = Vm.PlayerCardVMList
    self.OpponentCardVMList = Vm.OpponentCardVMList
    self.PlayerPutCardWaitForServerData = false
    self.HavePlayLongtimeIdle = false
    self.CurrentRound = 0
end

-- 断线重连了
function InGameService:OnRecoverGame(SvrEnterRsp)
    self:EndGame()
    self.HasSentAutoPlay = false
    self.NewMoveFantasyCardInfo = nil
    self.ImposedCardPlayOrder = {}
    self.PlayerExchangedCard = 0
    self.EnemyExchangedCard = 0
    self.CurrentRound = SvrEnterRsp.Round
    self.Board = SvrEnterRsp.Board -- 棋盘信息
    self:SetTimerForMove(nil)
    
    self.IsPlayedNpcEmoBehind = false
    self.IsPlayedNpcEmoLeading = false
    self.HavePlayLongtimeIdle = false
    self.HaveOrder = false -- 出牌是否有顺序
    self.IsGameRealStart = false -- 游戏正式开始了
    self.CardGameId = SvrEnterRsp.CardGameID
    self.PlayerCardGroup = SvrEnterRsp.Group
    self.MoveHandle.Reset(self:IsPlayerAttacker())
    self:InternalResetBeforeNewMove(self:IsPlayerAttacker())
    --self.Vm.IsPlayerMove = self:IsPlayerAttacker()
    MagicCardMgr:LoadDefineTimeFromTable()

    
    if self:IsPlayerAttacker() then
        self.EnemyCardGroup = GroupDefense
        self.PlayerExchangedCard = SvrEnterRsp.AttackerExchange and SvrEnterRsp.AttackerExchange + 1 or 0
        self.EnemyExchangedCard = SvrEnterRsp.DefenderExchange and SvrEnterRsp.DefenderExchange + 1 or 0
    else
        self.EnemyCardGroup = GroupAttack
        self.PlayerExchangedCard = SvrEnterRsp.DefenderExchange and SvrEnterRsp.DefenderExchange + 1 or 0
        self.EnemyExchangedCard = SvrEnterRsp.AttackerExchange and SvrEnterRsp.AttackerExchange + 1 or 0
    end

    self:SetGameRules(SvrEnterRsp)
    Log.I(
        "InGameService OnEnterRsp: PlayerCardGroup[%s], IsPlayerAttacker [%s]",
        Log.EnumValueToKey(ProtoCS.BATTLE_GROUP, self.PlayerCardGroup), self:IsPlayerAttacker()
    )

    self.ChosedCardIndex = -1

    -- 恢复双方手牌
    local PlayerCardVMListSvr = self:IsPlayerAttacker() and SvrEnterRsp.AttackerCards or SvrEnterRsp.DefenderCards
    local EnemyCardsSvr = self:IsPlayerAttacker() and SvrEnterRsp.DefenderCards or SvrEnterRsp.AttackerCards

    local _playerWeakValue = 0
    local _enemyWeakValue = 0
    local OpponentRemainCards = 0
    for i = 1, LocalDef.CardCountInGroup do
        -- 自己
        self.PlayerCardVMList[i]:ResetData(PlayerCardVMListSvr[i].CardID)
        self.PlayerCardVMList[i]:SetChangePoint(PlayerCardVMListSvr[i].Change)
        self.PlayerCardVMList[i]:SetIsPlayerCard(true)
        self.PlayerCardVMList[i]:SetExpose(true)
        local BoardLoc = PlayerCardVMListSvr[i].BoardLoc
        if PlayerCardVMListSvr[i].CardID > 0 then
            FLOG_INFO(string.format("【恢复牌局】剩余手牌 玩家：%s", PlayerCardVMListSvr[i].CardID))
        end
        if BoardLoc >= 0 then
            self.PlayerCardVMList[i]:SetActive(false) -- 此牌已经打出去了
        end
        _playerWeakValue = PlayerCardVMListSvr[i].ScoreChange
        if (_playerWeakValue and _playerWeakValue ~= 0) then
            self.PlayerCardVMList[i]:SetTournamentWeaken(_playerWeakValue)
        end

        -- 对方
        self.OpponentCardVMList[i]:ResetData(EnemyCardsSvr[i].CardID)
        local _showExpose = GameRuleService:HasRule(RuleDef.FANTASY_CARD_RULE_EXPOSE_ALL) or EnemyCardsSvr[i].IsExposed
        self.OpponentCardVMList[i]:SetExpose(_showExpose)
        self.OpponentCardVMList[i]:SetIsExposed(_showExpose)
        self.OpponentCardVMList[i]:SetChangePoint(EnemyCardsSvr[i].Change)

        BoardLoc = EnemyCardsSvr[i].BoardLoc
        if BoardLoc >= 0 then
            self.OpponentCardVMList[i]:SetActive(false) -- 此牌已经打出去了
        else
            OpponentRemainCards = OpponentRemainCards + 1
        end
        _enemyWeakValue = EnemyCardsSvr[i].ScoreChange
        if (_enemyWeakValue and _enemyWeakValue ~= 0) then
            self.OpponentCardVMList[i]:SetTournamentWeaken(_enemyWeakValue)
        end

        Log.I("  - PlayerCard[%d] id [%s]", i, PlayerCardVMListSvr[i].CardID)
        Log.I("  - NpcCard[%d]    id [%s] SrvIsExposed [%s]", i, EnemyCardsSvr[i].CardID, EnemyCardsSvr[i].IsExposed)
    end

    FLOG_INFO(string.format("【恢复牌局】剩余手牌数量 对手：%s", OpponentRemainCards))

    -- 恢复牌桌
    for i = 1, 9 do
        local BoardCard = self.Board and self.Board[i]
        if BoardCard and BoardCard.CardID > 0 then
            local IsPlayerCard = self.PlayerCardGroup == BoardCard.Group
            self.OnBoardCardVMList[i]:SetIsPlayerCard(IsPlayerCard)
            self.OnBoardCardVMList[i]:SetIsPlayed(true)
            self.OnBoardCardVMList[i]:SetCardId(BoardCard.CardID)
            if BoardCard.CardID > 0 then
                FLOG_INFO(string.format("【恢复牌局】棋盘手牌 ：%s，归属：%s", BoardCard.CardID, IsPlayerCard and "玩家" or "对手"))
            end
        else 
            self.OnBoardCardVMList[i]:ResetData()
        end
    end

    local TotalTimeForOneMove = self:GetActualTimeOutForMove()
    self.RemainActionTime = math.clamp((SvrEnterRsp.AutoPlayTime - TimeUtil.GetServerLogicTimeMS())/1000, 0, TotalTimeForOneMove)
    self.RemainActionTime = math.ceil(self.RemainActionTime)
    self.PassedTime = TotalTimeForOneMove - self.RemainActionTime
    EventMgr:SendEvent(EventID.MagicCardRecoverPos, self.RemainActionTime)
    self.Vm:UpdateScore()
    -- 恢复出牌倒计时
    self:OnGameDoStart(true)
end

function InGameService:OnEnterGame(SvrEnterRsp)
    self:EndGame()
    self.HavePlayLongtimeIdle = false
    self.NewMoveFantasyCardInfo = nil
    self.HasSentAutoPlay = false
    self.ImposedCardPlayOrder = {}
    self.PlayerExchangedCard = 0
    self.EnemyExchangedCard = 0
    self.CurrentRound = 1
    self:SetTimerForMove(nil)
    self.PassedTime = 0
    self.IsPlayedNpcEmoBehind = false
    self.IsPlayedNpcEmoLeading = false
    self.HaveOrder = false -- 是否有出售顺序
    self.IsGameRealStart = false -- 游戏正式开始了
    self.CardGameId = SvrEnterRsp.CardGameID
    self.PlayerCardGroup = SvrEnterRsp.Group
    self.MoveHandle.Reset(self:IsPlayerAttacker())
    self:InternalResetBeforeNewMove(self:IsPlayerAttacker())
    self.Vm.IsPlayerMove = self:IsPlayerAttacker()
    self.IsPlayerCurrentMove = self:CalculateIsPlayerCurrentMove()
    self.RemainActionTime = self:GetActualTimeOutForMove()
    MagicCardMgr:LoadDefineTimeFromTable()

    if self:IsPlayerAttacker() then
        self.EnemyCardGroup = GroupDefense
        self.PlayerExchangedCard = SvrEnterRsp.AttackerExchange and SvrEnterRsp.AttackerExchange + 1 or 0
        self.EnemyExchangedCard = SvrEnterRsp.DefenderExchange and SvrEnterRsp.DefenderExchange + 1 or 0
    else
        self.EnemyCardGroup = GroupAttack
        self.PlayerExchangedCard = SvrEnterRsp.DefenderExchange and SvrEnterRsp.DefenderExchange + 1 or 0
        self.EnemyExchangedCard = SvrEnterRsp.AttackerExchange and SvrEnterRsp.AttackerExchange + 1 or 0
    end

    Log.I(
        "InGameService OnEnterRsp: PlayerCardGroup[%s], IsPlayerAttacker [%s]",
        Log.EnumValueToKey(ProtoCS.BATTLE_GROUP, self.PlayerCardGroup), self:IsPlayerAttacker()
    )

    self:SetGameRules(SvrEnterRsp)

    self.ChosedCardIndex = -1

    -- 手牌
    local PlayerCardVMListSvr = self:IsPlayerAttacker() and SvrEnterRsp.AttackerCards or SvrEnterRsp.DefenderCards
    local EnemyCardsSvr = self:IsPlayerAttacker() and SvrEnterRsp.DefenderCards or SvrEnterRsp.AttackerCards

    local _playerWeakValue = 0
    local _enemyWeakValue = 0

    Log.I(" Cards in hand：")
    for i = 1, LocalDef.CardCountInGroup do
        -- 自己
        self.PlayerCardVMList[i]:ResetData(PlayerCardVMListSvr[i].CardID)
        self.PlayerCardVMList[i]:SetChangePoint(PlayerCardVMListSvr[i].Change)
        self.PlayerCardVMList[i]:SetIsPlayerCard(true)
        self.PlayerCardVMList[i]:SetExpose(true)
        _playerWeakValue = PlayerCardVMListSvr[i].ScoreChange
        if (_playerWeakValue and _playerWeakValue ~= 0) then
            self.PlayerCardVMList[i]:SetTournamentWeaken(_playerWeakValue)
        end

        -- 对方
        self.OpponentCardVMList[i]:ResetData(EnemyCardsSvr[i].CardID)
        local _showExpose = GameRuleService:HasRule(RuleDef.FANTASY_CARD_RULE_EXPOSE_ALL) or EnemyCardsSvr[i].IsExposed
        self.OpponentCardVMList[i]:SetExpose(_showExpose)
        self.OpponentCardVMList[i]:SetChangePoint(EnemyCardsSvr[i].Change)
        _enemyWeakValue = EnemyCardsSvr[i].ScoreChange
        if (_enemyWeakValue and _enemyWeakValue ~= 0) then
            self.OpponentCardVMList[i]:SetTournamentWeaken(_enemyWeakValue)
        end

        Log.I("  - PlayerCard[%d] id [%s]", i, PlayerCardVMListSvr[i].CardID)
        Log.I("  - NpcCard[%d]    id [%s] SrvIsExposed [%s]", i, EnemyCardsSvr[i].CardID, EnemyCardsSvr[i].IsExposed)
    end

    if (_playerWeakValue ~= 0) then
        _G.FLOG_INFO("大赛弱化，玩家弱化数值为："..tostring(_playerWeakValue))
        _G.MsgTipsUtil.ShowTips(_G.LSTR(LocalDef.UKeyConfig.WeakEffectPlayer))
    end

    if (_enemyWeakValue ~= 0) then
        _G.FLOG_INFO("大赛弱化，对手弱化数值为："..tostring(_enemyWeakValue))
        _G.MsgTipsUtil.ShowTips(_G.LSTR(LocalDef.UKeyConfig.WeakEffectOpponent))
    end

    Log.I(" Cards in hand：")
    for i = 1, 5 do
        self.PlayerCardVMList[i]:ResetData(PlayerCardVMListSvr[i].CardID)
        self.PlayerCardVMList[i]:SetInGamePlayerMode(false)
        self.PlayerCardVMList[i]:SetIsPlayerCard(true)
        self.PlayerCardVMList[i]:SetExpose(true)
        self.OpponentCardVMList[i]:ResetData(EnemyCardsSvr[i].CardID)
        self.OpponentCardVMList[i]:SetInGameEnemyMode()
        local _showExpose = GameRuleService:HasRule(RuleDef.FANTASY_CARD_RULE_EXPOSE_ALL) or EnemyCardsSvr[i].IsExposed
        self.OpponentCardVMList[i]:SetExpose(_showExpose)
        Log.I("  - PlayerCard[%d] id [%s]", i, PlayerCardVMListSvr[i].CardID)
        Log.I("  - NpcCard[%d]    id [%s] SrvIsExposed [%s]", i, EnemyCardsSvr[i].CardID, EnemyCardsSvr[i].IsExposed)
    end

    -- 牌桌
    for i = 1, 9 do
        self.OnBoardCardVMList[i]:ResetData()
    end
end

--- func desc
---@param SvrNewMoveRsp FantasyCardNewMoveRsp
---@param IsFromDelay bool
function InGameService:OnNewMoveRsp(SvrNewMoveRsp, IsFromDelay)
    if (SvrNewMoveRsp == nil) then
        _G.FLOG_ERROR("OnNewMoveRsp 但是消息为空，请检查")
        return
    end

    if (SvrNewMoveRsp.Card == nil) then
        _G.FLOG_ERROR("服务器下发的数据中  Card 为空，请检查")
        return
    end

    if (self.CardGameId ~= nil and self.CardGameId ~= SvrNewMoveRsp.CardGameID) then
        _G.FLOG_ERROR(
            string.format(
                "错误，本地的GameID:[%s] ， 服务器下发的GameID:[%s] 不匹配，请检查",
                self.CardGameId,
                SvrNewMoveRsp.CardGameID
            )
        )
        return
    end

    -- 这里得看一下，服务器在做幻卡大赛的时候，取消了等待客户端上传准备好ReadyForNewMove的协议
    -- 因此，如果服务器下发的行动回合，不是当前角色的行动回合，那么就先存起来，等客户端的表现完成后，再继续打牌
    self.HasSentAutoPlay = false
    if (IsFromDelay) then
        -- 这里做一下检测
        if (self.IsHandlingNewMove) then
            _G.FLOG_INFO(
                "准备处理一个服务器的DELAY MOVE，但是当前有正在处理的MOVE，重新等待一下"
            )

            if (self.NewSvrNewMoveRsp ~= nil) then
                Async.BeginTask(self.AsyncPostProcessForServerNewMove, self)
            end

            return false
        else
            self.NewMoveFantasyCardInfo = SvrNewMoveRsp.Card
            self.ChosedBoardLoc = SvrNewMoveRsp.Card.BoardLoc + 1
            self.ChosedCardIndex = SvrNewMoveRsp.PlaceCard + 1

            _G.FLOG_INFO(
                string.format(
                    "处理延迟播放 3，GameID:【%s】，本地回合：[%s], 服务器回合：【%s】，是否玩家出牌：【%s】，牌在手上index：【%s】，下到棋盘index：【%s】",
                    SvrNewMoveRsp.CardGameID, self.CurrentRound, SvrNewMoveRsp.Round, self.IsPlayerCurrentMove, SvrNewMoveRsp.PlaceCard,
                    SvrNewMoveRsp.Card.BoardLoc
                )
            )
            self.IsGameFinishedAfterThisMove = SvrNewMoveRsp.IsFinished
            self.MoveHandle.SetMoveRsp(SvrNewMoveRsp)
            self:TryProcessForMove()
        end
    else
        FLOG_INFO(string.format("【恢复牌局】收到出牌回复，自动出牌重置"))
        if (self.IsHandlingNewMove) then
            if(self.CurrentRound + 1 == SvrNewMoveRsp.Round) then
                self.NewSvrNewMoveRsp = SvrNewMoveRsp
                _G.FLOG_INFO(
                    string.format(
                        "++++++ 收到服务器消息，本地还在播放效果，本地 Round : [%s] 服务器 Round : [%s]，稍后播放",
                        self.CurrentRound,
                        SvrNewMoveRsp.Round
                    )
                )
            elseif (self.CurrentRound == SvrNewMoveRsp.Round) then
                if (self.IsPlayerCurrentMove and self.NewMoveFlipEffect == nil) then
                    _G.FLOG_INFO(
                        string.format(
                            "玩家出牌收到回复 1，GameID:【%s】，本地回合：[%s], 服务器回合：【%s】，是否玩家出牌：【%s】，牌在手上index：【%s】，下到棋盘index：【%s】",
                            SvrNewMoveRsp.CardGameID, self.CurrentRound, SvrNewMoveRsp.Round, self.IsPlayerCurrentMove, SvrNewMoveRsp.PlaceCard,
                            SvrNewMoveRsp.Card.BoardLoc
                        )
                    )
                    self.NewMoveFantasyCardInfo = SvrNewMoveRsp.Card
                    self.ChosedBoardLoc = SvrNewMoveRsp.Card.BoardLoc + 1
                    self.ChosedCardIndex = SvrNewMoveRsp.PlaceCard + 1
                    self.IsGameFinishedAfterThisMove = SvrNewMoveRsp.IsFinished
                    self.MoveHandle.SetMoveRsp(SvrNewMoveRsp)
                    self:TryProcessForMove()
                else
                    _G.FLOG_INFO(
                        string.format(
                            "!!!!!服务器下发重复轮次信息，轮次是：[%s] ，出牌 index：[%s], 棋盘index:[%s] ",
                            SvrNewMoveRsp.Round,
                            SvrNewMoveRsp.PlaceCard,
                            SvrNewMoveRsp.Card.BoardLoc
                        )
                    )
                end
            end
        else
            _G.FLOG_INFO(
                string.format(
                    "收到出牌回复 2，GameID:【%s】，本地回合：[%s], 服务器回合：【%s】，是否玩家出牌：【%s】，牌在手上index：【%s】，下到棋盘index：【%s】",
                    SvrNewMoveRsp.CardGameID, self.CurrentRound, SvrNewMoveRsp.Round, self.IsPlayerCurrentMove, SvrNewMoveRsp.PlaceCard,
                    SvrNewMoveRsp.Card.BoardLoc
                )
            )
            self.NewMoveFantasyCardInfo = SvrNewMoveRsp.Card
            self.ChosedBoardLoc = SvrNewMoveRsp.Card.BoardLoc + 1
            self.ChosedCardIndex = SvrNewMoveRsp.PlaceCard + 1
            self.IsGameFinishedAfterThisMove = SvrNewMoveRsp.IsFinished
            self.MoveHandle.SetMoveRsp(SvrNewMoveRsp)
            self:TryProcessForMove()
        end
    end

    return true
end

function InGameService:OnPlayerChooseBoardPos()
    self:TryProcessForMove()
end

function InGameService:IsPlayerAttacker()
    return self.PlayerCardGroup == GroupAttack
end

function InGameService:SetGameRules(SvrEnterRsp)
    -- 局内将流行规则和本地规则合并显示
    local Rules = table.shallowcopy(SvrEnterRsp.Rules)
    for _, R in ipairs(SvrEnterRsp.PopularRules) do
        table.insert(Rules, R)
    end
    GameRuleService:SetGameRules(Rules)

    -- set associated data based on rule
    -- “秩序/混乱”规则
    if SvrEnterRsp.CardsPlayOrder and #SvrEnterRsp.CardsPlayOrder ~= 0 then
        self.HaveOrder = true
        local DumpStr = nil
        for _, o in ipairs(SvrEnterRsp.CardsPlayOrder) do
            table.insert(self.ImposedCardPlayOrder, o)
            DumpStr = DumpStr and string.format("%s, %d", DumpStr, o) or tostring(o)
        end
        Log.I(" [秩序/混乱规则]下玩家出牌顺序: [%s]", DumpStr)
    else
        self.HaveOrder = false
    end

    -- "交换"规则
    if GameRuleService:HasRule(RuleDef.FANTASY_CARD_RULE_EXCHANGE) then
        if SvrEnterRsp.AttackerExchange and SvrEnterRsp.AttackerExchange >= 0 and SvrEnterRsp.DefenderExchange and
            SvrEnterRsp.DefenderExchange >= 0 then
            Log.I(
                " [交换规则] AttackerExchange [%d], DefenderExchange [%d]", SvrEnterRsp.AttackerExchange,
                SvrEnterRsp.DefenderExchange
            )
        else
            Log.E(
                " [交换规则]没有下发交换卡牌信息! 消息中的AttackerExchange [%s], DefenderExchange [%s]",
                SvrEnterRsp.AttackerExchange, SvrEnterRsp.DefenderExchange
            )
        end
    end
end

function InGameService:EndForThisMove()
    self.IsHandlingNewMove = false
    self:InternalHandleLongtimeIdle()
    -- Utils.DelayNextFrame(
    --     function()s
            if not self.IsGameFinishedAfterThisMove then
                self:ReadyForNewMove(true)
            else
                MagicCardMgr:SendFinishFantasyCard()
            end
    --     end
    -- )
end

function InGameService:EndGame()
    Log.I("EndGame: stop timerformove just in case")
    self.NewSvrNewMoveRsp = nil
    self:StopForTimeCountdown()
    self.CurrentRound = 1
    ActorAnimService:OnGameEnd()
end

function InGameService:OnGameDoStart(IsRecover)
    self.LongTimeIdleCardCount = ActorAnimService.GetNpcAnimCond(NpcAnimEnum.Anim_InGame_Impatient)

    if (self.HaveOrder) then
        -- 玩家的牌先全部禁用
        for i = 1, #self.PlayerCardVMList do
            self.PlayerCardVMList[i]:SetIsDisabled(true)
        end
    end

    self.IsGameRealStart = true
    self:ReadyForNewMove(IsRecover, IsRecover)
end

function InGameService:InternalResetBeforeNewMove()
    self.IsGameFinishedAfterThisMove = false
    self.NewMoveFlipEffect = nil
    self.PlayCardHandled = false
    self.ChosedBoardLoc = -1
    self.ChosedCardIndex = -1
    self.IsHandlingNewMove = false
    self.NewMoveFantasyCardInfo = nil
end

function InGameService:CalculateIsPlayerCurrentMove()
    if(self:IsPlayerAttacker()) then
        return self.CurrentRound % 2 == 1
    else
        return self.CurrentRound % 2 == 0
    end
end

function InGameService:ReadyForNewMove(TickToNextRound, IsRecover)
    if (TickToNextRound) then
        self.CurrentRound = self.CurrentRound  + 1
    end

    local _isPlayerMove = self:CalculateIsPlayerCurrentMove()

    if IsRecover then
        FLOG_INFO(string.format("【恢复牌局】当前回合数 %s：%s出牌，剩余出牌时间：%s", self.CurrentRound, _isPlayerMove and "玩家" or "对手", self.RemainActionTime or 0))
    end

    self.IsPlayerCurrentMove = _isPlayerMove
    self.Vm.IsPlayerMove = _isPlayerMove
    self.MoveHandle.Reset(_isPlayerMove)
    self:InternalResetBeforeNewMove(_isPlayerMove)
    if not self.IsPlayerCurrentMove and MagicCardMgr.IsPVP then
        self.RobotMoveDelay = MagicCardTourneyVMUtils.GetRobotMoveDelayTime()
    end

    local function OnReadyNewMove()
        -- 如果游戏在这里结束了，那么不计算
        if (MagicCardMgr.IsGameEnd) then
            return
        end
        EventMgr:SendEvent(EventID.MagicCardReadyNewMove)

        if not IsRecover then
            self.PassedTime = 0
            self.RemainActionTime = self:GetActualTimeOutForMove()
        end

        if self.TimerForMove ~= nil then
            self:StopForTimeCountdown()
        end
        local _timerMove = TimerMgr:AddTimer(self, self.OnTimerForNewMove, 0, 1, -1)
        self:SetTimerForMove(_timerMove)

        if (self.IsPlayerCurrentMove and self.ImposedCardPlayOrder) then
            -- 混乱/秩序规则处理
            --local NextAllowPlay = table.remove(self.ImposedCardPlayOrder, 1)
            local NextAllowPlay = self:GetNextAllowPlay()
            if (NextAllowPlay) then
                --local _luaIndex = NextAllowPlay + 1
                for i = 1, #self.PlayerCardVMList do
                    local CardVm = self.PlayerCardVMList[i]
                    CardVm:SetIsDisabled(i ~= NextAllowPlay)
                end
            else
                for i = 1, #self.PlayerCardVMList do
                    local CardVm = self.PlayerCardVMList[i]
                    CardVm:SetIsDisabled(false)
                end
            end
        end
    end

    -- show new turn
    if (self.CurrentRound <= 9) then
        EventMgr:SendEvent(EventID.MagicCardShowNewTurn, self.IsPlayerCurrentMove, OnReadyNewMove)
    else
        MagicCardMgr:SendFinishFantasyCard() -- 此时已经结束了，请求结束用于显示结算界面
    end
end

function InGameService:GetNextAllowPlay()
    for _, OrderIndex in ipairs(self.ImposedCardPlayOrder) do
        local _luaIndex = OrderIndex + 1
        local CardVm = self.PlayerCardVMList[_luaIndex]
        -- 重连时在手上剩余的牌 并且未打出去
        if CardVm.Active and not CardVm.IsPlayed then
            return _luaIndex
        end
    end
end

function InGameService:SetTimerForMove(TargetTimer)
    self.TimerForMove = TargetTimer
end

function InGameService:StopForTimeCountdown()
    if self.TimerForMove == nil then
        return
    end
    TimerMgr:CancelTimer(self.TimerForMove)
    self:SetTimerForMove(nil)
    if self.CountDownSoundEffectPlayed then
        Log.I("停止播放倒计时音效")
        AudioUtil.LoadAndPlayUISound(self.StopCountDown_SoundEffectStr)
        self.CountDownSoundEffectPlayed = nil
    end
end

function InGameService:TryProcessForMove()
    if self.NewMoveFlipEffect ~= nil then
        if self.IsPlayerCurrentMove and not self.PlayCardHandled then
            Log.I("玩家出牌超时！")
            local _localTimeCount = self.RemainActionTime
            if (_localTimeCount > 5) then
                _G.FLOG_ERROR(
                    "错误，玩家出牌，本地倒计时还有 " .. tostring(_localTimeCount) ..
                        ", 服务器就下发下一步，请检查"
                )
            end
        end
    end

    if not self.IsHandlingNewMove or self.PlayerPutCardWaitForServerData then
        self.IsHandlingNewMove = true
        self.PlayerPutCardWaitForServerData = false
        Async.BeginTask(self.HandleNewMoveAsync, self)
    end
end

function InGameService:HandleNewMoveAsync()
    self:HandlePlayCardAsync()

    if self.PlayCardHandled and self.NewMoveFlipEffect then
        self:HandleUpdateCardBoardAsync()
    else
        self:InternalEndHandleNewMoveAsync(false)
    end
end

function InGameService:HandlePlayCardAsync()
    if self.PlayCardHandled then
        return
    end

    self:StopForTimeCountdown()

    Log.I("Begin HandlePlayCard")
    self.PlayCardHandled = true
    self.Vm.CardNameIndexForSelf = 0
    self.Vm.CardNameIndexForOther = 0
    -- PlayCard ActorAnimation
    if self.IsPlayerCurrentMove then
        ActorAnimService:PlayMajorAnimByEnum(MajorAnimEnum.Major_PlayCard_Normal, false)
        Log.I("玩家落牌动作")
    else
        if (Log.Check(self.NewMoveFlipEffect, "Must receive NetNewMoveRsp when handling npc move!")) then
            Log.I("Npc落牌动做")
            -- npc play card anim
            local _, NpcFlipped = self.NewMoveFlipEffect:GetFlipCardNumForPcAndNpc()
            local TimeForPlayActorAnim = ActorAnimService:PlayNpcPlayCardAnim(
                                             self.NewMoveFlipEffect:GetComboNum(), NpcFlipped
                                         )
            Log.I(" - wait [%s]s for npc play card anim finish", TimeForPlayActorAnim)
            Utils.DelayAsync(TimeForPlayActorAnim)
            -- player出牌时通过点击有put音效，npc需要在收到回包是播放
            EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, LocalDef.ClickSoundEffectEnum.Put)
        end
    end

    Log.I("PlayCard UI update")
    EventMgr:SendEvent(EventID.MagicCardDoPlayOneCard)

    -- npc出牌时，角色落牌动作和界面表现是先后进行的，延迟读取配置的UI延时即可；
    -- 玩家出牌时，角色落牌动作和界面表现是同时的，这时候需要延迟两者中较长的那个
    local DelayTimeForUIPlayCardTime = LocalDef.UIPlayCardTime
    if self.IsPlayerCurrentMove then
        DelayTimeForUIPlayCardTime = math.max(ActorAnimService.MajorPlayCardAnimTime, LocalDef.UIPlayCardTime)
    end
    Log.I(" - wait [%s]s for PlayCard UI", DelayTimeForUIPlayCardTime)
    Utils.DelayAsync(DelayTimeForUIPlayCardTime)
end

---@param RuleEffects OneRuleEffect[]
---@param FlipCards OneFlippedCard[]
function InGameService:HandleRuleAndFlipAsync(RuleEffects, FlipCards)
    if not Log.Check(RuleEffects and FlipCards, "HandleRuleAndFlipAsync") then
        return
    end

    -- 显示规则
    for _, Rule in ipairs(RuleEffects) do
        if Rule.RuleId ~= 0 then
            EventMgr:SendEvent(EventID.MagicCardShowRuleEffect, Rule)
            Log.I(
                "显示规则效果：[%s], 用时[%s]s", GameRuleService.GetRuleName(Rule.RuleId),
                LocalDef.DelayTimeForOneRuleEffect
            )
            Utils.DelayAsync(LocalDef.DelayTimeForOneRuleEffect)
        end
    end

    -- 显示翻的牌
    if #FlipCards > 0 then
        -- 这里播放一次翻牌的声音就可以了 TODO
        AudioUtil.LoadAndPlayUISound(self.BattleFlipCard_SoundEffectStr)
        local HasSpecialRule = false
        for _, Card in ipairs(FlipCards) do
            local BoardCard = self.OnBoardCardVMList[Card.BoardLoc]
            if Card.CardId == 0 then
                BoardCard:SetIsPlayed(false)
            else
                BoardCard:SetCardId(Card.CardId)
                if Card.FlipType > 0 then
                    BoardCard:SetFlipType(Card.FlipType)
                end
                Log.I("翻牌：牌桌上第[%s]张", Card.BoardLoc)
                if Card.IsFlipBySpecialRule then
                    HasSpecialRule = true
                end
            end
        end

        local DelayTimeForFlipCard = LocalDef.DelayTimeForFlipCard
        Utils.DelayAsync(LocalDef.DelayTimeForFlipCard)
        -- 翻牌结束后再设置牌归属
        for _, Card in ipairs(FlipCards) do
            local BoardCard = self.OnBoardCardVMList[Card.BoardLoc]
            if Card.CardId == 0 then
                BoardCard:SetIsPlayed(false)
            else
                BoardCard:SetIsPlayerCard(Card.IsPlayerCard)
                BoardCard:SetIsPlayed(true)
            end
        end

        if HasSpecialRule then
            Log.I("特殊规则（加算同数连携），需要在翻牌后额外表现牌桌及卡牌效果")
            EventMgr:SendEvent(EventID.MagicCardShowBoardEffectForSpecialRule, FlipCards)
            DelayTimeForFlipCard = DelayTimeForFlipCard + LocalDef.DelayTimeForFlipCard
            Utils.DelayAsync(LocalDef.DelayTimeForFlipCard)
        end

        Log.I("翻牌表现共等待 [%s]", DelayTimeForFlipCard)
    end

    self.Vm:UpdateScore()
end

function InGameService:InternalHandleLongtimeIdle()
    -- 这里根据桌面的牌数量，播放新的待机动作
    local Cards = self.OnBoardCardVMList
    local playedCardCount = 0
    for i = 1, #Cards do
        if (Cards[i]:GetCardId() > 0) then
            playedCardCount= playedCardCount+1
        end
    end

    if (playedCardCount >= self.LongTimeIdleCardCount and not self.HavePlayLongtimeIdle) then
        self.HavePlayLongtimeIdle = true
        _G.FLOG_INFO("播放长时间IDLE动作")
        ActorAnimService:PlayNpcAnimByEnum(NpcAnimEnum.Anim_InGame_Impatient)
    end
end

function InGameService:HandleUpdateCardBoardAsync()
    if (self.NewMoveFantasyCardInfo ~= nil) then
        local Cards = self.OnBoardCardVMList
        local _cardVM = Cards[self.NewMoveFantasyCardInfo.BoardLoc + 1]
        if (self.NewMoveFantasyCardInfo.Change ~= nil) then
            _cardVM:SetChangePoint(self.NewMoveFantasyCardInfo.Change)
        end

        if (self.NewMoveFantasyCardInfo.ScoreChange ~= nil) then
            _cardVM:SetTournamentWeaken(self.NewMoveFantasyCardInfo.ScoreChange)
        end
    end

    if self.NewMoveFlipEffect:IsMoveEffectEmpty() then
        Log.I("本轮无事发生，延迟[%s]s后结束", LocalDef.DelayTimeForEmptyMoveEffect)
        Utils.DelayAsync(LocalDef.DelayTimeForEmptyMoveEffect)
    else
        -- 规则
        local AllRuleEffect = self.NewMoveFlipEffect.RuleEffect
        self:HandleRuleAndFlipAsync(AllRuleEffect.RuleEffects, AllRuleEffect.FlipCards)

        -- 连携
        local ComboEffects = self.NewMoveFlipEffect.ComboEffects
        local AnimBeginTime = TimeUtil.GetLocalTimeMS()
        local IsNpcComboAnimTriggered, TimeForPlayComboAnim = ActorAnimService:PlayNpcComboAnim(#ComboEffects, self.IsPlayerCurrentMove)

        for _, ComboEffect in ipairs(ComboEffects) do
            if ComboEffect.AceKillerEffect then
                self:HandleRuleAndFlipAsync(
                    {
                        ComboEffect.AceKillerEffect
                    }, {}
                )
            end

            self:HandleRuleAndFlipAsync(
                {
                    ComboEffect.ComboFlipEffect
                }, ComboEffect.FilpCards
            )
        end

        if IsNpcComboAnimTriggered then
            -- 连携触发的npc动画和ui表现同时播放。ui表现完后，可能动画时长还没到。这里需要检查并做延迟
            local PassedTime = TimeUtil.GetLocalTimeMS() - AnimBeginTime
            if PassedTime < TimeForPlayComboAnim then
                Utils.DelayAsync(TimeForPlayComboAnim - PassedTime)
            end
        else
            -- 没有触发combo，还需要检查是否根据比分触发表情动作
            local TimeForPlayNpcScoreAnim
            if not self.IsPlayedNpcEmoLeading then
                self.IsPlayedNpcEmoLeading, TimeForPlayNpcScoreAnim =
                    ActorAnimService:PlayNpcScoreAnim(
                        true, self.Vm.OpponentScore
                    )
            end

            if not self.IsPlayedNpcEmoBehind then
                self.IsPlayedNpcEmoBehind, TimeForPlayNpcScoreAnim =
                    ActorAnimService:PlayNpcScoreAnim(
                        false, self.Vm.OpponentScore
                    )
            end

            if TimeForPlayNpcScoreAnim and TimeForPlayNpcScoreAnim > 0 then
                Utils.DelayAsync(TimeForPlayNpcScoreAnim)
            end
        end

        -- 强化/弱化：
        local ChangedEffect = self.NewMoveFlipEffect.RuleEffect.ChangedEffect
        if ChangedEffect then
            EventMgr:SendEvent(EventID.MagicCardShowRuleEffect, ChangedEffect.RuleEffect)
            Log.I("强化弱化, 用时[%s]s", LocalDef.DelayTimeForOneRuleEffect)
            Utils.DelayAsync(LocalDef.DelayTimeForOneRuleEffect)

            for _, Card in ipairs(ChangedEffect.ChangedCards) do
                local Cards = self.OnBoardCardVMList
                if Card.IsOnHandCard then
                    Cards = Card.IsPlayerCard and self.PlayerCardVMList or self.OpponentCardVMList
                end
                local CardVm = Cards[Card.Loc]
                if Log.Check(CardVm, "强化弱化卡牌位置错误[%d]", Card.Loc) then
                    CardVm:SetChangePoint(Card.Change)
                end
            end
            Utils.DelayAsync(LocalDef.DelayTimeForChangePoint)
        end
    end
    self:InternalEndHandleNewMoveAsync(true)
end

function InGameService:InternalEndHandleNewMoveAsync(AllDone)
    if not AllDone then
        _G.FLOG_INFO("未全部处理完，只处理了玩家移动,服务器消息未及时下发，下次下发的时候处理后续内容")
        self.PlayerPutCardWaitForServerData = true
        return
    end

    self.PlayerPutCardWaitForServerData = false

    self:EndForThisMove()

    if (self.NewSvrNewMoveRsp ~= nil) then
        Async.BeginTask(self.AsyncPostProcessForServerNewMove, self)
    end
end

function InGameService:AsyncPostProcessForServerNewMove()
    _G.FLOG_INFO(
        string.format(
            "有从服务器下发的下一步数据，延迟[%d]秒处理", LocalDef.DelayTimeForServerData
        )
    )
    Utils.DelayAsync(LocalDef.DelayTimeForServerData)
    if (self:OnNewMoveRsp(self.NewSvrNewMoveRsp, true)) then
        self.NewSvrNewMoveRsp = nil
    end
end

function InGameService:TimeOverCountChooseRandomCard()
end

function InGameService:OnTimerForNewMove()
    -- update timer
    EventMgr:SendEvent(EventID.MagicCardUpdateTimer, self.RemainActionTime)
    local TotalTimeForOneMove = self:GetActualTimeOutForMove()
    local _timeLeft = self.RemainActionTime

    if _timeLeft <= 5 and not self.CountDownSoundEffectPlayed then
        Log.I("剩5s时播放倒计时音效")
        self.CountDownSoundEffectPlayed = true
        AudioUtil.LoadAndPlayUISound(self.BeginCountDown_SoundEffectStr)
    end
    
    if self.HasSentAutoPlay then
        FLOG_INFO(string.format("【恢复牌局】已发送自动出牌，等待回包:%s", _timeLeft))
        self:StopForTimeCountdown()
        return
    end

    self.PassedTime = TotalTimeForOneMove - self.RemainActionTime
    
    -- 本地玩家出牌
    if self.IsPlayerCurrentMove then
        -- 自动出牌
        if (_timeLeft <= 0) then
            self.HasSentAutoPlay = true
            FLOG_INFO(string.format("【恢复牌局】玩家自动出牌:%s", _timeLeft))
            MagicCardMgr:SendNewMoveReq(-1, -1, true, self.CurrentRound)
        end
        FLOG_INFO(string.format("【恢复牌局】玩家出牌回合计时:%s", _timeLeft))
    elseif MagicCardMgr:IsPVPMode() then -- PVP模式
        -- PVP的机器人，则由客户端发起出牌，时间随机。（服务端保底，达到最大时间时客户端未发起时，服务端自动出牌)
        if MagicCardMgr:IsPVPRobotMode() then
            if (self.PassedTime >= self.RobotMoveDelay or self.CurrentRound == 9) then
                self.HasSentAutoPlay = true
                FLOG_INFO(string.format("【恢复牌局】机器人对手自动出牌:%s", _timeLeft))
                MagicCardMgr:SendNewMoveReq(-1, -1, true, self.CurrentRound)
            end
        end
        FLOG_INFO(string.format("【恢复牌局】PVP对手出牌回合计时:%s", _timeLeft))
    else
        -- 这里是纯NPC，走另一个计时数量
        FLOG_INFO(string.format("【恢复牌局】NPC对手出牌回合计时:%s", _timeLeft))
        if (self.PassedTime >= LocalDef.NPCPutCardDelayTime) then
            self.HasSentAutoPlay = true
            FLOG_INFO(string.format("【恢复牌局】NPC对手自动出牌:%s", _timeLeft))
            MagicCardMgr:SendNewMoveReq(-1, -1, true, self.CurrentRound)
        end
    end

    self.RemainActionTime = self.RemainActionTime - 1
end

---@type 获取实际的出牌时间限制
function InGameService:GetActualTimeOutForMove()
    if self.IsPlayerCurrentMove then
        return MagicCardTourneyMgr:GetPlayerTimeOutForMove() -- 如果有大赛限时效果，则返回限时时间，否则返回正常出牌时间
    else
        return LocalDef.TotalTimeForOneMove
    end
end

return InGameService
