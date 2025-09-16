---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingVM = require("Game/Loading/LoadingVM")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class LoadingTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Text UFTextBlock
---@field TextTask UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingTitleItemView = LuaClass(UIView, true)

function LoadingTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text = nil
	--self.TextTask = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingTitleItemView:OnInit()
	self.Binders = {
		{ "TextLabel", UIBinderSetText.New(self, self.TextTask) },
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "TextBody", UIBinderSetText.New(self, self.Text) },
	}
end

function LoadingTitleItemView:OnDestroy()

end

function LoadingTitleItemView:OnShow()

end

function LoadingTitleItemView:OnHide()

end

function LoadingTitleItemView:OnRegisterUIEvent()

end

function LoadingTitleItemView:OnRegisterGameEvent()

end

function LoadingTitleItemView:OnRegisterBinder()
	self:RegisterBinders(LoadingVM, self.Binders)
end

return LoadingTitleItemView