---
--- Author: Administrator
--- DateTime: 2024-01-09 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ItemUtil = require("Utils/ItemUtil")

---@class BattlePassRewardSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgAvailable UFImage
---@field ImgGot UFImage
---@field ImgIcon UFImage
---@field ImgLock UFImage
---@field ImgMask UFImage
---@field ImgQuality UFImage
---@field RichTextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassRewardSlotItemView = LuaClass(UIView, true)

function BattlePassRewardSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgAvailable = nil
	--self.ImgGot = nil
	--self.ImgIcon = nil
	--self.ImgLock = nil
	--self.ImgMask = nil
	--self.ImgQuality = nil
	--self.RichTextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassRewardSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassRewardSlotItemView:OnInit()
end

function BattlePassRewardSlotItemView:OnDestroy()
end

function BattlePassRewardSlotItemView:OnShow()
end

function BattlePassRewardSlotItemView:OnHide()
end

function BattlePassRewardSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickedItem)
end

function BattlePassRewardSlotItemView:OnRegisterGameEvent()
end

function BattlePassRewardSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.Binders = {
		{ "Num", UIBinderSetText.New(self, self.RichTextNum)},
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "ItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IsAvailable", UIBinderSetIsVisible.New(self, self.ImgLock)},
		{ "GotVisible", UIBinderSetIsVisible.New(self, self.ImgGot)},
		{ "ImgMaskVisible", UIBinderSetIsVisible.New(self, self.ImgMask)},
		{ "ImgAvailableVisible", UIBinderSetIsVisible.New(self, self.ImgAvailable)},
	}

	self:RegisterBinders(ViewModel, self.Binders)
end

function BattlePassRewardSlotItemView:OnClickedItem()
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

function BattlePassRewardSlotItemView:UpdateView(Value)
	if Value == nil then
	   return
	end

	self.RichTextNum:SetText(Value.Num)

	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Value.Icon)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgQuality,Value.ItemQualityIcon)
	UIUtil.SetIsVisible(self.ImgLock, Value.Locked)
	UIUtil.SetIsVisible(self.ImgGot, Value.Got)
	UIUtil.SetIsVisible(self.ImgMask, Value.Mask)
	UIUtil.SetIsVisible(self.ImgAvailable, Value.Available)
end


return BattlePassRewardSlotItemView