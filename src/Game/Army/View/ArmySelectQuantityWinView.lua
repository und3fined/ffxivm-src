---
--- Author: Administrator
--- DateTime: 2025-03-11 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local ArmySelectQuantityWinVM = require("Game/Army/VM/ArmySelectQuantityWinVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class ArmySelectQuantityWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field ArmyDepotSlot CommBackpack126SlotView
---@field BatchUseQuantity CommEditQuantityItemView
---@field BtnCancel CommBtnLView
---@field BtnUse CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field EditQuantity CommEditQuantityItemView
---@field SliderHorizontal CommSliderHorizontalView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySelectQuantityWinView = LuaClass(UIView, true)

function ArmySelectQuantityWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.ArmyDepotSlot = nil
	--self.BatchUseQuantity = nil
	--self.BtnCancel = nil
	--self.BtnUse = nil
	--self.Comm2FrameM_UIBP = nil
	--self.EditQuantity = nil
	--self.SliderHorizontal = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySelectQuantityWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.ArmyDepotSlot)
	self:AddSubView(self.BatchUseQuantity)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.EditQuantity)
	self:AddSubView(self.SliderHorizontal)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySelectQuantityWinView:OnInit()
	self.WinVM = ArmySelectQuantityWinVM.New()
	self.Binders = {
		{ "NameText", UIBinderSetText.New(self, self.TextName) },
	}
	self.ArmyDepotSlot:SetClickButtonCallback(self, self.OnClickedBtnSlot)
end

function ArmySelectQuantityWinView:OnDestroy()

end

function ArmySelectQuantityWinView:OnShow()
	---默认文本设置
	---LSTR 选择数量
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(910420))
	self.BtnCancel:SetButtonText(LSTR(10003))
	self.BtnUse:SetButtonText(LSTR(10002))

	if nil == self.Params then
		return
	end

	local Item = self.Params.Item
	if Item ~= nil then
		self.MinValue = 1
		self.MaxValue = Item.Num
		self.Quantity = self.MinValue
		self.WinVM:UpdateVM(Item)
		UIUtil.SetIsVisible(self.SliderHorizontal, true)
		UIUtil.SetIsVisible(self.AmountSlider, false)
		UIUtil.SetIsVisible(self.BatchUseQuantity, false)
		UIUtil.SetIsVisible(self.EditQuantity, true)
		self.EditQuantity:SetInputLowerLimit(self.MinValue)
		self.EditQuantity:SetInputUpperLimit(self.MaxValue)

		self.EditQuantity:SetCurValue(self.MinValue)

		self.EditQuantity:SetModifyValueCallback(function (ConfirmValue)
			self.Quantity = ConfirmValue
			local Percent  = (self.Quantity - self.MinValue) / (self.MaxValue- self.MinValue)
			self.SliderHorizontal:SetValue(Percent)
		end)

		self.SliderHorizontal:SetValueChangedCallback(function (v)
			self:OnValueChangedSlider(v)
		end)

		self.SliderHorizontal:SetValue(0)
	end
end

function ArmySelectQuantityWinView:OnHide()

end

function ArmySelectQuantityWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnUse.Button, self.OnClickedOK)
end

function ArmySelectQuantityWinView:OnRegisterGameEvent()

end

function ArmySelectQuantityWinView:OnRegisterBinder()
	self:RegisterBinders(self.WinVM, self.Binders)
	self.ArmyDepotSlot:SetParams({Data = self.WinVM.ArmyDepotSlotVM})
end

---数量变化bySlider
function ArmySelectQuantityWinView:OnValueChangedSlider( Percent )
	self.Quantity  = math.floor(Percent * (self.MaxValue - self.MinValue)) + self.MinValue
	----防止相互调用死循环
	if self.EditQuantity.CurValue ~= self.Quantity then
		self.EditQuantity:SetCurValue(self.Quantity)
	end
end

function ArmySelectQuantityWinView:OnClickedCancel()
	self:Hide()
end


function ArmySelectQuantityWinView:OnClickedOK()
	if nil == self.Params or nil == self.Params.Item then
		self:Hide()
		return
	end
	---数量拦截
	local NuFullItemNum = self.Params.NuFullItemNum
	if NuFullItemNum then
		if self.Quantity > NuFullItemNum then
			---部队仓库空间不足
			MsgTipsUtil.ShowTipsByID(145031)
		end
	end
	local Item = self.Params.Item
	local DepotIndex = self.Params.DepotIndex
	local IsTake = self.Params.IsTake
	if IsTake then
		_G.ArmyMgr:SendGroupStoreFetChItemAndCheck(DepotIndex, Item.GID, Item.ResID, self.Quantity )
	else
		_G.ArmyMgr:SendGroupStoreDepositItemAndCheck(DepotIndex, Item.GID, self.Quantity, Item.ResID)
	end

	self:Hide()
end

function ArmySelectQuantityWinView:OnClickedBtnSlot()
	if self.Params and self.Params.Item then
		ItemTipsUtil.ShowTipsByResID(self.Params.Item.ResID, self.ArmyDepotSlot, {X = 0, Y = 0})
	end

end


return ArmySelectQuantityWinView