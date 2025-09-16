--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-02-20 09:19:07
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-02-25 10:44:02
FilePath: \Client\Source\Script\Game\GatheringLog\View\Item\CatheringLog96SlotView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-02-17 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class CatheringLog96SlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack96Slot CommBackpack96SlotView
---@field ImgLock UFImage
---@field ImgTag UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CatheringLog96SlotView = LuaClass(UIView, true)

function CatheringLog96SlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack96Slot = nil
	--self.ImgLock = nil
	--self.ImgTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CatheringLog96SlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CatheringLog96SlotView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.CommBackpack96Slot.Icon) },
		{ "bGot", UIBinderSetIsVisible.New(self, self.CommBackpack96Slot.IconChoose) },
		{ "bLockGray", UIBinderSetIsVisible.New(self, self.ImgLock)},
		{ "bLockGray", UIBinderSetIsVisible.New(self, self.CommBackpack96Slot.ImgMask)},
		{ "ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.CommBackpack96Slot.ImgQuanlity) },
		{ "bLeveQuestMarked", UIBinderSetIsVisible.New(self, self.ImgTag) },
	}
	UIUtil.SetIsVisible(self.CommBackpack96Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.CommBackpack96Slot.RichTextQuantity, false)
end

function CatheringLog96SlotView:OnDestroy()

end

function CatheringLog96SlotView:OnShow()

end

function CatheringLog96SlotView:OnHide()

end

function CatheringLog96SlotView:OnRegisterUIEvent()
	self.CommBackpack96Slot:SetClickButtonCallback(self.CommBackpack96Slot, self.OnSlotClicked)
end

function CatheringLog96SlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.CommBackpack96Slot:SetParams({Data = nil})
end

function CatheringLog96SlotView:OnSlotClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
    
	if not ViewModel.ItemID or ViewModel.ItemID == 0 then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ViewModel.ItemID, self)
end

function CatheringLog96SlotView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.LeveQuestMarkedItem, self.OnLeveQuestMarkedItem)
	self:RegisterGameEvent(_G.EventID.LeveQuestCancelMarkedItem, self.OnLeveQuestCancelMarkedItem)
end

function CatheringLog96SlotView:OnLeveQuestMarkedItem(ItemID)
	local VM = self.Params and self.Params.Data
	if VM and VM.ItemID == ItemID then
		self.ViewModel.bLeveQuestMarked = true
	end
end

function CatheringLog96SlotView:OnLeveQuestCancelMarkedItem(ItemID)
	local VM = self.Params and self.Params.Data
	if VM and VM.ItemID == ItemID then
		self.ViewModel.bLeveQuestMarked = false
	end
end

return CatheringLog96SlotView