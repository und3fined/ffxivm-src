---
--- Author: Administrator
--- DateTime: 2023-08-19 07:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsFrameVM = require("Game/ItemTips/VM/ItemTipsFrameVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local EquipImproveCfg = require("TableCfg/EquipImproveCfg")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local ProtoCommon = require("Protocol/ProtoCommon")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR
local EventID = _G.EventID

---@class EquipmentDetailView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBind UFButton
---@field BtnEuipImprove1 UFButton
---@field BtnMore UFButton
---@field BtnOnly UFButton
---@field BtnRight CommBtnLView
---@field BtnToGet UFButton
---@field DetailAttri1 UScaleBox
---@field DetailAttri2 UScaleBox
---@field DetailAttri3 UScaleBox
---@field DetailAttri4 UScaleBox
---@field FHorizontalBag UFHorizontalBox
---@field FHorizontalState UFHorizontalBox
---@field FHorizontalWarehouse UFHorizontalBox
---@field HorizontalInlay1 UFHorizontalBox
---@field HorizontalInlay2 UFHorizontalBox
---@field HorizontalInlay3 UFHorizontalBox
---@field HorizontalInlay4 UFHorizontalBox
---@field HorizontalInlay5 UFHorizontalBox
---@field IconBag UFImage
---@field IconHigh UFImage
---@field IconHigh2 UFImage
---@field IconWarehouse UFImage
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field ImgShowBar UFImage
---@field ImgX UFImage
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
---@field PanelBtns UFCanvasPanel
---@field PanelEuipImprove UFCanvasPanel
---@field PanelGlamours UFCanvasPanel
---@field PanelInlay UFCanvasPanel
---@field PanelInlayDetail UFCanvasPanel
---@field PanelMaker UFCanvasPanel
---@field PanelOther UFCanvasPanel
---@field PanelRepair UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PopupBG CommonPopUpBGView
---@field RedDot CommonRedDotView
---@field RichTextQuality URichTextBox
---@field ScrollBox UScrollBox
---@field SizeBoxX USizeBox
---@field TextAttri UFTextBlock
---@field TextAttri1 UFTextBlock
---@field TextAttri2 UFTextBlock
---@field TextAttri3 UFTextBlock
---@field TextAttri4 UFTextBlock
---@field TextAttriValue1 UFTextBlock
---@field TextAttriValue2 UFTextBlock
---@field TextAttriValue3 UFTextBlock
---@field TextAttriValue4 UFTextBlock
---@field TextBag UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextBuyPriceAmount UFTextBlock
---@field TextC UFTextBlock
---@field TextCan UFTextBlock
---@field TextCondition UFTextBlock
---@field TextDiscountConditon UFTextBlock
---@field TextDye UFTextBlock
---@field TextDyeName UFTextBlock
---@field TextEuipImprove UFTextBlock
---@field TextGlamours UFTextBlock
---@field TextHigh UFTextBlock
---@field TextHigh2 UFTextBlock
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
---@field TextName UFTextBlock
---@field TextNoInlay UFTextBlock
---@field TextOwn UFTextBlock
---@field TextRepair UFTextBlock
---@field TextRepairDiscount UFTextBlock
---@field TextSellPrice UFTextBlock
---@field TextSellPriceAmount UFTextBlock
---@field TextShadow UFTextBlock
---@field TextShadowName UFTextBlock
---@field TextSlash1 UFTextBlock
---@field TextSlash2 UFTextBlock
---@field TextToGet UFTextBlock
---@field TextType UFTextBlock
---@field TextWarehouse UFTextBlock
---@field ToggleBtnInlayDetail UToggleButton
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentDetailView = LuaClass(UIView, true)

function EquipmentDetailView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBind = nil
	--self.BtnEuipImprove1 = nil
	--self.BtnMore = nil
	--self.BtnOnly = nil
	--self.BtnRight = nil
	--self.BtnToGet = nil
	--self.DetailAttri1 = nil
	--self.DetailAttri2 = nil
	--self.DetailAttri3 = nil
	--self.DetailAttri4 = nil
	--self.FHorizontalBag = nil
	--self.FHorizontalState = nil
	--self.FHorizontalWarehouse = nil
	--self.HorizontalInlay1 = nil
	--self.HorizontalInlay2 = nil
	--self.HorizontalInlay3 = nil
	--self.HorizontalInlay4 = nil
	--self.HorizontalInlay5 = nil
	--self.IconBag = nil
	--self.IconHigh = nil
	--self.IconHigh2 = nil
	--self.IconWarehouse = nil
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.ImgShowBar = nil
	--self.ImgX = nil
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
	--self.PanelBtns = nil
	--self.PanelEuipImprove = nil
	--self.PanelGlamours = nil
	--self.PanelInlay = nil
	--self.PanelInlayDetail = nil
	--self.PanelMaker = nil
	--self.PanelOther = nil
	--self.PanelRepair = nil
	--self.PanelTips = nil
	--self.PopupBG = nil
	--self.RedDot = nil
	--self.RichTextQuality = nil
	--self.ScrollBox = nil
	--self.SizeBoxX = nil
	--self.TextAttri = nil
	--self.TextAttri1 = nil
	--self.TextAttri2 = nil
	--self.TextAttri3 = nil
	--self.TextAttri4 = nil
	--self.TextAttriValue1 = nil
	--self.TextAttriValue2 = nil
	--self.TextAttriValue3 = nil
	--self.TextAttriValue4 = nil
	--self.TextBag = nil
	--self.TextBuyPrice = nil
	--self.TextBuyPriceAmount = nil
	--self.TextC = nil
	--self.TextCan = nil
	--self.TextCondition = nil
	--self.TextDiscountConditon = nil
	--self.TextDye = nil
	--self.TextDyeName = nil
	--self.TextEuipImprove = nil
	--self.TextGlamours = nil
	--self.TextHigh = nil
	--self.TextHigh2 = nil
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
	--self.TextName = nil
	--self.TextNoInlay = nil
	--self.TextOwn = nil
	--self.TextRepair = nil
	--self.TextRepairDiscount = nil
	--self.TextSellPrice = nil
	--self.TextSellPriceAmount = nil
	--self.TextShadow = nil
	--self.TextShadowName = nil
	--self.TextSlash1 = nil
	--self.TextSlash2 = nil
	--self.TextToGet = nil
	--self.TextType = nil
	--self.TextWarehouse = nil
	--self.ToggleBtnInlayDetail = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentDetailView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRight)
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
	self:AddSubView(self.PopupBG)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentDetailView:OnInit()
	self.ViewModel = ItemTipsFrameVM.New()
	self.ViewModel.ShowDisCurEquipmentLevel = true
	self.ViewModel.ShowEquipmentColorType = true
	self.Part = -1
