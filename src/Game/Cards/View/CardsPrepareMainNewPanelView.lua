---
--- Author: MichaelYang_LightPaw
--- DateTime: 2024-01-15 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CardsPrepareMainNewPanelViewVM = require("Game/Cards/VM/CardsPrepareMainNewPanelViewVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local LSTR = _G.LSTR

---@class CardsPrepareMainNewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG UFImage
---@field BtnAutomatic UFButton
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnEditName UFButton
---@field BtnSave UFButton
---@field BtnTips CommInforBtnView
---@field BtnTips_1 UFButton
---@field CanvasCountdown UFCanvasPanel
---@field CardRulesDescPanel UFCanvasPanel
---@field CardsDecksNewPanel01 CardsDecksNewPanelView
---@field CardsDecksNewPanel02 CardsDecksNewPanel02View
---@field CardsDecksNewPanel03 CardsDecksNewPanel03View
---@field CommInforBtn CommInforBtnView
---@field CommTabsModule CommVerIconTabsView
---@field CommonTitle_UIBP CommonTitleView
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---@field FImage_54 UFImage
---@field IconBlank USpacer
---@field IconTitle UFImage
---@field IconTitle_1 UFImage
---@field ImgSave UFImage
---@field PanelIcon UFCanvasPanel
---@field PanelIcon_1 UFCanvasPanel
---@field PanelMain02 UFCanvasPanel
---@field PanelMain03 UFCanvasPanel
---@field PrepareEmoActPage CardsPrepareEmoActPanelView
---@field PrepareRulePage CardsPrepareRulePanelView
---@field TextAutomatic UFTextBlock
---@field TextCardNumNotEnough UFTextBlock
---@field TextCountdownTitle UFTextBlock
---@field TextCountdownValue UFTextBlock
---@field TextName UFTextBlock
---@field TextNameForEdit UFTextBlock
---@field TextSave UFTextBlock
---@field TextStarOverLimit UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitle_1 UFTextBlock
---@field Text_CardRules UFTextBlock
---@field Text_Subrule UFTextBlock
---@field Text_Subrule2 UFTextBlock
---@field Text_Subrule2_1 UFTextBlock
---@field Text_Subrule2_2 UFTextBlock
---@field Text_Subrule2_3 UFTextBlock
---@field Text_Subrule2_4 UFTextBlock
---@field Text_Subrule2_5 UFTextBlock
---@field Text_Subrule3 UFTextBlock
---@field AnimDeck UWidgetAnimation
---@field AnimEditCard UWidgetAnimation
---@field AnimEditDeck UWidgetAnimation
---@field AnimEmoAct UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimRulePage UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsPrepareMainNewPanelView = LuaClass(UIView, true)

function CardsPrepareMainNewPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnAutomatic = nil
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnEditName = nil
	--self.BtnSave = nil
	--self.BtnTips = nil
	--self.BtnTips_1 = nil
	--self.CanvasCountdown = nil
	--self.CardRulesDescPanel = nil
	--self.CardsDecksNewPanel01 = nil
	--self.CardsDecksNewPanel02 = nil
	--self.CardsDecksNewPanel03 = nil
	--self.CommInforBtn = nil
	--self.CommTabsModule = nil
	--self.CommonTitle_UIBP = nil
	--self.Common_PopUpBG_UIBP = nil
	--self.FImage_54 = nil
	--self.IconBlank = nil
	--self.IconTitle = nil
	--self.IconTitle_1 = nil
	--self.ImgSave = nil
	--self.PanelIcon = nil
	--self.PanelIcon_1 = nil
	--self.PanelMain02 = nil
	--self.PanelMain03 = nil
	--self.PrepareEmoActPage = nil
	--self.PrepareRulePage = nil
	--self.TextAutomatic = nil
	--self.TextCardNumNotEnough = nil
	--self.TextCountdownTitle = nil
	--self.TextCountdownValue = nil
	--self.TextName = nil
	--self.TextNameForEdit = nil
	--self.TextSave = nil
	--self.TextStarOverLimit = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.TextTitle_1 = nil
	--self.Text_CardRules = nil
	--self.Text_Subrule = nil
	--self.Text_Subrule2 = nil
	--self.Text_Subrule2_1 = nil
	--self.Text_Subrule2_2 = nil
	--self.Text_Subrule2_3 = nil
	--self.Text_Subrule2_4 = nil
	--self.Text_Subrule2_5 = nil
	--self.Text_Subrule3 = nil
	--self.AnimDeck = nil
	--self.AnimEditCard = nil
	--self.AnimEditDeck = nil
	--self.AnimEmoAct = nil
	--self.AnimIn = nil
	--self.AnimRulePage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.ViewModel = CardsPrepareMainNewPanelViewVM:New()
end

function CardsPrepareMainNewPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnTips)
	self:AddSubView(self.CardsDecksNewPanel01)
	self:AddSubView(self.CardsDecksNewPanel02)
	self:AddSubView(self.CardsDecksNewPanel03)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommTabsModule)
	self:AddSubView(self.CommonTitle_UIBP)
	self:AddSubView(self.Common_PopUpBG_UIBP)
	self:AddSubView(self.PrepareEmoActPage)
	self:AddSubView(self.PrepareRulePage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsPrepareMainNewPanelView:OnInit()
    --- 这个是拖拽的
    local _dragItemView = _G.UIViewMgr:CreateView(_G.UIViewID.MagicCardBigCardItem, self, true)
    _dragItemView:ShowView(
        {
            Data = self.ViewModel.CardsEditDecksPanelVM:GetDragVisualCardVM()
        }
    )
    self.ViewModel.CardsEditDecksPanelVM.DragVisualCardItemView = _dragItemView
    _dragItemView:HideView()

    local SelfBinders = {
        {
            "CheckNotify",
            UIBinderValueChangedCallback.New(self, nil, self.OnIsAllRulePassChanged)
        }
    }
    self.BinderForGroupVMBinders = SelfBinders
    local Binders = {
        {
            "GroupName",
            UIBinderSetText.New(self, self.TextName)
        },
        {
            "GroupName",
            UIBinderSetText.New(self, self.TextNameForEdit)
        }
    }
    self.CardsDecksPageVMBinders = Binders
    if (self.ParentVM ~= nil and self.ParentVM.TimeWaitForMatchStart ~= nil) then
        UIUtil.SetIsVisible(self.CanvasCountdown, true)
    else
        UIUtil.SetIsVisible(self.CanvasCountdown, false)
    end
    UIUtil.SetIsVisible(self.TextStarOverLimit, false)
    UIUtil.SetIsVisible(self.TextCardNumNotEnough, false)

    self.TabAnimMap = 
    {
        [1] = self.AnimDeck,
        [2] = self.AnimEmoAct,
        [3] = self.AnimRulePage,
    }
    self.PrepareRulePage:SetViewModel(self.ViewModel)
end

function CardsPrepareMainNewPanelView:OnIsAllRulePassChanged(NewValue, OldValue)
    local _cardGroupVM = self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM
    local _isAllRolePass = _cardGroupVM.IsAllRulePass
    if (_isAllRolePass) then
        UIUtil.SetIsVisible(self.TextStarOverLimit, false)
        UIUtil.SetIsVisible(self.TextCardNumNotEnough, false)
    else
        if (not _cardGroupVM.CheckRuleCardNum) then
            UIUtil.SetIsVisible(self.TextCardNumNotEnough, true)
            UIUtil.SetIsVisible(self.TextStarOverLimit, false)
        else
            UIUtil.SetIsVisible(self.TextCardNumNotEnough, false)
            UIUtil.SetIsVisible(self.TextStarOverLimit, true)
        end
    end
end

function CardsPrepareMainNewPanelView:OnDestroy()
end

function CardsPrepareMainNewPanelView:SetLSTR()
    self.TextTitle:SetText(_G.LSTR(1130080))--("幻卡备战")
	self.TextTitle_1:SetText(_G.LSTR(1130040))--1130040("编辑卡组")
	self.TextCountdownTitle:SetText(_G.LSTR(1130041))--1130041("开局倒计时:")
	self.TextAutomatic:SetText(_G.LSTR(1130042))--1130042("自动组卡")
	self.TextSave:SetText(_G.LSTR(1130043))--1130043("保存")
	self.Text_CardRules:SetText(_G.LSTR(1130044))--1130044("卡组规则")
    self.Text_Subrule:SetText(_G.LSTR(1130045))--1130045("5仅能编入一张")
    self.Text_Subrule2_3:SetText(_G.LSTR(1130046))--1130046("4幻卡：")
    self.Text_Subrule2_4:SetText(_G.LSTR(1130047))--1130047("无")
    self.Text_Subrule2_1:SetText(_G.LSTR(1130048))--1130048("5幻卡时最多编入2张")
    self.Text_Subrule2_5:SetText(_G.LSTR(1130049))--1130049("有")
    self.Text_Subrule2_2:SetText(_G.LSTR(1130050))--1130050("5幻卡时最多编入1张")
    self.Text_Subrule3:SetText(_G.LSTR(1130051))--1130051("3及一下幻卡：无限制")
    self.TextStarOverLimit:SetText(_G.LSTR(1130093)) --("星级超过限制")
    self.TextCardNumNotEnough:SetText(_G.LSTR(1130094)) --("幻卡数量不足5张")
end

function CardsPrepareMainNewPanelView:OnShow()
    self:SetLSTR()
    self:PlayAnimation(self.AnimStart)
    UIUtil.SetIsVisible(self.CardsDecksNewPanel01, false, true)
    UIUtil.SetIsVisible(self.CardsDecksNewPanel01, true, true)
    self.CardsDecksNewPanel01.IsFirstPlay = true
    UIUtil.SetIsVisible(self.PrepareEmoActPage, false)
    UIUtil.SetIsVisible(self.PrepareRulePage, false)
    self.IsFirst = true
    local Params = self.Params
    _G.ClientSetupMgr:SendQueryReq({ProtoCS.ClientSetupKey.FantacyCardEmoList})
    self.ViewModel:OnRefresh()
    -- UIUtil.SetIsVisible(self.BtnBack, false)
    -- UIUtil.SetIsVisible(self.PanelMain03, false)
    -- UIUtil.SetIsVisible(self.PrepareEmoActPage, false)
    -- UIUtil.SetIsVisible(self.BtnClose, true, true)
    UIUtil.SetIsVisible(self.CardRulesDescPanel, false)
    -- UIUtil.SetIsVisible(self.Common_PopUpBG_UIBP, false)
    self.ViewModel.LeftTabSelectIndex = 1
    self.CommTabsModule:UpdateItems(self.ViewModel.LeftTablIconList, self.ViewModel.LeftTabSelectIndex)
    self.ViewModel:UpdateRuleVMList()
end

function CardsPrepareMainNewPanelView:OnClickEditBtn()
    -- 这里播放一下编辑的动画
    self:PlayAnimation(self.AnimEditCard)

    -- 检测一下合理性
    local _currentSelectVM = self.ViewModel.CardsDecksPageVM.CurrentSelectItemVM
    if (_currentSelectVM ~= nil and _currentSelectVM.GroupCardList ~= nil) then
        local _cardIDList = {}
        for i = 1, #_currentSelectVM.GroupCardList do
            _cardIDList[i] = _currentSelectVM.GroupCardList[i]:GetCardId()
        end
        self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM:SetGroupCardList(_cardIDList)
    else
        self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM:SetGroupCardList(nil)
    end

    self:OnIsAllRulePassChanged()
    -- 检测完成

    -- 检测一下所有卡牌的有效性
    self.ViewModel.CardsEditDecksPanelVM:UpdateOwnedCardListToShowWithFilter()
    -- 检测完成

    self.ViewModel.CanDragCard = true
end

function CardsPrepareMainNewPanelView:OnHide()
    MagicCardMgr:OnEnterCardState(false)
end

function CardsPrepareMainNewPanelView:OnRegisterUIEvent()
    self.BtnClose:SetCallback(self, self.OnClickButtonClose)
    self.BtnBack:AddBackClick(self, self.OnClickBtnBack)
    UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickBtnSave)
    UIUtil.AddOnClickedEvent(self, self.BtnEditName, self.OnGroupNameChange)
    UIUtil.AddOnSelectionChangedEvent(self, self.CommTabsModule, self.OnCommVerIconTabsChanged)
    UIUtil.AddOnClickedEvent(self, self.BtnAutomatic, self.OnClickBtnAutomatic)
