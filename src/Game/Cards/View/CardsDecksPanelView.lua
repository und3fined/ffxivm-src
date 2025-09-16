---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-10-23 11:24
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CardsDecksPageVM = require("Game/Cards/VM/CardsDecksPageVM")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local EventID = require("Define/EventID")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterPanelWidget = require("UI/Adapter/UIAdapterPanelWidget")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType

---@class CardsDecksPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDefault CommBtnLView
---@field BtnEdit CommBtnLView
---@field PanelCurrentGroupCards UFCanvasPanel
---@field TableViewDecksList UTableView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsDecksPanelView = LuaClass(UIView, true)

function CardsDecksPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnDefault = nil
    -- self.BtnEdit = nil
    -- self.TableViewDecksList = nil
    -- self.TextName = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

    self.ViewModel = CardsDecksPageVM.New()
end

function CardsDecksPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnDefault)
    self:AddSubView(self.BtnEdit)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsDecksPanelView:OnInit()
    self.GroupTableViewAdapter = UIAdapterTableView.CreateAdapter(
                                     self, self.TableViewDecksList, self.OnCardGroupItemSelectChanged, true
                                 )

    self.PanelCurrentGroupCardsAdapter = UIAdapterPanelWidget.CreateAdapter(self, self.PanelCurrentGroupCards)

    local Binders = {
        {
            "CardGroupList",
            UIBinderUpdateBindableList.New(self, self.GroupTableViewAdapter)
        },
        {
            "GroupName",
            UIBinderSetText.New(self, self.TextName)
        },
        {
            "CurrentSelectItemVM",
            UIBinderValueChangedCallback.New(self, nil, self.OnCurrentSelectItemVMChange)
        }
    }
    local _binderForSelectGroupVM = {
        {
            "IsAllRulePass",
            UIBinderValueChangedCallback.New(self, nil, self.OnIsAllRulePassChanged)
        }
    }
    self.Binders = Binders
    self.BinderForSelectGroupVM = _binderForSelectGroupVM
    self.ViewModel:OnRefresh()
end

function CardsDecksPanelView:OnIsAllRulePassChanged(NewValue, OldValue)
    if (NewValue) then
        self.BtnEdit:UpdateImage(CommBtnColorType.Normal)
        self.BtnDefault:UpdateImage(CommBtnColorType.Normal)
        self.BtnDefault:SetIsEnabled(true, true)
    else
        self.BtnEdit:UpdateImage(CommBtnColorType.Recommend)
        self.BtnDefault:UpdateImage(CommBtnColorType.Disable)
        self.BtnDefault:SetIsEnabled(false, false)
    end
end

function CardsDecksPanelView:OnCurrentSelectItemVMChange(NewValue, OldValue)
    if (self.ViewModel == nil or NewValue == nil) then
        return
    end

    if (OldValue ~= nil) then
        self:UnRegisterBinders(OldValue, self.BinderForSelectGroupVM)
    end
    self:RegisterBinders(NewValue, self.BinderForSelectGroupVM)
    self.PanelCurrentGroupCardsAdapter:UpdateAll(NewValue.GroupCardList)
end

function CardsDecksPanelView:OnCardGroupItemSelectChanged(Index, ItemData, ItemView)
    self.ViewModel:SetItemSelected(ItemData)
end

function CardsDecksPanelView:OnDestroy()
end

function CardsDecksPanelView:OnShow()

end

function CardsDecksPanelView:OnHide()

end

function CardsDecksPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnEdit.Button, self.OnClickEditBtn)
    UIUtil.AddOnClickedEvent(self, self.BtnDefault, self.OnClickBtnDefault)
end

function CardsDecksPanelView:OnClickBtnDefault()
    local _isAllOk = self.ViewModel.CurrentSelectItemVM.IsAllRulePass
    if (not _isAllOk) then
        -- 这里弹出提示，编组没有OK的，就直接掠过
        return
    end

    self.ViewModel:SetCurrentSelectItemDefault()
end

function CardsDecksPanelView:OnClickEditBtn()
    -- 这里去打开一下，传入的参数要带当前选择的编辑卡组信息
    _G.UIViewMgr:ShowView(
        _G.UIViewID.MagicCardEditPanel, {
            Data = self.ViewModel.CurrentSelectItemVM
        }
    )
end

function CardsDecksPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MagicCardChangedName, self.OnMagicCardChangedName)
end

function CardsDecksPanelView:OnMagicCardChangedName()
    self.ViewModel:RefreshGroupName()
end

function CardsDecksPanelView:CurrentSelectItemVM()
end

function CardsDecksPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsDecksPanelView
