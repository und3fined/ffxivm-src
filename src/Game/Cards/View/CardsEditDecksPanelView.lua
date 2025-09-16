---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-10-23 15:01
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CardCfg = require("TableCfg/FantasyCardCfg")
local UIAdapterPanelWidget = require("UI/Adapter/UIAdapterPanelWidget")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local CardsEditDecksPanelVM = require("Game/Cards/VM/CardsEditDecksPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local CardsGroupCardVM = require("Game/Cards/VM/CardsGroupCardVM")
local EventID = require("Define/EventID")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ColorDefine = require("Define/ColorDefine")
local ColorUtil = require("Utils/ColorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE
local LSTR = _G.LSTR

---@class CardsEditDecksPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAutomatic UFButton
---@field BtnBack CommBackBtnView
---@field BtnEditName UFButton
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field BtnSave UFButton
---@field BtnTips UFButton
---@field BtnTips_1 UFButton
---@field CanvasCountdown UFCanvasPanel
---@field Card01 CardsBigCardItemView
---@field Card02 CardsBigCardItemView
---@field Card03 CardsBigCardItemView
---@field Card04 CardsBigCardItemView
---@field Card05 CardsBigCardItemView
---@field CardRulesDescPanel UFCanvasPanel
---@field CardsEditDecksCardsPage CardsEditDecksCardsPageView
---@field CommInforBtn_UIBP CommInforBtnView
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---@field IconTitle UFImage
---@field ImgSave UFImage
---@field PanelBtnInfo UFCanvasPanel
---@field PanelDecks UFCanvasPanel
---@field PanelIcon UFCanvasPanel
---@field TableViewSift UTableView
---@field TextAutomatic UFTextBlock
---@field TextCardNumNotEnough UFTextBlock
---@field TextCountdownTitle UFTextBlock
---@field TextCountdownValue UFTextBlock
---@field TextName UFTextBlock
---@field TextPageInfo UFTextBlock
---@field TextSave UFTextBlock
---@field TextStarOverLimit UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTotalCardNum UFTextBlock
---@field Text_CardRules UFTextBlock
---@field Text_Subrule UFTextBlock
---@field Text_Subrule2 UFTextBlock
---@field Text_Subrule2_1 UFTextBlock
---@field Text_Subrule2_2 UFTextBlock
---@field Text_Subrule2_3 UFTextBlock
---@field Text_Subrule2_4 UFTextBlock
---@field Text_Subrule2_5 UFTextBlock
---@field Text_Subrule3 UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsEditDecksPanelView = LuaClass(UIView, true)

function CardsEditDecksPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnAutomatic = nil
    -- self.BtnBack = nil
    -- self.BtnEditName = nil
    -- self.BtnSave = nil
    -- self.BtnTips = nil
    -- self.Card01 = nil
    -- self.Card02 = nil
    -- self.Card03 = nil
    -- self.Card04 = nil
    -- self.Card05 = nil
    -- self.ImgSave = nil
    -- self.TableViewSift = nil
    -- self.TextName = nil
    -- self.TextQuantity_1 = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.ViewModel = CardsEditDecksPanelVM.New()
end

function CardsEditDecksPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnBack)
    self:AddSubView(self.Card01)
    self:AddSubView(self.Card02)
    self:AddSubView(self.Card03)
    self:AddSubView(self.Card04)
    self:AddSubView(self.Card05)
    self:AddSubView(self.CardsEditDecksCardsPage)
    self:AddSubView(self.Common_PopUpBG_UIBP)
    self:AddSubView(self.CommInforBtn_UIBP)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY

    self.CardsEditDecksCardsPage:SetParentVM(self.ViewModel)
end

function CardsEditDecksPanelView:OnInit()
    self.Common_PopUpBG_UIBP:SetCallback(self, self.OnClickCommonPopUpBG)
    self.Common_PopUpBG_UIBP:SetHideOnClick(false)

    --- 这个是拖拽的
    local _dragItemView = _G.UIViewMgr:CreateView(_G.UIViewID.MagicCardBigCardItem, self, true)
    _dragItemView:ShowView(
        {
            Data = self.ViewModel:GetDragVisualCardVM()
        }
    )
    self.ViewModel.DragVisualCardItemView = _dragItemView
    _dragItemView:HideView()

    -- 这个是当前编队的
    self.PanelDecksAdapter = UIAdapterPanelWidget.CreateAdapter(self, self.PanelDecks)

    self.FilterTablViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSift, nil)

    local BinderForGroupVM = {
        {
            "GroupCardList",
            UIBinderUpdateBindableList.New(self, self.PanelDecksAdapter)
        },
        {
            "GroupName",
            UIBinderSetText.New(self, self.TextName)
        },
        {
            "CheckNotify",
            UIBinderValueChangedCallback.New(self, nil, self.OnIsAllRulePassChanged)
        }
    }
    local BinderForSelfVM = {
        {
            "FilterTabDataList",
            UIBinderUpdateBindableList.New(self, self.FilterTablViewAdapter)
        },
        {
            "BGFrameState",
            UIBinderValueChangedCallback.New(self, nil, self.OnBGFrameStateChange)
        },
        {
            "CurrentPageNum",
            UIBinderValueChangedCallback.New(self, nil, self.OnTextPageInfoChanged)
        },
        {
            "OwnedCardNumWithFilter",
            UIBinderValueChangedCallback.New(self, nil, self.OnOwnedCardNumWithFilterChanged)
        }
    }
    self.BinderForGroupVM = BinderForGroupVM
    self.BinderForSelfVM = BinderForSelfVM
    UIUtil.SetIsVisible(self.TextStarOverLimit, false)
    UIUtil.SetIsVisible(self.TextCardNumNotEnough, false)
