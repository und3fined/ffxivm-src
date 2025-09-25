---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-11-13 20:36
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local CardsMainPanelViewVM = require("Game/Cards/VM/CardsMainPanelViewVM")
local Async = require("Game/MagicCard/Module/AsyncUtils")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ActorAnimService = require("Game/MagicCard/Module/ActorAnimService")
local EventID = require("Define/EventID")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local AudioUtil = require("Utils/AudioUtil")
local FMath = _G.UE.UMathUtil
local RuleEnum = ProtoRes.Game.fantasy_card_rule
local NpcAnimEnum = ProtoRes.fantasy_card_npc_anim_enum
local MajorAnimEnum = ProtoRes.fantasy_card_major_anim_enum
local LSTR = _G.LSTR
local MagicCardMgr = _G.MagicCardMgr
local HUDMgr = _G.HUDMgr
local FlipTypeEnum = ProtoCS.FLIP_MOVEMENT
local InGameService = nil ---@class InGameService
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr
local FLOG_INFO = _G.FLOG_INFO
local MainPanelVM = require("Game/Main/MainPanelVM")

---@class CardsMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BluePanel UFCanvasPanel
---@field BluePanelEven UFCanvasPanel
---@field BluePanelEven01 CardsBigCardItemView
---@field BluePanelEven02 CardsBigCardItemView
---@field BluePanelEven03 CardsBigCardItemView
---@field BluePanelEven04 CardsBigCardItemView
---@field BluePanelForCardname UFCanvasPanel
---@field BluePanelForCardnameEven UFCanvasPanel
---@field BtnClose CommonCloseBtnView
---@field CardFirst01 CardsBigCardItemView
---@field CardFirst02 CardsBigCardItemView
---@field CardFirst03 CardsBigCardItemView
---@field CardSlot01 Cards3CornersItemView
---@field CardSlot02 Cards4CornersItemView
---@field CardSlot03 Cards3CornersItemView
---@field CardSlot04 Cards4CornersItemView
---@field CardSlot05 Cards4CornersItemView
---@field CardSlot06 Cards4CornersItemView
---@field CardSlot07 Cards3CornersItemView
---@field CardSlot08 Cards4CornersItemView
---@field CardSlot09 Cards3CornersItemView
---@field CardsTextPrompt CardsMainTextPromptView
---@field EffectForOther01 UFImage
---@field EffectForSelf01 UFImage
---@field FImg_TextPromptMask UFImage
---@field ImgCardBG UFImage
---@field ImgRedTurn URadialImage
---@field ImgSelfTurn URadialImage
---@field MainLBottomPanel MainLBottomPanelView
---@field MainTeamPanel MainTeamPanelView
---@field OtherCard01 CardsBigCardItemView
---@field OtherCard02 CardsBigCardItemView
---@field OtherCard03 CardsBigCardItemView
---@field OtherCard04 CardsBigCardItemView
---@field OtherCard05 CardsBigCardItemView
---@field OtherCardEven01 CardsBigCardItemView
---@field OtherCardEven02 CardsBigCardItemView
---@field OtherCardEven03 CardsBigCardItemView
---@field OtherCardEven04 CardsBigCardItemView
---@field OtherCardName01 UFTextBlock
---@field OtherCardName01_1 UFTextBlock
---@field OtherCardName02 UFTextBlock
---@field OtherCardName02_1 UFTextBlock
---@field OtherCardName03 UFTextBlock
---@field OtherCardName03_1 UFTextBlock
---@field OtherCardName04 UFTextBlock
---@field OtherCardName04_1 UFTextBlock
---@field OtherCardName05 UFTextBlock
---@field OtherGlowRation UFCanvasPanel
---@field PanelCardBoard UFCanvasPanel
---@field PanelFirst UFCanvasPanel
---@field PanelOtherDeal UFCanvasPanel
---@field PanelSelfDeal UFCanvasPanel
---@field RedPanel UFCanvasPanel
---@field RedPanelEven UFCanvasPanel
---@field RedPanelForCardname UFCanvasPanel
---@field RedPanelForCardnameEven UFCanvasPanel
---@field SelfCard01 CardsBigCardItemView
---@field SelfCard02 CardsBigCardItemView
---@field SelfCard03 CardsBigCardItemView
---@field SelfCard04 CardsBigCardItemView
---@field SelfCard05 CardsBigCardItemView
---@field SelfCardName01 UFTextBlock
---@field SelfCardName02 UFTextBlock
---@field SelfCardName03 UFTextBlock
---@field SelfCardName04 UFTextBlock
---@field SelfCardName05 UFTextBlock
---@field SelfCardNameEven01 UFTextBlock
---@field SelfCardNameEven02 UFTextBlock
---@field SelfCardNameEven03 UFTextBlock
---@field SelfCardNameEven04 UFTextBlock
---@field SelfGlowRation UFCanvasPanel
---@field TextBlueAmount UFTextBlock
---@field TextRedAmount UFTextBlock
---@field TextTime01 UFTextBlock
---@field TextTime02 UFTextBlock
---@field AnimDarkBG UWidgetAnimation
---@field AnimFirst UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRedTurn UWidgetAnimation
---@field AnimRedTurnSpeed UWidgetAnimation
---@field AnimScoreChange UWidgetAnimation
---@field AnimSelfTurn UWidgetAnimation
---@field AnimSelfTurnSpeed UWidgetAnimation
---@field AnimTableShake UWidgetAnimation
---@field BeginCountDown_SoundEffect SoftObjectPath
---@field StopCountDown_SoundEffect SoftObjectPath
---@field BattleBeginFlipCard_SoundEffect SoftObjectPath
---@field BattleFlipCard_SoundEffect SoftObjectPath
---@field BattleShow_SoundEffect SoftObjectPath
---@field BattleBegin_SoundEffect SoftObjectPath
---@field BattleShowFirst_SoundEffect SoftObjectPath
---@field BattleCancelDrag_SoundEffect SoftObjectPath
---@field BattleCardPut_SoundEffect SoftObjectPath
---@field BattleCardSelect_SoundEffect SoftObjectPath
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsMainPanelView = LuaClass(UIView, true)

function CardsMainPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    self.ViewModel = CardsMainPanelViewVM.New()
end

function CardsMainPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnClose)
    self:AddSubView(self.CardFirst01)
    self:AddSubView(self.CardFirst02)
    self:AddSubView(self.CardFirst03)
    self:AddSubView(self.CardSlot01)
    self:AddSubView(self.CardSlot02)
    self:AddSubView(self.CardSlot03)
    self:AddSubView(self.CardSlot04)
    self:AddSubView(self.CardSlot05)
    self:AddSubView(self.CardSlot06)
    self:AddSubView(self.CardSlot07)
    self:AddSubView(self.CardSlot08)
    self:AddSubView(self.CardSlot09)
    self:AddSubView(self.CardsTextPrompt)
    self:AddSubView(self.OtherCard01)
    self:AddSubView(self.OtherCard02)
    self:AddSubView(self.OtherCard03)
    self:AddSubView(self.OtherCard04)
    self:AddSubView(self.OtherCard05)
    self:AddSubView(self.SelfCard01)
    self:AddSubView(self.SelfCard02)
    self:AddSubView(self.SelfCard03)
    self:AddSubView(self.SelfCard04)
    self:AddSubView(self.SelfCard05)
    self:AddSubView(self.MainTeamPanel)
    self:AddSubView(self.MainLBottomPanel)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

--- @param CanvasPanel UWidget
local function GetCanvasOffsetInfo(CanvasPanel)
    return {
        -- offset = UIUtil.CanvasSlotGetOffsets(CanvasPanel),
        pos = UIUtil.CanvasSlotGetPosition(CanvasPanel),
        angle = CanvasPanel:GetRenderTransformAngle()
    }
end

local function GetPosInfo(ParentPanel)
    MagicCardMgr.PanelPosInfo = MagicCardMgr.PanelPosInfo or {}
    local OffsetInfo = MagicCardMgr.PanelPosInfo[ParentPanel:GetName()]
    if not OffsetInfo then
        OffsetInfo = {}
        for i = 1, ParentPanel:GetChildrenCount() do
            OffsetInfo[i] = GetCanvasOffsetInfo(ParentPanel:GetChildAt(i - 1))
        end
        MagicCardMgr.PanelPosInfo[ParentPanel:GetName()] = OffsetInfo
    end
    return OffsetInfo
end

local function GetChildViewList(TargetWidget, ChildCount)
    if (TargetWidget == nil) then
        return nil
    end

    local _result = {}
    for i = 1, ChildCount do
        local _childView = TargetWidget:GetChildAt(i - 1)
        _result[i] = _childView
    end
    return _result
end

function CardsMainPanelView:OnInit()
    self.ViewModel:InitData()
    self.ViewModel.BattleCancelDrag_SoundEffectStr = self.BattleCancelDrag_SoundEffect:ToString()
    self.ViewModel.BattleCardSelect_SoundEffectStr = self.BattleCardSelect_SoundEffect:ToString()
    self.IsPlayEnterGameAnim = false
    self.IsGameFinish = true
    --- 这个是拖拽的
    local _dragItemView = _G.UIViewMgr:CreateView(_G.UIViewID.MagicCardBigCardItem, self, true)
    _dragItemView:ShowView(
        {
            Data = self.ViewModel:GetDragVisualCardVM()
        }
    )
    self.ViewModel.DragVisualCardItemView = _dragItemView
    _dragItemView:HideView()

    self.BtnClose:SetCallback(self, self.OnClickBtnClose)
    InGameService = self.ViewModel:GetInGameService()
    InGameService.BeginCountDown_SoundEffectStr = self.BeginCountDown_SoundEffect:ToString()
    InGameService.StopCountDown_SoundEffectStr = self.StopCountDown_SoundEffect:ToString()
    InGameService.BattleFlipCard_SoundEffectStr = self.BattleFlipCard_SoundEffect:ToString()

    self.BattleCardPut_SoundEffectStr = self.BattleCardPut_SoundEffect:ToString()

    self.BlueCardItems = {}
    self.RedCardItems = {}
    self.CardItemsOnBoard = {}
    self.FirstOrSecondItems = {}

    for i = 1, 5 do
        local CardItemView = self.BluePanel:GetChildAt(i - 1)
        self.BlueCardItems[i] = CardItemView
        CardItemView = self.RedPanel:GetChildAt(i - 1)
        self.RedCardItems[i] = CardItemView
    end

    for i = 1, 9 do
        local CardItemView = self.PanelCardBoard:GetChildAt(i - 1)
        self.CardItemsOnBoard[i] = CardItemView
    end

    for i = 1, 3 do
        local _cardItemView = self.PanelFirst:GetChildAt(i - 1)
        self.FirstOrSecondItems[i] = _cardItemView
    end

    -- 取奇数牌时卡牌位置信息
    self.BlueOffsetInfoOdd = GetPosInfo(self.BluePanel)
    self.RedOffsetInfoOdd = GetPosInfo(self.RedPanel)

    -- 取偶数牌时卡牌位置信息
    self.BlueOffsetInfoEven = GetPosInfo(self.BluePanelEven)
    self.RedOffsetInfoEven = GetPosInfo(self.RedPanelEven)

    self.BlueNameViewList = GetChildViewList(self.BluePanelForCardname, LocalDef.CardCountInGroup)
    self.RedNameViewList = GetChildViewList(self.RedPanelForCardname, LocalDef.CardCountInGroup)
    self.BlueNameEvenViewList = GetChildViewList(self.BluePanelForCardnameEven, LocalDef.CardCountInGroup - 1)
    self.RedNameEvenViewList = GetChildViewList(self.RedPanelForCardnameEven, LocalDef.CardCountInGroup - 1)

    UIUtil.SetIsVisible(self.BluePanelForCardname, true)
    UIUtil.SetIsVisible(self.RedPanelForCardname, true)
    UIUtil.SetIsVisible(self.BluePanelForCardnameEven, true)
    UIUtil.SetIsVisible(self.RedPanelForCardnameEven, true)

    UIUtil.SetIsVisible(self.BluePanelEven, false)
    UIUtil.SetIsVisible(self.RedPanelEven, false)

    local Binders = {
        {
            "OpponentScore",
            UIBinderValueChangedCallback.New(self, nil, self.OnOpponentScoreChange)
        },
        {
            "PlayerScore",
            UIBinderValueChangedCallback.New(self, nil, self.OnPlayerScoreChange)
        },
        {
            "IsPlayerMove",
            UIBinderValueChangedCallback.New(self, nil, self.OnIsPlayerMoveChange)
        },
        {
            "CardNameIndexForSelf",
            UIBinderValueChangedCallback.New(self, nil, self.OnCardNameIndexForSelfChange)
        },
        {
            "CardNameIndexForOther",
            UIBinderValueChangedCallback.New(self, nil, self.OnCardNameIndexForOtherChange)
        }
    }
    self.Binders = Binders
