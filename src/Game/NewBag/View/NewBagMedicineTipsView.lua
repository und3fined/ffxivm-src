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

local LSTR = _G.LSTR
---@class NewBagMedicineTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnToGet UFButton
---@field MedicineSlot MedicineSlotView
---@field PaneDruglTips UFCanvasPanel
---@field PanelToGet UFCanvasPanel
---@field RichTextOwn URichTextBox
---@field RichTextQuality URichTextBox
---@field TextName UFTextBlock
---@field TextOwn UFTextBlock
---@field TextToGet UFTextBlock
---@field TextType UFTextBlock
---@field TipsMedicine ItemTipsMedicineItemView
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagMedicineTipsView = LuaClass(UIView, true)

function NewBagMedicineTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnToGet = nil
	--self.MedicineSlot = nil
	--self.PaneDruglTips = nil
	--self.PanelToGet = nil
	--self.RichTextOwn = nil
	--self.RichTextQuality = nil
	--self.TextName = nil
	--self.TextOwn = nil
	--self.TextToGet = nil
	--self.TextType = nil
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
		{ "OwnRichText", UIBinderSetText.New(self, self.RichTextOwn) },
		{ "ToGetVisible", UIBinderSetIsVisible.New(self, self.PanelToGet) },
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
	
end

function NewBagMedicineTipsView:OnClickedToGetBtn()
	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PaneDruglTips, InTagetView = self.BtnToGet}
	ItemTipsUtil.OnClickedToGetBtn(Params)
end

return NewBagMedicineTipsView