---
--- Author: Administrator
--- DateTime: 2024-01-30 10:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class PhotoRoleStatItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgPic UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoRoleStatItemView = LuaClass(UIView, true)

function PhotoRoleStatItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgPic = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoRoleStatItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoRoleStatItemView:OnInit()
	self.Binders = 
	{
		{ "Name", 				UIBinderSetText.New(self, self.TextName) },
		{ "Icon", 				UIBinderSetBrushFromAssetPath.New(self, self.ImgPic) },
		{ "IsSelected", 		UIBinderSetIsVisible.New(self, self.ImgSelect) },
	}
end

function PhotoRoleStatItemView:OnDestroy()

end

function PhotoRoleStatItemView:OnShow()

end

function PhotoRoleStatItemView:OnHide()

end

function PhotoRoleStatItemView:OnRegisterUIEvent()

end

function PhotoRoleStatItemView:OnRegisterGameEvent()

end

function PhotoRoleStatItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function PhotoRoleStatItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then
		return
	end

	local VM = Params.Data
	if nil == VM then
		return
	end

	VM.IsSelected = IsSelected
end

return PhotoRoleStatItemView