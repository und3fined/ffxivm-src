---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local ShopVM = require("Game/Shop/ShopVM")
local ShopDefine = require("Game/Shop/ShopDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
--local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
--local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local EToggleButtonState = _G.UE.EToggleButtonState

---@class ShopStuffItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommItemSlot CommBackpackSlotView
---@field ImgDiscount UImage
---@field ImgHotSale UFImage
---@field PanelDiscount UFCanvasPanel
---@field PanelHotSale UFCanvasPanel
---@field PanelTags UFCanvasPanel
---@field TableViewPrice UTableView
---@field TableViewTags UTableView
---@field TextFormerPrice UFTextBlock
---@field TextHotSale UFTextBlock
---@field TextItemName UFTextBlock
---@field TextNotice UFTextBlock
---@field ToggleBtnBg UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopStuffItemView = LuaClass(UIView, true)

function ShopStuffItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CommItemSlot = nil
    --self.ImgDiscount = nil
    --self.ImgHotSale = nil
    --self.PanelDiscount = nil
    --self.PanelHotSale = nil
    --self.PanelTags = nil
    --self.TableViewPrice = nil
    --self.TableViewTags = nil
    --self.TextFormerPrice = nil
    --self.TextHotSale = nil
    --self.TextItemName = nil
    --self.TextNotice = nil
    --self.ToggleBtnBg = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopStuffItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommItemSlot)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopStuffItemView:OnInit()
    self.TableViewPriceAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPrice, nil, true)
    self.TableViewTagsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTags, nil, true)

    self.Binders = {
        {"ShopItemName", UIBinderSetText.New(self, self.TextItemName)},
        {"CostList", UIBinderUpdateBindableList.New(self, self.TableViewPriceAdapter)},
        {"BuyDiscountInfoList", UIBinderUpdateBindableList.New(self, self.TableViewTagsAdapter)},
        {"bShowDiscount", UIBinderSetIsVisible.New(self, self.PanelDiscount)},
        {"bShowDiscount", UIBinderSetIsVisible.New(self, self.PanelTags)},
        {"OriginCostNum", UIBinderSetTextFormatForMoney.New(self, self.TextFormerPrice)},
        --{"IsSelected", UIBinderSetIsChecked.New(self, self.ToggleBtnBg)},
        {"CheckState", UIBinderSetCheckedState.New(self, self.ToggleBtnBg)},
        {"bBuy", UIBinderSetIsVisible.New(self, self.TextNotice)},
        {"BuyLimitText", UIBinderSetText.New(self, self.TextNotice)},
        {"IsHotSaleTagShow", UIBinderSetIsVisible.New(self, self.PanelHotSale)},
        {"HotSaleTagText", UIBinderSetText.New(self, self.TextHotSale)}
    }
end

function ShopStuffItemView:OnDestroy()
end

function ShopStuffItemView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    if ViewModel.bBuy then
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextNotice, ShopDefine.ShopTextColor.White)
    else
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextNotice, ShopDefine.ShopTextColor.Red)
    end

    if ViewModel.IsSelected then
        self.ToggleBtnBg:SetCheckedState(EToggleButtonState.Checked)
    else
        if not ViewModel.bBuy then
            self.ToggleBtnBg:SetCheckedState(EToggleButtonState.Locked)
        else
            self.ToggleBtnBg:SetCheckedState(EToggleButtonState.Unchecked)
        end
    end
 --]]
end

function ShopStuffItemView:OnHide()
end

function ShopStuffItemView:OnRegisterUIEvent()
    UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnBg, self.OnToggleBtnBgChange)
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnBg, self.OnToggleBtnBgClicked)
    --UIUtil.AddOnClickedEvent(self, self.CommItemSlot.FBtn_Item, self.OnFBtn_ItemClicked)
end

function ShopStuffItemView:OnRegisterGameEvent()
end

function ShopStuffItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)

    self.CommItemSlot:SetParams({Data = ViewModel.CommItemSlotVM})
end

function ShopStuffItemView:OnToggleBtnBgChange()
end

function ShopStuffItemView:OnToggleBtnBgClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    local ParentViewID = Params.Adapter.ViewID
    if ParentViewID == UIViewID.ShopMainPanelView then
        ShopVM:ShopItemListSelected(ViewModel.ShopItemId, true)
    elseif ParentViewID == UIViewID.ShopSearchResultPanelView then
        local SearchResultVM = ShopVM.ShopSearchResultPanelVM
        SearchResultVM:ShopItemListSelected(ViewModel.ShopItemId, true)
    end
end

return ShopStuffItemView
