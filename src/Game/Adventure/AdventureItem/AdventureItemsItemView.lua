---
--- Author: sammrli
--- DateTime: 2023-05-12 21:35
--- Description:冒险系统Item的Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class AdventureItemsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack96Slot CommBackpack96SlotView
---@field ImgJob UFImage
---@field PanelFunction UFCanvasPanel
---@field TextDate UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field ViewModel AdventureItemItemVM
local AdventureItemsItemView = LuaClass(UIView, true)

function AdventureItemsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack96Slot = nil
	--self.ImgJob = nil
	--self.PanelFunction = nil
	--self.TextDate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.ViewModel = nil
end

function AdventureItemsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureItemsItemView:OnInit()
	self.CommBackpack96Slot:SetIconChooseVisible(false)
	self.CommBackpack96Slot:CommSetIsGet(false)
	self.CommBackpack96Slot:SetRewardShow(false)
end

function AdventureItemsItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPointTips, self.OnClickPointBtn)
end

function AdventureItemsItemView:OnRegisterBinder()
	local ViewModel = self.Params.Data

	self.Binders = {
		{"DateText", UIBinderSetText.New(self, self.TextDate)},
		{"PanelJobVisible", UIBinderSetIsVisible.New(self, self.PanelFunction)},
		{"IconJob", UIBinderSetImageBrush.New(self, self.ImgJob)},
		{"NumText", UIBinderSetText.New(self, self.CommBackpack96Slot.RichTextQuantity)},
		{"IconPath", UIBinderSetImageBrush.New(self, self.CommBackpack96Slot.Icon)},
		{"IsMaskVisible", UIBinderSetIsVisible.New(self, self.PanelGot)},
		{"TextLevelVisible", UIBinderSetIsVisible.New(self, self.CommBackpack96Slot.RichTextLevel)},
		{"QualityPath", UIBinderSetImageBrush.New(self, self.CommBackpack96Slot.ImgQuanlity)},
		{"IsShowProgressPoint", UIBinderSetIsVisible.New(self, self.PanelProbarPoint)},
		{"ShowItemReward", UIBinderSetIsVisible.New(self, self.CommBackpack96Slot)},
	}

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function AdventureItemsItemView:OnClickPointBtn()
	if self.ViewModel and self.ViewModel.ResID then
		if self.ViewModel.IsShowProgressPoint then
			local HelpInfoUtil = require("Utils/HelpInfoUtil")
			local View = self
			View.BtnInfor = self.BtnPointTips
			View.HelpInfoID = 11185
			HelpInfoUtil.ShowHelpInfo(View)
		else
			if self.ViewModel.ResID > 0 then
				ItemTipsUtil.ShowTipsByResID(self.ViewModel.ResID, self.CommBackpack96Slot, nil, nil, 30)
			end
		end
	end
end

return AdventureItemsItemView