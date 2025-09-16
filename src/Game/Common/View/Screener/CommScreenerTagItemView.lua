---
--- Author: lydianwang
--- DateTime: 2023-06-08 17:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CommScreenerTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTagName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommScreenerTagItemView = LuaClass(UIView, true)

function CommScreenerTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextTagName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommScreenerTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommScreenerTagItemView:OnInit()

end

function CommScreenerTagItemView:OnDestroy()

end

function CommScreenerTagItemView:OnShow()

end

function CommScreenerTagItemView:OnHide()

end

function CommScreenerTagItemView:OnRegisterUIEvent()

end

function CommScreenerTagItemView:OnRegisterGameEvent()

end

function CommScreenerTagItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "TagNameText", UIBinderSetText.New(self, self.TextTagName) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

return CommScreenerTagItemView