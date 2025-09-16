---
--- Author: Administrator
--- DateTime: 2023-08-04 09:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemTipsFrameVM = require("Game/ItemTips/VM/ItemTipsFrameVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local LocalizationUtil = require("Utils/LocalizationUtil")
local CommonUtil = require("Utils/CommonUtil")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR
local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary

---@class ItemTipsFrameNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BaitItem ItemTipsBaitItemView
---@field BtnBind UFButton
---@field BtnOnly UFButton
---@field BtnToGet UFButton
---@field BuddyItem ItemTipsBuddyItemView
---@field CardItem ItemTipsCardItemView
---@field CollectionItem ItemTipsCollectionItemView
---@field CompanionItem ItemTipsCompanionItemView
---@field EquipmentItem ItemTipsEquipmentItemView
---@field FHorizontalBag UFHorizontalBox
---@field FHorizontalWarehouse UFHorizontalBox
---@field HorizontalTopBtns UFHorizontalBox
---@field IconBag UFImage
---@field IconHigh UFImage
---@field IconHigh2 UFImage
---@field IconWarehouse UFImage
---@field ImgGlamoursDye UFImage
---@field ImgItem UFImage
---@field ImgShowBar UFImage
---@field ImgTick UFImage
---@field MaterialItem ItemTipsMaterialItemView
---@field MealItem ItemTipsMealItemView
---@field MedicineItem ItemTipsMedicineItemView
---@field PanelTime UFCanvasPanel
---@field PanelTimeExpired UFHorizontalBox
---@field PanelTimeValidity UFHorizontalBox
---@field PanelTips UFCanvasPanel
---@field PanelToGet UFCanvasPanel
---@field RichTextQuality URichTextBox
---@field ScrollBox UScrollBox
---@field TextBag UFTextBlock
---@field TextExpired UFTextBlock
---@field TextHigh UFTextBlock
---@field TextHigh2 UFTextBlock
---@field TextName UFTextBlock
---@field TextOwn UFTextBlock
---@field TextSlash1 UFTextBlock
---@field TextSlash2 UFTextBlock
---@field TextTime UFTextBlock
---@field TextToGet UFTextBlock
---@field TextType UFTextBlock
---@field TextWarehouse UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsFrameNewView = LuaClass(UIView, true)

function ItemTipsFrameNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BaitItem = nil
	--self.BtnBind = nil
	--self.BtnOnly = nil
	--self.BtnToGet = nil
	--self.BuddyItem = nil
	--self.CardItem = nil
	--self.CollectionItem = nil
	--self.CompanionItem = nil
	--self.EquipmentItem = nil
	--self.FHorizontalBag = nil
	--self.FHorizontalWarehouse = nil
	--self.HorizontalTopBtns = nil
	--self.IconBag = nil
	--self.IconHigh = nil
	--self.IconHigh2 = nil
	--self.IconWarehouse = nil
	--self.ImgGlamoursDye = nil
	--self.ImgItem = nil
	--self.ImgShowBar = nil
	--self.ImgTick = nil
	--self.MaterialItem = nil
	--self.MealItem = nil
	--self.MedicineItem = nil
	--self.PanelTime = nil
	--self.PanelTimeExpired = nil
	--self.PanelTimeValidity = nil
	--self.PanelTips = nil
	--self.PanelToGet = nil
	--self.RichTextQuality = nil
	--self.ScrollBox = nil
	--self.TextBag = nil
	--self.TextExpired = nil
	--self.TextHigh = nil
	--self.TextHigh2 = nil
	--self.TextName = nil
	--self.TextOwn = nil
	--self.TextSlash1 = nil
	--self.TextSlash2 = nil
	--self.TextTime = nil
	--self.TextToGet = nil
	--self.TextType = nil
	--self.TextWarehouse = nil
	--self.AnimIn = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsFrameNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BaitItem)
	self:AddSubView(self.BuddyItem)
	self:AddSubView(self.CardItem)
	self:AddSubView(self.CollectionItem)
	self:AddSubView(self.CompanionItem)
	self:AddSubView(self.EquipmentItem)
	self:AddSubView(self.MaterialItem)
	self:AddSubView(self.MealItem)
	self:AddSubView(self.MedicineItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsFrameNewView:OnInit()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, "dd:hh", _G.LSTR(1020001), self.TimeOutCallback, self.TimeUpdateCallback)
	self.ViewModel = ItemTipsFrameVM
	self.Binders = {
		{ "ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgShowBar) },
		{ "BtnBindVisible", UIBinderSetIsVisible.New(self, self.BtnBind, false, true) },
		{ "BtnOnlyVisible", UIBinderSetIsVisible.New(self, self.BtnOnly, false, true) },
		{ "TypeName",    	UIBinderSetText.New(self, self.TextType) },
		{ "ItemName",			UIBinderSetText.New(self, self.TextName) },
		{ "LevelText",			UIBinderSetText.New(self, self.RichTextQuality) },
		{ "IconID",			UIBinderSetBrushFromIconID.New(self, self.ImgItem) },
		{ "LearnVisible", UIBinderSetIsVisible.New(self, self.ImgTick) },
		--{ "GlamoursImgVisible", UIBinderSetIsVisible.New(self, self.ImgGlamoursDye) },
		--{ "ProfRestrictionsImgVisible", UIBinderSetIsVisible.New(self, self.ImgForbid) },
		--{ "ProfRestrictionsImgColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgForbid) },

		{ "ToGetVisible", UIBinderSetIsVisible.New(self, self.PanelToGet) },
------------------------------------------------------------------------------------------
		{ "BaitItemVisible", UIBinderSetIsVisible.New(self, self.BaitItem) },
		{ "CardItemVisible", UIBinderSetIsVisible.New(self, self.CardItem) },
		{ "CollectionItemVisible", UIBinderSetIsVisible.New(self, self.CollectionItem) },
		{ "EquipmentItemVisible", UIBinderSetIsVisible.New(self, self.EquipmentItem) },
		{ "MaterialItemVisible", UIBinderSetIsVisible.New(self, self.MaterialItem) },
		{ "MealItemVisible", UIBinderSetIsVisible.New(self, self.MealItem) },
		{ "MedicineItemVisible", UIBinderSetIsVisible.New(self, self.MedicineItem) },
		{ "BuddyItemVisible", UIBinderSetIsVisible.New(self, self.BuddyItem) },
		{ "CompanionItemVisible", UIBinderSetIsVisible.New(self, self.CompanionItem) },

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

		{ "ShowTimeText", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 1, true, true) },
		{ "PanelTimeVisible", UIBinderSetIsVisible.New(self, self.PanelTime) },
		{ "TimeValidityVisible", UIBinderSetIsVisible.New(self, self.PanelTimeValidity) },
		{ "TimeExpiredVisible", UIBinderSetIsVisible.New(self, self.PanelTimeExpired) },
	}
	---自定义的点击获取按钮的回调函数
	self.OnClickedToGetBtnCallback = nil

end

function ItemTipsFrameNewView:OnDestroy()

end

function ItemTipsFrameNewView:SetViewNotPopup()
	self.ViewNotPopup = true
end

function ItemTipsFrameNewView:TimeOutCallback()
	if nil == self.ViewModel then return end

	self.ViewModel:SetItemExpired(true)
end

function ItemTipsFrameNewView:TimeUpdateCallback(LeftTime)
	return LocalizationUtil.GetCountdownTimeForLongTime(LeftTime, "")
end

function ItemTipsFrameNewView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.HideCallback = Params.HideCallback
	self.OnClickedToGetBtnCallback = Params.OnClickedToGetBtnCallback
	local ItemView = Params.ItemView
	if nil ~= ItemView then
		ItemTipsUtil.AdjustTipsPosition(self.PanelTips, ItemView, Params.Offset, Params.CustomBottomMargin)
	else
		if nil ~= Params.Offset then
			ItemTipsUtil.AdjustTipsPositionByPos(self.PanelTips, Params.Offset, Params.CustomBottomMargin)
		end
	end

	local ItemData = Params.ItemData
	if nil ~= ItemData then
		self.ViewModel:UpdateVM(ItemData)
	end
	self.EquipmentItem:UpdateInlayAllSlot()

	self:PlayAnimation(self.AnimUpdate)

	self.IsHideJoyStick = false
	if CommonUtil.IsDisableShowJoyStick() ~= true then
		self.IsHideJoyStick = true
		CommonUtil.DisableShowJoyStick(true)
		CommonUtil.HideJoyStick()
	end
end

function ItemTipsFrameNewView:UpdateUI(Item)
	self.ViewModel:UpdateVM(Item)
	self.EquipmentItem:UpdateInlayAllSlot()
	self:ToOriginState()
	self:PlayAnimation(self.AnimUpdate)
end

function ItemTipsFrameNewView:ToOriginState()
	self.ScrollBox:ScrollToStart()
	
end

function ItemTipsFrameNewView:OnHide()
	UIViewMgr:HideView(UIViewID.ItemTipsStatus)

	local HideCallback = self.HideCallback
	if nil ~= HideCallback then
		HideCallback()
	end

	if self.IsHideJoyStick then
		CommonUtil.DisableShowJoyStick(false)
		CommonUtil.ShowJoyStick()
	end
end

function ItemTipsFrameNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBind, self.OnClickedBindBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnOnly, self.OnClickedOnlyBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnClickedToGetBtn)
end

