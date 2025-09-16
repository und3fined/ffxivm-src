---
--- Author: sammrli
--- DateTime: 2023-09-18 20:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class GateScoreItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgScoreNumber UFImage
---@field AnimScoreAdd UWidgetAnimation
---@field AnimScoreSubtract UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateScoreItemView = LuaClass(UIView, true)

function GateScoreItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgScoreNumber = nil
	--self.AnimScoreAdd = nil
	--self.AnimScoreSubtract = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateScoreItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateScoreItemView:OnInit()

end

function GateScoreItemView:OnDestroy()

end

function GateScoreItemView:OnShow()

end

function GateScoreItemView:OnHide()

end

function GateScoreItemView:OnRegisterUIEvent()

end

function GateScoreItemView:OnRegisterGameEvent()

end

function GateScoreItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	---@type GateScoreItemVM
	local GateScoreItemVM = self.Params.Data
	if nil == GateScoreItemVM then
		return
	end

	local Binders = {
		{ "IconNumber", UIBinderSetBrushFromAssetPath.New(self, self.ImgScoreNumber)},
	}
	self:RegisterBinders(GateScoreItemVM, Binders)

	local CallbackAdd = function()
		self:PlayAnim(true)
	end
	GateScoreItemVM:SetNumberAddCallback(CallbackAdd)
	local CallbackSubtract = function()
		self:PlayAnim(false)
	end
	GateScoreItemVM:SetNumberSubtractCallback(CallbackSubtract)
end

function GateScoreItemView:PlayAnim(IsAdd)
	if IsAdd then
		self:PlayAnimation(self.AnimScoreAdd)
	else
		self:PlayAnimation(self.AnimScoreSubtract)
	end
end

return GateScoreItemView