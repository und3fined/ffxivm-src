---
--- Author: muyanli
--- DateTime: 2025-06-11 15:23
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLandListWinItemVM = require("Game/House/VM/Item/HouseLandListWinItemVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
---@class HouseLandListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLandSales UFButton
---@field IconLandSales UFImage
---@field IconMoney UFImage
---@field TextBuyType UFTextBlock
---@field TextHouseLand UFTextBlock
---@field ToggleBtnCollection UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandListItemView = LuaClass(UIView, true)

function HouseLandListItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnLandSales = nil
    -- self.IconLandSales = nil
    -- self.IconMoney = nil
    -- self.TextBuyType = nil
    -- self.TextHouseLand = nil
    -- self.ToggleBtnCollection = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandListItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandListItemView:OnInit()
    self.ViewModel = HouseLandListWinItemVM.New()
    self.Binders = {{"IsCollect", UIBinderSetIsChecked.New(self, self.ToggleBtnCollection)},
                    {"IconLandSales", UIBinderSetBrushFromAssetPath.New(self, self.IconLandSales)},
                    {"TextHouseLand", UIBinderSetText.New(self, self.TextHouseLand)},
                    {"TextBuyType", UIBinderSetText.New(self, self.TextBuyType)},
                    {"IconMoney", UIBinderSetBrushFromAssetPath.New(self, self.IconMoney)}}
end

function HouseLandListItemView:OnDestroy()

end

function HouseLandListItemView:OnShow()
end

function HouseLandListItemView:OnHide()

end

function HouseLandListItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnLandSales, self.OnBtnLandSalesClick)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnCollection, self.OnClickedToggleBtnCollection)
end

function HouseLandListItemView:OnRegisterGameEvent()

end

function HouseLandListItemView:OnRegisterBinder()
    if nil == self.Params or nil == self.Params.Data then
        return
    end
    local ViewModel = self.Params.Data

    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseLandListItemView:OnBtnLandSalesClick()
    if self.ViewModel then
        _G.HouseLandMgr:OpenHouseOrLandPanel(self.ViewModel)
    end
end

function HouseLandListItemView:OnClickedToggleBtnCollection(ToggleButton, State)
    self.ViewModel:CollectLand()
end

return HouseLandListItemView
