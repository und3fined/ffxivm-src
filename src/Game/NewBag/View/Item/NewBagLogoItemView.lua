---
--- Author: Administrator
--- DateTime: 2023-09-07 20:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class NewBagLogoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagLogoItemView = LuaClass(UIView, true)

function NewBagLogoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagLogoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagLogoItemView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
	}

end

function NewBagLogoItemView:OnDestroy()

end

function NewBagLogoItemView:OnShow()

end

function NewBagLogoItemView:OnHide()

end

function NewBagLogoItemView:OnRegisterUIEvent()

end

function NewBagLogoItemView:OnRegisterGameEvent()

end

function NewBagLogoItemView:OnRegisterBinder()

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


return NewBagLogoItemView