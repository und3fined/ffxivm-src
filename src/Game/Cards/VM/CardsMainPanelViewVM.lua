--
-- Author: MichaelYang_LightPaw
-- Date: 2023-11-14 11:18
-- Description:
--
-- 全局的ViewModel需要在UIViewModelConfig中配置, 具体说明参考下面wiki
-- https://iwiki.woa.com/pages/viewpage.action?pageId=1066338863
-- ViewModel是用来存储UI需要显示的数据，尽量不要处理和UI显示无关的逻辑。
-- ViewModel中数据变化时，会调用绑定Binder的OnValueChanged函数来更新UI。
-- UIViewModel所有成员变量都会创建为UIBindableProperty，所以UIViewModel不应该包含非UI要显示的属性。
-- UIViewModel包含一个BindableProperties列表，Key值是PropertyName，Value值是UIBindableProperty
-- 使用类变量时和普通变量一样使用，UIViewModel会自动创建UIBindableProperty
-- 更多UIViewModel介绍请参考下面wiki
-- https://iwiki.woa.com/pages/viewpage.action?pageId=858296043
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local InGameSrvClass = require("Game/MagicCard/Module/InGameService")
local CardsSingleCardVM = require("Game/Cards/VM/CardsSingleCardVM")
local CardsSingleCardOnBoardVM = require("Game/Cards/VM/CardsSingleCardOnBoardVM")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local MagicCardLocalDef = require("Game/MagicCard/MagicCardLocalDef")
local AudioUtil = require("Utils/AudioUtil")
local ClickSoundEffectEnum = MagicCardLocalDef.ClickSoundEffectEnum
local InGameSrv = nil ---@class InGameService
local MagicCardMgr = nil ---@class MagicCardMgr
local GameRuleService = nil ---@class GameRuleService
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender
local LSTR = _G.LSTR
local RuleDef = ProtoRes.Game.fantasy_card_rule
local CardTypeEnum = LocalDef.CardItemType
local CardItemType = LocalDef.CardItemType
local EventMgr = _G.EventMgr

---@class CardsMainPanelViewVM : UIViewModel
local CardsMainPanelViewVM = LuaClass(UIViewModel)

---Ctor
function CardsMainPanelViewVM:Ctor()
    MagicCardMgr = _G.MagicCardMgr
    GameRuleService = MagicCardMgr:GetRuleService()

    --- 这个是拖拽的
    self.DragVisualCardVM = nil
    self.DragVisualCardItemView = nil
    self.CurrentDragCardVM = nil
    self.CardNameIndex = 0 -- 显示横向的名字，1表示玩家的左边第一个，-1表示对手的左边第一个
    self.CurrentClickVM = nil -- 当前点击的VM
    -- 这里要取消一下名字显示相关
    self.CardNameIndexForSelf = 0
    self.CardNameOddOrEvenForSelf = 1 -- 1表示奇数 0 表示偶数
    self.CardNameIndexForOther = 0
    self.CardNameOddOrEvenForOther = 1 -- 1表示奇数，0 表示偶数

    -- 是否进入游戏了，现在有用到了 lua 的 coroutine来播放效果，但是中途可能排副本排到了，因为不确定性，需要这个做个多重判断
    self.IsEnterGame = false
end

function CardsMainPanelViewVM:GetDragVisualCardItemView()
    return self.DragVisualCardItemView
end

---@return RuleConfig[]
function CardsMainPanelViewVM:GetAllRulesToShow()
    local Rules, CurrentIndex = {}, 1
    if GameRuleService.GameRules then
        for _, Rule in ipairs(GameRuleService.GameRules) do
            if Rule.IsShowInBegining == 1 then
                Rules[CurrentIndex] = Rule
                CurrentIndex = CurrentIndex + 1
            end
        end
    end
    return Rules
end

function CardsMainPanelViewVM:DealCardTopNameOnBoard(TargetVM, IsShow)
    -- 这里判断一下index ，1-3显示下方
    local _index = TargetVM:GetIndex()
    if (_index >= 1 and _index <= 3) then
        TargetVM:SetShowBottomName(IsShow)
    else
        TargetVM:SetShowTopName(IsShow)
    end
