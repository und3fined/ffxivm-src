local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemUtil = require("Utils/ItemUtil")
local DepotEnlargeCfg = require("TableCfg/DepotEnlargeCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local UIBindableList = require("UI/UIBindableList")
local DepotLogoItemVM = require("Game/NewBag/VM/DepotLogoItemVM")
local DepotConfig = require("Game/Depot/DepotConfig")
local BagMgr = _G.BagMgr
local ScoreMgr = _G.ScoreMgr
---@class DepotExpandWinVM : UIViewModel
local DepotExpandWinVM = LuaClass(UIViewModel)

---Ctor
function DepotExpandWinVM:Ctor()
    self.DepotIconBindableList = UIBindableList.New(DepotLogoItemVM)
	self.CurrentIndex = 1

	self.CostScoreText = nil
    self.CostScoreColor = nil
    self.ScoreIconImg = nil
    self.ScoreID = nil
end

function DepotExpandWinVM:UpdateIconList()
    self.DepotIconBindableList:UpdateByValues(DepotConfig.DepotIconConfig)
end

function DepotExpandWinVM:SetSelectedIcon(Index)
	self.CurrentIndex = Index
end

function DepotExpandWinVM:UpdateVM(EnlargeID)
    local CfgRow = DepotEnlargeCfg:FindCfgByKey(EnlargeID)
	if CfgRow then
        local NeedCost = CfgRow.ItemNum * CfgRow.ScoreNum
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

--要返回当前类
return DepotExpandWinVM