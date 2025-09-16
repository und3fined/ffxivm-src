---
--- Author: Administrator
--- DateTime: 2024-09-25 11:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local NewBagDowngradetWinVM = require("Game/NewBag/VM/NewBagDowngradetWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local LSTR = _G.LSTR
---@class NewBagDowngradetWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot1 BagSlotView
---@field BagSlot2 BagSlotView
---@field BtnCancel CommBtnLView
---@field BtnUse CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommSingleBox5 CommSingleBoxView
---@field TextHint UFTextBlock
---@field TextName1 UFTextBlock
---@field TextName2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagDowngradetWinView = LuaClass(UIView, true)

function NewBagDowngradetWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot1 = nil
	--self.BagSlot2 = nil
	--self.BtnCancel = nil
	--self.BtnUse = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommSingleBox5 = nil
	--self.TextHint = nil
	--self.TextName1 = nil
	--self.TextName2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagDowngradetWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot1)
	self:AddSubView(self.BagSlot2)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommSingleBox5)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagDowngradetWinView:OnInit()
	self.Binders = {
		{ "Name1Text", UIBinderSetText.New(self, self.TextName1) },
		{ "Name2Text", UIBinderSetText.New(self, self.TextName2) },
		{ "SingleBoxVisible", UIBinderSetIsVisible.New(self, self.CommSingleBox5) },
	}
end

function NewBagDowngradetWinView:OnDestroy()
	NewBagDowngradetWinVM.NoConfirm = nil
end

function NewBagDowngradetWinView:OnShow()
	if nil == self.Params then
		return
	end

	NewBagDowngradetWinVM:UpdateVM(self.Params)
	self.CommSingleBox5:SetChecked(false)
	NewBagDowngradetWinVM.IsShowTag = false
end

function NewBagDowngradetWinView:OnHide()
end

function NewBagDowngradetWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnUse.Button, self.OnClickedOK)
	UIUtil.AddOnClickedEvent(self, self.CommSingleBox5.ToggleButton, self.OnBtnClickedSingleBox)
	UIUtil.AddOnClickedEvent(self, self.BagSlot1.BtnSlot, self.OnItem1Clicked)
	UIUtil.AddOnClickedEvent(self, self.BagSlot2.BtnSlot, self.OnItem2Clicked)
end

function NewBagDowngradetWinView:OnRegisterGameEvent()

end

function NewBagDowngradetWinView:OnRegisterBinder()
	self:RegisterBinders(NewBagDowngradetWinVM, self.Binders)
	self.BagSlot1:SetParams({Data = NewBagDowngradetWinVM.BagSlotVM1})
	self.BagSlot2:SetParams({Data = NewBagDowngradetWinVM.BagSlotVM2})

	self.TextHint:SetText(LSTR(990073))
	self.CommSingleBox5:SetText(LSTR(10020))
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(990074))
	self.BtnCancel:SetButtonText(LSTR(10003))
	self.BtnUse:SetButtonText(LSTR(10002))
end

function NewBagDowngradetWinView:OnBtnClickedSingleBox(ToggleButton, State)
	local IsChecked = self.CommSingleBox5:GetChecked()
	NewBagDowngradetWinVM.IsShowTag = IsChecked
end

function NewBagDowngradetWinView:OnClickedCancel()
	self:Hide()
end


function NewBagDowngradetWinView:OnClickedOK()
	self:Hide()
	if nil == self.Params then
		return
	end
	NewBagDowngradetWinVM.NoConfirm = NewBagDowngradetWinVM.IsShowTag
	local ClickedOkAction = self.Params.ClickedOkAction
	if ClickedOkAction ~= nil then
		ClickedOkAction()
	end
end

function NewBagDowngradetWinView:OnItem1Clicked()
	ItemTipsUtil.ShowTipsByResID(NewBagDowngradetWinVM.BagSlotVM1.ResID, self.BagSlot1)
	
end

function NewBagDowngradetWinView:OnItem2Clicked()
	ItemTipsUtil.ShowTipsByResID(NewBagDowngradetWinVM.BagSlotVM2.ResID, self.BagSlot2)
	
end

return NewBagDowngradetWinView