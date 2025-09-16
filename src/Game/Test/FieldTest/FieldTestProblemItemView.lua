---
--- Author: sammrli
--- DateTime: 2023-06-15 12:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class FieldTestProblemItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg_1 UFImage
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FieldTestProblemItemView = LuaClass(UIView, true)

function FieldTestProblemItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg_1 = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FieldTestProblemItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FieldTestProblemItemView:OnInit()

end

function FieldTestProblemItemView:OnDestroy()

end

function FieldTestProblemItemView:OnShow()

end

function FieldTestProblemItemView:OnHide()

end

function FieldTestProblemItemView:OnRegisterUIEvent()
end

function FieldTestProblemItemView:OnRegisterGameEvent()

end

function FieldTestProblemItemView:OnRegisterBinder()
	if nil == self.Params then return end

	---@type FieldTestProblemItemVM
	self.ViewModel = self.Params.Data

	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.Text) },
		{ "BgColor", UIBinderSetColorAndOpacityHex.New(self, self.Bg_1) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function FieldTestProblemItemView:OnSelectChanged(IsSelected)
	if self.ViewModel then
		self.ViewModel.BgColor =  IsSelected and "DEA309A0" or "FFFFFF66"
	end
end

return FieldTestProblemItemView