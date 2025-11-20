local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local UIBindableList = require("UI/UIBindableList")
local OpsTeamUpRewardItemVM = require("Game/Ops/VM/OpsTeamUp/ItemVM/OpsTeamUpRewardItemVM")
local OpsTeamUpDefine = require("Game/Ops/OpsTeamUp/OpsTeamUpDefine")


---@class OpsTeamUpTreasureChestItemVM : UIViewModel
local OpsTeamUpTreasureChestItemVM = LuaClass(UIViewModel)

---Ctor
function OpsTeamUpTreasureChestItemVM:Ctor()
	self.NodeID = nil
	self.Title = nil
	self.RewardItemVMList = UIBindableList.New(OpsTeamUpRewardItemVM)
	self.bGoldChestEffect = nil
end

---后续如果做成列表item就用这个
function OpsTeamUpTreasureChestItemVM:UpdateVM(Params)
    if Params then
		self.NodeID = Params.NodeID
		if self.NodeID then
			self:SetVMData(self.NodeID)
		end
    end
end

function OpsTeamUpTreasureChestItemVM:SetVMData(NodeID)
    if NodeID then
		self.NodeID = NodeID
		local CfgData = ActivityNodeCfg:FindCfgByKey(self.NodeID)
		if CfgData then
			self.Title = CfgData.NodeTitle
			local Rewards = {}
			for _, Value in ipairs(CfgData.Rewards) do
				if Value.ItemID ~= 0 then
					local Reward = {}
					Reward.ItemID = Value.ItemID
					Reward.Type = Value.Type
					Reward.Num = Value.Num
					table.insert(Rewards, Reward)
				end
			end
			self.RewardItemVMList:UpdateByValues(Rewards)
		end
		---特效显示
		self.bGoldChestEffect = NodeID == OpsTeamUpDefine.GoldRewardNodeID 
    end
end

function OpsTeamUpTreasureChestItemVM:UpdateProbability(LotteryProbability)
    self.LotteryProbability = LotteryProbability
end

function OpsTeamUpTreasureChestItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.NodeID == self.NodeID
end

function OpsTeamUpTreasureChestItemVM:GetNodeID()
	return self.NodeID
end

return OpsTeamUpTreasureChestItemVM