end

function CardsMainPanelView:OnCardNameIndexForSelfChange(NewValue, OldValue)
    if (OldValue ~= nil and OldValue ~= 0) then
        local _targetView = nil
        if (self.ViewModel.CardNameOddOrEvenForSelf == 1) then
            _targetView = self.BlueNameViewList[OldValue]
        else
            _targetView = self.BlueNameEvenViewList[OldValue]
        end
        if _targetView then
            UIUtil.SetIsVisible(_targetView, false)
        end
    end

    if (NewValue ~= nil and NewValue ~= 0) then
        local _targetView = nil
        if (self.ViewModel.CardNameOddOrEvenForSelf == 1) then
            _targetView = self.BlueNameViewList[NewValue]
        else
            _targetView = self.BlueNameEvenViewList[NewValue]
        end
        if _targetView then
            UIUtil.SetIsVisible(_targetView, true)
        end
        _targetView:SetText(self.ViewModel.CurrentClickVM.CardName)
    end
end

function CardsMainPanelView:OnCardNameIndexForOtherChange(NewValue, OldValue)
    if (OldValue ~= nil and OldValue ~= 0) then
        local _targetView = nil
        if (self.ViewModel.CardNameOddOrEvenForOther == 1) then
            _targetView = self.RedNameViewList[OldValue]
        else
            _targetView = self.RedNameEvenViewList[OldValue]
        end
        if _targetView then
            UIUtil.SetIsVisible(_targetView, false)
        end
    end

    if (NewValue ~= nil and NewValue ~= 0) then
        local _targetView = nil
        if (self.ViewModel.CardNameOddOrEvenForOther == 1) then
            _targetView = self.RedNameViewList[NewValue]
        else
            _targetView = self.RedNameEvenViewList[NewValue]
        end
        if _targetView then
            UIUtil.SetIsVisible(_targetView, true)
        end
        _targetView:SetText(self.ViewModel.CurrentClickVM.CardName)
    end
end

---@type 对手积分变化
function CardsMainPanelView:OnOpponentScoreChange(NewValue, OldValue)
    self.TextRedAmount:SetText(NewValue)
    self:PlayAnimation(self.AnimScoreChange)
end

---@type 玩家积分变化
function CardsMainPanelView:OnPlayerScoreChange(NewValue, OldValue)
    self.TextBlueAmount:SetText(NewValue)
    self:PlayAnimation(self.AnimScoreChange)
end

function CardsMainPanelView:OnIsPlayerMoveChange(NewValue, OldValue)
    -- 行动回合发生变化，后续的改变在 UpdateTimerForMove 里面
    if (NewValue) then
        self.TextTime01:SetText("00:00")
        self.ImgRedTurn:SetPercent(0)
    else
        self.TextTime02:SetText("00:00")
        self.ImgSelfTurn:SetPercent(0)
    end
end

function CardsMainPanelView:OnClickBtnClose()
    -- 这里做二次确认
    if MagicCardMgr.IsGameEnd then
        self:InternalUserQuitGame()
    else
        local function ConfirmQuit()
            self:InternalUserQuitGame()
        end
        MsgBoxUtil.ShowMsgBoxTwoOp(
            nil, LSTR(LocalDef.UKeyConfig.Exit), LSTR(LocalDef.UKeyConfig.ExitMagicCardGameTips),
            ConfirmQuit, nil, LSTR(LocalDef.UKeyConfig.CommonCancel), LSTR(LocalDef.UKeyConfig.CommonConfirm)
        )
    end
end

function CardsMainPanelView:OnGameEventDoRefresh(FantasyCardEnterRsp)
    FLOG_INFO("幻卡 : OnGameEventDoRefresh")
    if (self.IsPlayEnterGameAnim) then
        _G.FLOG_ERROR("错误，请检查一下为什么已经开始播放动画了，又播放一次")
        return
    end
    
    --播放完开局行礼动作后，播放待机动作
    local function MajorAfterPlaySolute()
        if (not self.IsShowView) then
            return
        end
        self:PlayMajorTakeOutAnim()
    end

    local function NpcAfterPlaySolute()
        if (not self.IsShowView) then
            return
        end
        self:PlayNpcTakeOutAnim()
    end
    local MajorSaluteDuration, NpcSaluteDuration = ActorAnimService:PlayMajorAndNpcSaluteAnim()
    self:RegisterTimer(MajorAfterPlaySolute, MajorSaluteDuration)
    self:RegisterTimer(NpcAfterPlaySolute, NpcSaluteDuration)

    self:ShutdownCoroutine()
    self:ResetData()
    self.IsGameFinish = false
    self.ViewModel:OnEnterGameRsp(FantasyCardEnterRsp)
    self:ShowRemainTimeText(false)
    self.MainTeamPanel:SetShowCardMode()
    
    local BeginDisplayCoroutine = function()
        self.IsPlayEnterGameAnim = true
        if not self.ViewModel:HasExposeCardRules() then
            self:FlipCardToExpose()
            Utils.DelayAsync(LocalDef.FlipToExposeCardAnimTime * 2)
        end

        print("【开局：显示规则】")
        for _, Rule in ipairs(self.ViewModel:GetAllRulesToShow()) do
            local RuleId = Rule.Rule
            _G.FLOG_INFO(string.format("当前规则， [%s]", Rule.RuleText))
            self:PlayAnimation(self.AnimDarkBG)
            self.CardsTextPrompt.PlayRuleAsyc(self.CardsTextPrompt, RuleId)

            if RuleId == RuleEnum.FANTASY_CARD_RULE_EXCHANGE then
                print(
                    "交换规则额外处理: PlayerExchangedCard: [%d] EnemyExchangedCard: [%d]",
                    InGameService.PlayerExchangedCard, InGameService.EnemyExchangedCard
                )
                local _playerVM = self.ViewModel.PlayerCardVMList[InGameService.PlayerExchangedCard]
                local _opponentVM = self.ViewModel.OpponentCardVMList[InGameService.EnemyExchangedCard]
                local _opponentCardID = _opponentVM.CardId
                local _playerCardID = _playerVM.CardId
                _playerVM.FlipType = FlipTypeEnum.FLIP_MOVEMENT_VERTICAL
                if (_opponentVM.IsExposed) then
                    _opponentVM.FlipType = FlipTypeEnum.FLIP_MOVEMENT_VERTICAL
                end
                if CommonUtil.IsObjectValid(self.BattleBeginFlipCard_SoundEffect) then
                    AudioUtil.LoadAndPlayUISound(self.BattleBeginFlipCard_SoundEffect:ToString())
                end
                _playerVM.ExchangedCardId = _opponentCardID
                _opponentVM.ExchangedCardId = _playerCardID
                Utils.DelayAsync(LocalDef.ExchangeRuleDisplayAnimTime)
            elseif RuleId == RuleEnum.FANTASY_CARD_RULE_EXPOSE_THREE or RuleId == RuleEnum.FANTASY_CARD_RULE_EXPOSE_ALL then
                print("全明牌、三明牌规则额外处理: ")
                self:FlipCardToExpose()
                Utils.DelayAsync(LocalDef.FlipToExposeCardAnimTime)
            end
        end

        print("【开局：显示 开始】")
        self:PlayAnimation(self.AnimDarkBG)
        --AudioUtil.LoadAndPlayUISound(self.BattleBegin_SoundEffect:ToString())
        self.CardsTextPrompt.PlayKeyTextAsyc(self.CardsTextPrompt, "Start")
        Utils.DelayAsync(LocalDef.FlipToExposeCardAnimTime)

        FLOG_INFO("【开局：显示先后手】")
        if CommonUtil.IsObjectValid(self.BattleShowFirst_SoundEffect) then
            AudioUtil.LoadAndPlayUISound(self.BattleShowFirst_SoundEffect:ToString())
        end
        UIUtil.SetIsVisible(self.PanelFirst, true)
        self:PlayAnimation(self.AnimFirst)
        Utils.DelayAsync(LocalDef.TimeWaitForShowWhosFirst)
        if (InGameService.IsPlayerCurrentMove) then
            print("先手是蓝方")
        else
            print("先手是红方")
        end
        self.BeginDisplayCoroutine = nil
        self.ViewModel:OnGameStarted()
        self.IsPlayEnterGameAnim = false
    end

    self.BeginDisplayCoroutine = coroutine.create(BeginDisplayCoroutine)
    coroutine.resume(self.BeginDisplayCoroutine)
