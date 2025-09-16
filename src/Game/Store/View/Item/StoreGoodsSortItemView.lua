
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class StoreGoodsSortItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field TextSort UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreGoodsSortItemView = LuaClass(UIView, true)

function StoreGoodsSortItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.TextSort = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreGoodsSortItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreGoodsSortItemView:OnInit()
	self.Binders = {
		{ "SubName", UIBinderSetText.New(self, self.TextSort) },
		{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSort) },
	}
end

function StoreGoodsSortItemView:OnDestroy()

end

function StoreGoodsSortItemView:OnShow()

end

function StoreGoodsSortItemView:OnHide()

end

function StoreGoodsSortItemView:OnRegisterUIEvent()

end

function StoreGoodsSortItemView:OnRegisterGameEvent()

end

function StoreGoodsSortItemView:OnRegisterBinder()
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

return StoreGoodsSortItemView