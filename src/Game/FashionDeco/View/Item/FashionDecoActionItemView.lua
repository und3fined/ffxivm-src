---
--- Author: ccppeng
--- DateTime: 2024-11-05 21:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
---@class FashionDecoActionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconAction UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoActionItemView = LuaClass(UIView, true)

function FashionDecoActionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconAction = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoActionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionDecoActionItemView:OnInit()

end

function FashionDecoActionItemView:OnDestroy()

end

function FashionDecoActionItemView:OnShow()

end

function FashionDecoActionItemView:OnHide()

end

function FashionDecoActionItemView:OnRegisterUIEvent()

end

function FashionDecoActionItemView:OnRegisterGameEvent()

end

function FashionDecoActionItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel

	self.Binders = {
		{"AppearanceIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconAction)},

	}
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return FashionDecoActionItemView