end

function CardsEditDecksPanelView:OnClickCommonPopUpBG()
    UIUtil.SetIsVisible(self.CardRulesDescPanel, false)
    UIUtil.SetIsVisible(self.Common_PopUpBG_UIBP, false)
end

function CardsEditDecksPanelView:OnIsAllRulePassChanged(NewValue, OldValue)
    local _isAllRolePass = self.ViewModel.EditGroupCardVM.IsAllRulePass
    if (_isAllRolePass) then
        UIUtil.SetIsVisible(self.TextStarOverLimit, false)
        UIUtil.SetIsVisible(self.TextCardNumNotEnough, false)
    else
        local _cardGroupVM = self.ViewModel.EditGroupCardVM
        if (not _cardGroupVM.CheckRuleCardNum) then
            UIUtil.SetIsVisible(self.TextCardNumNotEnough, true)
            UIUtil.SetIsVisible(self.TextStarOverLimit, false)
        else
            UIUtil.SetIsVisible(self.TextCardNumNotEnough, false)
            UIUtil.SetIsVisible(self.TextStarOverLimit, true)
        end
    end
end

function CardsEditDecksPanelView:OnOwnedCardNumWithFilterChanged(NewValue, OldValue)
    self.TextTotalCardNum:SetText(string.format(LSTR(LocalDef.UKeyConfig.CardCount), self.ViewModel.OwnedCardNumWithFilter))
end

function CardsEditDecksPanelView:OnTextPageInfoChanged(NewValue, OldValue)
    self.TextPageInfo:SetText(string.format("%d / %d", self.ViewModel.CurrentPageNum, self.ViewModel.TotalPagesNumber))
    if (self.ViewModel.TotalPagesNumber == 1) then
        -- 全部disable
        self.BtnLeft:SetIsEnabled(false)
        self.BtnRight:SetIsEnabled(false)
    elseif (self.ViewModel.CurrentPageNum == 1) then
        -- 往前翻页禁用
        self.BtnLeft:SetIsEnabled(false)
        self.BtnRight:SetIsEnabled(true)
    elseif (self.ViewModel.CurrentPageNum == self.ViewModel.TotalPagesNumber) then
        -- 往后翻页禁用
        self.BtnLeft:SetIsEnabled(true)
        self.BtnRight:SetIsEnabled(false)
    else
        -- 翻页前后按钮都enable
        self.BtnLeft:SetIsEnabled(true)
        self.BtnRight:SetIsEnabled(true)
    end
end

