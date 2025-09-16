---
--- Author: Administrator
--- DateTime: 2023-10-17 20:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ShopInletListItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgInlerBg UFImage
---@field ImgInlet UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopInletListItemNewView = LuaClass(UIView, true)

function ShopInletListItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgInlerBg = nil
	--self.ImgInlet = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopInletListItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopInletListItemNewView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgInlet) },
	}
end

function ShopInletListItemNewView:OnDestroy()

end

function ShopInletListItemNewView:OnShow()

end

function ShopInletListItemNewView:OnHide()

end

function ShopInletListItemNewView:OnRegisterUIEvent()

end

function ShopInletListItemNewView:OnRegisterGameEvent()

end

function ShopInletListItemNewView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

return ShopInletListItemNewView