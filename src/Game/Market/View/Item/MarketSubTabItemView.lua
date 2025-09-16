---
--- Author: Administrator
--- DateTime: 2024-06-14 11:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
---@class MarketSubTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFocus UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketSubTabItemView = LuaClass(UIView, true)

function MarketSubTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgFocus = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketSubTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketSubTabItemView:OnInit()
	self.Binders = {
		{ "SubTabName", UIBinderSetText.New(self, self.TextName) },
		{ "SelectedVisible", UIBinderSetIsVisible.New(self, self.ImgFocus) },
		{ "NameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName) },
	}
end

function MarketSubTabItemView:OnDestroy()

end

function MarketSubTabItemView:OnShow()

end

function MarketSubTabItemView:OnHide()

end

function MarketSubTabItemView:OnRegisterUIEvent()

end

function MarketSubTabItemView:OnRegisterGameEvent()

end

function MarketSubTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if nil == self.Binders then return end
	
	self:RegisterBinders(ViewModel, self.Binders)
end


return MarketSubTabItemView