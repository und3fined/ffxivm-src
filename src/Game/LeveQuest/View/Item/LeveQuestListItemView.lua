---
--- Author: Administrator
--- DateTime: 2023-12-25 20:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetProfIconSimple = require("Binder/UIBinderSetProfIconSimple")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class LeveQuestListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm74Slot CommBackpack74SlotView
---@field IconCheck UFImage
---@field ImgBgFocus UFImage
---@field ImgIcon UFImage
---@field PanelSubmit UFCanvasPanel
---@field TextItemName UFTextBlock
---@field TextLv UFTextBlock
---@field TextName UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextSubmit UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LeveQuestListItemView = LuaClass(UIView, true)

function LeveQuestListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm74Slot = nil
	--self.IconCheck = nil
	--self.ImgBgFocus = nil
	--self.ImgIcon = nil
	--self.PanelSubmit = nil
	--self.TextItemName = nil
	--self.TextLv = nil
	--self.TextName = nil
	--self.TextQuantity = nil
	--self.TextSubmit = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LeveQuestListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LeveQuestListItemView:OnInit()

	self.Binders = {
		{"ProfTypeIcon", UIBinderSetProfIconSimple.New(self, self.ImgIcon)},
		{"QuestName", UIBinderSetText.New(self, self.TextName)},
		{"Level", UIBinderSetText.New(self, self.TextLv)},
		{"TextItemName", UIBinderSetText.New(self, self.TextItemName)},
		{"QuantityNum", UIBinderSetText.New(self, self.TextQuantity)},
		{"QuantityNumVisible", UIBinderSetIsVisible.New(self, self.TextQuantity)},
		{"IconCheckVisible", UIBinderSetIsVisible.New(self, self.TextSubmit)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgBgFocus)},
		{"SelectedColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLv)},
		{"SelectedColor", UIBinderSetColorAndOpacityHex.New(self, self.TextItemName)},
		{"SelectedColor", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity)},
		{"SelectedColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName)},
		{"SelectedLineColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgIcon)},

		{"ItemLevelVisible", UIBinderSetIsVisible.New(self, self.Comm74Slot.RichTextLevel)},
	}
	

	self.Comm74Slot:SetClickButtonCallback(self, self.OnLeveQuestItemClicked)
end

function LeveQuestListItemView:OnDestroy()
end

function LeveQuestListItemView:OnShow()
end

function LeveQuestListItemView:OnHide()
end

function LeveQuestListItemView:OnRegisterUIEvent()
end

function LeveQuestListItemView:OnRegisterGameEvent()
end

function LeveQuestListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.Comm74Slot:SetParams({Data = ViewModel.PropsItemVM})
end

function LeveQuestListItemView:OnSelectChanged(IsSelected)

	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	
    ViewModel:SetSelected(IsSelected)
end

function LeveQuestListItemView:OnLeveQuestItemClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	ItemTipsUtil.ShowTipsByResID(ViewModel.ItemID, self.Comm74Slot, _G.UE4.FVector2D(0, 0))
end

return LeveQuestListItemView