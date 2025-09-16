local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")
local OpsActivityTreasureChestPanelVM = require("Game/Ops/VM/OpsActivityTreasureChestPanelVM")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsActivityPrizePoolWinVM : UIViewModel
local OpsActivityPrizePoolWinVM = LuaClass(UIViewModel)

local LSTR = _G.LSTR
---Ctor
function OpsActivityPrizePoolWinVM:Ctor()
    self.FinalRewardName = nil
    self.FinalRewardProbability = nil
    self.FinalRewardPoster = nil
    self.TextDesc = nil
    self.FinalRewardProbabilityColor = nil
    self.OwnedText = false
    self.AwardVMList = UIBindableList.New(OpsActivityRewardItemVM)
end

function OpsActivityPrizePoolWinVM:UpdatePrizePool(LotteryInfo)

    self.FinalRewardName = OpsActivityTreasureChestPanelVM.TextRewardName
    self.FinalRewardPoster = OpsActivityTreasureChestPanelVM.ImgPoster
    self.OwnedText = false
    local DrawNum = LotteryInfo.DrawNum
    local LotteryDrawWeight = LotteryInfo.LotteryDrawWeight
    local DropedID = LotteryInfo.DropedResID
	local DropedResID = {}
	for _,v in ipairs(table.array_concat(OpsActivityTreasureChestPanelVM.LotteryAwardNodes, {OpsActivityTreasureChestPanelVM.FinalAward})) do
		if table.contain(DropedID, v.ID) then
			table.insert(DropedResID, v.DropID)
		end
	end
    local TotalWeight = 0
    for _, v in ipairs(LotteryDrawWeight) do
        TotalWeight = TotalWeight + v.Weight
    end
    if DrawNum == #OpsActivityTreasureChestPanelVM.LotteryConsumeNum then
        self.TextDesc = LSTR(OpsActivityDefine.LocalStrID.OwnedAllReward)
        self.FinalRewardProbability = LSTR(OpsActivityDefine.LocalStrID.Owned)
        self.FinalRewardProbabilityColor = "828282"
        self.OwnedText = true
        for _,v in ipairs(OpsActivityTreasureChestPanelVM.LotteryAwardNodes) do
            v.IconReceivedVisible = true
            v.LotteryProbability = LSTR(OpsActivityDefine.LocalStrID.Owned)
            v.ProbabilityColor = "828282"
        end
    else
        self.TextDesc = LSTR(OpsActivityDefine.LocalStrID.NextLotteryProbality)
        for _, ResID in ipairs(DropedResID) do
            if ResID == OpsActivityTreasureChestPanelVM.FinalAward.DropID then
                self.FinalRewardProbability = LSTR(OpsActivityDefine.LocalStrID.Owned)
                self.FinalRewardProbabilityColor = "828282"
                self.OwnedText = true
            else
                for i, node in ipairs(OpsActivityTreasureChestPanelVM.LotteryAwardNodes) do
                    if node.DropID == ResID then
                        OpsActivityTreasureChestPanelVM.LotteryAwardNodes[i].IconReceivedVisible = true
                        OpsActivityTreasureChestPanelVM.LotteryAwardNodes[i].LotteryProbability = LSTR(OpsActivityDefine.LocalStrID.Owned)
                        OpsActivityTreasureChestPanelVM.LotteryAwardNodes[i].ProbabilityColor = "828282"
                        break
                    end
                end
            end
        end
        local TotalProbability = 0
        for _,v in ipairs(LotteryDrawWeight) do
            for i, node in ipairs(OpsActivityTreasureChestPanelVM.LotteryAwardNodes) do
                local ItemID = self:FindItemID(v.ResID)
                if node.DropID == ItemID then
                    local Probability = string.format("%.2f%%", v.Weight/TotalWeight*100)
                    local ProbabilityNumber = tonumber(string.match(Probability, "([%d%.]+)"))
                    OpsActivityTreasureChestPanelVM.LotteryAwardNodes[i].LotteryProbability = Probability
                    if ProbabilityNumber  == 100 then
                        OpsActivityTreasureChestPanelVM.LotteryAwardNodes[i].ProbabilityColor = "FFEEBB"
                    else
                        OpsActivityTreasureChestPanelVM.LotteryAwardNodes[i].ProbabilityColor = "d5d5d5"
                    end
                    TotalProbability = TotalProbability + ProbabilityNumber
                    break
                end
            end
        end
        for _,v in ipairs(LotteryDrawWeight) do
            if v.ResID == OpsActivityTreasureChestPanelVM.FinalAward.ID then
                local FinalRewardProbability = 100 - TotalProbability
                self.FinalRewardProbability = string.format("%.2f%%", FinalRewardProbability)
                if FinalRewardProbability == 100 then
                    self.FinalRewardProbabilityColor = "FFEEBB"
                else
                    self.FinalRewardProbabilityColor = "d5d5d5"
                end
                break
            end
        end
    end
    local LotteryAwardNodes = OpsActivityTreasureChestPanelVM.LotteryAwardNodes
    for _, LotteryAwardNode in ipairs(LotteryAwardNodes) do
        LotteryAwardNode.ItemSlotType = ItemDefine.ItemSlotType.Item126Slot
    end
    self.AwardVMList:UpdateByValues(LotteryAwardNodes)
end

function OpsActivityPrizePoolWinVM:FindItemID(ID)
    for _, node in ipairs(OpsActivityTreasureChestPanelVM.LotteryAwardNodes) do
        if node.ID == ID  then
            return node.DropID
        end
    end
end


return OpsActivityPrizePoolWinVM