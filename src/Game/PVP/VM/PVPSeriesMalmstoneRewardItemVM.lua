local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local SeriesMalmstoneBreakThroughCfg = require("TableCfg/SeriesMalmstoneBreakThroughCfg")
local SeriesMalmstoneRewardCfg = require("TableCfg/SeriesMalmstoneRewardCfg")

local PVPInfoMgr = _G.PVPInfoMgr

---@class PVPSeriesMalmstoneRewardItemVM : UIViewModel
local PVPSeriesMalmstoneRewardItemVM = LuaClass(UIViewModel)

function PVPSeriesMalmstoneRewardItemVM:Ctor()
    self.ID = nil
    self.BreakThroughTargetList = {}
    self.IsBreakThroughLevel = false -- 是否为突破等级
    self.IsBrokeThrough = false  -- 是否已突破
    self.IsReachLevel = false
    self.Level = nil
    self.UpExp = 0
    self.IsLocked = false
    self.IsReceivedReward = false
    self.ResID = nil
    self.IconPath = nil
    self.Num = nil
    self.IsSelected = false
    self.TextColor = "828282FF"
    self.Percent = 0
    self.IsLevelMax = false
end

function PVPSeriesMalmstoneRewardItemVM:UpdateVM(Params)
    local RewardCfg = SeriesMalmstoneRewardCfg:FindCfgByKey(Params.ID)
    if RewardCfg == nil then return end

    self.ID = RewardCfg.ID
    self.Level = RewardCfg.Level
    self.IsReceivedReward = PVPInfoMgr:IsReceivedRewardByID(RewardCfg.ID)
    self.UpExp = RewardCfg.UpExp
    self.ResID = RewardCfg.BasicReward[1].ID
    self.IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(RewardCfg.BasicReward[1].ID))
    self.Num = RewardCfg.BasicReward[1].Num

    local IsReachLevel = PVPInfoMgr:GetSeriesMalmstoneLevel() >= RewardCfg.Level
    local IsBreakThroughLevel, BreakThroughTargetList, IsBrokeThrough = self:GetBreakThroughData(RewardCfg.ID)
    self.IsReachLevel = IsReachLevel
    self.IsBreakThroughLevel = IsBreakThroughLevel
    self.TextColor = IsReachLevel and "FBECC1FF" or "828282FF"
    self.BreakThroughTargetList = BreakThroughTargetList
    self.IsBrokeThrough = IsBrokeThrough
    self.IsLocked = IsBreakThroughLevel and (not IsBrokeThrough)

    self.IsLevelMax = self:CheckLevelMax(RewardCfg.Level)
    self.Percent = self:GetLevelProgress() 
end

function PVPSeriesMalmstoneRewardItemVM:GetBreakThroughData(ID)
    local IsBreakThroughLevel = false
    local BreakThroughTargetList = {}
    local IsLevelBrokeThrough = true

    local RewardCfg = SeriesMalmstoneRewardCfg:FindCfgByKey(ID)
    if RewardCfg then
        for _, TargetID in pairs(RewardCfg.BreakThroughTarget or {}) do
            if TargetID ~= 0 then
                IsBreakThroughLevel = true

                local IsTargetBrokeThrough = false
                local TargetDescription = ""
                local TargetCurCount = 0
                local TargetMaxCount = 0
                local TargetGameType = 0
                local BreakThroughCfg = SeriesMalmstoneBreakThroughCfg:FindCfgByKey(TargetID)
                if BreakThroughCfg then
                    TargetDescription = BreakThroughCfg.Description
                    TargetMaxCount = BreakThroughCfg.ConditionParam
                    TargetGameType = BreakThroughCfg.GameType
                    if PVPInfoMgr:GetSeriesMalmstoneLevel() >= RewardCfg.Level then
                        IsTargetBrokeThrough = true
                        TargetCurCount = BreakThroughCfg.ConditionParam
                    else
                        IsTargetBrokeThrough, TargetCurCount = PVPInfoMgr:IsTargetBrokeThrough(TargetID)
                    end
                end
                IsLevelBrokeThrough = IsLevelBrokeThrough and IsTargetBrokeThrough

                local Data = {
                    TargetID = TargetID,
                    IsTargetBrokeThrough = IsTargetBrokeThrough,
                    Description = TargetDescription,
                    TargetCurCount = TargetCurCount,
                    TargetMaxCount = TargetMaxCount,
                    GameType = TargetGameType
                }
                table.insert(BreakThroughTargetList, Data)
            end
        end
    end

    return IsBreakThroughLevel, BreakThroughTargetList, IsLevelBrokeThrough
end

function PVPSeriesMalmstoneRewardItemVM:GetLevelProgress()
    local CurLevel = PVPInfoMgr:GetSeriesMalmstoneLevel()
    local CfgLevel = self.Level
    if CurLevel > CfgLevel then
        return 1
    end

    if CurLevel == CfgLevel then
        local NextLevel = CfgLevel + 1
        local NextLevelCfg = PVPInfoMgr:GetCurSeasonSeriesMalmstoneLevelCfg(NextLevel)
        if NextLevelCfg then
            local IsBreakThroughLevel = self:CheckIsBreakThroughLevel(NextLevelCfg.ID)
            if IsBreakThroughLevel then
                local CurExp = PVPInfoMgr:GetCurSeriesMalmstoneExp()
                local NeedExp = self.UpExp
                if CurExp and NeedExp then
                    return CurExp >= NeedExp and 1 or 0
                end
            end
        end
    end
    return 0
end

function PVPSeriesMalmstoneRewardItemVM:CheckIsBreakThroughLevel(ID)
    local IsBreakThroughLevel = false
    local RewardCfg = SeriesMalmstoneRewardCfg:FindCfgByKey(ID)
    if RewardCfg then
        for _, TargetID in pairs(RewardCfg.BreakThroughTarget or {}) do
            if TargetID ~= 0 then
                IsBreakThroughLevel = true
                break
            end
        end
    end
    return IsBreakThroughLevel
end

function PVPSeriesMalmstoneRewardItemVM:CheckLevelMax(Level)
    local CurSeasonCfg = PVPInfoMgr:GetCurSeasonSeriesMalmstoneCfg()
    if CurSeasonCfg then
        return Level >= CurSeasonCfg.LevelMax
    end

    return false
end

function PVPSeriesMalmstoneRewardItemVM:OnSelectChanged(IsSelected)
    self.IsSelected = IsSelected
end

return PVPSeriesMalmstoneRewardItemVM