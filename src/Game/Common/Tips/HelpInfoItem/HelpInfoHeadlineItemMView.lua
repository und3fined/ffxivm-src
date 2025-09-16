---
--- Author: Administrator
--- DateTime: 2023-09-13 09:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HelpInfoHeadlineItemMView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HelpInfoHeadlineItemMView = LuaClass(UIView, true)

function HelpInfoHeadlineItemMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HelpInfoHeadlineItemMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HelpInfoHeadlineItemMView:OnInit()
	self.Binders = 
	{
		{"RichTextTitle", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function HelpInfoHeadlineItemMView:OnDestroy()

end

function HelpInfoHeadlineItemMView:OnShow()

end

function HelpInfoHeadlineItemMView:OnHide()

end

function HelpInfoHeadlineItemMView:OnRegisterUIEvent()

end

function HelpInfoHeadlineItemMView:OnRegisterGameEvent()

end

function HelpInfoHeadlineItemMView:OnRegisterBinder()
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

return HelpInfoHeadlineItemMView