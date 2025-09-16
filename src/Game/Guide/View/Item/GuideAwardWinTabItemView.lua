---
--- Author: Administrator
--- DateTime: 2024-04-24 15:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")

---@class GuideAwardWinTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF UFCanvasPanel
---@field FRetainerBox_0 UFRetainerBox
---@field ImgBGFocus UFImage
---@field ImgBGNormal UFImage
---@field PanelReceived UFCanvasPanel
---@field SlotItem CommBackpack126SlotView
---@field TextNumber UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GuideAwardWinTabItemView = LuaClass(UIView, true)

function GuideAwardWinTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF = nil
	--self.FRetainerBox_0 = nil
	--self.ImgBGFocus = nil
	--self.ImgBGNormal = nil
	--self.PanelReceived = nil
	--self.SlotItem = nil
	--self.TextNumber = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GuideAwardWinTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GuideAwardWinTabItemView:OnInit()
	self.Binders = {
		{"CollectTargetNum", UIBinderSetText.New(self, self.TextNumber)},
		{"IsGetProgress", UIBinderSetIsVisible.New(self, self.EFF)},
		{"IsCollectedAward", UIBinderSetIsVisible.New(self, self.PanelReceived)},
		{"AwardIcon", UIBinderValueChangedCallback.New(self, nil, self.OnAwardIconChanged)},
		{"AwardNum", UIBinderValueChangedCallback.New(self, nil, self.OnAwardNumChanged)},
	}
end

function GuideAwardWinTabItemView:OnAwardIconChanged(NewValue, OldValue)
	self.SlotItem:SetIconImg(NewValue)
end

function GuideAwardWinTabItemView:OnAwardNumChanged(NewValue, OldValue)
	self.SlotItem:SetNumVisible(true)
	self.SlotItem:SetNum(NewValue)
end

function GuideAwardWinTabItemView:OnDestroy()

end

function GuideAwardWinTabItemView:OnShow()
	self.SlotItem:SetIconChooseVisible(false) -- 隐藏选中ICON
	UIUtil.SetIsVisible(self.ImgBGFocus, false)
	local Pos = UIUtil.GetWidgetPosition(self)

	_G.FLOG_INFO("定位BUG测试用 , GuideAwardWinTabItemView:OnShow() . x:%s , y:%s", Pos.X, Pos.Y)
end

function GuideAwardWinTabItemView:OnHide()
	local Pos = UIUtil.GetWidgetPosition(self)

	_G.FLOG_INFO("定位BUG测试用 , GuideAwardWinTabItemView:OnHide() . x:%s , y:%s", Pos.X, Pos.Y)
end

function GuideAwardWinTabItemView:OnRegisterUIEvent()
end

function GuideAwardWinTabItemView:OnRegisterGameEvent()

end

function GuideAwardWinTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)

	if (self.ViewModel.ItemClickCallback ~= nil) then
		self.SlotItem:SetClickButtonCallback(self, self.ViewModel.ItemClickCallback)
	end
end

return GuideAwardWinTabItemView