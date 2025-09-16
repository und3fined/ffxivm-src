---
--- Author: ghnvbnvb
--- DateTime: 2023-05-09 17:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CraftingLogCareerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field TextCareer UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogCareerItemView = LuaClass(UIView, true)

function CraftingLogCareerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.TextCareer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogCareerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CraftingLogCareerItemView:OnInit()
	self.Binders = {
		{ "TypeTabName", UIBinderSetText.New(self, self.TextCareer) },
	}
end

function CraftingLogCareerItemView:OnDestroy()

end

function CraftingLogCareerItemView:OnShow()

end

function CraftingLogCareerItemView:OnHide()

end

function CraftingLogCareerItemView:OnRegisterUIEvent()

end

function CraftingLogCareerItemView:OnRegisterGameEvent()

end

function CraftingLogCareerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return CraftingLogCareerItemView