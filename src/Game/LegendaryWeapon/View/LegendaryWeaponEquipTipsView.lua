---
--- Author: guanjiewu
--- DateTime: 2024-01-11 14:52
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
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")

---@class LegendaryWeaponEquipTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBind UFButton
---@field BtnOnly UFButton
---@field BtnToGet UFButton
---@field DetailAttri1 UScaleBox
---@field DetailAttri2 UScaleBox
---@field DetailAttri3 UScaleBox
---@field DetailAttri4 UScaleBox
---@field FHorizontalBag UFHorizontalBox
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
---@field PanelInlay UFCanvasPanel
---@field PanelInlayDetail UFCanvasPanel
---@field PanelLimitation UFCanvasPanel
---@field PanelOther UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelToGet UFCanvasPanel
---@field RichTextQuality URichTextBox
---@field ScrollBox UScrollBox
---@field Spacer4Bind USpacer
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
---@field TextBag UFTextBlock
---@field TextBuyPrice UFTextBlock
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
---@field TextName UFTextBlock
---@field TextNoInlay UFTextBlock
---@field TextOwn UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---@field TextSlash1 UFTextBlock
---@field TextSlash2 UFTextBlock
---@field TextToGet UFTextBlock
---@field TextType UFTextBlock
---@field TextWarehouse UFTextBlock
---@field ToggleBtnInlayDetail UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponEquipTipsView = LuaClass(UIView, true)

function LegendaryWeaponEquipTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBind = nil
	--self.BtnOnly = nil
	--self.BtnToGet = nil
	--self.DetailAttri1 = nil
	--self.DetailAttri2 = nil
	--self.DetailAttri3 = nil
	--self.DetailAttri4 = nil
	--self.FHorizontalBag = nil
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
	--self.PanelInlay = nil
	--self.PanelInlayDetail = nil
	--self.PanelLimitation = nil
	--self.PanelOther = nil
	--self.PanelTips = nil
	--self.PanelToGet = nil
	--self.RichTextQuality = nil
	--self.ScrollBox = nil
	--self.Spacer4Bind = nil
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
	--self.TextBag = nil
	--self.TextBuyPrice = nil
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
	--self.TextName = nil
	--self.TextNoInlay = nil
	--self.TextOwn = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--self.TextSlash1 = nil
	--self.TextSlash2 = nil
	--self.TextToGet = nil
	--self.TextType = nil
	--self.TextWarehouse = nil
	--self.ToggleBtnInlayDetail = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponEquipTipsView:OnRegisterSubView()
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

function LegendaryWeaponEquipTipsView:OnInit()
	self.ViewModel = ItemTipsFrameVM.New()
	self.MultiBinders = {
		{
			ViewModel = self.ViewModel,
			Binders = {
				-- { "ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgShowBar) },
				{ "BtnBindVisible", UIBinderSetIsVisible.New(self, self.BtnBind, false, true) },
				{ "BtnOnlyVisible", UIBinderSetIsVisible.New(self, self.BtnOnly, false, true) },
				{ "TypeName",    	UIBinderSetText.New(self, self.TextType) },
				{ "ItemName",			UIBinderSetText.New(self, self.TextName) },
				{ "LevelText",			UIBinderSetText.New(self, self.RichTextQuality) },

				{ "DepotNumText", UIBinderSetItemNumFormat.New(self, self.TextWarehouse) },
				{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.TextSlash1) },
				{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.IconHigh) },
				{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.TextHigh) },

				{ "BagNumText", UIBinderSetItemNumFormat.New(self, self.TextBag) },
				{ "BagHQNumText", UIBinderSetItemNumFormat.New(self, self.TextHigh2) },
				{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.TextSlash2) },
				{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.IconHigh2) },
				{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.TextHigh2) },
			}
		},
		{
			ViewModel = self.ViewModel.ItemTipsEquipmentVM,
			Binders = {
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

				{ "CantInlayVisible", UIBinderValueChangedCallback.New(self, nil, self.UncheckedInlayDetail) },

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
		
				{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
				{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },
			}
		}
	}
end

function LegendaryWeaponEquipTipsView:OnDestroy()

end

function LegendaryWeaponEquipTipsView:OnShow()
	self.TextToGet:SetText(LSTR(220001))	--"获取"
	self.TextAttri:SetText(LSTR(220002))	--"属性"
	self.TextInlay:SetText(LSTR(220003))	--"魔晶石"
	self.TextBP:SetText(LSTR(220004))		--"商店贩售价格"
	self.TextSP:SetText(LSTR(220005))		--"收购价格"
	self.TextOwn:SetText(LSTR(220006))		--"持有"
	self.TextNoInlay:SetText(LSTR(1020041))--"无法镶嵌魔晶石"
end

function LegendaryWeaponEquipTipsView:OnHide()

end

function LegendaryWeaponEquipTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBind, self.OnClickedBindBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnOnly, self.OnClickedOnlyBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnClickedToGetBtn)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnInlayDetail, self.OnClickToggleBtnInlayDetail)
end

function LegendaryWeaponEquipTipsView:OnRegisterGameEvent()

end

function LegendaryWeaponEquipTipsView:OnRegisterBinder()
	self.TextSlash1:SetText("")
	self.TextSlash2:SetText("")

	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	self:RegisterMultiBinders(self.MultiBinders)
end

function LegendaryWeaponEquipTipsView:Setup(Equip)
	if Equip == nil then
		return
	end
	-- local ItemDataParams = {
	-- 	GID = -1,
	-- 	ResID = ResID,
	-- }
	self.ViewModel:UpdateVM(Equip)
	self:UpdateInlayAllSlot()
end

function LegendaryWeaponEquipTipsView:OnClickedBindBtn()
	local Params = { ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnBind}
	ItemTipsUtil.OnClickedBindBtn(self.ViewModel, Params)
end

function LegendaryWeaponEquipTipsView:OnClickedOnlyBtn()
	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnOnly}
	ItemTipsUtil.OnClickedOnlyBtn(self.ViewModel, Params)
end

function LegendaryWeaponEquipTipsView:OnClickedToGetBtn()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end

	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnToGet}
	ItemTipsUtil.OnClickedToGetBtn(Params)

--	_G.EventMgr:SendEvent(_G.EventID.LegendaryUpdateEquipTips, {IsActive = true})
end

function LegendaryWeaponEquipTipsView:OnClickToggleBtnInlayDetail()
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

-- 在无法镶嵌魔晶石的情况下不显示魔晶石的详细面板
function LegendaryWeaponEquipTipsView:UncheckedInlayDetail()
	local ViewModel = self.ViewModel.ItemTipsEquipmentVM
	if nil == ViewModel then return end

	if ViewModel.InlayVisible == false then
		ViewModel.InlayVisible = true
		ViewModel.InlayDetailVisible = false
		self.ToggleBtnInlayDetail:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
	end
end

function LegendaryWeaponEquipTipsView:UpdateInlayAllSlot()
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

function LegendaryWeaponEquipTipsView:UpdateInlaySlot(Index, ResID, bNomal, bShow)
	local InlaySlotItem = self["InlaySlotItem"..Index]
	InlaySlotItem.ViewModel:InitMagicsparSlot(ResID, Index, bNomal)
	UIUtil.SetIsVisible(InlaySlotItem, bShow)
end

return LegendaryWeaponEquipTipsView