---
--- Author: sammrli
--- DateTime: 2023-05-22 10:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class FieldTestItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg UFImage
---@field Mark UFTextBlock
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FieldTestItemView = LuaClass(UIView, true)

function FieldTestItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.Mark = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FieldTestItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FieldTestItemView:OnInit()

end

function FieldTestItemView:OnDestroy()

end

function FieldTestItemView:OnShow()

end

function FieldTestItemView:OnHide()

end

function FieldTestItemView:OnRegisterUIEvent()
end

function FieldTestItemView:OnRegisterGameEvent()

end

function FieldTestItemView:OnRegisterBinder()
	if nil == self.Params then return end

	---@type FieldTestItemVM
	self.ViewModel = self.Params.Data

	local Binders = {
		{ "Text", UIBinderSetText.New(self, self.Text) },
		{ "BgColor", UIBinderSetColorAndOpacityHex.New(self, self.Bg) },
		{ "IsAutoExpand", UIBinderSetIsVisible.New(self, self.Mark)}
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function FieldTestItemView:OnSelectChanged(IsSelected)
	if self.ViewModel then
		self.ViewModel.BgColor =  IsSelected and "DEA309A0" or "00000001"
	end
end

return FieldTestItemView