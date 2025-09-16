--
-- Author: ZhengJanChuan
-- Date: 2024-01-18 20:08
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIBindableList = require("UI/UIBindableList")
local BattlepassBigrewardCfg = require("TableCfg/BattlepassBigrewardCfg")
local BattepassSeasonCfg = require("TableCfg/BattepassSeasonCfg")
local BattlePassAdvanceListItemVM = require("Game/BattlePass/VM/Item/BattlePassAdvanceListItemVM")
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local BagMgr = require("Game/Bag/BagMgr")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local LSTR = _G.LSTR

---@class BattlePassAdvanceVM : UIViewModel
local BattlePassAdvanceVM = LuaClass(UIViewModel)

---Ctor
function BattlePassAdvanceVM:Ctor()
    self.BigRewardList = UIBindableList.New(BattlePassAdvanceListItemVM)
    self.BigRewardList2 = UIBindableList.New(BattlePassAdvanceListItemVM)
    self.Privilege1 = ""
    self.Privilege2 = ""
    self.Privilege3 = ""
    self.FormerPrice1Text = ""
    self.FormerPrice2Text = ""
    self.GrandPrizeName = ""
    self.GrandPrizeImg = nil
    self.GrandPrizeID = nil
    self.GrandPrizeJumpID = nil
    self.DeluxeRewardName = ""
    self.DeluxeRewardImg = nil
    self.BattlePassState = BattlePassDefine.GradeType.Basic
end

function BattlePassAdvanceVM:OnInit()
end

function BattlePassAdvanceVM:OnBegin()
end

function BattlePassAdvanceVM:OnEnd()
end

function BattlePassAdvanceVM:OnShutdown()
end

function BattlePassAdvanceVM:UpdateVM()
    self:UpdateBaseInfo()
    self:UpdateRewardList()
end

function BattlePassAdvanceVM:UpdateRewardList()
    local GroupID = BattlePassMgr:GetBattlePassGroupID()
    local Cfgs = BattlepassBigrewardCfg:FindCfgsByGroupID(GroupID)

    local SeasonID = BattlePassMgr:GetSeasonID()

    local SeasonCfg = BattepassSeasonCfg:FindCfgByKey(SeasonID)

    if Cfgs == nil then
        return
    end

    if SeasonCfg == nil then
        return
    end

    local ItemList = {}
    local ItemList2 = {}

    --开通至臻立即获得的道具
    for _, v in ipairs(SeasonCfg.UltimateReward) do
        if v.ID ~= 0 then
            local Temp = {}
            Temp.ResID = v.ID
            Temp.Num = v.Num
            Temp.ItemVM = ItemUtil.CreateItem(v.ID, v.Num)
            Temp.IsShowLevel = false
            Temp.Level = 1
            Temp.IsGetNow = true
            table.insert(ItemList2, Temp)
        end
    end

    for index, v in ipairs(Cfgs) do
        local Temp = {}
        Temp.ResID = v.ItemID
        Temp.Num = v.Num
        Temp.ItemVM = ItemUtil.CreateItem(v.ItemID, v.Num)
        Temp.IsGetNow = false
        Temp.IsShowLevel = true
        Temp.Level = v.Level
        Temp.JumpID = v.ItemType == 4 and v.SuitID or nil
        table.insert(ItemList, Temp)
        table.insert(ItemList2, Temp)
    end
    self.BigRewardList:UpdateByValues(ItemList)
    self.BigRewardList2:UpdateByValues(ItemList2)
end

function BattlePassAdvanceVM:UpdatePrivilegeList()
    local SeasonID = BattlePassMgr:GetSeasonID()

    local Cfgs = BattepassSeasonCfg:FindCfgByKey(SeasonID)
    if Cfgs == nil then
        return
    end

    self.Privilege1 = string.format(string.format("%s", _G.LSTR(850007)), Cfgs.UltimateRewardLevel) -- %d战令等级
    self.Privilege2 = string.format("%s", Cfgs.UltimatePermissionShow)
    self.Privilege3 = string.format("%s", _G.LSTR(850040))
end

function BattlePassAdvanceVM:UpdateBaseInfo()
    local SeasonID = BattlePassMgr:GetSeasonID()

    local Cfg = BattepassSeasonCfg:FindCfgByKey(SeasonID)
    if Cfg == nil then
        return
    end
    self.BattlePassState = BattlePassMgr:GetBattlePassGrade()
    if  self.BattlePassState >  BattlePassDefine.GradeType.Basic then
        self.FormerPrice1Text =  _G.LSTR(850028) -- 已购买
    else
        self.FormerPrice1Text = string.format("￥ %d", tonumber(Cfg.BasicToMiddlePrice)) 
    end

    if self.BattlePassState >  BattlePassDefine.GradeType.Middle then
        self.FormerPrice2Text =  _G.LSTR(850028) -- 已购买
    else
        self.FormerPrice2Text =  string.format("￥ %d", BattlePassMgr:GetBattlePassGrade() >  BattlePassDefine.GradeType.Basic and tonumber(Cfg.MiddleToUltimatePrice)  or tonumber(Cfg.BasicToUltimatePrice))
    end
    self.DeluxeRewardImg = Cfg.BestRewardBG
    self.GrandPrizeImg = Cfg.UpgradeBG
    self.DeluxeRewardName = ItemUtil.GetItemName(Cfg.UltimateRewardItem)

    local GroupID = BattlePassMgr:GetBattlePassGroupID()
    local Cfgs = BattlepassBigrewardCfg:FindCfgsByGroupID(GroupID)
    local Len = table.length(Cfgs)
    local LastPrizeCfg = Cfgs[Len]
    if LastPrizeCfg ~= nil then
        self.GrandPrizeID = LastPrizeCfg.ItemID
        self.GrandPrizeJumpID = LastPrizeCfg.ItemID
        if LastPrizeCfg.ItemType == 4 then
            self.GrandPrizeJumpID = LastPrizeCfg.SuitID
        end
        self.GrandPrizeName = ItemUtil.GetItemName(LastPrizeCfg.ItemID)
    end

end


--要返回当前类
return BattlePassAdvanceVM