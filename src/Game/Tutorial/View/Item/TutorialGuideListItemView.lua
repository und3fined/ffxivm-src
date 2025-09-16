---
--- Author: Administrator
--- DateTime: 2023-06-05 16:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local TutorialGuidePanelVM = require("Game/Tutorial/VM/TutorialGuidePanelVM")

---@class TutorialGuideListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RedDot2 CommonRedDot2View
---@field TextContain URichTextBox
---@field TextName URichTextBox
---@field TextNew UFTextBlock
---@field ToggleButton UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGuideListItemView = LuaClass(UIView, true)

function TutorialGuideListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RedDot2 = nil
	--self.TextContain = nil
	--self.TextName = nil
	--self.TextNew = nil
	--self.ToggleButton = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGuideListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGuideListItemView:OnInit()
	self.Binders = {
		{"TextName", UIBinderSetText.New(self, self.TextName)},
		{"TextNewVisible", UIBinderSetIsVisible.New(self, self.RedDot2)},
		{"TextContainVisible", UIBinderSetIsVisible.New(self, self.TextContain)},
		{"TextContain", UIBinderSetText.New(self, self.TextContain)},
		{"IsSelected", UIBinderSetIsChecked.New(self, self.ToggleButton, false)},
		-- {"IsNew", UIBinderSetIsVisible.New(self, self.RedDot2)},
	}
end

function TutorialGuideListItemView:OnDestroy()
end

function TutorialGuideListItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.GuideID ~= nil then
		local RedName = _G.TutorialGuideMgr:GetRedDotName(ViewModel.GuideID)
		if RedName ~= nil then
			self.RedDot2:SetRedDotNameByString(RedName)
		end
	end

	self.RedDot2:SetText(_G.LSTR(10030))
end

function TutorialGuideListItemView:OnHide()
end

function TutorialGuideListItemView:OnRegisterGameEvent()
end

function TutorialGuideListItemView:OnRegisterBinder()
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

function TutorialGuideListItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return 
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	ViewModel.IsSelected = bSelected
end

function TutorialGuideListItemView:ChangedNewStatus()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return 
	end

	ViewModel:ChangedNewStatus()
end





return TutorialGuideListItemView
