---
--- Author: Administrator
--- DateTime: 2024-02-22 15:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class WardrobeBindSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field ImgSwitch UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeBindSlotItemView = LuaClass(UIView, true)

function WardrobeBindSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.ImgSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeBindSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeBindSlotItemView:OnInit()
	self.Binders = {
		{ "IsSwitch", UIBinderSetIsVisible.New(self, self.ImgSwitch)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.BagSlot.ImgSelect)},
	}

end

function WardrobeBindSlotItemView:OnDestroy()

end

function WardrobeBindSlotItemView:OnShow()

end

function WardrobeBindSlotItemView:OnHide()

end

function WardrobeBindSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnClickButtonItem)
end

function WardrobeBindSlotItemView:OnRegisterGameEvent()

end

function WardrobeBindSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.BagSlot:SetParams({Data = ViewModel.BagSlotVM})
end

function WardrobeBindSlotItemView:OnClickButtonItem()
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

function WardrobeBindSlotItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
end



return WardrobeBindSlotItemView