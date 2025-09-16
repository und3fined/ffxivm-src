---
--- Author: Administrator
--- DateTime: 2024-07-11 19:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local BagMgr = require("Game/Bag/BagMgr")
local ItemFishingBaitTipsFrameVM = require("Game/ItemTips/VM/ItemFishingBaitTipsFrameVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL 
local LSTR = _G.LSTR
---@class ItemFishingBaitTipsFrameView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BaitItem ItemTipsBaitItemView
---@field BtnToGet UFButton
---@field Comm152Slot CommBackpack152SlotView
---@field FHorizontalBag UFHorizontalBox
---@field FHorizontalWarehouse UFHorizontalBox
---@field IconBag UFImage
---@field IconWarehouse UFImage
---@field ImgItem UFImage
---@field ItemTipsCollection ItemTipsCollectionItemView
---@field PanelTips UFCanvasPanel
---@field PanelToGet UFCanvasPanel
---@field RichTextQuality URichTextBox
---@field ScrollBox UScrollBox
---@field TextBag UFTextBlock
---@field TextName UFTextBlock
---@field TextOwn UFTextBlock
---@field TextToGet UFTextBlock
---@field TextType UFTextBlock
---@field TextWarehouse UFTextBlock
---@field TipsMedicine ItemTipsMedicineItemView
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemFishingBaitTipsFrameView = LuaClass(UIView, true)

function ItemFishingBaitTipsFrameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BaitItem = nil
	--self.BtnToGet = nil
	--self.Comm152Slot = nil
	--self.FHorizontalBag = nil
	--self.FHorizontalWarehouse = nil
	--self.IconBag = nil
	--self.IconWarehouse = nil
	--self.ImgItem = nil
	--self.ItemTipsCollection = nil
	--self.PanelTips = nil
	--self.PanelToGet = nil
	--self.RichTextQuality = nil
	--self.ScrollBox = nil
	--self.TextBag = nil
	--self.TextName = nil
	--self.TextOwn = nil
	--self.TextToGet = nil
	--self.TextType = nil
	--self.TextWarehouse = nil
	--self.TipsMedicine = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemFishingBaitTipsFrameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BaitItem)
	self:AddSubView(self.Comm152Slot)
	self:AddSubView(self.ItemTipsCollection)
	self:AddSubView(self.TipsMedicine)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemFishingBaitTipsFrameView:OnInit()
	self.ViewModel = ItemFishingBaitTipsFrameVM.New()
	self.Binders = {
		{ "TypeName",    	UIBinderSetText.New(self, self.TextType) },
		{ "ItemName",			UIBinderSetText.New(self, self.TextName) },
		{ "LevelText",			UIBinderSetText.New(self, self.RichTextQuality) },
		{ "ToGetVisible", UIBinderSetIsVisible.New(self, self.PanelToGet) },
		{ "DepotNumText", UIBinderSetItemNumFormat.New(self, self.TextWarehouse) },
		{ "BagNumText", UIBinderSetItemNumFormat.New(self, self.TextBag) },
		{ "IconID", UIBinderSetBrushFromIconID.New(self, self.Comm152Slot.Icon)},
	}
	self:UIInit()
end

function ItemFishingBaitTipsFrameView:OnDestroy()

end

function ItemFishingBaitTipsFrameView:OnShow()
	self:PlayAnimation(self.AnimUpdate)
end

function ItemFishingBaitTipsFrameView:OnHide()

end

function ItemFishingBaitTipsFrameView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnClickedToGetBtn)
end

function ItemFishingBaitTipsFrameView:OnRegisterGameEvent()

end

function ItemFishingBaitTipsFrameView:OnRegisterBinder()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
	self.TipsMedicine:SetParams({Data = self.ViewModel.ItemTipsMedicineVM})
	self.ItemTipsCollection:SetParams({Data = self.ViewModel.ItemTipsCollectionVM})
end

function ItemFishingBaitTipsFrameView:UpdateUI(ItemData)
	local BagSlotItem = BagSlotVM.New()
	local BagItem = BagMgr:FindItem(ItemData.GID)
	if BagItem == nil then
		BagItem = {
			ResID = ItemData.ResID,
			GID = 0,
			Num = 0
		}
	end
	BagSlotItem:UpdateVM(BagItem)
	self.ViewModel:UpdateVM(BagSlotItem)
	self:ToOriginState()
	self:PlayAnimation(self.AnimUpdate)
	local Cfg = ItemCfg:FindCfgByKey(ItemData.ResID)
	if Cfg.ItemType == ITEM_TYPE_DETAIL.CONSUMABLES_BAIT then
        UIUtil.SetIsVisible(self.ItemTipsCollection,false)
    else
        UIUtil.SetIsVisible(self.TipsMedicine,false)
    end
end

function ItemFishingBaitTipsFrameView:ToOriginState()
	self.ScrollBox:ScrollToStart()
end

function ItemFishingBaitTipsFrameView:OnClickedToGetBtn()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end

	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnToGet}
	ItemTipsUtil.OnClickedToGetBtn(Params)
end

function ItemFishingBaitTipsFrameView:UIInit()
	UIUtil.SetIsVisible(self.Comm152Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.Comm152Slot.RichTextQuantity, false)
	UIUtil.SetIsVisible(self.Comm152Slot.IconChoose, false)
	self.TextToGet:SetText(LSTR(1000056))
	self.TextOwn:SetText(LSTR(1020033))
end

return ItemFishingBaitTipsFrameView