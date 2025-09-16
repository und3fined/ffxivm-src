--
-- Author: ZhengJianChuan
-- Date: 2024-11-18 10:51
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local LevequestCfg = require("TableCfg/LevequestCfg")
local LevequestBgCfg = require("TableCfg/LevequestBgCfg")
local NpcCfg = require("TableCfg/NpcCfg")

local ProfUtil = require("Game/Profession/ProfUtil")

local LSTR = _G.LSTR
local LeveQuestMgr = _G.LeveQuestMgr

local LeveQuestTaskInfoItemVM = require("Game/LeveQuest/VM/Item/LeveQuestTaskInfoItemVM")

---@class LeveQuestMainPanelVM : UIViewModel
local LeveQuestMainPanelVM = LuaClass(UIViewModel)

---Ctor
function LeveQuestMainPanelVM:Ctor()
    self.ProfLv = ""
    self.ProfIcon = nil
    self.ProfExpPercent = nil
    self.ProfExp = ""
    self.SingleChecked = nil
    self.QuestPlace = ""
    self.QuestNpcImg = ""
    self.QuestLimitNum = ""
    self.LeveQuestVM1 = LeveQuestTaskInfoItemVM.New()
    self.LeveQuestVM2 = LeveQuestTaskInfoItemVM.New()

    self.IsEmpty = false
    self.EffProBarVisible = false
end

function LeveQuestMainPanelVM:OnInit()
end

function LeveQuestMainPanelVM:OnBegin()
end

function LeveQuestMainPanelVM:OnEnd()
end

function LeveQuestMainPanelVM:OnShutdown()
end

-- 更新理符对应等级的委托（每个等级段，只有2个）
function LeveQuestMainPanelVM:UpdateLeveQuestItems(ProdID,Level)
    if Level == nil then
        return
    end

    local Cfgs = LevequestCfg:FindAllCfg(string.format("ProfType == %s and Level == %s",tostring(ProdID), tostring(Level)))
    for index, value in ipairs(Cfgs) do
        local ItemVM = index == 1 and self.LeveQuestVM1 or self.LeveQuestVM2
        ItemVM:UpdateVM(value)
    end
end

-- 更新背景图跟发行人
function LeveQuestMainPanelVM:UpdateBackground(ProfID, Level)
    local Cfg = LevequestBgCfg:FindCfg(string.format("ProfID == %d and Level == %d", ProfID, Level))
    if Cfg == nil then
        return
    end

    self.QuestNpcImg = Cfg.Background
    local NPC = NpcCfg:FindCfgByKey(Cfg.PublishID)
    if NPC and NPC.Name ~= nil then
        self.QuestPlace = string.format("%s", NPC.Name)
    end
end


-- 更新理符限制信息
function LeveQuestMainPanelVM:UpdateLeveQuestInfo()
    local TotalRestoreNum = LeveQuestMgr:GetResotreTotalNum()
    local RestoreNum = LeveQuestMgr:GetRestoreNum()

    self.QuestLimitNum = string.format("%d/%d", RestoreNum,TotalRestoreNum)
end

-- 更新职业
function LeveQuestMainPanelVM:UpdateProfLv(ProfID)
    local Lv =  LeveQuestMgr:GetProfCurLevel(ProfID) or 1
    self.ProfLv = string.format(LSTR(880001), Lv)
end

-- 更新职业图标
function LeveQuestMainPanelVM:UpdateProfIcon(ProfID)
    self.ProfIcon = ProfUtil.Prof2Icon(ProfID) or ""
end

-- 更新经验值
function LeveQuestMainPanelVM:UpdateExpValue(ProfID, Params)
    local CurExp = LeveQuestMgr:GetProfCurExp(ProfID)
    local CurLevel =  LeveQuestMgr:GetProfCurLevel(ProfID)
    if Params then CurExp = Params.ULongParam3 end

    --_G.FLOG_INFO(" LeveQuestMainPanelVM:UpdateExpValue " .. ProfID .. " Level : " .. CurLevel .. ", ExP :".. CurExp)

    local LevelCfg = LevelExpCfg:FindCfgByKey(CurLevel)
    if LevelCfg == nil then
        self.ProfExpPercent = 1
        self.ProfExp = string.format("%s", LSTR(880002))  -- 没配就是满级
    else
        local MaxExp = LevelCfg.NextExp
        self.ProfExp = string.format("%d/%d", CurExp, MaxExp)
        self.ProfExpPercent = CurExp < MaxExp and CurExp/MaxExp or 1
    end
end

--要返回当前类
return LeveQuestMainPanelVM