end

function EquipmentDetailView:OnDestroy()

end

function EquipmentDetailView:InitText()
	self.TextRepair:SetText(LSTR(1050208))
	self.TextC:SetText(LSTR(1050209))
	self.TextRepairDiscount:SetText(LSTR(1050210))
	self.TextEuipImprove:SetText(LSTR(1050123))
	self.TextGlamours:SetText(LSTR(1050211))
	self.TextShadow:SetText(LSTR(1050212))
	self.TextDye:SetText(LSTR(1050213))
	self.TextBuyPrice:SetText(LSTR(1050214))
	self.TextSellPrice:SetText(LSTR(1050215))
	self.TextMakerName:SetText(LSTR(1050216))
	self.TextOwn:SetText(LSTR(1050217))
	self.TextAttri:SetText(LSTR(1050054))
	self.TextToGet:SetText(LSTR(1050218))
	self.TextInlay:SetText(LSTR(1020040))
	self.TextNoInlay:SetText(LSTR(1020041))
	self.TextSlash1:SetText("/")
	self.TextSlash2:SetText("/")
	self.TextCan:SetText(LSTR(1020046))
end

function EquipmentDetailView:OnShow()
	if nil ~= self.Params and nil ~= self.Params.ContainerView then
		UIUtil.SetIsVisible(self.PopupBG, true)
		ItemTipsUtil.AdjustTipsPosition(self.PanelTips, self.Params.ContainerView, self.Params.ViewOffset)
	else
		UIUtil.SetIsVisible(self.PopupBG, false)
	end

	if nil ~= self.Params and self.Params.bHideButtons == true then
		UIUtil.SetIsVisible(self.PanelBtns, false)
	else
		UIUtil.SetIsVisible(self.PanelBtns, true)
	end
	self.ViewModel.ItemTipsEquipmentVM.bShowPanelMore = false
	if nil ~= self.Params then
		self.bPersonUI = self.Params.bPersonUI
	end
	--锁定X
	UIUtil.SetIsVisible(self.ImgX, false)
	self.RedDot:SetIsCustomizeRedDot(true)
	self:InitText()
