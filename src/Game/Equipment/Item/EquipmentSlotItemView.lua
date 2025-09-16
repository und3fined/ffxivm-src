---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetItemColor = require("Binder/UIBinderSetItemColor")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local EquipmentSlotItemVM = require("Game/Equipment/VM/EquipmentSlotItemVM")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local EquipmentMgr = _G.EquipmentMgr
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")

local EndureState = EquipmentDefine.EndureState

---@class EquipmentSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DiscountTag EquipmentDiscountTagView
---@field EFF_FullColor UFCanvasPanel
---@field FBtn_Item UFButton
---@field FImg_Icon UFImage
---@field FImg_Mask UFImage
---@field FImg_Quality UFImage
---@field FImg_Select UFImage
---@field ImgBottomBg UFImage
---@field ImgDyeState UFImage
---@field ImgImproper UFImage
---@field ImgVisibleState UFImage
---@field ImgWearable UFImage
---@field PanelGlamours UFCanvasPanel
---@field ProgressBar_Lasting UProgressBar
---@field ProgressBar_Lasting2 UProgressBar
---@field RichTextNum URichTextBox
---@field Tag_Suit UFImage
---@field TextActivate UFTextBlock
---@field AnimChange UWidgetAnimation
---@field AnimGet UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimRepair UWidgetAnimation
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentSlotItemView = LuaClass(UIView, true)

local EndureColorMap =
{
	[EndureState.Unavailable] = "4E4E4EFF",
	[EndureState.Normal] = "3B724CFF",
	[EndureState.Full] = "3A6A9EFF",
}

function EquipmentSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DiscountTag = nil
	--self.EFF_FullColor = nil
	--self.FBtn_Item = nil
	--self.FImg_Icon = nil
	--self.FImg_Mask = nil
	--self.FImg_Quality = nil
	--self.FImg_Select = nil
	--self.ImgBottomBg = nil
	--self.ImgDyeState = nil
	--self.ImgImproper = nil
	--self.ImgVisibleState = nil
	--self.ImgWearable = nil
	--self.PanelGlamours = nil
	--self.ProgressBar_Lasting = nil
	--self.ProgressBar_Lasting2 = nil
	--self.RichTextNum = nil
	--self.Tag_Suit = nil
	--self.TextActivate = nil
	--self.AnimChange = nil
	--self.AnimGet = nil
	--self.AnimIn = nil
	--self.AnimRepair = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DiscountTag)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentSlotItemView:OnInit()
	self.ViewModel = EquipmentSlotItemVM.New()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.FImg_Icon) },
		{ "DyeStatePath", UIBinderSetBrushFromAssetPath.New(self, self.ImgDyeState) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.FImg_Select) },
		{ "bMask", UIBinderSetIsVisible.New(self, self.FImg_Mask) },
		{ "bBtnVisibel", UIBinderSetIsVisible.New(self, self.FBtn_Item, false, true) },
		-- { "Color", UIBinderSetItemColor.New(self, self.FImg_Quality) },
		{ "QualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.FImg_Quality) },
		{ "IsInScheme", UIBinderSetIsVisible.New(self, self.Tag_Suit) },
		{ "ProgressValue", UIBinderSetPercent.New(self, self.ProgressBar_Lasting2) },
		{ "bShowProgress", UIBinderSetIsVisible.New(self, self.ProgressBar_Lasting) },
		{ "bShowProgress", UIBinderSetIsVisible.New(self, self.ProgressBar_Lasting2) },
		{ "bShowRepair", UIBinderSetIsVisible.New(self, self.DiscountTag) },
		{ "PlayRepairEffect", UIBinderValueChangedCallback.New(self, nil, self.OnPlayRepairEffectChange) },
		{ "bPlayAnimChange", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimChangeChanged) },
		{ "bInGlamours", UIBinderSetIsVisible.New(self, self.PanelGlamours)},
		{ "bShowArchiveActiveState", UIBinderSetIsVisible.New(self, self.ImgBottomBg)},
		{ "bShowArchiveActiveState", UIBinderSetIsVisible.New(self, self.TextActivate)},
		{ "ActiveStateText", UIBinderSetText.New(self, self.TextActivate)},
		{ "ActiveStateTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextActivate)},
		{ "bShowGlamourNotVisible", UIBinderSetIsVisible.New(self, self.ImgVisibleState)},
		{ "bShowQuality", UIBinderSetIsVisible.New(self, self.FImg_Quality) },
		{ "EmptySlotOpacity", UIBinderSetOpacity.New(self, self.FImg_Icon) },
		{ "EndureState", UIBinderValueChangedCallback.New(self, nil, self.OnEndureStateChanged) },
		{ "bIsWearable", UIBinderSetIsVisible.New(self, self.ImgWearable, true) },
		{ "WearableColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgWearable) },
		{ "bShowImgDyeState", UIBinderSetIsVisible.New(self, self.ImgDyeState)},
		{ "bShowImgImproper", UIBinderSetIsVisible.New(self, self.ImgImproper)},
		{ "DyeColorValue", UIBinderSetColorAndOpacityHex.New(self, self.ImgDyeState)},
		{ "bAllStainUnlock", UIBinderSetIsVisible.New(self, self.EFF_FullColor)},
		{ "CanImprove", UIBinderSetIsVisible.New(self, self.IconEuipImprove) },
		
	}
	UIUtil.AddOnClickedEvent(self, self.FBtn_Item, self.OnSlotItemClick)
end

function EquipmentSlotItemView:OnDestroy()

end

function EquipmentSlotItemView:OnShow()
	if self.ViewModel.bCheckShowRepair == false then return end

	local EquipmentCfg = EquipmentCfg:FindCfgByEquipID(self.ViewModel.ResID)
	if EquipmentCfg == nil then return end
	local RepairProf = EquipmentCfg.RepairProf
    local ProfDetail = EquipmentMgr:GetEnabledProf(RepairProf)

    local RepairProfCurLevel = ProfDetail and ProfDetail.Level or 0
    local RepairProfLevel = EquipmentCfg.RepairProfLevel
    local RepairProfRatio = EquipmentCfg.RepairProfRatio

	self.ViewModel.bShowRepair = ProfDetail ~= nil and RepairProfCurLevel >= RepairProfLevel
	self.DiscountTag.ViewModel.DiscountOffValue = (10000-RepairProfRatio)/100
end

function EquipmentSlotItemView:OnHide()

end

function EquipmentSlotItemView:OnRegisterUIEvent()

end

function EquipmentSlotItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.EquipRepairSucc, self.OnEquipRepairSucc)
end
function EquipmentSlotItemView:OnEquipRepairSucc(Params,Part)
	for _, GID in pairs(Params) do
		if GID == self.ViewModel.GID then
			self.ViewModel.Item = EquipmentMgr:GetItemByGID(GID)
			self.ViewModel:UpdateEndureDeg()
			break
		end
	end
end
function EquipmentSlotItemView:OnRegisterBinder()
	if self.Params ~= nil and self.Params.Data ~= nil and self.Params.Data.__IsSlotItemVM == true then
		self.ViewModel = self.Params.Data
	end
	
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function EquipmentSlotItemView:OnSlotItemClick()
	if (self.ViewModel.OnClick) then
		self.ViewModel.OnClick(self.ViewModel)
	end
end

function EquipmentSlotItemView:OnSelectChanged(bSelect)
	self.ViewModel.bSelect = bSelect
end

function EquipmentSlotItemView:OnPlayRepairEffectChange()
	-- if self.ViewModel.bPlayAnimFix then
		-- self.ViewModel.bPlayAnimFix = false
	-- end
end

function EquipmentSlotItemView:OnPlayAnimChangeChanged(bPlayAnimChange)
	if bPlayAnimChange then
		self:PlayAnimation(self.AnimChange)
		self.ViewModel.bPlayAnimChange = false
	end
end

function EquipmentSlotItemView:OnEndureStateChanged(InEndureState)
	local Color = EndureColorMap[InEndureState]
	UIUtil.ProgressBarSetFillColorAndOpacityHex(self.ProgressBar_Lasting2, Color)
end

return EquipmentSlotItemView