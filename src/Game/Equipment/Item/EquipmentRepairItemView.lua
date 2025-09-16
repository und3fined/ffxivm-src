---
--- Author: zimuyi
--- DateTime: 2023-05-25 16:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetScoreIcon = require("Binder/UIBinderSetScoreIcon")

local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local EquipmentRepairItemVM = require("Game/Equipment/VM/EquipmentRepairItemVM")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")

local EndureState = EquipmentDefine.EndureState

---@class EquipmentRepairItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRepair CommBtnSView
---@field ImgBg UFImage
---@field ImgHighlightBg UFImage
---@field ImgMoney UFImage
---@field ProBarCondition UProgressBar
---@field SlotItem EquipmentSlotItemView
---@field TextCondition UFTextBlock
---@field TextDiscount UFTextBlock
---@field TextName UFTextBlock
---@field TextPrice UFTextBlock
---@field AnimFixIn UWidgetAnimation
---@field AnimFixOut UWidgetAnimation
---@field AnimFixProgress UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentRepairItemView = LuaClass(UIView, true)

local EndureColorMap =
{
	[EndureState.Unavailable] = "4E4E4EFF",
	[EndureState.Normal] = "3B724CFF",
	[EndureState.Full] = "3A6A9EFF",
}

function EquipmentRepairItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRepair = nil
	--self.ImgBg = nil
	--self.ImgHighlightBg = nil
	--self.ImgMoney = nil
	--self.ProBarCondition = nil
	--self.SlotItem = nil
	--self.TextCondition = nil
	--self.TextDiscount = nil
	--self.TextName = nil
	--self.TextPrice = nil
	--self.AnimFixIn = nil
	--self.AnimFixOut = nil
	--self.AnimFixProgress = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentRepairItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRepair)
	self:AddSubView(self.SlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentRepairItemView:OnInit()
	self.ViewModel = EquipmentRepairItemVM.New()
	self.ViewModel.AnimFixLeastTime = self.AnimFixProgress:GetEndTime() - 1.0 + self.AnimFixOut:GetEndTime()
	self.Binders =
	{
		{ "EquipName", UIBinderSetText.New(self, self.TextName) },
		{ "EndureDegProgress", UIBinderSetPercent.New(self, self.ProBarCondition) },
		{ "EndureDeg", UIBinderSetTextFormat.New(self, self.TextCondition, "%.2f%%") },
		{ "FormattedDiscount", UIBinderSetText.New(self, self.TextDiscount) },
		{ "FormattedPrice", UIBinderSetText.New(self, self.TextPrice) },
		{ "bCanRepair", UIBinderValueChangedCallback.New(self, nil, self.OnCanRepairChanged) },
		{ "EndureState", UIBinderValueChangedCallback.New(self, nil, self.OnEndureStateChanged) },
		{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgBg, true) },
		{ "bSelected", UIBinderSetIsVisible.New(self, self.ImgHighlightBg) },
		{ "bPlayAnimFix", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimFixChanged) },
		{ "ScoreType", UIBinderSetScoreIcon.New(self, self.ImgMoney) },
	}
end

function EquipmentRepairItemView:OnDestroy()

end

function EquipmentRepairItemView:OnShow()
	self.BtnRepair.TextContent:SetText(LSTR(1050171))
end

function EquipmentRepairItemView:OnHide()

end

function EquipmentRepairItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRepair, self.OnRepairClicked)
end

function EquipmentRepairItemView:OnRegisterGameEvent()

end

function EquipmentRepairItemView:OnRegisterBinder()
	if nil ~= self.Params and nil ~= self.Params.Data then
		self.ViewModel = self.Params.Data
	end
	self.SlotItem:SetParams({ Data = self.ViewModel.SlotItemVM })
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function EquipmentRepairItemView:OnCanRepairChanged(bCanRepair)
	self.BtnRepair:SetIsEnabled(bCanRepair)
end

function EquipmentRepairItemView:OnRepairClicked()
	self.ViewModel.bCanRepair = false
	EquipmentMgr:SendEquipRepair({self.ViewModel.GID}, true)
end

function EquipmentRepairItemView:OnEndureStateChanged(InEndureState)
	local Color = EndureColorMap[InEndureState]
	UIUtil.ProgressBarSetFillColorAndOpacityHex(self.ProBarCondition, Color)
end

function EquipmentRepairItemView:OnPlayAnimFixChanged(bPlayAnimFix)
	if bPlayAnimFix then
		-- 播放动效
		self:PlayAnimation(self.AnimFixIn)
		self:PlayAnimation(self.AnimFixProgress, self.ViewModel.EndureDegProgress)
		local FixProgressTime = self.AnimFixProgress:GetEndTime() - self.ViewModel.EndureDegProgress
		self:RegisterTimer(function() self:PlayAnimation(self.AnimFixOut) end, FixProgressTime)

		-- 数值跟随动效变换
		local TimeInterval = 0.05
		local FixValueTime = 1.0 - self.ViewModel.EndureDegProgress
		local UpdateNumber = math.ceil(FixValueTime / TimeInterval)
		local function UpdateEndureDegText()
			local EndureDeg = self.ViewModel.EndureDeg + TimeInterval * 100
			self.ViewModel.EndureDeg = math.min(100, EndureDeg)
		end
		self:RegisterTimer(UpdateEndureDegText, TimeInterval, TimeInterval, UpdateNumber)

		self.bPlayAnimFix = false
	end
end

return EquipmentRepairItemView