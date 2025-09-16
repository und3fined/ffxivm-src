---
--- Author: Administrator
--- DateTime: 2023-11-14 10:54
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")

---@class CardsBoardSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CardsBigCardItem CardsBigCardItemView
---@field ImgBlue UFImage
---@field ImgRed UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsBoardSlotItemView = LuaClass(UIView, true)

function CardsBoardSlotItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.ImgBlue = nil
    -- self.ImgRed = nil
    -- self.ImgSelect = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsBoardSlotItemView:PlayEffectForSpecialRule()
    self.CardsBigCardItem:PlayEffectForSpecialRule()
end

function CardsBoardSlotItemView:SetAsSpecialFlippedCard(Card)
    self.CardsBigCardItem:SetAsSpecialFlippedCard(Card)
end

function CardsBoardSlotItemView:SetAsTriggerCard(Efects, RuleID)
    self.CardsBigCardItem:SetAsTriggerCard(Efects, RuleID)
end

function CardsBoardSlotItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CardsBigCardItem)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsBoardSlotItemView:OnInit()
    local Binders = {
        {
            "UpdateNotify",
            UIBinderValueChangedCallback.New(self, nil, self.OnUpdateNotifyChange)
        },
        {
            "ShowHover",
            UIBinderValueChangedCallback.New(self, nil, self.OnShowHoverChange)
        }
    }
    self.Binders = Binders

    local BindersForSingleCard = {
        {
            "CardId",
            UIBinderValueChangedCallback.New(self, nil, self.OnCardIdChange)
        }
    }
    self.BindersForSingleCard = BindersForSingleCard
end

function CardsBoardSlotItemView:OnShowHoverChange(NewValue, OldValue)
    if (NewValue) then
        UIUtil.SetIsVisible(self.ImgSelect, true)
    else
        UIUtil.SetIsVisible(self.ImgSelect, false)
    end
end

function CardsBoardSlotItemView:OnCardIdChange(NewValue, OldValue)
end

function CardsBoardSlotItemView:OnUpdateNotifyChange(NewValue, OldValue)
    if (self.ViewModel.IsPlayed) then
        if (self.ViewModel.IsPlayerCard) then
            UIUtil.SetIsVisible(self.CardsBigCardItem, true, true)
            UIUtil.SetIsVisible(self.ImgBlue, true, true)
            UIUtil.SetIsVisible(self.ImgRed, false, false)
        else
            UIUtil.SetIsVisible(self.CardsBigCardItem, true, true)
            UIUtil.SetIsVisible(self.ImgBlue, false, false)
            UIUtil.SetIsVisible(self.ImgRed, true, true)
        end
    else
        UIUtil.SetIsVisible(self.CardsBigCardItem, false, false)
        UIUtil.SetIsVisible(self.ImgBlue, false, false)
        UIUtil.SetIsVisible(self.ImgRed, false, false)
    end
end

function CardsBoardSlotItemView:OnDestroy()

end

---@param Operation MagicCardItemDragDropOperation
function CardsBoardSlotItemView:OnDragEnter(MyGeometry, PointerEvent, Operation)
    local selfVM = self.ViewModel
    if (selfVM) then
        selfVM:OnDragEnter()
    end
end

function CardsBoardSlotItemView:OnDragLeave(PointerEvent, Operation)
    local selfVM = self.ViewModel
    if selfVM then
        selfVM:OnDragLeave()
    end
end

---@param Operation MagicCardItemDragDropOperation
---@return boolean
function CardsBoardSlotItemView:OnDrop(MyGeometry, PointerEvent, Operation)
    local selfVM = self.ViewModel
    if selfVM then
        return selfVM:OnDrop(Operation.WidgetReference.ViewModel)
    end
    return false
end

---@param Operation MagicCardItemDragDropOperation
function CardsBoardSlotItemView:OnDragCancelled(PointerEvent, Operation)
    if (Operation == nil) then
        _G.FLOG_ERROR("CardsBoardSlotItemView:OnDragCancelled 错误，传入的 Operation 为空，请检查")
        return
    end

    local DraggedCardVm = Operation.WidgetReference.ViewModel
    DraggedCardVm:OnDragCancelled()
    if (Operation.SetDragEnterCard ~= nil) then
        Operation:SetDragEnterCard()
    else
        _G.FLOG_ERROR("CardsBoardSlotItemView:OnDragCancelled 错误， Operation.SetDragEnterCard 为空，请检查")
    end
end

function CardsBoardSlotItemView:OnShow()
    UIUtil.SetIsVisible(self.ImgSelect, false)
    self.CardsBigCardItem:SetParams(
        {
            Data = self.ViewModel.SingleCardVM
        }
    )

    -- 这里去做一下旋转
    local _index = self.ViewModel:GetIndex()
    if(_index  == 1) then
        self.CanvasFrameRoot:SetRenderTransformAngle(0)
    elseif(_index == 3) then
        self.CanvasFrameRoot:SetRenderTransformAngle(90)
    elseif(_index == 7) then
        self.CanvasFrameRoot:SetRenderTransformAngle(-90)
    elseif(_index == 9) then
        self.CanvasFrameRoot:SetRenderTransformAngle(180)
    end
end

function CardsBoardSlotItemView:OnHide()

end

function CardsBoardSlotItemView:OnRegisterUIEvent()

end

function CardsBoardSlotItemView:OnRegisterGameEvent()

end

function CardsBoardSlotItemView:OnRegisterBinder()
    -- ViewModel 是 CardsSingleCardOnBoardVM
    self.ViewModel = self.Params.Data
    if (self.ViewModel == nil) then
        _G.FLOG_ERROR("错误，没有ViewModel，请检查!")
        return
    end
    self:RegisterBinders(self.ViewModel, self.Binders)
    self:RegisterBinder(self.ViewModel.SingleCardVM, self.BindersForSingleCard)
end

return CardsBoardSlotItemView
