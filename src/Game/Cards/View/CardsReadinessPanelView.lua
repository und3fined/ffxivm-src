---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-11-08 09:56
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterPanelWidget = require("UI/Adapter/UIAdapterPanelWidget")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextList = require("Binder/UIBinderSetTextList")
local CardsReadinessPanelVM = require("Game/Cards/VM/CardsReadinessPanelVM")
local ProtoRes = require("Protocol/ProtoRes")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local MajorUtil = require("Utils/MajorUtil")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")
local AudioUtil = require("Utils/AudioUtil")
local MagicCardMgr = _G.MagicCardMgr
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr
local LSTR = _G.LSTR
local RaceTypeEnum = ProtoCommon.race_type

---@class CardsReadinessPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnDecks CommBtnLView
---@field BtnRule CommBtnLView
---@field BtnSure CommBtnXLView
---@field CommCurrency CommMoneySlotView
---@field DecksCard01 CardsBigCardItemView
---@field DecksCard02 CardsBigCardItemView
---@field DecksCard03 CardsBigCardItemView
---@field DecksCard04 CardsBigCardItemView
---@field DecksCard05 CardsBigCardItemView
---@field DrawReward CommBackpack96SlotView
---@field HeadSlot CommPlayerHeadSlotView
---@field HorizontalCurrency UFHorizontalBox
---@field ImgBigBG UFImage
---@field ImgBoard UFImage
---@field ImgLeftBG UFImage
---@field LoseReward CommBackpack96SlotView
---@field PanelCard UFCanvasPanel
---@field PanelOdds UFCanvasPanel
---@field PanelRewardInfo UFCanvasPanel
---@field PanelRules UFCanvasPanel
---@field PanelStage UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RichTextCurrency URichTextBox
---@field Sidebar CardsSidebarPanelView
---@field TableViewOddsReward UTableView
---@field TableViewRule UTableView
---@field TextDecksDefault UFTextBlock
---@field TextDraw UFTextBlock
---@field TextGroupName UFTextBlock
---@field TextLose UFTextBlock
---@field TextOdds UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextRule01 UFTextBlock
---@field TextRule02 UFTextBlock
---@field TextRule03 UFTextBlock
---@field TextRule04 UFTextBlock
---@field TextRuleTitle01 UFTextBlock
---@field TextRuleTitle02 UFTextBlock
---@field TextStage01 UFTextBlock
---@field TextStage02 UFTextBlock
---@field TextStage03 UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTimes UFTextBlock
---@field TextTitle UFTextBlock
---@field TextWin UFTextBlock
---@field VerticalGeneralRuleRoot UFVerticalBox
---@field VerticalPopularRuleRoot UFVerticalBox
---@field WinReward CommBackpack96SlotView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field TimeWaitForMatchStart int
---@field BeginCountDown_SoundEffect SoftObjectPath
---@field StopCountDown_SoundEffect SoftObjectPath
---@field CameraMoveParamMap int
---@field CameraMoveTime float
---@field DistanceToNpc float
---@field PanelShow_SoundEffect SoftObjectPath
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsReadinessPanelView = LuaClass(UIView, true)

function CardsReadinessPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnClose = nil
    -- self.BtnConfirm = nil
    -- self.BtnDecks = nil
    -- self.BtnRule = nil
    -- self.CommCurrency = nil
    -- self.DecksCard01 = nil
    -- self.DecksCard02 = nil
    -- self.DecksCard03 = nil
    -- self.DecksCard04 = nil
    -- self.DecksCard05 = nil
    -- self.DrawReward = nil
    -- self.HeadSlot = nil
    -- self.LoseReward = nil
    -- self.PanelMiddle01 = nil
    -- self.PanelMiddle02 = nil
    -- self.PopUpBG = nil
    -- self.RichTextCurrency = nil
    -- self.Sidebar = nil
    -- self.TableViewOddsReward = nil
    -- self.TableViewRule = nil
    -- self.TextConfirm = nil
    -- self.TextDecksDefault = nil
    -- self.TextDecksName = nil
    -- self.TextPlayerName = nil
    -- self.TextRule01 = nil
    -- self.TextRule02 = nil
    -- self.TextRule03 = nil
    -- self.TextRule04 = nil
    -- self.TextSubtitle = nil
    -- self.TextTimes = nil
    -- self.WinReward = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    self.ViewModel = CardsReadinessPanelVM.New()
    self.CanHandleExit = true
end

function CardsReadinessPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnClose)
    self:AddSubView(self.BtnDecks)
    self:AddSubView(self.BtnRule)
    self:AddSubView(self.CommCurrency)
    self:AddSubView(self.DecksCard01)
    self:AddSubView(self.DecksCard02)
    self:AddSubView(self.DecksCard03)
    self:AddSubView(self.DecksCard04)
    self:AddSubView(self.DecksCard05)
    self:AddSubView(self.DrawReward)
    self:AddSubView(self.HeadSlot)
    self:AddSubView(self.LoseReward)
    self:AddSubView(self.PopUpBG)
    self:AddSubView(self.Sidebar)
    self:AddSubView(self.WinReward)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsReadinessPanelView:OnInit()
    self.TableViewOddsRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewOddsReward, nil, true)
    self.TableViewRuleAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRule, nil, true)
    self.PanelCardAdapter = UIAdapterPanelWidget.CreateAdapter(self, self.PanelCard)
    self.Sidebar:SetParentViewModel(self.ViewModel)
    local Binders = {
        {
            "OpponentName",
            UIBinderSetText.New(self, self.TextPlayerName)
        },
        {
            "MatchCost",
            UIBinderSetText.New(self, self.RichTextCurrency)
        },
        {
            "UpdateNotify",
            UIBinderValueChangedCallback.New(self, nil, self.OnUpdateNotify)
        },
        --  {"AwardCoins", UIBinderSetTextFormat.New(self, self.Text_RewardQuantity, "%d")},
        -- {
        --     "TotalCoinNum",
        --     UIBinderSetText.New(self, self.CommCurrency.TextMoneyAmount)
        -- },
        {
            "MatchRecord",
            UIBinderSetTextFormat.New(self, self.TextTimes, LSTR(LocalDef.UKeyConfig.Round))
        },
        {
            "TimeWaitForMatchStart",
            UIBinderValueChangedCallback.New(self, nil, self.OnTimeWaitForMatchStartChanged)
        },
        --  {"BattleCardGroupName", UIBinderSetText.New(self, self.Text_CardName)},
        {
            "RewardCardList",
            UIBinderUpdateBindableList.New(self, self.TableViewOddsRewardAdapter)
        },
        --  {"CardGroupList", UIBinderUpdateBindableList.New(self, self.GroupTableViewAdapter)},
        --  {"IsShowRuleDesc", UIBinderValueChangedCallback.New(self, nil, self.OnChangeIsShowRuleDesc)},
        {
            "GeneralRulesTextList",
            UIBinderSetTextList.New(self, self.VerticalGeneralRuleRoot)
        },
        {
            "CardsRuleDetailVMList",
            UIBinderUpdateBindableList.New(self, self.TableViewRuleAdapter)
        },
        {
            "PopularRulesTextList",
            UIBinderSetTextList.New(self, self.VerticalPopularRuleRoot)
        }, --  {"IsEditingGroup", UIBinderSetIsVisible.New(self, self.RootPanel, true)},
        {
            "IsInTourney",
            UIBinderSetIsVisible.New(self, self.PanelOdds, true)
        },
        {
            "IsInTourney",
            UIBinderSetIsVisible.New(self, self.HorizontalCurrency, true)
        },
        {
            "IsInTourney",
            UIBinderSetIsVisible.New(self, self.TextTimes, true)
        },
        {
            "IsInTourney",
            UIBinderSetIsVisible.New(self, self.PanelStage)
        },
        {
            "CurStageText",
            UIBinderSetText.New(self, self.TextStage01)
        },
        {
            "CurEffectText",
            UIBinderSetText.New(self, self.TextStage02)
        },
        {
            "CurEffectDesc",
            UIBinderSetText.New(self, self.TextStage03)
        },
    }
    self.Binders = Binders

    UIUtil.SetIsVisible(self.Sidebar, false)
end

function CardsReadinessPanelView:OnDestroy()
end

function CardsReadinessPanelView:OnUpdateNotify(NewValue, OldValue)
    local _viewModel = self.ViewModel
    if (_viewModel.UsingCardGroup ~= nil) then
        self.PanelCardAdapter:UpdateAll(_viewModel.UsingCardGroup.GroupCardList)
        self.TextGroupName:SetText(_viewModel.UsingCardGroup.GroupName)
    end
end

function CardsReadinessPanelView:OnTimeWaitForMatchStartChanged(NewValue, OldValue)
    local _min = 0

    while (NewValue >= 60) do
        NewValue = NewValue - 60
        _min = _min + 1
    end

    self.BtnSure.TextContent:SetText(string.format(LSTR(LocalDef.UKeyConfig.ConfirmCD), _min, NewValue))
end

