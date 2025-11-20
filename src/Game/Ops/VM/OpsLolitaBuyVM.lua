--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-06-30 10:06:42
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-06-30 11:03:43
FilePath: \Client\Source\Script\Game\Ops\VM\OpsLolitaBuyVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ItemUtil = require("Utils/ItemUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR

---@class OpsLolitaBuyVM : UIViewModel
local OpsLolitaBuyVM = LuaClass(UIViewModel)
---Ctor
function OpsLolitaBuyVM:Ctor()
    self.TitleText = nil
    self.SubTitleText = nil
    self.SuitDataList = nil
    self.Rewards = nil
    self.PurchaseNum = nil
    self.TotalNum = nil
    self.PurchaseProgress = nil
    self.RewardStatus = nil
    self.RewardsPrice = nil
    self.MoviePath = nil
end

function OpsLolitaBuyVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    local NodeList = ActivityData.NodeList
    self.TitleText = Activity.Title
    self.SubTitleText = Activity.SubTitle

    --完成商城购买节点(5个)
    self.SuitDataList = {}
    self.PurchaseNum = 0
    local NodeID, NodeCfg
    for _, v in ipairs(NodeList) do
        if not v.Head.EmergencyShutDown then
            NodeID = v.Head.NodeID
            NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID) or {}
            if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeMallPurchased then
                local GoodsID = NodeCfg.Params and NodeCfg.Params[1]
                if GoodsID and GoodsID ~= 0 then
                    local GoodsData = _G.StoreMgr:GetProductDataByID(GoodsID)
                    if GoodsData ~= nil and GoodsData.Cfg ~= nil then
                        local GoodsItemID, ItemType = self:GetDataTypeByGoodsData(GoodsData)
                        local OriginalPrice, BuyGoodPrice, Discount = self:GetPriceByGoodsData(GoodsData)
                        local IsBuy = v.Extra.Progress.Value > 0
                        if IsBuy then
                            self.PurchaseNum = self.PurchaseNum + 1
                        end
                        self.SuitDataList[ItemType] = {
                            NodeID = NodeID,
                            GoodsID = GoodsID,
                            GoodsName = GoodsData.Cfg.Name,
                            GoodsItemID = GoodsItemID,
                            OriginalPrice = OriginalPrice,
                            BuyGoodPrice = BuyGoodPrice,
                            Discount = Discount,
                            JumpType = NodeCfg.JumpType,
                            JumpID = NodeCfg.JumpParam,
                            IsBuy = IsBuy,
                            bSelected = false
                        }
                    end
                end
            elseif NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode then
                self.RewardStatus = v.Head.RewardStatus
                self.TotalNum = NodeCfg.Target or 0
                self.Rewards = self:SaveRewardsData(NodeCfg.Rewards)
                local NodeDesc = NodeCfg.NodeDesc
                self.RewardsPrice = string.isnilorempty( NodeDesc) and "0" or NodeDesc
                self.MoviePath = NodeCfg.StrParam
            end
        end
    end
end

function OpsLolitaBuyVM:GetDataTypeByGoodsData(GoodsData)
	local CfgItems = GoodsData.Cfg.Items or {}
	local GoodsItemID = CfgItems[1] and CfgItems[1].ID
	if GoodsItemID ~= nil then 
        local Cfg = ItemCfg:FindCfgByKey(GoodsItemID)
        local ItemType = Cfg and Cfg.ItemType or 0
        return GoodsItemID, ItemType
    end
    return 0, 0
end

function OpsLolitaBuyVM:GetPriceByGoodsData(GoodsData)
    local OriginalPrice, BuyGoodPrice = 0, 0
    local GoodCfgData = GoodsData.Cfg
    local PriceData = GoodCfgData.Price[StoreDefine.PriceDefaultIndex]
    local Discount = GoodCfgData.Discount
    if not Discount then
        Discount = StoreDefine.DiscountMaxValue
    end
    if Discount <= 0 then
        Discount = StoreDefine.DiscountMaxValue - Discount
    end
    OriginalPrice = PriceData.Count
    BuyGoodPrice = math.floor(OriginalPrice * (Discount / StoreDefine.DiscountMaxValue))
    return OriginalPrice, BuyGoodPrice, Discount
end

function OpsLolitaBuyVM:GetLowestPriceGoodsID()
    local LowestPriceGoodsID, LowestPrice = 0, 0
    if self.SuitDataList ~= nil then
        for _, SuitData in pairs(self.SuitDataList) do
            local GoodsID = SuitData.GoodsID
            local BuyGoodPrice = SuitData.BuyGoodPrice
            if LowestPriceGoodsID == 0 or BuyGoodPrice < LowestPrice then
                LowestPriceGoodsID = GoodsID
                LowestPrice = BuyGoodPrice
            end
        end
    end
    return LowestPriceGoodsID
end

function OpsLolitaBuyVM:SaveRewardsData(NodeCfgRewards)
    local RewardsData = {}
    for _, value in pairs(NodeCfgRewards) do
        local ItemID = value.ItemID
        if ItemID ~= 0 then
            local LootProduce = self:GetLootProduceByItemID(ItemID) or {}
            table.insert(RewardsData, {ItemID = ItemID, LootProduce = LootProduce})
        end
    end
    return RewardsData
end

function OpsLolitaBuyVM:GetLootProduceByItemID(GoodsItemID)
	local ItemTableData = GoodsItemID and ItemCfg:FindCfgByKey(GoodsItemID)
	if ItemTableData ~= nil then
		local FuncTableData = FuncCfg:FindCfgByKey(ItemTableData.UseFunc)
		if FuncTableData ~= nil and not table.is_nil_empty(FuncTableData.Func) and not table.is_nil_empty(FuncTableData.Func[1].Value) then
			local DropMappingID = FuncTableData.Func[1].Value[1]
			local MappingTableData = LootMappingCfg:FindCfg(string.format("ID = %d", DropMappingID))
			if not table.is_nil_empty(MappingTableData.Programs) then
                return ItemUtil.GetLootItems(MappingTableData.Programs[1].ID)
			end
		end
	end
end

function OpsLolitaBuyVM:SetSuitDataByNodeID(NodeID, IsBuy)
    for _, value in pairs(self.SuitDataList) do
        if value.NodeID == NodeID then
            value.IsBuy = IsBuy
        end
    end
end

function OpsLolitaBuyVM:UpdateOnNodeChanged(NodeList)
    local NodeID, NodeCfg
    local PurchaseNum = 0
    for _, v in pairs(NodeList) do
        if not v.Head.EmergencyShutDown then
            NodeID = v.Head.NodeID
            NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID) or {}
            if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeMallPurchased then
                local IsBuy = v.Extra.Progress.Value > 0
                if IsBuy then
                    PurchaseNum = PurchaseNum + 1
                end
                self:SetSuitDataByNodeID(NodeID, IsBuy)
            elseif NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode then
                self.RewardStatus = v.Head.RewardStatus
            end
        end
    end
    self.PurchaseNum = PurchaseNum
    _G.EventMgr:SendEvent(_G.EventID.OpsLolitaNodeChanged)
end

return OpsLolitaBuyVM