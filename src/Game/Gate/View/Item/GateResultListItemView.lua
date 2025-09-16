---
--- Author: sammrli
--- DateTime: 2023-09-20 20:31
--- Description:金蝶结算界面Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class GateResultListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextDescription01 UFTextBlock
---@field TextDescription02 UFTextBlock
---@field TextDescription03 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateResultListItemView = LuaClass(UIView, true)

function GateResultListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextDescription01 = nil
	--self.TextDescription02 = nil
	--self.TextDescription03 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateResultListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateResultListItemView:OnInit()

end

function GateResultListItemView:OnDestroy()

end

function GateResultListItemView:OnShow()

end

function GateResultListItemView:OnHide()

end

function GateResultListItemView:OnRegisterUIEvent()

end

function GateResultListItemView:OnRegisterGameEvent()

end

function GateResultListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	---@type GateResultListItemVM
	local GateResultListItemVM = self.Params.Data
	if nil == GateResultListItemVM then
		return
	end
	local Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
		{ "Name", UIBinderSetText.New(self, self.TextDescription01)},
		{ "Num", UIBinderSetText.New(self, self.TextDescription02)},
		{ "Score", UIBinderSetText.New(self, self.TextDescription03)},
	}
	self:RegisterBinders(GateResultListItemVM, Binders)
end

return GateResultListItemView