function CardsReadinessPanelView:SetLSTR()
    self.TextTitle:SetText(_G.LSTR(1130083))--("幻卡挑战")
	self.TextSubtitle:SetText(_G.LSTR(1130084))--("倒计时结束自动开启挑战")
	self.TextOdds:SetText(_G.LSTR(1130085))--("概率获得:")
	self.TextDecksDefault:SetText(_G.LSTR(1130086))--("默认卡组")
    self.BtnDecks:SetButtonText(_G.LSTR(1130087)) --卡组一览

    self.TextRuleTitle01:SetText(_G.LSTR(1130035))--("流行规则")
    self.TextRuleTitle02:SetText(_G.LSTR(1130036))--("对局规则")
    self.TextWin:SetText(_G.LSTR(1130052))--("胜利")
    self.TextDraw:SetText(_G.LSTR(1130054))--("平局")
    self.TextLose:SetText(_G.LSTR(1130053))--("失败")
end

function CardsReadinessPanelView:OnShow()
    self:SetLSTR()
    self:CheckEditTutorial()
    self.HasClickChallengeBtn = false
    self.ViewModel:RefreshData()
    AudioUtil.LoadAndPlayUISound(self.PanelShow_SoundEffect:ToString())
    if self.ViewModel.HeadIconPath then
        self.HeadSlot:SetIcon(self.ViewModel.HeadIconPath, false)
    else
        self.HeadSlot:SetInfo(self.ViewModel.OpponentRoleID)
    end

    UIUtil.SetIsVisible(self.Sidebar, false)
    UIUtil.SetIsVisible(self.PanelRewardInfo, true)
    UIUtil.SetIsVisible(self.PanelRules, false)
    self.BtnRule:SetButtonText(LSTR(LocalDef.UKeyConfig.RuleDetail))

    -- self.CoinIconName
    self:UpdateForRewardIcon(self.WinReward, self.ViewModel.AwardCoins)
    self:UpdateForRewardIcon(self.DrawReward, self.ViewModel.DrawCoins)
    self:UpdateForRewardIcon(self.LoseReward, self.ViewModel.FailCoins)

    self.CommCurrency:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)

    self:RunToNpc()

    self.DecksCard01:SetTextCardNameVisible(false)
    self.DecksCard02:SetTextCardNameVisible(false)
    self.DecksCard03:SetTextCardNameVisible(false)
    self.DecksCard04:SetTextCardNameVisible(false)
    self.DecksCard05:SetTextCardNameVisible(false)

    self.WinReward:SetClickButtonCallback(self, self.OnClickCoinItem)
    self.DrawReward:SetClickButtonCallback(self, self.OnClickCoinItem)
    self.LoseReward:SetClickButtonCallback(self, self.OnClickCoinItem)

    UIUtil.ImageSetBrushFromAssetPath(self.ImgBigBG, self.ViewModel.BigBGPath)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgLeftBG, self.ViewModel.RuleBGPath)
end

---@type 幻卡编辑新手指引
function CardsReadinessPanelView:CheckEditTutorial()
    --解锁幻卡数量>= 8
	if MagicCardCollectionMgr:GetUnlockCardNum() >= 8 then
        local function ShowEditCheckRecptTutorial(Params)
            local EventParams = _G.EventMgr:GetEventParams()
            EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
            EventParams.Param1 = TutorialDefine.GameplayType.FantasyCard
            EventParams.Param2 = TutorialDefine.GamePlayStage.FantasyCardCardGroup
            _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
        end
        local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowEditCheckRecptTutorial, Params = {}}
        _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig) --玩法节点
	end

    --对局的目标是NPC，且不是幻卡大师。
    local NPCID = MagicCardMgr:GetPVENPCID()
    if not MagicCardMgr:IsPVPMode() and NPCID ~= 1011060 then
        local function ShowEditCheckRecptTutorial(Params)
            local EventParams = _G.EventMgr:GetEventParams()
            EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
            EventParams.Param1 = TutorialDefine.GameplayType.FantasyCard
            EventParams.Param2 = TutorialDefine.GamePlayStage.FantasyCardRuleGuide
            _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
        end
        local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowEditCheckRecptTutorial, Params = {}}
        _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig) --玩法节点
	end
end

function CardsReadinessPanelView:OnClickCoinItem(TargetItemView)
    --没有积分配置，暂时屏蔽弹窗
    if MagicCardMgr:IsPVPMode() then
        return
    end
    ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, false, TargetItemView)
end

