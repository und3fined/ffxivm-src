---
--- Author: Administrator
--- DateTime: 2024-09-11 09:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class GoldSaucerMainPanelChallengeNotesSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---@field ImgJob UFImage
---@field PanelFunction UFCanvasPanel
---@field TextDate UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMainPanelChallengeNotesSlotItemView = LuaClass(UIView, true)

function GoldSaucerMainPanelChallengeNotesSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--self.ImgJob = nil
	--self.PanelFunction = nil
	--self.TextDate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnInit()
	
	
end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnDestroy()

end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnShow()
	UIUtil.SetIsVisible(self.Comm96Slot.IconChoose, false)
end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnHide()

end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnRegisterUIEvent()
	self.Comm96Slot:SetClickButtonCallback(self, self.OnClickedHandle)
end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnRegisterGameEvent()

end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local Binders = {
		{"DateText", UIBinderSetText.New(self, self.TextDate)},
		{"PanelJobVisible", UIBinderSetIsVisible.New(self, self.PanelFunction)},
		{"IconJob", UIBinderSetImageBrush.New(self, self.ImgJob)},
		
		{"NumText", UIBinderSetText.New(self, self.Comm96Slot.RichTextQuantity)},
		{"IconPath", UIBinderSetImageBrush.New(self, self.Comm96Slot.Icon)},
		{"IsMaskVisible", UIBinderSetIsVisible.New(self, self.Comm96Slot.ImgMask)},
		{"IsReceived", UIBinderSetIsVisible.New(self, self.Comm96Slot.IconReceived)},
		{"TextLevelVisible", UIBinderSetIsVisible.New(self, self.Comm96Slot.RichTextLevel)},
		{"QualityPath", UIBinderSetImageBrush.New(self, self.Comm96Slot.ImgQuanlity)},
	}

	self:RegisterBinders(ViewModel, Binders)
end

function GoldSaucerMainPanelChallengeNotesSlotItemView:OnClickedHandle()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local ItemResID = ViewModel.ResID
	if ItemResID and ItemResID > 0 then
		ItemTipsUtil.ShowTipsByResID(ItemResID, self.Comm96Slot, nil, nil, 30)
	end
end

return GoldSaucerMainPanelChallengeNotesSlotItemView