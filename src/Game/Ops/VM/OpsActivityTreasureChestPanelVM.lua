local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local SaveKey = require("Define/SaveKey")
local ProtoRes = require("Protocol/ProtoRes")
local ItemDefine = require("Game/Item/ItemDefine")

local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local USaveMgr = _G.UE.USaveMgr

---@class OpsActivityTreasureChestPanelVM : UIViewModel
local OpsActivityTreasureChestPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsActivityTreasureChestPanelVM:Ctor()
    self.TextTitle = nil
    self.TextSubTitle = nil
    self.TextTime = nil
    self.ImgPoster = nil
    self.PurchaseNum = nil
    self.TextRewardName = nil
    self.FinalRewardNum = nil
    self.FinalRewardIcon = nil
    self.FinalRewardImgQuanlity = nil
    self.ImgKey = nil
    self.ConsumePropNum = nil
    self.DrawNum = nil
    self.FinalAwardSuitID = nil
    self.FinalAwardItemID = nil
    self.VideoNode = nil
    self.FinalRewardTips = false
    self.CheckBoxState = false
    self.AwardVMList = UIBindableList.New(OpsActivityRewardItemVM)
end

function OpsActivityTreasureChestPanelVM:Update(Params)

    local Activity = Params.Activity
    self.ActivityID = Activity.ActivityID
    self.TextTitle = Activity.Title
    self.TextSubTitle = Activity.SubTitle

    local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
    local LotteryNode = nil
    local NodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeLotteryDrawNoLayBack)
    if NodeList and #NodeList > 0 then
        local NodeID  = NodeList[1].Head.NodeID
        LotteryNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    end

    NodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypePictureShare)
    if NodeList and #NodeList > 0 then
        local NodeID  = NodeList[1].Head.NodeID
        self.ShareNode = NodeList[1]
        self.ShareNodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
    end

    NodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeExchange)
    if NodeList and #NodeList > 0 then
        local NodeID  = NodeList[1].Head.NodeID
        self.ExchangeNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    end

    NodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    if NodeList and #NodeList > 0 then
        local NodeID  = NodeList[1].Head.NodeID
        self.VideoNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    else
       self.VideoNode = nil
    end

   --[[ local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
    local ActivityNodes = ActivityNodeCfg:FindAllCfg("ActivityID = " .. self.ActivityID)
    local LotteryNode = nil
    if ActivityNodes then
        for _, v in ipairs(ActivityNodes) do
            if v.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypeLotteryDrawNoLayBack then
                LotteryNode = v
            elseif v.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypePictureShare then
                self.ShareNode = v
            elseif v.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypeExchange then
                self.ExchangeNode = v
            elseif v.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypeClientShow then
                self.VideoNode = v
            end
        end
    end]]--

    if LotteryNode ~= nil then
        self.LotteryNodeID = LotteryNode.NodeID
        local PrizePoolID = LotteryNode.Params[1]
        local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
        self.LotteryAwardNodes = CommercializationRandCfg:FindAllCfg("PrizePoolID = "..PrizePoolID)
        if self.LotteryAwardNodes then
            table.sort(self.LotteryAwardNodes, function(node1,node2)
            return node1.DropWeight < node2.DropWeight
            end)
            self.FinalAward = self.LotteryAwardNodes[1]
            self.FinalAwardItemID = self.FinalAward.DropID
            self.FinalAwardSuitID = self.FinalAward.PreviewID
            self.ImgPoster = self.FinalAward.ImgPoster
            self.TextRewardName = ItemUtil.GetItemName(self.FinalAwardItemID)
            local OrdinaryPrizes = self.LotteryAwardNodes
            table.remove(OrdinaryPrizes,1)
            for _, OrdinaryPrize in ipairs(OrdinaryPrizes) do
                OrdinaryPrize.ItemSlotType = ItemDefine.ItemSlotType.Item96Slot
            end
            self.AwardVMList:UpdateByValues(OrdinaryPrizes)
            local CommercializationRandConsumeCfg = require("TableCfg/CommercializationRandConsumeCfg")
            local LotteryCousumeNode = CommercializationRandConsumeCfg:FindCfg("PoolID = "..PrizePoolID)
            if LotteryCousumeNode then
                self.LotteryPropID = LotteryCousumeNode.ConsumeResID
                self.ImgKey = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.LotteryPropID))
                self.LotteryConsumeNum = LotteryCousumeNode.ConsumeResNum
            end
        end
    end

    local SkipAnimation = USaveMgr.GetInt(SaveKey.OpsSkipAnimation, 0, true)
    self.CheckBoxState = SkipAnimation == self.ActivityID
end

function OpsActivityTreasureChestPanelVM:SetFinalRewardTips(ItemID, ItemNum)
    self.FinalRewardNum = ItemNum
    self.FinalRewardIcon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ItemID))
    self.FinalRewardImgQuanlity = ItemUtil.GetItemColorIcon(ItemID)
end


return OpsActivityTreasureChestPanelVM