---
--- Author: jamiyang
--- DateTime: 2023-10-13 17:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class LoginCreateSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgEmpty UFImage
---@field ImgFace UFImage
---@field ImgNot UFImage
---@field ImgSelectEffect UFImage
---@field ImgTick UFImage
---@field TextWord UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateSlotItemView = LuaClass(UIView, true)

function LoginCreateSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgEmpty = nil
	--self.ImgFace = nil
	--self.ImgNot = nil
	--self.ImgSelectEffect = nil
	--self.ImgTick = nil
	--self.TextWord = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateSlotItemView:OnInit()
	self.Binders = {
		{ "ImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFace, true) },
		{ "bShowImgSelectEffect", UIBinderSetIsVisible.New(self, self.ImgSelectEffect) },
		{ "bShowImgTick", UIBinderSetIsVisible.New(self, self.ImgTick) },
		{ "bShowBlank", UIBinderSetIsVisible.New(self, self.ImgFace, true) },
		{ "bShowBlank", UIBinderSetIsVisible.New(self, self.ImgNot) },
		{ "bShowBlank", UIBinderSetIsVisible.New(self, self.TextWord) },
	}
end

function LoginCreateSlotItemView:OnDestroy()

end

function LoginCreateSlotItemView:OnShow()
	self.TextWord:SetText(_G.LSTR(1250040)) --"无"
end

function LoginCreateSlotItemView:OnHide()

end

function LoginCreateSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function LoginCreateSlotItemView:OnRegisterGameEvent()

end

function LoginCreateSlotItemView:OnRegisterBinder()
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

function LoginCreateSlotItemView:OnClickButtonItem()
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

function LoginCreateSlotItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
end

return LoginCreateSlotItemView