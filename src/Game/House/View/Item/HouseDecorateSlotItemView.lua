---
--- Author: skysong
--- DateTime: 2025-05-22 09:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class HouseDecorateSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field ImgSlot UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseDecorateSlotItemView = LuaClass(UIView, true)

function HouseDecorateSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.ImgSlot = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseDecorateSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseDecorateSlotItemView:OnInit()
    self.Binders = {
        { "Name", UIBinderSetText.New(self, self.TextName) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
        { "Icon", UIBinderSetBrushFromIconID.New(self, self.ImgSlot) },
        { "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgSlot) },
    }
end

function HouseDecorateSlotItemView:OnDestroy()

end

function HouseDecorateSlotItemView:OnShow()

end

function HouseDecorateSlotItemView:OnHide()

end

function HouseDecorateSlotItemView:OnRegisterUIEvent()

end

function HouseDecorateSlotItemView:OnRegisterGameEvent()

end

function HouseDecorateSlotItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then return end
    local ViewModel = Params.Data
    if nil == ViewModel then return end
    if ViewModel then
        self.ViewModel = ViewModel
        self:RegisterBinders(ViewModel, self.Binders)
    end
end

return HouseDecorateSlotItemView