end

---@param TargetVM 目前是 CardsSingleCardVM
function CardsMainPanelViewVM:HandleCardClicked(TargetVM)
    if (TargetVM == nil) then
        return
    end

    if (self.CurrentClickVM ~= nil) then
        -- 如果当前点击的已经有了，那么不处理了，主要是处理多手指点击
        FLOG_INFO("[CardsMainPanelViewVM] 当前已选中卡牌，不再处理点击选中！")
        return
    end

    -- 处理鼠标按下
    if (TargetVM:GetIsExposed()) then
        self.CurrentClickVM = TargetVM
        local _cardType = TargetVM:GetCardType()
        if (_cardType == LocalDef.CardItemType.OnBoard) then
            self:DealCardTopNameOnBoard(TargetVM, true)
        elseif (_cardType == LocalDef.CardItemType.PlayerCard) then
            local _playedCount = 0
            local _targetIndex = TargetVM:GetIndex()
            local _realIndex = _targetIndex

            for i = 1, LocalDef.CardCountInGroup do
                if (self.PlayerCardVMList[i]:GetIsPlayed()) then
                    _playedCount = _playedCount + 1
                    if (i < _targetIndex) then
                        _realIndex = _realIndex - 1
                    end
                end
            end

            -- 获取当前是奇数还是偶数
            self.CardNameOddOrEvenForSelf = (LocalDef.CardCountInGroup - _playedCount) % 2
            if (self.CardNameOddOrEvenForSelf == 1) then
                if (_playedCount > 0) then
                    self.CardNameIndexForSelf = (_playedCount / 2) + _realIndex
                else
                    self.CardNameIndexForSelf = _realIndex
                end
            else
                if (_playedCount > 1) then
                    self.CardNameIndexForSelf = ((_playedCount - 1) / 2) + _realIndex
                else
                    self.CardNameIndexForSelf = _realIndex
                end
            end
        elseif (_cardType == LocalDef.CardItemType.OpponentCard) then
            -- 这里要取计算一下，到底显示哪个
            local _playedCount = 0
            local _targetIndex = TargetVM:GetIndex()
            local _realIndex = _targetIndex

            for i = 1, LocalDef.CardCountInGroup do
                if (self.OpponentCardVMList[i]:GetIsPlayed()) then
                    _playedCount = _playedCount + 1
                    if (i < _targetIndex) then
                        _realIndex = _realIndex - 1
                    end
                end
            end

            -- 获取当前是奇数还是偶数
            self.CardNameOddOrEvenForOther = (LocalDef.CardCountInGroup - _playedCount) % 2
            if (self.CardNameOddOrEvenForOther == 1) then
                if (_playedCount > 0) then
                    self.CardNameIndexForOther = (_playedCount / 2) + _realIndex
                else
                    self.CardNameIndexForOther = _realIndex
                end
            else
                if (_playedCount > 1) then
                    self.CardNameIndexForOther = ((_playedCount - 1) / 2) + _realIndex
                else
                    self.CardNameIndexForOther = _realIndex
                end
            end
        end
    end

    return true
end

function CardsMainPanelViewVM:GetDragVisualCardScale()
    return LocalDef.ScaleForCardInGame
end

function CardsMainPanelViewVM:OnDragEnter(TargetVM)
end

function CardsMainPanelViewVM:OnDragLeave(TargetVM)
end

function CardsMainPanelViewVM:OnDrop(DropOnCardItemVM)
    if (DropOnCardItemVM == nil) then
        _G.FLOG_ERROR("错误，传入的 DropOnCardItemVM 为空，请检查!")
        return
    end

    if (self.CurrentDragCardVM == nil) then
        _G.FLOG_ERROR("错误，self.CurrentDragCardVM 为空，请检查!")
        return
    end

    if (DropOnCardItemVM == self.CurrentDragCardVM) then
        self:OnDragCancelled()
        return
    end

    if (DropOnCardItemVM:GetIsPlayed()) then
        self:OnDragCancelled()
        return
    end

    local _dropType = DropOnCardItemVM:GetCardType()
    if (_dropType == LocalDef.CardItemType.OnBoard) then
        self:PlayerChooseBoardPos(DropOnCardItemVM:GetIndex())
    end

    -- 这里无论如何都直接取消，正常服务器会返回，然后做动画处理，但是如果返回错误的话，那就会在原地留一个空
    -- 因此这样做
    self:OnDragCancelled(nil, true)
