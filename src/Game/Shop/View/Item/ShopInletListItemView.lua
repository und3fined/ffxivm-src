---
--- Author: Administrator
--- DateTime: 2024-08-20 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIconItemAndScore = require("Binder/UIBinderSetIconItemAndScore")

---@class ShopInletListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnList UFButton
---@field ImgInlerBg UFImage
---@field ImgInlet UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopInletListItemView = LuaClass(UIView, true)

function ShopInletListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnList = nil
	--self.ImgInlerBg = nil
	--self.ImgInlet = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopInletListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopInletListItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgInlerBg) },
		{ "ScoreID", UIBinderSetIconItemAndScore.New(self, self.ImgInlet) },
	}
end

function ShopInletListItemView:OnDestroy()

end

function ShopInletListItemView:OnShow()

end

function ShopInletListItemView:OnHide()

end

function ShopInletListItemView:OnRegisterUIEvent()

end

function ShopInletListItemView:OnRegisterGameEvent()

end

function ShopInletListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

return ShopInletListItemView