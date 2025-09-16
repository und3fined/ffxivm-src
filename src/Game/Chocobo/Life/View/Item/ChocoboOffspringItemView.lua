---
--- Author: Administrator
--- DateTime: 2024-01-04 21:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")

---@class ChocoboOffspringItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Avatar ChocoboAvatarItemView
---@field ImgGender UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboOffspringItemView = LuaClass(UIView, true)

function ChocoboOffspringItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Avatar = nil
	--self.ImgGender = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboOffspringItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Avatar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboOffspringItemView:OnInit()

end

function ChocoboOffspringItemView:OnDestroy()

end

function ChocoboOffspringItemView:OnShow()

end

function ChocoboOffspringItemView:OnHide()

end

function ChocoboOffspringItemView:OnRegisterUIEvent()

end

function ChocoboOffspringItemView:OnRegisterGameEvent()

end

function ChocoboOffspringItemView:OnRegisterBinder()
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
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "GenderPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGender) },
		{ "Color", UIBinderSetColorAndOpacity.New(self, self.Avatar.ImgColor) },
	}
	self:RegisterBinders(ViewModel, Binders)
end

return ChocoboOffspringItemView