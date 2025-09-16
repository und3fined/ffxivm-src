---
--- Author: xingcaicao
--- DateTime: 2023-05-16 11:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class PersonInfoGameStyleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconStyle UFImage
---@field IconUnStyle UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoGameStyleItemView = LuaClass(UIView, true)

function PersonInfoGameStyleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconStyle = nil
	--self.IconUnStyle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoGameStyleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoGameStyleItemView:OnInit()
	self.Binders = {
		{ "Icon", 		UIBinderSetImageBrush.New(self, self.IconStyle) },
		{ "IsEmpty",	UIBinderSetIsVisible.New(self, self.IconUnStyle) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.IconStyle, true) },
	}
end

function PersonInfoGameStyleItemView:OnDestroy()

end

function PersonInfoGameStyleItemView:OnShow()

end

function PersonInfoGameStyleItemView:OnHide()

end

function PersonInfoGameStyleItemView:OnRegisterUIEvent()

end

function PersonInfoGameStyleItemView:OnRegisterGameEvent()

end

function PersonInfoGameStyleItemView:OnRegisterBinder()
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

return PersonInfoGameStyleItemView