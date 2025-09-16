---
--- Author: usakizhang
--- DateTime: 2025-03-11 10:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local OpsCeremony126SlotVM = require("Game/Ops/VM/OpsCeremony/OpsCeremony126SlotVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
---@class OpsCeremony126SlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field ImgQuanlity UFImage
---@field PanelInfo UFCanvasPanel
---@field PanelReceived UFCanvasPanel
---@field RichTextQuantity URichTextBox
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCeremony126SlotView = LuaClass(UIView, true)

function OpsCeremony126SlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.ImgQuanlity = nil
	--self.PanelInfo = nil
	--self.PanelReceived = nil
	--self.RichTextQuantity = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCeremony126SlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCeremony126SlotView:OnInit()
	self.ItemVM = OpsCeremony126SlotVM.New()
	self.Binders = {
		{ "Num", UIBinderSetText.New(self, self.RichTextQuantity)},
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
		{ "IconReceivedVisible", UIBinderSetIsVisible.New(self, self.PanelReceived)},
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuanlity)},
	}
end

function OpsCeremony126SlotView:OnDestroy()
	self.ItemVM = nil
end

function OpsCeremony126SlotView:OnShow()

end

function OpsCeremony126SlotView:OnHide()

end

function OpsCeremony126SlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickSlotBtn)
end

function OpsCeremony126SlotView:OnRegisterGameEvent()

end

function OpsCeremony126SlotView:OnRegisterBinder()
	if self.ItemVM then
		self:RegisterBinders(self.ItemVM, self.Binders)
	end
end

function OpsCeremony126SlotView:Update(Params)
	if self.ItemVM then
		self.ItemVM:Update(Params)
	end
end

function OpsCeremony126SlotView:OnClickSlotBtn()
	local ViewModel = self.ItemVM
	if not ViewModel then
		return
	end
	if ViewModel.IsItem then
		ItemTipsUtil.ShowTipsByResID(ViewModel.ResID, self)
	else
		local ItemSize = UIUtil.GetLocalSize(self)
		TipsUtil.ShowInfoTips(LSTR(1580027), self, _G.UE.FVector2D(-(ItemSize.X / 2.0) - 20, -(ItemSize.Y / 2.0) + 10), _G.UE.FVector2D(0.5, 0.5), false)
	end

end
return OpsCeremony126SlotView