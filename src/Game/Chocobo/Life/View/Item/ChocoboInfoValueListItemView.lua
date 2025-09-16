---
--- Author: Administrator
--- DateTime: 2023-12-14 15:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ChocoboInfoValueListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextValue UFTextBlock
---@field TextValueCount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboInfoValueListItemView = LuaClass(UIView, true)

function ChocoboInfoValueListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextValue = nil
	--self.TextValueCount = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboInfoValueListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboInfoValueListItemView:OnInit()

end

function ChocoboInfoValueListItemView:OnDestroy()

end

function ChocoboInfoValueListItemView:OnShow()

end

function ChocoboInfoValueListItemView:OnHide()

end

function ChocoboInfoValueListItemView:OnRegisterUIEvent()

end

function ChocoboInfoValueListItemView:OnRegisterGameEvent()

end

function ChocoboInfoValueListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	if nil == Data then
		return
	end

	local ViewModel = Data
	self.VM = ViewModel

	local Binders = {
		{ "AttrName", UIBinderSetText.New(self, self.TextValue) },
		{ "AttrIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "AttrValue", UIBinderSetText.New(self, self.TextValueCount) },
	}
	self:RegisterBinders(ViewModel, Binders)
end

return ChocoboInfoValueListItemView