---@param Numbers integer
---@param TargetCommBackpackSlotView CommBackpackSlotView
function CardsReadinessPanelView:UpdateForRewardIcon(TargetCommBackpackSlotView, Num)
    local _selfVM = self.ViewModel
    TargetCommBackpackSlotView:SetIconImg(_selfVM.CoinIconName)
    TargetCommBackpackSlotView:SetNum(Num)
    TargetCommBackpackSlotView:CommSetVisible(TargetCommBackpackSlotView.RichTextLevel, false)
    TargetCommBackpackSlotView:CommSetVisible(TargetCommBackpackSlotView.IconChoose, false)
end

function CardsReadinessPanelView:OnHide()

end

function CardsReadinessPanelView:OnClickExitBtn()
    if not self.CanHandleExit then
        return
    end

    local function ConfirmQuit()
        MagicCardMgr:QuitBeforeEnterGame()
    end

    if MagicCardMgr:IsPVPMode() then
        MsgBoxUtil.ShowMsgBoxTwoOp(
            nil, LSTR(LocalDef.UKeyConfig.Exit), LSTR(LocalDef.UKeyConfig.ExitMagicCardGameTips),
            ConfirmQuit, nil, LSTR(LocalDef.UKeyConfig.CommonCancel), LSTR(LocalDef.UKeyConfig.CommonConfirm)
        )
    else
        ConfirmQuit()
    end
end

function CardsReadinessPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSure.Button, self.OnClickBtnConfirm)
    UIUtil.AddOnClickedEvent(self, self.BtnDecks, self.OnClickBtnDecks)
    UIUtil.AddOnClickedEvent(self, self.BtnRule, self.OnClickBtnShowRule)
    self.BtnClose:SetCallback(self, self.OnClickExitBtn)
end

function CardsReadinessPanelView:OnClickBtnConfirm()
    if self.HasClickChallengeBtn then
        return
    end

    self.HasClickChallengeBtn = true
    self:RegisterTimer(
        function()
            self.HasClickChallengeBtn = false
        end,
        1
    )

    local UsingCardGroup = self.ViewModel and self.ViewModel.UsingCardGroup
    if UsingCardGroup == nil or not UsingCardGroup:IsGroupAvailable() then
        _G.MsgTipsUtil.ShowTips(_G.LSTR(LocalDef.UKeyConfig.NoAvailableCardGroup))
        return
    end
    
    if self.ViewModel:TryEnterChanllenge() then
        local RemainTime = self.ViewModel.TimeWaitForMatchStart
        _G.MagicCardMgr:OnWaitingGameToStart(RemainTime)
        self:Hide()
    end
end

function CardsReadinessPanelView:OnClickBtnShowRule()
    self.ViewModel:OnClickBtnShowRule()
    if (self.ViewModel.ShowRule) then
        self.BtnRule:SetButtonText(LSTR(LocalDef.UKeyConfig.HideRule))
        UIUtil.SetIsVisible(self.PanelRewardInfo, false)
        UIUtil.SetIsVisible(self.PanelRules, true)
    else
        self.BtnRule:SetButtonText(LSTR(LocalDef.UKeyConfig.RuleDetail))
        UIUtil.SetIsVisible(self.PanelRewardInfo, true)
        UIUtil.SetIsVisible(self.PanelRules, false)
    end
end

function CardsReadinessPanelView:OnClickBtnHideRule()
end

--- 打开卡组边显示
function CardsReadinessPanelView:OnClickBtnDecks()
    UIUtil.SetIsVisible(self.Sidebar, true)
end

function CardsReadinessPanelView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function CardsReadinessPanelView:OnTimer()
    self.ViewModel:UpdateTimer()
end

function CardsReadinessPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MagicCardOnSvrCreateAutoGroup, self.OnGameEventCreateAutoGroup)
    self:RegisterGameEvent(EventID.MagicCardGameFinish, self.OnGameEventGameFinish)
    self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
end

function CardsReadinessPanelView:OnGameEventCreateAutoGroup(CardList)
    self.ViewModel:OnAutoGroupCreated(CardList)
end

function CardsReadinessPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function CardsReadinessPanelView:RunToNpc()
    MagicCardMgr:UpdateMajorAndNPCTransform()
    Utils.Delay(
        LocalDef.CameraTurnTime,
        function()
            self.CanHandleExit = true
        end
    )
end

function CardsReadinessPanelView:OnGameEventGameFinish(GameFinishRsp)
    if (GameFinishRsp == nil) then
        return
    end
    FLOG_INFO("幻卡 : OnGameEventGameFinish")

    Utils.Delay(
        0.5, function()
            MagicCardMgr:EndGame(GameFinishRsp)
        end
    )
end

function CardsReadinessPanelView:OnMoneyUpdate()
	self.CommCurrency:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)
end

return CardsReadinessPanelView