end

function CardsMainPanelViewVM:IsPlayerAllowedMove()
    -- 玩家只能在timer启动后移动
    local _canDrag = InGameSrv.IsPlayerCurrentMove and InGameSrv.TimerForMove ~= nil and InGameSrv.IsHandlingNewMove ==
                         false

    return _canDrag
end

function CardsMainPanelViewVM:CancelLastChosedCard()
    if InGameSrv.ChosedCardIndex ~= -1 then
        -- self.PlayerCardVMList[InGameSrv.ChosedCardIndex].IsSelected = false
        InGameSrv.ChosedCardIndex = -1
    end
end

function CardsMainPanelViewVM:CanDrag(TargetCardVM)
    if (not self:IsPlayerAllowedMove()) then
        return false
    end
    if TargetCardVM:GetCardId() == 0 or TargetCardVM:GetIsDisable() then
        return false
    end

    local _dragCardType = TargetCardVM:GetCardType()
    if (_dragCardType == CardTypeEnum.PlayerCard) then
        return true
    end

    return false
end

function CardsMainPanelViewVM:PlayerChooseBoardPos(BoardPos)
    if not InGameSrv.IsPlayerCurrentMove then
        _G.FLOG_ERROR("PlayerChooseBoardPos error, not player move")
        return
    end
    if InGameSrv.ChosedCardIndex ~= -1 then
        InGameSrv.ChosedBoardLoc = BoardPos
        MagicCardMgr:SendNewMoveReq(InGameSrv.ChosedCardIndex, BoardPos, false, InGameSrv.CurrentRound)
        EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Put)
        InGameSrv:OnPlayerChooseBoardPos()
    else
        _G.FLOG_ERROR("错误，已经在拖动了，为什么没有选中卡牌？")
        self:OnDragCancelled(nil)
    end
end

function CardsMainPanelViewVM:PlayerChooseCard(CardIndex)
    if CardIndex == -1 then
        if InGameSrv.ChosedCardIndex ~= -1 then
            self:CancelLastChosedCard()
            EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Cancel)
        end
        return
    end

    if self:IsPlayerAllowedMove() then
        self:CancelLastChosedCard()
        InGameSrv.ChosedCardIndex = CardIndex
        EventMgr:SendEvent(EventID.MagicCardPlayCardClickSound, ClickSoundEffectEnum.Select)
    end
end

---@param TargeTVM CardsSingleCardVM
function CardsMainPanelViewVM:OnDragDetected(TargetVM)
    if (TargetVM == nil) then
        _G.FLOG_ERROR("错误，传入的 TargetVM 为空，请检查!")
        return
    end
    AudioUtil.LoadAndPlayUISound(self.BattleCardSelect_SoundEffectStr)
    TargetVM:SetIsShowCardRootPanel(false)
    self.CurrentDragCardVM = TargetVM
    self:PlayerChooseCard(self.CurrentDragCardVM:GetIndex())
end

function CardsMainPanelViewVM:HandleOnMouseLeave(TargetVM)
    if (TargetVM == nil) then
        return
    end

    if (self.CurrentClickVM == TargetVM) then
        local _cardType = TargetVM:GetCardType()
        if (_cardType == LocalDef.CardItemType.OnBoard) then
            self:DealCardTopNameOnBoard(TargetVM, false)
        elseif (_cardType == LocalDef.CardItemType.PlayerCard or _cardType == LocalDef.CardItemType.OpponentCard) then
            -- 这里要取消一下名字显示相关
            self.CardNameIndexForSelf = 0
            self.CardNameIndexForOther = 0
        end
        self.CurrentClickVM = nil
    end
