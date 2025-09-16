---
--- Author: Administrator
--- DateTime: 2024-02-20 20:20
--- Description:奖励Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionEvaluationSlot96pxItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot CommBackpackSlotView
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationSlot96pxItemView = LuaClass(UIView, true)

function FashionEvaluationSlot96pxItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationSlot96pxItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationSlot96pxItemView:OnInit()
	self.Binders = {
		--{"IsGetProgress", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{"Num", UIBinderSetText.New(self, self.TextQuantity)},
		{"AwardIcon", UIBinderSetBrushFromAssetPath.New(self, self.BackpackSlot.FImg_Icon)},
	}
end

function FashionEvaluationSlot96pxItemView:OnDestroy()

end

function FashionEvaluationSlot96pxItemView:OnShow()

end

function FashionEvaluationSlot96pxItemView:OnHide()

end

function FashionEvaluationSlot96pxItemView:OnRegisterUIEvent()
	self.BackpackSlot:SetClickButtonCallback(self, self.OnBtnClicked)
end

function FashionEvaluationSlot96pxItemView:OnRegisterGameEvent()

end

function FashionEvaluationSlot96pxItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self.ItemID = self.ViewModel.AwardID
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function FashionEvaluationSlot96pxItemView:OnBtnClicked()
	ItemTipsUtil.ShowTipsByItem({ResID = self.ItemID}, self.BackpackSlot, {X = -2, Y = -15})
end

return FashionEvaluationSlot96pxItemView