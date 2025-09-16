---
--- Author: jamiyang
--- DateTime: 2024-01-23 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class HaircutSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field IconLock UFImage
---@field IconSpecial UFImage
---@field ImgFace UFImage
---@field ImgMask UFImage
---@field ImgNot UFImage
---@field ImgSelectEffect UFImage
---@field Imgmultipleselection1 UFImage
---@field Imgmultipleselection2 UFImage
---@field Panelmultipleselection UFCanvasPanel
---@field TextWord UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutSlotItemView = LuaClass(UIView, true)

function HaircutSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.IconLock = nil
	--self.IconSpecial = nil
	--self.ImgFace = nil
	--self.ImgMask = nil
	--self.ImgNot = nil
	--self.ImgSelectEffect = nil
	--self.Imgmultipleselection1 = nil
	--self.Imgmultipleselection2 = nil
	--self.Panelmultipleselection = nil
	--self.TextWord = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutSlotItemView:OnInit()
	self.Binders = {
		{ "ImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFace, true) },
		--{ "bShowImgSelectEffect", UIBinderSetIsVisible.New(self, self.ImgSelectEffect) },
		{ "bShowImgTick", UIBinderSetIsVisible.New(self, self.Imgmultipleselection1) },
		{ "bShowImgTick", UIBinderSetIsVisible.New(self, self.Imgmultipleselection2) },
		{ "bShowBlank", UIBinderSetIsVisible.New(self, self.ImgFace, true) },
		{ "bShowBlank", UIBinderSetIsVisible.New(self, self.ImgNot) },
		{ "bShowBlank", UIBinderSetIsVisible.New(self, self.TextWord) },
		{ "bSpecial", UIBinderSetIsVisible.New(self, self.IconSpecial) },
		{ "bLocked", UIBinderSetIsVisible.New(self, self.IconLock) },
		{ "bLocked", UIBinderSetIsVisible.New(self, self.ImgMask) },
		--{ "bLocked", UIBinderValueChangedCallback.New(self, nil, self.OnLockChange) },
	}
end

function HaircutSlotItemView:OnDestroy()

end

function HaircutSlotItemView:OnShow()
	self.TextWord:SetText(_G.LSTR(1250040)) --"无"
end

function HaircutSlotItemView:OnHide()
	
end

function HaircutSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function HaircutSlotItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.HairUnlockCompleted, self.OnHairUnlockCompleted)
end

function HaircutSlotItemView:OnRegisterBinder()
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

function HaircutSlotItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.IsSingSelect == false then
		ViewModel:ItemSelectChanged()
		local ParentView = Adapter.ParentView
		ParentView:OnWorldTableSelectChange(Params.Index)
	elseif ViewModel and ViewModel.IsSingSelect and ViewModel.bShowImgSelectEffect and ViewModel.bUseCancel and Params.Index > 1 then
		self:OnSelectChanged(false)
		local ParentView = Adapter.ParentView
		ParentView.FaceTableView:SetSelectedIndex(1)
	else
		Adapter:OnItemClicked(self, Params.Index)
	end
end

function HaircutSlotItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end

	if IsSelected then
		self:PlayAnimation(self.AnimChecked)
	else
		self:PlayAnimation(self.AnimUnchecked)
	end
end

function HaircutSlotItemView:OnLockChange(NewValue, OldValue)
	if OldValue == true and NewValue == false then
		self:PlayAnimation(self.AnimUnlock)
	end
end

function HaircutSlotItemView:OnHairUnlockCompleted()
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.bShowImgSelectEffect then
		self:PlayAnimation(self.AnimUnlock)
	end
end

return HaircutSlotItemView