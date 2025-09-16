---
--- Author: jususchen
--- DateTime: 2024-08-12 14:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PWorldExplainItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldExplainItemView = LuaClass(UIView, true)

function PWorldExplainItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldExplainItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldExplainItemView:OnInit()
	self.Binders = 
	{
		{"RichTextTitle", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function PWorldExplainItemView:OnRegisterBinder()
	if self.Params and self.Params.Data then
		self:RegisterBinders(self.Params.Data, self.Binders)
	end
end

return PWorldExplainItemView