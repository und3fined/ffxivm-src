--[[
Author: v_hggzhang
Date: 2024-05-20 17:56:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-06-17 10:42:02
FilePath: \Script\Game\PWorld\Match\PWorldMatchVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PWorldMatchVM = LuaClass(UIViewModel)
local UIBindableList = require("UI/UIBindableList")
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local PWorldHelper = require("Game/PWorld/PWorldHelper")

local LSTR = _G.LSTR

local PWorldMatchItemVM = require("Game/PWorld/Match/PWorldMatchItemVM")

function PWorldMatchVM:Ctor()
    self.IsMatching = false
    self.MatchItemVMs = UIBindableList.New(PWorldMatchItemVM)
    self.MatchCnt = 0
    self.MatchMaxCnt = 5
    self.IsDailyRandom = false
    self.Title = ""
    self.bShowRobotGuide = false
    self.bRobotGuideChecked = true
end

function PWorldMatchVM:UpdateVM()
    local PWorldMatchMgr = _G.PWorldMatchMgr
    self.IsMatching = PWorldMatchMgr:IsMatching()
    self.MatchCnt = PWorldMatchMgr:GetMatchItemCnt()
    
    -- 在不改变原有逻辑上增加if判断，这里先判断副本，在判断玩法 前置条件是两种匹配不能共存
    if self.MatchCnt > 0 then
        self.IsDailyRandom = PWorldMatchMgr:IsDailyRandomStat()
        self.MatchMaxCnt = self.IsDailyRandom and PWorldEntDefine.RandMatchMaxCnt or PWorldEntDefine.NormMatchMaxCnt
        local Items = PWorldMatchMgr:GetMatchItems()
        local Data = {}
        for Idx = 1, self.MatchMaxCnt do
            if Items[Idx] then
                table.insert(Data, {EntID = Items[Idx], Enable = true})
            else
                table.insert(Data, {Enable = false})
            end
        end

        self.MatchItemVMs:UpdateByValues(Data)
        self:UpdTitle()
    elseif PWorldMatchMgr:GetCrystallineItemCnt() > 0 or PWorldMatchMgr:GetFrontlineItemCnt() > 0 then
        self.MatchCnt = PWorldMatchMgr:GetCrystallineItemCnt() + PWorldMatchMgr:GetFrontlineItemCnt()
        self.MatchMaxCnt = PWorldEntDefine.PVPMatchMaxCnt
        local Items = {}
        local CrystallineMatchItems = PWorldMatchMgr:GetCrystallineItems()
        local FrontlineMatchItems = PWorldMatchMgr:GetFrontlineItems()
        Items = table.merge_table(Items, CrystallineMatchItems)
        Items = table.merge_table(Items, FrontlineMatchItems)
        local Data = {}
        for Idx = 1, self.MatchMaxCnt do
            if Items[Idx] then
                table.insert(Data, {EntID = Items[Idx], Enable = true})
            else
                table.insert(Data, {Enable = false})
            end
        end

        self.MatchItemVMs:UpdateByValues(Data)
        self:UpdatePVPTitle()
    elseif PWorldMatchMgr:GetMatchChocoboItemCnt() > 0 then
        self.MatchCnt = PWorldMatchMgr:GetMatchChocoboItemCnt()
        self.IsDailyRandom = false
        self.MatchMaxCnt = 1
        local Items = PWorldMatchMgr:GetMatchChocoboItems()
        local Data = {}
        for Idx = 1, self.MatchMaxCnt do
            if Items[Idx] then
                table.insert(Data, {EntID = Items[Idx], Enable = true})
            else
                table.insert(Data, {Enable = false})
            end
        end

        self.MatchItemVMs:UpdateByValues(Data)
        self:UpdChocoboTitle()
    end

    self:UpdateMatchGuide()
end

function PWorldMatchVM:UpdTitle()
    local fmt = self.IsDailyRandom and PWorldHelper.GetPWorldText("DAILY_MATCH_TITLE") or PWorldHelper.GetPWorldText("NORMAL_MATCH_TITLE")
    self.Title = string.sformat(fmt, self.MatchCnt, self.MatchMaxCnt)
end

function PWorldMatchVM:UpdatePVPTitle()
    self.Title = PWorldHelper.pformat("PVP_MATCH_TITLE", self.MatchMaxCnt, self.MatchCnt, self.MatchMaxCnt)
end

function PWorldMatchVM:UpdChocoboTitle()
    -- LSTR string: 陆行鸟竞赛
    local TaskName = LSTR(430009)
    self.Title = PWorldHelper.pformat("MATCH_NUM_LIMIT", self.MatchMaxCnt, TaskName, self.MatchCnt, self.MatchMaxCnt)
end

function PWorldMatchVM:UpdateMatchRank()
    for _, Item in pairs(self.MatchItemVMs:GetItems() or {}) do
        Item:UpdateMatchRank()
    end
end

function PWorldMatchVM:UpdateMatchGuide()
    local bHasRobotGuideMatch = false
    local bHasUnchecked
    
    for _, Item in ipairs(_G.PWorldMatchMgr.Matches or {}) do
        if _G.PWorldMatchMgr.IsRobotMatchNeed(Item.EntID) then
            bHasRobotGuideMatch = true
            if _G.PWorldMatchMgr:IsRobotMatchUnChecked(Item.EntID)  then
                bHasUnchecked = true
            end
        end
    end

    self.bShowRobotGuide = bHasRobotGuideMatch
    self.bRobotGuideChecked = bHasRobotGuideMatch and not bHasUnchecked
end

function PWorldMatchVM:UpdateLackProf()
    for _, Item in pairs(self.MatchItemVMs:GetItems() or {}) do
        Item:UpdateLackProf()
    end
end

return PWorldMatchVM
