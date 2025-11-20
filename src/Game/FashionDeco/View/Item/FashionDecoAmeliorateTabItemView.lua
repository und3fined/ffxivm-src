---
--- Author: Administrator
--- DateTime: 2025-09-03 14:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionDecoAmeliorateTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect01 UFButton
---@field ImgTabBG UFImage
---@field ImgTabLock01 UFImage
---@field PanelTabSelect01 UFCanvasPanel
---@field PanelTabSelectFront UFCanvasPanel
---@field RedDot CommonRedDotView
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoAmeliorateTabItemView = LuaClass(UIView, true)

function FashionDecoAmeliorateTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect01 = nil
	--self.ImgTabBG = nil
	--self.ImgTabLock01 = nil
	--self.PanelTabSelect01 = nil
	--self.PanelTabSelectFront = nil
	--self.RedDot = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoAmeliorateTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionDecoAmeliorateTabItemView:OnInit()
end

function FashionDecoAmeliorateTabItemView:OnDestroy()

end

function FashionDecoAmeliorateTabItemView:OnShow()

end

function FashionDecoAmeliorateTabItemView:OnHide()

end

function FashionDecoAmeliorateTabItemView:OnRegisterUIEvent()

end

function FashionDecoAmeliorateTabItemView:OnRegisterGameEvent()

end

function FashionDecoAmeliorateTabItemView:OnRegisterBinder()
	--FashionDecoAmeliorateTabItemVM
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel

	local Binders = {
		{ "ImgItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgTabBG) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.PanelTabSelect01)},
		{ "IsUnlocked", UIBinderSetIsVisible.New(self, self.ImgTabLock01, true)},

		--注意SeriesType必须在IsShowRedDot前面，否则在IsShowRedDot的时候没有红点名字
		{ "SeriesType",  UIBinderValueChangedCallback.New(self, nil, self.OnSeriesTypeChanged) },
		{ "IsSelect",  UIBinderValueChangedCallback.New(self, nil, self.OnIsSelectChanged) },
		-- { "IsShowRedDot",  UIBinderValueChangedCallback.New(self, nil, self.IsShowRedDotChanged) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function FashionDecoAmeliorateTabItemView:OnIsSelectChanged(IsSelect)
	if IsSelect then
		self:PlayAnimation(self.AnimChecked)
	else
		self:PlayAnimation(self.AnimUnchecked)
	end
end

function FashionDecoAmeliorateTabItemView:OnSeriesTypeChanged(InSeriesType)
	if self.ViewModel ~= nil then
		--红点
		self.RedDotName = string.format("Root/Menu/FashionDeco/Wing/Ameliorate/SeriesType%s", self.ViewModel.SeriesType)
		self.RedDot:SetRedDotNameByString(self.RedDotName) --设置红点名字
	end
end

-- function FashionDecoAmeliorateTabItemView:IsShowRedDotChanged(IsShowRedDot)
-- 	--是否显示红点(感叹号样式)
-- 	if IsShowRedDot then
-- 		_G.RedDotMgr:AddRedDotByName(self.RedDotName, nil, true)
-- 	else
-- 		_G.RedDotMgr:DelRedDotByName(self.RedDotName)
-- 	end
-- end

return FashionDecoAmeliorateTabItemView