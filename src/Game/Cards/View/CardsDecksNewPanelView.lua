---
--- Author: MichaelYang_LightPaw
--- DateTime: 2024-01-15 10:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CardsDecksPageVM = require("Game/Cards/VM/CardsDecksPageVM")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local CardsSingleCardVM = require("Game/Cards/VM/CardsSingleCardVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterPanelWidget = require("UI/Adapter/UIAdapterPanelWidget")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType

---@class CardsDecksNewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Card01 CardsBigCardItemView
---@field Card02 CardsBigCardItemView
---@field Card03 CardsBigCardItemView
---@field Card04 CardsBigCardItemView
---@field Card05 CardsBigCardItemView
---@field ImgBack01 UFImage
---@field ImgBack02 UFImage
---@field ImgBack03 UFImage
---@field ImgBack04 UFImage
---@field ImgBack05 UFImage
---@field PanelCurrentGroupCards UFCanvasPanel
---@field AnimChangeCard UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsDecksNewPanelView = LuaClass(UIView, true)

function CardsDecksNewPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Card01 = nil
    --self.Card02 = nil
    --self.Card03 = nil
    --self.Card04 = nil
    --self.Card05 = nil
    --self.ImgBack01 = nil
    --self.ImgBack02 = nil
    --self.ImgBack03 = nil
    --self.ImgBack04 = nil
    --self.ImgBack05 = nil
    --self.PanelCurrentGroupCards = nil
    --self.AnimChangeCard = nil
    --self.AnimIn = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsDecksNewPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.Card01)
    self:AddSubView(self.Card02)
    self:AddSubView(self.Card03)
    self:AddSubView(self.Card04)
    self:AddSubView(self.Card05)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsDecksNewPanelView:OnInit()
    self.ViewModel = self.ParentView.ViewModel.CardsEditDecksPanelVM
    self.CardBGList = {}
    self.CardBGList[1] = self.ImgBack01
    self.CardBGList[2] = self.ImgBack02
    self.CardBGList[3] = self.ImgBack03
    self.CardBGList[4] = self.ImgBack04
    self.CardBGList[5] = self.ImgBack05
    self.PanelCurrentGroupCardsAdapter = UIAdapterPanelWidget.CreateAdapter(self, self.PanelCurrentGroupCards)
    local Binders = {
        {
            "EditCardChangeNotify",
            UIBinderValueChangedCallback.New(self, nil, self.OnCurrentSelectItemVMChange)
        }
    }
    self.IsFirstPlay = true
    self.Binders = Binders
end

function CardsDecksNewPanelView:OnDestroy()
end

function CardsDecksNewPanelView:OnCurrentSelectItemVMChange(NewValue, OldValue)
    self.PanelCurrentGroupCardsAdapter:UpdateAll(self.ViewModel.EditGroupCardVM.GroupCardList)
    if (self.IsFirstPlay) then
        self.IsFirstPlay = false
        return
    end
    --self:StopAllAnimations()
    self:PlayAnimation(self.AnimChangeCard)
end

function CardsDecksNewPanelView:InternalUpdateCards()
end

function CardsDecksNewPanelView:OnShow()
    self.IsFirstPlay = true
end

function CardsDecksNewPanelView:OnHide()
end

function CardsDecksNewPanelView:OnRegisterUIEvent()
end

function CardsDecksNewPanelView:OnRegisterGameEvent()
end

function CardsDecksNewPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsDecksNewPanelView
