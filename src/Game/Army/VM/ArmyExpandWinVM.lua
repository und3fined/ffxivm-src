local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDepotSlotVM = require("Game/Army/ItemVM/ArmyDepotSlotVM")
local ItemUtil = require("Utils/ItemUtil")
local GroupStoreEnlargeCfg = require("TableCfg/GroupStoreEnlargeCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local LSTR = _G.LSTR
local BagMgr = _G.BagMgr
local ScoreMgr = _G.ScoreMgr
---@class ArmyExpandWinVM : UIViewModel
local ArmyExpandWinVM = LuaClass(UIViewModel)

---Ctor
function ArmyExpandWinVM:Ctor()
    self.ArmyDepotSlotVM = ArmyDepotSlotVM.New()

    self.ItemNumberText = nil
    self.NameText = nil
    self.EnlargeTitleText = nil
    self.ConsumeScoreVisible = nil
    self.LackCheckBoxVisible = nil
	self.CostScoreText = nil
    self.CostScoreColor = nil
    self.ScoreIconImg = nil
    self.ExpandBtnEnable = nil
    self.ScoreID = nil
    self.StoreID = nil
end

function ArmyExpandWinVM:UpdateVM(EnlargeID, StoreID)
    self.StoreID = StoreID
    local CfgRow = GroupStoreEnlargeCfg:FindCfgByKey(EnlargeID)
	if CfgRow then
        --扩充格子数量
        local EnlargeRichText = RichTextUtil.GetText(string.format("%d", CfgRow.Enlarge), "89bd88", 0, nil)
        -- LSTR string:扩容%s格仓库
        self.EnlargeTitleText = string.format(LSTR(910131), EnlargeRichText)

         --道具
         local ItemID = CfgRow.ItemID
         local Item = ItemUtil.CreateItem(ItemID, 0)
         self.ArmyDepotSlotVM:UpdateVM(Item, {IsShowNum = false})
         local HasNum = BagMgr:GetItemNum(ItemID)
         local NeedNum = CfgRow.ItemNum
         local NeedCost = 0
         if HasNum < NeedNum then
            local ItemRichText = RichTextUtil.GetText(string.format("%d", HasNum), "dc5868", 0, nil)
            self.ItemNumberText = string.format("%s/%d", ItemRichText, NeedNum)
            self.LackCheckBoxVisible = true
            self.ConsumeScoreVisible = false
            NeedCost = (NeedNum - HasNum)*CfgRow.ScoreNum
            self.ExpandBtnEnable = false
         else
            local ItemRichText = RichTextUtil.GetText(string.format("%d", HasNum), "d5d5d5", 0, nil)
            self.ItemNumberText = string.format("%s/%d", ItemRichText, NeedNum)
            self.LackCheckBoxVisible = false
            self.ConsumeScoreVisible = false
            self.ExpandBtnEnable = true
         end
         self.NameText = ItemUtil.GetItemName(ItemID)

        --积分
        local ScoreID = CfgRow.ScoreID
        self.ScoreID = ScoreID
        self.CostScoreText = NeedCost
        if NeedCost > ScoreMgr:GetScoreValueByID(ScoreID) then
            self.CostScoreColor = "dc5868"
        else
            self.CostScoreColor = "838382"
        end
        local ScoreData =  ScoreCfg:FindCfgByKey(ScoreID)
        if ScoreData then
            self.ScoreIconImg = ScoreData.IconName
        end
	end
end

function ArmyExpandWinVM:SetConsumeItem()
    self.LackCheckBoxVisible = true
    self.ConsumeScoreVisible = false
    self.ExpandBtnEnable = false
end

function ArmyExpandWinVM:SetConsumeScore()
    self.ConsumeScoreVisible = true
    self.LackCheckBoxVisible = false
    self.ExpandBtnEnable = true
end


--要返回当前类
return ArmyExpandWinVM