end

function CardsMainPanelViewVM:ClearClickVM()
    self.CurrentClickVM = nil
end

function CardsMainPanelViewVM:GetDragVisualCardVM()
    return self.DragVisualCardVM
end

---@param TargetVM 目前是 CardsSingleCardVM
function CardsMainPanelViewVM:HandelCardMouseUp(TargetVM)
    if (TargetVM == nil) then
        return
    end

    if (self.CurrentClickVM == TargetVM) then
        if (TargetVM:GetCardType() == LocalDef.CardItemType.OnBoard) then
            self:DealCardTopNameOnBoard(TargetVM, false)
        end

        self.CurrentClickVM = nil
        -- 这里要取消一下名字显示相关
        self.CardNameIndexForSelf = 0
        self.CardNameIndexForOther = 0
    end
end

function CardsMainPanelViewVM:OnDragCancelled(TargetVM, IsPutOkCancel)
    if (self.DragVisualCardItemView ~= nil) then
        self.DragVisualCardItemView:HideView()
    end

    if (self.CurrentDragCardVM ~= nil) then
        self.CurrentDragCardVM:SetIsShowCardRootPanel(true)
        self.CurrentDragCardVM = nil
    end

    if (not IsPutOkCancel) then
        AudioUtil.LoadAndPlayUISound(self.BattleCancelDrag_SoundEffectStr)
    end

    self:PlayerChooseCard(-1)
end

--- func desc
---@param TargetCardVM CardsSingleCardVM
function CardsMainPanelViewVM:CanCardClick(TargetCardVM)
    return true
end

function CardsMainPanelViewVM:InitData()
    self.DragVisualCardVM = CardsSingleCardVM.New(self, -1, CardItemType.DragVisual)
    self.DragVisualCardVM:SetShowName(false)
    self.DragVisualCardVM:SetShowBottomName(false)
    self.DragVisualCardVM:SetShowTopName(false)
    self.PlayerCardVMList = {} -- 自己的卡牌
    self.OpponentCardVMList = {} -- 对面的卡牌
    self.OnBoardCardVMList = {} -- 已经打出的，在卡面上的卡牌
    self.DeskShowCardList = {} -- 表现先后手的卡牌
    self.IsPlayerMove = false -- 是否玩家的回合
    -- 这里要取消一下名字显示相关
    self.CardNameIndexForSelf = 0
    self.CardNameOddOrEvenForSelf = 0 -- 1表示奇数 2 表示偶数
    self.CardNameIndexForOther = 0
    self.CardNameOddOrEvenForOther = 0 -- 1表示奇数， 2 表示偶数

    InGameSrv = InGameSrvClass.New(self)

    -- 自己的
    for i = 1, 5 do
        self.PlayerCardVMList[i] = CardsSingleCardVM.New(self, i, CardItemType.PlayerCard)
        CardsSingleCardVM:SetIsPlayerCard(true)
        self.PlayerCardVMList[i]:SetShowName(false)
    end

    -- 对面的
    for i = 1, 5 do
        self.OpponentCardVMList[i] = CardsSingleCardVM.New(self, i, CardItemType.OpponentCard)
        self.OpponentCardVMList[i]:SetShowName(false)
    end

    -- 棋盘上的
    for i = 1, 9 do
        self.OnBoardCardVMList[i] = CardsSingleCardOnBoardVM.New(self, i, CardItemType.OnBoard)
    end

    -- 显示用的
    for i = 1, 3 do
        self.DeskShowCardList[i] = CardsSingleCardVM.New(self, i, CardItemType.ShowOnDeskAtBegining)
        self.DeskShowCardList[i]:SetShowName(false)
    end

    InGameSrv = InGameSrvClass.New(self)
    self:UpdateScore()
end

