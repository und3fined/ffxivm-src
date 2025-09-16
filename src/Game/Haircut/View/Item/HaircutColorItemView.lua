---
--- Author: jamiyang
--- DateTime: 2024-01-23 09:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")

---@class HaircutColorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnColor UFButton
---@field ImgColor UFImage
---@field ImgSelectEffect UFImage
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutColorItemView = LuaClass(UIView, true)

function HaircutColorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnColor = nil
	--self.ImgColor = nil
	--self.ImgSelectEffect = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutColorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutColorItemView:OnInit()
	self.Binders = {
		{ "bItemSelect", UIBinderSetIsVisible.New(self, self.ImgSelectEffect)},
		{ "bItemSelect", UIBinderSetIsVisible.New(self, self.TextNum) },
		{ "SelectText", UIBinderSetText.New(self, self.TextNum)},
		{ "ItemColorAndOpacity", UIBinderSetColorAndOpacity.New(self, self.ImgColor) },
	}
end

function HaircutColorItemView:OnDestroy()

end

function HaircutColorItemView:OnShow()

end

function HaircutColorItemView:OnHide()

end

function HaircutColorItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnColor, self.OnClickButtonItem)
end

function HaircutColorItemView:OnRegisterGameEvent()

end

function HaircutColorItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function HaircutColorItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

function HaircutColorItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end

	-- if IsSelected then
	-- 	self:PlayAnimation(self.AnimChecked)
	-- else
	-- 	self:PlayAnimation(self.AnimUnchecked)
	-- end
end

return HaircutColorItemView