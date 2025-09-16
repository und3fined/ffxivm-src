---
--- Author: Administrator
--- DateTime: 2023-12-01 16:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class ArmyDepotSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot UFButton
---@field ImgIcon UFImage
---@field ImgMask UFImage
---@field ImgNews UFImage
---@field ImgPick1 UFImage
---@field ImgPick2 UFImage
---@field ImgQuality UFImage
---@field ImgSelect UFImage
---@field ImgSuit UFImage
---@field ImgWearable UFImage
---@field PanelBag UFCanvasPanel
---@field PanelEquipment UFCanvasPanel
---@field PanelMultiChoice UFCanvasPanel
---@field RichTextNum URichTextBox
---@field TextMedicineCD UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyDepotSlotView = LuaClass(UIView, true)

function ArmyDepotSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.ImgIcon = nil
	--self.ImgMask = nil
	--self.ImgNews = nil
	--self.ImgPick1 = nil
	--self.ImgPick2 = nil
	--self.ImgQuality = nil
	--self.ImgSelect = nil
	--self.ImgSuit = nil
	--self.ImgWearable = nil
	--self.PanelBag = nil
	--self.PanelEquipment = nil
	--self.PanelMultiChoice = nil
	--self.RichTextNum = nil
	--self.TextMedicineCD = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyDepotSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyDepotSlotView:OnInit()
	self.Binders = {
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IsNew", UIBinderSetIsVisible.New(self, self.ImgNews) },
		{ "Num", UIBinderSetItemNumFormat.New(self, self.RichTextNum) },
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.RichTextNum) },
		{ "ItemCD", UIBinderSetTextFormat.New(self, self.TextMedicineCD, "%d") },
		{ "IsCD", UIBinderSetIsVisible.New(self, self.TextMedicineCD) },
		{ "IsMask", UIBinderSetIsVisible.New(self, self.ImgMask) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsInScheme", UIBinderSetIsVisible.New(self, self.ImgSuit) },

		{"PanelBagVisible", UIBinderSetIsVisible.New(self, self.PanelBag)},

		{ "LeftCornerFlagImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgWearable) },
		{ "LeftCornerFlagImgVisible", UIBinderSetIsVisible.New(self, self.ImgWearable) },
		{ "LeftCornerFlagImgColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgWearable) },


		--回收选中
		{ "PanelMultiChoiceVisible", UIBinderSetIsVisible.New(self, self.PanelMultiChoice) },
	}
end

function ArmyDepotSlotView:OnDestroy()

end

function ArmyDepotSlotView:OnShow()
	local Params = self.Params
	if nil == Params then
		return 
	end
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	if ViewModel.CurloadNum and Params.Index and Params.Index + 10 >= ViewModel.CurloadNum then
		local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
		local ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
		if ArmyDepotPanelVM then
			ArmyDepotPanelVM:UpdateTabInfoByShowEnd()
		end
	end
end

function ArmyDepotSlotView:OnHide()

end

function ArmyDepotSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickButtonItem)
	UIUtil.AddOnDoubleClickedEvent(self, self.BtnSlot, self.OnDoubleClickButtonItem)
end

function ArmyDepotSlotView:OnRegisterGameEvent()

end

function ArmyDepotSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function ArmyDepotSlotView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	ViewModel:ClickedItemVM()
end

function ArmyDepotSlotView:OnDoubleClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemDoubleClicked(self, Params.Index)
end

return ArmyDepotSlotView