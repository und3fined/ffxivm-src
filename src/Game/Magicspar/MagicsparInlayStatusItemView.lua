---
--- Author: enqingchen
--- DateTime: 2022-03-14 17:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetItemMicroIcon = require("Binder/UIBinderSetItemMicroIcon")

---@class MagicsparInlayStatusItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_InlayStatus UFImage
---@field Text_AttriType UFTextBlock
---@field Text_MagicsparName UFTextBlock
---@field Text_ToInlay UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInlayStatusItemView = LuaClass(UIView, true)

function MagicsparInlayStatusItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_InlayStatus = nil
	--self.Text_AttriType = nil
	--self.Text_MagicsparName = nil
	--self.Text_ToInlay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparInlayStatusItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInlayStatusItemView:OnInit()

end

function MagicsparInlayStatusItemView:OnDestroy()

end

function MagicsparInlayStatusItemView:OnShow()

end

function MagicsparInlayStatusItemView:OnHide()

end

function MagicsparInlayStatusItemView:OnRegisterUIEvent()

end

function MagicsparInlayStatusItemView:OnRegisterGameEvent()

end

function MagicsparInlayStatusItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.Text_MagicsparName) },
		{ "Detail", UIBinderSetText.New(self, self.Text_AttriType) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.Text_MagicsparName) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.Text_AttriType) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.Text_ToInlay, true, true) },
		{ "DefaultIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FImg_InlayStatus) },
		{ "ResID", UIBinderSetItemMicroIcon.New(self, self.FImg_InlayStatus) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return MagicsparInlayStatusItemView