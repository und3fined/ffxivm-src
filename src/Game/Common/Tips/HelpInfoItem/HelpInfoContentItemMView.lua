---
--- Author: Administrator
--- DateTime: 2023-09-13 09:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HelpInfoContentItemMView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HelpInfoContentItemMView = LuaClass(UIView, true)

function HelpInfoContentItemMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HelpInfoContentItemMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HelpInfoContentItemMView:OnInit()
	self.Binders = 
	{
		{"RichTextContent", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function HelpInfoContentItemMView:OnDestroy()

end

function HelpInfoContentItemMView:OnShow()

end

function HelpInfoContentItemMView:OnHide()

end

function HelpInfoContentItemMView:OnRegisterUIEvent()

end

function HelpInfoContentItemMView:OnRegisterGameEvent()

end

function HelpInfoContentItemMView:OnRegisterBinder()
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

return HelpInfoContentItemMView