local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local BagMgr = require("Game/Bag/BagMgr")
local OpsActivityTreasureChestPanelVM = require("Game/Ops/VM/OpsActivityTreasureChestPanelVM")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")

local LSTR = _G.LSTR

---@class OpsActivityTreasureChestBuyItemWinVM : UIViewModel
local OpsActivityTreasureChestBuyItemWinVM = LuaClass(UIViewModel)

---Ctor
function OpsActivityTreasureChestBuyItemWinVM:Ctor()

    self.FreeImgQuality = nil
    self.FreeImgIcon = nil
    self.FreeSlotNum = nil
    self.FreeSlotName = nil
    self.PropsImgQuality = nil
    self.PropsImgIcon = nil
    self.PropsSlotNum = nil
    self.PropsSlotName = nil
    self.PurchaseAmount = nil
    self.PurchaseNumDesc = nil
    self.RemainPurchaseAmount = nil
    self.Price = nil
    self.Title = nil
    self.PriceColor = nil
    self.PurchaseDesc = nil
    self.FreePerNum = nil
    self.PropsPerNum = nil
end

function OpsActivityTreasureChestBuyItemWinVM:SetTreasureChestBuyWinInfo()
    local ExchangeNode = OpsActivityTreasureChestPanelVM.ExchangeNode
    if ExchangeNode == nil then
       return
    end
    if ExchangeNode.Rewards then
        self.Title = ExchangeNode.NodeTitle
        self.PropsSlotResID = ExchangeNode.Rewards[2].ItemID
        self.PropsPerNum = ExchangeNode.Rewards[2].Num
        -- 赠送的抽奖道具
        self.FreeSlotResID = ExchangeNode.Rewards[1].ItemID
        -- 单次购买的抽奖道具数量
        self.FreePerNum = ExchangeNode.Rewards[2].Num
        self.SinglePrice = ExchangeNode.Params[2]
        self.ScoreID = ExchangeNode.Params[1]
    end

    self.PropsSlotName = ItemUtil.GetItemName(self.PropsSlotResID)
    self.FreeSlotName = ItemUtil.GetItemName(self.FreeSlotResID)
    self.PropsImgQuality = ItemUtil.GetItemColorIcon(self.PropsSlotResID)
    self.FreeImgQuality = ItemUtil.GetItemColorIcon(self.FreeSlotResID)
    self.PropsImgIcon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.PropsSlotResID))
    self.FreeImgIcon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.FreeSlotResID))

    local desc1 = RichTextUtil.GetText(string.format("%s×%d", self.PropsSlotName, self.PropsPerNum), "d1ba8e", 0, nil)
    local desc2 = RichTextUtil.GetText(string.format("%s×%d", self.FreeSlotName, self.FreePerNum), "d1ba8e", 0, nil)
    self.PurchaseDesc = string.format(ExchangeNode.NodeDesc, desc1, desc2)

end

function OpsActivityTreasureChestBuyItemWinVM:UpdateTreasureChestBuyWinInfo()
    if OpsActivityTreasureChestPanelVM.LotteryConsumeNum ~= nil then
        -- 当前道具数量
        local CurrentPropNum = BagMgr:GetItemNum(self.FreeSlotResID)
        -- 总可购买次数
        local TotaolPurchaseAmount = OpsActivityTreasureChestPanelVM.ExchangeNode.Target
        -- 剩余可购次数
        self.RemainPurchaseAmount = TotaolPurchaseAmount - OpsActivityTreasureChestPanelVM.PurchaseNum
        self.PurchaseNumDesc = string.format(LSTR(OpsActivityDefine.LocalStrID.LeftToPurchase) ,self.RemainPurchaseAmount, TotaolPurchaseAmount)
        -- 本抽所需的抽奖道具数
        local LotteryPropNum = OpsActivityTreasureChestPanelVM.LotteryConsumeNum[OpsActivityTreasureChestPanelVM.DrawNum + 1] or 0
        if CurrentPropNum >= LotteryPropNum then
            self.PurchaseAmount = 1
        else
            self.PurchaseAmount = math.ceil((LotteryPropNum - CurrentPropNum) /  self.FreePerNum )
        end
        self:SetPurchasePrice(self.PurchaseAmount)
    end
end

function OpsActivityTreasureChestBuyItemWinVM:SetPurchasePrice(Value)
    local ScoreValue = ScoreMgr:GetScoreValueByID(self.ScoreID)
    local Price = Value * self.SinglePrice
    self.Price = ScoreMgr.FormatScore(Price)
    self.PurchaseAmount = Value
    self.PropsSlotNum = self.PropsPerNum*self.PurchaseAmount
    self.FreeSlotNum = self.FreePerNum*self.PurchaseAmount
    if ScoreValue < Price then
        self.PriceColor = "dc5868"
        self.CanBuy = false
    else
        self.PriceColor = "D2BA8E"
        self.CanBuy = true
    end
end

return OpsActivityTreasureChestBuyItemWinVM