---
--- Author: kofhuang
--- DateTime: 2025-03-25 20:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class MultiLanguageTestLogView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg_1 UFImage
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MultiLanguageTestLogView = LuaClass(UIView, true)

function MultiLanguageTestLogView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg_1 = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MultiLanguageTestLogView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MultiLanguageTestLogView:OnInit()

end

function MultiLanguageTestLogView:OnDestroy()

end

function MultiLanguageTestLogView:OnShow()

end

function MultiLanguageTestLogView:OnHide()

end

function MultiLanguageTestLogView:OnRegisterUIEvent()

end

function MultiLanguageTestLogView:OnRegisterGameEvent()

end

function MultiLanguageTestLogView:OnRegisterBinder()
	if nil == self.Params then return end

	self.ViewModel = self.Params.Data

	local Binders = {
		{ "Text", UIBinderSetText.New(self, self.Text) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

return MultiLanguageTestLogView