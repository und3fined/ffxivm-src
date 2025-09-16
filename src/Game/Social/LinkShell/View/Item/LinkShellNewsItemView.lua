---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class LinkShellNewsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextNews URichTextBox
---@field RichTextTime URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellNewsItemView = LuaClass(UIView, true)

function LinkShellNewsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextNews = nil
	--self.RichTextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellNewsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellNewsItemView:OnInit()
	self.Binders = {
		{ "Desc", 		UIBinderSetText.New(self, self.RichTextNews) },
		{ "TimeDesc", 	UIBinderSetText.New(self, self.RichTextTime) },
	}
end

function LinkShellNewsItemView:OnDestroy()

end

function LinkShellNewsItemView:OnShow()

end

function LinkShellNewsItemView:OnHide()

end

function LinkShellNewsItemView:OnRegisterUIEvent()

end

function LinkShellNewsItemView:OnRegisterGameEvent()

end

function LinkShellNewsItemView:OnRegisterBinder()
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

return LinkShellNewsItemView