end

function EquipmentDetailView:OnHide()
	self.bPersonUI = false
	_G.EventMgr:SendEvent(_G.EventID.EquipDetailViewClose)
end

function EquipmentDetailView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBind, self.OnClickedBindBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnOnly, self.OnClickedOnlyBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnClickedToGetBtn)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnInlayDetail, self.OnClickToggleBtnInlayDetail)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnClickedRightBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickedMoreBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnEuipImprove1, self.OnClickedImproveBtn)
end

function EquipmentDetailView:UpdateEquipment(Value, Part)
	self.ViewModel.ItemTipsEquipmentVM.Part = Part
	self.ViewModel:UpdateVM(Value)
	self.ViewModel.ItemTipsEquipmentVM.bShowPanelMore = false
	--改良只用第一次显示，改良完之后装备直接消失就没了s
	local bShow = _G.EquipmentMgr:GetImproveMaterialEnough(self.ViewModel.ResID)
	self.RedDot:SetRedDotUIIsShow(bShow)
	local NeedUpdate = EquipmentMgr:CheckCanMosic(self.ViewModel.ResID)
	if NeedUpdate then
		self:UpdateInlayAllSlot()
	end
	--update重新处理一次魔晶石按钮
	self.ToggleBtnInlayDetail:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
end

function EquipmentDetailView:Refresh(NotPlayAnimation)
	self:UpdateEquipment(self.ViewModel.Item, self.ViewModel.ItemTipsEquipmentVM.Part)
	if not NotPlayAnimation then
		self:PlayAnimation(self.AnimUpdate)
	end
end

