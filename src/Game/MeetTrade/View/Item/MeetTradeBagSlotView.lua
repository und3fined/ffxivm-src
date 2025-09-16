---
--- Author: usakizhang
--- DateTime: 2024-12-26 20:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetAnimPlayPercentage = require("Binder/UIBinderSetAnimPlayPercentage")
local MeetTradeBagMainVM = require("Game/MeetTrade/VM/MeetTradeBagMainVM")
local UIUtil = require("Utils/UIUtil")

---@class MeetTradeBagSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot_UIBP BagSlotView
---@field BtnDelete UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MeetTradeBagSlotView = LuaClass(UIView, true)

function MeetTradeBagSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot_UIBP = nil
	--self.BtnDelete = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MeetTradeBagSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MeetTradeBagSlotView:OnInit()
	self.Binders = {
		{ "ItemVisible", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.PanelBag) },
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.BagSlot_UIBP.ImgQuality) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.BagSlot_UIBP.ImgIcon) },
		{ "Num", UIBinderSetText.New(self, self.BagSlot_UIBP.RichTextNum) },
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.RichTextNum) },
		{ "IsMask", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.ImgMask) },
		{ "IsSelectedForTrade", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.PanelMultiChoice) },
		--- 只有TableViewChosenItemList中的Item才需要显示该图标
		{ "IsShowDeletButton", UIBinderSetIsVisible.New(self, self.BtnDelete, false, true) },
		--- 复用背包Item，蓝图中存在一些在面对面交易不需要显示的图标，全部默认不显示
		{ "IsShowOtherInfo", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.ImgSelect) },
		{ "IsShowOtherInfo", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.PanelEquipment) },
		{ "IsShowOtherInfo", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.PanelMedicine) },
		{ "IsShowOtherInfo", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.IconLimitedTime) },
		{ "IsShowOtherInfo", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.IconExpired) },
		{ "IsShowOtherInfo", UIBinderSetIsVisible.New(self, self.BagSlot_UIBP.IconEuipImprove) },
		--- 数量更新时播放动效
		{ "AnimOpticalFeedbackStartAt", UIBinderSetAnimPlayPercentage.New(self, self.BagSlot_UIBP, self.AnimOpticalFeedback, true)}
	}
end

function MeetTradeBagSlotView:OnDestroy()

end

function MeetTradeBagSlotView:OnShow()

end

function MeetTradeBagSlotView:OnHide()

end

function MeetTradeBagSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickedDeleteButton)
end

function MeetTradeBagSlotView:OnRegisterGameEvent()

end


function MeetTradeBagSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function MeetTradeBagSlotView:OnClickedDeleteButton()
	local Params = self.Params
	if nil == Params then
		return
	end
	--- MeetTradeBagMainView的Onclick事件用于响应整个Slot的点击事件，这个按钮只是Slot左上角的一个按钮
	--- 因此不能上报给TableView,TableView也不实现对点击的响应，如果上报TableView且响应，Tableview会同时收到BagSlotView检测的点击事件
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	---从选择列表去除自身
	MeetTradeBagMainVM:RemoveItemVMFromSelectedList(ViewModel)
end
return MeetTradeBagSlotView