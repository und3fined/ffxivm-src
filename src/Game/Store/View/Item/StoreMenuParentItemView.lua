 
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class StoreMenuParentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreMenuParentItemView = LuaClass(UIView, true)

function StoreMenuParentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreMenuParentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreMenuParentItemView:OnInit()
	-- self.Binders = {
	-- 	{ "TabName", UIBinderSetText.New(self, self.TextName) },
	-- 	{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
	-- 	{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName) },
	-- }
end

function StoreMenuParentItemView:OnDestroy()

end

function StoreMenuParentItemView:OnShow()

end

function StoreMenuParentItemView:OnHide()

end

function StoreMenuParentItemView:OnRegisterUIEvent()

end

function StoreMenuParentItemView:OnRegisterGameEvent()

end

function StoreMenuParentItemView:OnRegisterBinder()
	-- local Params = self.Params
	-- if nil == Params then
	-- 	return
	-- end

	-- local ViewModel = Params.Data
	-- if nil == ViewModel then
	-- 	return
	-- end

	-- self:RegisterBinders(ViewModel, self.Binders)
end

return StoreMenuParentItemView