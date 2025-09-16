---
--- Author: Administrator
--- DateTime: 2024-05-11 15:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local TipsUtil = require("Utils/TipsUtil")

---@class ArmyBatchGroupItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSwitch UFButton
---@field ImgJob UFImage
---@field ImgState UFImage
---@field PanelAll UFCanvasPanel
---@field SingleBoxAll CommSingleBoxView
---@field TextJobNum UFTextBlock
---@field TextName UFTextBlock
---@field TextPalace UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyBatchGroupItemView = LuaClass(UIView, true)

function ArmyBatchGroupItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSwitch = nil
	--self.ImgJob = nil
	--self.ImgState = nil
	--self.PanelAll = nil
	--self.SingleBoxAll = nil
	--self.TextJobNum = nil
	--self.TextName = nil
	--self.TextPalace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyBatchGroupItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBoxAll)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyBatchGroupItemView:OnInit()
	self.Binders = {
		{ "RoleName", UIBinderSetText.New(self, self.TextName)},
		{ "JobLevel", UIBinderSetText.New(self, self.TextJobNum)},
		{ "State", UIBinderSetText.New(self, self.TextPalace)},
		{ "OnlineStatusIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgState)},
		{ "JobIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgJob)},
		{ "bChecked", UIBinderValueChangedCallback.New(self, nil, self.OnCheckedChanged) },
		{ "bOnline", UIBinderValueChangedCallback.New(self, nil, self.OnlineStateChanged)},
		{ "IsEmpty", UIBinderSetIsVisible.New(self, self.PanelAll, true)},
	}
end

function ArmyBatchGroupItemView:OnDestroy()

end

function ArmyBatchGroupItemView:OnShow()

end

function ArmyBatchGroupItemView:OnHide()

end

function ArmyBatchGroupItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickedBtnSwitch)
end

function ArmyBatchGroupItemView:OnRegisterGameEvent()

end

function ArmyBatchGroupItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ArmyBatchGroupItemView:OnlineStateChanged(Value)
	--UIUtil.SetRenderOpacity(self.FCanvasPanel_14, Value and 1 or 0.5)
end

function ArmyBatchGroupItemView:OnCheckedChanged(bChecked)
	self.SingleBoxAll:SetChecked(bChecked, false)
end

function ArmyBatchGroupItemView:OnClickedBtnSwitch()

	if self.ViewModel then
		local RoleIDs = {self.ViewModel.RoleID}
		self.ViewModel.OnClickedSwitchCategory(self.ViewModel.Owner, RoleIDs, self.BtnSwitch)
	end
end
return ArmyBatchGroupItemView