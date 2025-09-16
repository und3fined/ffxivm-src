---
--- Author: Administrator
--- DateTime: 2023-09-13 09:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HelpInfoHeadlineItemLView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HelpInfoHeadlineItemLView = LuaClass(UIView, true)

function HelpInfoHeadlineItemLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HelpInfoHeadlineItemLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HelpInfoHeadlineItemLView:OnInit()
	self.Binders = 
	{
		{"RichTextTitle", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function HelpInfoHeadlineItemLView:OnDestroy()

end

function HelpInfoHeadlineItemLView:OnShow()

end

function HelpInfoHeadlineItemLView:OnHide()

end

function HelpInfoHeadlineItemLView:OnRegisterUIEvent()

end

function HelpInfoHeadlineItemLView:OnRegisterGameEvent()

end

function HelpInfoHeadlineItemLView:OnRegisterBinder()
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

return HelpInfoHeadlineItemLView