end

function CardsMainPanelView:OnRecoverGame(FantasyCardEnterRsp)
    -- 打牌动作
    ActorAnimService:PlayMajorAnimByEnum(MajorAnimEnum.Major_Anim_InGame_Normal)
    ActorAnimService:PlayNpcAnimByEnum(NpcAnimEnum.Anim_InGame_Normal)
    self.ViewModel:ResetData()
    UIUtil.SetIsVisible(self.ImgSelfTurn, false)
    UIUtil.SetIsVisible(self.ImgRedTurn, false)
    UIUtil.SetIsVisible(self.PanelFirst, false)
    UIUtil.SetIsVisible(self.PanelSelfDeal, false)
    UIUtil.SetIsVisible(self.PanelOtherDeal, false)
    self:ResetTimeProgress()

    self:ShutdownCoroutine()
    self.IsGameFinish = false
    self:ShowRemainTimeText(false)
    self.MainTeamPanel:SetShowCardMode()
    if not self.ViewModel:HasExposeCardRules() then
        self:FlipCardToExpose()
    end
    self.ViewModel:OnRecoverGameRsp(FantasyCardEnterRsp)
end

function CardsMainPanelView:FlipCardToExpose()
    if CommonUtil.IsObjectValid(self.BattleBeginFlipCard_SoundEffect) then
        AudioUtil.LoadAndPlayUISound(self.BattleBeginFlipCard_SoundEffect:ToString())
    end
    -- 翻牌
    ---@param CardItemVm CardsSingleCardVM
    local function TriggerFlipToExposeCard(CardItemVm)
        if CardItemVm.ShouldExpose and not CardItemVm.IsExposed then
            CardItemVm.FlipType = ProtoCS.FLIP_MOVEMENT.FLIP_MOVEMENT_LEVEL
            CardItemVm:SetIsExposed(true)
        end
    end

    for i = 1, 5 do
        TriggerFlipToExposeCard(self.ViewModel.PlayerCardVMList[i])
        TriggerFlipToExposeCard(self.ViewModel.OpponentCardVMList[i])
    end
end

function CardsMainPanelView:OnDestroy()

end

function CardsMainPanelView:OnShow()
    MagicCardMgr:TurnCamera(nil, 1, nil)
    MagicCardMgr:UpdateMajorAndNPCTransform()
    local UActorManager = _G.UE.UActorManager.Get()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    UActorManager:HideActor(MajorEntityID, false)

    UIUtil.SetIsVisible(self.MainLBottomPanel, false) -- 聊天模块有问题，暂时屏蔽
    if CommonUtil.IsObjectValid(self.BattleShow_SoundEffect) then
        AudioUtil.LoadAndPlayUISound(self.BattleShow_SoundEffect:ToString())
    end
    UIUtil.SetIsVisible(self.EffectForOther01, false)
    UIUtil.SetIsVisible(self.EffectForSelf01, false)

    self.ViewModel.DragVisualCardItemView:Hide()
    self.ViewModel:ResetData()
    self.MainTeamPanel:SetShowCardMode()

    MainPanelVM:SetEmotionVisible(false)
    MainPanelVM:SetPhotoVisible(false)
    UIUtil.SetIsVisible(self.ImgSelfTurn, false)
    UIUtil.SetIsVisible(self.ImgRedTurn, false)
    UIUtil.SetIsVisible(self.PanelFirst, false)
    UIUtil.SetIsVisible(self.PanelSelfDeal, false)
    UIUtil.SetIsVisible(self.PanelOtherDeal, false)
    -- 处于幻卡大赛时显示阶段信息
    if MagicCardTourneyMgr:GetIsInTourney() == true then
        local TourneyBG = MagicCardTourneyDefine.ImgPath.MagicCardBG
        UIUtil.ImageSetBrushFromAssetPath(self.ImgCardBG, TourneyBG)
    end
    
    self:ResetTimeProgress()

    for i = 1, LocalDef.CardCountInGroup do
        UIUtil.SetIsVisible(self.BlueNameViewList[i], false)
        UIUtil.SetIsVisible(self.RedNameViewList[i], false)
    end

    for i = 1, LocalDef.CardCountInGroup - 1 do
        UIUtil.SetIsVisible(self.BlueNameEvenViewList[i], false)
        UIUtil.SetIsVisible(self.RedNameEvenViewList[i], false)
    end

    -- 自己的牌初始化
    for i = 1, #self.BlueCardItems do
        local CardItemView = self.BlueCardItems[i]
        CardItemView:SetParams(
            {
                Data = self.ViewModel.PlayerCardVMList[i]
            }
        )
    end

    -- 对手的牌初始化
    for i = 1, #self.RedCardItems do
        local CardItemView = self.RedCardItems[i]
        CardItemView:SetParams(
            {
                Data = self.ViewModel.OpponentCardVMList[i]
            }
        )
    end

    -- 棋盘初始化
    for i = 1, #self.CardItemsOnBoard do
        local CardItemView = self.CardItemsOnBoard[i]
        CardItemView:SetParams(
            {
                Data = self.ViewModel.OnBoardCardVMList[i]
            }
        )
    end

    for i = 1, 3 do
        local CardItemView = self.FirstOrSecondItems[i]
        CardItemView:SetParams(
            {
                Data = self.ViewModel.DeskShowCardList[i]
            }
        )
    end

    self:ResetCardsAndNamesPos()

    self:UpdateRemainTimeText(self.Params)
