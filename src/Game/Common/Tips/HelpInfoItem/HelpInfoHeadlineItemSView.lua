---
--- Author: Administrator
--- DateTime: 2024-06-27 11:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HelpInfoHeadlineItemSView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HelpInfoHeadlineItemSView = LuaClass(UIView, true)

function HelpInfoHeadlineItemSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HelpInfoHeadlineItemSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HelpInfoHeadlineItemSView:OnInit()
	self.Binders = 
	{
		{"RichTextTitle", UIBinderSetText.New(self, self.RichTextContent)},
	}

end

function HelpInfoHeadlineItemSView:OnDestroy()

end

function HelpInfoHeadlineItemSView:OnShow()

end

function HelpInfoHeadlineItemSView:OnHide()

end

function HelpInfoHeadlineItemSView:OnRegisterUIEvent()

end

function HelpInfoHeadlineItemSView:OnRegisterGameEvent()

end

function HelpInfoHeadlineItemSView:OnRegisterBinder()
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

return HelpInfoHeadlineItemSView