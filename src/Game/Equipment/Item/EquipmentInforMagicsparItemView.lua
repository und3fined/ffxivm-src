---
--- Author: enqingchen
--- DateTime: 2022-07-26 11:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetItemMicroIcon = require("Binder/UIBinderSetItemMicroIcon")

---@class EquipmentInforMagicsparItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Slot01_1 UFImage
---@field FTextBlock UFTextBlock
---@field FTextBlock_78 UFTextBlock
---@field Text_ToInlay UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentInforMagicsparItemView = LuaClass(UIView, true)

function EquipmentInforMagicsparItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Slot01_1 = nil
	--self.FTextBlock = nil
	--self.FTextBlock_78 = nil
	--self.Text_ToInlay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentInforMagicsparItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentInforMagicsparItemView:OnInit()

end

function EquipmentInforMagicsparItemView:OnDestroy()

end

function EquipmentInforMagicsparItemView:OnShow()

end

function EquipmentInforMagicsparItemView:OnHide()

end

function EquipmentInforMagicsparItemView:OnRegisterUIEvent()

end

function EquipmentInforMagicsparItemView:OnRegisterGameEvent()

end

function EquipmentInforMagicsparItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.FTextBlock_78) },
		{ "Detail", UIBinderSetText.New(self, self.FTextBlock) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.FTextBlock_78) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.FTextBlock) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.Text_ToInlay, true, true) },
		{ "DefaultIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FImg_Slot01_1) },
		{ "ResID", UIBinderSetItemMicroIcon.New(self, self.FImg_Slot01_1) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return EquipmentInforMagicsparItemView