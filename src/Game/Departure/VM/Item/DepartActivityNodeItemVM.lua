--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:启程活动节点ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")

---@class DepartActivityNodeItemVM : UIViewModel
local DepartActivityNodeItemVM = LuaClass(UIViewModel)

function DepartActivityNodeItemVM:Ctor()
    self.NodeID = 0 -- 节点ID
    self.RewardID = 0 -- 奖励ID
    self.RewardNum = 0 -- 奖励数量
    self.RewardIcon = ""
    self.IsGetProgress = false -- 是否达成
    self.IsGetReward = false -- 是否已领奖
    self.TargetNum = 0 -- 目标达成数量
    self.RewardStatus = 0 -- 奖励领取状态 0:不可领取 1:可领取，未领取 2:已领取
    self.BtnCheckVisible = false
end


function DepartActivityNodeItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.NodeID == self.NodeID
end
 
function DepartActivityNodeItemVM:UpdateVM(Value)
    self.NodeID = Value.NodeID 
    local NodeInfo = DepartOfLightVMUtils.GetActivityNodeDetail(self.NodeID)
    if NodeInfo == nil then
        return
    end
    local Rewards = NodeInfo.Rewards
    if Rewards and #Rewards > 0 then
        local Reward = Rewards[1]
        self.RewardID = Reward.ItemID
        self.RewardNum = Reward.Num
        local Cfg = ItemCfg:FindCfgByKey(self.RewardID)
        if nil ~= Cfg then
            self.RewardIcon = UIUtil.GetIconPath(Cfg.IconID)
        end
        self.ItemQualityIcon = ItemUtil.GetItemColorIcon(self.RewardID)
    end
    self.BtnCheckVisible = ItemUtil.IsCanPreviewByResID(self.RewardID) and self.RewardID ~= 62201152 -- 武器外观有问题
    self.RewardStatus = Value.RewardStatus
    self.IsGetProgress = Value.Finished
    self.TargetNum = NodeInfo.Target
end

return DepartActivityNodeItemVM