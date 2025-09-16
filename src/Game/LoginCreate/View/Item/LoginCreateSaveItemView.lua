---
--- Author: jamiyang
--- DateTime: 2023-11-16 11:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class LoginCreateSaveItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextSaveNum UFTextBlock
---@field TextSaveTime UFTextBlock
---@field TextTribeGender UFTextBlock
---@field ToggleBtnSave UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateSaveItemView = LuaClass(UIView, true)

function LoginCreateSaveItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextSaveNum = nil
	--self.TextSaveTime = nil
	--self.TextTribeGender = nil
	--self.ToggleBtnSave = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateSaveItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateSaveItemView:OnInit()
	self.Binders = {
		{ "IdText", UIBinderSetText.New(self, self.TextSaveNum)},
		{ "TimeText", UIBinderSetText.New(self, self.TextSaveTime)},
		{ "TribeGenderText", UIBinderSetText.New(self, self.TextTribeGender)},
		{ "bItemSelect", UIBinderSetIsChecked.New(self, self.ToggleBtnSave)},
	}

end

function LoginCreateSaveItemView:OnDestroy()

end

function LoginCreateSaveItemView:OnShow()

end

function LoginCreateSaveItemView:OnHide()

end

function LoginCreateSaveItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnSave, self.OnClickButtonItem)

end

function LoginCreateSaveItemView:OnRegisterGameEvent()

end

function LoginCreateSaveItemView:OnRegisterBinder()
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

function LoginCreateSaveItemView:OnClickButtonItem()
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

function LoginCreateSaveItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
end

return LoginCreateSaveItemView