---
---@Author: ZhengJanChuan
---@Date: 2024-01-18 17:14:16
---@Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local RichTextUtil = require("Utils/RichTextUtil")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local BattlepassLevelRewardCfg = require("TableCfg/BattlepassLevelRewardCfg")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local ItemVM = require("Game/Item/ItemVM")
local BattlePassLevelRewardItemVM = require("Game/BattlePass/VM/Item/BattlePassLevelRewardItemVM")
local BattlePassBuyLevelWinVM = LuaClass(UIViewModel)

local ProtoRes = require("Protocol/ProtoRes")
local WarningColor = "#F5514F"
local NormalColor = "#D5D5D5"

---Ctor
function BattlePassBuyLevelWinVM:Ctor()
    self.TipsText = ""
    self.CurLvText = ""
    self.PriceText = ""
    self.PriceIcon = ""
    self.ItemList = {}
    self.LevelRewardList = UIBindableList.New(BattlePassLevelRewardItemVM)
    self.PriceTextColor = NormalColor
end

function BattlePassBuyLevelWinVM:OnInit()
end

function BattlePassBuyLevelWinVM:OnBegin()
    self.LevelRewardList:Clear()
end

function BattlePassBuyLevelWinVM:OnEnd()
    self.LevelRewardList:Clear()
end 

function BattlePassBuyLevelWinVM:OnShutdown()
end

function BattlePassBuyLevelWinVM:UpdateLevelRewardList(CurLevel, EndLevel, Dir)
    -- 递增
    if Dir > 0 then
        local Length =  self.LevelRewardList:Length()
        local ItemData = self.LevelRewardList:Get(Length)
        local StartLv = ItemData ~= nil and ItemData.BPLevel or CurLevel
        local End = EndLevel - StartLv
        local Grade = BattlePassMgr:GetBattlePassGrade()

        for i = 1, End, 1 do
            for _, v in ipairs(self.ItemList) do
                if v.Level == StartLv + i then
                    if Grade >= v.Grade then
                        if v.Grade == BattlePassDefine.GradeType.Basic then
                            if not BattlePassMgr:GotLevelReward(v.Level, BattlePassDefine.GradeType.Basic) then
                                self.LevelRewardList:AddByValue(v)
                            end
                        end
    
                        if v.Grade == BattlePassDefine.GradeType.Middle then
                            if not BattlePassMgr:GotLevelReward(v.Level, BattlePassDefine.GradeType.Middle) then
                                self.LevelRewardList:AddByValue(v)
                            end
                        end
                    end
                end
            end
        end
    elseif  Dir < 0  then
        for i = self.LevelRewardList:Length(), 1 , -1 do
            local ItemData = self.LevelRewardList:Get(i)
            if ItemData ~= nil and EndLevel < ItemData.BPLevel then
                self.LevelRewardList:RemoveAt(i)
            end
        end
    end


end

 
function BattlePassBuyLevelWinVM:InitLevelRewardList()
    local GroupID = BattlePassMgr:GetBattlePassGroupID()
    local Cfgs = BattlepassLevelRewardCfg:FindCfgsByGroupID(GroupID)
    self.ItemList = {}

    for _, v in ipairs(Cfgs) do
        for index, value in ipairs(v.BasicReward) do
            if value.ID ~= 0 then
                local Item = ItemUtil.CreateItem(value.ID, value.Num)
                Item.Level = v.Level
                Item.Grade = BattlePassDefine.GradeType.Basic
                table.insert(self.ItemList, Item)
            end
        end

        for index, value in ipairs(v.MiddleReward) do
            if value.ID ~= 0 then
                local Item = ItemUtil.CreateItem(value.ID, value.Num)
                Item.Level = v.Level
                Item.Grade = BattlePassDefine.GradeType.Middle
                table.insert(self.ItemList, Item)
            end
        end
    end

end

function BattlePassBuyLevelWinVM:SetBuyLevelWin(Level)
    self.CurLvText = tostring(Level)
    local CurLevel = BattlePassMgr:GetBattlePassLevel()
    local LastLevel = CurLevel + Level

    -- self:UpdateLevelRewardList(CurLevel, LastLevel)
    self.TipsText = string.format(_G.LSTR(850005), string.format(LastLevel), "")  -- 购买后升级至%s级

end

function BattlePassBuyLevelWinVM:SetBuyLevelPrice(Level)
    local StartLevel = BattlePassMgr:GetBattlePassLevel()
    local EndLevel = StartLevel + Level
    local GroupID = BattlePassMgr:GetBattlePassGroupID()
    local Cfgs = BattlepassLevelRewardCfg:FindCfgsByGroupID(GroupID)

    local Price = 0
    for _, v in ipairs(Cfgs) do
        if v.Level > StartLevel and v.Level <= EndLevel then
            Price = Price + v.Price
        end
    end

    self.PriceText = ScoreMgr.FormatScore(Price)
    self.PriceTextColor = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS) >= Price and NormalColor or WarningColor

    return ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS) >= Price
    
end

return BattlePassBuyLevelWinVM
