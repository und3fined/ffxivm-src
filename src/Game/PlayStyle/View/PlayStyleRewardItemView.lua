---
--- Author: Administrator
--- DateTime: 2023-11-07 19:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL

---@class PlayStyleRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field Slot152 CommBackpack152SlotView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleRewardItemView = LuaClass(UIView, true)

function PlayStyleRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.Slot152 = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Slot152)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleRewardItemView:OnInit()
	self.Binders = {
		{ "Num", UIBinderSetItemNumFormat.New(self, self.Slot152.RichTextQuantity) },
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.Slot152.RichTextQuantity) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Slot152.Icon) },
		{ "ItemName", UIBinderSetText.New(self, self.TextName) },

	}
end

function PlayStyleRewardItemView:OnDestroy()

end

function PlayStyleRewardItemView:OnShow()
	self.Slot152:SetLevelVisible(false)
	self.Slot152:SetIconChooseVisible(false)

end

function PlayStyleRewardItemView:OnHide()

end

function PlayStyleRewardItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnBtnClick)
end

function PlayStyleRewardItemView:OnBtnClick()
	local ID = self.ViewModel.ID
	local Cfg = ItemCfg:FindCfg(ID)
	if Cfg == nil then
		return
	end
	if Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_CURRENCY then
		ItemTipsUtil.CurrencyTips(self.ViewModel.ID, true, self)
	else
		ItemTipsUtil.ShowTipsByResID(self.ViewModel.ID, self.BtnClick)
	end
end

function PlayStyleRewardItemView:OnRegisterGameEvent()

end

function PlayStyleRewardItemView:OnRegisterBinder()
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

return PlayStyleRewardItemView