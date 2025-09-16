---
--- Author: henghaoli
--- DateTime: 2025-02-20 11:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HelpInfoSkillItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextLeft URichTextBox
---@field RichTextRight URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HelpInfoSkillItemView = LuaClass(UIView, true)

function HelpInfoSkillItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextLeft = nil
	--self.RichTextRight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HelpInfoSkillItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HelpInfoSkillItemView:OnInit()
	self.Binders = {
		{ "TextLeft", UIBinderSetText.New(self, self.RichTextLeft) },
		{ "TextRight", UIBinderSetText.New(self, self.RichTextRight) },
	}
end

function HelpInfoSkillItemView:OnDestroy()

end

function HelpInfoSkillItemView:OnShow()

end

function HelpInfoSkillItemView:OnHide()

end

function HelpInfoSkillItemView:OnRegisterUIEvent()

end

function HelpInfoSkillItemView:OnRegisterGameEvent()

end

function HelpInfoSkillItemView:OnRegisterBinder()
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

return HelpInfoSkillItemView