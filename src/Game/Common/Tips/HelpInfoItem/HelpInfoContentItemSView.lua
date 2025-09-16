---
--- Author: Administrator
--- DateTime: 2024-06-27 11:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HelpInfoContentItemSView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HelpInfoContentItemSView = LuaClass(UIView, true)

function HelpInfoContentItemSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HelpInfoContentItemSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HelpInfoContentItemSView:OnInit()
	self.Binders = 
	{
		{"RichTextContent", UIBinderSetText.New(self, self.RichTextContent)},
	}

end

function HelpInfoContentItemSView:OnDestroy()

end

function HelpInfoContentItemSView:OnShow()
	if self.Params then
		local VM = self.Params.Data
		if VM and VM.BindableProperties and VM.BindableProperties.RichTextContent then
			local TextCon = VM.BindableProperties.RichTextContent.Value
			if TextCon == "      " then
				UIUtil.TextBlockSetFontSize(self.RichTextContent, 8)
			end
		end
	end
end

function HelpInfoContentItemSView:OnHide()

end

function HelpInfoContentItemSView:OnRegisterUIEvent()

end

function HelpInfoContentItemSView:OnRegisterGameEvent()

end

function HelpInfoContentItemSView:OnRegisterBinder()
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

return HelpInfoContentItemSView