---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class EquipmentFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Select UFImage
---@field RichText_Filter URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentFilterItemView = LuaClass(UIView, true)

function EquipmentFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Select = nil
	--self.RichText_Filter = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentFilterItemView:OnInit()

end

function EquipmentFilterItemView:OnDestroy()

end

function EquipmentFilterItemView:OnShow()

end

function EquipmentFilterItemView:OnHide()

end

function EquipmentFilterItemView:OnRegisterUIEvent()

end

function EquipmentFilterItemView:OnRegisterGameEvent()

end

function EquipmentFilterItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "Text", UIBinderSetText.New(self, self.RichText_Filter) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return EquipmentFilterItemView