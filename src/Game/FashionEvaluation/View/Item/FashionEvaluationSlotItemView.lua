---
--- Author: Administrator
--- DateTime: 2024-02-20 20:20
--- Description:追踪界面 外观列表ItemView		
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionEvaluationSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommBackpack126SlotView
---@field CommonRedDot CommonRedDotView
---@field IconHave UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationSlotItemView = LuaClass(UIView, true)

function FashionEvaluationSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm126Slot = nil
	--self.CommonRedDot = nil
	--self.IconHave = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationSlotItemView:OnInit()
	self.Binders = {
		{"AppearanceIcon", UIBinderSetBrushFromAssetPath.New(self, self.Comm126Slot.Icon)},
		{"CanUnLock", UIBinderSetIsVisible.New(self, self.Comm126Slot.RedDot2)},
		{"CanUnLock", UIBinderValueChangedCallback.New(self, nil, self.OnCanUnLockChange) },
		{"IsOwn", UIBinderSetIsVisible.New(self, self.IconHave)},
	}

	self.Comm126Slot:SetNumVisible(false)
	self.Comm126Slot:SetIconChooseVisible(false)
	self.Comm126Slot:SetItemLevel("")
end

function FashionEvaluationSlotItemView:OnDestroy()

end

function FashionEvaluationSlotItemView:OnShow()
	local AppID = self.Params and self.Params.Data and self.Params.Data.AppearanceID
	local RedDotName = FashionEvaluationMgr:GetRedDotName(AppID)
	self.CommonRedDot:SetRedDotData(nil, RedDotName, RedDotDefine.RedDotStyle.NormalStyle)
end

function FashionEvaluationSlotItemView:OnHide()

end

function FashionEvaluationSlotItemView:OnRegisterUIEvent()

end

function FashionEvaluationSlotItemView:OnRegisterGameEvent()

end

function FashionEvaluationSlotItemView:OnRegisterBinder()
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

function FashionEvaluationSlotItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.Comm126Slot.ImgSelect, IsSelected)
end

function FashionEvaluationSlotItemView:OnCanUnLockChange(CanUnLock)
	local RedDotName = self:GetRedDotName()
	if CanUnLock then
		_G.RedDotMgr:AddRedDotByName(RedDotName)
	else
		_G.RedDotMgr:DelRedDotByName(RedDotName)
	end
end

function FashionEvaluationSlotItemView:GetRedDotName()
	local AppID = self.Params and self.Params.Data and self.Params.Data.AppearanceID or 0
	local RedDotName = string.format(FashionEvaluationDefine.TrackRedDotName..'/'..AppID)
	return RedDotName
end


return FashionEvaluationSlotItemView