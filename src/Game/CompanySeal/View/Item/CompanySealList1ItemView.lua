---
--- Author: Administrator
--- DateTime: 2024-06-03 19:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfIconSimple = require("Binder/UIBinderSetProfIconSimple")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local FVector2D = _G.UE.FVector2D



---@class CompanySealList1ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---@field CommBackpackSlot_UIBP CommBackpackSlotView
---@field GoldTipsBtn UFButton
---@field Icon UFImage
---@field IconProFession UFImage
---@field IconProfessionBG UFImage
---@field IconTagGold UFImage
---@field IconTagSilver UFImage
---@field ImgFocus UFImage
---@field ImgProfessionMask UFImage
---@field PanelTagGold UFCanvasPanel
---@field PanelTagSilver UFCanvasPanel
---@field RedDot CommonRedDotView
---@field RichTextName URichTextBox
---@field RichTextRequire URichTextBox
---@field RichTextState URichTextBox
---@field SilverTipsBtn UFButton
---@field TextQuantityGold UFTextBlock
---@field TextQuantitySilver UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealList1ItemView = LuaClass(UIView, true)

function CompanySealList1ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--self.CommBackpackSlot_UIBP = nil
	--self.GoldTipsBtn = nil
	--self.Icon = nil
	--self.IconProFession = nil
	--self.IconProfessionBG = nil
	--self.IconTagGold = nil
	--self.IconTagSilver = nil
	--self.ImgFocus = nil
	--self.ImgProfessionMask = nil
	--self.PanelTagGold = nil
	--self.PanelTagSilver = nil
	--self.RedDot = nil
	--self.RichTextName = nil
	--self.RichTextRequire = nil
	--self.RichTextState = nil
	--self.SilverTipsBtn = nil
	--self.TextQuantityGold = nil
	--self.TextQuantitySilver = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealList1ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.CommBackpackSlot_UIBP)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealList1ItemView:OnInit()
	self.Binders = {
		{ "ImgFocusVisible", UIBinderSetIsVisible.New(self, self.ImgFocus) },
		{ "JobIcon", UIBinderSetProfIcon.New(self, self.IconProFession) },
		{ "JobIconSimple", UIBinderSetProfIconSimple.New(self, self.IconProfessionBG) },
		{ "Name", UIBinderSetText.New(self, self.RichTextName) },
		{ "TaskState", UIBinderSetText.New(self, self.RichTextState) },
		{ "RequireNum", UIBinderSetText.New(self, self.RichTextRequire) },
		{ "TagSilverVisible", UIBinderSetIsVisible.New(self, self.PanelTagSilver) },
		{ "TagGoldVisible", UIBinderSetIsVisible.New(self, self.PanelTagGold) },
		{ "SilverText", UIBinderSetText.New(self, self.TextQuantitySilver) },
		{ "GoldText", UIBinderSetText.New(self, self.TextQuantityGold) },
		{ "ItemIcon", UIBinderSetImageBrush.New(self, self.Comm96Slot.Icon)},
		{ "ImgFocusVisible", UIBinderSetIsVisible.New(self, self.ImgFocus) },
		{ "ItemQualityIcon", UIBinderSetImageBrush.New(self, self.Comm96Slot.ImgQuanlity)},
		{ "TextQuantity", UIBinderSetIsVisible.New(self, self.Comm96Slot.RichTextQuantity)},
		{ "TextLevel", UIBinderSetIsVisible.New(self, self.Comm96Slot.RichTextLevel)},
		{ "IconChoose", UIBinderSetIsVisible.New(self, self.Comm96Slot.IconChoose)},
		{ "StateIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
		{ "StateIconVisible", UIBinderSetIsVisible.New(self, self.Icon)},	
		{ "TaskLv", UIBinderSetText.New(self, self.TextLevel)},	
		{ "ProfessionMask", UIBinderSetIsVisible.New(self, self.ImgProfessionMask)},	
		{ "ItemMask", UIBinderSetIsVisible.New(self, self.Comm96Slot.ImgMask)},	
	}

end

function CompanySealList1ItemView:OnDestroy()

end

function CompanySealList1ItemView:OnShow()

end

function CompanySealList1ItemView:OnHide()

end

function CompanySealList1ItemView:OnRegisterUIEvent()
	self.Comm96Slot:SetClickButtonCallback(self, self.OnTaskItemClicked)
	UIUtil.AddOnClickedEvent(self, self.GoldTipsBtn, self.GoldRewardTips)
	UIUtil.AddOnClickedEvent(self, self.SilverTipsBtn, self.SilverRewardTips)
end

function CompanySealList1ItemView:OnRegisterGameEvent()

end

function CompanySealList1ItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

function CompanySealList1ItemView:OnTaskItemClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	ItemTipsUtil.ShowTipsByResID(ViewModel.NQItemID, self.Comm96Slot, _G.UE4.FVector2D(0, 0))
end

function CompanySealList1ItemView:OnSelectChanged(NewValue)
	UIUtil.SetIsVisible(self.ImgFocus, NewValue)
end

function CompanySealList1ItemView:GoldRewardTips()
	local HelpCfgs = HelpCfg:FindAllHelpIDCfg(56002)
	local TipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
	local Alignment = FVector2D(1.22, -0.3)
	local Offset = FVector2D(1, 0)
	TipsUtil.ShowInfoTitleTips(TipsContent, self.PanelTagGold, Offset, Alignment, false)
end

function CompanySealList1ItemView:SilverRewardTips()
	local HelpCfgs = HelpCfg:FindAllHelpIDCfg(56001)
	local TipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
	local Alignment = FVector2D(1.22, -0.3)
	local Offset = FVector2D(1, 0)
	TipsUtil.ShowInfoTitleTips(TipsContent, self.IconTagSilver, Offset, Alignment, false)
end


return CompanySealList1ItemView