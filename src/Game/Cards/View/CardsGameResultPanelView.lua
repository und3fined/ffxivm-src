---
--- Author: Administrator
--- DateTime: 2023-11-14 10:03
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MagicCardLocalDef = require("Game/MagicCard/MagicCardLocalDef")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CardsFinishGameVM = require("Game/Cards/VM/CardsFinishGameVM")
local CardReadnessRewardItemVM = require("Game/Cards/VM/CardReadnessRewardItemVM")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MajorUtil = require("Utils/MajorUtil")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local EventID = require("Define/EventID")
local ActorAnimService = require("Game/MagicCard/Module/ActorAnimService")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local BagMgr = require("Game/Bag/BagMgr")
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr
local TourneyVM = _G.MagicCardTourneyVM
local BATTLE_RESULT = ProtoCS.BATTLE_RESULT
local EventMgr = _G.EventMgr
local DefaultFVector2D = _G.UE.FVector2D(0, 0)
local TargetOffSet = _G.UE.FVector2D(20, 20)

---@class CardsGameResultPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgain CommBtnMView
---@field BtnLeave CommBtnMView
---@field CommBtn CommInforBtnView
---@field CommSlot CommBackpackSlotView
---@field HeadSlot01 CommPlayerHeadSlotView
---@field HeadSlot02 CommPlayerHeadSlotView
---@field PanelDraw UFCanvasPanel
---@field PanelFaild UFCanvasPanel
---@field PanelRoot UFCanvasPanel
---@field PanelStage UFCanvasPanel
---@field PanelUp UFCanvasPanel
---@field PanelWin UFCanvasPanel
---@field PlayerName01 UFTextBlock
---@field PlayerName02 UFTextBlock
---@field RichTextOngoing URichTextBox
---@field RichTextStagProgress URichTextBox
---@field RichTextStageName URichTextBox
---@field ScaleItem UScaleBox
---@field TableViewReward UTableView
---@field TextDraw UFTextBlock
---@field TextFaild UFTextBlock
---@field TextReward UFTextBlock
---@field TextStage UFTextBlock
---@field TextTimes UFTextBlock
---@field TextUp UFTextBlock
---@field TextWin UFTextBlock
---@field TextWin_Eff UFTextBlock
---@field AnimDraw UWidgetAnimation
---@field AnimFaild UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimTips UWidgetAnimation
---@field AnimWin UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsGameResultPanelView = LuaClass(UIView, true)

function CardsGameResultPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnAgain = nil
    -- self.BtnLeave = nil
    -- self.CommBtn = nil
    -- self.HeadSlot01 = nil
    -- self.HeadSlot02 = nil
    -- self.PanelDraw = nil
    -- self.PanelFaild = nil
    -- self.PanelUp = nil
    -- self.PanelWin = nil
    -- self.PlayerName01 = nil
    -- self.PlayerName02 = nil
    -- self.TableViewReward = nil
    -- self.TextTimes = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsGameResultPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnAgain)
    self:AddSubView(self.BtnLeave)
    self:AddSubView(self.CommBtn)
    self:AddSubView(self.HeadSlot01)
    self:AddSubView(self.HeadSlot02)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsGameResultPanelView:OnInit()
    self.RewardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)

    self.ViewModel = CardsFinishGameVM.New()
    local Binders = {
        {
            "RewardItemVMList",
            UIBinderUpdateBindableList.New(self, self.RewardTableViewAdapter)
        }
    }
    self.Binders = Binders
    UIUtil.SetIsVisible(self.CommSlot.RedDot2, false)
end

