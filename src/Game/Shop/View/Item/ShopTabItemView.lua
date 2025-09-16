---
--- Author: Administrator
--- DateTime: 2023-10-13 15:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class ShopTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot2 CommonRedDot2View
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimNormal UWidgetAnimation
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopTabItemView = LuaClass(UIView, true)

function ShopTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot2 = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--self.AnimNormal = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopTabItemView:OnInit()
	self.Binders = {
        {"TabName", UIBinderSetText.New(self, self.TextName)},
        {"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
    }
end

function ShopTabItemView:OnDestroy()

end

function ShopTabItemView:OnShow()
	self.FirstType = self.ViewModel.FirstType
	self.RedDotName = _G.ShopMgr.TabRedDotName .. "/".. self.FirstType
	self.CommonRedDot2:SetRedDotNameByString(self.RedDotName)
end

function ShopTabItemView:OnHide()

end

function ShopTabItemView:OnRegisterUIEvent()

end

function ShopTabItemView:OnRegisterGameEvent()
end

function ShopTabItemView:OnSelectChanged(NewValue)
	local Color = ""
	if NewValue then
		Color = "#594123"
	else
		Color = "#d5d5d5"
	end
	if NewValue then
		self:PlayAnimation(self.AnimSelect)
	else
		self:PlayAnimation(self.AnimNormal)
	end
	UIUtil.SetColorAndOpacityHex(self.TextName,Color)
	UIUtil.SetIsVisible(self.ImgSelect, NewValue)
end

function ShopTabItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
	self.ViewModel = ViewModel
    self:RegisterBinders(ViewModel, self.Binders)
end

return ShopTabItemView