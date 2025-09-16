local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemUtil = require("Utils/ItemUtil")
local BagEnlargeCfg = require("TableCfg/BagEnlargeCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local LSTR = _G.LSTR
local BagMgr = _G.BagMgr
local ScoreMgr = _G.ScoreMgr
---@class BagExpandWinVM : UIViewModel
local BagExpandWinVM = LuaClass(UIViewModel)

---Ctor
function BagExpandWinVM:Ctor()
    self.BagSlotVM = BagSlotVM.New()

    self.ItemNumberText = nil
    self.NameText = nil
    self.ConsumeScoreVisible = nil
	self.CostScoreText = nil
    self.CostScoreColor = nil
    self.ScoreIconImg = nil
    self.ExpandBtnEnable = nil
    self.ScoreID = nil

    self.CurrentNum = nil
	self.EnlargeNum = nil
    self.ScoreTipsText = nil
	self.ScoreInfoVisible = nil
    self.CostPropsVisible = nil
end

function BagExpandWinVM:UpdateVM(EnlargeID)
    local CfgRow = BagEnlargeCfg:FindCfgByKey(EnlargeID)
	if CfgRow then
        self.CurrentNum = string.format(LSTR(990048), BagMgr.Capacity)
        self.EnlargeNum = string.format(LSTR(990049), CfgRow.Enlarge + BagMgr.Capacity)
        local ItemID = CfgRow.ItemID
        local ScoreID = CfgRow.ScoreID
        local ScoreNum = CfgRow.ScoreNum
        local NeedNum = CfgRow.ItemNum
        local HasNum = BagMgr:GetItemNum(ItemID)

        self.CostPropsVisible = ItemID ~= 0
        self.ScoreID = ScoreID
        self.CostScoreText = ItemID ~= 0 and (HasNum < NeedNum and (NeedNum - HasNum) * ScoreNum or 0) or ScoreNum

        local ScoreData =  ScoreCfg:FindCfgByKey(ScoreID)
        if ScoreData then
            self.ScoreIconImg = ScoreData.IconName
        end

        if ItemID == 0 then
            -- 积分
            self.ConsumeScoreVisible = true
            self.ExpandBtnEnable = true
            self.CostScoreColor = ScoreNum > ScoreMgr:GetScoreValueByID(ScoreID) and "dc5868" or "838382"

        else
            -- 道具
            local Item = ItemUtil.CreateItem(ItemID, 0)
            self.BagSlotVM:UpdateVM(Item, {IsShowNum = false})
            self.NameText = ItemUtil.GetItemName(ItemID)

            if HasNum < NeedNum then
                self.ItemNumberText = string.format("%s/%d", 
                    RichTextUtil.GetText(tostring(HasNum), "dc5868", 0, nil), 
                    NeedNum)
                self.CostScoreColor = (NeedNum - HasNum) * ScoreNum > ScoreMgr:GetScoreValueByID(ScoreID) and "dc5868" or "838382"
                self.ConsumeScoreVisible = true
                self.ExpandBtnEnable = false
            else
                self.ItemNumberText = string.format("%s/%d", 
                    RichTextUtil.GetText(tostring(HasNum), "d5d5d5", 0, nil), 
                    NeedNum)
                self.ConsumeScoreVisible = false
                self.ExpandBtnEnable = true
            end

        end
	end
end

function BagExpandWinVM:CheckConsumeScore(IsConsume)
    if IsConsume then
        self.ScoreTipsText = LSTR(990050)
        self.ScoreInfoVisible = true
        local NeedCost = self.CostScoreText
	    local ScoreID = self.ScoreID
        self.ExpandBtnEnable = NeedCost <= ScoreMgr:GetScoreValueByID(ScoreID)
    else
        self.ScoreTipsText = LSTR(990051)
        self.ScoreInfoVisible = false
        self.ExpandBtnEnable = false
    end

    if not self.CostPropsVisible then
        self.ExpandBtnEnable = true
    end
end

--要返回当前类
return BagExpandWinVM