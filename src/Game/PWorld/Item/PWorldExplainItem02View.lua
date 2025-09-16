---
--- Author: jususchen
--- DateTime: 2024-08-13 11:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PWorldExplainItem02View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldExplainItem02View = LuaClass(UIView, true)

function PWorldExplainItem02View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldExplainItem02View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldExplainItem02View:OnInit()
	self.Binders = 
	{
		{"RichTextContent", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function PWorldExplainItem02View:OnRegisterBinder()
	if self.Params and self.Params.Data then
		self:RegisterBinders(self.Params.Data, self.Binders)
	end
end

return PWorldExplainItem02View