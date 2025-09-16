---
--- Author: Administrator
--- DateTime: 2023-09-18 09:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
---@class JumboCactpotGetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Panel01 UFCanvasPanel
---@field Panel02 UFCanvasPanel
---@field Panel03 UFCanvasPanel
---@field Panel04 UFCanvasPanel
---@field Panel05 UFCanvasPanel
---@field PanelReward01 UFCanvasPanel
---@field PanelReward02 UFCanvasPanel
---@field Reward01 CommBackpackSlotView
---@field Reward02 CommBackpackSlotView
---@field RichTextBoxNumber URichTextBox
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotGetItemView = LuaClass(UIView, true)

function JumboCactpotGetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Panel01 = nil
	--self.Panel02 = nil
	--self.Panel03 = nil
	--self.Panel04 = nil
	--self.Panel05 = nil
	--self.PanelReward01 = nil
	--self.PanelReward02 = nil
	--self.Reward01 = nil
	--self.Reward02 = nil
	--self.RichTextBoxNumber = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotGetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Reward01)
	self:AddSubView(self.Reward02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotGetItemView:OnInit()
	self.Binders = {
		-- { "bShowItemReward", UIBinderSetIsVisible.New(self, self.PanelReward01)},
		-- { "bPanel1Show", UIBinderSetIsVisible.New(self, self.Panel01)},
		-- { "bPanel2Show", UIBinderSetIsVisible.New(self, self.Panel02)},
		-- { "bPanel3Show", UIBinderSetIsVisible.New(self, self.Panel03)},
		-- { "bPanel4Show", UIBinderSetIsVisible.New(self, self.Panel04)},
		-- { "bPanel5Show", UIBinderSetIsVisible.New(self, self.Panel05)},

		-- { "Level", UIBinderSetText.New(self, self.TextTitle)},
		-- { "RichNumber", UIBinderSetText.New(self, self.RichTextBoxNumber)},
		-- { "RewardNum", UIBinderSetText.New(self, self.Reward02.RichTextNum)},
		-- { "ItemCount", UIBinderSetText.New(self, self.Reward01.RichTextNum)},
		-- { "bNumVisible", UIBinderSetIsVisible.New(self, self.Reward01.RichTextNum)},
		-- { "bNumVisible", UIBinderSetIsVisible.New(self, self.Reward02.RichTextNum)},

		-- { "ItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.Reward01.FImg_Icon) },
		-- { "JDIcon", UIBinderSetBrushFromAssetPath.New(self, self.Reward02.FImg_Icon) },
	}
end

function JumboCactpotGetItemView:OnDestroy()

end

function JumboCactpotGetItemView:OnShow()
	-- local Params = self.Params
	-- if nil == Params then
	-- 	return
	-- end

	-- local ViewModel = Params.Data
	-- if nil == ViewModel then
	-- 	return
	-- end

	-- self.Reward01:SetClickButtonCallback(self.Reward01, function(TargetItemView)
	-- 	ItemTipsUtil.ShowTipsByResID(ViewModel.ItemResID, self.Reward02)
	-- end)

	-- self.Reward02:SetClickButtonCallback(self.Reward02, function(TargetItemView)
	-- 	ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, false, TargetItemView)
	-- end)
end

function JumboCactpotGetItemView:OnHide()

end

function JumboCactpotGetItemView:OnRegisterUIEvent()

end

function JumboCactpotGetItemView:OnRegisterGameEvent()

end

function JumboCactpotGetItemView:OnRegisterBinder()
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

return JumboCactpotGetItemView