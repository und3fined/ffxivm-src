---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-10-31 11:02
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterPanelWidget = require("UI/Adapter/UIAdapterPanelWidget")

---@class CardsEditDecksCardsPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFrame UFImage
---@field ImgFrameBlue UFImage
---@field ImgFrameYellow UFImage
---@field OwnCard01 CardsBigCardItemView
---@field OwnCard02 CardsBigCardItemView
---@field OwnCard03 CardsBigCardItemView
---@field OwnCard04 CardsBigCardItemView
---@field OwnCard05 CardsBigCardItemView
---@field OwnCard06 CardsBigCardItemView
---@field OwnCard07 CardsBigCardItemView
---@field OwnCard08 CardsBigCardItemView
---@field OwnCard09 CardsBigCardItemView
---@field OwnCard10 CardsBigCardItemView
---@field OwnCard11 CardsBigCardItemView
---@field OwnCard12 CardsBigCardItemView
---@field OwnCard13 CardsBigCardItemView
---@field OwnCard14 CardsBigCardItemView
---@field OwnCard15 CardsBigCardItemView
---@field OwnCard16 CardsBigCardItemView
---@field OwnCard17 CardsBigCardItemView
---@field OwnCard18 CardsBigCardItemView
---@field OwnCard19 CardsBigCardItemView
---@field OwnCard20 CardsBigCardItemView
---@field PanelCard UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsEditDecksCardsPageView = LuaClass(UIView, true)

function CardsEditDecksCardsPageView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.ImgFrame = nil
    -- self.ImgFrameBlue = nil
    -- self.ImgFrameYellow = nil
    -- self.OwnCard01 = nil
    -- self.OwnCard02 = nil
    -- self.OwnCard03 = nil
    -- self.OwnCard04 = nil
    -- self.OwnCard05 = nil
    -- self.OwnCard06 = nil
    -- self.OwnCard07 = nil
    -- self.OwnCard08 = nil
    -- self.OwnCard09 = nil
    -- self.OwnCard10 = nil
    -- self.OwnCard11 = nil
    -- self.OwnCard12 = nil
    -- self.OwnCard13 = nil
    -- self.OwnCard14 = nil
    -- self.OwnCard15 = nil
    -- self.OwnCard16 = nil
    -- self.OwnCard17 = nil
    -- self.OwnCard18 = nil
    -- self.OwnCard19 = nil
    -- self.OwnCard20 = nil
    -- self.PanelCard = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsEditDecksCardsPageView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.OwnCard01)
    self:AddSubView(self.OwnCard02)
    self:AddSubView(self.OwnCard03)
    self:AddSubView(self.OwnCard04)
    self:AddSubView(self.OwnCard05)
    self:AddSubView(self.OwnCard06)
    self:AddSubView(self.OwnCard07)
    self:AddSubView(self.OwnCard08)
    self:AddSubView(self.OwnCard09)
    self:AddSubView(self.OwnCard10)
    self:AddSubView(self.OwnCard11)
    self:AddSubView(self.OwnCard12)
    self:AddSubView(self.OwnCard13)
    self:AddSubView(self.OwnCard14)
    self:AddSubView(self.OwnCard15)
    self:AddSubView(self.OwnCard16)
    self:AddSubView(self.OwnCard17)
    self:AddSubView(self.OwnCard18)
    self:AddSubView(self.OwnCard19)
    self:AddSubView(self.OwnCard20)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsEditDecksCardsPageView:OnInit()
    -- 这个是总的卡片
    self.PanelCardAdapter = UIAdapterPanelWidget.CreateAdapter(self, self.PanelCard)

    local BinderForParentVM = {{"OwnedCardListToShow", UIBinderUpdateBindableList.New(self, self.PanelCardAdapter)}}
    self.Binders = BinderForParentVM

    UIUtil.SetIsVisible(self.ImgFrameBlue, false)
    UIUtil.SetIsVisible(self.ImgFrameYellow, false)
end

function CardsEditDecksCardsPageView:OnDestroy()

end

function CardsEditDecksCardsPageView:OnShow()

end

function CardsEditDecksCardsPageView:OnHide()

end

function CardsEditDecksCardsPageView:SetCardPoolFrameState(TargetState)
    UIUtil.SetIsVisible(self.ImgFrameBlue, TargetState == LocalDef.BGFrameState.BlueState)
    UIUtil.SetIsVisible(self.ImgFrameYellow, TargetState == LocalDef.BGFrameState.YellowState)
end

function CardsEditDecksCardsPageView:SetParentVM(ParentVM)
    self.ParentVM = ParentVM
end

function CardsEditDecksCardsPageView:OnDragEnter(MyGeometry, PointerEvent, Operation)
    local _otherViewModel = Operation.WidgetReference.ViewModel
    if (_otherViewModel:GetCardType() == LocalDef.CardItemType.InfoShow) then
		self.ParentVM:SetCardPoolFrameState(LocalDef.BGFrameState.YellowState)
    end
end

function CardsEditDecksCardsPageView:OnDragLeave(PointerEvent, Operation)
    local _otherViewModel = Operation.WidgetReference.ViewModel
    if (_otherViewModel:GetCardType() == LocalDef.CardItemType.InfoShow) then
        self.ParentVM:SetCardPoolFrameState(LocalDef.BGFrameState.BlueState)
    end
end

function CardsEditDecksCardsPageView:OnDrop(MyGeometry, PointerEvent, Operation)
    self.ParentVM:OnDrop()
    return false
end

function CardsEditDecksCardsPageView:OnRegisterUIEvent()

end

function CardsEditDecksCardsPageView:OnRegisterGameEvent()

end

function CardsEditDecksCardsPageView:OnRegisterBinder()
    self:RegisterBinders(self.ParentVM, self.Binders)
end

return CardsEditDecksCardsPageView