function CardsGameResultPanelView:DoShowView()
    self:PlayAnimation(self.AnimIn)
    UIUtil.SetIsVisible(self.PanelRoot, true)
    -- if (self.ViewModel.CoinLootItem ~= nil) then
    --     _G.EventMgr:SendEvent(_G.EventID.DealLootItem, self.ViewModel.CoinLootItem)
    -- end
    --MagicCardMgr:OnShowGetLootItem()

    local NpcAnimEnum = ProtoRes.fantasy_card_npc_anim_enum
    local AnimIndex = 0
    local NpcAnimDuration = 0
    local IsNpcPlayAnim = false
    if self.ViewModel.BattleResult == BATTLE_RESULT.BATTLE_RESULT_WIN then
        AnimIndex = NpcAnimEnum.Emo_PlayerSuccess
        -- PVP模式下播放的是对手配置动作，所以玩家赢了，对手就是输的动作
        if MagicCardMgr:IsPVPMode() then
            IsNpcPlayAnim, NpcAnimDuration = ActorAnimService:PlayNpcEmoAnim(NpcAnimEnum.Emo_PlayerFailure)
        else
            -- 和NPC对战，播放的是表格配置的动作
            IsNpcPlayAnim, NpcAnimDuration = ActorAnimService:PlayNpcEmoAnim(NpcAnimEnum.Emo_PlayerSuccess)
        end
        ActorAnimService:PlaySettedEmoAnim(MagicCardLocalDef.SettedEmoTypeDefine.Victory, true)
        UIUtil.SetIsVisible(self.PanelWin, true)
        UIUtil.SetIsVisible(self.PanelDraw, false)
        UIUtil.SetIsVisible(self.PanelFaild, false)
        UIUtil.SetIsVisible(self.PanelUp, false)
        self:PlayAnimation(self.AnimWin)
    elseif self.ViewModel.BattleResult == BATTLE_RESULT.BATTLE_RESULT_FAIL then
        AnimIndex = NpcAnimEnum.Emo_PlayerFailure
        if MagicCardMgr:IsPVPMode() then
            IsNpcPlayAnim, NpcAnimDuration = ActorAnimService:PlayNpcEmoAnim(NpcAnimEnum.Emo_PlayerSuccess)
        else
            IsNpcPlayAnim, NpcAnimDuration = ActorAnimService:PlayNpcEmoAnim(NpcAnimEnum.Emo_PlayerFailure)
        end
        ActorAnimService:PlaySettedEmoAnim(MagicCardLocalDef.SettedEmoTypeDefine.Fail, true)
        UIUtil.SetIsVisible(self.PanelWin, false)
        UIUtil.SetIsVisible(self.PanelDraw, false)
        UIUtil.SetIsVisible(self.PanelFaild, true)
        UIUtil.SetIsVisible(self.PanelUp, true)
        self:PlayAnimation(self.AnimFaild)
    else
        AnimIndex = NpcAnimEnum.Emo_Draw
        IsNpcPlayAnim, NpcAnimDuration = ActorAnimService:PlayNpcEmoAnim(NpcAnimEnum.Emo_Draw)
        ActorAnimService:PlaySettedEmoAnim(MagicCardLocalDef.SettedEmoTypeDefine.Draw, true)
        UIUtil.SetIsVisible(self.PanelWin, false)
        UIUtil.SetIsVisible(self.PanelDraw, true)
        UIUtil.SetIsVisible(self.PanelFaild, false)
        UIUtil.SetIsVisible(self.PanelUp, true)
        self:PlayAnimation(self.AnimDraw)
    end

    local function StopAnimation()
        ActorAnimService:OnGameEnd()
    end
    self:RegisterTimer(StopAnimation, NpcAnimDuration)
    self:CheckMagicCardTourney()
end

function CardsGameResultPanelView:OnDestroy()

end

function CardsGameResultPanelView:SetLSTR()
	self.TextWin:SetText(_G.LSTR(1130052))--1130052("胜利")
    self.TextWin_Eff:SetText(_G.LSTR(1130052))--1130052("胜利")
	self.TextFaild:SetText(_G.LSTR(1130053))--1130053("失败:")
	self.TextDraw:SetText(_G.LSTR(1130054))--1130054("平局")
	self.TextReward:SetText(_G.LSTR(1130055))--1130055("奖励")
	self.TextUp:SetText(_G.LSTR(1130056))--1130056("提升幻卡收集")
    self.TextStage:SetText(_G.LSTR(1130057))--1130057("阶段效果")
    self.BtnLeave:SetButtonText(_G.LSTR(1130058))--1130058("离开")
    self.BtnAgain:SetButtonText(_G.LSTR(1130059))--1130059("再战")
end

function CardsGameResultPanelView:OnShow()
    self:SetLSTR()
    local _selfVM = self.ViewModel
    if (_selfVM ~= nil and self.Params ~= nil) then
        _selfVM:InitData(self.Params.Data)
        UIUtil.SetIsVisible(self.PanelRoot, false)
        self:DoShowView()

        -- 玩家的头像和名字
        self.HeadSlot01:SetInfo(MajorUtil.GetMajorRoleID(), PersonInfoDefine.SimpleViewSource.Default)
        self.PlayerName01:SetText(_selfVM.BlueTeamName)

        -- 对手的头像和名字
        if _selfVM.HeadIconPath then
            self.HeadSlot02:SetIcon(_selfVM.HeadIconPath)
        else
            self.HeadSlot02:SetInfo(_selfVM.OpponentRoleID)
        end
        self.PlayerName02:SetText(_selfVM.RedTeamName)

        local _battleStr = string.format(_G.LSTR(MagicCardLocalDef.UKeyConfig.Round), _selfVM.BattleRecordNum)
        self.TextTimes:SetText(_battleStr)
    end
    self.CommBtn:SetCallback(self, self.OnClickCommBtn)
    self.CommBtn:SetButtonStyle(3)
    _G.LootMgr:SetDealyState(false)