end

---@type 刷新等待时间文本
function CardsMainPanelView:UpdateRemainTimeText(Params)
    if Params == nil then
        return
    end

    local IsPVP = Params.IsOpponentPVP
    if not IsPVP then
        self:ShowRemainTimeText(false) -- PVP模式才显示准备时间
        return
    end

    self.RemainTime = Params.RemainTime
    if self.RemainTime and self.RemainTime > 0 then
        local function UpdateRemainTime()
            self:ShowRemainTimeText(true)
            self.RemainTime = self.RemainTime - 1
            local TiemText = string.format(_G.LSTR(LocalDef.UKeyConfig.Seconds), self.RemainTime)
            self.CardsTextPrompt:UpdateWaitCountdown(TiemText) 
            if self.RemainTime <= 0 or self.IsGameFinish == false then
                self:ShowRemainTimeText(false)
                if self.RemainTimeTimer then
                    self:UnRegisterTimer(self.RemainTimeTimer)
                    self.RemainTimeTimer = nil
                end
            elseif math.fmod(self.RemainTime, 4) == 0 then
                local WaitTipText = MagicCardVMUtils.GetWaitForOpponentText()
                self.CardsTextPrompt:UpdateWaitText(WaitTipText)
            end
        end

        self.RemainTimeTimer = self:RegisterTimer(UpdateRemainTime, 0.1, 1, 0)
    else
        self:ShowRemainTimeText(false)
    end
end

function CardsMainPanelView:ShowRemainTimeText(IsShow)
    UIUtil.SetIsVisible(self.CardsTextPrompt.RootPanel, IsShow)
    UIUtil.SetIsVisible(self.CardsTextPrompt.TextPrompt_RivalChoose, IsShow, false)
end

function CardsMainPanelView:ResetData()
    self:ResetCardsAndNamesPos()
    self.ViewModel:ResetData()
    UIUtil.SetIsVisible(self.ImgSelfTurn, false)
    UIUtil.SetIsVisible(self.ImgRedTurn, false)
    UIUtil.SetIsVisible(self.PanelFirst, false)
    UIUtil.SetIsVisible(self.PanelSelfDeal, false)
    UIUtil.SetIsVisible(self.PanelOtherDeal, false)
    self:ResetTimeProgress()
end

function CardsMainPanelView:ResetCardsAndNamesPos()
    -- 卡牌归位
    local function ResetCardItemView(TargetItemView, OffsetInfo)
        if TargetItemView == nil or not CommonUtil.IsObjectValid(TargetItemView) then
            return
        end

        TargetItemView:SetVisible(true, true)
        UIUtil.CanvasSlotSetPosition(TargetItemView, OffsetInfo.pos)
        TargetItemView:SetRenderTransformAngle(OffsetInfo.angle)
    end

    for i = 1, 5 do
        ResetCardItemView(self.RedCardItems[i], self.RedOffsetInfoOdd[i])
        ResetCardItemView(self.BlueCardItems[i], self.BlueOffsetInfoOdd[i])
    end
end

function CardsMainPanelView:PlayMajorTakeOutAnim()
   local MajorDuration = ActorAnimService:PlayMajorAnimByEnum(MajorAnimEnum.Major_PlayCard_TakeOut, false) -- 掏牌动作
    --播放完掏牌作后，播放待机动作
    local function AfterPlayTakeOut()
        if (not self.IsShowView) then
            return
        end
        ActorAnimService:PlayMajorAnimByEnum(MajorAnimEnum.Major_Anim_InGame_Normal)
    end

    --玩家掏牌时长
    self:RegisterTimer(AfterPlayTakeOut, MajorDuration)
end

-- 掏牌动作
function CardsMainPanelView:PlayNpcTakeOutAnim()
    local _, NpcDuration = ActorAnimService:PlayNpcAnimByEnum(NpcAnimEnum.PlayCard_TakeOut)
    --播放完掏牌作后，播放待机动作
    local function AfterPlayTakeOut()
        if (not self.IsShowView) then
            return
        end
        ActorAnimService:PlayNpcAnimByEnum(NpcAnimEnum.Anim_InGame_Normal)
    end

    --Npc掏牌时长
    self:RegisterTimer(AfterPlayTakeOut, NpcDuration)
end

function CardsMainPanelView:StopPlayingAnim()
    ActorAnimService:StopMajorAnim()
    ActorAnimService:StopNpcAnim()
end

function CardsMainPanelView:OnHide()
    MainPanelVM:SetEmotionVisible(true)
    MainPanelVM:SetPhotoVisible(true)
    self:StopPlayingAnim()
    -- 断线先结束各计时器
    self:ShutdownCoroutine()
    InGameService:EndGame()
    if not self.IsGameFinish then
        MagicCardMgr:OnUserQuitGameWithDisConnect()
    end
end

function CardsMainPanelView:OnRegisterUIEvent()

end

function CardsMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MagicCardShowNewTurn, self.OnGameEventShowNewTurn)
    self:RegisterGameEvent(EventID.MagicCardReadyNewMove, self.OnMagicCardReadyNewMove)
    self:RegisterGameEvent(EventID.MagicCardDoPlayOneCard, self.OnGameEventDoPlayOneCard)
    self:RegisterGameEvent(EventID.MagicCardRecoverPos, self.OnGameEventMagicCardRecoverPos)
    self:RegisterGameEvent(EventID.MagicCardRecover, self.OnRecoverGame)
    self:RegisterGameEvent(EventID.MagicCardShowBoardEffectForSpecialRule, self.OnGameEventShowBoardEffectForSpecialRule)
    self:RegisterGameEvent(EventID.MagicCardGameFinish, self.OnGameEventGameFinish)
    self:RegisterGameEvent(EventID.MagicCardUpdateTimer, self.OnGameEventUpdateTimer)
    -- self:RegisterGameEvent(EventID.MagicCardEnlargeOneCard, self.OnGameEventEnlargeOneCard)
    self:RegisterGameEvent(EventID.MagicCardRefreshMainPanel, self.OnGameEventDoRefresh)
    self:RegisterGameEvent(EventID.MagicCardNewMove, self.OnGameEventNewMove)
    self:RegisterGameEvent(EventID.MagicCardShowRulePanelInBattle, self.OnMagicCardShowRulePanelInBattle)
    self:RegisterGameEvent(EventID.MagicCardShowRuleEffect, self.OnGameEventShowRuleEffect)
    self:RegisterGameEvent(EventID.MagicCardBattleRecover, self.OnMagicCardBattleRecover)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)

end

-- 进入副本之前都会发退出前一个可以直接监听这个消息
function CardsMainPanelView:OnPWorldExit()
    self.IsPlayEnterGameAnim = false
    self.IsGameFinish = true
    -- 这里退出一下coroutine
    self:ShutdownCoroutine()
    InGameService:EndGame()
    MagicCardMgr:OnUserQuitGame()
end

function CardsMainPanelView:InternalUserQuitGame()
    self.IsPlayEnterGameAnim = false
    self.IsGameFinish = true
    -- 这里退出一下coroutine
    FLOG_INFO("玩家退出了幻卡游戏")
    self:ShutdownCoroutine()
    --self.ViewModel:OnUserQuitGame()
    MagicCardMgr:SendFinishFantasyCard(true)
end

---@param NetMsg FantasyCardEnterRsp
function CardsMainPanelView:OnMagicCardBattleRecover(NetMsg)
end

function CardsMainPanelView:OnGameEventAppEnterBackground()
    self:ShutdownCoroutine()
end

---@param RuleEffect OneCommonFlipEffect
function CardsMainPanelView:OnGameEventShowRuleEffect(RuleEffect)
    if RuleEffect == nil then
        return
    end
    -- if RuleId == RuleEnum.FANTASY_CARD_RULE_TRUMP then
    self.CardsTextPrompt:PlayRule(RuleEffect.RuleId)

    if RuleEffect.TriggerEffects == nil then
        return
    end

    -- -- TriggerEffects ~= nil, 表示是特殊规则触发

    -- 播放AnimDarkBG时，先临时调高相关卡牌的zorder，之后再恢复
    local OrigZOrder = UIUtil.CanvasSlotGetZOrder(self.CardItemsOnBoard[1])
    local TargetZOrder = UIUtil.CanvasSlotGetZOrder(self.FImg_TextPromptMask) + 1
    for _, TriggerEffect in ipairs(RuleEffect.TriggerEffects) do
        -- 根据Trigger卡牌和被翻的卡牌位置，计算Connect效果四方向的显示/隐藏逻辑
        local ConnectEffects = {
            UP = false,
            DOWN = false,
            LEFT = false,
            RIGHT = false
        }
        for _, Card in ipairs(TriggerEffect.FlipCards) do
            local CardView = self.CardItemsOnBoard[Card.BoardLoc]

            local Offset = Card.BoardLoc - TriggerEffect.TriggerCardBoardLoc
            if Offset > 0 then
                if Offset == 1 then
                    ConnectEffects.RIGHT = true
                else
                    ConnectEffects.DOWN = true
                end
            else
                if Offset == -1 then
                    ConnectEffects.LEFT = true
                else
                    ConnectEffects.UP = true
                end
            end

            UIUtil.CanvasSlotSetZOrder(CardView, TargetZOrder)
            CardView:SetAsSpecialFlippedCard(Card)
        end

        local TriggerCardView = self.CardItemsOnBoard[TriggerEffect.TriggerCardBoardLoc]
        UIUtil.CanvasSlotSetZOrder(TriggerCardView, TargetZOrder)
        TriggerCardView:SetAsTriggerCard(ConnectEffects, RuleEffect.RuleId)
    end

    Utils.PlayUIAnimation(
        self, self.AnimDarkBG, function()
            -- reset
            for _, TriggerEffect in ipairs(RuleEffect.TriggerEffects) do
                local TriggerCardView = self.CardItemsOnBoard[TriggerEffect.TriggerCardBoardLoc]

                UIUtil.CanvasSlotSetZOrder(TriggerCardView, OrigZOrder)
                for _, Card in ipairs(TriggerEffect.FlipCards) do
                    local CardView = self.CardItemsOnBoard[Card.BoardLoc]
                    UIUtil.CanvasSlotSetZOrder(CardView, OrigZOrder)
                end
            end
        end
    )
end

---@param FlipCards OneFlippedCard[]
function CardsMainPanelView:OnGameEventShowBoardEffectForSpecialRule(FlipCards)
    -- self:PlayAnimation(self.AnimTableShake)
    for _, Card in ipairs(FlipCards) do
        if Card.IsFlipBySpecialRule then
            local CardView = self.CardItemsOnBoard[Card.BoardLoc]
            CardView:PlayEffectForSpecialRule()
        end
    end
end