function CardsEditDecksPanelView:ShowSaveMentionBox()
    local Params = {}

    local function confirm()
        _G.UIViewMgr:HideView(_G.UIViewID.MagicCardEditPanel)
    end

    Params.CloseBtnCallback = self.OnClickKeepBtn
    MsgBoxUtil.ShowMsgBoxTwoOp(
        self, LSTR(LocalDef.UKeyConfig.Hint), LSTR(LocalDef.UKeyConfig.ExitConfirm), confirm,
        nil, LSTR(LocalDef.UKeyConfig.CommonCancel), LSTR(LocalDef.UKeyConfig.CommonConfirm), Params
    )
end

function CardsEditDecksPanelView:OnClickButtonClose()
    local _editCardList = self.ViewModel.EditGroupCardVM.GroupCardList
    local _realCardList = self.ViewModel.RealCardGroupVM.GroupCardList

    local _anyChange = false

    for i = 1, LocalDef.CardCountInGroup do
        if (_editCardList[i]:GetCardId() ~= _realCardList[i]:GetCardId()) then
            _anyChange = true
            break
        end
    end

    if (_anyChange) then
        -- 有任何改动，这里去提示一下
        self:ShowSaveMentionBox()
    else
        _G.UIViewMgr:HideView(_G.UIViewID.MagicCardEditPanel)
    end
end

function CardsEditDecksPanelView:OnBGFrameStateChange(NewValue, OldValue)
    self.CardsEditDecksCardsPage:SetCardPoolFrameState(NewValue)
end

function CardsEditDecksPanelView:OnDestroy()

end

function CardsEditDecksPanelView:OnShow()
    self:SetLSTR()
    self.ViewModel.RealCardGroupVM = nil
    if(self.Params ~=nil and self.Params.Data ~= nil) then
        self.ViewModel.RealCardGroupVM = self.Params.Data
    end

    self.ViewModel:UpdateOwnedCardListToShowWithFilter()
    self:OnTextPageInfoChanged()
    self:OnOwnedCardNumWithFilterChanged()
    UIUtil.SetIsVisible(self.CardRulesDescPanel, false)
    UIUtil.SetIsVisible(self.Common_PopUpBG_UIBP, false)
    self.ViewModel.DragVisualCardItemView:HideView()

    if (self.ParentVM ~= nil and self.ParentVM.TimeWaitForMatchStart ~= nil) then
        UIUtil.SetIsVisible(self.CanvasCountdown, true)
    else
        UIUtil.SetIsVisible(self.CanvasCountdown, false)
    end
end

function CardsEditDecksPanelView:SetLSTR()
	self.TextTitle:SetText(_G.LSTR(1130040))--1130040("编辑卡组")
	self.TextCountdownTitle:SetText(_G.LSTR(1130041))--1130041("开局倒计时:")
	self.TextAutomatic:SetText(_G.LSTR(1130042))--1130042("自动组卡")
	self.TextSave:SetText(_G.LSTR(1130043))--1130043("保存")
	self.Text_CardRules:SetText(_G.LSTR(1130044))--1130044("卡组规则")
    self.Text_Subrule:SetText(_G.LSTR(1130045))--1130045("5仅能编入一张")
    self.Text_Subrule2:SetText(_G.LSTR(1130046))--1130046("4幻卡：")
    self.Text_Subrule2_4:SetText(_G.LSTR(1130047))--1130047("无")
    self.Text_Subrule2_1:SetText(_G.LSTR(1130048))--1130048("5幻卡时最多编入2张")
    self.Text_Subrule2_5:SetText(_G.LSTR(1130049))--1130049("有")
    self.Text_Subrule2_2:SetText(_G.LSTR(1130050))--1130050("5幻卡时最多编入1张")
    self.Text_Subrule3:SetText(_G.LSTR(1130051))--1130051("3及一下幻卡：无限制")
    self.TextStarOverLimit:SetText(_G.LSTR(1130093)) --("星级超过限制")
    self.TextCardNumNotEnough:SetText(_G.LSTR(1130094)) --("幻卡数量不足5张")
end

function CardsEditDecksPanelView:OnHide()
    self.ViewModel:OnHide()
    _G.EventMgr:SendEvent(_G.EventID.MagicCardChangedName)
    _G.UIViewMgr:HideView(_G.UIViewID.MagicCardEditGroupNameView)
end

function CardsEditDecksPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnClickButtonClose)
    UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickBtnSave)
    UIUtil.AddOnClickedEvent(self, self.BtnAutomatic, self.OnClickBtnAutomatic)
    UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnClickBtnLeft)
    UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnClickBtnRight)
    UIUtil.AddOnClickedEvent(self, self.BtnEditName, self.OnGroupNameChange)
    UIUtil.AddOnClickedEvent(self, self.BtnTips, self.OnClickBtnTips)
end

--- 显示TIPS
function CardsEditDecksPanelView:OnClickBtnTips()
    UIUtil.SetIsVisible(self.CardRulesDescPanel, true)
    UIUtil.SetIsVisible(self.Common_PopUpBG_UIBP, true)
end

function CardsEditDecksPanelView:OnGroupNameChange()
    local function OnOkCallback(Text)
        self.ViewModel.EditGroupCardVM.GroupName = Text
        self.ViewModel.RealCardGroupVM.GroupName = Text
        -- 这里直接保存
        self.ViewModel.RealCardGroupVM:SaveEditGroup()
    end
    _G.UIViewMgr:ShowView(
        _G.UIViewID.MagicCardEditGroupNameView, {
            OrigName = self.ViewModel.EditGroupCardVM.GroupName,
            OnOkCallback = OnOkCallback
        }
    )
end

function CardsEditDecksPanelView:OnClickBtnLeft()
    self.ViewModel:OnClickPrePageBtn()
end

function CardsEditDecksPanelView:OnClickBtnRight()
    self.ViewModel:OnClickNextPageBtn()
end

function CardsEditDecksPanelView:ShowSaveWarning(WarningStr)
    local function Confirm()
        self:InternalTrySave()
    end
    MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(LocalDef.UKeyConfig.Hint), WarningStr, Confirm, nil, LSTR(LocalDef.UKeyConfig.CommonCancel), LSTR(LocalDef.UKeyConfig.CommonConfirm))
end

function CardsEditDecksPanelView:InternalTrySave()
    self.ViewModel.EditGroupCardVM:SaveEditGroup()
end

--- 点击保存
function CardsEditDecksPanelView:OnClickBtnSave()
    local _editGroupCardVM = self.ViewModel.EditGroupCardVM
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

--- 自动组卡
function CardsEditDecksPanelView:OnClickBtnAutomatic()
    MagicCardMgr:SendGroupAutoEditReq(self.ViewModel.EditGroupCardVM:GetServerIndex())
end

function CardsEditDecksPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MagicCardOnNetEditGroupRsp, self.OnGameEventEditGroupRsp)
end

function CardsEditDecksPanelView:OnGameEventEditGroupRsp(CardGroupId, CardIDList)
    self.ViewModel:OnEditGroupReturn(CardGroupId, CardIDList)
end

function CardsEditDecksPanelView:OnTimeWaitForMatchStartChanged(NewValue, OldValue)
    local _min = 0

    while (NewValue >= 60) do
        NewValue = NewValue - 60
        _min = _min + 1
    end

    self.TextCountdownValue:SetText(string.format("%02d:%02d", _min, NewValue))
end

--- 这个比 onshow 要先调用
function CardsEditDecksPanelView:OnRegisterBinder()
    local _originCardViewModel = self.Params.Data -- CardsGroupCardVM
    self.ParentVM = _originCardViewModel.__ParentVM -- 目前是 CardsReadinessPanelVM，用来处理倒计时的
    self.ViewModel.EditGroupCardVM:SimpleCopyFromOther(_originCardViewModel)

    if (self.ParentVM ~= nil and self.ParentVM.TimeWaitForMatchStart ~= nil and self.BindersForCountdown == nil) then
        local _bindersForCountdown = {
            {
                "TimeWaitForMatchStart",
                UIBinderValueChangedCallback.New(self, nil, self.OnTimeWaitForMatchStartChanged)
            }
        }
        self.BindersForCountdown = _bindersForCountdown
    end

    if (self.BindersForCountdown ~= nil) then
        self:RegisterBinders(self.ParentVM, self.BindersForCountdown)
    end

    self:RegisterBinders(self.ViewModel.EditGroupCardVM, self.BinderForGroupVM)
    self:RegisterBinders(self.ViewModel, self.BinderForSelfVM)
end

return CardsEditDecksPanelView