end

--- 自动组卡
function CardsPrepareMainNewPanelView:OnClickBtnAutomatic()
    _G.MagicCardMgr:SendGroupAutoEditReq(self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM:GetServerIndex())
end


--- 左边的栏目选择变动了
function CardsPrepareMainNewPanelView:OnCommVerIconTabsChanged(CurIndex)
    self.ViewModel:SetLeftTabSelectIndex(CurIndex)
    self.TextSubtitle:SetText(LocalDef.EditType[CurIndex] or "")
    self:ShowCurSelectPanel(CurIndex)
end

function CardsPrepareMainNewPanelView:ShowCurSelectPanel(CurIndex)
    UIUtil.SetIsVisible(self.PrepareEmoActPage, CurIndex == 2)
    UIUtil.SetIsVisible(self.PrepareRulePage, CurIndex == 3)
    local TabAnim = self.TabAnimMap[CurIndex]
    if (CurIndex == 1) then
        -- 显示卡组信息
        if(self.IsFirst) then
            self.IsFirst = false
            return
        end
    else
        self:StopAllAnimations()
        local AnimTime = self.AnimIn:GetEndTime()
        self:PlayAnimationTimeRange(self.AnimIn, AnimTime, AnimTime, 1, nil, 1.0, false)
    end
    self:PLayAnimation(TabAnim)