function CardsMainPanelView:OnGameEventDoPlayOneCard(IsPlayerMove, CardId, BoardLoc, ChangedCardsOnBoard)
    -- stop progress anim
    self:StopAnimation(self.AnimGlow)
    self:StopAnimation(self.AnimProgress)

    self:UpdateTimerForMove(0)

    -- set hand card played
    local PlayingCards = InGameService.IsPlayerCurrentMove and self.ViewModel.PlayerCardVMList or
                             self.ViewModel.OpponentCardVMList
    local PlayedCard = PlayingCards[InGameService.ChosedCardIndex]
    if not PlayedCard then
        _G.FLOG_ERROR("PlayedCard is nil! InGameService.ChosedCardIndex [%s]", InGameService.ChosedCardIndex)
        return
    end
    PlayedCard:SetIsPlayed(true)
    -- 设置手牌位置、隐藏并收拢卡牌
    local PlayingCardsItemView = InGameService.IsPlayerCurrentMove and self.BlueCardItems or self.RedCardItems
    local function GetIndexToHide()
        for i, ItemView in ipairs(PlayingCardsItemView) do
            if ItemView.ViewModel == PlayedCard then
                return i
            end
        end
        return 1
    end
    local IndexToHide = GetIndexToHide()
    local CardItemView = PlayingCardsItemView[IndexToHide]
    if CardItemView then
        CardItemView:SetVisible(false)
    end
    local function SetPlayedCardItemOffset(RemainCardsView)
        local RemainCardNum = #RemainCardsView
        local PlayedOffsetInfo = self:GetPlayingOffsetInfo(RemainCardNum, InGameService.IsPlayerCurrentMove)
        local BeginIndex = (#PlayedOffsetInfo - RemainCardNum) / 2
        local WorkData = {}
        for i = 1, RemainCardNum do
            local CardItemView = RemainCardsView[i]
            WorkData[i] = {}
            WorkData[i].CardItemView = CardItemView
            WorkData[i].DesOffsetInfo = PlayedOffsetInfo[i + BeginIndex]
            WorkData[i].OrigOffsetInfo = GetCanvasOffsetInfo(CardItemView)
        end

        local StartOffsetTime = TimeUtil.GetLocalTimeMS()
        local TimerId
        local function TempCallback()
            local PassedTime = (TimeUtil.GetLocalTimeMS() - StartOffsetTime) / 1000
            local Ratio = PassedTime / LocalDef.LerpTimeForMoveCard
            Ratio = Ratio > 1 and 1 or Ratio
            for _, Work in ipairs(WorkData) do
                UIUtil.CanvasSlotSetPosition(
                    Work.CardItemView, FMath.V2DLerp(Work.OrigOffsetInfo.pos, Work.DesOffsetInfo.pos, Ratio)
                )
                Work.CardItemView:SetRenderTransformAngle(
                    FMath.Lerp(
                        Work.OrigOffsetInfo.angle, Work.DesOffsetInfo.angle, Ratio
                    )
                )
            end

            if Ratio == 1 then
                self:UnRegisterTimer(TimerId)
                return
            end
        end
        TimerId = self:RegisterTimer(TempCallback, 0, 0, -1)
    end
    local function GetRemainCardsView()
        local RemainCardsView = {}
        for _, CardItemView in ipairs(PlayingCardsItemView) do
            if UIUtil.IsVisible(CardItemView) then
                table.insert(RemainCardsView, CardItemView)
            end
        end
        return RemainCardsView
    end
    local RemainCardsView = GetRemainCardsView()
    if #RemainCardsView > 0 then
        SetPlayedCardItemOffset(RemainCardsView)
    end

    local BoardCard = self.ViewModel.OnBoardCardVMList[InGameService.ChosedBoardLoc]
    BoardCard:SetIsPlayed(true)

    AudioUtil.LoadAndPlayUISound(self.BattleCardPut_SoundEffectStr)

    if (InGameService.IsPlayerCurrentMove) then
        BoardCard:SetCardId(PlayedCard.CardId)
        BoardCard:SetChangePoint(PlayedCard.ChangePoint)
        BoardCard:SetTournamentWeaken(PlayedCard.TournamentWeaken)
    else
        BoardCard:SetCardId(InGameService.NewMoveFantasyCardInfo.CardID)
        BoardCard:SetChangePoint(InGameService.NewMoveFantasyCardInfo.Change)
        BoardCard:SetTournamentWeaken(InGameService.NewMoveFantasyCardInfo.ScoreChange)
    end

    BoardCard:SetIsPlayerCard(PlayedCard.IsPlayerCard)
    
    -- 清除选中幻卡，防止无法点击
    self.ViewModel:ClearClickVM()
    -- 取消DragDrop效果
    _G.UE.UWidgetBlueprintLibrary.CancelDragDrop()
end

function CardsMainPanelView:OnGameEventMagicCardRecoverPos(RemianTime)
    self:UpdateTimerForMove(RemianTime)
    -- 手牌
    self:RecoverHandCardsPos(self.ViewModel.PlayerCardVMList, self.BlueCardItems, true)
    self:RecoverHandCardsPos(self.ViewModel.OpponentCardVMList, self.RedCardItems, false)
end

-- 恢复手牌位置
function CardsMainPanelView:RecoverHandCardsPos(CardVMList, CardItems, IsPlayerCards)
    local PlayingCards = CardVMList
    if not PlayingCards then
        return
    end

    local PlayingCardsItemView = CardItems
    -- 隐藏打出去的手牌
    for Index, CardVM in ipairs(PlayingCards) do
        if not CardVM.Active then
            CardVM:SetIsPlayed(true)
            local CardItemView = PlayingCardsItemView[Index]
            if CardItemView then
                CardItemView:SetVisible(false)
                FLOG_INFO(string.format("【恢复牌局】隐藏已打出的手牌 %s：%s", IsPlayerCards and "玩家" or "对手", CardVM.CardId or 0))
            end
        end
    end

    -- 设置手牌位置,收拢卡牌
    local function GetRemainCardsView()
        local RemainCardsView = {}
        for _, CardItemView in ipairs(PlayingCardsItemView) do
            if UIUtil.IsVisible(CardItemView) then
                table.insert(RemainCardsView, CardItemView)
            end
        end
        return RemainCardsView
    end

    local RemainCardsView = GetRemainCardsView()
    if #RemainCardsView > 0 then
        local RemainCardNum = #RemainCardsView
        local PlayedOffsetInfo = self:GetPlayingOffsetInfo(RemainCardNum, IsPlayerCards)
        local BeginIndex = (#PlayedOffsetInfo - RemainCardNum) / 2
        local WorkData = {}
        for i = 1, RemainCardNum do
            local CardItemView = RemainCardsView[i]
            WorkData[i] = {}
            WorkData[i].CardItemView = CardItemView
            WorkData[i].DesOffsetInfo = PlayedOffsetInfo[i + BeginIndex]
            WorkData[i].OrigOffsetInfo = GetCanvasOffsetInfo(CardItemView)
        end

        for _, Work in ipairs(WorkData) do
            UIUtil.CanvasSlotSetPosition(Work.CardItemView, Work.DesOffsetInfo.pos)
            Work.CardItemView:SetRenderTransformAngle(Work.DesOffsetInfo.angle)
        end
    end
end


function CardsMainPanelView:GetPlayingOffsetInfo(RemainCardNum, IsPlayerCards)
    if IsPlayerCards then
        return RemainCardNum % 2 == 1 and self.BlueOffsetInfoOdd or self.BlueOffsetInfoEven
    else
        return RemainCardNum % 2 == 1 and self.RedOffsetInfoOdd or self.RedOffsetInfoEven
    end
end

function CardsMainPanelView:OnMagicCardShowRulePanelInBattle()
    -- 显示规则详情
end

function CardsMainPanelView:OnGameEventNewMove(FantasyCardNewMoveRsp)
    InGameService:OnNewMoveRsp(FantasyCardNewMoveRsp, false)
end

function CardsMainPanelView:OnGameEventUpdateTimer(RemainTime)
    --MagicCardMgr:TurnCamera(nil, 0, nil)
    self:UpdateTimerForMove(RemainTime)
end

function CardsMainPanelView:OnGameEventShowNewTurn(IsPlayerMove, OnReadyCallback, IsRecover)
    if (IsPlayerMove) then
        self.ViewModel:ClearClickVM() -- 清除选中幻卡，防止无法点击
        UIUtil.SetIsVisible(self.ImgSelfTurn, true)
        UIUtil.SetIsVisible(self.ImgRedTurn, false)
        self:PlayAnimation(self.AnimRedTurn, 0)
        self:StopAnimation(self.AnimRedTurn)
        self:PlayAnimation(self.AnimSelfTurn)
        if IsRecover then
            OnReadyCallback()
        else
            self.CardsTextPrompt.PlayKeyText(self.CardsTextPrompt, "BlueTurn", OnReadyCallback)
        end
    else
        UIUtil.SetIsVisible(self.ImgSelfTurn, false)
        UIUtil.SetIsVisible(self.ImgRedTurn, true)
        self:PlayAnimation(self.AnimSelfTurn, 0)
        self:StopAnimation(self.AnimSelfTurn)
        self:PlayAnimation(self.AnimRedTurn)
        if IsRecover then
            OnReadyCallback()
        else
            self.CardsTextPrompt.PlayKeyText(self.CardsTextPrompt, "RedTurn", OnReadyCallback)
        end
    end
    UIUtil.SetIsVisible(self.PanelSelfDeal, IsPlayerMove)
    UIUtil.SetIsVisible(self.PanelOtherDeal, not IsPlayerMove)
end

-- 更新进度
function CardsMainPanelView:UpdateTimerForMove(TimeRemains)
    TimeRemains = math.ceil(TimeRemains)

    local _totalTime = InGameService:GetActualTimeOutForMove()
    if (InGameService.IsPlayerCurrentMove) then
        -- 自己的时间显示
        if TimeRemains <= 0 then
            self.TextTime02:SetText("00:00")
            self.ImgSelfTurn:SetPercent(0)
        else
            self.ImgSelfTurn:SetPercent(TimeRemains / _totalTime)
            local _min = 0
            while (TimeRemains >= 60) do
                TimeRemains = TimeRemains - 60
                _min = _min + 1
            end

            self.TextTime02:SetText(string.format("%02d:%02d", _min, TimeRemains))
            if TimeRemains == 5 then
                self:PlayAnimation(self.AnimSelfTurnSpeed)
            end
        end
    else
        -- 对面的时间显示
        if TimeRemains <= 0 then
            self.ImgRedTurn:SetPercent(0)
            self.TextTime01:SetText("00:00")
        else
            self.ImgRedTurn:SetPercent(TimeRemains / _totalTime)
            local _min = 0
            while (TimeRemains >= 60) do
                TimeRemains = TimeRemains - 60
                _min = _min + 1
            end
            self.TextTime01:SetText(string.format("%02d:%02d", _min, TimeRemains))
            if TimeRemains == 5 then
                self:PlayAnimation(self.AnimRedTurnSpeed)
            end
        end
    end

    UIUtil.SetIsVisible(self.PanelSelfDeal, InGameService.IsPlayerCurrentMove)
    UIUtil.SetIsVisible(self.PanelOtherDeal, not InGameService.IsPlayerCurrentMove)
end

function CardsMainPanelView:ResetTimeProgress()
    self.TextTime01:SetText("00:00")
    self.ImgRedTurn:SetPercent(0)
    self.TextTime02:SetText("00:00")
    self.ImgSelfTurn:SetPercent(0)
    UIUtil.SetIsVisible(self.PanelSelfDeal, false)
    UIUtil.SetIsVisible(self.PanelOtherDeal, false)
end

function CardsMainPanelView:ShutdownCoroutine()
    if (self.BeginDisplayCoroutine ~= nil ) then
        FLOG_INFO("ShutdownCoroutine 幻卡游戏")
        if CommonUtil.IsObjectValid(self.BeginDisplayCoroutine) then
            coroutine.close(self.BeginDisplayCoroutine)
        end
        self.BeginDisplayCoroutine = nil
    end
end

function CardsMainPanelView:OnGameEventGameFinish(GameFinishRsp)
    if (GameFinishRsp == nil) then
        return
    end

    FLOG_INFO("幻卡 : OnGameEventGameFinish")

    self.IsGameFinish = true
    --self.Params.Data = nil -- 这里取置空一下

    -- 有可能刚进入游戏，对面就退出了
    self:ShutdownCoroutine()

    local BattleResult, ShouldRestart = GameFinishRsp.Result, GameFinishRsp.ShouldRestart
    self:ResetTimeProgress()
    if BattleResult == ProtoCS.BATTLE_RESULT.BATTLE_RESULT_WIN then
        self.CardsTextPrompt:PlayKeyText("BlueWins")
    elseif BattleResult == ProtoCS.BATTLE_RESULT.BATTLE_RESULT_FAIL then
        self.CardsTextPrompt:PlayKeyText("RedWins")
    else
        -- draw
        if ShouldRestart then
            self.CardsTextPrompt:PlayRule(RuleEnum.FANTASY_CARD_RULE_NONE_STOP)
        else
            self.CardsTextPrompt:PlayKeyText("Draw")
        end
    end
    self:PlayAnimation(self.AnimDarkBG)

    local InGameSrv = self.ViewModel:GetInGameService()
    if InGameSrv then
        InGameSrv:EndGame()  --先结束出牌计时
    end

    self:RegisterTimer(function()
        self.ViewModel:OnFinishGameRsp(GameFinishRsp)
    end, LocalDef.ShowFinishTextDisplayTime)
end

function CardsMainPanelView:OnMagicCardReadyNewMove()
    -- 获取手牌
    local PlayingCardsItemView = InGameService.IsPlayerCurrentMove and self.BlueCardItems or self.RedCardItems
    if PlayingCardsItemView == nil then
        return
    end
    for _, CardItemView in ipairs(PlayingCardsItemView) do
        if UIUtil.IsVisible(CardItemView) then
            CardItemView:PlayAnimHandGlow()
        end
    end
end

function CardsMainPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsMainPanelView
