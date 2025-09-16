---
--- Author: Administrator
--- DateTime: 2024-01-15 10:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class CardsDecksNewPanel03View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field CardsEditDecksCardsPage CardsEditDecksCardsPageView
---@field TableViewSift UTableView
---@field TextPageInfo UFTextBlock
---@field TextTotalCardNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsDecksNewPanel03View = LuaClass(UIView, true)

function CardsDecksNewPanel03View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.CardsEditDecksCardsPage = nil
	--self.TableViewSift = nil
	--self.TextPageInfo = nil
	--self.TextTotalCardNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsDecksNewPanel03View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CardsEditDecksCardsPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsDecksNewPanel03View:OnInit()
	self.FilterTablViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSift, nil)
	self.ViewModel = self.ParentView.ViewModel.CardsEditDecksPanelVM
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
	self.BinderForSelfVM = BinderForSelfVM
	self.CardsEditDecksCardsPage:SetParentVM(self.ViewModel)
end

function CardsDecksNewPanel03View:OnOwnedCardNumWithFilterChanged(NewValue, OldValue)
    self.TextTotalCardNum:SetText(string.format(_G.LSTR(LocalDef.UKeyConfig.CardCount), self.ViewModel.OwnedCardNumWithFilter))
end

function CardsDecksNewPanel03View:OnTextPageInfoChanged(NewValue, OldValue)
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

function CardsDecksNewPanel03View:OnBGFrameStateChange(NewValue, OldValue)
    self.CardsEditDecksCardsPage:SetCardPoolFrameState(NewValue)
end

function CardsDecksNewPanel03View:OnDestroy()

end

function CardsDecksNewPanel03View:OnShow()
    self.ViewModel:UpdateOwnedCardListToShowWithFilter()
    self:OnTextPageInfoChanged()
    self:OnOwnedCardNumWithFilterChanged()
    self.ViewModel.DragVisualCardItemView:HideView()
end

function CardsDecksNewPanel03View:OnHide()

end

function CardsDecksNewPanel03View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnClickBtnLeft)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnClickBtnRight)
end

function CardsDecksNewPanel03View:OnClickBtnLeft()
    self.ViewModel:OnClickPrePageBtn()
end

function CardsDecksNewPanel03View:OnClickBtnRight()
    self.ViewModel:OnClickNextPageBtn()
end

function CardsDecksNewPanel03View:OnRegisterGameEvent()

end

function CardsDecksNewPanel03View:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.BinderForSelfVM)
end

return CardsDecksNewPanel03View