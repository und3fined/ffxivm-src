---
--- Author: Administrator
--- DateTime: 2024-01-09 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")


---@class BattlePassRewardShowItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RewardSlot CommRewardsSlotView
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassRewardShowItemView = LuaClass(UIView, true)

function BattlePassRewardShowItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RewardSlot = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassRewardShowItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RewardSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassRewardShowItemView:OnInit()

end

function BattlePassRewardShowItemView:OnDestroy()

end

function BattlePassRewardShowItemView:OnShow()

end

function BattlePassRewardShowItemView:OnHide()

end

function BattlePassRewardShowItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.RewardSlot.BtnClick, self.OnClickItem)
end

function BattlePassRewardShowItemView:OnRegisterGameEvent()

end

function BattlePassRewardShowItemView:OnRegisterBinder()

	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.Binders = {
		{ "LvText", UIBinderSetText.New(self, self.TextLevel)},
		{ "ItemName", UIBinderSetText.New(self, self.TextName)},
		{ "ItemNameVisible", UIBinderSetIsVisible.New(self, self.TextName)},
	}

	self:RegisterBinders(ViewModel, self.Binders)

end

function BattlePassRewardShowItemView:OnClickItem()

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.ItemID ~= nil then
		ItemTipsUtil.ShowTipsByResID(ViewModel.ItemID, self.RewardSlot)
	end
end

return BattlePassRewardShowItemView