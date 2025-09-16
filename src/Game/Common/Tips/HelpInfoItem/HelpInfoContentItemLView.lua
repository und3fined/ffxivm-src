---
--- Author: Administrator
--- DateTime: 2023-09-13 09:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HelpInfoContentItemLView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HelpInfoContentItemLView = LuaClass(UIView, true)

function HelpInfoContentItemLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HelpInfoContentItemLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HelpInfoContentItemLView:OnInit()
	self.Binders = 
	{
		{"RichTextContent", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function HelpInfoContentItemLView:OnDestroy()

end

function HelpInfoContentItemLView:OnShow()

end

function HelpInfoContentItemLView:OnHide()

end

function HelpInfoContentItemLView:OnRegisterUIEvent()

end

function HelpInfoContentItemLView:OnRegisterGameEvent()

end

function HelpInfoContentItemLView:OnRegisterBinder()
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

return HelpInfoContentItemLView