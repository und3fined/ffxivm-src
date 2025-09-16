---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText  = require("Binder/UIBinderSetText")

---@class LinkShellMemberGroupItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextDesc URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellMemberGroupItemView = LuaClass(UIView, true)

function LinkShellMemberGroupItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextDesc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellMemberGroupItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellMemberGroupItemView:OnInit()
	self.Binders = {
		{"Desc", UIBinderSetText.New(self, self.RichTextDesc)},
	}
end

function LinkShellMemberGroupItemView:OnDestroy()

end

function LinkShellMemberGroupItemView:OnShow()

end

function LinkShellMemberGroupItemView:OnHide()

end

function LinkShellMemberGroupItemView:OnRegisterUIEvent()

end

function LinkShellMemberGroupItemView:OnRegisterGameEvent()

end

function LinkShellMemberGroupItemView:OnRegisterBinder()
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

return LinkShellMemberGroupItemView