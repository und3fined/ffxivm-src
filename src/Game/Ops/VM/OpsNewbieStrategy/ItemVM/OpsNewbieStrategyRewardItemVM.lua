local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeRewardType = ProtoRes.Game.ActivityNodeRewardType
local ProtoCS = require("Protocol/ProtoCS")
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsNewbieStrategyRewardItemVM : UIViewModel
local OpsNewbieStrategyRewardItemVM = LuaClass(UIViewModel)

---Ctor
function OpsNewbieStrategyRewardItemVM:Ctor()
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
end

function OpsNewbieStrategyRewardItemVM:UpdateVM(Params)

    if Params then
		self.NodeID = Params.NodeID
        self.ItemID = Params.ItemID
        self.key = Params.ItemID
        self.ItemType = Params.Type
        self.Num = Params.Num
        self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(self.ItemID, ItemDefine.ItemSlotType.Item96Slot)
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
end

function OpsNewbieStrategyRewardItemVM:UpdateProbability(LotteryProbability)
    self.LotteryProbability = LotteryProbability
end

function OpsNewbieStrategyRewardItemVM:SetRewardStatus(RewardStatus)
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

function OpsNewbieStrategyRewardItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.NodeID == self.NodeID
end

function OpsNewbieStrategyRewardItemVM:GetRewardStatus()
	return self.RewardStatus
end

function OpsNewbieStrategyRewardItemVM:GetNodeID()
	return self.NodeID
end

return OpsNewbieStrategyRewardItemVM