---
--- Author: Administrator
--- DateTime: 2024-02-20 20:21
--- Description:追踪界面 外观模型Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionEvaluationFittingRoomWinEquipmentListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot CommBackpackSlotView
---@field ImgFocus UFImage
---@field TextName UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationFittingRoomWinEquipmentListView = LuaClass(UIView, true)

function FashionEvaluationFittingRoomWinEquipmentListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot = nil
	--self.ImgFocus = nil
	--self.TextName = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationFittingRoomWinEquipmentListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationFittingRoomWinEquipmentListView:OnInit()
	self.Binders = {
		{"EquipIcon", UIBinderSetBrushFromAssetPath.New(self, self.BackpackSlot.FImg_Icon)},
		{"EquipName", UIBinderSetText.New(self, self.TextName)},
		{"OwnNumText", UIBinderSetText.New(self, self.TextQuantity)},
		{"IsVisible", UIBinderSetIsVisible.New(self, self)},
	}
	UIUtil.SetIsVisible(self.BackpackSlot.RedDot2, false)
end

function FashionEvaluationFittingRoomWinEquipmentListView:OnDestroy()

end

function FashionEvaluationFittingRoomWinEquipmentListView:OnShow()

end

function FashionEvaluationFittingRoomWinEquipmentListView:OnHide()

end

function FashionEvaluationFittingRoomWinEquipmentListView:OnRegisterUIEvent()

end

function FashionEvaluationFittingRoomWinEquipmentListView:OnRegisterGameEvent()

end

function FashionEvaluationFittingRoomWinEquipmentListView:OnRegisterBinder()
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

function FashionEvaluationFittingRoomWinEquipmentListView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgFocus, IsSelected)
end

return FashionEvaluationFittingRoomWinEquipmentListView