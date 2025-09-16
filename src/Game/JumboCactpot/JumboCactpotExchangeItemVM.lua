---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ScoreCfg = require("TableCfg/ScoreCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local FairycolorgRankingCfg = require("TableCfg/FairycolorgRankingCfg")

local LSTR = _G.LSTR
---@class JumboCactpotExchangeItemVM : UIViewModel
local JumboCactpotExchangeItemVM = LuaClass(UIViewModel)

---Ctor
function JumboCactpotExchangeItemVM:Ctor()
    self.FText_Ranking = 1
    self.Reward1 = 	""
    self.Reward1Status = self.Reward1 ~= nil
    self.Reward1Num = 0
    self.Reward1TextStatus = self.Reward1Num ~= nil
    self.Reward2 = ""
    self.Reward2Status = self.Reward2 ~= nil
    self.Reward2Num = 0
    self.Reward2TextStatus = self.Reward2Num ~= nil
    self.FText_Status = ""
    self.FText_Miss = ""
    self.BtnStatus = false
    self.IsMountNotOwn = false
end

function JumboCactpotExchangeItemVM:OnBegin()

end

function JumboCactpotExchangeItemVM:OnInitValue(RankingLevel, Reward1ID, Reward1Num, Reward2ID, Reward2Num, TxtStatus, BtnStatus, index)
    self.FText_Ranking = RankingLevel
    local Reward1Cfg = ScoreCfg:FindCfgByKey(Reward1ID)
    if nil ~= Reward1Cfg then
        self.Reward1 = Reward1Cfg.IconName
        self.Reward1Num = Reward1Num
        self.Reward1Status = true
    else
        self.Reward1Status = false
    end
    local Reward2Cfg = ItemCfg:FindCfgByKey(Reward2ID)
    if nil ~= Reward2Cfg then
        self.Reward2 = Reward2Cfg.IconName
        self.Reward2Num = Reward2Num
        self.Reward2Status = true
    else
        self.Reward2Status = false
    end
    self.FText_Status = FairycolorgRankingCfg:FindValue(index, "RewardName")
    local TextMiss = "----"
    -- BtnStatus 无效0;未购买1;未开奖2;已开奖可兑换3;已过期4;
    if BtnStatus  == 0 then
        TextMiss = LSTR(240001) -- 未中奖
    elseif BtnStatus  == 2 then
        TextMiss = LSTR(240002) -- 未开奖
    end
    self.FText_Miss = TextMiss
    self.BtnStatus = BtnStatus == 3
end

return JumboCactpotExchangeItemVM