end

function CardsPrepareMainNewPanelView:OnGroupNameChange()
    local _targetVM = self.ViewModel.CardsEditDecksPanelVM
    local function OnOkCallback(Text)
        _targetVM.EditGroupCardVM.GroupName = Text
        self.ViewModel.CardsDecksPageVM.CurrentSelectItemVM.GroupName = Text
        -- 这里直接保存
        self.ViewModel.CardsDecksPageVM.CurrentSelectItemVM:SaveEditGroup()
    end
    _G.UIViewMgr:ShowView(
        _G.UIViewID.MagicCardEditGroupNameView, {
            OrigName = _targetVM.EditGroupCardVM.GroupName,
            OnOkCallback = OnOkCallback
        }
    )
end

--- 点击保存
function CardsPrepareMainNewPanelView:OnClickBtnSave()
    local _editGroupCardVM = self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM
    if not _editGroupCardVM.IsAllRulePass then
        -- 先看一下，如果是默认卡组，那么提示不让保存
        if (_editGroupCardVM.IsDefaultGroup) then
            local _finalStr = LSTR(LocalDef.UKeyConfig.CanNotSave)
            MsgBoxUtil.ShowMsgBoxOneOpRight(
                self, LSTR(LocalDef.UKeyConfig.Hint), _finalStr, nil, nil, LSTR(LocalDef.UKeyConfig.CommonCancel), LSTR(LocalDef.UKeyConfig.CommonConfirm), nil
            )
        elseif (not _editGroupCardVM.CheckRuleCardNum) then
            local _finalStr = LSTR(LocalDef.UKeyConfig.CardNumLessFive)
            self:ShowSaveWarning(_finalStr)
        elseif (not _editGroupCardVM.CheckRuleFourStarCard or not _editGroupCardVM.CheckRuleFiveStarCard) then
            local _finalStr = LSTR(LocalDef.UKeyConfig.CardStarOverLimit)
            self:ShowSaveWarning(_finalStr)
        end
    else
        self:InternalTrySave()
    end