end

function CardsGameResultPanelView:OnHide()
    --self:PlayAnimation(self.AnimOut)
    self.Super:PlayAnimOut()
    ActorAnimService:StopMajorAnim()
    ActorAnimService:StopNpcAnim()
    MagicCardMgr:OnUserQuitGameWithDisConnect()
end

function CardsGameResultPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnLeave, self.OnFinishBtnClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnAgain, self.OnRestartBtnClicked)
end

function CardsGameResultPanelView:OnClickCommBtn()
    local Params = {}
    Params.InTagetView = self.CommBtn
    Params.Offset = TargetOffSet
	Params.Alignment = DefaultFVector2D
    _G.UIViewMgr:ShowView(_G.UIViewID.MagicCardShowGetWayView, Params)
end

function CardsGameResultPanelView:OnFinishBtnClicked()
    self:Hide()
    ActorAnimService:OnGameExit()
    self.ViewModel:OnQuitGame()
end

function CardsGameResultPanelView:OnRestartBtnClicked()
    if (MagicCardMgr.IsPVP) then
        -- 这里先退出，以后的PVP可能点击再战就是打开PVP大赛界面？
        self:OnFinishBtnClicked()
        MagicCardMgr:OnUserQuitGame()
        if MagicCardTourneyMgr:GetIsInTourney() == false then -- 换卡大赛
            MagicCardTourneyMgr:OnStartMatch() -- 开始匹配
        end
        return
    end
    
    MagicCardMgr:RestartGame(MagicCardMgr.CardGameId, true)
    self:Hide()
end

function CardsGameResultPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
end

function CardsGameResultPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

-- 处于幻卡大赛对局
function CardsGameResultPanelView:CheckMagicCardTourney()
    if MagicCardTourneyMgr:GetIsInTourney() == false then
        UIUtil.SetIsVisible(self.PanelStage, false)
        return
    end
    -- 阶段结算时，不能再战,隐藏按钮
    local IsShowAgainBtn = not TourneyVM:IsNeedStageSettlement()
    UIUtil.SetIsVisible(self.BtnAgain, IsShowAgainBtn)
    if TourneyVM:IsNeedStageSettlement() then
        self:PlayAnimation(self.AnimTips)
    end
    local IconPath = MagicCardTourneyDefine.ImgPath.Score

    -- 更新单局结束奖励
    local _selfVM = self.ViewModel
    _selfVM.RewardItemVMList = {}
    local _newVM = CardReadnessRewardItemVM.New()
    _newVM:SetIconImage(IconPath)
    local ResultScore = self:GetResultScore()
    _newVM:SetCount(ResultScore)
    table.insert(_selfVM.RewardItemVMList, _newVM)
    self.RewardTableViewAdapter:ClearChildren()
    self.RewardTableViewAdapter:UpdateAll(_selfVM.RewardItemVMList)

    -- 阶段效果结束，隐藏效果UI
    local IsStageEffectFinished = TourneyVM:IsCurStageEffectFinished()
    if IsStageEffectFinished then
        UIUtil.SetIsVisible(self.PanelStage, false)
        return
    end

    UIUtil.SetIsVisible(self.PanelStage, true)
    UIUtil.SetIsVisible(self.CommSlot, false)
    UIUtil.SetIsVisible(self.RichTextStageName, false)
    UIUtil.SetIsVisible(self.RichTextStagProgress, false)
    UIUtil.SetIsVisible(self.RichTextOngoing, false)
    UIUtil.SetIsVisible(self.PanelUp, false)
    UIUtil.SetIsVisible(self.TextTimes, false)
    
    
    local SelectEffectInfo = TourneyVM.CurEffectInfo or {}
    local EffectData = TourneyVMUtils.GetEffectInfoByEffectID(SelectEffectInfo.EffectID)
    self.CommSlot:SetIconImg(IconPath)

    if EffectData then
        local StageWinScore = EffectData.StageWinScore
        local StageLoseScore = EffectData.StageLoseScore
        local WinScore = EffectData.WinScore -- 单局奖励
        local LoseScore = EffectData.LoseScore
        --阶段与效果进度
        local EffectStateText = string.format("%s：%s", EffectData.EffectName, TourneyVM:GetCurStageEffectStatusText())
        self.RichTextStageName:SetText(EffectStateText)
        local CurEffectID = TourneyVM:GetCurStageEffectID()
        if TourneyVMUtils.IsNeedShowEfectProgress(CurEffectID, true) then
            if EffectData.Arg and EffectData.Arg > 0 then
                if TourneyVM.EffectProgress and TourneyVM.EffectArg then
                    local ProgressText = string.format(_G.LSTR(MagicCardLocalDef.UKeyConfig.CurProgress), TourneyVM.EffectProgress, TourneyVM.EffectArg)
                    self.RichTextStagProgress:SetText(ProgressText)
                end
            end
            self.RichTextOngoing:SetText(TourneyVM.EffectAndProgressText)
        else
            self.RichTextStagProgress:SetText("")
            self.RichTextOngoing:SetText(EffectStateText)
        end

        --结果图标
        local EffectStatus = TourneyVM:GetCurStageEffectStatus()
        if EffectStatus == ProtoCS.EFFECT_STATUS.EFFECT_STATUS_IN_PROGRESS then
            local EffectScore = self:GetResultEffectScore(CurEffectID, TourneyVM.EffectProgress, TourneyVM.EffectArg)
            if not string.isnilorempty(EffectScore) then -- 单局效果
                UIUtil.SetIsVisible(self.RichTextStageName, true)
                UIUtil.SetIsVisible(self.RichTextStagProgress, true)
                UIUtil.SetIsVisible(self.CommSlot, true)
                self.CommSlot:SetNum(EffectScore)
            else
                UIUtil.SetIsVisible(self.RichTextOngoing, true)
            end
        elseif EffectStatus == ProtoCS.EFFECT_STATUS.EFFECT_STATUS_FAIL then
            UIUtil.SetIsVisible(self.RichTextStageName, true)
            UIUtil.SetIsVisible(self.RichTextStagProgress, true)
            if not string.isnilorempty(StageLoseScore) then
                UIUtil.SetIsVisible(self.CommSlot, true)
                self.CommSlot:SetNum(StageLoseScore)
            elseif not string.isnilorempty(LoseScore) then
                UIUtil.SetIsVisible(self.CommSlot, true)
                self.CommSlot:SetNum(LoseScore)
            end
        elseif EffectStatus == ProtoCS.EFFECT_STATUS.EFFECT_STATUS_SUCCESS then
            UIUtil.SetIsVisible(self.RichTextStageName, true)
            UIUtil.SetIsVisible(self.RichTextStagProgress, true)
            if not string.isnilorempty(StageWinScore) then
                UIUtil.SetIsVisible(self.CommSlot, true)
                self.CommSlot:SetNum(StageWinScore)
            elseif not string.isnilorempty(WinScore) then
                UIUtil.SetIsVisible(self.CommSlot, true)
                self.CommSlot:SetNum(WinScore)
            end
        end
    end
    
   
