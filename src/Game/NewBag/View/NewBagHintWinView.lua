---
--- Author: Administrator
--- DateTime: 2024-09-06 20:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local NewBagHintWinVM = require("Game/NewBag/VM/NewBagHintWinVM")

local LSTR = _G.LSTR
---@class NewBagHintWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field BtnCancel CommBtnLView
---@field BtnUse CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field RichTextHint URichTextBox
---@field SingleBox CommSingleBoxView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagHintWinView = LuaClass(UIView, true)

function NewBagHintWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.BtnCancel = nil
	--self.BtnUse = nil
	--self.Comm2FrameM_UIBP = nil
	--self.RichTextHint = nil
	--self.SingleBox = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagHintWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagHintWinView:OnInit()
	self.Binders = {
		{ "TipsText", UIBinderSetText.New(self, self.RichTextHint) },
		{ "NameText", UIBinderSetText.New(self, self.TextName) },
		{ "SingleBoxVisible", UIBinderSetIsVisible.New(self, self.SingleBox) },
	}
end

function NewBagHintWinView:OnDestroy()

end

function NewBagHintWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	NewBagHintWinVM:UpdateVM(Params)
	if not string.isnilorempty(Params.Title) then
		self.Comm2FrameM_UIBP:SetTitleText(Params.Title)
	end
	local SingleBoxText = Params.SingleBoxText
	if SingleBoxText then
		self.SingleBox:SetText(SingleBoxText)
	end
end

function NewBagHintWinView:OnHide()

end

function NewBagHintWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnUse.Button, self.OnClickedOK)
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnItemClicked)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnSingleBoxSelectionChanged)
	self.Comm2FrameM_UIBP:SetClickCloseCallback(self, self.OnClickedCancel)
end

function NewBagHintWinView:OnRegisterGameEvent()
end

function NewBagHintWinView:OnRegisterBinder()
	self:RegisterBinders(NewBagHintWinVM, self.Binders)
	self.BagSlot:SetParams({Data = NewBagHintWinVM.BagSlotVM})

	self.SingleBox:SetText(LSTR(10020))
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(10004))
	self.BtnCancel:SetButtonText(LSTR(10003))
	self.BtnUse:SetButtonText(LSTR(10002))
end

function NewBagHintWinView:OnClickedCancel()
	self:Hide()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ClickedCancelListener = Params.ClickedCancelListener
	local ClickedCancelAction = Params.ClickedCancelAction
	if ClickedCancelAction ~= nil then
		if ClickedCancelListener then
			ClickedCancelAction(ClickedCancelListener)
		else
			ClickedCancelAction()
		end
	end
end

function NewBagHintWinView:OnClickedOK()
	self:Hide()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ClickedOkListener = Params.ClickedOkListener
	local ClickedOkAction = Params.ClickedOkAction
	if ClickedOkAction ~= nil then
		if ClickedOkListener then
			ClickedOkAction(ClickedOkListener)
		else
			ClickedOkAction()
		end
	end
end

function NewBagHintWinView:OnSingleBoxSelectionChanged(_, State)
	local Params = self.Params
	if nil == Params then
		return
	end
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local SingleBoxCheckedListener = Params.SingleBoxCheckedListener
	local SingleBoxCheckedFunc = Params.SingleBoxCheckedFunc
	if SingleBoxCheckedFunc ~= nil then
		if SingleBoxCheckedListener then
			SingleBoxCheckedFunc(SingleBoxCheckedListener, IsChecked)
		else
			SingleBoxCheckedFunc(IsChecked)
		end
	end

end

function NewBagHintWinView:OnItemClicked()
	local Params = self.Params
	if nil == Params then
		return
	end
	ItemTipsUtil.ShowTipsByItem(Params.Item, self.BagSlot)
	
end

return NewBagHintWinView