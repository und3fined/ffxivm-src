---
--- Author: Administrator
--- DateTime: 2023-09-12 19:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class MedicineSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgQuality UFImage
---@field PanelMedicine UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MedicineSlotView = LuaClass(UIView, true)

function MedicineSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgQuality = nil
	--self.PanelMedicine = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MedicineSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MedicineSlotView:OnInit()

end

function MedicineSlotView:OnDestroy()

end

function MedicineSlotView:OnShow()

end

function MedicineSlotView:OnHide()

end

function MedicineSlotView:OnRegisterUIEvent()

end

function MedicineSlotView:OnRegisterGameEvent()

end

function MedicineSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local Binders = {
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

return MedicineSlotView