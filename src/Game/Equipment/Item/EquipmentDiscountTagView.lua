---
--- Author: enqingchen
--- DateTime: 2022-01-13 14:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EquipmentDiscountTagVM = require("Game/Equipment/VM/EquipmentDiscountTagVM")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class EquipmentDiscountTagView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FText_Discount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentDiscountTagView = LuaClass(UIView, true)

function EquipmentDiscountTagView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FText_Discount = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentDiscountTagView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentDiscountTagView:OnInit()
	self.ViewModel = EquipmentDiscountTagVM.New()
end

function EquipmentDiscountTagView:OnDestroy()

end

function EquipmentDiscountTagView:OnShow()

end

function EquipmentDiscountTagView:OnHide()

end

function EquipmentDiscountTagView:OnRegisterUIEvent()

end

function EquipmentDiscountTagView:OnRegisterGameEvent()

end

function EquipmentDiscountTagView:OnRegisterBinder()
	local Binders = {
		{ "DiscountOffValue", UIBinderSetTextFormat.New(self, self.FText_Discount, "-%d%%") },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return EquipmentDiscountTagView