---
--- Author: xingcaicao
--- DateTime: 2024-07-15 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class LinkShellDetailActivityItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextActivity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellDetailActivityItemView = LuaClass(UIView, true)

function LinkShellDetailActivityItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextActivity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellDetailActivityItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellDetailActivityItemView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetImageBrush.New(self, self.ImgIcon) },
		{ "Name", UIBinderSetText.New(self, self.TextActivity) },
	}
end

function LinkShellDetailActivityItemView:OnDestroy()

end

function LinkShellDetailActivityItemView:OnShow()

end

function LinkShellDetailActivityItemView:OnHide()

end

function LinkShellDetailActivityItemView:OnRegisterUIEvent()

end

function LinkShellDetailActivityItemView:OnRegisterGameEvent()

end

function LinkShellDetailActivityItemView:OnRegisterBinder()
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

return LinkShellDetailActivityItemView