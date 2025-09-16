---
--- Author: xingcaicao
--- DateTime: 2023-05-11 19:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class TeamInviteListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamInviteListItemView = LuaClass(UIView, true)

function TeamInviteListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamInviteListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamInviteListItemView:OnInit()

end

function TeamInviteListItemView:OnDestroy()

end

function TeamInviteListItemView:OnShow()

end

function TeamInviteListItemView:OnHide()

end

function TeamInviteListItemView:OnRegisterUIEvent()

end

function TeamInviteListItemView:OnRegisterGameEvent()

end

function TeamInviteListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data

	local Binders = {
	   { "Name", UIBinderSetText.New(self, self.TextName) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

return TeamInviteListItemView