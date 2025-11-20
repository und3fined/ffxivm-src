---
--- Author: Administrator
--- DateTime: 2025-08-05 11:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class WardrobeSuitWinListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack96Slot CommBackpack96SlotView
---@field ImgFocus UFImage
---@field TextName UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeSuitWinListView = LuaClass(UIView, true)

function WardrobeSuitWinListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack96Slot = nil
	--self.ImgFocus = nil
	--self.TextName = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeSuitWinListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeSuitWinListView:OnInit()
	self.Binders = {
		{"EquipName", UIBinderSetText.New(self, self.TextName)},
		{"EquipNum", UIBinderSetText.New(self, self.TextQuantity)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgFocus)},
	}
end

function WardrobeSuitWinListView:OnDestroy()

end

function WardrobeSuitWinListView:OnShow()

end

function WardrobeSuitWinListView:OnHide()

end

function WardrobeSuitWinListView:OnRegisterUIEvent()

end

function WardrobeSuitWinListView:OnRegisterGameEvent()

end

function WardrobeSuitWinListView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	if ViewModel.ItemVM ~= nil then
	self.CommBackpack96Slot:SetParams({Data = ViewModel.ItemVM})
	end
end

function WardrobeSuitWinListView:OnSelectChanged(bSelected)
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

return WardrobeSuitWinListView