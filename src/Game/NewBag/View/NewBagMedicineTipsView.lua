---
--- Author: Administrator
--- DateTime: 2023-09-12 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsFrameVM = require("Game/ItemTips/VM/ItemTipsFrameVM")
local MedicineSlotVM = require("Game/NewBag/VM/MedicineSlotVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")

local LSTR = _G.LSTR
---@class NewBagMedicineTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnToGet UFButton
---@field FHorizontalBag UFHorizontalBox
---@field FHorizontalWarehouse UFHorizontalBox
---@field IconBag UFImage
---@field IconHigh UFImage
---@field IconHigh2 UFImage
---@field IconWarehouse UFImage
---@field MedicineSlot MedicineSlotView
---@field PaneDruglTips UFCanvasPanel
---@field PanelToGet UFCanvasPanel
---@field RichTextQuality URichTextBox
---@field TextBag UFTextBlock
---@field TextHigh UFTextBlock
---@field TextHigh2 UFTextBlock
---@field TextName UFTextBlock
---@field TextOwn UFTextBlock
---@field TextSlash1 UFTextBlock
---@field TextSlash2 UFTextBlock
---@field TextToGet UFTextBlock
---@field TextType UFTextBlock
---@field TextWarehouse UFTextBlock
---@field TipsMedicine ItemTipsMedicineItemView
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagMedicineTipsView = LuaClass(UIView, true)

function NewBagMedicineTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnToGet = nil
	--self.FHorizontalBag = nil
	--self.FHorizontalWarehouse = nil
	--self.IconBag = nil
	--self.IconHigh = nil
	--self.IconHigh2 = nil
	--self.IconWarehouse = nil
	--self.MedicineSlot = nil
	--self.PaneDruglTips = nil
	--self.PanelToGet = nil
	--self.RichTextQuality = nil
	--self.TextBag = nil
	--self.TextHigh = nil
	--self.TextHigh2 = nil
	--self.TextName = nil
	--self.TextOwn = nil
	--self.TextSlash1 = nil
	--self.TextSlash2 = nil
	--self.TextToGet = nil
	--self.TextType = nil
	--self.TextWarehouse = nil
	--self.TipsMedicine = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagMedicineTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MedicineSlot)
	self:AddSubView(self.TipsMedicine)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagMedicineTipsView:OnInit()
	self.ViewModel = ItemTipsFrameVM.New()
	self.MedicineSlotVM = MedicineSlotVM.New()

	self.Binders = {
		{ "TypeName", UIBinderSetText.New(self, self.TextType) },
		{ "ItemName", UIBinderSetText.New(self, self.TextName) },
		{ "LevelText", UIBinderSetText.New(self, self.RichTextQuality) },
		--{ "OwnRichText", UIBinderSetText.New(self, self.RichTextOwn) },
		{ "ToGetVisible", UIBinderSetIsVisible.New(self, self.PanelToGet) },

		{ "DepotNumText", UIBinderSetItemNumFormat.New(self, self.TextWarehouse) },
		{ "DepotHQNumText", UIBinderSetItemNumFormat.New(self, self.TextHigh) },
		{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.TextSlash1) },
		{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.IconHigh) },
		{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.TextHigh) },

		{ "BagNumText", UIBinderSetItemNumFormat.New(self, self.TextBag) },
		{ "BagHQNumText", UIBinderSetItemNumFormat.New(self, self.TextHigh2) },
		{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.TextSlash2) },
		{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.IconHigh2) },
		{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.TextHigh2) },

	}
end

function NewBagMedicineTipsView:OnDestroy()

end

function NewBagMedicineTipsView:OnShow()

end

function NewBagMedicineTipsView:UpdateByItem(Value)
	self.ViewModel:UpdateVM(Value)
	self.MedicineSlotVM:UpdateVM(Value)
	self:PlayAnimation(self.AnimUpdate)
end

function NewBagMedicineTipsView:OnHide()

end

function NewBagMedicineTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnClickedToGetBtn)
end

function NewBagMedicineTipsView:OnRegisterGameEvent()

end

function NewBagMedicineTipsView:OnRegisterBinder()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.TipsMedicine:SetParams({Data = ViewModel.ItemTipsMedicineVM})
	self.MedicineSlot:SetParams({Data = self.MedicineSlotVM})

	self.TextToGet:SetText(LSTR(990092))
	self.TextOwn:SetText(LSTR(990093))
	self.TextSlash1:SetText("/")
	self.TextSlash2:SetText("/")
end

function NewBagMedicineTipsView:OnClickedToGetBtn()
	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PaneDruglTips, InTagetView = self.BtnToGet}
	ItemTipsUtil.OnClickedToGetBtn(Params)
end

return NewBagMedicineTipsView