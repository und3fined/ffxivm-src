---
--- Author: Administrator
--- DateTime: 2025-04-03 19:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CommTipsTextItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommTipsTextItemView = LuaClass(UIView, true)

function CommTipsTextItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommTipsTextItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommTipsTextItemView:OnInit()
	self.Binders = 
	{
		{"RichTextContent", UIBinderSetText.New(self, self.RichTextContent)},
	}
end

function CommTipsTextItemView:OnDestroy()

end

function CommTipsTextItemView:OnShow()

end

function CommTipsTextItemView:OnHide()

end

function CommTipsTextItemView:OnRegisterUIEvent()

end

function CommTipsTextItemView:OnRegisterGameEvent()

end

function CommTipsTextItemView:OnRegisterBinder()

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

return CommTipsTextItemView