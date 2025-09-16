---
--- Author: Administrator
--- DateTime: 2025-03-13 15:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class WardrobeSuitItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack96Slot CommBackpack96SlotView
---@field ImgNo UFImage
---@field ImgUnlock UFImage
---@field StainTag WardrobeStainTagItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeSuitItemView = LuaClass(UIView, true)

function WardrobeSuitItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack96Slot = nil
	--self.ImgNo = nil
	--self.ImgUnlock = nil
	--self.StainTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeSuitItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack96Slot)
	self:AddSubView(self.StainTag)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeSuitItemView:OnInit()
	self.Binders = {
		{"CanEquip", UIBinderSetIsVisible.New(self, self.ImgNo, true)},
		{"IsUnlock", UIBinderSetIsVisible.New(self, self.ImgUnlock, true)},
		{"StainedEnable", UIBinderSetIsVisible.New(self, self.StainTag)},
		{"IsStained", UIBinderSetIsVisible.New(self, self.StainTag.ImgDye)},
		{"HideColor", UIBinderSetIsVisible.New(self, self.StainTag.ImgStainColor, true)},
	}
end

function WardrobeSuitItemView:OnDestroy()

end

function WardrobeSuitItemView:OnShow()

end

function WardrobeSuitItemView:OnHide()

end

function WardrobeSuitItemView:OnRegisterUIEvent()

end

function WardrobeSuitItemView:OnRegisterGameEvent()

end

function WardrobeSuitItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.CommBackpack96Slot:SetParams({Data = ViewModel.ItemVM})
end

return WardrobeSuitItemView