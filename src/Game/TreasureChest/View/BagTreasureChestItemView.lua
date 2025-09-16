
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class BagTreasureChestItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Comm152Slot CommBackpack152SlotView
---@field EditQuantity CommEditQuantityItemView
---@field ImgSelect1 UFImage
---@field ImgSelect2 UFImage
---@field PanelSelect UFCanvasPanel
---@field TextSlot UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagTreasureChestItemView = LuaClass(UIView, true)

function BagTreasureChestItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Comm152Slot = nil
	--self.EditQuantity = nil
	--self.ImgSelect1 = nil
	--self.ImgSelect2 = nil
	--self.PanelSelect = nil
	--self.TextSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagTreasureChestItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm152Slot)
	self:AddSubView(self.EditQuantity)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagTreasureChestItemView:OnInit()
	self.Binders = {
		{ "IsSelected", 	UIBinderSetIsVisible.New(self, self.PanelSelect) },
		{ "IsSelected", 	UIBinderSetIsVisible.New(self, self.Btn, nil, true) },
		{ "ItemName", 		UIBinderSetText.New(self, self.TextSlot) },
		{ "Selected2Icon", 	UIBinderSetBrushFromAssetPath.New(self, self.ImgSelect2) },
	}
	self.MaxNum = _G.TreasureChestVM.MAXNum
	self.LimitTipsStr = LSTR(1230008)	--- "已达选择上限"
end

function BagTreasureChestItemView:OnDestroy()

end

function BagTreasureChestItemView:OnShow()
	self.EditQuantity.IsSetValueOnShow = false
	self.EditQuantity:SetCurValue(self.ViewModel.SelectedNum)
	self.EditQuantity:SetInputLowerLimit(0)
	self.EditQuantity:SetInputUpperLimit(self.MaxNum, self.LimitTipsStr)
	self.EditQuantity:SetModifyValueCallback(function(NewNum)
		self.ViewModel:SetNum(NewNum)
		_G.TreasureChestVM:UpdateCurrentNum()
	end)
	self.Comm152Slot:SetClickButtonCallback(self, function() ItemTipsUtil.ShowTipsByResID(self.ViewModel.ResID, self, {X = 0,Y = 0}, nil) end)
	self.Comm152Slot:SetCoubleClickButtonCallback(self, function() ItemTipsUtil.ShowTipsByResID(self.ViewModel.ResID, self, {X = 0,Y = 0}, nil) end)
	self.Comm152Slot:SetNum(self.ViewModel.Num)
end

function BagTreasureChestItemView:OnHide()
end

function BagTreasureChestItemView:OnRegisterUIEvent()

end

function BagTreasureChestItemView:OnRegisterGameEvent()
	UIUtil.AddOnClickedEvent(self, self.EditQuantity.BtnCurValue, self.OnClickedBtnCurValue)
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedBtn)
	
end

function BagTreasureChestItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	self.ViewModel = self.Params.Data
	self:RegisterBinders(self.ViewModel, self.Binders)
	self:RegisterBinders(_G.TreasureChestVM, {{ "CurrentNum", UIBinderValueChangedCallback.New(self, nil, self.UpdateLimitNum) }})
end

function BagTreasureChestItemView:UpdateLimitNum(CurrentNum)
	self.EditQuantity:SetBtnAddIsEnabled(CurrentNum ~= self.MaxNum)
	self.EditQuantity:SetInputUpperLimit(self.MaxNum)
end

function BagTreasureChestItemView:OnClickedBtnCurValue()
	if _G.TreasureChestVM:GetSingleFlag() then
		_G.TreasureChestVM:SetSingleFlag(false)
		_G.TreasureChestVM:SetCurrentNum(_G.TreasureChestVM.CurrentNum - self.ViewModel.SelectedNum)
		self.EditQuantity.CommMiniKeyView:SetInputUpperLimit(self.MaxNum - _G.TreasureChestVM.CurrentNum)
	end
end

function BagTreasureChestItemView:SetCurValue(NewNum)
	self.EditQuantity:SetCurValue(NewNum)
end

function BagTreasureChestItemView:OnClickedBtn()
	if self.ViewModel.IsSelected then
		self.ViewModel:OnSetIsSelected(false)
		self:SetCurValue(0)
	end
end

return BagTreasureChestItemView