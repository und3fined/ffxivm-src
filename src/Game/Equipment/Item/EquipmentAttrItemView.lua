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
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class EquipmentAttrItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img_JobIcon UFImage
---@field Text_Attri UFTextBlock
---@field Text_Value UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentAttrItemView = LuaClass(UIView, true)

function EquipmentAttrItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img_JobIcon = nil
	--self.Text_Attri = nil
	--self.Text_Value = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentAttrItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentAttrItemView:OnInit()

end

function EquipmentAttrItemView:OnDestroy()

end

function EquipmentAttrItemView:OnShow()

end

function EquipmentAttrItemView:OnHide()

end

function EquipmentAttrItemView:OnRegisterUIEvent()

end

function EquipmentAttrItemView:OnRegisterGameEvent()

end

function EquipmentAttrItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "LeftText", UIBinderSetText.New(self, self.Text_Attri) },
		{ "RightText", UIBinderSetText.New(self, self.Text_Value) },
		-- { "RightIcon", UIBinderSetBrushFromAssetPath.New(self, self.Img_JobIcon) },
		-- { "bHasIcon", UIBinderSetIsVisible.New(self, self.Img_JobIcon) },
		{ "RightTextColor", UIBinderSetColorAndOpacityHex.New(self, self.Text_Value) },
		{ "LeftTextColor", UIBinderSetColorAndOpacityHex.New(self, self.Text_Attri) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return EquipmentAttrItemView