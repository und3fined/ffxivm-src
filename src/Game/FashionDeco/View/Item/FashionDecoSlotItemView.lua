---
--- Author: ccppeng
--- DateTime: 2024-11-05 11:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class FashionDecoSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommBackpack126SlotView
---@field IconCollect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoSlotItemView = LuaClass(UIView, true)

function FashionDecoSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm126Slot = nil
	--self.IconCollect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionDecoSlotItemView:OnInit()

end

function FashionDecoSlotItemView:OnDestroy()

end

function FashionDecoSlotItemView:OnShow()

end

function FashionDecoSlotItemView:OnHide()

end

function FashionDecoSlotItemView:OnRegisterUIEvent()

end

function FashionDecoSlotItemView:OnRegisterGameEvent()

end

function FashionDecoSlotItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel

	self.Binders = {
		{"AppearanceIcon", UIBinderSetBrushFromAssetPath.New(self, self.Comm126Slot.Icon,nil,nil,true)},
		{
			"ItemLevelVisible",
			UIBinderSetIsVisible.New(self, self.Comm126Slot.RichTextLevel)
		},
		{
			"NumVisible",
			UIBinderSetIsVisible.New(self, self.Comm126Slot.RichTextQuantity)
		},
		{
			"Equip",
			UIBinderSetIsVisible.New(self, self.Comm126Slot.IconChoose)
		},
		{
			"RedDot2Visible", UIBinderValueChangedCallback.New(self, nil, self.OnRedDot2VisibleChanged)
		},
		{
			"IconCollectVisible",
			UIBinderSetIsVisible.New(self, self.IconCollect)
		},
		{
			"IsSelect",
			UIBinderSetIsVisible.New(self, self.Comm126Slot.ImgSelect)
		},
		{
            "ShowImgEmpty",
            UIBinderValueChangedCallback.New(self, nil, self.OnImgEmptyVisibleChanged)
        }
	}
	UIUtil.SetIsVisible(self.Comm126Slot.ImgSelect, false)
	self:RegisterBinders(self.ViewModel, self.Binders)

end
function FashionDecoSlotItemView:OnSelectChanged(IsSelected)
    if nil == self.Params then return end

    local ViewModel = self.Params.Data
    if ViewModel and ViewModel.OnSelectedChange then
        ViewModel:OnSelectedChange(IsSelected)
    end
end
function FashionDecoSlotItemView:OnRedDot2VisibleChanged(NewValue,OldValue)
	if NewValue ~= nil then
		UIUtil.SetIsVisible(self.Comm126Slot.RedDot2, NewValue)
		UIUtil.SetIsVisible(self.Comm126Slot.RedDot2.PanelRedDot, NewValue)
	end

end
function FashionDecoSlotItemView:OnImgEmptyVisibleChanged(NewValue,OldValue)
	if NewValue ~= nil then
		UIUtil.SetIsVisible(self.Comm126Slot.ImgQuanlity, not NewValue)
		UIUtil.SetIsVisible(self.Comm126Slot.ImgEmpty, NewValue)
	end

end
return FashionDecoSlotItemView