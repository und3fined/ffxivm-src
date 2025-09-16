---
--- Author: Administrator
--- DateTime: 2023-12-25 20:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class LeveQuestProps74pxItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm74Slot CommBackpack74SlotView
---@field TextPercentage URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LeveQuestProps74pxItemView = LuaClass(UIView, true)

function LeveQuestProps74pxItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm74Slot = nil
	--self.TextPercentage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LeveQuestProps74pxItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LeveQuestProps74pxItemView:OnInit()

	self.Binders = {
		{"TextPer", UIBinderSetText.New(self, self.TextPercentage)},
		{"TextPerVisible", UIBinderSetIsVisible.New(self, self.TextPercentage)},
		{"LevelVisible", UIBinderSetIsVisible.New(self, self.Comm74Slot.RichTextLevel)},
	}

	self.Comm74Slot:SetClickButtonCallback(self, self.OnLeveQuestItemClicked)

end

function LeveQuestProps74pxItemView:OnDestroy()

end

function LeveQuestProps74pxItemView:OnShow()

end

function LeveQuestProps74pxItemView:OnHide()

end

function LeveQuestProps74pxItemView:OnRegisterUIEvent()

end

function LeveQuestProps74pxItemView:OnRegisterGameEvent()

end

function LeveQuestProps74pxItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.Comm74Slot:SetParams({Data = ViewModel.ItemVM})
end

function LeveQuestProps74pxItemView:OnLeveQuestItemClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	
	if ViewModel.ItemID ~= nil then
		if ItemUtil.ItemIsScore(ViewModel.ItemID) then
			ItemTipsUtil.CurrencyTips(ViewModel.ItemID, false, self, _G.UE4.FVector2D(0, 0))
		elseif ViewModel.ItemData ~= nil and ViewModel.ItemData.ItemNum ~= nil then
			if ViewModel.ItemID ~= 0 then
				local Item = ItemUtil.CreateItem(ViewModel.ItemID)
				local ItemNum = ViewModel.ItemData.ItemNum
				local PropHaveNumber = ViewModel.IsHQ and _G.BagMgr:GetItemHQNum(ViewModel.ItemID) or _G.BagMgr:GetItemNumWithHQ(ViewModel.ItemID)                                      
				Item.NeedBuyNum = ItemNum - PropHaveNumber
				ItemTipsUtil.ShowTipsByItem(Item, self, _G.UE4.FVector2D(0, 0))
			end
		else
			ItemTipsUtil.ShowTipsByResID(ViewModel.ItemID, self, _G.UE4.FVector2D(0, 0))
		end
	end
end

return LeveQuestProps74pxItemView