end

function CardsPrepareMainNewPanelView:ShowSaveWarning(WarningStr)
    local function Confirm()
        self:InternalTrySave()
    end
    MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(LocalDef.UKeyConfig.Hint), WarningStr, Confirm, nil, LSTR(LocalDef.UKeyConfig.CommonCancel), LSTR(LocalDef.UKeyConfig.CommonConfirm))
end

function CardsPrepareMainNewPanelView:InternalTrySave()
    self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM:SaveEditGroup()
end

function CardsPrepareMainNewPanelView:OnClickButtonClose()
    _G.UIViewMgr:HideView(_G.UIViewID.MagicCardPrepareMainPanel)
end

function CardsPrepareMainNewPanelView:OnClickBtnBack()
    local _anyChange = false

    if(self.ViewModel ~= nil and self.ViewModel.CardsEditDecksPanelVM ~= nil and self.ViewModel.CardsDecksPageVM ~= nil and
        self.ViewModel.CardsDecksPageVM.CurrentSelectItemVM ~= nil and
        self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM ~= nil) then
        local _editCardList = self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM.GroupCardList
        local _realCardList = self.ViewModel.CardsDecksPageVM.CurrentSelectItemVM.GroupCardList
        for i = 1, LocalDef.CardCountInGroup do
            if (_editCardList[i]:GetCardId() ~= _realCardList[i]:GetCardId()) then
                _anyChange = true
                break
            end
        end
    end

    if (_anyChange) then
        -- 有任何改动，这里去提示一下
        self:ShowSaveMentionBox()
    else
        local _isInGameConfirm = false -- 是否在准备进入对局的情况了
        if (_isInGameConfirm ) then
            _G.UIViewMgr:HideView(_G.UIViewID.MagicCardPrepareMainPanel)
        else
            -- 播放一个返回动画
            self:StopAllAnimations()
            self:PlayAnimation(self.AnimEditDeck)
            self.ViewModel.CanDragCard = false
        end
    end