function CardsMainPanelViewVM:ResetData()
    -- 自己的
    for i = 1, 5 do
        self.PlayerCardVMList[i]:ResetData(0)
        self.PlayerCardVMList[i]:SetInGamePlayerMode(false)
    end

    -- 对面的
    for i = 1, 5 do
        self.OpponentCardVMList[i]:ResetData(0)
        self.OpponentCardVMList[i]:SetInGameEnemyMode()
    end

    -- 棋盘上的
    for i = 1, 9 do
        self.OnBoardCardVMList[i]:ResetData()
    end

    -- 显示先后手用的
    for i = 1, 3 do
        self.DeskShowCardList[i]:ResetData(0)
    end

    self.PlayerScore = LocalDef.DefaultPlayerScore
    self.OpponentScore = LocalDef.DefaultPlayerScore
end

function CardsMainPanelViewVM:OnGameStarted()
    if (not self.IsEnterGame) then
        _G.FLOG_WARNING("注意，准备正式开始游戏，但是游戏提前退出了")
        return
    end
    InGameSrv:OnGameDoStart()
end

--- 是否有全名牌或者三明牌规则
function CardsMainPanelViewVM:HasExposeCardRules()
    return GameRuleService:HasRule(RuleDef.FANTASY_CARD_RULE_EXPOSE_ALL, RuleDef.FANTASY_CARD_RULE_EXPOSE_THREE)
end

function CardsMainPanelViewVM:OnRecoverGameRsp(FantasyCardEnterRsp)
    InGameSrv:OnRecoverGame(FantasyCardEnterRsp)

    self.DragVisualCardVM:ResetData(0)
    self.DragVisualCardVM:SetInGamePlayerMode(true)
    self.DragVisualCardVM:SetExpose(true)
end

function CardsMainPanelViewVM:OnEnterGameRsp(FantasyCardEnterRsp)
    self.IsEnterGame = true
    InGameSrv:OnEnterGame(FantasyCardEnterRsp)

    self.DragVisualCardVM:ResetData(0)
    self.DragVisualCardVM:SetInGamePlayerMode(true)
    self.DragVisualCardVM:SetExpose(true)

    -- 设置规则
    self.DisplayRuleTextList = MagicCardVMUtils.GetRuleTextList(GameRuleService.GameRules)
    -- 根据是否玩家先手，随机设置DeskShowPanel下的牌
    local NumCardForFirstHand = math.random(2, 3)
    for i, Card in ipairs(self.DeskShowCardList) do
        if i <= NumCardForFirstHand then
            Card:SetShowFirstOrSecond(InGameSrv.IsPlayerCurrentMove)
        else
            Card:SetShowFirstOrSecond(not InGameSrv.IsPlayerCurrentMove)
        end
    end
end

function CardsMainPanelViewVM:OnFinishGameRsp(GameFinishRsp)
    self.IsEnterGame = false
    InGameSrv:EndGame()
    if GameFinishRsp.ShouldRestart then
        MagicCardMgr:RestartGame(GameFinishRsp.CardGameID, false)
    else
        MagicCardMgr:EndGame(GameFinishRsp)
    end
end

function CardsMainPanelViewVM:UpdateScore()
    local PlayerScore = 0
    for i = 1, 9 do
        local BoardCard = self.OnBoardCardVMList[i]
        if BoardCard.CardId ~= 0 and BoardCard.IsPlayerCard then
            PlayerScore = PlayerScore + 1
        end
    end

    for i = 1, 5 do
        local PlayerCard = self.PlayerCardVMList[i]
        if not PlayerCard.IsPlayed then
            PlayerScore = PlayerScore + 1
        end
    end

    self.PlayerScore = PlayerScore
    self.OpponentScore = 10 - PlayerScore
end

function CardsMainPanelViewVM:GetInGameService()
    return InGameSrv
end

--- 是否在处理玩家或npc出牌
function CardsMainPanelViewVM:IsPlayingCard()
    return InGameSrv.NewMoveFlipEffect ~= nil
end

function CardsMainPanelViewVM:OnUserQuitGame()
    self.IsEnterGame = false
    self:OnDragCancelled(nil, false)
    InGameSrv:EndGame()
    MagicCardMgr:OnUserQuitGame()
    _G.UIViewMgr:HideView(_G.UIViewID.MagicCardMainPanel)
end

-- 要返回当前类
return CardsMainPanelViewVM