function EquipmentDetailView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.EquipRepairSucc, self.OnEquipRepairSucc)
	self:RegisterGameEvent(EventID.MagicsparInlaySucc, self.OnInlaySucc)
	self:RegisterGameEvent(EventID.MagicsparUnInlaySucc, self.OnUnInlaySucc)
	self:RegisterGameEvent(EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
end

function EquipmentDetailView:OnRegisterBinder()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end

	local Binders = {
		{ "ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgShowBar) },
		{ "BtnBindVisible", UIBinderSetIsVisible.New(self, self.BtnBind, false, true) },
		{ "BtnOnlyVisible", UIBinderSetIsVisible.New(self, self.BtnOnly, false, true) },
		{ "TypeName",    	UIBinderSetText.New(self, self.TextType) },
		{ "ItemName",			UIBinderSetText.New(self, self.TextName) },
		{ "LevelText",			UIBinderSetText.New(self, self.RichTextQuality) },
		{ "OwnRichText", UIBinderSetText.New(self, self.RichTextOwn) },

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

	self:RegisterBinders(ViewModel, Binders)

	local EquipBinders = {
		{ "ProfDetailColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLimit) },
		{ "ProfDetailColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLevel) },
		{ "ProfText", UIBinderSetText.New(self, self.TextLimit) },
		{ "ImgXColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgX) },
		
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

		{ "ImgXVisible", UIBinderSetIsVisible.New(self, self.ImgX) },
		{ "LongAttriVisible1", UIBinderSetIsVisible.New(self, self.TextMainAttri1) },
		{ "LongAttriVisible1", UIBinderSetIsVisible.New(self, self.TextMainAttriValue1) },
		{ "LongAttriVisible2", UIBinderSetIsVisible.New(self, self.TextMainAttri2) },
		{ "LongAttriVisible2", UIBinderSetIsVisible.New(self, self.TextMainAttriValue2) },
		{ "ShortAttriVisible1", UIBinderSetIsVisible.New(self, self.DetailAttri1) },
		{ "ShortAttriVisible2", UIBinderSetIsVisible.New(self, self.DetailAttri2) },
		{ "ShortAttriVisible3", UIBinderSetIsVisible.New(self, self.DetailAttri3) },
		{ "ShortAttriVisible4", UIBinderSetIsVisible.New(self, self.DetailAttri4) },

		----魔晶石

		{ "InlayMainPanelVisible", UIBinderSetIsVisible.New(self, self.PanelInlay) },
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

		{ "EndureDegValue", UIBinderSetText.New(self, self.TextCondition) },
		{ "EndureDiscountCondition", UIBinderSetText.New(self, self.TextDiscountConditon) },
		
		{ "EndureDegColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCondition) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPriceAmount) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPriceAmount) },
		{ "MakerNameText", UIBinderSetText.New(self, self.TextMakerName) },
		{ "MakerNameVisible", UIBinderSetIsVisible.New(self, self.PanelMaker) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
		
		----底部按钮
		{ "RightBtnText", UIBinderSetText.New(self, self.BtnRight.TextContent) },
		{ "bRightBtnEnabled", UIBinderValueChangedCallback.New(self, nil, self.OnRightBtnEnabledChanged) },
		{ "IsCanImproved", UIBinderSetIsVisible.New(self, self.BtnEuipImprove1, false, true)},
		{ "IsCanImproved", UIBinderSetIsVisible.New(self, self.PanelEuipImprove) }
	}
	self:RegisterBinders(ViewModel.ItemTipsEquipmentVM, EquipBinders)
end

function EquipmentDetailView:OnClickToggleBtnInlayDetail()
	local ViewModel = self.ViewModel.ItemTipsEquipmentVM
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

function EquipmentDetailView:UpdateInlayAllSlot()
	local ViewModel = self.ViewModel.ItemTipsEquipmentVM
	if nil == ViewModel then return end

	local Item = ViewModel.Item
	local MagicsparCfg = ViewModel.MagicsparCfg
	if Item == nil or MagicsparCfg == nil then
		return
	end

	if Item.Attr == nil or Item.Attr.Equip == nil or Item.Attr.Equip.GemInfo == nil then
		return
	end

	local lst = Item.Attr.Equip.GemInfo.CarryList

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

function EquipmentDetailView:UpdateInlaySlot(Index, ResID, bNomal, bShow)
	local InlaySlotItem = self["InlaySlotItem"..Index]
	InlaySlotItem.ViewModel:InitMagicsparSlot(ResID, Index, bNomal)
	UIUtil.SetIsVisible(InlaySlotItem, bShow)
end

function EquipmentDetailView:ToOriginState()
	self.ScrollBox:ScrollToStart()
	UIViewMgr:HideView(UIViewID.ItemTipsStatus)
	UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
end

function EquipmentDetailView:OnClickedBindBtn()
	local Params = { ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnBind}
	ItemTipsUtil.OnClickedBindBtn(self.ViewModel, Params)
end

function EquipmentDetailView:OnClickedImproveBtn()
	local Params = { ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnBind}
	ItemTipsUtil.OnClickedImproveBtn(self.ViewModel, Params)
end

function EquipmentDetailView:OnClickedOnlyBtn()
	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnOnly}
	ItemTipsUtil.OnClickedOnlyBtn(self.ViewModel, Params)
end

function EquipmentDetailView:OnClickedToGetBtn()
	local ParentViewID = self.bPersonUI and UIViewID.EquipTips or nil
	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnToGet, HidePopUpBG = true, ParentViewID = ParentViewID}
	ItemTipsUtil.OnClickedToGetBtn(Params)
end

function EquipmentDetailView:OnClickedRightBtn()
	if nil == self.ViewModel.Item then
		return
	end
	local EquipDetailVM = self.ViewModel.ItemTipsEquipmentVM
	local bCanEquip = EquipmentMgr:CanEquiped(self.ViewModel.ResID)
	local GID = self.ViewModel.Item.GID
	if bCanEquip == false then
		MsgTipsUtil.ShowTips(LSTR(1050064))
		return
	end

	local EquipedItem = EquipmentMgr:GetEquipedItemByGID(GID)
	local bEquiped = nil ~= EquipedItem
	local EquipReqInfo = {{Part = EquipDetailVM.Part, GID = GID}}

	if bEquiped then
		--卸载
		if not EquipDetailVM.bRightBtnEnabled then
			MsgTipsUtil.ShowTips(LSTR(1050015))
			return
		end
		EquipmentMgr:SendEquipOff(EquipReqInfo)
	else
		EquipmentMgr:SendEquipOnChecked(EquipReqInfo, EquipedItem, self.ViewModel.Item)
	end
end

function EquipmentDetailView:OnClickedMoreBtn()
	local EquipmentMainVM = require("Game/Equipment/VM/EquipmentMainVM")
	self:InitStorageBtnTips()
	local ViewModel = self.ViewModel.ItemTipsEquipmentVM
	local bIsShow = ViewModel.bShowPanelMore
	ViewModel.bShowPanelMore = not bIsShow
	-- if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
	-- 	UIViewMgr:HideView(UIViewID.CommStorageTipsView)
	-- 	return
	-- end

	-- local BtnList =  {
	-- 	{Content = LSTR(1050146), ClickItemCallback = self.OnClickedMagicsparBtn, View = self},
	-- 	{Content = LSTR(1050018), ClickItemCallback = self.OnClickedRepairBtn, View = self}
	-- }

	-- local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnMore)
	-- TipsUtil.ShowStorageBtnsTips(BtnList, self.BtnMore, _G.UE.FVector2D(-BtnSize.X /2 -10, -20), _G.UE.FVector2D(0.5, 1), true)
end

function EquipmentDetailView:OnClickedRepairBtn()
	if nil == self.ViewModel.Item then
		return
	end
	EquipmentMgr:OpenEquipmentRepair(self.ViewModel.Item.GID)
	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
	end
end

function EquipmentDetailView:OnClickedImprove()
	if not _G.EquipmentMgr:CheckCanOperate(LSTR(1050176)) then
		return
	end
	_G.UIViewMgr:ShowView(UIViewID.EuipmentImproveWinView, {EquipID = self.ViewModel.ResID, GID = self.ViewModel.Item.GID, OpenType = 1})
	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
	end
end

function EquipmentDetailView:OnClickedMagicsparBtn()
	if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGemInfo) then
		_G.MsgTipsUtil.ShowTips(LSTR(1050222))
		return
	end
	if nil == self.ViewModel.Item then
		return
	end
	local ViewModel = self.ViewModel.ItemTipsEquipmentVM
	ViewModel.bShowPanelMore = false
	local Param = {GID = self.ViewModel.Item.GID, ResID = self.ViewModel.ResID}
	EquipmentMgr:TryInlayMagicspar(Param)
	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
	end
end

function EquipmentDetailView:InitStorageBtnTips()  
	local CanImprove =  EquipmentMgr:CheckCanImprove(self.ViewModel.ResID)
	local BtnList = {}
	local bShow = _G.EquipmentMgr:GetImproveMaterialEnough(self.ViewModel.ResID)
	local MagicsparData = {Content = LSTR(1050146), ClickItemCallback = self.OnClickedMagicsparBtn, View = self, 
	NeedSetEnable = true, bIsEnabled = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGemInfo) and EquipmentMgr:CheckCanMosic(self.ViewModel.ResID)}
	local RepairData = {Content = LSTR(1050018), ClickItemCallback = self.OnClickedRepairBtn, View = self}
	local ImproveData = {Content = LSTR(1050084), ClickItemCallback = self.OnClickedImprove, View = self, bShowRedPoint = bShow}
	table.insert(BtnList, MagicsparData)
	if CanImprove then
		table.insert(BtnList, ImproveData)
	end
	table.insert(BtnList, RepairData)
	local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnMore)
	TipsUtil.ShowStorageBtnsTips(BtnList, self.BtnMore, _G.UE.FVector2D(-BtnSize.X, 0), _G.UE.FVector2D(0, 1), false)
end

---------- VM事件 ----------

function EquipmentDetailView:OnRightBtnEnabledChanged(bIsEnabled)
	self.BtnRight:SetIsEnabled(bIsEnabled, true)
end

---------- 游戏事件 ----------

function EquipmentDetailView:OnEquipRepairSucc(Params)
	if nil == self.ViewModel.Item then
		return
	end
	
	for _, GID in pairs(Params) do
		if GID == self.ViewModel.Item.GID then
			self:Refresh()
			break
		end
	end
end

function EquipmentDetailView:OnInlaySucc(Params)
	if nil == self.ViewModel.Item then
		return
	end
	if Params.GID == self.ViewModel.Item.GID then
		self:Refresh()
	end
end

function EquipmentDetailView:OnUnInlaySucc(Params)
	if nil == self.ViewModel.Item then
		return
	end
	if Params.GID == self.ViewModel.Item.GID then
		self:Refresh()
	end
end

function EquipmentDetailView:OnLootItemUpdateRes(InLootList, InReason)
	if not InLootList or not next(InLootList) then
        return
    end
	local Cfg = EquipImproveCfg:FindCfgByKey(self.ViewModel.ResID)
	local MaterialID = Cfg and Cfg.MaterialID or 0
	for key, value in pairs(InLootList) do
		-- body
		if value.Item and value.Item.ResID == MaterialID then
			local bShow = _G.EquipmentMgr:GetImproveMaterialEnough(self.ViewModel.ResID)
			self.RedDot:SetRedDotUIIsShow(bShow)
			self:InitStorageBtnTips()
		end
	end
end

return EquipmentDetailView