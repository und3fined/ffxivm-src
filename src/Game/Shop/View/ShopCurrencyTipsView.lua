---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ShopVM = require("Game/Shop/ShopVM")
---@class ShopCurrencyTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field CurrencyPage ShopCurrencyPageView
---@field ItemTipsContent ItemTipsContentView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopCurrencyTipsView = LuaClass(UIView, true)

function ShopCurrencyTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CommonPopUpBG = nil
    --self.CurrencyPage = nil
    --self.ItemTipsContent = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopCurrencyTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommonPopUpBG)
    self:AddSubView(self.CurrencyPage)
    self:AddSubView(self.ItemTipsContent)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopCurrencyTipsView:OnInit()
    self.CurrencyIdShow = 0
end

function ShopCurrencyTipsView:OnDestroy()
end

function ShopCurrencyTipsView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    if self.CurrencyIdShow ~= ViewModel.CurrencyIdShow then
		self.CurrencyIdShow = ViewModel.CurrencyIdShow
        self.CurrencyPage:SetParams({Data = ShopVM.CurrencyPageVM})
		self.ItemTipsContent:SetParams({ViewModel = ViewModel.ItemTipsVM})
    end
end

function ShopCurrencyTipsView:OnHide()
end

function ShopCurrencyTipsView:OnRegisterUIEvent()
end

function ShopCurrencyTipsView:OnRegisterGameEvent()
end

function ShopCurrencyTipsView:OnRegisterBinder()
    self.CommonPopUpBG:SetHideOnClick(true)
end

return ShopCurrencyTipsView
