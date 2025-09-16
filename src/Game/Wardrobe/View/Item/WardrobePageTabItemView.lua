---
--- Author: Administrator
--- DateTime: 2024-02-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetOutlineColor = require("Binder/UIBinderSetOutlineColor")

local NormalColor = "#878075"
local SelectedColor = "#FFF4D0"

local OutlineNormalColor = "#2121217F"
local OutlineSelectedColor = "#8066447F"

---@class WardrobePageTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field ImgTabNormal UFImage
---@field TextTabName UFTextBlock
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobePageTabItemView = LuaClass(UIView, true)

function WardrobePageTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.ImgTabNormal = nil
	--self.TextTabName = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobePageTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobePageTabItemView:OnInit()
	self.Binders = 
	{
		{ "TabName", UIBinderSetText.New(self, self.TextTabName) },
		{ "TabSelectedColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTabName)},
		{ "TabOutlineSelectedColor", UIBinderSetOutlineColor.New(self, self.TextTabName)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
	}

end

function WardrobePageTabItemView:OnDestroy()

end

function WardrobePageTabItemView:OnShow()
	self.TextTabName.Font.OutlineSettings.OutlineSize = 2
end

function WardrobePageTabItemView:OnHide()

end

function WardrobePageTabItemView:OnRegisterUIEvent()

end

function WardrobePageTabItemView:OnRegisterGameEvent()

end

function WardrobePageTabItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)

end

function WardrobePageTabItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	--播放动画
	-- if bSelected then
	-- 	self:PlayAnimation(self.AnimSelect)
	-- end
	ViewModel.IsSelected = bSelected
	ViewModel.TabSelectedColor = bSelected and SelectedColor or NormalColor
	ViewModel.TabOutlineSelectedColor = bSelected and OutlineSelectedColor or OutlineNormalColor
end

function WardrobePageTabItemView:PlaySelectedAnimation()
	if self.ViewModel and self.ViewModel.IsSelected then
		self:PlayAnimation(self.AnimSelect)
	end
end

return WardrobePageTabItemView