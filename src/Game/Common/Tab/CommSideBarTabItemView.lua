---
--- Author: ccppeng
--- DateTime: 2024-11-01 18:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIUtil = require("Utils/UIUtil")
---@class CommSideBarTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommAvatar CommPlayerHeadSlotView
---@field Icon UFImage
---@field IconLock UFImage
---@field IconText UFImage
---@field ImgSelect UFImage
---@field PaneSingleIcon UScaleBox
---@field PanelAvatarPlusText UFCanvasPanel
---@field PanelIconPlusText UFCanvasPanel
---@field TextAvatar1 UFTextBlock
---@field TextAvatar2 UFTextBlock
---@field TextIcon UFTextBlock
---@field AnimSelectIn UWidgetAnimation
---@field AnimSelectOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSideBarTabItemView = LuaClass(UIView, true)

function CommSideBarTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommAvatar = nil
	--self.Icon = nil
	--self.IconLock = nil
	--self.IconText = nil
	--self.ImgSelect = nil
	--self.PaneSingleIcon = nil
	--self.PanelAvatarPlusText = nil
	--self.PanelIconPlusText = nil
	--self.TextAvatar1 = nil
	--self.TextAvatar2 = nil
	--self.TextIcon = nil
	--self.AnimSelectIn = nil
	--self.AnimSelectOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSideBarTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommAvatar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSideBarTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	local Binders = {
		{ "Icon", UIBinderSetImageBrush.New(self, self.Icon, true) },
		{ "ScaleBoxIconVisibility", UIBinderSetVisibility.New(self,  self.PaneSingleIcon) },
		{ "bSelect",
		UIBinderValueChangedCallback.New(self, nil, self.OnUpdateToSelect)  },
		{ "IsLock", UIBinderSetIsVisible.New(self, self.IconLock)}
	}

	self:RegisterBinders(ViewModel, Binders)
end

function CommSideBarTabItemView:OnUpdateToSelect(InNewValue,InOldValue)
	if InNewValue == _G.UE.ESlateVisibility.Visible then
		self:PlayAnimLoopIn()
		self.ViewModel:SetSelectIcon()
		--UIUtil.SetIsVisible(self.ImgSelect,true)
	else
		self.ViewModel:SetNormalIcon()
		self:PlayAnimLoopOut()
		--UIUtil.SetIsVisible(self.ImgSelect,false)
	end
end

function CommSideBarTabItemView:PlayAnimLoopIn()
	self:PlayAnimation(self.AnimSelectIn)
	self:StopAnimation(self.AnimSelectOut)
end

function CommSideBarTabItemView:PlayAnimLoopOut()
	self:PlayAnimation(self.AnimSelectOut)
	self:StopAnimation(self.AnimSelectIn)
end

return CommSideBarTabItemView