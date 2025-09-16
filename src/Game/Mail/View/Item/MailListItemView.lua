local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local MailMgr = _G.MailMgr

---@class MailListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field CommonRedDot CommonRedDotView
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field RichTextDate URichTextBox
---@field RichTextMailName URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MailListItemView = LuaClass(UIView, true)

function MailListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.CommonRedDot = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.RichTextDate = nil
	--self.RichTextMailName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MailListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MailListItemView:OnInit()
	self.Binders = {
		{ "ShowTitle", UIBinderSetText.New(self, self.RichTextMailName ) },
		{ "ImgIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "ID", UIBinderValueChangedCallback.New(self, nil, self.OnIDChanged) },
		{ "TimeText", UIBinderSetText.New(self, self.RichTextDate ) },
		{ "ShowTitleColor", UIBinderSetColorAndOpacityHex.New(self, self.RichTextMailName) },
	}
end

function MailListItemView:OnDestroy()

end

function MailListItemView:OnShow()
	UIUtil.SetIsVisible(self.ImgSelect, false)
end

function MailListItemView:OnHide()

end

function MailListItemView:OnRegisterUIEvent()

end

function MailListItemView:OnRegisterGameEvent()

end

function MailListItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function MailListItemView:OnSelectChanged(IsSelected, IsByClick)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	ViewModel.IsSelected = IsSelected
	ViewModel:RefreshShowTitleColor()
end

function MailListItemView:OnIDChanged(NewValue, OldValue)
	self.CommonRedDot:SetRedDotNameByString(MailMgr:GetRedDotName(NewValue))
end

return MailListItemView