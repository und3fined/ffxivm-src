---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class LinkShellNewsSmlItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextNews URichTextBox
---@field RichTextTime URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellNewsSmlItemView = LuaClass(UIView, true)

function LinkShellNewsSmlItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextNews = nil
	--self.RichTextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellNewsSmlItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellNewsSmlItemView:OnInit()
	self.Binders = {
		{ "Desc", 		UIBinderSetText.New(self, self.RichTextNews) },
		{ "TimeDesc", 	UIBinderSetText.New(self, self.RichTextTime) },
	}
end

function LinkShellNewsSmlItemView:OnDestroy()

end

function LinkShellNewsSmlItemView:OnShow()

end

function LinkShellNewsSmlItemView:OnHide()

end

function LinkShellNewsSmlItemView:OnRegisterUIEvent()

end

function LinkShellNewsSmlItemView:OnRegisterGameEvent()

end

function LinkShellNewsSmlItemView:OnRegisterBinder()
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

return LinkShellNewsSmlItemView