---
--- Author: yutingzhan
--- DateTime: 2025-08-27 14:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemDefine = require("Game/Item/ItemDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class OpsGirlsDayAwardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm74Slot1 CommBackpack74SlotView
---@field Comm74Slot2 CommBackpack74SlotView
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsGirlsDayAwardItemView = LuaClass(UIView, true)

function OpsGirlsDayAwardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm74Slot1 = nil
	--self.Comm74Slot2 = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayAwardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm74Slot1)
	self:AddSubView(self.Comm74Slot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayAwardItemView:OnInit()

end

function OpsGirlsDayAwardItemView:OnDestroy()

end

function OpsGirlsDayAwardItemView:OnShow()

end

function OpsGirlsDayAwardItemView:OnHide()

end

function OpsGirlsDayAwardItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Comm74Slot1.Btn, self.OnClickReward1)
	UIUtil.AddOnClickedEvent(self, self.Comm74Slot2.Btn, self.OnClickReward2)
end

function OpsGirlsDayAwardItemView:OnClickReward1()
	if self.Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		_G.OpsActivityMgr:SendActivityNodeGetReward(self.Node.Head.NodeID)
	else
		ItemTipsUtil.ShowTipsByResID(self.Reward1ItemID, self.Comm74Slot1, nil, nil, 30)
	end
end

function OpsGirlsDayAwardItemView:OnClickReward2()
	if self.Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		_G.OpsActivityMgr:SendActivityNodeGetReward(self.Node.Head.NodeID)
	else
		ItemTipsUtil.ShowTipsByResID(self.Reward2ItemID, self.Comm74Slot2, nil, nil, 30)
	end
end


function OpsGirlsDayAwardItemView:OnRegisterGameEvent()
end

function OpsGirlsDayAwardItemView:OnRegisterBinder()

end

function OpsGirlsDayAwardItemView:UpdateRewardStatus(Node)
	local RewardStatus = Node.Head.RewardStatus
	local Slots = { self.Comm74Slot1, self.Comm74Slot2 }
	local StatusConfig = {
		[ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet] = { PanelAvailable = true, IconReceived = false, MaskVisible = false },
		[ProtoCS.Game.Activity.RewardStatus.RewardStatusDone] = { PanelAvailable = false, IconReceived = true, MaskVisible = true },
		[ProtoCS.Game.Activity.RewardStatus.RewardStatusNo] = { PanelAvailable = false, IconReceived = false, MaskVisible = false }
	}

	local Config = StatusConfig[RewardStatus]
	if Config then
		for _, Slot in ipairs(Slots) do
			UIUtil.SetIsVisible(Slot.PanelAvailable, Config.PanelAvailable)
			UIUtil.SetIsVisible(Slot.IconReceived, Config.IconReceived)
			UIUtil.SetIsVisible(Slot.ImgMask, Config.MaskVisible)
		end
	end
	self.Node = Node
end

function OpsGirlsDayAwardItemView:SetRewardItem(NodeCfg)
	local Rewards = NodeCfg.Rewards
	self.Reward1ItemID = Rewards[1].ItemID
	self.Reward2ItemID = Rewards[2].ItemID
	self:SetSlotItem(Rewards[1], self.Comm74Slot1)
	self:SetSlotItem(Rewards[2], self.Comm74Slot2)
	self.TextQuantity:SetText(NodeCfg.Params[1])
end

function OpsGirlsDayAwardItemView:SetSlotItem(Reward, Slot)
	local ItemQualityIcon = ItemUtil.GetSlotColorIcon(Reward.ItemID, ItemDefine.ItemSlotType.Item74Slot)

	local Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Reward.ItemID))
	local Num = _G.ScoreMgr.FormatScore(Reward.Num)
	local BtnCheckVisible = ItemUtil.IsCanPreviewByResID(Reward.ItemID)
	UIUtil.SetIsVisible(Slot.IconChoose, false)
	UIUtil.SetIsVisible(Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(Slot.BtnCheck, BtnCheckVisible)

	Slot:SetIconImg(Icon)
	Slot:SetQualityImg(ItemQualityIcon)
	Slot:SetNum(Num)

end

return OpsGirlsDayAwardItemView