---
--- Author: Administrator
--- DateTime: 2024-01-17 15:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class ChocoboNameWordItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field TextWord UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboNameWordItemView = LuaClass(UIView, true)

function ChocoboNameWordItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.TextWord = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboNameWordItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboNameWordItemView:OnInit()

end

function ChocoboNameWordItemView:OnDestroy()

end

function ChocoboNameWordItemView:OnShow()

end

function ChocoboNameWordItemView:OnHide()

end

function ChocoboNameWordItemView:OnRegisterUIEvent()

end

function ChocoboNameWordItemView:OnRegisterGameEvent()

end

function ChocoboNameWordItemView:OnRegisterBinder()
	local Params = self.Params
	if Params ==  nil then return end 

	local ViewModel = Params.Data
	if ViewModel == nil then return end

 	local Binders = {
        { "TextWord", UIBinderSetText.New(self, self.TextWord) },
        { "Selected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "TextWordColor", UIBinderSetColorAndOpacityHex.New(self, self.TextWord) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

function ChocoboNameWordItemView:OnSelectChanged(Value)
	local Params = self.Params
	if Params ==  nil then return end 

	local ViewModel = Params.Data
	if ViewModel == nil then return end
	ViewModel:SetSelect(Value)
end

return ChocoboNameWordItemView