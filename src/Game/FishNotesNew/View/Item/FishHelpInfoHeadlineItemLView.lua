---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class FishHelpInfoHeadlineItemLView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishHelpInfoHeadlineItemLView = LuaClass(UIView, true)

function FishHelpInfoHeadlineItemLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishHelpInfoHeadlineItemLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishHelpInfoHeadlineItemLView:OnInit()
	self.Binders = 
	{
		{"RichTextTitle", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function FishHelpInfoHeadlineItemLView:OnDestroy()

end

function FishHelpInfoHeadlineItemLView:OnShow()
	
end

function FishHelpInfoHeadlineItemLView:OnHide()

end

function FishHelpInfoHeadlineItemLView:OnRegisterUIEvent()

end

function FishHelpInfoHeadlineItemLView:OnRegisterGameEvent()

end

function FishHelpInfoHeadlineItemLView:OnRegisterBinder()
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

return FishHelpInfoHeadlineItemLView