---
--- Author: Administrator
--- DateTime: 2025-07-25 19:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class OpsReturnPointItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnPointItemView = LuaClass(UIView, true)

function OpsReturnPointItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnPointItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnPointItemView:OnInit()
	self.Binders = {
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
	}
end

function OpsReturnPointItemView:OnDestroy()

end

function OpsReturnPointItemView:OnShow()

end

function OpsReturnPointItemView:OnHide()

end

function OpsReturnPointItemView:OnRegisterUIEvent()

end

function OpsReturnPointItemView:OnRegisterGameEvent()

end

function OpsReturnPointItemView:OnRegisterBinder()
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

function OpsReturnPointItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
end

return OpsReturnPointItemView