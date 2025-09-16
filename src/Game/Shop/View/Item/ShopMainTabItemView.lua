---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
--local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ShopVM = require("Game/Shop/ShopVM")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class ShopMainTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTab UFButton
---@field ImgDown UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field ImgUp UFImage
---@field TextTabName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopMainTabItemView = LuaClass(UIView, true)

function ShopMainTabItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTab = nil
	--self.ImgDown = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.ImgUp = nil
	--self.TextTabName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopMainTabItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopMainTabItemView:OnInit()
    self.Binders = {
        {"TabName", UIBinderSetText.New(self, self.TextTabName)},
        {"IsSelected", UIBinderSetIsVisible.New(self, self.ImgDown, true)},
        {"IsSelected", UIBinderSetIsVisible.New(self, self.ImgUp)},
        {"bShowSelectedState", UIBinderSetIsVisible.New(self, self.ImgNormal, true)},
        {"bShowSelectedState", UIBinderSetIsVisible.New(self, self.ImgSelect)},
        {"NameColorText", UIBinderSetColorAndOpacityHex.New(self, self.TextTabName)}
    }
end

function ShopMainTabItemView:OnDestroy()
end

function ShopMainTabItemView:OnShow()
end

function ShopMainTabItemView:OnHide()
end

function ShopMainTabItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnTab, self.OnBtnTabClick)
end

function ShopMainTabItemView:OnRegisterGameEvent()
end

function ShopMainTabItemView:OnBtnTabClick()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    ShopVM:LeftTabsMainTabExpandChange(ViewModel.TabName)
end

function ShopMainTabItemView:OnRegisterBinder()
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

return ShopMainTabItemView