end

-- 单局比赛结束积分
function CardsGameResultPanelView:GetResultScore()
    local OpponentInfo = MagicCardMgr:GetOpponentInfo()
    if (OpponentInfo == nil) then
        return
    end

    if self.ViewModel.BattleResult == BATTLE_RESULT.BATTLE_RESULT_WIN then
        return OpponentInfo.WinAward or 0
    elseif self.ViewModel.BattleResult == BATTLE_RESULT.BATTLE_RESULT_FAIL then
        return  OpponentInfo.FailAward or 0
    else
        return OpponentInfo.TieAward or 0
    end
end

-- 单局比赛结束效果加成积分
function CardsGameResultPanelView:GetResultEffectScore(EffectID, EffectProgress, EffectArg)
    local AwardInfo = TourneyVMUtils.GetCurEffectAwardScore(EffectID)
    if AwardInfo == nil then
        return 0
    end

    local Result = self.ViewModel.BattleResult
    -- 单局翻牌,按翻牌进度算输赢
    if AwardInfo.Type == ProtoRes.Game.fantasy_tournament_effect_type.FANTASY_TOURNAMENT_EFFECT_TYPE_BATTLE_FLIP then
        if EffectProgress and EffectArg then
            if EffectProgress >= EffectArg then
                Result = BATTLE_RESULT.BATTLE_RESULT_WIN
            else
                Result = BATTLE_RESULT.BATTLE_RESULT_FAIL
            end
        end
    end

    if Result == BATTLE_RESULT.BATTLE_RESULT_WIN then
        return AwardInfo.Win
    elseif Result == BATTLE_RESULT.BATTLE_RESULT_FAIL then
        return AwardInfo.Lose
    else
        return 0
    end
end

-- 进入副本之前都会发退出前一个可以直接监听这个消息
function CardsGameResultPanelView:OnPWorldExit()
    MagicCardMgr:OnUserQuitGame()
    self:Hide()
end

return CardsGameResultPanelView
