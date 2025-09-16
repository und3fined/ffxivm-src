---
--- Author: Administrator
--- DateTime: 2023-04-03 19:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MentorConditionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgConditionFalse UFImage
---@field ImgConditionTrue UFImage
---@field RichTextCondition02 URichTextBox
---@field TextCondition UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MentorConditionItemView = LuaClass(UIView, true)

function MentorConditionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgConditionFalse = nil
	--self.ImgConditionTrue = nil
	--self.RichTextCondition02 = nil
	--self.TextCondition = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MentorConditionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MentorConditionItemView:OnInit()
	self.Binders = {
		{ "TextCondition", UIBinderSetText.New(self, self.TextCondition) },
		{ "ImgConditionTrue", UIBinderSetIsVisible.New(self, self.ImgConditionTrue, false, false, false) },
		{ "TextProgress", UIBinderSetText.New(self, self.RichTextCondition02) },
		{ "VisibleProgress", UIBinderSetIsVisible.New(self, self.RichTextCondition02) },
	}
end

function MentorConditionItemView:OnDestroy()

end

function MentorConditionItemView:OnShow()

end

function MentorConditionItemView:OnHide()

end

function MentorConditionItemView:OnRegisterUIEvent()

end

function MentorConditionItemView:OnRegisterGameEvent()

end

function MentorConditionItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return MentorConditionItemView