function ItemTipsFrameNewView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
end

function ItemTipsFrameNewView:OnRegisterBinder()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	--[[local Binders = {
		{ "ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgShowBar) },
		{ "BtnBindVisible", UIBinderSetIsVisible.New(self, self.BtnBind, false, true) },
		{ "BtnOnlyVisible", UIBinderSetIsVisible.New(self, self.BtnOnly, false, true) },
		{ "TypeName",    	UIBinderSetText.New(self, self.TextType) },
		{ "ItemName",			UIBinderSetText.New(self, self.TextName) },
		{ "LevelText",			UIBinderSetText.New(self, self.RichTextQuality) },
		{ "IconID",			UIBinderSetBrushFromIconID.New(self, self.ImgItem) },
		{ "LearnVisible", UIBinderSetIsVisible.New(self, self.ImgTick) },
		{ "GlamoursStatusImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgGlamoursDye) },
		{ "GlamoursImgVisible", UIBinderSetIsVisible.New(self, self.ImgGlamoursDye) },
		{ "GlamoursImgColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgGlamoursDye) },
		{ "ProfRestrictionsImgVisible", UIBinderSetIsVisible.New(self, self.ImgForbid) },
		{ "ProfRestrictionsImgColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgForbid) },

		{ "OwnRichText", UIBinderSetText.New(self, self.RichTextOwn) },

		{ "ToGetVisible", UIBinderSetIsVisible.New(self, self.PanelToGet) },
------------------------------------------------------------------------------------------
		{ "BaitItemVisible", UIBinderSetIsVisible.New(self, self.BaitItem) },
		{ "CardItemVisible", UIBinderSetIsVisible.New(self, self.CardItem) },
		{ "CollectionItemVisible", UIBinderSetIsVisible.New(self, self.CollectionItem) },
		{ "EquipmentItemVisible", UIBinderSetIsVisible.New(self, self.EquipmentItem) },
		{ "MaterialItemVisible", UIBinderSetIsVisible.New(self, self.MaterialItem) },
		{ "MealItemVisible", UIBinderSetIsVisible.New(self, self.MealItem) },
		{ "MedicineItemVisible", UIBinderSetIsVisible.New(self, self.MedicineItem) },
	}]]--

	self:RegisterBinders(ViewModel, self.Binders)
	self.BaitItem:SetParams({Data = self.ViewModel.ItemTipsBaitVM})
	self.EquipmentItem:SetParams({Data = self.ViewModel.ItemTipsEquipmentVM})
	self.CardItem:SetParams({Data = self.ViewModel.ItemTipsCardVM})
	self.CollectionItem:SetParams({Data = self.ViewModel.ItemTipsCollectionVM})
	self.MaterialItem:SetParams({Data = self.ViewModel.ItemTipsMaterialVM})
	self.MealItem:SetParams({Data = self.ViewModel.ItemTipsMealVM})
	self.MedicineItem:SetParams({Data = self.ViewModel.ItemTipsMedicineVM})
	self.BuddyItem:SetParams({Data = self.ViewModel.ItemTipsBuddyVM})
	self.CompanionItem:SetParams({Data = self.ViewModel.ItemTipsCompanionVM})

	self.TextToGet:SetText(LSTR(1000056))
	self.TextExpired:SetText(LSTR(1020032))
	self.TextOwn:SetText(LSTR(1020033))

	self.TextSlash1:SetText("/")
	self.TextSlash2:SetText("/")

end

function ItemTipsFrameNewView:OnClickedBindBtn()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	
	local Params = { ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnBind}
	ItemTipsUtil.OnClickedBindBtn(self.ViewModel, Params)

end

function ItemTipsFrameNewView:OnClickedOnlyBtn()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	
	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnOnly}
	ItemTipsUtil.OnClickedOnlyBtn(self.ViewModel, Params)
	
end

function ItemTipsFrameNewView:OnPreprocessedMouseButtonUp(MouseEvent)
	if _G.NewTutorialMgr:GetTutorialCurID() ~= nil and _G.NewTutorialMgr:GetTutorialCurID() == 69 then
		return
	end

	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end

	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) == false and self.ViewNotPopup ~= true then
		if UIViewMgr:IsViewVisible(UIViewID.CommGetWayTipsView) == false then
			UIViewMgr:HideView(UIViewID.ItemTips)
		end
	end
end

function ItemTipsFrameNewView:OnClickedToGetBtn()
	if self.OnClickedToGetBtnCallback ~= nil then
		self.OnClickedToGetBtnCallback()
		return
	end
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnToGet}
	ItemTipsUtil.OnClickedToGetBtn(Params)

	_G.EventMgr:SendEvent(_G.EventID.WardrobeTipOpenGetWayView)
end


return ItemTipsFrameNewView