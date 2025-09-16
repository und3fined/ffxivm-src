---
--- Author: Administrator
--- DateTime: 2023-08-04 12:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
---@class ItemTipsEquipmentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DetailAttri1 UScaleBox
---@field DetailAttri2 UScaleBox
---@field DetailAttri3 UScaleBox
---@field DetailAttri4 UScaleBox
---@field HorizontalInlay1 UFHorizontalBox
---@field HorizontalInlay2 UFHorizontalBox
---@field HorizontalInlay3 UFHorizontalBox
---@field HorizontalInlay4 UFHorizontalBox
---@field HorizontalInlay5 UFHorizontalBox
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field InlaySlot UFWrapBox
---@field InlaySlotItem1 MagicsparInlaySlotView
---@field InlaySlotItem10 MagicsparInlaySlotView
---@field InlaySlotItem2 MagicsparInlaySlotView
---@field InlaySlotItem3 MagicsparInlaySlotView
---@field InlaySlotItem4 MagicsparInlaySlotView
---@field InlaySlotItem5 MagicsparInlaySlotView
---@field InlaySlotItem6 MagicsparInlaySlotView
---@field InlaySlotItem7 MagicsparInlaySlotView
---@field InlaySlotItem8 MagicsparInlaySlotView
---@field InlaySlotItem9 MagicsparInlaySlotView
---@field PanelAttri UFCanvasPanel
---@field PanelEuipImprove UFCanvasPanel
---@field PanelGlamours UFCanvasPanel
---@field PanelInlay UFCanvasPanel
---@field PanelInlayDetail UFCanvasPanel
---@field PanelLimitation UFCanvasPanel
---@field PanelMaker UFCanvasPanel
---@field PanelOther UFCanvasPanel
---@field PanelRepair UFCanvasPanel
---@field TextAttri UFTextBlock
---@field TextAttri1 UFTextBlock
---@field TextAttri2 UFTextBlock
---@field TextAttri3 UFTextBlock
---@field TextAttri4 UFTextBlock
---@field TextAttriValue1 UFTextBlock
---@field TextAttriValue2 UFTextBlock
---@field TextAttriValue3 UFTextBlock
---@field TextAttriValue4 UFTextBlock
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextC UFTextBlock
---@field TextCan UFTextBlock
---@field TextCondition UFTextBlock
---@field TextDiscountCondition UFTextBlock
---@field TextDye UFTextBlock
---@field TextDyeName UFTextBlock
---@field TextEuipImprove UFTextBlock
---@field TextGlamours1 UFTextBlock
---@field TextInlay UFTextBlock
---@field TextInlay1 UFTextBlock
---@field TextInlay2 UFTextBlock
---@field TextInlay3 UFTextBlock
---@field TextInlay4 UFTextBlock
---@field TextInlay5 UFTextBlock
---@field TextInlayAttri1 UFTextBlock
---@field TextInlayAttri2 UFTextBlock
---@field TextInlayAttri3 UFTextBlock
---@field TextInlayAttri4 UFTextBlock
---@field TextInlayAttri5 UFTextBlock
---@field TextLevel UFTextBlock
---@field TextLimit UFTextBlock
---@field TextMainAttri1 UFTextBlock
---@field TextMainAttri2 UFTextBlock
---@field TextMainAttriValue1 UFTextBlock
---@field TextMainAttriValue2 UFTextBlock
---@field TextMakerName UFTextBlock
---@field TextNoInlay UFTextBlock
---@field TextRepair UFTextBlock
---@field TextRepairDiscount UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---@field TextShadow UFTextBlock
---@field TextShadowName UFTextBlock
---@field ToggleBtnInlayDetail UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsEquipmentItemView = LuaClass(UIView, true)

function ItemTipsEquipmentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DetailAttri1 = nil
	--self.DetailAttri2 = nil
	--self.DetailAttri3 = nil
	--self.DetailAttri4 = nil
	--self.HorizontalInlay1 = nil
	--self.HorizontalInlay2 = nil
	--self.HorizontalInlay3 = nil
	--self.HorizontalInlay4 = nil
	--self.HorizontalInlay5 = nil
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.InlaySlot = nil
	--self.InlaySlotItem1 = nil
	--self.InlaySlotItem10 = nil
	--self.InlaySlotItem2 = nil
	--self.InlaySlotItem3 = nil
	--self.InlaySlotItem4 = nil
	--self.InlaySlotItem5 = nil
	--self.InlaySlotItem6 = nil
	--self.InlaySlotItem7 = nil
	--self.InlaySlotItem8 = nil
	--self.InlaySlotItem9 = nil
	--self.PanelAttri = nil
	--self.PanelEuipImprove = nil
	--self.PanelGlamours = nil
	--self.PanelInlay = nil
	--self.PanelInlayDetail = nil
	--self.PanelLimitation = nil
	--self.PanelMaker = nil
	--self.PanelOther = nil
	--self.PanelRepair = nil
	--self.TextAttri = nil
	--self.TextAttri1 = nil
	--self.TextAttri2 = nil
	--self.TextAttri3 = nil
	--self.TextAttri4 = nil
	--self.TextAttriValue1 = nil
	--self.TextAttriValue2 = nil
	--self.TextAttriValue3 = nil
	--self.TextAttriValue4 = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextC = nil
	--self.TextCan = nil
	--self.TextCondition = nil
	--self.TextDiscountCondition = nil
	--self.TextDye = nil
	--self.TextDyeName = nil
	--self.TextEuipImprove = nil
	--self.TextGlamours1 = nil
	--self.TextInlay = nil
	--self.TextInlay1 = nil
	--self.TextInlay2 = nil
	--self.TextInlay3 = nil
	--self.TextInlay4 = nil
	--self.TextInlay5 = nil
	--self.TextInlayAttri1 = nil
	--self.TextInlayAttri2 = nil
	--self.TextInlayAttri3 = nil
	--self.TextInlayAttri4 = nil
	--self.TextInlayAttri5 = nil
	--self.TextLevel = nil
	--self.TextLimit = nil
	--self.TextMainAttri1 = nil
	--self.TextMainAttri2 = nil
	--self.TextMainAttriValue1 = nil
	--self.TextMainAttriValue2 = nil
	--self.TextMakerName = nil
	--self.TextNoInlay = nil
	--self.TextRepair = nil
	--self.TextRepairDiscount = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--self.TextShadow = nil
	--self.TextShadowName = nil
	--self.ToggleBtnInlayDetail = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsEquipmentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.InlaySlotItem1)
	self:AddSubView(self.InlaySlotItem10)
	self:AddSubView(self.InlaySlotItem2)
	self:AddSubView(self.InlaySlotItem3)
	self:AddSubView(self.InlaySlotItem4)
	self:AddSubView(self.InlaySlotItem5)
	self:AddSubView(self.InlaySlotItem6)
	self:AddSubView(self.InlaySlotItem7)
	self:AddSubView(self.InlaySlotItem8)
	self:AddSubView(self.InlaySlotItem9)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsEquipmentItemView:OnInit()
	self.Binders = {
		{ "ProfDetailColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLimit) },
		{ "ProfDetailColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLevel) },
		{ "ProfText", UIBinderSetText.New(self, self.TextLimit) },
		{ "GradeText", UIBinderSetText.New(self, self.TextLevel) },

		{ "LongAttriText1", UIBinderSetText.New(self, self.TextMainAttri1) },
		{ "LongAttriValue1", UIBinderSetText.New(self, self.TextMainAttriValue1) },
		{ "LongAttriText2", UIBinderSetText.New(self, self.TextMainAttri2) },
		{ "LongAttriValue2", UIBinderSetText.New(self, self.TextMainAttriValue2) },
		{ "ShortAttriText1", UIBinderSetText.New(self, self.TextAttri1) },
		{ "ShortAttriValue1", UIBinderSetText.New(self, self.TextAttriValue1) },
		{ "ShortAttriText2", UIBinderSetText.New(self, self.TextAttri2) },
		{ "ShortAttriValue2", UIBinderSetText.New(self, self.TextAttriValue2) },
		{ "ShortAttriText3", UIBinderSetText.New(self, self.TextAttri3) },
		{ "ShortAttriValue3", UIBinderSetText.New(self, self.TextAttriValue3) },
		{ "ShortAttriText4", UIBinderSetText.New(self, self.TextAttri4) },
		{ "ShortAttriValue4", UIBinderSetText.New(self, self.TextAttriValue4) },

		{ "LongAttriVisible1", UIBinderSetIsVisible.New(self, self.TextMainAttri1) },
		{ "LongAttriVisible1", UIBinderSetIsVisible.New(self, self.TextMainAttriValue1) },
		{ "LongAttriVisible2", UIBinderSetIsVisible.New(self, self.TextMainAttri2) },
		{ "LongAttriVisible2", UIBinderSetIsVisible.New(self, self.TextMainAttriValue2) },
		{ "ShortAttriVisible1", UIBinderSetIsVisible.New(self, self.DetailAttri1) },
		{ "ShortAttriVisible2", UIBinderSetIsVisible.New(self, self.DetailAttri2) },
		{ "ShortAttriVisible3", UIBinderSetIsVisible.New(self, self.DetailAttri3) },
		{ "ShortAttriVisible4", UIBinderSetIsVisible.New(self, self.DetailAttri4) },

		----魔晶石

		{ "CanInlayVisible", UIBinderSetIsVisible.New(self, self.ToggleBtnInlayDetail, false, true) },
		{ "InlayVisible", UIBinderSetIsVisible.New(self, self.InlaySlot) },
		{ "InlayDetailVisible", UIBinderSetIsVisible.New(self, self.PanelInlayDetail) },
		{ "CantInlayVisible", UIBinderSetIsVisible.New(self, self.TextNoInlay) },

		{ "InlayNameText1", UIBinderSetText.New(self, self.TextInlay1) },
		{ "InlayNameText2", UIBinderSetText.New(self, self.TextInlay2) },
		{ "InlayNameText3", UIBinderSetText.New(self, self.TextInlay3) },
		{ "InlayNameText4", UIBinderSetText.New(self, self.TextInlay4) },
		{ "InlayNameText5", UIBinderSetText.New(self, self.TextInlay5) },

		{ "InlayNameColor1", UIBinderSetColorAndOpacityHex.New(self, self.TextInlay1) },
		{ "InlayNameColor2", UIBinderSetColorAndOpacityHex.New(self, self.TextInlay2) },
		{ "InlayNameColor3", UIBinderSetColorAndOpacityHex.New(self, self.TextInlay3) },
		{ "InlayNameColor4", UIBinderSetColorAndOpacityHex.New(self, self.TextInlay4) },
		{ "InlayNameColor5", UIBinderSetColorAndOpacityHex.New(self, self.TextInlay5) },

		{ "InlayAttriText1", UIBinderSetText.New(self, self.TextInlayAttri1) },
		{ "InlayAttriText2", UIBinderSetText.New(self, self.TextInlayAttri2) },
		{ "InlayAttriText3", UIBinderSetText.New(self, self.TextInlayAttri3) },
		{ "InlayAttriText4", UIBinderSetText.New(self, self.TextInlayAttri4) },
		{ "InlayAttriText5", UIBinderSetText.New(self, self.TextInlayAttri5) },

		{ "ShadowNameText", UIBinderSetText.New(self, self.TextShadowName) },
		{ "DyeNameText", UIBinderSetText.New(self, self.TextDyeName) },
		
		{ "DyeTextVisible", UIBinderSetIsVisible.New(self, self.TextDye) },
		{ "DyeNameTextVisible", UIBinderSetIsVisible.New(self, self.TextDyeName) },

		{ "EndureDegValue", UIBinderSetText.New(self, self.TextCondition) },
		{ "EndureDiscountCondition", UIBinderSetText.New(self, self.TextDiscountCondition) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },

		{ "MakerNameText", UIBinderSetText.New(self, self.TextMakerName) },
		{ "MakerNameVisible", UIBinderSetIsVisible.New(self, self.PanelMaker) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
		{ "IsCanImproved", UIBinderSetIsVisible.New(self, self.PanelEuipImprove) },
		
	}

end

function ItemTipsEquipmentItemView:OnDestroy()

end

function ItemTipsEquipmentItemView:OnShow()
end

function ItemTipsEquipmentItemView:OnHide()

end

function ItemTipsEquipmentItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnInlayDetail, self.OnClickToggleBtnInlayDetail)
end

function ItemTipsEquipmentItemView:OnRegisterGameEvent()

end

function ItemTipsEquipmentItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	
	self:RegisterBinders(ViewModel, self.Binders)
	self.TextBP:SetText(LSTR(1020034))
	self.TextSP:SetText(LSTR(1020035))
	self.TextAttri:SetText(LSTR(1020039))
	self.TextInlay:SetText(LSTR(1020040))
	self.TextNoInlay:SetText(LSTR(1020041))
	self.TextRepair:SetText(LSTR(1020042))
	self.TextC:SetText(LSTR(1020043))
	self.TextRepairDiscount:SetText(LSTR(1020044))
	self.TextEuipImprove:SetText(LSTR(1020045))
	self.TextCan:SetText(LSTR(1020046))
	self.TextGlamours1:SetText(LSTR(1020047))
	self.TextShadow:SetText(LSTR(1020048))
	self.TextDye:SetText(LSTR(1000057))
end

function ItemTipsEquipmentItemView:OnClickToggleBtnInlayDetail()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if ViewModel.InlayVisible == true then
		ViewModel.InlayVisible = false
		ViewModel.InlayDetailVisible = true
		self.ToggleBtnInlayDetail:SetCheckedState(_G.UE.EToggleButtonState.Checked)
	else
		ViewModel.InlayVisible = true
		ViewModel.InlayDetailVisible = false
		self.ToggleBtnInlayDetail:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
	end
end

function ItemTipsEquipmentItemView:UpdateInlayAllSlot()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel.InlayDetailVisible = false
	self.ToggleBtnInlayDetail:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)

	local Item = ViewModel.Item
	local MagicsparCfg = ViewModel.MagicsparCfg
	if MagicsparCfg == nil then
		return
	end

	local lst = {}
    if Item and Item.Attr and Item.Attr.Equip and Item.Attr.Equip.GemInfo then
		lst = Item.Attr.Equip.GemInfo.CarryList or {} 
	end

	local iNomalCount = MagicsparCfg.NomalCount
	local iBanCount = MagicsparCfg.BanCount
	for i = 1, 2 do
		self:UpdateInlaySlot(i, lst[i], true, i <= iNomalCount)
		self:UpdateInlaySlot(i + 5, lst[i], true, i <= iNomalCount)
	end
	for i = 1, 3 do
		self:UpdateInlaySlot(2 + i, lst[2 + i], false, i <= iBanCount)
		self:UpdateInlaySlot(2 + i + 5, lst[2 + i], false, i <= iBanCount)
	end
end

function ItemTipsEquipmentItemView:UpdateInlaySlot(Index, ResID, bNomal, bShow)
	local InlaySlotItem = self["InlaySlotItem"..Index]
	InlaySlotItem.ViewModel:InitMagicsparSlot(ResID, Index, bNomal)
	UIUtil.SetIsVisible(InlaySlotItem, bShow)
end

return ItemTipsEquipmentItemView