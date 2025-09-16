---
--- Author: Administrator
--- DateTime: 2025-03-13 14:19
--- Description:奖励节点
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local DepartOfLightMgr = require("Game/Departure/DepartOfLightMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class DepartureSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field Comm96Slot CommBackpack96SlotView
---@field IconHookFocus UFImage
---@field IconHookNormal UFImage
---@field PanelAvailable UFCanvasPanel
---@field PanelHook UFCanvasPanel
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureSlotView = LuaClass(UIView, true)

function DepartureSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.Comm96Slot = nil
	--self.IconHookFocus = nil
	--self.IconHookNormal = nil
	--self.PanelAvailable = nil
	--self.PanelHook = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureSlotView:OnInit()
	self.Binders = {
		{"BtnCheckVisible", UIBinderSetIsVisible.New(self, self.BtnCheck, false, true)},
		{"RewardNum", UIBinderSetText.New(self, self.Comm96Slot.RichTextQuantity)},
		{"RewardIcon", UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.Icon)},
		{"TargetNum", UIBinderSetText.New(self, self.Text)},
		{"RewardStatus", UIBinderValueChangedCallback.New(self, nil, self.OnRewardStatusChange)},
		{"ItemQualityIcon", UIBinderSetImageBrush.New(self, self.Comm96Slot.ImgQuanlity)},
	}
end

function DepartureSlotView:OnDestroy()

end

function DepartureSlotView:OnShow()
	UIUtil.SetIsVisible(self.Comm96Slot.IconChoose, false)
end

function DepartureSlotView:OnHide()

end

function DepartureSlotView:OnRegisterUIEvent()
	self.Comm96Slot:SetClickButtonCallback(self, self.OnBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnPreviewBtnClicked)
end

function DepartureSlotView:OnRegisterGameEvent()

end

function DepartureSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function DepartureSlotView:OnBtnClicked()
	local ItemID = self.ViewModel.RewardID
	local NodeID = self.ViewModel.NodeID
	local State = self.ViewModel.RewardStatus
	if State == DepartOfLightDefine.ERewardStatus.RewardStatusWaitGet then
		DepartOfLightMgr:SendDepartureGetTaskRewardReq(NodeID)
	else
		ItemTipsUtil.ShowTipsByItem({ResID = ItemID}, self.Comm96Slot, {X = -2, Y = -15})
	end
end

function DepartureSlotView:OnPreviewBtnClicked()
	local ItemID = self.ViewModel and self.ViewModel.RewardID or 0
	_G.PreviewMgr:OpenPreviewView(ItemID)
end

function DepartureSlotView:OnRewardStatusChange(State)
	UIUtil.SetIsVisible(self.PanelHook, State ~= DepartOfLightDefine.ERewardStatus.RewardStatusNo)
	UIUtil.SetIsVisible(self.IconHookFocus, State == DepartOfLightDefine.ERewardStatus.RewardStatusWaitGet)
	UIUtil.SetIsVisible(self.IconHookNormal, State == DepartOfLightDefine.ERewardStatus.RewardStatusDone)

	UIUtil.SetIsVisible(self.PanelAvailable, State == DepartOfLightDefine.ERewardStatus.RewardStatusWaitGet) -- 待领奖
	UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, State == DepartOfLightDefine.ERewardStatus.RewardStatusDone, false) -- 已领奖
end


return DepartureSlotView