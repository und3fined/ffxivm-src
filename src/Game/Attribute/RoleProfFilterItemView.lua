---
--- Author: enqingchen
--- DateTime: 2021-12-31 16:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class RoleProfFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Select UFImage
---@field RichText_Filter URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RoleProfFilterItemView = LuaClass(UIView, true)

function RoleProfFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Select = nil
	--self.RichText_Filter = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RoleProfFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RoleProfFilterItemView:OnInit()

end

function RoleProfFilterItemView:OnDestroy()

end

function RoleProfFilterItemView:OnShow()

end

function RoleProfFilterItemView:OnHide()

end

function RoleProfFilterItemView:OnRegisterUIEvent()

end

function RoleProfFilterItemView:OnRegisterGameEvent()

end

function RoleProfFilterItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "Text", UIBinderSetText.New(self, self.RichText_Filter) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return RoleProfFilterItemView