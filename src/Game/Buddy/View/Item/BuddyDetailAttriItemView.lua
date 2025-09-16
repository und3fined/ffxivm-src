---
--- Author: Administrator
--- DateTime: 2023-11-30 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class BuddyDetailAttriItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextAttri UFTextBlock
---@field TextAttriValue URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyDetailAttriItemView = LuaClass(UIView, true)

function BuddyDetailAttriItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextAttri = nil
	--self.TextAttriValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyDetailAttriItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyDetailAttriItemView:OnInit()
	self.Binders = {
		{ "AttriText", UIBinderSetText.New(self, self.TextAttri)},
		{ "ValueText", UIBinderSetText.New(self, self.TextAttriValue) },
	}
end

function BuddyDetailAttriItemView:OnDestroy()

end

function BuddyDetailAttriItemView:OnShow()

end

function BuddyDetailAttriItemView:OnHide()

end

function BuddyDetailAttriItemView:OnRegisterUIEvent()

end

function BuddyDetailAttriItemView:OnRegisterGameEvent()

end

function BuddyDetailAttriItemView:OnRegisterBinder()
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

return BuddyDetailAttriItemView