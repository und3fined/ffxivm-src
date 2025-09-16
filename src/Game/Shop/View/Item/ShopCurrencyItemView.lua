---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
--local ShopDefine = require("Game/Shop/ShopDefine")
local ShopVM = require("Game/Shop/ShopVM")
local UIViewID = require("Define/UIViewID")
--local ShopCurrencyTipsVM = require("Game/Shop/ShopCurrencyTipsVM")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
--local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIconItemAndScore = require("Binder/UIBinderSetIconItemAndScore")
--local ItemCfg = require("TableCfg/ItemCfg")
--local ScoreMgr = require("Game/Score/ScoreMgr")

---@class ShopCurrencyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCurrency UFButton
---@field ImgCurrency UFImage
---@field TextAmount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopCurrencyItemView = LuaClass(UIView, true)

function ShopCurrencyItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnCurrency = nil
    --self.ImgCurrency = nil
    --self.TextAmount = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopCurrencyItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopCurrencyItemView:OnInit()
    self.Binders = {
        {"CostNum", UIBinderSetTextFormatForMoney.New(self, self.TextAmount)},
        {"TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextAmount)},
        {"CostId", UIBinderSetIconItemAndScore.New(self, self.ImgCurrency)},
        --{"CostNum", UIBinderSetTextFormatForMoney.New(self, self.TextAmount)}
    }
end

function ShopCurrencyItemView:OnDestroy()
end

function ShopCurrencyItemView:OnShow()

end

function ShopCurrencyItemView:OnHide()
end

function ShopCurrencyItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnCurrency, self.OnBtnCurrencyClicked)
end

function ShopCurrencyItemView:OnRegisterGameEvent()
end

function ShopCurrencyItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

function ShopCurrencyItemView:OnBtnCurrencyClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    if not ViewModel.bClick then
        return
    end

    local ParamsData = {
        CurrencyIsItem = ViewModel.IsItem,
        CurrencyIdShow = ViewModel.CostId
    }

    local ParentViewID = Params.Adapter.ViewID
    if ParentViewID == UIViewID.ShopSearchResultPanelView then
        ShopVM.ShopSearchResultPanelVM:ShowCurrencyTipsPanel(ParamsData)
    else
        ShopVM:ShowCurrencyTipsPanel(ParamsData)
    end
end

return ShopCurrencyItemView
