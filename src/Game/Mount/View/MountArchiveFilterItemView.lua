---
--- Author: jamiyang
--- DateTime: 2023-03-12 16:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
--local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
--local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MountArchiveFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonBg UButton
---@field CommBackpackSlot_UIBP CommBackpackSlotView
---@field ImgCheck UFImage
---@field ImgNormal UFImage
---@field TextDesc UFTextBlock
---@field ToggleBtnItem UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountArchiveFilterItemView = LuaClass(UIView, true)

function MountArchiveFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonBg = nil
	--self.CommBackpackSlot_UIBP = nil
	--self.ImgCheck = nil
	--self.ImgNormal = nil
	--self.TextDesc = nil
	--self.ToggleBtnItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountArchiveFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpackSlot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountArchiveFilterItemView:OnInit()
	--local Binders2 = {
		--{ "IsItemSelect", UIBinderSetIsVisible.New(self, self.ImgCheck) },
	--}
	--self:RegisterBinders(self, Binders2)
	self.Binders = {
		{"ItemMountName", UIBinderSetText.New(self, self.TextDesc)},
		{"IsSelect", UIBinderSetIsVisible.New(self, self.ImgCheck)},
		--{"IsSelect", UIBinderSetIsVisible.New(self, self.ImgNormal), true},
	}
end

function MountArchiveFilterItemView:OnDestroy()

end

function MountArchiveFilterItemView:OnShow()

end

function MountArchiveFilterItemView:OnHide()

end

function MountArchiveFilterItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnItem, self.OnClickButtonItem)
	UIUtil.AddOnClickedEvent(self, self.ButtonBg, self.OnClickButtonItem)
end

function MountArchiveFilterItemView:OnRegisterGameEvent()

end

function MountArchiveFilterItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MountArchiveFilterItemView:OnClickButtonItem()
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

function MountArchiveFilterItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
	self.ToggleBtnItem:SetChecked(IsSelected)
	--使用ItemVM.SelectMode，不要在这里加if else

	-- if ViewModel.AwardID == 0 or ViewModel.IsAlreadyPossessed or ViewModel.Obtained then
	-- 	UIUtil.SetIsVisible(self.FImg_Select, IsSelected)
	-- 	UIUtil.SetIsVisible(self.FImg_Preview, false)
	-- else
	-- 	UIUtil.SetIsVisible(self.FImg_Preview, IsSelected)
	-- 	UIUtil.SetIsVisible(self.FImg_Select, false)
	-- end
	-- if ViewModel.AwardID == nil then
	-- 	UIUtil.SetIsVisible(self.FImg_Select, IsSelected)
	-- else
	-- 	UIUtil.SetIsVisible(self.FImg_Preview, IsSelected)
	-- end
end

return MountArchiveFilterItemView