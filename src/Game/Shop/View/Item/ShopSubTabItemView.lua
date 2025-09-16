---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local ShopVM = require("Game/Shop/ShopVM")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class ShopSubTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSubTab UToggleButton
---@field TextTabName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopSubTabItemView = LuaClass(UIView, true)

function ShopSubTabItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnSubTab = nil
    --self.TextTabName = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopSubTabItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopSubTabItemView:OnInit()
    self.Binders = {
        {"TabName", UIBinderSetText.New(self, self.TextTabName)},
        {"IsSelected", UIBinderSetIsChecked.New(self, self.BtnSubTab)},
        {"NameColorText", UIBinderSetColorAndOpacityHex.New(self, self.TextTabName)}
    }

end

function ShopSubTabItemView:OnDestroy()
end

function ShopSubTabItemView:OnShow()
end

function ShopSubTabItemView:OnHide()
end

function ShopSubTabItemView:OnRegisterUIEvent()
    UIUtil.AddOnStateChangedEvent(self, self.BtnSubTab, self.OnBtnSubTabChange)
end

function ShopSubTabItemView:OnRegisterGameEvent()
end

function ShopSubTabItemView:OnRegisterBinder()
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

function ShopSubTabItemView:OnBtnSubTabChange()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    ShopVM:LeftTabsSubTabSelectChange(ViewModel.TabName, ViewModel.ParentName)
end

return ShopSubTabItemView
