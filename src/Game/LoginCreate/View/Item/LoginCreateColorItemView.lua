---
--- Author: jamiyang
--- DateTime: 2023-10-19 19:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")


---@class LoginCreateColorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnColor UFButton
---@field ImgColor UFImage
---@field ImgSelectEffect UFImage
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateColorItemView = LuaClass(UIView, true)

function LoginCreateColorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnColor = nil
	--self.ImgColor = nil
	--self.ImgSelectEffect = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateColorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateColorItemView:OnInit()
	self.Binders = {
		{ "bItemSelect", UIBinderSetIsVisible.New(self, self.ImgSelectEffect)},
		{ "bItemSelect", UIBinderSetIsVisible.New(self, self.TextNum) },
		{ "SelectText", UIBinderSetText.New(self, self.TextNum)},
		{ "ItemColorAndOpacity", UIBinderSetColorAndOpacity.New(self, self.ImgColor) },
	}

end

function LoginCreateColorItemView:OnDestroy()

end

function LoginCreateColorItemView:OnShow()

end

function LoginCreateColorItemView:OnHide()

end

function LoginCreateColorItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnColor, self.OnClickButtonItem)

end

function LoginCreateColorItemView:OnRegisterGameEvent()

end

function LoginCreateColorItemView:OnRegisterBinder()
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

function LoginCreateColorItemView:OnClickButtonItem()
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

function LoginCreateColorItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
end

return LoginCreateColorItemView