end

function CardsPrepareMainNewPanelView:ShowSaveMentionBox()
    local Params = {}

    local function confirm()
        -- 播放一个返回动画
        self:StopAllAnimations()
        self:PlayAnimation(self.AnimEditDeck)
        self.ViewModel.CanDragCard = false

        -- 这里要将编辑窗口的还原
        local _targetVM = self.ViewModel.CardsDecksPageVM.CurrentSelectItemVM
        self.ViewModel.CardsEditDecksPanelVM:SetEditGroupCardVM(_targetVM)
    end

    Params.CloseBtnCallback = self.OnClickKeepBtn
    MsgBoxUtil.ShowMsgBoxTwoOp(
        self, LSTR(LocalDef.UKeyConfig.Hint), LSTR(LocalDef.UKeyConfig.ExitConfirm), confirm,
        nil, LSTR(LocalDef.UKeyConfig.CommonCancel), LSTR(LocalDef.UKeyConfig.CommonConfirm), Params
    )
end

function CardsPrepareMainNewPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MagicCardOnNetEditGroupRsp, self.OnGameEventEditGroupRsp)
    self:RegisterGameEvent(EventID.MagicCardChangedName, self.OnMagicCardChangedName)
end

function CardsPrepareMainNewPanelView:OnMagicCardChangedName()
    self.ViewModel.CardsDecksPageVM:RefreshGroupName()
end

function CardsPrepareMainNewPanelView:OnGameEventEditGroupRsp(CardGroupId, CardIDList)
    self.ViewModel.CardsEditDecksPanelVM:OnEditGroupReturn(CardGroupId, CardIDList)
end

function CardsPrepareMainNewPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel.CardsEditDecksPanelVM.EditGroupCardVM, self.BinderForGroupVMBinders)
    self:RegisterBinders(self.ViewModel.CardsDecksPageVM, self.CardsDecksPageVMBinders)
end

return CardsPrepareMainNewPanelView
