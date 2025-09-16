---
--- Author: Administrator
--- DateTime: 2024-01-22 19:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FishNewSlotItem74pxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm74Slot CommBackpack74SlotView
---@field FishSlot UFCanvasPanel
---@field ImgAutoRelease UFImage
---@field ImgUnknown UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNewSlotItem74pxView = LuaClass(UIView, true)

function FishNewSlotItem74pxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm74Slot = nil
	--self.FishSlot = nil
	--self.ImgAutoRelease = nil
	--self.ImgUnknown = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNewSlotItem74pxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNewSlotItem74pxView:OnInit()
	-- 部分绑定在CommBackpack74SlotView子类中，因此不在此进行
	self.Binder = {
		{"IsUnknown",UIBinderSetIsVisible.New(self, self.ImgUnknown, false, true)},
		-- {"IsMask",UIBinderSetIsVisible.New(self, self.Comm74Slot.ImgMask, false, true)},
		-- {"NumVisible",UIBinderSetIsVisible.New(self, self.Comm74Slot.RichTextQuantity, false, true)},
		{"IsShowIcon",UIBinderSetIsVisible.New(self, self.Comm74Slot.Icon, false, true)},
		-- {"IsSelect", UIBinderSetIsVisible.New(self, self.Comm74Slot.ImgSelect, false, true)},
		-- {"Num", UIBinderSetTextFormat.New(self, self.Comm74Slot.RichTextQuantity, "%d")},
		-- {"Icon", UIBinderSetBrushFromAssetPath.New(self, self.Comm74Slot.Icon)},
		{"IsFishLoop", UIBinderSetIsVisible.New(self, self.ImgAutoRelease, false, true)},
	}
end

function FishNewSlotItem74pxView:OnDestroy()

end

function FishNewSlotItem74pxView:OnShow()
	UIUtil.SetIsVisible(self.Comm74Slot.IconChoose,false)
end

function FishNewSlotItem74pxView:OnHide()

end

function FishNewSlotItem74pxView:OnRegisterUIEvent()

end

function FishNewSlotItem74pxView:OnRegisterGameEvent()

end

function FishNewSlotItem74pxView:OnRegisterBinder()
	local Params = self.Params
	local ViewModel = nil

	if nil == Params then
		return
	else
		ViewModel = Params.Data
		if nil == ViewModel then
			return
		end
	end

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel,self.Binder)
end

return FishNewSlotItem74pxView