---
--- Author: enqingchen
--- DateTime: 2021-12-31 16:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetAttrName = require("Binder/UIBinderSetAttrName")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local AttributeSummaryItemVM = require("Game/Attribute/VM/AttributeSummaryItemVM")
---@class AttributeSummaryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Text_AttriItem UFTextBlock
---@field Text_AttriValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AttributeSummaryItemView = LuaClass(UIView, true)

function AttributeSummaryItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text_AttriItem = nil
	--self.Text_AttriValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AttributeSummaryItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AttributeSummaryItemView:OnInit()
	self.ViewModel = AttributeSummaryItemVM.New()
end

function AttributeSummaryItemView:OnDestroy()

end

function AttributeSummaryItemView:OnShow()

end

function AttributeSummaryItemView:OnHide()

end

function AttributeSummaryItemView:OnRegisterUIEvent()

end

function AttributeSummaryItemView:OnRegisterGameEvent()

end

function AttributeSummaryItemView:OnRegisterBinder()
	local Binders = {
		{ "AttrKey", UIBinderSetAttrName.New(self, self.Text_AttriItem) },
		{ "AttrValue", UIBinderSetTextFormat.New(self, self.Text_AttriValue, "%d") },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return AttributeSummaryItemView