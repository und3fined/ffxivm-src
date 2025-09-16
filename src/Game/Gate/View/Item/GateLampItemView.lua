---
--- Author: sammrli
--- DateTime: 2023-09-14 16:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class GateLampItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNumber UFImage
---@field AnimScoreAdd UWidgetAnimation
---@field AnimScoreSubtract UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateLampItemView = LuaClass(UIView, true)

function GateLampItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNumber = nil
	--self.AnimScoreAdd = nil
	--self.AnimScoreSubtract = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateLampItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateLampItemView:OnInit()
end

function GateLampItemView:OnDestroy()

end

function GateLampItemView:OnShow()

end

function GateLampItemView:OnHide()

end

function GateLampItemView:OnRegisterUIEvent()

end

function GateLampItemView:OnRegisterGameEvent()

end

function GateLampItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	---@see GateLampItemVM
	local GateLampItemVM = self.Params.Data
	if nil == GateLampItemVM then
		return
	end

	local Binders =
	{
		{ "IconNumber", UIBinderSetBrushFromAssetPath.New(self, self.ImgNumber)},
	}
	self:RegisterBinders(GateLampItemVM, Binders)

	local CallbackAdd = function()
		self:PlayAnim(true)
	end
	GateLampItemVM:SetNumberAddCallback(CallbackAdd)
	local CallbackSubtract = function()
		self:PlayAnim(false)
	end
	GateLampItemVM:SetNumberSubtractCallback(CallbackSubtract)
end

function GateLampItemView:PlayAnim(IsAdd)
	if IsAdd then
		self:PlayAnimation(self.AnimScoreAdd)
	else
		self:PlayAnimation(self.AnimScoreSubtract)
	end
end

return GateLampItemView