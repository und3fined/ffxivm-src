---
--- Author: enqingchen
--- DateTime: 2022-03-14 12:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class EquipmentMoreFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Select UFImage
---@field RichText_Filter URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentMoreFilterItemView = LuaClass(UIView, true)

function EquipmentMoreFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Select = nil
	--self.RichText_Filter = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentMoreFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentMoreFilterItemView:OnInit()

end

function EquipmentMoreFilterItemView:OnDestroy()

end

function EquipmentMoreFilterItemView:OnShow()

end

function EquipmentMoreFilterItemView:OnHide()

end

function EquipmentMoreFilterItemView:OnRegisterUIEvent()

end

function EquipmentMoreFilterItemView:OnRegisterGameEvent()

end

function EquipmentMoreFilterItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "Text", UIBinderSetText.New(self, self.RichText_Filter) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.FImg_Select) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentMoreFilterItemView:OnSelectChanged(bSelect)
	self.ViewModel.bSelect = bSelect
end

return EquipmentMoreFilterItemView