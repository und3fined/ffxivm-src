---
--- Author: Administrator
--- DateTime: 2025-03-17 16:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CardsPrepareRuleListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextContent UFTextBlock
---@field ToggleBtnItem UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsPrepareRuleListItemView = LuaClass(UIView, true)

function CardsPrepareRuleListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextContent = nil
	--self.ToggleBtnItem = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsPrepareRuleListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsPrepareRuleListItemView:OnInit()
	self.Binders = {
		{ "RuleName", UIBinderSetText.New(self, self.TextContent) },
	}
end

function CardsPrepareRuleListItemView:OnDestroy()

end

function CardsPrepareRuleListItemView:OnShow()

end

function CardsPrepareRuleListItemView:OnHide()

end

function CardsPrepareRuleListItemView:OnRegisterUIEvent()

end

function CardsPrepareRuleListItemView:OnRegisterGameEvent()

end

function CardsPrepareRuleListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CardsPrepareRuleListItemView:OnSelectChanged(IsSelected)
	self.ToggleBtnItem:SetChecked(IsSelected, false)
end


return CardsPrepareRuleListItemView