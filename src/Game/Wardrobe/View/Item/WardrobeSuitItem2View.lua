---
--- Author: Administrator
--- DateTime: 2025-08-05 11:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class WardrobeSuitItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack126Slot CommBackpack126SlotView
---@field CommonRedDot CommonRedDotView
---@field ImgNo UFImage
---@field ImgUnlock UFImage
---@field StainTag WardrobeStainTagItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeSuitItem2View = LuaClass(UIView, true)

function WardrobeSuitItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack126Slot = nil
	--self.CommonRedDot = nil
	--self.ImgNo = nil
	--self.ImgUnlock = nil
	--self.StainTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeSuitItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack126Slot)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.StainTag)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeSuitItem2View:OnInit()
	self.Binders = {
		{"CanEquip", UIBinderSetIsVisible.New(self, self.ImgNo, true)},
		{"IsUnlock", UIBinderSetIsVisible.New(self, self.ImgUnlock, true)},
		{"StainedEnable", UIBinderSetIsVisible.New(self, self.StainTag)},
		{"IsStained", UIBinderSetIsVisible.New(self, self.StainTag.ImgDye)},
		{"HideColor", UIBinderSetIsVisible.New(self, self.StainTag.ImgStainColor, true)},
		{"IsRed", UIBinderSetIsVisible.New(self, self.CommonRedDot)},
	}
end

function WardrobeSuitItem2View:OnDestroy()

end

function WardrobeSuitItem2View:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	if ViewModel ~= nil then
		if ViewModel.RedDotName ~= nil then
			self.CommonRedDot:SetRedDotNameByString(ViewModel.RedDotName)
		end
	end
end

function WardrobeSuitItem2View:OnHide()

end

function WardrobeSuitItem2View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBackpack126Slot.Btn, self.OnClickButtonItem)
end

function WardrobeSuitItem2View:OnRegisterGameEvent()
end

function WardrobeSuitItem2View:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.CommBackpack126Slot:SetParams({Data = ViewModel.ItemVM})
end

function WardrobeSuitItem2View:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.ItemVM.IsSelect = bSelected
end

function WardrobeSuitItem2View:OnClickButtonItem()
	local Params = self.Params
    if nil == Params then
        return
    end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

    Adapter:OnItemClicked(self, Params.Index)
end


return WardrobeSuitItem2View