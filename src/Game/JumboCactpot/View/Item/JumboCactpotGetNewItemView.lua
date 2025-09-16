---
--- Author: Administrator
--- DateTime: 2024-07-09 11:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")

local ItemTipsUtil = require("Utils/ItemTipsUtil")
---@class JumboCactpotGetNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field PanelReward01 UFCanvasPanel
---@field PanelReward02 UFCanvasPanel
---@field RichTextBoxNumber URichTextBox
---@field Slot01 CommBackpack96SlotView
---@field Slot02 CommBackpack96SlotView
---@field TextDescribe UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotGetNewItemView = LuaClass(UIView, true)

function JumboCactpotGetNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.PanelReward01 = nil
	--self.PanelReward02 = nil
	--self.RichTextBoxNumber = nil
	--self.Slot01 = nil
	--self.Slot02 = nil
	--self.TextDescribe = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotGetNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Slot01)
	self:AddSubView(self.Slot02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotGetNewItemView:OnInit()
	self.Binders = {
		{ "bShowItemReward", UIBinderSetIsVisible.New(self, self.PanelReward01)},
		{ "Level", UIBinderSetText.New(self, self.TextTitle)},
		{ "TextDescribe", UIBinderSetText.New(self, self.TextDescribe)},

		{ "RichNumber", UIBinderSetText.New(self, self.RichTextBoxNumber)},
		{ "RewardNum", UIBinderSetTextFormatForMoney.New(self, self.Slot02.RichTextQuantity)},
		{ "ItemCount", UIBinderSetText.New(self, self.Slot01.RichTextQuantity)},
		{ "bNumVisible", UIBinderSetIsVisible.New(self, self.Slot01.RichTextQuantity)},
		{ "bNumVisible", UIBinderSetIsVisible.New(self, self.Slot02.RichTextQuantity)},

		{ "ItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.Slot01.Icon) },
		{ "JDIcon", UIBinderSetBrushFromAssetPath.New(self, self.Slot02.Icon) },
		{ "ImgBGPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG) },

	}
end

function JumboCactpotGetNewItemView:OnDestroy()

end

function JumboCactpotGetNewItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.Slot01:SetClickButtonCallback(self.Slot01, function(TargetItemView)
		ItemTipsUtil.ShowTipsByResID(ViewModel.ItemResID, self.Slot01)
	end)

	self.Slot02:SetClickButtonCallback(self.Slot02, function(TargetItemView)
		ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, false, TargetItemView)
	end)

	self.Slot01:SetLevelVisible(false)
	self.Slot02:SetLevelVisible(false)

	self.Slot01:SetIconChooseVisible(false)
	self.Slot02:SetIconChooseVisible(false)

end

function JumboCactpotGetNewItemView:OnHide()

end

function JumboCactpotGetNewItemView:OnRegisterUIEvent()

end

function JumboCactpotGetNewItemView:OnRegisterGameEvent()

end

function JumboCactpotGetNewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end



return JumboCactpotGetNewItemView