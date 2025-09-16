---
--- Author: Administrator
--- DateTime: 2024-09-03 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local NewBagSelectQuantityVM = require("Game/NewBag/VM/NewBagSelectQuantityVM")
local DepotVM = require("Game/Depot/DepotVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")

local LSTR = _G.LSTR
---@class NewBagSelectQuantityWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BagSlot BagSlotView
---@field BatchUseQuantity CommEditQuantityItemView
---@field BtnCancel CommBtnLView
---@field BtnUse CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field EditQuantity CommEditQuantityItemView
---@field SliderHorizontal CommSliderHorizontalView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagSelectQuantityWinView = LuaClass(UIView, true)

function NewBagSelectQuantityWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BagSlot = nil
	--self.BatchUseQuantity = nil
	--self.BtnCancel = nil
	--self.BtnUse = nil
	--self.Comm2FrameM_UIBP = nil
	--self.EditQuantity = nil
	--self.SliderHorizontal = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagSelectQuantityWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BagSlot)
	self:AddSubView(self.BatchUseQuantity)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.EditQuantity)
	self:AddSubView(self.SliderHorizontal)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagSelectQuantityWinView:OnInit()
	self.Binders = {
		{ "NameText", UIBinderSetText.New(self, self.TextName) },
		{ "Percent", UIBinderSetSlider.New(self, self.SliderHorizontal)},
	}
end

function NewBagSelectQuantityWinView:OnDestroy()

end

function NewBagSelectQuantityWinView:OnShow()
	if nil == self.Params then
		return
	end

	local Item = self.Params.Item
	if Item ~= nil then
		self.MinValue = 1
		self.MaxValue = Item.Num
		NewBagSelectQuantityVM:UpdateVM(Item)
		if Item.BatchUse then
			UIUtil.SetIsVisible(self.SliderHorizontal, false)
			UIUtil.SetIsVisible(self.AmountSlider, true)
			UIUtil.SetIsVisible(self.BatchUseQuantity, true)
			UIUtil.SetIsVisible(self.EditQuantity, false)

			self.AmountSlider:SetSliderValueMaxMin(self.MaxValue, self.MinValue)
			self.AmountSlider:SetSliderValueMaxTips(LSTR(990098)) -- 已达到最大数量， 不能再增加
			self.AmountSlider:SetSliderValueMinTips(LSTR(990099)) -- 已达到最小数量， 不能再减少

			self.BatchUseQuantity:SetInputLowerLimit(self.MinValue, LSTR(990100)) -- 已达最小数量
			self.BatchUseQuantity:SetInputUpperLimit(self.MaxValue, LSTR(990101)) -- 已达最大数量

			self.BatchUseQuantity:SetCurValue(self.MinValue)
			self.Quantity = self.MinValue

			-- 标志防递归调用
			local isUpdating = false

			self.BatchUseQuantity:SetModifyValueCallback(function (ConfirmValue)
				if isUpdating then return end
				isUpdating = true
				self.Quantity = ConfirmValue
				self.AmountSlider:SetSliderValue(ConfirmValue)
				isUpdating = false
			end)

			self.AmountSlider:SetValueChangedCallback(function (v)
				if isUpdating then return end
				isUpdating = true
				self.Quantity = v
				self.BatchUseQuantity:SetCurValue(v)
				isUpdating = false
			end)


		else
			UIUtil.SetIsVisible(self.SliderHorizontal, true)
			UIUtil.SetIsVisible(self.AmountSlider, false)
			UIUtil.SetIsVisible(self.BatchUseQuantity, false)
			UIUtil.SetIsVisible(self.EditQuantity, true)
			self.EditQuantity:SetInputLowerLimit(self.MinValue)
			self.EditQuantity:SetInputUpperLimit(self.MaxValue)

			self.EditQuantity:SetCurValue(self.MinValue)
			self.Quantity = self.MinValue

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
end

function NewBagSelectQuantityWinView:OnHide()

end

function NewBagSelectQuantityWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnUse.Button, self.OnClickedOK)
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnClickedBtnSlot)
end

function NewBagSelectQuantityWinView:OnRegisterGameEvent()
end

function NewBagSelectQuantityWinView:OnRegisterBinder()
	self:RegisterBinders(NewBagSelectQuantityVM, self.Binders)
	self.BagSlot:SetParams({Data = NewBagSelectQuantityVM.BagSlotVM})

	self.Comm2FrameM_UIBP:SetTitleText(LSTR(990094))
	self.BtnCancel:SetButtonText(LSTR(10003))
	self.BtnUse:SetButtonText(LSTR(10002))
end

function NewBagSelectQuantityWinView:OnValueChangedSlider( Percent )
	self.Quantity  = math.floor(Percent * (self.MaxValue - self.MinValue)) + self.MinValue
	self.EditQuantity:SetCurValue(self.Quantity)
end

function NewBagSelectQuantityWinView:OnAmountSliderValueChanged( Percent )
	self.Quantity  = math.floor(Percent * (self.MaxValue - self.MinValue)) + self.MinValue
	self.BatchUseQuantity:SetCurValue(self.Quantity)
end

function NewBagSelectQuantityWinView:OnClickedCancel()
	self:Hide()
end


function NewBagSelectQuantityWinView:OnClickedOK()
	if nil == self.Params or nil == self.Params.Item then
		self:Hide()
		return
	end

	local Item = self.Params.Item
	if Item.BatchUse then
		_G.BagMgr:SendMsgUseItemReq(Item.GID, self.Quantity, 0)
	else
		local DepotIndex = self.Params.DepotIndex
		if DepotIndex ~= nil then
			_G.DepotMgr:SendMsgDepotTransfer(DepotVM:GetCurDepotIndex(), DepotIndex, Item.GID, self.Quantity)
		else
			_G.BagMgr:SendMsgBagTransDepot(Item.GID, DepotVM:GetCurDepotIndex(), 0, self.Quantity)
		end
	end
	self:Hide()

end

function NewBagSelectQuantityWinView:OnClickedBtnSlot()
	if self.Params and self.Params.Item then
		ItemTipsUtil.ShowTipsByResID(self.Params.Item.ResID, self.BagSlot, {X = 0, Y = 0})
	end
end


return NewBagSelectQuantityWinView