--[[
Author: jususchen jususchen@tencent.com
Date: 2025-08-01 17:05:02
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-08-04 14:18:49
FilePath: \Script\Game\Ops\VM\OpsMoggleCollect\OpsMoggleCollectRewardItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeRewardType = ProtoRes.Game.ActivityNodeRewardType
local ProtoCS = require("Protocol/ProtoCS")
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsMoggleCollectRewardItemVM: UIViewModel
local OpsMoggleCollectRewardItemVM = LuaClass(UIViewModel)

function OpsMoggleCollectRewardItemVM:Ctor()
    self.key = nil
    self.Icon = nil
    self.ItemQualityIcon = nil
    self.Num = nil
    self.ItemID = nil
    self.LotteryProbability = nil
    self.HideItemLevel = true
    self.IconChooseVisible = false
    self.IconReceivedVisible = false
	self.IsSelect = false
	self.IsMask = false
	self.RewardStatus = nil
	self.NodeID = nil
	self.IsReward = nil
	self.Name = nil
end

function OpsMoggleCollectRewardItemVM:UpdateVM(Params)
	if not Params then
		return
	end

	self.NodeID = Params.NodeID
	self.ItemID = Params.ItemID
	self.key = Params.ItemID
	self.ItemType = Params.Type
	self.Num = Params.Num
	self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(self.ItemID, ItemDefine.ItemSlotType.Item96Slot)
	self.Name = ItemUtil.GetItemName(Params.ItemID)
	if self.ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeItem then
		--道具
		self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.ItemID))
	elseif self.ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeScore then
		--货币
		self.Icon = _G.ScoreMgr:GetScoreIconName(self.ItemID)
		self.Num = _G.ScoreMgr.FormatScore(self.Num)
	elseif self.ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeLoot then
		--掉落(掉落配置有多个item,只显示第一个做容错处理，策划确认不会配置掉落)
		local RewardItemList = ItemUtil.GetLootItems(self.ItemID)	
		if RewardItemList and #RewardItemList > 0 then
			self.ItemID = RewardItemList[1].ResID
			if RewardItemList[1].IsScore then
				self.Icon = _G.ScoreMgr:GetScoreIconName(self.ItemID)
			else
				self.Icon = ItemUtil.GetItemIcon(self.ItemID)
			end
			self.Num = RewardItemList[1].Num
		end
	end
	self:SetRewardStatus(Params.RewardStatus)
end

function OpsMoggleCollectRewardItemVM:UpdateProbability(LotteryProbability)
    self.LotteryProbability = LotteryProbability
end

function OpsMoggleCollectRewardItemVM:SetRewardStatus(RewardStatus)
	self.RewardStatus = RewardStatus
	if RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		self.IconReceivedVisible = false
		self.IsReward = false
		self.IsMask = false
	elseif RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		self.IconReceivedVisible = false
		self.IsReward = true
		self.IsMask = false
	elseif RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		self.IconReceivedVisible = true
		self.IsReward = false
		self.IsMask = true
	end
end

function OpsMoggleCollectRewardItemVM:GetRewardStatus()
	return self.RewardStatus
end

function OpsMoggleCollectRewardItemVM:GetNodeID()
	return self.NodeID
end


return OpsMoggleCollectRewardItemVM