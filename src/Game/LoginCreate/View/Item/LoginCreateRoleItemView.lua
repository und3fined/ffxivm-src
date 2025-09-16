---
--- Author: jamiyang
--- DateTime: 2023-10-16 15:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class LoginCreateRoleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCreate UFButton
---@field EFF UFCanvasPanel
---@field ImgAvatar UFImage
---@field ImgSelect UFImage
---@field PanelRole UFCanvasPanel
---@field PanelRoleCreate UFCanvasPanel
---@field TextCustom UFTextBlock
---@field ToggleBtnRole UToggleButton
---@field AnimChecked UWidgetAnimation
---@field AnimCheckedGo UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateRoleItemView = LuaClass(UIView, true)

function LoginCreateRoleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCreate = nil
	--self.EFF = nil
	--self.ImgAvatar = nil
	--self.ImgSelect = nil
	--self.PanelRole = nil
	--self.PanelRoleCreate = nil
	--self.TextCustom = nil
	--self.ToggleBtnRole = nil
	--self.AnimChecked = nil
	--self.AnimCheckedGo = nil
	--self.AnimIn = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateRoleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateRoleItemView:OnInit()
	self.Binders = {
		{ "ImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgAvatar, true) },
		{ "bCreate", UIBinderSetIsVisible.New(self, self.PanelRole, true) },
		{ "bCreate", UIBinderSetIsVisible.New(self, self.PanelRoleCreate, false) },
		{ "bItemSelect", UIBinderSetIsChecked.New(self, self.ToggleBtnRole)},
		{ "bItemSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
	}
	self.TextCustom:SetText(_G.LSTR(980099)) --"自定义"
end

function LoginCreateRoleItemView:OnDestroy()

end

function LoginCreateRoleItemView:OnShow()

end

function LoginCreateRoleItemView:OnHide()

end

function LoginCreateRoleItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnRole, self.OnClickButtonItem)
	UIUtil.AddOnClickedEvent(self, self.BtnCreate, self.OnClickButtonItem)
end

function LoginCreateRoleItemView:OnRegisterGameEvent()

end

function LoginCreateRoleItemView:OnRegisterBinder()
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

function LoginCreateRoleItemView:OnClickButtonItem()
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

function LoginCreateRoleItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
	self:StopAllAnimations()
	if IsSelected then
		self:PlayAnimation(self.AnimChecked)
	else
		self:PlayAnimation(self.AnimUnchecked)
	end
end

return LoginCreateRoleItemView